import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import{ reduceErrors } from './utils';

import LightningConfirm from 'lightning/confirm';
import fetchRoles from '@salesforce/apex/RoleHierarchyController.fetchRoles';
import updateParent from '@salesforce/apex/RoleHierarchyController.updateParent';
import updateUsers from '@salesforce/apex/RoleHierarchyController.updateUsers';

import VIEW_ROLES from '@salesforce/userPermission/ViewRoles';
import VIEW_ALL_USERS from '@salesforce/userPermission/ViewAllUsers';
import MANAGE_ROLES from '@salesforce/userPermission/ManageRoles';
import MANAGE_USERS from '@salesforce/userPermission/ManageUsers';

export default class RoleHierarchyTree extends LightningElement
{
    roleTree = [];
    rawRoles = [];

    focusNodeId = null;
    focusUserId = null;
    cutRoleId = null;
    cutRoleName = null;
    cutUserIds = null;
    cutUserNames = null;
    cutUserRoleId = null;

    selectedRoleId = null;
    isUpdating = false;

    roleOptions = [];
    allOptions = [];

    roleComponents = {};
    expandedStateMap = {};
    allCollapsed = false;

    connectedCallback()
    {
        console.log(`User can view roles --> ${VIEW_ROLES}`);

        if(this.canViewRoles)
        {   this.loadRoles();
            document.addEventListener('roledisconnect', this.handleRoleDisconnect.bind(this));
        }
        else
        {   this.showErrorToast('Access denied: insufficient permissions to manage the Role Hierarchy.', 'If you think this is a mistake, please reach out to your Administrator.');
        }
    }

    async loadRoles(focusId)
    {   try
        {   const data = await fetchRoles();
            this.rawRoles = Array.isArray(data) ? data : [];
            this.roleTree = this.buildRoleHierarchy(this.rawRoles);
            this.roleOptions = this.buildSearchOptions(this.rawRoles);
            this.allOptions = this.roleOptions;
            if(focusId){ this.focusNodeId = focusId; }
        }
        catch(error)
        {   this.showErrorToast('Load Failed', reduceErrors(error).join(' | '));
        }
    }

    buildRoleHierarchy(flatRoles)
    {   const map = {};
        flatRoles.forEach(role => {
            map[role.Id] = {
                ...role,
                children: [],
                expanded: this.expandedStateMap[role.Id] ?? true
            };
        });

        const tree = [];

        flatRoles.forEach((role) =>
        {   if(role.ParentRoleId && map[role.ParentRoleId])
            {   map[role.ParentRoleId].children.push(map[role.Id]);
            }
            else
            {   tree.push(map[role.Id]);
            }
        });

            // Mark last child and set branchClass
        Object.values(map).forEach(parent => {
            if (parent.children.length > 0) {
                const lastIndex = parent.children.length - 1;
                parent.children.forEach((child, i) => {
                    const isLast = i === lastIndex;
                    child.branchClass = isLast ? 'node-branch last-child' : 'node-branch';
                });
            }
        });

        return tree;
    }

    buildSearchOptions(flatRoles)
    {   return flatRoles.map((r) => ({ label: r.Name, value: r.Id, type: 'role' })).sort((a, b) => a.label.localeCompare(b.label));
    }

    handleRoleInit(event)
    {   const { roleId, componentRef } = event.detail;
        this.roleComponents[roleId] = componentRef;
    }

    handleRoleDisconnect(event)
    {   const { roleId } = event.detail;
        if(this.roleComponents[roleId])
        {   delete this.roleComponents[roleId];
        }
    }

    handleSearchSelect(event)
    {
        const { roleId, userId, isActive } = event.detail || {};
        const targetRoleId = roleId || null;
        const targetUserId = userId || null;

        if(!targetRoleId){ return; }

        const expandedRoleIds = this.getAncestorIds(targetRoleId);
        expandedRoleIds.add(targetRoleId);
        const hasMissing = [...expandedRoleIds].some(id => !(id in this.roleComponents));

        if(hasMissing)
        {       // console.log("There are disconnected roles ---> " + hasMissing);
            expandedRoleIds.forEach((id) => { this.expandedStateMap[id] = true; });
            this.allCollapsed = false;
            this.roleTree = this.buildRoleHierarchy(this.rawRoles);
        }
        else
        {   this.highlightRole(targetRoleId);

            if(userId)
            {   const roleComp = this.roleComponents[roleId];
                if(roleComp)
                {   roleComp.focusOnUser(userId, isActive);
                }
            }
        }

        this.focusNodeId = targetRoleId;
        this.focusUserId = targetUserId;
        this.focusOnUserIsActive = isActive;
    }

    getAncestorIds(roleId)
    {   const ids = new Set();
    	let current = this.rawRoles.find(r => r.Id === roleId);

    	while(current && current.ParentRoleId)
    	{	ids.add(current.ParentRoleId);
    		current = this.rawRoles.find(r => r.Id === current.ParentRoleId);
    	}

    	return ids;
    }

    handleRoleFocus(event)
    {   this.highlightRole(this.focusNodeId);

        if(this.focusUserId)
        {   const roleComp = this.roleComponents[this.focusNodeId];
            roleComp.focusOnUser(this.focusUserId, this.focusOnUserIsActive);
        }

        this.focusNodeId = null;
        this.focusUserId = null;
        this.focusOnUserIsActive = null;

    }

    handleRoleCut(event)
    {   const cutRoleId = event.detail.roleId;
        if(cutRoleId)
        {   const cutRoleName = this.rawRoles.find(r => r.Id === cutRoleId).Name;
            this.cutRoleId = cutRoleId;
            this.cutRoleName = cutRoleName;
        }
        else
        {   this.cutRoleId = null;
            this.cutRoleName = null;
        }
    }

    handleUsersCut(event)
    {   const cutUserIds = event.detail.userIds;
        const cutUserNames = event.detail.userNames;
        const cutUserRoleId = event.detail.roleId;

        if(cutUserIds)
        {   this.cutUserIds = cutUserIds;
            this.cutUserNames = cutUserNames;
            this.cutUserRoleId = cutUserRoleId;
        }
        else
        {   this.cutUserIds = null;
            this.cutUserNames = null;
            this.cutUserRoleId = null;
        }
    }

    handleNewRoleClick()
    {   // console.log('New Role button clicked');
    }

    handleToggleNode(event)
    {   const { roleId, expanded } = event.detail;
        this.expandedStateMap[roleId] = expanded;
    }

    handleExpandCollapseAll()
    {   this.allCollapsed = !this.allCollapsed;
        this.expandedStateMap = {};

        if(this.allCollapsed)
        {   for(const role of this.rawRoles)
            {   this.expandedStateMap[role.Id] = false;
            }
        }

        this.roleTree = this.buildRoleHierarchy(this.rawRoles);
    }

    async handleRoleDrop(event)
    {   const parentRoleId = event.detail.parentRoleId;
        const childRoleId = event.detail.childRoleId;

        const parentRole = this.rawRoles.find(r => r.Id === parentRoleId);
        const childRole = this.rawRoles.find(r => r.Id === childRoleId);

//        console.log('RoleHierarchyTree.handleRoleDrop detail ---> ' + JSON.stringify(event.detail));

        if(childRoleId && childRoleId !== parentRoleId)
        {
            const result = await LightningConfirm.open(
                {   message: `Move role "${childRole.Name}" under "${parentRole.Name}"?`,
                    variant: 'header',
                    label: 'Confirm Role Move'
                });

            if (result)
            {   this.moveRole(parentRoleId, childRoleId)
            }
        }
    }

    async handleUserDrop(event)
    {   const roleFromId = event.detail.roleFromId;
        const roleToId = event.detail.roleToId;
        const userIds = event.detail.userIds;
        const userNames = event.detail.userNames;

        const roleFrom = this.rawRoles.find(r => r.Id === roleFromId);
        const roleTo = this.rawRoles.find(r => r.Id === roleToId);

//        console.log('RoleHierarchyTree.handleRoleDrop detail ---> ' + JSON.stringify(event.detail));

        if(roleFromId && roleToId && roleFromId !== roleToId)
        {
            const result = await LightningConfirm.open(
                {   message: `Move user${userNames> 1 ? 's' : ''} "${userNames}" from Role "${roleFrom.Name}" to "${roleTo.Name}"?`,
                    variant: 'header',
                    label: 'Confirm User(s) Move'
                });

            if(result)
            {   this.moveUsers(roleToId, roleFromId, JSON.parse(userIds));
                this.cutUserRoleId = null;
                this.cutUserIds = null;
                this.cutUserNames = null;
            }
        }
    }

    handleNewRoleCreated(event)
    {   const newId = event.detail?.newRoleId;
        if(newId)
        {   fetchRoles().then(data =>
            {   this.rawRoles = data;
                this.roleTree = this.buildRoleHierarchy(data);
                this.allOptions = this.buildSearchOptions(data);
                this.highlightRole(newId);
                this.selectedRoleId = null;

                this.showSuccessToast('New role created successfully.');
            });
        }
    }

    handleRoleUpdated(event)
    {   const updatedId = event.detail?.updatedRoleId;
        if(updatedId)
        {   fetchRoles().then(data =>
            {   this.rawRoles = data;
                this.roleTree = this.buildRoleHierarchy(data);
                this.allOptions = this.buildSearchOptions(data);
                this.highlightRole(updatedId);
                this.selectedRoleId = null;

                this.showSuccessToast('Role updated successfully.');
            });
        }
    }

    async handleRoleDelete(event)
    {   const roleId = event.detail?.roleId;
        const role = this.rawRoles.find(r => r.Id === roleId);

        const result = await LightningConfirm.open(
            {   message: `Are you sure you want to delete role "${role.Name}"?`,
                variant: 'header',
                label: 'Confirm Role Delete'
            });

        try
        {   if(result)
            {   this.isUpdating = true;
                await deleteRecord(role.Id);
                fetchRoles()
                .then(data =>
                {   this.isUpdating = false;
                    this.rawRoles = data;
                    this.roleTree = this.buildRoleHierarchy(data);
                    this.allOptions = this.buildSearchOptions(data);
                    this.highlightRole(role.ParentRoleId);
                    this.selectedRoleId = null;
                });
            }
        }
        catch(error)
        {   this.isUpdating = false;
//            console.log(`Error ---> ${JSON.stringify(error)}`);
            this.dispatchEvent(new ShowToastEvent({ title: 'Error deleting record', message: reduceErrors(error).join(', '), variant: 'error' }));
        }
    }

    moveRole(parentRoleId, childRoleId)
    {   this.isUpdating = true;

        updateParent({ roleId: childRoleId, newParentId: parentRoleId })
        .then(uRole =>
        {
            this.rawRoles = this.rawRoles.map(role => role.Id === childRoleId ? { ...role, ParentRoleId: parentRoleId } : role);
            
            this.cutRoleId = null;
            this.selectedRoleId = null;

            this.showSuccessToast('Role moved successfully');
            
            // Ensure parent is expanded in the state map
            this.expandedStateMap[parentRoleId] = true;
            
            // Rebuild the tree with updated expansion state
            this.roleTree = this.buildRoleHierarchy(this.rawRoles);
            
            // Set focusNodeId so the child will be highlighted when it renders
            this.focusNodeId = childRoleId;
            
            // Wait for the tree to rebuild and components to re-render
            setTimeout(() => {
                // Ensure parent is expanded (in case it was collapsed)
                if(this.roleComponents[parentRoleId]) {
                    this.roleComponents[parentRoleId].expandChildren();
                }
                
                // Set highlight flag for the child
                setTimeout(() => {
                    const childComp = this.roleComponents[childRoleId];
                    if(childComp) {
                        childComp.setHighlight();
                        childComp.highlight();
                    }
                    
                    // Clear focusNodeId after highlighting
                    setTimeout(() => {
                        this.focusNodeId = null;
                    }, 100);
                }, 100);
            }, 100);
        })
        .catch(error =>
        {   const friendlyMessage = reduceErrors(error);
            this.showErrorToast('Paste Failed', friendlyMessage.join(' | '));
        })
        .finally(() =>
        {   this.isUpdating = false;
        });
    }

    moveUsers(roleId, roleFromId, userIds)
    {   this.isUpdating = true;
//        console.log('Moving users from one role to another...');
        updateUsers({ roleFromId: roleFromId, roleToId: roleId, userIds: userIds })
        .then(result =>
            {
                result.forEach(role => {
                    const hRole = this.rawRoles.find(r => r.Id === role.Id);
                    const tRole = this.findRoleNodeById(role.Id);
                    hRole.TotalUsers = tRole.TotalUsers = role.TotalUsers;
                    hRole.ActiveUsers = tRole.ActiveUsers = role.ActiveUsers;
                    hRole.InactiveUsers = tRole.InactiveUsers = role.InactiveUsers;
                });

                this.refreshRole(roleId);
                this.refreshRole(roleFromId);
                this.highlightRole(roleId);
            })
            .catch(error =>
            {   console.log('Error ---> ', error);
                const friendlyMessage = reduceErrors(error);
                this.showErrorToast('Paste Failed', friendlyMessage.join(' | '));
            })
            .finally(() =>
            {   this.isUpdating = false;
            });
    }

    findRoleNodeById(roleId, nodes = this.roleTree)
    {   for (const node of nodes)
        {   if (node.Id === roleId)
            {   return node;
            }

            if (node.children && node.children.length > 0)
            {   const found = this.findRoleNodeById(roleId, node.children);
                if (found) return found;
            }
        }

        return null;
    }


    refreshRole(roleId)
    {   const roleComp = this.roleComponents[roleId];
        if(roleComp)
        {   roleComp.refreshUsers();
        }
    }

    highlightRole(roleId)
    {   const roleComp = this.roleComponents[roleId];
        if(roleComp)
        {   //roleComp.highlight();
             roleComp.setHighlight();
        }
    }

    extractErrorMessage(error)
    {   try
        {   if(error?.body?.fieldErrors)
            {   const fieldErrors = error.body.fieldErrors;
                const pageErrors = error.body.pageErrors;
                const messages = [];
                Object.keys(fieldErrors).forEach(field => { fieldErrors[field].forEach(fe => { messages.push(fe.message); }); });
                Object.keys(pageErrors).forEach(field => { fieldErrors[field].forEach(fe => { messages.push(fe.message); }); });
                return messages.join(' | ');
            }
            else if(error?.body?.message){ return error.body.message; }
            else if(error?.message){ return error.message; }

            return 'An unknown error occurred.';
        }
        catch(e)
        {   return 'Error parsing error object.';
        }
    }

    showErrorToast(title, message)
    {   this.dispatchEvent(new ShowToastEvent({title: title, message: message, variant: 'error', mode: 'sticky'}));
    }

    showSuccessToast(title)
    {   this.dispatchEvent(new ShowToastEvent({title: title, variant: 'success', mode: 'dismissable'}));
    }

    get expandCollapseAllLabel(){ return this.allCollapsed ? '▶ Expand All' : '▼ Collapse All'; }
    get canViewRoles(){ return VIEW_ROLES; }
    get canManageRoles(){ return MANAGE_ROLES; }
    get canManageUsers(){ return MANAGE_USERS; }
    get canViewAllUsers(){ return VIEW_ALL_USERS; }
    get searchForUsers(){ return this.canViewAllUsers || this.canManageUsers; }

}
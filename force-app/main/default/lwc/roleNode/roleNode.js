import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/ldsUtils';
import LightningConfirm from 'lightning/confirm';
import RoleUserModal from 'c/roleUserModal';
import RoleCreateModal from 'c/roleCreateModal';

import VIEW_ALL_USERS from '@salesforce/userPermission/ViewAllUsers';
import MANAGE_ROLES from '@salesforce/userPermission/ManageRoles';
import MANAGE_USERS from '@salesforce/userPermission/ManageUsers';

import getUsersByRole from '@salesforce/apex/RoleHierarchyController.getUsersByRole';

export default class RoleNode extends NavigationMixin(LightningElement)
{   @api role;
    @api focusNodeId;
    @api focusUserId;
    @api cutRoleId;
    @api cutRoleName;
    @api cutUserIds;
    @api cutUserRoleId;
    @api cutUserNames;
    @api expandedStateMap;

    @track isDragOver = false;
    @track isHovered = false;
    @track expanded = true;
    @track showUsers = false;
    @track showActiveUsersOnly = true;
    @track cutConfirmed = false;
    @track cutSelectedUsersConfirmed = false;
    @track totalUsers = 0;

    @track users = [];
    @track selectedUserIds = new Set();
    @track toHighlight = false;

    _focused = false;
    _pendingScrollUserId = null;

    connectedCallback()
    {   if(this.role)
        {   this.dispatchEvent(new CustomEvent('roleinit', { detail: { roleId: this.role.Id, componentRef: this }, bubbles: true, composed: true }));
            this.totalUsers = this.role.TotalUsers;

                // In case the node element is just being reconnecting to DOM
            if(this.role?.Id === this.focusNodeId)
            {   this.dispatchEvent(new CustomEvent('rolefocus', { detail: { roleId: this.role.Id, componentRef: this }, bubbles: true, composed: true }));
            }
        }
    }

    disconnectedCallback()
    {   Promise.resolve().then(() => { document.dispatchEvent(new CustomEvent('roledisconnect', { detail: { roleId: this.role.Id } })); });
    }

    renderedCallback()
    {
        if(this.role)
        {   if(this.expandedStateMap)
            {   this.expanded = this.expandedStateMap[this.role.Id] ?? true
            }

            if(this.role.Id === this.cutRoleId)
            {   this.cutRoleId = null;
                this.cutRoleName = null;
            }
        }

        if(this.role?.Id === this.focusNodeId && !this._focused)
        {
            if(this.toHighlight)
            {   this.highlight();
                this.toHighlight = false;
            }

            if(this._pendingScrollUserId)
            {   this.scrollSelectedUserIntoView(this._pendingScrollUserId);
                this._pendingScrollUserId = null;
            }
        }

    }

    @api print()
    {   //console.log(`Role ${this.role.Id} ---> ${this.role.Name}.`);
    }

    @api refreshUsers()
    {   getUsersByRole({ roleId: this.role.Id }).then(data =>
        {   this.users = data;
            this.showUsers = this.users.length > 0;
            this.totalUsers = this.users.length;
            this.selectedUserIds = new Set();
            this.cutSelectedUsersConfirmed = false;
        });
    }

    @api focusOnUser(userId, isActive)
    {   getUsersByRole({ roleId: this.role.Id }).then(data =>
        {   this.users = data;
            this.showUsers = this.users.length > 0;
            this.totalUsers = this.users.length;
            this.showActiveUsersOnly = isActive;
            this.selectedUserIds = new Set();
            this.cutSelectedUsersConfirmed = false;
            this._pendingScrollUserId = userId;
            this.focusNodeId = this.role.Id;
        });
    }

    applyTemporaryFocusRing(el)
    {   try
        {   el.style.outline = '2px solid rgba(27,150,255,1)';
            el.style.outlineOffset = '2px';
            el.style.borderRadius = '4px';
            setTimeout(() =>
                {   try
                    {   el.style.outline = '';
                        el.style.outlineOffset = '';
                    }
                    catch(_){ /* no-op */ }
                }, 5000);
        }
        catch(_){ /* no-op */ }
    }

    @api highlight()
    {   const el = this.template.querySelector('.node-label');

        if(el)
        {   try
            {   el.scrollIntoView({ block: 'center' });
                this.applyTemporaryFocusRing(el);
            }
            catch(_){}
        }
    }

    @api setHighlight()
    {
        this.toHighlight = true;
    }

    @api expandChildren()
    {   this.expanded = true;
    }

    scrollSelectedUserIntoView(userId)
    {   const el = this.template.querySelector(`.user-card[data-id="${userId}"]`);

        if(el)
        {   try
            {   el.scrollIntoView({ block: 'center' });
                this.applyTemporaryFocusRing(el);
            }
            catch(_){}
        }
    }

    handleUserLinkClick(event)
    {   event.stopPropagation();
    }

    handleToggle()
    {   this.expanded = !this.expanded;

        this.dispatchEvent(new CustomEvent('togglenode', {
            detail: { roleId: this.role.Id, expanded: this.expanded },
            bubbles: true,
            composed: true
        }));
    }

    handleToggleInactiveUsers()
    {   this.showActiveUsersOnly = event.target.checked;
    }

    handleDragStart(event)
    {   event.stopPropagation();
//        console.log('Role drag start --->');

        if(event.dataTransfer)
        {   event.dataTransfer.setData('dragType', 'Role');
            event.dataTransfer.setData('roleId', this.role.Id);
        }
    }

    handleUserDragStart(event)
    {   event.stopPropagation();

        const userId = event.currentTarget.dataset.id;

            // If not already selected, reset selection to this only
        if(!this.selectedUserIds.has(userId))
        {   this.selectedUserIds = new Set([userId]);
        }

        const selected = Array.from(this.selectedUserIds);
        const selectedUsers = this.users.filter(u => selected.includes(u.Id));
        const names = selectedUsers.map(u => u.Name);

        event.dataTransfer.setData('dragType', 'User');
        event.dataTransfer.setData('roleId', this.role.Id);
        event.dataTransfer.setData('roleName', this.role.Name);
        event.dataTransfer.setData('userIds', JSON.stringify(Array.from(this.selectedUserIds)));
        event.dataTransfer.setData('userNames', JSON.stringify(names));

//        console.log(`Dragged user names ---> ${JSON.stringify(names)}`);

            // Customize preview text
        let dragText = `${selected.length} user${selected.length > 1 ? 's' : ''}`;
        if(names.length <= 3){ dragText += `: ${names.join(', ')}`; }
        else{ dragText += `: ${names.slice(0, 3).join(', ')}...`; }

        const dragPreview = document.createElement('div');
        dragPreview.style.position = 'absolute';
        dragPreview.style.top = '-1000px';
        dragPreview.style.left = '-1000px';
        dragPreview.style.background = '#fff';
        dragPreview.style.border = '1px solid #ccc';
        dragPreview.style.padding = '10px 10px';
        dragPreview.style.borderRadius = '4px';
        dragPreview.style.fontSize = '0.75rem';
        dragPreview.style.boxShadow = '0 2px 5px rgba(0,0,0,0.2)';
        dragPreview.textContent = dragText;

        document.body.appendChild(dragPreview);
        event.dataTransfer.setDragImage(dragPreview, -30, 30);

        // Clean up after short delay
        setTimeout(() => dragPreview.remove(), 0);
    }

    handleUserSelectChange(event)
    {   const userId = event.target.dataset.id;
        const checked = event.target.checked;
        const newSet = new Set(this.selectedUserIds);

        if (checked)
        {   newSet.add(userId);
        }
        else
        {   newSet.delete(userId);
        }

        this.selectedUserIds = newSet;
    }

    async handleAddRole()
    {   const ret = await RoleCreateModal.open(
            {   size: 'small',
                label: 'New User Role',
                description: 'New User Role',
                parentRole: this.role
            });

        if(ret)
        {   this.dispatchEvent(new CustomEvent('newrolecreated', { detail: { newRoleId: ret.newRoleId }, bubbles: true, composed: true }));
        }
    }

    async handleEditRole()
    {   const ret = await RoleCreateModal.open(
            {   size: 'small',
                label: 'Edit User Role',
                description: 'Edit User Role',
                existingRole: this.role
            });

        if(ret && ret.updatedRoleId)
        {   this.dispatchEvent(new CustomEvent('roleupdated', { detail: { updatedRoleId: ret.updatedRoleId }, bubbles: true, composed: true }));
        }
    }

    handleDeleteRole()
    {   this.dispatchEvent(new CustomEvent('roledelete', { detail: { roleId: this.role.Id }, bubbles: true, composed: true }));
    }

    handleUsers()
    {   RoleUserModal.open(
            {   size: 'medium',
                label: 'Role Users',
                description: `Users in ${this.role.Name}`,
                role: this.role
            });
    }

    allowDrop(event)
    {   event.preventDefault();
        event.stopPropagation();

        this.isDragOver = true;
    }

    handleDrop(event)
    {   event.preventDefault();
        event.stopPropagation();

//        debugger;
        this.isDragOver = false;

        if(event.dataTransfer)
        {
            const dragType = event.dataTransfer.getData('dragType');
            const roleId = event.dataTransfer.getData('roleId');
            const userIds = event.dataTransfer.getData('userIds');
            const userNames = event.dataTransfer.getData('userNames');

            if(dragType === 'Role')
            {   //console.log(`Role handleDrop ---> new parent role for ${roleId} - ${this.role.Name} - [${this.role.Id}][${this.role.Name}]`);
                this.dispatchEvent(new CustomEvent('roledrop', {detail: { parentRoleId: this.role.Id, childRoleId: roleId }, bubbles: true, composed: true}));
            }
            else if(dragType === 'User')
            {   //console.log(`Users handleDrop ---> new role for Users [${userIds}][${userNames}] - [${this.role.Id}][${this.role.Name}]`);
                this.dispatchEvent(new CustomEvent('userdrop', {detail: { roleToId: this.role.Id, roleFromId: roleId, userIds: userIds, userNames: userNames }, bubbles: true, composed: true}));
            }
        }
    }

    handleUndoCut()
    {   this.cutConfirmed = false;
        this.dispatchEvent(new CustomEvent('rolecut', { detail: { roleId: undefined }, bubbles: true, composed: true }));
    }

    handleCut()
    {   this.cutConfirmed = true;
        this.dispatchEvent(new CustomEvent('rolecut', { detail: { roleId: this.role.Id }, bubbles: true, composed: true }));
    }

    handleCutSelectedUsers()
    {   this.cutSelectedUsersConfirmed = true;

        const selected = Array.from(this.selectedUserIds);
        const selectedUsers = this.users.filter(u => selected.includes(u.Id));
        const names = selectedUsers.map(u => u.Name);

        this.dispatchEvent(new CustomEvent('userscut', { detail: { roleId: this.role.Id, userIds: JSON.stringify(selected), userNames: JSON.stringify(names) }, bubbles: true, composed: true }));
    }

    handleUndoCutSelectedUsers()
    {   this.cutSelectedUsersConfirmed = false;
        this.dispatchEvent(new CustomEvent('userscut', { detail: { roleId: null, userIds: null, userNames: null }, bubbles: true, composed: true }));
    }


    handlePaste()
    {   this.dispatchEvent(new CustomEvent('roledrop', {detail: { parentRoleId: this.role.Id, childRoleId: this.cutRoleId }, bubbles: true, composed: true}));
    }

    handlePasteUsers()
    {   this.dispatchEvent(new CustomEvent('userdrop', {detail: { roleToId: this.role.Id, roleFromId: this.cutUserRoleId, userIds: this.cutUserIds, userNames: this.cutUserNames }, bubbles: true, composed: true}));
    }

    handleCancel()
    {   this.dispatchEvent(new CustomEvent('rolecut', { detail: { roleId: null }, bubbles: true, composed: true }));
    }

    handleDragLeave(event)
    {   event.stopPropagation();
        this.isDragOver = false;
    }

    handleMouseOver()
    {   this.isHovered = true;
    }

    handleMouseOut()
    {   this.isHovered = false;
    }

    toggleUserList()
    {   this.showUsers = !this.showUsers;
        this.showActiveUsersOnly = true;
        if(this.showUsers && this.users.length === 0)
        {   getUsersByRole({ roleId: this.role.Id }).then(data => { this.users = data; });
        }
    }

    get showCancelButton(){ if(this.role.Id === this.cutRoleId){ return true; }  }
    get showAddRoleButton(){ return this.canManageRoles; }
    get showEditButton(){ return this.canManageRoles; }
    get showCutSelectedUsersButton(){ return this.selectedUserIds.size > 0; }
    get showPasteUsersButton(){ return this.cutUserIds && !(this.role?.Id === this.cutUserRoleId); }
    get pasteTooltip(){ return `Move Role [${this.cutRoleName}] here.`; }
    get pasteUsersTooltip(){ return `Move Users ${this.cutUserNames} here.`; }
    get isSelected(){ return this.selectedRoleId === this.role.Id; }
    get toggleSymbol(){ return this.role.children && this.role.children.length > 0 ? (this.expanded ? '▼' : '▶') : ''; }
    get isFocused(){ return this.role?.Id === this.focusNodeId; }
    get isTopLevel(){ return !this.role?.ParentRoleId; }
    get showDeleteButton(){ return this.totalUsers === 0 && this.role?.children?.length === 0; }
    get showUsersButton(){ return this.role?.TotalUsers > 0; }
    get usersButtonLabel(){ return `Users [${this.totalUsers}]`; }
    get userLinkClass(){ return this.canManageUsers ? 'user-link' : 'user-link disabled-link'; }
    get userCardClass(){ return this.canManageUsers ? 'user-card draggable' : 'user-card'; }
    get isUserCheckboxDisabled(){ return !this.canManageUsers; }
    get roleNodeStyle(){ return this.canManageRoles ? "cursor: grab;" : "cursor: default;"; }

    get canManageRoles() { return MANAGE_ROLES; }
    get canManageUsers() { return MANAGE_USERS; }
    get canViewAllUsers() { return VIEW_ALL_USERS; }

    get showPasteButton()
    {   if(!this.cutRoleId){ return false; }
        if(this.role.Id === this.cutRoleId){ return false; }
        return true;
    }

    get filteredUsers()
    {   const base = this.showActiveUsersOnly ? this.users.filter(user => user.IsActive) : this.users;
        return base.map(user => ({...user, selected: this.selectedUserIds.has(user.Id) }));
    }

    get filteredUsers()
    {   const base = this.showActiveUsersOnly ? this.users.filter(user => user.IsActive) : this.users;
        return base.map(user => ({...user, selected: this.selectedUserIds.has(user.Id), href: '/lightning/r/User/' + user.Id + '/view' }));
    }

    get computedClass()
    {   let classes = 'node-label';
        if(this.isDragOver){ classes += ' drag-over'; }
        return classes;
    }

}
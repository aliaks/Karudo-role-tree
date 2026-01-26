import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningModal from 'lightning/modal';
import getOrgDefaults from '@salesforce/apex/RoleHierarchyController.getOrgDefaults';
import createRole from '@salesforce/apex/RoleHierarchyController.createRole';
import updateRole from '@salesforce/apex/RoleHierarchyController.updateRole';

export default class RoleCreateModal extends LightningModal
{   @api parentRole;
    @api existingRole;  // For edit mode

    error;
    parentRoleId;
    roleId;
    isEditMode = false;

    opportunityAccess = 'None';
    caseAccess = 'None';
    
    orgDefaults;
    minOpportunityAccessLevel = 0;
    minCaseAccessLevel = 0;

    opportunityAccessOptions = [
        { label: 'None', value: 'None', level: 0, helpText: 'Users cannot access opportunities on accounts they own unless they own the opportunity' },
        { label: 'Read', value: 'Read', level: 1, helpText: 'Users can view all opportunities associated with accounts they own' },
        { label: 'Edit', value: 'Edit', level: 2, helpText: 'Users can view and edit all opportunities associated with accounts they own' }
    ];

    caseAccessOptions = [
        { label: 'None', value: 'None', level: 0, helpText: 'Users cannot access cases on accounts they own unless they own the case' },
        { label: 'Read', value: 'Read', level: 1, helpText: 'Users can view all cases associated with accounts they own' },
        { label: 'Edit', value: 'Edit', level: 2, helpText: 'Users can view and edit all cases associated with accounts they own' }
    ];

    connectedCallback()
    {   if(this.existingRole)
        {   // Edit mode - set values immediately
            this.isEditMode = true;
            this.roleId = this.existingRole.Id;
            this.parentRoleId = this.existingRole.ParentRoleId;
            
            // Set access values from existing role immediately
            if(this.existingRole.OpportunityAccessForAccountOwner)
            {   this.opportunityAccess = this.existingRole.OpportunityAccessForAccountOwner;
            }
            if(this.existingRole.CaseAccessForAccountOwner)
            {   this.caseAccess = this.existingRole.CaseAccessForAccountOwner;
            }
        }
        else if(this.parentRole)
        {   // Create mode
            this.parentRoleId = this.parentRole.Id;
        }
        
        this.loadOrgDefaults();
    }
    
    async loadOrgDefaults()
    {   try
        {   this.orgDefaults = await getOrgDefaults();
            this.minOpportunityAccessLevel = this.orgDefaults.opportunityAccessLevel;
            this.minCaseAccessLevel = this.orgDefaults.caseAccessLevel;
            
            // Only update access values if not already set (i.e., in create mode)
            if(!this.isEditMode)
            {   this.opportunityAccess = this.orgDefaults.opportunityAccess;
                this.caseAccess = this.orgDefaults.caseAccess;
            }
            else
            {   // In edit mode, only fall back to org defaults if values weren't set
                if(!this.existingRole.OpportunityAccessForAccountOwner)
                {   this.opportunityAccess = this.orgDefaults.opportunityAccess;
                }
                if(!this.existingRole.CaseAccessForAccountOwner)
                {   this.caseAccess = this.orgDefaults.caseAccess;
                }
            }
        }
        catch(error)
        {   console.error('Error loading org defaults:', error);
            this.error = error;
        }
    }
    
    get filteredOpportunityAccessOptions()
    {   return this.opportunityAccessOptions.map(opt => ({
            ...opt,
            disabled: opt.level < this.minOpportunityAccessLevel,
            checked: opt.value === this.opportunityAccess,
            isDisabled: opt.level < this.minOpportunityAccessLevel
        }));
    }
    
    get filteredCaseAccessOptions()
    {   return this.caseAccessOptions.map(opt => ({
            ...opt,
            disabled: opt.level < this.minCaseAccessLevel,
            checked: opt.value === this.caseAccess,
            isDisabled: opt.level < this.minCaseAccessLevel
        }));
    }

    async handleSubmit(event)
    {   event.preventDefault();
        const fields = event.detail.fields;
        
        try {
            let result;
            if (this.isEditMode) {
                // Update existing role
                result = await updateRole({
                    roleId: this.roleId,
                    name: fields.Name,
                    parentRoleId: fields.ParentRoleId,
                    rollupDescription: fields.RollupDescription || null,
                    caseAccess: this.caseAccess,
                    opportunityAccess: this.opportunityAccess
                });
                
                this.close({ updatedRoleId: result.Id, updatedRole: result });
            } else {
                // Create new role
                result = await createRole({
                    name: fields.Name,
                    parentRoleId: fields.ParentRoleId,
                    developerName: fields.DeveloperName,
                    rollupDescription: fields.RollupDescription || null,
                    caseAccess: this.caseAccess,
                    opportunityAccess: this.opportunityAccess
                });
                
                this.close({ newRoleId: result.Id, newRole: result });
            }
        } catch (error) {
            console.error('Error saving role:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error saving role',
                    message: error.body?.message || error.message || 'An unexpected error occurred.',
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        }
    }

    handleOpportunityAccessChange(event)
    {   this.opportunityAccess = event.target.value;
    }

    handleCaseAccessChange(event)
    {   this.caseAccess = event.target.value;
    }

    get modalTitle()
    {   return this.isEditMode ? 'Edit User Role' : 'Create New User Role';
    }

}
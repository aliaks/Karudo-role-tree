import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningModal from 'lightning/modal';
import getOrgDefaults from '@salesforce/apex/RoleHierarchyController.getOrgDefaults';

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
        {   // Edit mode
            this.isEditMode = true;
            this.roleId = this.existingRole.Id;
            this.parentRoleId = this.existingRole.ParentRoleId;
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
            
            // Set default values to org defaults if not in edit mode
            if(!this.isEditMode)
            {   this.opportunityAccess = this.orgDefaults.opportunityAccess;
                this.caseAccess = this.orgDefaults.caseAccess;
            }
            else
            {   // In edit mode, preserve existing values if they exist
                if(this.existingRole.OpportunityAccessForAccountOwner)
                {   this.opportunityAccess = this.existingRole.OpportunityAccessForAccountOwner;
                }
                else
                {   this.opportunityAccess = this.orgDefaults.opportunityAccess;
                }
                
                if(this.existingRole.CaseAccessForAccountOwner)
                {   this.caseAccess = this.existingRole.CaseAccessForAccountOwner;
                }
                else
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

    handleSuccess(event)
    {   const roleId = event.detail.id;
        if(this.isEditMode)
        {   this.close({ updatedRoleId: roleId });
        }
        else
        {   this.close({ newRoleId: roleId });
        }
    }

    handleError(event)
    {   const error = event.detail;
        console.error('Role creation failed:', error);

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error creating role',
                message: error.message || 'An unexpected error occurred.',
                variant: 'error',
                mode: 'sticky'
            })
        );
    }

    handleSubmit(event)
    {   event.preventDefault();
        const fields = event.detail.fields;
        fields.CaseAccessForAccountOwner = this.caseAccess;
        fields.OpportunityAccessForAccountOwner = this.opportunityAccess;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleOpportunityAccessChange(event)
    {   this.opportunityAccess = event.detail.value;
    }

    handleCaseAccessChange(event)
    {   this.caseAccess = event.detail.value;
    }

    get modalTitle()
    {   return this.isEditMode ? 'Edit User Role' : 'Create New User Role';
    }

}
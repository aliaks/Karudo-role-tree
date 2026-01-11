import { LightningElement, api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import getUsersByRole from '@salesforce/apex/RoleHierarchyController.getUsersByRole';

export default class RoleUserModal extends LightningModal
{
    @api role;
    users = [];
    error;

    activeCount = 0;
    inactiveCount = 0;

    showActiveOnly = false;

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Email', fieldName: 'Email', type: 'email' },
        { label: 'Active', fieldName: 'IsActive', type: 'boolean' }
    ];

    get filteredUsers()
    {   return this.showActiveOnly ? this.users.filter(user => user.IsActive) : this.users;
    }

    connectedCallback()
    {
        getUsersByRole({ roleId: this.role.Id })
            .then(result =>
            {   this.users = result;
                this.activeCount = result.filter(u => u.IsActive).length;
                this.inactiveCount = result.length - this.activeCount;
            })
            .catch(err =>
            {   this.error = err.body?.message || 'Error loading users';
            });
    }

    handleCheckboxChange(event)
    {   this.showActiveOnly = event.target.checked;
    }

    get userRoleLabel()
    {   return `Users: ${this.role.Name}`;
    }
}
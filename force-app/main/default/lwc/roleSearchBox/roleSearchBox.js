// force-app/main/default/lwc/roleSearchBox/roleSearchBox.js
import { LightningElement, api } from 'lwc';
import searchUsers from '@salesforce/apex/RoleHierarchyController.searchUsers';

export default class RoleSearchBox extends LightningElement
{
    @api options = [];        // roles only, from parent
    @api minChars = 2;        // user search threshold
    @api debounceMs = 250;    // type-ahead debounce
    @api maxResults = 50;     // cap for Apex searchUsers
    @api searchForUsers;

    placeholder = 'Search Roles & Users';

    searchKey = '';
    filteredOptions = [];
    highlightedIndex = -1;    // keyboard navigation index

    _timer = null;            // debounce timer
    _searchToken = 0;         // drop stale responses

    handleChange(event)
    {   const q = event.target.value;
        this.searchKey = q;
        this.highlightedIndex = -1;
        if(this._timer){ clearTimeout(this._timer); }
        this._timer = setTimeout(() => { this.refreshDropdown(q); }, this.debounceMs);
    }

    async refreshDropdown(q)
    {   const roles = this.filterRoles(q);
        let users = [];

        if(this.searchForUsers)
        {   if(q && q.trim().length >= this.minChars)
            {   const token = ++this._searchToken;
                try
                {   const res = await searchUsers({ q, size: this.maxResults });
                    if(token === this._searchToken)
                    {   users = (res || []).map((u) => ({ label: `${u.Name} — ${u.Email}`, value: u.Id, type: 'user', roleId: u.UserRoleId, isActive: u.IsActive }));
                    }
                }
                catch(e)
                {   if(token === this._searchToken){ users = []; }
                }
            }
        }
         
        this.filteredOptions = [...roles, ...users].map((opt, index) => ({
            ...opt,
            className: this.getOptionClass(index)
        }));
        this.highlightedIndex = -1;
    }

    filterRoles(q)
    {   if(!q){ return []; }
        const regex = this.buildMultiWordRegex(q);
        return (this.options || [])
            .filter((opt) => regex.test(opt.label))
            .map((opt) => ({ ...opt, type: 'role' }))
            .sort((a, b) => a.label.localeCompare(b.label));
    }

    handleOptionClick(event)
    {   const id = event.currentTarget.dataset.id;
        const opt = this.filteredOptions.find((o) => o.value === id);
        if(!opt){ return; }
        this.selectOption(opt);
    }

    handleKeyDown(event)
    {   if(!this.shouldShowDropdown){ return; }

        const key = event.key;

        if(key === 'ArrowDown')
        {   event.preventDefault();
            this.highlightedIndex = Math.min(this.highlightedIndex + 1, this.filteredOptions.length - 1);
            this.updateOptionClasses();
            this.scrollHighlightedIntoView();
        }
        else if(key === 'ArrowUp')
        {   event.preventDefault();
            this.highlightedIndex = Math.max(this.highlightedIndex - 1, 0);
            this.updateOptionClasses();
            this.scrollHighlightedIntoView();
        }
        else if(key === 'Enter')
        {   event.preventDefault();
            if(this.highlightedIndex >= 0 && this.highlightedIndex < this.filteredOptions.length)
            {   const opt = this.filteredOptions[this.highlightedIndex];
                this.selectOption(opt);
            }
        }
        else if(key === 'Escape')
        {   event.preventDefault();
            this.closeDropdown();
        }
    }

    selectOption(opt)
    {   if(!opt){ return; }
        const detail = (opt.type === 'user') ? { userId: opt.value, roleId: opt.roleId, isActive: opt.isActive } : { roleId: opt.value };
        this.dispatchEvent(new CustomEvent('searchselect', { detail, bubbles: true, composed: true }));
        this.closeDropdown();
    }

    closeDropdown()
    {   this.searchKey = '';
        this.filteredOptions = [];
        this.highlightedIndex = -1;
    }

    scrollHighlightedIntoView()
    {   setTimeout(() =>
        {   const highlighted = this.template.querySelector('.dropdown-option.highlighted');
            if(highlighted)
            {   highlighted.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
            }
        }, 0);
    }

    handleOptionMouseEnter(event)
    {   const index = parseInt(event.currentTarget.dataset.index, 10);
        this.highlightedIndex = index;
        this.updateOptionClasses();
    }

    updateOptionClasses()
    {   this.filteredOptions = this.filteredOptions.map((opt, index) => ({
            ...opt,
            className: this.getOptionClass(index)
        }));
    }

    buildMultiWordRegex(searchString)
    {   const words = searchString.split(/\s+/).map(this.escapeRegex).filter(Boolean);
        const pattern = words.map((w) => '(?=.*' + w + ')').join('') + '.*';
        return new RegExp(pattern, 'i');
    }

    escapeRegex(string)
    {   return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    }

    get shouldShowDropdown()
    {   return this.searchKey?.trim().length > 0 && this.filteredOptions.length > 0;
    }

    getOptionClass(index)
    {   return index === this.highlightedIndex ? 'dropdown-option highlighted' : 'dropdown-option';
    }
}





//import { LightningElement, api } from 'lwc';
//
//export default class RoleSearchBox extends LightningElement
//{
//    @api options = [];
//    searchKey = '';
//    filteredOptions = [];
//
//    handleSearchKeyChange(event)
//    {   this.searchKey = event.target.value;
//
//        if (this.searchKey)
//        {
//            const regex = this.buildMultiWordRegex(this.searchKey);
//            this.filteredOptions = this.options.filter(opt => regex.test(opt.label));
//        }
//        else
//        {
//            this.filteredOptions = [];
//        }
//    }
//
//    handleKeyUp(event)
//    {   const q = event.target.value;
//        this.searchKey = q;
//        if(this._timer){ clearTimeout(this._timer); }
//        this._timer = setTimeout(() =>
//            {   this.filterOptions();
//                if(q && q.trim().length >= this.minChars)
//                {   this.dispatchEvent(new CustomEvent('searchinput', { detail: { q }, bubbles: true, composed: true }));
//                }
//                else
//                {   this.dispatchEvent(new CustomEvent('searchinput', { detail: { q: '' }, bubbles: true, composed: true }));
//                }
//            }, this.debounceMs);
//    }
//
//    handleOptionClick(event)
//    {   const selectedId = event.currentTarget.dataset.id;
//        this.searchKey = '';
//        this.filteredOptions = [];
//
//        this.dispatchEvent(new CustomEvent('searchselect', {
//            detail: { roleId: selectedId }
//        }));
//    }
//
//    buildMultiWordRegex(searchString)
//    {   const words = searchString.split(/\s+/).map(this.escapeRegex).filter(Boolean);
//        const pattern = words.map(word => `(?=.*${word})`).join('') + '.*';
//        return new RegExp(pattern, 'i');
//    }
//
//    escapeRegex(string)
//    {   return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
//    }
//
//    get shouldShowDropdown()
//    {   return this.searchKey?.trim().length > 0 && this.filteredOptions.length > 0;
//    }
//
//}
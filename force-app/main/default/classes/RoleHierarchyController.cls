public with sharing class RoleHierarchyController
{
    @AuraEnabled
    public static UserRole updateParent(String roleId, String newParentId)
    {   UserRole ur = new UserRole(Id = roleId, ParentRoleId = newParentId);
        update ur;
        return ur;
    }

    @AuraEnabled
    public static User updateUser(String roleId, String userId)
    {   User u = new User(Id = userId, UserRoleId = roleId);
        update u;
        return u;
    }

    @AuraEnabled
    public static List<User> updateUserReturnRoleUsers(String roleId, String userId)
    {   User u = new User(Id = userId, UserRoleId = roleId);
        update u;

        return getUsersByRole(roleId);
    }

    @AuraEnabled
    public static List<RoleWithUsers> updateUsers(String roleFromId, String roleToId, String[] userIds)
    {   List<User> uList = [select Id from User where Id in :userIds];
        for(User u : uList){ u.UserRoleId = roleToId; }
        update uList;

        List<RoleWithUsers> ret = new List<RoleWithUsers>();
        ret.add(fetchRoleById(roleFromId));
        ret.add(fetchRoleById(roleToId));

        return ret;
    }

    @AuraEnabled
    public static List<User> getUsersByRole(Id roleId)
    {   return [select Id, Name, Email, IsActive from User where UserRoleId = :roleId order by Name];
    }

    @AuraEnabled
    public static OrgDefaults getOrgDefaults()
    {   
        Organization org = [SELECT Id, DefaultOpportunityAccess, DefaultCaseAccess FROM Organization LIMIT 1];
        return new OrgDefaults(org);
    }

    @AuraEnabled
    public static RoleWithUsers createRole(String name, String parentRoleId, String developerName, String rollupDescription, String caseAccess, String opportunityAccess)
    {
        UserRole role = new UserRole();
        role.Name = name;
        role.ParentRoleId = parentRoleId;
        role.DeveloperName = developerName;
        role.RollupDescription = rollupDescription;
        role.CaseAccessForAccountOwner = caseAccess;
        role.OpportunityAccessForAccountOwner = opportunityAccess;
        
        insert role;
        
        return fetchRoleById(role.Id);
    }

    @AuraEnabled
    public static RoleWithUsers updateRole(String roleId, String name, String parentRoleId, String rollupDescription, String caseAccess, String opportunityAccess)
    {
        UserRole role = new UserRole(Id = roleId);
        role.Name = name;
        role.ParentRoleId = parentRoleId;
        role.RollupDescription = rollupDescription;
        role.CaseAccessForAccountOwner = caseAccess;
        role.OpportunityAccessForAccountOwner = opportunityAccess;
        
        update role;
        
        return fetchRoleById(roleId);
    }

    @AuraEnabled
    public static List<RoleWithUsers> fetchRoles()
    {
        List<UserRole> roles = [select Id, Name, ParentRoleId, CaseAccessForAccountOwner, OpportunityAccessForAccountOwner, (select Id, Name, Email, IsActive from Users) from UserRole where PortalType = 'None'];
        List<RoleWithUsers> result = new List<RoleWithUsers>();

        for (UserRole r : roles)
        {   result.add(new RoleWithUsers(r, false));
        }

        return result;
    }

    @AuraEnabled
    public static RoleWithUsers fetchRoleById(String roleId)
    {   return new RoleWithUsers([select Id, Name, ParentRoleId, CaseAccessForAccountOwner, OpportunityAccessForAccountOwner, (select Id, Name, Email, IsActive from Users) from UserRole where Id = :roleId], false);
    }

    @AuraEnabled(cacheable=true)
    public static List<User> searchUsers(String q, Integer size)
    {   if(String.isBlank(q)){ return new List<User>(); }
        String term = q.trim();
        if(term.length() < 2){ return new List<User>(); }

        Integer lim = (size == null || size <= 0 || size > 100) ? 50 : size;

        List<String> tokens = new List<String>();
        for(String t : term.split(' '))
        {   String tt = t != null ? t.trim() : null;
            if(String.isBlank(tt)){ continue; }
            if(tt.length() > 60){ tt = tt.substring(0,60); } // guard
            tokens.add(String.escapeSingleQuotes(tt));
        }
        if(tokens.isEmpty()){ return new List<User>(); }

        String base = 'select Id, Name, Email, IsActive, UserRoleId from User where UserRoleId != null and UserRole.PortalType = \'None\' ';

        List<String> andClauses = new List<String>();
        for(String tok : tokens)
        {   String xlike = '%' + tok + '%';
            andClauses.add('(' +
                    'Name like \'' + xlike + '\' or ' +
                    'Email like \'' + xlike + '\' or ' +
                    'Username like \'' + xlike + '\' ' +
                    ')');
        }

        String wherePart = andClauses.isEmpty() ? '' : (' and ' + String.join(andClauses, ' and '));
        String soql = base + wherePart + ' ORDER BY Name LIMIT ' + String.valueOf(lim);

        List<User> users = (List<User>) Database.query(soql);
        SObjectAccessDecision dec = Security.stripInaccessible(AccessType.READABLE, users);

        return (List<User>) dec.getRecords();
    }

    public class RoleWithUsers
    {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String ParentRoleId;
        @AuraEnabled public String CaseAccessForAccountOwner;
        @AuraEnabled public String OpportunityAccessForAccountOwner;
        @AuraEnabled public Integer TotalUsers;
        @AuraEnabled public Integer ActiveUsers;
        @AuraEnabled public Integer InactiveUsers;
        @AuraEnabled public List<User> Users;

        public RoleWithUsers(UserRole r, Boolean includeUserList)
        {   Integer active = 0;
            for(User u : r.Users){ if(u.IsActive){ active++; } }

            this.Id = r.Id;
            this.Name = r.Name;
            this.ParentRoleId = r.ParentRoleId;
            this.CaseAccessForAccountOwner = r.CaseAccessForAccountOwner;
            this.OpportunityAccessForAccountOwner = r.OpportunityAccessForAccountOwner;
            this.TotalUsers = r.Users.size();
            this.ActiveUsers = active;
            this.InactiveUsers = this.TotalUsers - active;

            if(includeUserList)
            {   this.Users = r.Users;
            }
        }
    }

    public class OrgDefaults
    {
        @AuraEnabled public String opportunityAccess;
        @AuraEnabled public String caseAccess;
        @AuraEnabled public Integer opportunityAccessLevel;
        @AuraEnabled public Integer caseAccessLevel;

        public OrgDefaults(Organization org)
        {   this.opportunityAccess = mapToRoleAccessValue(org.DefaultOpportunityAccess);
            this.caseAccess = mapToRoleAccessValue(org.DefaultCaseAccess);
            this.opportunityAccessLevel = getAccessLevel(this.opportunityAccess);
            this.caseAccessLevel = getAccessLevel(this.caseAccess);
        }

        private String mapToRoleAccessValue(String orgAccess)
        {   // Map Organization default values to UserRole field values
            if(orgAccess == 'None' || orgAccess == 'Private') return 'None';
            if(orgAccess == 'Read' || orgAccess == 'ReadOnly') return 'Read';
            if(orgAccess == 'Edit' || orgAccess == 'ReadWrite' || orgAccess == 'ReadWriteTransfer' || orgAccess == 'ReadEditTransfer') return 'Edit';
            if(orgAccess == 'All' || orgAccess == 'ControlledByParent') return 'Edit';
            return 'None';
        }

        private Integer getAccessLevel(String access)
        {   if(access == 'None') return 0;
            if(access == 'Read') return 1;
            if(access == 'Edit') return 2;
            return 0;
        }
    }

}
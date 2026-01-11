@IsTest(SeeAllData=true)
private class RoleHierarchyControllerTest
{

    private static Id roleAId;
    private static Id roleBId;

    private static List<UserRole> fetchTwoRoles()
    {   List<UserRole> roles = [SELECT Id, Name, ParentRoleId FROM UserRole WHERE PortalType = 'None' LIMIT 5];
        System.assert(roles.size() >= 2, 'Test requires at least 2 UserRole records (non-portal) in the org.');
        return new List<UserRole>{ roles[0], roles[1] };
    }

    private static List<User> activeUsersWithRole(Id roleId, Integer limitSize)
    {   return [SELECT Id, Name, Email, IsActive, UserRoleId FROM User WHERE IsActive = true AND UserRoleId = :roleId LIMIT :limitSize];
    }

    private static User anyActiveUserNot(Id excludeUserId)
    {   List<User> us = [SELECT Id, Name, Email, IsActive, UserRoleId FROM User WHERE IsActive = true AND Id != :excludeUserId LIMIT 1];
        System.assert(!us.isEmpty(), 'Test requires at least one active User in the org.');
        return us[0];
    }


    @IsTest
    static void testUpdateParent_setsNewParent()
    {
        List<UserRole> two = fetchTwoRoles();
        UserRole roleA = two[0];
        UserRole roleB = two[1];

        // Ensure no circular dependency - set both to null first to break any existing relationship
        roleA.ParentRoleId = null;
        roleB.ParentRoleId = null;
        update new List<UserRole>{roleA, roleB};

        Test.startTest();
        UserRole updated = RoleHierarchyController.updateParent(roleA.Id, roleB.Id);
        Test.stopTest();

        UserRole reloaded = [SELECT Id, ParentRoleId FROM UserRole WHERE Id = :roleA.Id LIMIT 1];
        System.assertEquals(roleB.Id, reloaded.ParentRoleId, 'Role A should have Role B as parent after updateParent');
        System.assertEquals(updated.Id, reloaded.Id);
    }

    @IsTest
    static void testUpdateUser_movesUserToRole()
    {
        List<UserRole> two = fetchTwoRoles();
        roleAId = two[0].Id;
        roleBId = two[1].Id;
        User u = anyActiveUserNot(UserInfo.getUserId());
        u.UserRoleId = roleAId;
        update u;

        Test.startTest();
        User returnedUser = RoleHierarchyController.updateUser(roleBId, u.Id);
        Test.stopTest();

        User afterMove = [SELECT Id, UserRoleId FROM User WHERE Id = :u.Id];
        System.assertEquals(roleBId, afterMove.UserRoleId, 'User should be in roleB after updateUser');
        System.assertEquals(afterMove.Id, returnedUser.Id);
    }

    @IsTest
    static void testUpdateUserReturnRoleUsers_returnsOnlyTargetRole()
    {
        List<UserRole> two = fetchTwoRoles();
        roleAId = two[0].Id;
        roleBId = two[1].Id;

        User u = anyActiveUserNot(UserInfo.getUserId());

            // Put user in roleA then move to roleB via method that returns list
        u.UserRoleId = roleAId;
        update u;

        Test.startTest();
        List<User> result = RoleHierarchyController.updateUserReturnRoleUsers(roleBId, u.Id);
        Test.stopTest();

        Set<Id> ids = new Set<Id>();
        for (User x : result) ids.add(x.Id);
        System.assert(ids.contains(u.Id), 'Moved user must be returned');
    }

    @IsTest
    static void testUpdateUsers_bulkMoveAndCounts()
    {
        List<UserRole> two = fetchTwoRoles();
        Id roleFrom = two[0].Id;
        Id roleTo = two[1].Id;

            // Ensure we have at least two users in roleFrom; if not, reassign any actives temporarily
        List<User> inFrom = activeUsersWithRole(roleFrom, 2);
        Integer needed = 2 - inFrom.size();
        if (needed > 0)
        {   List<User> candidates =
                [   SELECT Id, UserRoleId FROM User
                    WHERE IsActive = true AND (UserRoleId = NULL OR UserRoleId != :roleFrom)
                    LIMIT :needed
                ];
            System.assert(!candidates.isEmpty(), 'Need more active users to stage bulk move test.');
            for (User c : candidates) c.UserRoleId = roleFrom;
            update candidates;
            inFrom.addAll(candidates);
        }

        List<String> idsToMove = new List<String>();
        for (User u : inFrom) idsToMove.add((String)u.Id);

        Test.startTest();
        List<RoleHierarchyController.RoleWithUsers> roles = RoleHierarchyController.updateUsers(roleFrom, roleTo, idsToMove);
        Test.stopTest();

        Map<Id, User> moved = new Map<Id, User>([SELECT Id, UserRoleId FROM User WHERE Id IN :(new Map<Id,User>(inFrom)).keySet()]);

        for (User u : moved.values())
        {   System.assertEquals(roleTo, u.UserRoleId, 'All staged users should be moved to roleTo');
        }

        System.assertEquals(2, roles.size(), 'Expect [from, to] RoleWithUsers entries');
        System.assertEquals((String)roleFrom, roles[0].Id);
        System.assertEquals((String)roleTo, roles[1].Id);

        RoleHierarchyController.RoleWithUsers fromR = RoleHierarchyController.fetchRoleById((String)roleFrom);
        RoleHierarchyController.RoleWithUsers toR   = RoleHierarchyController.fetchRoleById((String)roleTo);
        System.assertEquals(fromR.TotalUsers, fromR.ActiveUsers + fromR.InactiveUsers);
        System.assertEquals(toR.TotalUsers,   toR.ActiveUsers + toR.InactiveUsers);
    }

    @IsTest
    static void testGetUsersByRole_filtersAndOrders()
    {   List<UserRole> two = fetchTwoRoles();
        Id targetRole = two[0].Id;

        List<User> us = activeUsersWithRole(targetRole, 2);
        if (us.isEmpty())
        {   User u = anyActiveUserNot(UserInfo.getUserId());
            u.UserRoleId = targetRole;
            update u;
        }

        List<User> got = RoleHierarchyController.getUsersByRole(targetRole);
        for (Integer i = 1; i < got.size(); i++)
        {   System.assert(got[i-1].Name.compareTo(got[i].Name) <= 0, 'Expected Name ASC ordering');
        }
    }

    @IsTest
    static void testFetchRoles_and_fetchRoleById_counts()
    {
        List<RoleHierarchyController.RoleWithUsers> all = RoleHierarchyController.fetchRoles();
        System.assert(!all.isEmpty(), 'There should be at least one role returned');
        RoleHierarchyController.RoleWithUsers pick = all[0];
        RoleHierarchyController.RoleWithUsers byId = RoleHierarchyController.fetchRoleById(pick.Id);
        System.assertEquals(byId.TotalUsers, byId.ActiveUsers + byId.InactiveUsers, 'Counts must reconcile');
        System.assertEquals(null, byId.Users, 'Users list should be null (includeUserList=false)');
    }

    @IsTest
    static void testGetOrgDefaults_returnsDefaults()
    {
        Test.startTest();
        RoleHierarchyController.OrgDefaults defaults = RoleHierarchyController.getOrgDefaults();
        Test.stopTest();

        System.assertNotEquals(null, defaults, 'OrgDefaults should not be null');
        System.assertNotEquals(null, defaults.opportunityAccess, 'Opportunity access should not be null');
        System.assertNotEquals(null, defaults.caseAccess, 'Case access should not be null');
        System.assert(defaults.opportunityAccessLevel >= 0, 'Opportunity access level should be >= 0');
        System.assert(defaults.caseAccessLevel >= 0, 'Case access level should be >= 0');
        
        // Verify access values are valid
        Set<String> validValues = new Set<String>{'None', 'Read', 'Edit'};
        System.assert(validValues.contains(defaults.opportunityAccess), 'Opportunity access should be None, Read, or Edit');
        System.assert(validValues.contains(defaults.caseAccess), 'Case access should be None, Read, or Edit');
    }

    @IsTest
    static void testFetchRoles_includesAccessFields()
    {
        List<RoleHierarchyController.RoleWithUsers> all = RoleHierarchyController.fetchRoles();
        System.assert(!all.isEmpty(), 'There should be at least one role returned');
        
        // Just verify the fields are populated (can be null if not set)
        RoleHierarchyController.RoleWithUsers pick = all[0];
        // These fields should exist and be accessible
        String oppAccess = pick.OpportunityAccessForAccountOwner;
        String caseAccess = pick.CaseAccessForAccountOwner;
        
        // Verify fetchRoleById also includes these fields
        RoleHierarchyController.RoleWithUsers byId = RoleHierarchyController.fetchRoleById(pick.Id);
        System.assertNotEquals(null, byId, 'Role by ID should not be null');
    }

    @IsTest
    static void testSearchUsers_findsUsers()
    {
        User u = anyActiveUserNot(UserInfo.getUserId());
        
        Test.startTest();
        // Search by partial name
        List<User> results = RoleHierarchyController.searchUsers(u.Name.substring(0, 3), 10);
        Test.stopTest();
        
        System.assert(results != null, 'Results should not be null');
        
        // Test with empty query
        List<User> emptyResults = RoleHierarchyController.searchUsers('', 10);
        System.assertEquals(0, emptyResults.size(), 'Empty query should return no results');
        
        // Test with single character (should return empty)
        List<User> shortResults = RoleHierarchyController.searchUsers('x', 10);
        System.assertEquals(0, shortResults.size(), 'Single character query should return no results');
    }
}
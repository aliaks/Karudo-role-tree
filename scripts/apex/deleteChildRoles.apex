// Anonymous Apex script to delete all child UserRole records under a specified parent role
// Execute this in Developer Console or via SF CLI
// 
// USAGE: Update the ROLE_NAME_TO_CLEAN variable below with the parent role name
// This will delete ALL child roles recursively but will NOT delete the parent role itself

// *** CONFIGURE THIS ***
String ROLE_NAME_TO_CLEAN = 'deltag';
// *********************

try {
    // Find the parent role
    List<UserRole> parentRoles = [
        SELECT Id, Name, DeveloperName 
        FROM UserRole 
        WHERE Name = :ROLE_NAME_TO_CLEAN 
        LIMIT 1
    ];
    
    if (parentRoles.isEmpty()) {
        System.debug('❌ ERROR: Role "' + ROLE_NAME_TO_CLEAN + '" not found.');
    } else {
        UserRole parentRole = parentRoles[0];
        System.debug('✅ Found parent role: ' + parentRole.Name + ' (ID: ' + parentRole.Id + ')');
        
        // Get all roles in the org to build the hierarchy
        List<UserRole> allRoles = [
            SELECT Id, Name, DeveloperName, ParentRoleId 
            FROM UserRole
        ];
        
        // Build a map for quick lookup
        Map<Id, UserRole> roleMap = new Map<Id, UserRole>(allRoles);
        
        // Find all descendant role IDs recursively
        Set<Id> descendantIds = new Set<Id>();
        findAllDescendants(parentRole.Id, roleMap, descendantIds);
        
        System.debug('Found ' + descendantIds.size() + ' descendant roles to delete.');
        
        if (descendantIds.isEmpty()) {
            System.debug('✅ No child roles found under "' + parentRole.Name + '". Nothing to delete.');
        } else {
            // Delete in waves from leaf nodes up to ensure parent-child constraints are respected
            Integer totalDeleted = 0;
            Integer maxIterations = 20; // Safety limit to prevent infinite loops
            Integer iteration = 0;
            
            while (!descendantIds.isEmpty() && iteration < maxIterations) {
                iteration++;
                
                // Find roles that have no children (leaf nodes)
                Set<Id> leafNodes = new Set<Id>();
                for (Id roleId : descendantIds) {
                    Boolean hasChildren = false;
                    for (UserRole role : allRoles) {
                        if (role.ParentRoleId == roleId && descendantIds.contains(role.Id)) {
                            hasChildren = true;
                            break;
                        }
                    }
                    if (!hasChildren) {
                        leafNodes.add(roleId);
                    }
                }
                
                if (leafNodes.isEmpty()) {
                    System.debug('⚠️ WARNING: No leaf nodes found but ' + descendantIds.size() + ' roles remaining. Breaking to prevent infinite loop.');
                    break;
                }
                
                // Delete the leaf nodes
                List<UserRole> rolesToDelete = new List<UserRole>();
                for (Id leafId : leafNodes) {
                    rolesToDelete.add(new UserRole(Id = leafId));
                }
                
                System.debug('Iteration ' + iteration + ': Deleting ' + rolesToDelete.size() + ' leaf roles...');
                Database.delete(rolesToDelete, false);
                
                totalDeleted += rolesToDelete.size();
                descendantIds.removeAll(leafNodes);
            }
            
            System.debug('✅ Successfully deleted ' + totalDeleted + ' descendant roles under "' + parentRole.Name + '"');
            System.debug('✅ Parent role "' + parentRole.Name + '" was preserved (not deleted).');
            
            if (!descendantIds.isEmpty()) {
                System.debug('⚠️ WARNING: ' + descendantIds.size() + ' roles could not be deleted. They may have dependencies.');
            }
        }
    }
    
} catch (Exception e) {
    System.debug('❌ ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

// Helper method to recursively find all descendants
void findAllDescendants(Id parentId, Map<Id, UserRole> roleMap, Set<Id> descendants) {
    for (UserRole role : roleMap.values()) {
        if (role.ParentRoleId == parentId) {
            descendants.add(role.Id);
            // Recursively find children of this role
            findAllDescendants(role.Id, roleMap, descendants);
        }
    }
}

// Anonymous Apex script to create UserRole hierarchy for Southern Maine Coast organization
// Execute this in Developer Console or via SF CLI: sf apex run --file scripts/apex/createRoleHierarchy.apex

// Map to store role IDs for parent-child relationships
Map<String, Id> roleMap = new Map<String, Id>();

// Helper method to create a role
UserRole createRole(String name, String devName, Id parentRoleId) {
    UserRole role = new UserRole(
        Name = name,
        DeveloperName = devName.replaceAll('[^a-zA-Z0-9]', '_'),
        ParentRoleId = parentRoleId
    );
    insert role;
    System.debug('Created role: ' + name + ' (ID: ' + role.Id + ')');
    return role;
}

try {
    // Level 1: District Manager (Top Level) - Assumes this role already exists
    UserRole districtMgr = [
        SELECT Id, Name 
        FROM UserRole 
        WHERE Name = 'District Manager – Southern Maine Coast' 
        LIMIT 1
    ];
    System.debug('Found existing role: ' + districtMgr.Name + ' (ID: ' + districtMgr.Id + ')');
    roleMap.put('DM_SMC', districtMgr.Id);
    
    // Level 2: Market Managers
    UserRole marketMgrPortland = createRole(
        'Market Manager – Greater Portland',
        'Market_Manager_Greater_Portland',
        districtMgr.Id
    );
    roleMap.put('MM_Portland', marketMgrPortland.Id);
    
    UserRole marketMgrMidCoast = createRole(
        'Market Manager – Mid-Coast Maine',
        'Market_Manager_Mid_Coast_Maine',
        districtMgr.Id
    );
    roleMap.put('MM_MidCoast', marketMgrMidCoast.Id);
    
    UserRole marketMgrYork = createRole(
        'Market Manager – York County Coast',
        'Market_Manager_York_County_Coast',
        districtMgr.Id
    );
    roleMap.put('MM_York', marketMgrYork.Id);
    
    // Level 3: Branch Managers - Greater Portland
    UserRole branchMgrPortland = createRole(
        'Branch Manager – Portland',
        'Branch_Manager_Portland',
        marketMgrPortland.Id
    );
    roleMap.put('BM_Portland', branchMgrPortland.Id);
    
    UserRole branchMgrSPortland = createRole(
        'Branch Manager – South Portland',
        'Branch_Manager_South_Portland',
        marketMgrPortland.Id
    );
    roleMap.put('BM_SPortland', branchMgrSPortland.Id);
    
    UserRole branchMgrWestbrook = createRole(
        'Branch Manager – Westbrook',
        'Branch_Manager_Westbrook',
        marketMgrPortland.Id
    );
    roleMap.put('BM_Westbrook', branchMgrWestbrook.Id);
    
    // Level 3: Branch Managers - Mid-Coast Maine
    UserRole branchMgrBrunswick = createRole(
        'Branch Manager – Brunswick',
        'Branch_Manager_Brunswick',
        marketMgrMidCoast.Id
    );
    roleMap.put('BM_Brunswick', branchMgrBrunswick.Id);
    
    UserRole branchMgrBath = createRole(
        'Branch Manager – Bath',
        'Branch_Manager_Bath',
        marketMgrMidCoast.Id
    );
    roleMap.put('BM_Bath', branchMgrBath.Id);
    
    UserRole branchMgrRockland = createRole(
        'Branch Manager – Rockland',
        'Branch_Manager_Rockland',
        marketMgrMidCoast.Id
    );
    roleMap.put('BM_Rockland', branchMgrRockland.Id);
    
    // Level 3: Branch Managers - York County Coast
    UserRole branchMgrBiddeford = createRole(
        'Branch Manager – Biddeford / Saco',
        'Branch_Manager_Biddeford_Saco',
        marketMgrYork.Id
    );
    roleMap.put('BM_Biddeford', branchMgrBiddeford.Id);
    
    UserRole branchMgrKennebunk = createRole(
        'Branch Manager – Kennebunk',
        'Branch_Manager_Kennebunk',
        marketMgrYork.Id
    );
    roleMap.put('BM_Kennebunk', branchMgrKennebunk.Id);
    
    UserRole branchMgrSanford = createRole(
        'Branch Manager – Sanford (Inland York)',
        'Branch_Manager_Sanford_Inland_York',
        marketMgrYork.Id
    );
    roleMap.put('BM_Sanford', branchMgrSanford.Id);
    
    // Level 4: Individual Contributors - Portland Branch
    createRole('Senior Account Executive – Commercial', 'Sr_AE_Commercial_Portland', branchMgrPortland.Id);
    createRole('Account Executive – Commercial', 'AE_Commercial_Portland', branchMgrPortland.Id);
    createRole('Sales Operations Specialist', 'Sales_Ops_Specialist_Portland', branchMgrPortland.Id);
    createRole('Service Supervisor', 'Service_Supervisor_Portland', branchMgrPortland.Id);
    
    // Level 4: Individual Contributors - South Portland Branch
    createRole('Account Executive – Commercial', 'AE_Commercial_SPortland', branchMgrSPortland.Id);
    createRole('Account Executive – SMB', 'AE_SMB_SPortland', branchMgrSPortland.Id);
    createRole('Field Service Lead', 'Field_Service_Lead_SPortland', branchMgrSPortland.Id);
    
    // Level 4: Individual Contributors - Westbrook Branch
    createRole('Account Executive – Commercial', 'AE_Commercial_Westbrook', branchMgrWestbrook.Id);
    createRole('Logistics Coordinator', 'Logistics_Coordinator_Westbrook', branchMgrWestbrook.Id);
    createRole('Operations Lead', 'Operations_Lead_Westbrook', branchMgrWestbrook.Id);
    
    // Level 4: Individual Contributors - Brunswick Branch
    createRole('Account Executive – Commercial', 'AE_Commercial_Brunswick', branchMgrBrunswick.Id);
    createRole('Sales Support Specialist', 'Sales_Support_Specialist_Brunswick', branchMgrBrunswick.Id);
    createRole('Operations Lead', 'Operations_Lead_Brunswick', branchMgrBrunswick.Id);
    
    // Level 4: Individual Contributors - Bath Branch
    createRole('Account Executive – Industrial', 'AE_Industrial_Bath', branchMgrBath.Id);
    createRole('Field Service Coordinator', 'Field_Service_Coordinator_Bath', branchMgrBath.Id);
    
    // Level 4: Individual Contributors - Rockland Branch
    createRole('Account Executive – SMB', 'AE_SMB_Rockland', branchMgrRockland.Id);
    createRole('Service Supervisor', 'Service_Supervisor_Rockland', branchMgrRockland.Id);
    
    // Level 4: Individual Contributors - Biddeford/Saco Branch
    createRole('Account Executive – Commercial', 'AE_Commercial_Biddeford', branchMgrBiddeford.Id);
    createRole('Account Executive – SMB', 'AE_SMB_Biddeford', branchMgrBiddeford.Id);
    createRole('Operations Lead', 'Operations_Lead_Biddeford', branchMgrBiddeford.Id);
    
    // Level 4: Individual Contributors - Kennebunk Branch
    createRole('Account Executive – SMB', 'AE_SMB_Kennebunk', branchMgrKennebunk.Id);
    createRole('Field Service Supervisor', 'Field_Service_Supervisor_Kennebunk', branchMgrKennebunk.Id);
    
    // Level 4: Individual Contributors - Sanford Branch
    createRole('Account Executive – Commercial', 'AE_Commercial_Sanford', branchMgrSanford.Id);
    createRole('Logistics Supervisor', 'Logistics_Supervisor_Sanford', branchMgrSanford.Id);
    
    System.debug('✅ Successfully created all UserRole records in the hierarchy!');
    System.debug('Total roles created: ' + [SELECT COUNT() FROM UserRole WHERE DeveloperName LIKE '%Maine%' OR DeveloperName LIKE '%York%' OR DeveloperName LIKE '%Portland%']);
    
} catch (Exception e) {
    System.debug('❌ Error creating roles: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

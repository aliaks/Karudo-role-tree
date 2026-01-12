// Anonymous Apex script to create UserRole hierarchy for New Hampshire Seacoast organization
// Execute this in Developer Console or via SF CLI: sf apex run --file scripts/apex/createRoleHierarchyNH.apex

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
        WHERE Name = 'District Manager – New Hampshire Seacoast' 
        LIMIT 1
    ];
    System.debug('Found existing role: ' + districtMgr.Name + ' (ID: ' + districtMgr.Id + ')');
    roleMap.put('DM_NH', districtMgr.Id);
    
    // Level 2: Market Managers
    UserRole marketMgrPortsmouth = createRole(
        'Market Manager – Portsmouth Coastal',
        'Market_Manager_Portsmouth_Coastal',
        districtMgr.Id
    );
    roleMap.put('MM_Portsmouth', marketMgrPortsmouth.Id);
    
    UserRole marketMgrDover = createRole(
        'Market Manager – Dover–Somersworth',
        'Market_Manager_Dover_Somersworth',
        districtMgr.Id
    );
    roleMap.put('MM_Dover', marketMgrDover.Id);
    
    UserRole marketMgrSeacoastNorth = createRole(
        'Market Manager – Seacoast North & Lakes Connector',
        'Market_Manager_Seacoast_North_Lakes_Connector',
        districtMgr.Id
    );
    roleMap.put('MM_SeacoastNorth', marketMgrSeacoastNorth.Id);
    
    // Level 3: Branch Managers - Portsmouth Coastal
    UserRole branchMgrPortsmouth = createRole(
        'Branch Manager – Portsmouth',
        'Branch_Manager_Portsmouth',
        marketMgrPortsmouth.Id
    );
    roleMap.put('BM_Portsmouth', branchMgrPortsmouth.Id);
    
    UserRole branchMgrRye = createRole(
        'Branch Manager – Rye / Hampton',
        'Branch_Manager_Rye_Hampton',
        marketMgrPortsmouth.Id
    );
    roleMap.put('BM_Rye', branchMgrRye.Id);
    
    UserRole branchMgrExeter = createRole(
        'Branch Manager – Exeter',
        'Branch_Manager_Exeter',
        marketMgrPortsmouth.Id
    );
    roleMap.put('BM_Exeter', branchMgrExeter.Id);
    
    // Level 3: Branch Managers - Dover–Somersworth
    UserRole branchMgrDover = createRole(
        'Branch Manager – Dover',
        'Branch_Manager_Dover',
        marketMgrDover.Id
    );
    roleMap.put('BM_Dover', branchMgrDover.Id);
    
    UserRole branchMgrSomersworth = createRole(
        'Branch Manager – Somersworth',
        'Branch_Manager_Somersworth',
        marketMgrDover.Id
    );
    roleMap.put('BM_Somersworth', branchMgrSomersworth.Id);
    
    UserRole branchMgrRochester = createRole(
        'Branch Manager – Rochester',
        'Branch_Manager_Rochester',
        marketMgrDover.Id
    );
    roleMap.put('BM_Rochester', branchMgrRochester.Id);
    
    // Level 3: Branch Managers - Seacoast North & Lakes Connector
    UserRole branchMgrDurham = createRole(
        'Branch Manager – Durham / UNH',
        'Branch_Manager_Durham_UNH',
        marketMgrSeacoastNorth.Id
    );
    roleMap.put('BM_Durham', branchMgrDurham.Id);
    
    UserRole branchMgrNewmarket = createRole(
        'Branch Manager – Newmarket',
        'Branch_Manager_Newmarket',
        marketMgrSeacoastNorth.Id
    );
    roleMap.put('BM_Newmarket', branchMgrNewmarket.Id);
    
    UserRole branchMgrLaconia = createRole(
        'Branch Manager – Laconia (Seacoast Extension)',
        'Branch_Manager_Laconia_Seacoast_Extension',
        marketMgrSeacoastNorth.Id
    );
    roleMap.put('BM_Laconia', branchMgrLaconia.Id);
    
    // Level 4: Individual Contributors - Portsmouth Branch
    createRole('(Portsmouth) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Portsmouth', branchMgrPortsmouth.Id);
    createRole('(Portsmouth) Account Executive – Commercial', 'AE_Commercial_Portsmouth', branchMgrPortsmouth.Id);
    createRole('(Portsmouth) Sales Operations Specialist', 'Sales_Ops_Specialist_Portsmouth', branchMgrPortsmouth.Id);
    createRole('(Portsmouth) Service Supervisor', 'Service_Supervisor_Portsmouth', branchMgrPortsmouth.Id);
    
    // Level 4: Individual Contributors - Rye/Hampton Branch
    createRole('(Rye/Hampton) Account Executive – SMB', 'AE_SMB_Rye_Hampton', branchMgrRye.Id);
    createRole('(Hampton) Field Service Lead', 'Field_Service_Lead_Hampton', branchMgrRye.Id);
    createRole('(Rye/Hampton) Sales Support Specialist', 'Sales_Support_Specialist_Rye_Hampton', branchMgrRye.Id);
    
    // Level 4: Individual Contributors - Exeter Branch
    createRole('(Exeter) Account Executive – Commercial', 'AE_Commercial_Exeter', branchMgrExeter.Id);
    createRole('(Exeter) Operations Lead', 'Operations_Lead_Exeter', branchMgrExeter.Id);
    createRole('(Exeter) Field Service Coordinator', 'Field_Service_Coordinator_Exeter', branchMgrExeter.Id);
    
    // Level 4: Individual Contributors - Dover Branch
    createRole('(Dover) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Dover', branchMgrDover.Id);
    createRole('(Dover) Account Executive – Commercial', 'AE_Commercial_Dover', branchMgrDover.Id);
    createRole('(Dover) Logistics Supervisor', 'Logistics_Supervisor_Dover', branchMgrDover.Id);
    createRole('(Dover) Service Supervisor', 'Service_Supervisor_Dover', branchMgrDover.Id);
    
    // Level 4: Individual Contributors - Somersworth Branch
    createRole('(Somersworth) Account Executive – SMB', 'AE_SMB_Somersworth', branchMgrSomersworth.Id);
    createRole('(Somersworth) Sales Support Specialist', 'Sales_Support_Specialist_Somersworth', branchMgrSomersworth.Id);
    createRole('(Somersworth) Field Service Supervisor', 'Field_Service_Supervisor_Somersworth', branchMgrSomersworth.Id);
    
    // Level 4: Individual Contributors - Rochester Branch
    createRole('(Rochester) Account Executive – Commercial', 'AE_Commercial_Rochester', branchMgrRochester.Id);
    createRole('(Rochester) Operations Lead', 'Operations_Lead_Rochester', branchMgrRochester.Id);
    createRole('(Rochester) Field Service Coordinator', 'Field_Service_Coordinator_Rochester', branchMgrRochester.Id);
    
    // Level 4: Individual Contributors - Durham/UNH Branch
    createRole('(Durham) Account Executive – Commercial', 'AE_Commercial_Durham', branchMgrDurham.Id);
    createRole('(Durham) Sales Operations Specialist', 'Sales_Ops_Specialist_Durham', branchMgrDurham.Id);
    createRole('(Durham) Service Supervisor', 'Service_Supervisor_Durham', branchMgrDurham.Id);
    
    // Level 4: Individual Contributors - Newmarket Branch
    createRole('(Newmarket) Account Executive – SMB', 'AE_SMB_Newmarket', branchMgrNewmarket.Id);
    createRole('(Newmarket) Field Service Lead', 'Field_Service_Lead_Newmarket', branchMgrNewmarket.Id);
    createRole('(Newmarket) Sales Support Specialist', 'Sales_Support_Specialist_Newmarket', branchMgrNewmarket.Id);
    
    // Level 4: Individual Contributors - Laconia Branch
    createRole('(Laconia) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Laconia', branchMgrLaconia.Id);
    createRole('(Laconia) Account Executive – Commercial', 'AE_Commercial_Laconia', branchMgrLaconia.Id);
    createRole('(Laconia) Logistics Coordinator', 'Logistics_Coordinator_Laconia', branchMgrLaconia.Id);
    createRole('(Laconia) Field Service Supervisor', 'Field_Service_Supervisor_Laconia', branchMgrLaconia.Id);
    
    System.debug('✅ Successfully created all UserRole records in the New Hampshire Seacoast hierarchy!');
    System.debug('Total roles created: ' + [SELECT COUNT() FROM UserRole WHERE DeveloperName LIKE '%Portsmouth%' OR DeveloperName LIKE '%Dover%' OR DeveloperName LIKE '%Laconia%']);
    
} catch (Exception e) {
    System.debug('❌ Error creating roles: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

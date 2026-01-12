// Anonymous Apex script to create UserRole hierarchy for Greater New York Metro organization
// Execute this in Developer Console or via SF CLI: sf apex run --file scripts/apex/createRoleHierarchyNY.apex

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
    // Level 1: Regional Director (Top Level) - Assumes this role already exists
    UserRole regionalDir = [
        SELECT Id, Name 
        FROM UserRole 
        WHERE Name = 'Regional Director – Greater New York Metro' 
        LIMIT 1
    ];
    System.debug('Found existing role: ' + regionalDir.Name + ' (ID: ' + regionalDir.Id + ')');
    roleMap.put('RD_NY', regionalDir.Id);
    
    // Level 2: District Directors
    UserRole districtDirCore = createRole(
        'District Director – NYC Core',
        'District_Director_NYC_Core',
        regionalDir.Id
    );
    roleMap.put('DD_Core', districtDirCore.Id);
    
    UserRole districtDirExtended = createRole(
        'District Director – NYC Extended Metro',
        'District_Director_NYC_Extended_Metro',
        regionalDir.Id
    );
    roleMap.put('DD_Extended', districtDirExtended.Id);
    
    // Level 3: District Managers - NYC Core
    UserRole districtMgrManhattan = createRole(
        'District Manager – Manhattan',
        'District_Manager_Manhattan',
        districtDirCore.Id
    );
    roleMap.put('DM_Manhattan', districtMgrManhattan.Id);
    
    UserRole districtMgrBrooklyn = createRole(
        'District Manager – Brooklyn',
        'District_Manager_Brooklyn',
        districtDirCore.Id
    );
    roleMap.put('DM_Brooklyn', districtMgrBrooklyn.Id);
    
    UserRole districtMgrQueensBronx = createRole(
        'District Manager – Queens & Bronx',
        'District_Manager_Queens_Bronx',
        districtDirCore.Id
    );
    roleMap.put('DM_QueensBronx', districtMgrQueensBronx.Id);
    
    // Level 3: District Managers - NYC Extended Metro
    UserRole districtMgrLongIsland = createRole(
        'District Manager – Long Island',
        'District_Manager_Long_Island',
        districtDirExtended.Id
    );
    roleMap.put('DM_LongIsland', districtMgrLongIsland.Id);
    
    UserRole districtMgrWestchester = createRole(
        'District Manager – Westchester & Hudson Valley',
        'District_Manager_Westchester_Hudson_Valley',
        districtDirExtended.Id
    );
    roleMap.put('DM_Westchester', districtMgrWestchester.Id);
    
    UserRole districtMgrNNJ = createRole(
        'District Manager – Northern New Jersey',
        'District_Manager_Northern_New_Jersey',
        districtDirExtended.Id
    );
    roleMap.put('DM_NNJ', districtMgrNNJ.Id);
    
    // Level 4: Branch Managers - Manhattan
    UserRole branchMgrMidtown = createRole(
        'Branch Manager – Midtown Manhattan',
        'Branch_Manager_Midtown_Manhattan',
        districtMgrManhattan.Id
    );
    roleMap.put('BM_Midtown', branchMgrMidtown.Id);
    
    UserRole branchMgrDowntown = createRole(
        'Branch Manager – Downtown Manhattan',
        'Branch_Manager_Downtown_Manhattan',
        districtMgrManhattan.Id
    );
    roleMap.put('BM_Downtown', branchMgrDowntown.Id);
    
    UserRole branchMgrUptown = createRole(
        'Branch Manager – Uptown Manhattan',
        'Branch_Manager_Uptown_Manhattan',
        districtMgrManhattan.Id
    );
    roleMap.put('BM_Uptown', branchMgrUptown.Id);
    
    // Level 4: Branch Managers - Brooklyn
    UserRole branchMgrDowntownBK = createRole(
        'Branch Manager – Downtown Brooklyn',
        'Branch_Manager_Downtown_Brooklyn',
        districtMgrBrooklyn.Id
    );
    roleMap.put('BM_DowntownBK', branchMgrDowntownBK.Id);
    
    UserRole branchMgrWilliamsburg = createRole(
        'Branch Manager – Williamsburg',
        'Branch_Manager_Williamsburg',
        districtMgrBrooklyn.Id
    );
    roleMap.put('BM_Williamsburg', branchMgrWilliamsburg.Id);
    
    UserRole branchMgrSunsetPark = createRole(
        'Branch Manager – Sunset Park',
        'Branch_Manager_Sunset_Park',
        districtMgrBrooklyn.Id
    );
    roleMap.put('BM_SunsetPark', branchMgrSunsetPark.Id);
    
    // Level 4: Branch Managers - Queens & Bronx
    UserRole branchMgrLIC = createRole(
        'Branch Manager – Long Island City',
        'Branch_Manager_Long_Island_City',
        districtMgrQueensBronx.Id
    );
    roleMap.put('BM_LIC', branchMgrLIC.Id);
    
    UserRole branchMgrAstoria = createRole(
        'Branch Manager – Astoria',
        'Branch_Manager_Astoria',
        districtMgrQueensBronx.Id
    );
    roleMap.put('BM_Astoria', branchMgrAstoria.Id);
    
    UserRole branchMgrHuntsPoint = createRole(
        'Branch Manager – Hunts Point (Bronx)',
        'Branch_Manager_Hunts_Point_Bronx',
        districtMgrQueensBronx.Id
    );
    roleMap.put('BM_HuntsPoint', branchMgrHuntsPoint.Id);
    
    // Level 4: Branch Managers - Long Island
    UserRole branchMgrNassau = createRole(
        'Branch Manager – Nassau County',
        'Branch_Manager_Nassau_County',
        districtMgrLongIsland.Id
    );
    roleMap.put('BM_Nassau', branchMgrNassau.Id);
    
    UserRole branchMgrSuffolk = createRole(
        'Branch Manager – Suffolk County',
        'Branch_Manager_Suffolk_County',
        districtMgrLongIsland.Id
    );
    roleMap.put('BM_Suffolk', branchMgrSuffolk.Id);
    
    // Level 4: Branch Managers - Westchester & Hudson Valley
    UserRole branchMgrWhitePlains = createRole(
        'Branch Manager – White Plains',
        'Branch_Manager_White_Plains',
        districtMgrWestchester.Id
    );
    roleMap.put('BM_WhitePlains', branchMgrWhitePlains.Id);
    
    UserRole branchMgrNewRochelle = createRole(
        'Branch Manager – New Rochelle',
        'Branch_Manager_New_Rochelle',
        districtMgrWestchester.Id
    );
    roleMap.put('BM_NewRochelle', branchMgrNewRochelle.Id);
    
    // Level 4: Branch Managers - Northern New Jersey
    UserRole branchMgrJerseyCity = createRole(
        'Branch Manager – Jersey City',
        'Branch_Manager_Jersey_City',
        districtMgrNNJ.Id
    );
    roleMap.put('BM_JerseyCity', branchMgrJerseyCity.Id);
    
    UserRole branchMgrNewark = createRole(
        'Branch Manager – Newark',
        'Branch_Manager_Newark',
        districtMgrNNJ.Id
    );
    roleMap.put('BM_Newark', branchMgrNewark.Id);
    
    // Level 5: Individual Contributors - Midtown Manhattan
    createRole('(Midtown Manhattan) Senior Account Executive – Enterprise', 'Sr_AE_Enterprise_Midtown_Manhattan', branchMgrMidtown.Id);
    createRole('(Midtown Manhattan) Account Executive – Commercial', 'AE_Commercial_Midtown_Manhattan', branchMgrMidtown.Id);
    createRole('(Midtown Manhattan) Sales Operations Specialist', 'Sales_Ops_Specialist_Midtown_Manhattan', branchMgrMidtown.Id);
    createRole('(Midtown Manhattan) Service Supervisor', 'Service_Supervisor_Midtown_Manhattan', branchMgrMidtown.Id);
    
    // Level 5: Individual Contributors - Downtown Manhattan
    createRole('(Downtown Manhattan) Senior Account Executive – Enterprise', 'Sr_AE_Enterprise_Downtown_Manhattan', branchMgrDowntown.Id);
    createRole('(Downtown Manhattan) Account Executive – Commercial', 'AE_Commercial_Downtown_Manhattan', branchMgrDowntown.Id);
    createRole('(Downtown Manhattan) Operations Lead', 'Operations_Lead_Downtown_Manhattan', branchMgrDowntown.Id);
    createRole('(Downtown Manhattan) Field Service Coordinator', 'Field_Service_Coordinator_Downtown_Manhattan', branchMgrDowntown.Id);
    
    // Level 5: Individual Contributors - Uptown Manhattan
    createRole('(Uptown Manhattan) Account Executive – Commercial', 'AE_Commercial_Uptown_Manhattan', branchMgrUptown.Id);
    createRole('(Uptown Manhattan) Account Executive – SMB', 'AE_SMB_Uptown_Manhattan', branchMgrUptown.Id);
    createRole('(Uptown Manhattan) Sales Support Specialist', 'Sales_Support_Specialist_Uptown_Manhattan', branchMgrUptown.Id);
    
    // Level 5: Individual Contributors - Downtown Brooklyn
    createRole('(Downtown Brooklyn) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Downtown_Brooklyn', branchMgrDowntownBK.Id);
    createRole('(Downtown Brooklyn) Account Executive – Commercial', 'AE_Commercial_Downtown_Brooklyn', branchMgrDowntownBK.Id);
    createRole('(Downtown Brooklyn) Operations Lead', 'Operations_Lead_Downtown_Brooklyn', branchMgrDowntownBK.Id);
    createRole('(Downtown Brooklyn) Service Supervisor', 'Service_Supervisor_Downtown_Brooklyn', branchMgrDowntownBK.Id);
    
    // Level 5: Individual Contributors - Williamsburg
    createRole('(Williamsburg) Account Executive – SMB', 'AE_SMB_Williamsburg', branchMgrWilliamsburg.Id);
    createRole('(Williamsburg) Field Service Lead', 'Field_Service_Lead_Williamsburg', branchMgrWilliamsburg.Id);
    createRole('(Williamsburg) Sales Support Specialist', 'Sales_Support_Specialist_Williamsburg', branchMgrWilliamsburg.Id);
    
    // Level 5: Individual Contributors - Sunset Park
    createRole('(Sunset Park) Account Executive – Industrial', 'AE_Industrial_Sunset_Park', branchMgrSunsetPark.Id);
    createRole('(Sunset Park) Logistics Supervisor', 'Logistics_Supervisor_Sunset_Park', branchMgrSunsetPark.Id);
    createRole('(Sunset Park) Operations Lead', 'Operations_Lead_Sunset_Park', branchMgrSunsetPark.Id);
    
    // Level 5: Individual Contributors - Long Island City
    createRole('(Long Island City) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Long_Island_City', branchMgrLIC.Id);
    createRole('(Long Island City) Account Executive – Commercial', 'AE_Commercial_Long_Island_City', branchMgrLIC.Id);
    createRole('(Long Island City) Logistics Coordinator', 'Logistics_Coordinator_Long_Island_City', branchMgrLIC.Id);
    createRole('(Long Island City) Service Supervisor', 'Service_Supervisor_Long_Island_City', branchMgrLIC.Id);
    
    // Level 5: Individual Contributors - Astoria
    createRole('(Astoria) Account Executive – SMB', 'AE_SMB_Astoria', branchMgrAstoria.Id);
    createRole('(Astoria) Sales Support Specialist', 'Sales_Support_Specialist_Astoria', branchMgrAstoria.Id);
    createRole('(Astoria) Field Service Lead', 'Field_Service_Lead_Astoria', branchMgrAstoria.Id);
    
    // Level 5: Individual Contributors - Hunts Point
    createRole('(Hunts Point) Account Executive – Industrial', 'AE_Industrial_Hunts_Point', branchMgrHuntsPoint.Id);
    createRole('(Hunts Point) Operations Lead', 'Operations_Lead_Hunts_Point', branchMgrHuntsPoint.Id);
    createRole('(Hunts Point) Logistics Supervisor', 'Logistics_Supervisor_Hunts_Point', branchMgrHuntsPoint.Id);
    
    // Level 5: Individual Contributors - Nassau County
    createRole('(Nassau County) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Nassau_County', branchMgrNassau.Id);
    createRole('(Nassau County) Account Executive – Commercial', 'AE_Commercial_Nassau_County', branchMgrNassau.Id);
    createRole('(Nassau County) Sales Operations Specialist', 'Sales_Ops_Specialist_Nassau_County', branchMgrNassau.Id);
    createRole('(Nassau County) Service Supervisor', 'Service_Supervisor_Nassau_County', branchMgrNassau.Id);
    
    // Level 5: Individual Contributors - Suffolk County
    createRole('(Suffolk County) Account Executive – Commercial', 'AE_Commercial_Suffolk_County', branchMgrSuffolk.Id);
    createRole('(Suffolk County) Account Executive – SMB', 'AE_SMB_Suffolk_County', branchMgrSuffolk.Id);
    createRole('(Suffolk County) Field Service Coordinator', 'Field_Service_Coordinator_Suffolk_County', branchMgrSuffolk.Id);
    
    // Level 5: Individual Contributors - White Plains
    createRole('(White Plains) Senior Account Executive – Enterprise', 'Sr_AE_Enterprise_White_Plains', branchMgrWhitePlains.Id);
    createRole('(White Plains) Account Executive – Commercial', 'AE_Commercial_White_Plains', branchMgrWhitePlains.Id);
    createRole('(White Plains) Operations Lead', 'Operations_Lead_White_Plains', branchMgrWhitePlains.Id);
    
    // Level 5: Individual Contributors - New Rochelle
    createRole('(New Rochelle) Account Executive – Commercial', 'AE_Commercial_New_Rochelle', branchMgrNewRochelle.Id);
    createRole('(New Rochelle) Sales Support Specialist', 'Sales_Support_Specialist_New_Rochelle', branchMgrNewRochelle.Id);
    createRole('(New Rochelle) Field Service Lead', 'Field_Service_Lead_New_Rochelle', branchMgrNewRochelle.Id);
    
    // Level 5: Individual Contributors - Jersey City
    createRole('(Jersey City) Senior Account Executive – Enterprise', 'Sr_AE_Enterprise_Jersey_City', branchMgrJerseyCity.Id);
    createRole('(Jersey City) Account Executive – Commercial', 'AE_Commercial_Jersey_City', branchMgrJerseyCity.Id);
    createRole('(Jersey City) Logistics Supervisor', 'Logistics_Supervisor_Jersey_City', branchMgrJerseyCity.Id);
    createRole('(Jersey City) Service Supervisor', 'Service_Supervisor_Jersey_City', branchMgrJerseyCity.Id);
    
    // Level 5: Individual Contributors - Newark
    createRole('(Newark) Account Executive – Industrial', 'AE_Industrial_Newark', branchMgrNewark.Id);
    createRole('(Newark) Operations Lead', 'Operations_Lead_Newark', branchMgrNewark.Id);
    createRole('(Newark) Field Service Coordinator', 'Field_Service_Coordinator_Newark', branchMgrNewark.Id);
    
    System.debug('✅ Successfully created all UserRole records in the Greater New York Metro hierarchy!');
    System.debug('Total roles created: ' + [SELECT COUNT() FROM UserRole WHERE DeveloperName LIKE '%Manhattan%' OR DeveloperName LIKE '%Brooklyn%' OR DeveloperName LIKE '%Queens%']);
    
} catch (Exception e) {
    System.debug('❌ Error creating roles: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

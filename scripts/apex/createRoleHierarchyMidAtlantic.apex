// Anonymous Apex script to create UserRole hierarchy for Northern Mid-Atlantic organization
// Execute this in Developer Console or via SF CLI: sf apex run --file scripts/apex/createRoleHierarchyMidAtlantic.apex

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
        WHERE Name = 'Regional Director – Northern Mid-Atlantic' 
        LIMIT 1
    ];
    System.debug('Found existing role: ' + regionalDir.Name + ' (ID: ' + regionalDir.Id + ')');
    roleMap.put('RD_MidAtlantic', regionalDir.Id);
    
    // Level 2: District Directors
    UserRole districtDirEasternPA = createRole(
        'District Director – Eastern Pennsylvania',
        'District_Director_Eastern_Pennsylvania',
        regionalDir.Id
    );
    roleMap.put('DD_EasternPA', districtDirEasternPA.Id);
    
    UserRole districtDirNJ = createRole(
        'District Director – New Jersey',
        'District_Director_New_Jersey',
        regionalDir.Id
    );
    roleMap.put('DD_NJ', districtDirNJ.Id);
    
    UserRole districtDirDEMD = createRole(
        'District Director – Delaware & Eastern Maryland',
        'District_Director_Delaware_Eastern_Maryland',
        regionalDir.Id
    );
    roleMap.put('DD_DEMD', districtDirDEMD.Id);
    
    // Level 3: District Managers - Eastern Pennsylvania
    UserRole districtMgrPhilly = createRole(
        'District Manager – Philadelphia Metro',
        'District_Manager_Philadelphia_Metro',
        districtDirEasternPA.Id
    );
    roleMap.put('DM_Philly', districtMgrPhilly.Id);
    
    UserRole districtMgrLehigh = createRole(
        'District Manager – Lehigh Valley & Northeast PA',
        'District_Manager_Lehigh_Valley_Northeast_PA',
        districtDirEasternPA.Id
    );
    roleMap.put('DM_Lehigh', districtMgrLehigh.Id);
    
    // Level 3: District Managers - New Jersey
    UserRole districtMgrCentralNJ = createRole(
        'District Manager – Central New Jersey',
        'District_Manager_Central_New_Jersey',
        districtDirNJ.Id
    );
    roleMap.put('DM_CentralNJ', districtMgrCentralNJ.Id);
    
    UserRole districtMgrSouthernNJ = createRole(
        'District Manager – Southern New Jersey',
        'District_Manager_Southern_New_Jersey',
        districtDirNJ.Id
    );
    roleMap.put('DM_SouthernNJ', districtMgrSouthernNJ.Id);
    
    // Level 3: District Managers - Delaware & Eastern Maryland
    UserRole districtMgrDE = createRole(
        'District Manager – Delaware',
        'District_Manager_Delaware',
        districtDirDEMD.Id
    );
    roleMap.put('DM_DE', districtMgrDE.Id);
    
    UserRole districtMgrEasternMD = createRole(
        'District Manager – Eastern Maryland',
        'District_Manager_Eastern_Maryland',
        districtDirDEMD.Id
    );
    roleMap.put('DM_EasternMD', districtMgrEasternMD.Id);
    
    // Level 4: Branch Managers - Philadelphia Metro
    UserRole branchMgrPhiladelphia = createRole(
        'Branch Manager – Philadelphia',
        'Branch_Manager_Philadelphia',
        districtMgrPhilly.Id
    );
    roleMap.put('BM_Philadelphia', branchMgrPhiladelphia.Id);
    
    UserRole branchMgrKOP = createRole(
        'Branch Manager – King of Prussia',
        'Branch_Manager_King_of_Prussia',
        districtMgrPhilly.Id
    );
    roleMap.put('BM_KOP', branchMgrKOP.Id);
    
    UserRole branchMgrCherryHill = createRole(
        'Branch Manager – Cherry Hill (NJ)',
        'Branch_Manager_Cherry_Hill_NJ',
        districtMgrPhilly.Id
    );
    roleMap.put('BM_CherryHill', branchMgrCherryHill.Id);
    
    // Level 4: Branch Managers - Lehigh Valley & Northeast PA
    UserRole branchMgrAllentown = createRole(
        'Branch Manager – Allentown',
        'Branch_Manager_Allentown',
        districtMgrLehigh.Id
    );
    roleMap.put('BM_Allentown', branchMgrAllentown.Id);
    
    UserRole branchMgrBethlehem = createRole(
        'Branch Manager – Bethlehem',
        'Branch_Manager_Bethlehem',
        districtMgrLehigh.Id
    );
    roleMap.put('BM_Bethlehem', branchMgrBethlehem.Id);
    
    UserRole branchMgrScranton = createRole(
        'Branch Manager – Scranton',
        'Branch_Manager_Scranton',
        districtMgrLehigh.Id
    );
    roleMap.put('BM_Scranton', branchMgrScranton.Id);
    
    // Level 4: Branch Managers - Central New Jersey
    UserRole branchMgrEdison = createRole(
        'Branch Manager – Edison',
        'Branch_Manager_Edison',
        districtMgrCentralNJ.Id
    );
    roleMap.put('BM_Edison', branchMgrEdison.Id);
    
    UserRole branchMgrNewBrunswick = createRole(
        'Branch Manager – New Brunswick',
        'Branch_Manager_New_Brunswick',
        districtMgrCentralNJ.Id
    );
    roleMap.put('BM_NewBrunswick', branchMgrNewBrunswick.Id);
    
    UserRole branchMgrPrinceton = createRole(
        'Branch Manager – Princeton',
        'Branch_Manager_Princeton',
        districtMgrCentralNJ.Id
    );
    roleMap.put('BM_Princeton', branchMgrPrinceton.Id);
    
    // Level 4: Branch Managers - Southern New Jersey
    UserRole branchMgrMountLaurel = createRole(
        'Branch Manager – Mount Laurel',
        'Branch_Manager_Mount_Laurel',
        districtMgrSouthernNJ.Id
    );
    roleMap.put('BM_MountLaurel', branchMgrMountLaurel.Id);
    
    UserRole branchMgrVineland = createRole(
        'Branch Manager – Vineland',
        'Branch_Manager_Vineland',
        districtMgrSouthernNJ.Id
    );
    roleMap.put('BM_Vineland', branchMgrVineland.Id);
    
    UserRole branchMgrAtlanticCity = createRole(
        'Branch Manager – Atlantic City',
        'Branch_Manager_Atlantic_City',
        districtMgrSouthernNJ.Id
    );
    roleMap.put('BM_AtlanticCity', branchMgrAtlanticCity.Id);
    
    // Level 4: Branch Managers - Delaware
    UserRole branchMgrWilmington = createRole(
        'Branch Manager – Wilmington',
        'Branch_Manager_Wilmington',
        districtMgrDE.Id
    );
    roleMap.put('BM_Wilmington', branchMgrWilmington.Id);
    
    UserRole branchMgrNewarkDE = createRole(
        'Branch Manager – Newark (DE)',
        'Branch_Manager_Newark_DE',
        districtMgrDE.Id
    );
    roleMap.put('BM_NewarkDE', branchMgrNewarkDE.Id);
    
    UserRole branchMgrDoverDE = createRole(
        'Branch Manager – Dover',
        'Branch_Manager_Dover',
        districtMgrDE.Id
    );
    roleMap.put('BM_DoverDE', branchMgrDoverDE.Id);
    
    // Level 4: Branch Managers - Eastern Maryland
    UserRole branchMgrBaltimore = createRole(
        'Branch Manager – Baltimore',
        'Branch_Manager_Baltimore',
        districtMgrEasternMD.Id
    );
    roleMap.put('BM_Baltimore', branchMgrBaltimore.Id);
    
    UserRole branchMgrTowson = createRole(
        'Branch Manager – Towson',
        'Branch_Manager_Towson',
        districtMgrEasternMD.Id
    );
    roleMap.put('BM_Towson', branchMgrTowson.Id);
    
    UserRole branchMgrColumbia = createRole(
        'Branch Manager – Columbia',
        'Branch_Manager_Columbia',
        districtMgrEasternMD.Id
    );
    roleMap.put('BM_Columbia', branchMgrColumbia.Id);
    
    // Level 5: Individual Contributors - Philadelphia
    createRole('(Philadelphia) Senior Account Executive – Enterprise', 'Sr_AE_Enterprise_Philadelphia', branchMgrPhiladelphia.Id);
    createRole('(Philadelphia) Account Executive – Commercial', 'AE_Commercial_Philadelphia', branchMgrPhiladelphia.Id);
    createRole('(Philadelphia) Sales Operations Specialist', 'Sales_Ops_Specialist_Philadelphia', branchMgrPhiladelphia.Id);
    createRole('(Philadelphia) Service Supervisor', 'Service_Supervisor_Philadelphia', branchMgrPhiladelphia.Id);
    
    // Level 5: Individual Contributors - King of Prussia
    createRole('(King of Prussia) Account Executive – Commercial', 'AE_Commercial_King_of_Prussia', branchMgrKOP.Id);
    createRole('(King of Prussia) Operations Lead', 'Operations_Lead_King_of_Prussia', branchMgrKOP.Id);
    createRole('(King of Prussia) Field Service Coordinator', 'Field_Service_Coordinator_King_of_Prussia', branchMgrKOP.Id);
    
    // Level 5: Individual Contributors - Cherry Hill
    createRole('(Cherry Hill) Account Executive – SMB', 'AE_SMB_Cherry_Hill', branchMgrCherryHill.Id);
    createRole('(Cherry Hill) Sales Support Specialist', 'Sales_Support_Specialist_Cherry_Hill', branchMgrCherryHill.Id);
    createRole('(Cherry Hill) Field Service Lead', 'Field_Service_Lead_Cherry_Hill', branchMgrCherryHill.Id);
    
    // Level 5: Individual Contributors - Allentown
    createRole('(Allentown) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Allentown', branchMgrAllentown.Id);
    createRole('(Allentown) Account Executive – Commercial', 'AE_Commercial_Allentown', branchMgrAllentown.Id);
    createRole('(Allentown) Operations Lead', 'Operations_Lead_Allentown', branchMgrAllentown.Id);
    
    // Level 5: Individual Contributors - Bethlehem
    createRole('(Bethlehem) Account Executive – SMB', 'AE_SMB_Bethlehem', branchMgrBethlehem.Id);
    createRole('(Bethlehem) Sales Support Specialist', 'Sales_Support_Specialist_Bethlehem', branchMgrBethlehem.Id);
    createRole('(Bethlehem) Field Service Supervisor', 'Field_Service_Supervisor_Bethlehem', branchMgrBethlehem.Id);
    
    // Level 5: Individual Contributors - Scranton
    createRole('(Scranton) Account Executive – Commercial', 'AE_Commercial_Scranton', branchMgrScranton.Id);
    createRole('(Scranton) Logistics Coordinator', 'Logistics_Coordinator_Scranton', branchMgrScranton.Id);
    createRole('(Scranton) Service Supervisor', 'Service_Supervisor_Scranton', branchMgrScranton.Id);
    
    // Level 5: Individual Contributors - Edison
    createRole('(Edison) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Edison', branchMgrEdison.Id);
    createRole('(Edison) Account Executive – Commercial', 'AE_Commercial_Edison', branchMgrEdison.Id);
    createRole('(Edison) Sales Operations Specialist', 'Sales_Ops_Specialist_Edison', branchMgrEdison.Id);
    createRole('(Edison) Service Supervisor', 'Service_Supervisor_Edison', branchMgrEdison.Id);
    
    // Level 5: Individual Contributors - New Brunswick
    createRole('(New Brunswick) Account Executive – SMB', 'AE_SMB_New_Brunswick', branchMgrNewBrunswick.Id);
    createRole('(New Brunswick) Field Service Lead', 'Field_Service_Lead_New_Brunswick', branchMgrNewBrunswick.Id);
    createRole('(New Brunswick) Sales Support Specialist', 'Sales_Support_Specialist_New_Brunswick', branchMgrNewBrunswick.Id);
    
    // Level 5: Individual Contributors - Princeton
    createRole('(Princeton) Senior Account Executive – Enterprise', 'Sr_AE_Enterprise_Princeton', branchMgrPrinceton.Id);
    createRole('(Princeton) Account Executive – Commercial', 'AE_Commercial_Princeton', branchMgrPrinceton.Id);
    createRole('(Princeton) Operations Lead', 'Operations_Lead_Princeton', branchMgrPrinceton.Id);
    
    // Level 5: Individual Contributors - Mount Laurel
    createRole('(Mount Laurel) Account Executive – Commercial', 'AE_Commercial_Mount_Laurel', branchMgrMountLaurel.Id);
    createRole('(Mount Laurel) Operations Lead', 'Operations_Lead_Mount_Laurel', branchMgrMountLaurel.Id);
    createRole('(Mount Laurel) Field Service Coordinator', 'Field_Service_Coordinator_Mount_Laurel', branchMgrMountLaurel.Id);
    
    // Level 5: Individual Contributors - Vineland
    createRole('(Vineland) Account Executive – SMB', 'AE_SMB_Vineland', branchMgrVineland.Id);
    createRole('(Vineland) Sales Support Specialist', 'Sales_Support_Specialist_Vineland', branchMgrVineland.Id);
    createRole('(Vineland) Field Service Lead', 'Field_Service_Lead_Vineland', branchMgrVineland.Id);
    
    // Level 5: Individual Contributors - Atlantic City
    createRole('(Atlantic City) Account Executive – Commercial', 'AE_Commercial_Atlantic_City', branchMgrAtlanticCity.Id);
    createRole('(Atlantic City) Service Supervisor', 'Service_Supervisor_Atlantic_City', branchMgrAtlanticCity.Id);
    createRole('(Atlantic City) Logistics Coordinator', 'Logistics_Coordinator_Atlantic_City', branchMgrAtlanticCity.Id);
    
    // Level 5: Individual Contributors - Wilmington
    createRole('(Wilmington) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Wilmington', branchMgrWilmington.Id);
    createRole('(Wilmington) Account Executive – Commercial', 'AE_Commercial_Wilmington', branchMgrWilmington.Id);
    createRole('(Wilmington) Operations Lead', 'Operations_Lead_Wilmington', branchMgrWilmington.Id);
    createRole('(Wilmington) Service Supervisor', 'Service_Supervisor_Wilmington', branchMgrWilmington.Id);
    
    // Level 5: Individual Contributors - Newark DE
    createRole('(Newark DE) Account Executive – SMB', 'AE_SMB_Newark_DE', branchMgrNewarkDE.Id);
    createRole('(Newark DE) Sales Support Specialist', 'Sales_Support_Specialist_Newark_DE', branchMgrNewarkDE.Id);
    createRole('(Newark DE) Field Service Lead', 'Field_Service_Lead_Newark_DE', branchMgrNewarkDE.Id);
    
    // Level 5: Individual Contributors - Dover DE
    createRole('(Dover DE) Account Executive – Commercial', 'AE_Commercial_Dover_DE', branchMgrDoverDE.Id);
    createRole('(Dover DE) Operations Lead', 'Operations_Lead_Dover_DE', branchMgrDoverDE.Id);
    createRole('(Dover DE) Field Service Coordinator', 'Field_Service_Coordinator_Dover_DE', branchMgrDoverDE.Id);
    
    // Level 5: Individual Contributors - Baltimore
    createRole('(Baltimore) Senior Account Executive – Enterprise', 'Sr_AE_Enterprise_Baltimore', branchMgrBaltimore.Id);
    createRole('(Baltimore) Account Executive – Commercial', 'AE_Commercial_Baltimore', branchMgrBaltimore.Id);
    createRole('(Baltimore) Sales Operations Specialist', 'Sales_Ops_Specialist_Baltimore', branchMgrBaltimore.Id);
    createRole('(Baltimore) Service Supervisor', 'Service_Supervisor_Baltimore', branchMgrBaltimore.Id);
    
    // Level 5: Individual Contributors - Towson
    createRole('(Towson) Account Executive – SMB', 'AE_SMB_Towson', branchMgrTowson.Id);
    createRole('(Towson) Field Service Lead', 'Field_Service_Lead_Towson', branchMgrTowson.Id);
    createRole('(Towson) Sales Support Specialist', 'Sales_Support_Specialist_Towson', branchMgrTowson.Id);
    
    // Level 5: Individual Contributors - Columbia MD
    createRole('(Columbia MD) Account Executive – Commercial', 'AE_Commercial_Columbia_MD', branchMgrColumbia.Id);
    createRole('(Columbia MD) Operations Lead', 'Operations_Lead_Columbia_MD', branchMgrColumbia.Id);
    createRole('(Columbia MD) Field Service Coordinator', 'Field_Service_Coordinator_Columbia_MD', branchMgrColumbia.Id);
    
    System.debug('✅ Successfully created all UserRole records in the Northern Mid-Atlantic hierarchy!');
    System.debug('Total roles created: ' + [SELECT COUNT() FROM UserRole WHERE DeveloperName LIKE '%Philadelphia%' OR DeveloperName LIKE '%Edison%' OR DeveloperName LIKE '%Baltimore%']);
    
} catch (Exception e) {
    System.debug('❌ Error creating roles: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

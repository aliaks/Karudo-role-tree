// Anonymous Apex script to create UserRole hierarchy for Upstate New York organization
// Execute this in Developer Console or via SF CLI: sf apex run --file scripts/apex/createRoleHierarchyUpstateNY.apex

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
        WHERE Name = 'Regional Director – Upstate New York' 
        LIMIT 1
    ];
    System.debug('Found existing role: ' + regionalDir.Name + ' (ID: ' + regionalDir.Id + ')');
    roleMap.put('RD_Upstate', regionalDir.Id);
    
    // Level 2: District Directors
    UserRole districtDirHudson = createRole(
        'District Director – Hudson Valley & Capital Region',
        'District_Director_Hudson_Valley_Capital_Region',
        regionalDir.Id
    );
    roleMap.put('DD_Hudson', districtDirHudson.Id);
    
    UserRole districtDirCentral = createRole(
        'District Director – Central New York',
        'District_Director_Central_New_York',
        regionalDir.Id
    );
    roleMap.put('DD_Central', districtDirCentral.Id);
    
    UserRole districtDirWestern = createRole(
        'District Director – Western & Finger Lakes',
        'District_Director_Western_Finger_Lakes',
        regionalDir.Id
    );
    roleMap.put('DD_Western', districtDirWestern.Id);
    
    // Level 3: District Managers - Hudson Valley & Capital Region
    UserRole districtMgrCapital = createRole(
        'District Manager – Capital District',
        'District_Manager_Capital_District',
        districtDirHudson.Id
    );
    roleMap.put('DM_Capital', districtMgrCapital.Id);
    
    UserRole districtMgrMidHudson = createRole(
        'District Manager – Mid-Hudson Valley',
        'District_Manager_Mid_Hudson_Valley',
        districtDirHudson.Id
    );
    roleMap.put('DM_MidHudson', districtMgrMidHudson.Id);
    
    // Level 3: District Managers - Central New York
    UserRole districtMgrSyracuse = createRole(
        'District Manager – Syracuse Metro',
        'District_Manager_Syracuse_Metro',
        districtDirCentral.Id
    );
    roleMap.put('DM_Syracuse', districtMgrSyracuse.Id);
    
    UserRole districtMgrMohawk = createRole(
        'District Manager – Mohawk Valley',
        'District_Manager_Mohawk_Valley',
        districtDirCentral.Id
    );
    roleMap.put('DM_Mohawk', districtMgrMohawk.Id);
    
    // Level 3: District Managers - Western & Finger Lakes
    UserRole districtMgrRochester = createRole(
        'District Manager – Rochester & Finger Lakes',
        'District_Manager_Rochester_Finger_Lakes',
        districtDirWestern.Id
    );
    roleMap.put('DM_Rochester', districtMgrRochester.Id);
    
    UserRole districtMgrBuffalo = createRole(
        'District Manager – Buffalo & Niagara',
        'District_Manager_Buffalo_Niagara',
        districtDirWestern.Id
    );
    roleMap.put('DM_Buffalo', districtMgrBuffalo.Id);
    
    // Level 4: Branch Managers - Capital District
    UserRole branchMgrAlbany = createRole(
        'Branch Manager – Albany',
        'Branch_Manager_Albany',
        districtMgrCapital.Id
    );
    roleMap.put('BM_Albany', branchMgrAlbany.Id);
    
    UserRole branchMgrSchenectady = createRole(
        'Branch Manager – Schenectady',
        'Branch_Manager_Schenectady',
        districtMgrCapital.Id
    );
    roleMap.put('BM_Schenectady', branchMgrSchenectady.Id);
    
    UserRole branchMgrTroy = createRole(
        'Branch Manager – Troy',
        'Branch_Manager_Troy',
        districtMgrCapital.Id
    );
    roleMap.put('BM_Troy', branchMgrTroy.Id);
    
    // Level 4: Branch Managers - Mid-Hudson Valley
    UserRole branchMgrPoughkeepsie = createRole(
        'Branch Manager – Poughkeepsie',
        'Branch_Manager_Poughkeepsie',
        districtMgrMidHudson.Id
    );
    roleMap.put('BM_Poughkeepsie', branchMgrPoughkeepsie.Id);
    
    UserRole branchMgrKingston = createRole(
        'Branch Manager – Kingston',
        'Branch_Manager_Kingston',
        districtMgrMidHudson.Id
    );
    roleMap.put('BM_Kingston', branchMgrKingston.Id);
    
    UserRole branchMgrNewburgh = createRole(
        'Branch Manager – Newburgh',
        'Branch_Manager_Newburgh',
        districtMgrMidHudson.Id
    );
    roleMap.put('BM_Newburgh', branchMgrNewburgh.Id);
    
    // Level 4: Branch Managers - Syracuse Metro
    UserRole branchMgrSyracuse = createRole(
        'Branch Manager – Syracuse',
        'Branch_Manager_Syracuse',
        districtMgrSyracuse.Id
    );
    roleMap.put('BM_Syracuse', branchMgrSyracuse.Id);
    
    UserRole branchMgrLiverpool = createRole(
        'Branch Manager – Liverpool',
        'Branch_Manager_Liverpool',
        districtMgrSyracuse.Id
    );
    roleMap.put('BM_Liverpool', branchMgrLiverpool.Id);
    
    UserRole branchMgrAuburn = createRole(
        'Branch Manager – Auburn',
        'Branch_Manager_Auburn',
        districtMgrSyracuse.Id
    );
    roleMap.put('BM_Auburn', branchMgrAuburn.Id);
    
    // Level 4: Branch Managers - Mohawk Valley
    UserRole branchMgrUtica = createRole(
        'Branch Manager – Utica',
        'Branch_Manager_Utica',
        districtMgrMohawk.Id
    );
    roleMap.put('BM_Utica', branchMgrUtica.Id);
    
    UserRole branchMgrRome = createRole(
        'Branch Manager – Rome',
        'Branch_Manager_Rome',
        districtMgrMohawk.Id
    );
    roleMap.put('BM_Rome', branchMgrRome.Id);
    
    UserRole branchMgrHerkimer = createRole(
        'Branch Manager – Herkimer',
        'Branch_Manager_Herkimer',
        districtMgrMohawk.Id
    );
    roleMap.put('BM_Herkimer', branchMgrHerkimer.Id);
    
    // Level 4: Branch Managers - Rochester & Finger Lakes
    UserRole branchMgrRochester = createRole(
        'Branch Manager – Rochester',
        'Branch_Manager_Rochester',
        districtMgrRochester.Id
    );
    roleMap.put('BM_Rochester', branchMgrRochester.Id);
    
    UserRole branchMgrCanandaigua = createRole(
        'Branch Manager – Canandaigua',
        'Branch_Manager_Canandaigua',
        districtMgrRochester.Id
    );
    roleMap.put('BM_Canandaigua', branchMgrCanandaigua.Id);
    
    UserRole branchMgrGeneva = createRole(
        'Branch Manager – Geneva',
        'Branch_Manager_Geneva',
        districtMgrRochester.Id
    );
    roleMap.put('BM_Geneva', branchMgrGeneva.Id);
    
    // Level 4: Branch Managers - Buffalo & Niagara
    UserRole branchMgrBuffalo = createRole(
        'Branch Manager – Buffalo',
        'Branch_Manager_Buffalo',
        districtMgrBuffalo.Id
    );
    roleMap.put('BM_Buffalo', branchMgrBuffalo.Id);
    
    UserRole branchMgrNiagaraFalls = createRole(
        'Branch Manager – Niagara Falls',
        'Branch_Manager_Niagara_Falls',
        districtMgrBuffalo.Id
    );
    roleMap.put('BM_NiagaraFalls', branchMgrNiagaraFalls.Id);
    
    UserRole branchMgrJamestown = createRole(
        'Branch Manager – Jamestown',
        'Branch_Manager_Jamestown',
        districtMgrBuffalo.Id
    );
    roleMap.put('BM_Jamestown', branchMgrJamestown.Id);
    
    // Level 5: Individual Contributors - Albany
    createRole('(Albany) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Albany', branchMgrAlbany.Id);
    createRole('(Albany) Account Executive – Commercial', 'AE_Commercial_Albany', branchMgrAlbany.Id);
    createRole('(Albany) Sales Operations Specialist', 'Sales_Ops_Specialist_Albany', branchMgrAlbany.Id);
    createRole('(Albany) Service Supervisor', 'Service_Supervisor_Albany', branchMgrAlbany.Id);
    
    // Level 5: Individual Contributors - Schenectady
    createRole('(Schenectady) Account Executive – Commercial', 'AE_Commercial_Schenectady', branchMgrSchenectady.Id);
    createRole('(Schenectady) Operations Lead', 'Operations_Lead_Schenectady', branchMgrSchenectady.Id);
    createRole('(Schenectady) Field Service Coordinator', 'Field_Service_Coordinator_Schenectady', branchMgrSchenectady.Id);
    
    // Level 5: Individual Contributors - Troy
    createRole('(Troy) Account Executive – SMB', 'AE_SMB_Troy', branchMgrTroy.Id);
    createRole('(Troy) Sales Support Specialist', 'Sales_Support_Specialist_Troy', branchMgrTroy.Id);
    createRole('(Troy) Field Service Lead', 'Field_Service_Lead_Troy', branchMgrTroy.Id);
    
    // Level 5: Individual Contributors - Poughkeepsie
    createRole('(Poughkeepsie) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Poughkeepsie', branchMgrPoughkeepsie.Id);
    createRole('(Poughkeepsie) Account Executive – Commercial', 'AE_Commercial_Poughkeepsie', branchMgrPoughkeepsie.Id);
    createRole('(Poughkeepsie) Operations Lead', 'Operations_Lead_Poughkeepsie', branchMgrPoughkeepsie.Id);
    
    // Level 5: Individual Contributors - Kingston
    createRole('(Kingston) Account Executive – SMB', 'AE_SMB_Kingston', branchMgrKingston.Id);
    createRole('(Kingston) Sales Support Specialist', 'Sales_Support_Specialist_Kingston', branchMgrKingston.Id);
    createRole('(Kingston) Field Service Supervisor', 'Field_Service_Supervisor_Kingston', branchMgrKingston.Id);
    
    // Level 5: Individual Contributors - Newburgh
    createRole('(Newburgh) Account Executive – Commercial', 'AE_Commercial_Newburgh', branchMgrNewburgh.Id);
    createRole('(Newburgh) Logistics Coordinator', 'Logistics_Coordinator_Newburgh', branchMgrNewburgh.Id);
    createRole('(Newburgh) Service Supervisor', 'Service_Supervisor_Newburgh', branchMgrNewburgh.Id);
    
    // Level 5: Individual Contributors - Syracuse
    createRole('(Syracuse) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Syracuse', branchMgrSyracuse.Id);
    createRole('(Syracuse) Account Executive – Commercial', 'AE_Commercial_Syracuse', branchMgrSyracuse.Id);
    createRole('(Syracuse) Operations Lead', 'Operations_Lead_Syracuse', branchMgrSyracuse.Id);
    createRole('(Syracuse) Service Supervisor', 'Service_Supervisor_Syracuse', branchMgrSyracuse.Id);
    
    // Level 5: Individual Contributors - Liverpool
    createRole('(Liverpool) Account Executive – SMB', 'AE_SMB_Liverpool', branchMgrLiverpool.Id);
    createRole('(Liverpool) Sales Support Specialist', 'Sales_Support_Specialist_Liverpool', branchMgrLiverpool.Id);
    createRole('(Liverpool) Field Service Lead', 'Field_Service_Lead_Liverpool', branchMgrLiverpool.Id);
    
    // Level 5: Individual Contributors - Auburn
    createRole('(Auburn) Account Executive – Commercial', 'AE_Commercial_Auburn', branchMgrAuburn.Id);
    createRole('(Auburn) Operations Lead', 'Operations_Lead_Auburn', branchMgrAuburn.Id);
    createRole('(Auburn) Field Service Coordinator', 'Field_Service_Coordinator_Auburn', branchMgrAuburn.Id);
    
    // Level 5: Individual Contributors - Utica
    createRole('(Utica) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Utica', branchMgrUtica.Id);
    createRole('(Utica) Account Executive – Commercial', 'AE_Commercial_Utica', branchMgrUtica.Id);
    createRole('(Utica) Service Supervisor', 'Service_Supervisor_Utica', branchMgrUtica.Id);
    
    // Level 5: Individual Contributors - Rome
    createRole('(Rome) Account Executive – SMB', 'AE_SMB_Rome', branchMgrRome.Id);
    createRole('(Rome) Sales Support Specialist', 'Sales_Support_Specialist_Rome', branchMgrRome.Id);
    createRole('(Rome) Field Service Lead', 'Field_Service_Lead_Rome', branchMgrRome.Id);
    
    // Level 5: Individual Contributors - Herkimer
    createRole('(Herkimer) Account Executive – Commercial', 'AE_Commercial_Herkimer', branchMgrHerkimer.Id);
    createRole('(Herkimer) Logistics Supervisor', 'Logistics_Supervisor_Herkimer', branchMgrHerkimer.Id);
    createRole('(Herkimer) Operations Lead', 'Operations_Lead_Herkimer', branchMgrHerkimer.Id);
    
    // Level 5: Individual Contributors - Rochester
    createRole('(Rochester) Senior Account Executive – Enterprise', 'Sr_AE_Enterprise_Rochester', branchMgrRochester.Id);
    createRole('(Rochester) Account Executive – Commercial', 'AE_Commercial_Rochester', branchMgrRochester.Id);
    createRole('(Rochester) Sales Operations Specialist', 'Sales_Ops_Specialist_Rochester', branchMgrRochester.Id);
    createRole('(Rochester) Service Supervisor', 'Service_Supervisor_Rochester', branchMgrRochester.Id);
    
    // Level 5: Individual Contributors - Canandaigua
    createRole('(Canandaigua) Account Executive – SMB', 'AE_SMB_Canandaigua', branchMgrCanandaigua.Id);
    createRole('(Canandaigua) Field Service Lead', 'Field_Service_Lead_Canandaigua', branchMgrCanandaigua.Id);
    createRole('(Canandaigua) Sales Support Specialist', 'Sales_Support_Specialist_Canandaigua', branchMgrCanandaigua.Id);
    
    // Level 5: Individual Contributors - Geneva
    createRole('(Geneva) Account Executive – Commercial', 'AE_Commercial_Geneva', branchMgrGeneva.Id);
    createRole('(Geneva) Operations Lead', 'Operations_Lead_Geneva', branchMgrGeneva.Id);
    createRole('(Geneva) Field Service Coordinator', 'Field_Service_Coordinator_Geneva', branchMgrGeneva.Id);
    
    // Level 5: Individual Contributors - Buffalo
    createRole('(Buffalo) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Buffalo', branchMgrBuffalo.Id);
    createRole('(Buffalo) Account Executive – Commercial', 'AE_Commercial_Buffalo', branchMgrBuffalo.Id);
    createRole('(Buffalo) Logistics Supervisor', 'Logistics_Supervisor_Buffalo', branchMgrBuffalo.Id);
    createRole('(Buffalo) Service Supervisor', 'Service_Supervisor_Buffalo', branchMgrBuffalo.Id);
    
    // Level 5: Individual Contributors - Niagara Falls
    createRole('(Niagara Falls) Account Executive – SMB', 'AE_SMB_Niagara_Falls', branchMgrNiagaraFalls.Id);
    createRole('(Niagara Falls) Field Service Lead', 'Field_Service_Lead_Niagara_Falls', branchMgrNiagaraFalls.Id);
    createRole('(Niagara Falls) Sales Support Specialist', 'Sales_Support_Specialist_Niagara_Falls', branchMgrNiagaraFalls.Id);
    
    // Level 5: Individual Contributors - Jamestown
    createRole('(Jamestown) Account Executive – Commercial', 'AE_Commercial_Jamestown', branchMgrJamestown.Id);
    createRole('(Jamestown) Operations Lead', 'Operations_Lead_Jamestown', branchMgrJamestown.Id);
    createRole('(Jamestown) Field Service Coordinator', 'Field_Service_Coordinator_Jamestown', branchMgrJamestown.Id);
    
    System.debug('✅ Successfully created all UserRole records in the Upstate New York hierarchy!');
    System.debug('Total roles created: ' + [SELECT COUNT() FROM UserRole WHERE DeveloperName LIKE '%Albany%' OR DeveloperName LIKE '%Syracuse%' OR DeveloperName LIKE '%Rochester%']);
    
} catch (Exception e) {
    System.debug('❌ Error creating roles: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

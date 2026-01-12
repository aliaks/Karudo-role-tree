// Anonymous Apex script to create UserRole hierarchy for Southeast organization
// Execute this in Developer Console or via SF CLI: sf apex run --file scripts/apex/createRoleHierarchySoutheast.apex

// Map to store role IDs for parent-child relationships
Map<String, Id> roleMap = new Map<String, Id>();
Set<String> usedDevNames = new Set<String>();

// Helper method to create a role with guaranteed unique DeveloperName
UserRole createRole(String name, String devName, Id parentRoleId) {
    String cleanedDevName = devName.replaceAll('[^a-zA-Z0-9]', '_');
    if (!cleanedDevName.substring(0, 1).isAlpha()) {
        cleanedDevName = 'Role_' + cleanedDevName;
    }
    if (cleanedDevName.length() > 80) {
        cleanedDevName = cleanedDevName.substring(0, 80);
    }
    String finalDevName = cleanedDevName;
    Integer counter = 1;
    while ([SELECT COUNT() FROM UserRole WHERE DeveloperName = :finalDevName] > 0 || usedDevNames.contains(finalDevName)) {
        String suffix = '_' + counter;
        Integer maxLength = 80 - suffix.length();
        finalDevName = cleanedDevName.substring(0, Math.min(cleanedDevName.length(), maxLength)) + suffix;
        counter++;
        if (counter > 1000) {
            throw new IllegalArgumentException('Unable to generate unique DeveloperName for: ' + name);
        }
    }
    usedDevNames.add(finalDevName);
    UserRole role = new UserRole(
        Name = name,
        DeveloperName = finalDevName,
        ParentRoleId = parentRoleId
    );
    insert role;
    System.debug('Created role: ' + name + ' (DevName: ' + finalDevName + ', ID: ' + role.Id + ')');
    return role;
}

try {
    // Level 1: SVP (Top Level) - Assumes this role already exists
    UserRole svp = [
        SELECT Id, Name 
        FROM UserRole 
        WHERE Name = 'SVP – Southeast' 
        LIMIT 1
    ];
    System.debug('Found existing role: ' + svp.Name + ' (ID: ' + svp.Id + ')');
    roleMap.put('SVP_Southeast', svp.Id);
    
    // Level 2: Regional Directors
    UserRole regionalDirCarolinas = createRole(
        'Regional Director – Carolinas',
        'Regional_Director_Carolinas',
        svp.Id
    );
    roleMap.put('RD_Carolinas', regionalDirCarolinas.Id);
    
    UserRole regionalDirGAAL = createRole(
        'Regional Director – Georgia & Alabama',
        'Regional_Director_Georgia_Alabama',
        svp.Id
    );
    roleMap.put('RD_GAAL', regionalDirGAAL.Id);
    
    UserRole regionalDirFlorida = createRole(
        'Regional Director – Florida',
        'Regional_Director_Florida',
        svp.Id
    );
    roleMap.put('RD_Florida', regionalDirFlorida.Id);
    
    // Level 3: District Directors - Carolinas
    UserRole districtDirNC = createRole(
        'District Director – North Carolina',
        'District_Director_North_Carolina',
        regionalDirCarolinas.Id
    );
    roleMap.put('DD_NC', districtDirNC.Id);
    
    UserRole districtDirSC = createRole(
        'District Director – South Carolina',
        'District_Director_South_Carolina',
        regionalDirCarolinas.Id
    );
    roleMap.put('DD_SC', districtDirSC.Id);
    
    // Level 3: District Directors - Georgia & Alabama
    UserRole districtDirGA = createRole(
        'District Director – Georgia',
        'District_Director_Georgia',
        regionalDirGAAL.Id
    );
    roleMap.put('DD_GA', districtDirGA.Id);
    
    UserRole districtDirAL = createRole(
        'District Director – Alabama',
        'District_Director_Alabama',
        regionalDirGAAL.Id
    );
    roleMap.put('DD_AL', districtDirAL.Id);
    
    // Level 3: District Directors - Florida
    UserRole districtDirNorthFL = createRole(
        'District Director – North Florida',
        'District_Director_North_Florida',
        regionalDirFlorida.Id
    );
    roleMap.put('DD_NorthFL', districtDirNorthFL.Id);
    
    UserRole districtDirCentralSouthFL = createRole(
        'District Director – Central & South Florida',
        'District_Director_Central_South_Florida',
        regionalDirFlorida.Id
    );
    roleMap.put('DD_CentralSouthFL', districtDirCentralSouthFL.Id);
    
    // Level 4: District Managers - North Carolina
    UserRole districtMgrCharlotte = createRole(
        'District Manager – Charlotte Metro',
        'District_Manager_Charlotte_Metro',
        districtDirNC.Id
    );
    roleMap.put('DM_Charlotte', districtMgrCharlotte.Id);
    
    UserRole districtMgrRaleighDurham = createRole(
        'District Manager – Raleigh–Durham',
        'District_Manager_Raleigh_Durham',
        districtDirNC.Id
    );
    roleMap.put('DM_RaleighDurham', districtMgrRaleighDurham.Id);
    
    // Level 4: District Managers - South Carolina
    UserRole districtMgrGreenvilleSpartanburg = createRole(
        'District Manager – Greenville–Spartanburg',
        'District_Manager_Greenville_Spartanburg',
        districtDirSC.Id
    );
    roleMap.put('DM_GreenvilleSpartanburg', districtMgrGreenvilleSpartanburg.Id);
    
    UserRole districtMgrCharlestonCoast = createRole(
        'District Manager – Charleston Coast',
        'District_Manager_Charleston_Coast',
        districtDirSC.Id
    );
    roleMap.put('DM_CharlestonCoast', districtMgrCharlestonCoast.Id);
    
    // Level 4: District Managers - Georgia
    UserRole districtMgrAtlanta = createRole(
        'District Manager – Atlanta Metro',
        'District_Manager_Atlanta_Metro',
        districtDirGA.Id
    );
    roleMap.put('DM_Atlanta', districtMgrAtlanta.Id);
    
    UserRole districtMgrSavannahCoastal = createRole(
        'District Manager – Savannah & Coastal GA',
        'District_Manager_Savannah_Coastal_GA',
        districtDirGA.Id
    );
    roleMap.put('DM_SavannahCoastal', districtMgrSavannahCoastal.Id);
    
    // Level 4: District Managers - Alabama
    UserRole districtMgrBirmingham = createRole(
        'District Manager – Birmingham Metro',
        'District_Manager_Birmingham_Metro',
        districtDirAL.Id
    );
    roleMap.put('DM_Birmingham', districtMgrBirmingham.Id);
    
    UserRole districtMgrMobileGulfCoast = createRole(
        'District Manager – Mobile & Gulf Coast',
        'District_Manager_Mobile_Gulf_Coast',
        districtDirAL.Id
    );
    roleMap.put('DM_MobileGulfCoast', districtMgrMobileGulfCoast.Id);
    
    // Level 4: District Managers - North Florida
    UserRole districtMgrJacksonville = createRole(
        'District Manager – Jacksonville',
        'District_Manager_Jacksonville',
        districtDirNorthFL.Id
    );
    roleMap.put('DM_Jacksonville', districtMgrJacksonville.Id);
    
    UserRole districtMgrTallahasseePanhandle = createRole(
        'District Manager – Tallahassee & Panhandle',
        'District_Manager_Tallahassee_Panhandle',
        districtDirNorthFL.Id
    );
    roleMap.put('DM_TallahasseePanhandle', districtMgrTallahasseePanhandle.Id);
    
    // Level 4: District Managers - Central & South Florida
    UserRole districtMgrOrlandoCentral = createRole(
        'District Manager – Orlando & Central FL',
        'District_Manager_Orlando_Central_FL',
        districtDirCentralSouthFL.Id
    );
    roleMap.put('DM_OrlandoCentral', districtMgrOrlandoCentral.Id);
    
    UserRole districtMgrSouthFlorida = createRole(
        'District Manager – South Florida',
        'District_Manager_South_Florida',
        districtDirCentralSouthFL.Id
    );
    roleMap.put('DM_SouthFlorida', districtMgrSouthFlorida.Id);
    
    // Level 5: Branch Managers - Charlotte Metro
    UserRole branchMgrCharlotte = createRole(
        'Branch Manager – Charlotte',
        'Branch_Manager_Charlotte',
        districtMgrCharlotte.Id
    );
    roleMap.put('BM_Charlotte', branchMgrCharlotte.Id);
    
    UserRole branchMgrGastonia = createRole(
        'Branch Manager – Gastonia',
        'Branch_Manager_Gastonia',
        districtMgrCharlotte.Id
    );
    roleMap.put('BM_Gastonia', branchMgrGastonia.Id);
    
    // Level 5: Branch Managers - Raleigh–Durham
    UserRole branchMgrRaleigh = createRole(
        'Branch Manager – Raleigh',
        'Branch_Manager_Raleigh',
        districtMgrRaleighDurham.Id
    );
    roleMap.put('BM_Raleigh', branchMgrRaleigh.Id);
    
    UserRole branchMgrDurham = createRole(
        'Branch Manager – Durham',
        'Branch_Manager_Durham',
        districtMgrRaleighDurham.Id
    );
    roleMap.put('BM_Durham', branchMgrDurham.Id);
    
    // Level 5: Branch Managers - Greenville–Spartanburg
    UserRole branchMgrGreenville = createRole(
        'Branch Manager – Greenville',
        'Branch_Manager_Greenville',
        districtMgrGreenvilleSpartanburg.Id
    );
    roleMap.put('BM_Greenville', branchMgrGreenville.Id);
    
    UserRole branchMgrSpartanburg = createRole(
        'Branch Manager – Spartanburg',
        'Branch_Manager_Spartanburg',
        districtMgrGreenvilleSpartanburg.Id
    );
    roleMap.put('BM_Spartanburg', branchMgrSpartanburg.Id);
    
    // Level 5: Branch Managers - Charleston Coast
    UserRole branchMgrCharleston = createRole(
        'Branch Manager – Charleston',
        'Branch_Manager_Charleston',
        districtMgrCharlestonCoast.Id
    );
    roleMap.put('BM_Charleston', branchMgrCharleston.Id);
    
    UserRole branchMgrMountPleasant = createRole(
        'Branch Manager – Mount Pleasant',
        'Branch_Manager_Mount_Pleasant',
        districtMgrCharlestonCoast.Id
    );
    roleMap.put('BM_MountPleasant', branchMgrMountPleasant.Id);
    
    // Level 5: Branch Managers - Atlanta Metro
    UserRole branchMgrAtlanta = createRole(
        'Branch Manager – Atlanta',
        'Branch_Manager_Atlanta',
        districtMgrAtlanta.Id
    );
    roleMap.put('BM_Atlanta', branchMgrAtlanta.Id);
    
    UserRole branchMgrMarietta = createRole(
        'Branch Manager – Marietta',
        'Branch_Manager_Marietta',
        districtMgrAtlanta.Id
    );
    roleMap.put('BM_Marietta', branchMgrMarietta.Id);
    
    // Level 5: Branch Managers - Savannah & Coastal GA
    UserRole branchMgrSavannah = createRole(
        'Branch Manager – Savannah',
        'Branch_Manager_Savannah',
        districtMgrSavannahCoastal.Id
    );
    roleMap.put('BM_Savannah', branchMgrSavannah.Id);
    
    UserRole branchMgrBrunswick = createRole(
        'Branch Manager – Brunswick',
        'Branch_Manager_Brunswick',
        districtMgrSavannahCoastal.Id
    );
    roleMap.put('BM_Brunswick', branchMgrBrunswick.Id);
    
    // Level 5: Branch Managers - Birmingham Metro
    UserRole branchMgrBirmingham = createRole(
        'Branch Manager – Birmingham',
        'Branch_Manager_Birmingham',
        districtMgrBirmingham.Id
    );
    roleMap.put('BM_Birmingham', branchMgrBirmingham.Id);
    
    UserRole branchMgrHoover = createRole(
        'Branch Manager – Hoover',
        'Branch_Manager_Hoover',
        districtMgrBirmingham.Id
    );
    roleMap.put('BM_Hoover', branchMgrHoover.Id);
    
    // Level 5: Branch Managers - Mobile & Gulf Coast
    UserRole branchMgrMobile = createRole(
        'Branch Manager – Mobile',
        'Branch_Manager_Mobile',
        districtMgrMobileGulfCoast.Id
    );
    roleMap.put('BM_Mobile', branchMgrMobile.Id);
    
    UserRole branchMgrDaphne = createRole(
        'Branch Manager – Daphne',
        'Branch_Manager_Daphne',
        districtMgrMobileGulfCoast.Id
    );
    roleMap.put('BM_Daphne', branchMgrDaphne.Id);
    
    // Level 5: Branch Managers - Jacksonville
    UserRole branchMgrJacksonville = createRole(
        'Branch Manager – Jacksonville',
        'Branch_Manager_Jacksonville',
        districtMgrJacksonville.Id
    );
    roleMap.put('BM_Jacksonville', branchMgrJacksonville.Id);
    
    UserRole branchMgrStAugustine = createRole(
        'Branch Manager – St. Augustine',
        'Branch_Manager_St_Augustine',
        districtMgrJacksonville.Id
    );
    roleMap.put('BM_StAugustine', branchMgrStAugustine.Id);
    
    // Level 5: Branch Managers - Tallahassee & Panhandle
    UserRole branchMgrTallahassee = createRole(
        'Branch Manager – Tallahassee',
        'Branch_Manager_Tallahassee',
        districtMgrTallahasseePanhandle.Id
    );
    roleMap.put('BM_Tallahassee', branchMgrTallahassee.Id);
    
    UserRole branchMgrPensacola = createRole(
        'Branch Manager – Pensacola',
        'Branch_Manager_Pensacola',
        districtMgrTallahasseePanhandle.Id
    );
    roleMap.put('BM_Pensacola', branchMgrPensacola.Id);
    
    // Level 5: Branch Managers - Orlando & Central FL
    UserRole branchMgrOrlando = createRole(
        'Branch Manager – Orlando',
        'Branch_Manager_Orlando',
        districtMgrOrlandoCentral.Id
    );
    roleMap.put('BM_Orlando', branchMgrOrlando.Id);
    
    UserRole branchMgrKissimmee = createRole(
        'Branch Manager – Kissimmee',
        'Branch_Manager_Kissimmee',
        districtMgrOrlandoCentral.Id
    );
    roleMap.put('BM_Kissimmee', branchMgrKissimmee.Id);
    
    // Level 5: Branch Managers - South Florida
    UserRole branchMgrMiami = createRole(
        'Branch Manager – Miami',
        'Branch_Manager_Miami',
        districtMgrSouthFlorida.Id
    );
    roleMap.put('BM_Miami', branchMgrMiami.Id);
    
    UserRole branchMgrFortLauderdale = createRole(
        'Branch Manager – Fort Lauderdale',
        'Branch_Manager_Fort_Lauderdale',
        districtMgrSouthFlorida.Id
    );
    roleMap.put('BM_FortLauderdale', branchMgrFortLauderdale.Id);
    
    // Level 6: Individual Contributors - Charlotte
    createRole('(Charlotte) Senior Account Executive – Enterprise', 'Sr_AE_Enterprise_Charlotte', branchMgrCharlotte.Id);
    createRole('(Charlotte) Account Executive – Commercial', 'AE_Commercial_Charlotte', branchMgrCharlotte.Id);
    createRole('(Charlotte) Sales Operations Specialist', 'Sales_Ops_Specialist_Charlotte', branchMgrCharlotte.Id);
    createRole('(Charlotte) Service Supervisor', 'Service_Supervisor_Charlotte', branchMgrCharlotte.Id);
    
    // Level 6: Individual Contributors - Gastonia
    createRole('(Gastonia) Account Executive – Commercial', 'AE_Commercial_Gastonia', branchMgrGastonia.Id);
    createRole('(Gastonia) Operations Lead', 'Operations_Lead_Gastonia', branchMgrGastonia.Id);
    createRole('(Gastonia) Field Service Coordinator', 'Field_Service_Coordinator_Gastonia', branchMgrGastonia.Id);
    
    // Level 6: Individual Contributors - Raleigh
    createRole('(Raleigh) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Raleigh', branchMgrRaleigh.Id);
    createRole('(Raleigh) Account Executive – Commercial', 'AE_Commercial_Raleigh', branchMgrRaleigh.Id);
    createRole('(Raleigh) Service Supervisor', 'Service_Supervisor_Raleigh', branchMgrRaleigh.Id);
    
    // Level 6: Individual Contributors - Durham
    createRole('(Durham) Account Executive – SMB', 'AE_SMB_Durham', branchMgrDurham.Id);
    createRole('(Durham) Field Service Lead', 'Field_Service_Lead_Durham', branchMgrDurham.Id);
    
    // Level 6: Individual Contributors - Greenville
    createRole('(Greenville) Account Executive – Commercial', 'AE_Commercial_Greenville', branchMgrGreenville.Id);
    createRole('(Greenville) Operations Lead', 'Operations_Lead_Greenville', branchMgrGreenville.Id);
    
    // Level 6: Individual Contributors - Spartanburg
    createRole('(Spartanburg) Account Executive – SMB', 'AE_SMB_Spartanburg', branchMgrSpartanburg.Id);
    createRole('(Spartanburg) Service Supervisor', 'Service_Supervisor_Spartanburg', branchMgrSpartanburg.Id);
    
    // Level 6: Individual Contributors - Charleston
    createRole('(Charleston) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Charleston', branchMgrCharleston.Id);
    createRole('(Charleston) Account Executive – Commercial', 'AE_Commercial_Charleston', branchMgrCharleston.Id);
    createRole('(Charleston) Service Supervisor', 'Service_Supervisor_Charleston', branchMgrCharleston.Id);
    
    // Level 6: Individual Contributors - Mount Pleasant
    createRole('(Mount Pleasant) Account Executive – SMB', 'AE_SMB_Mount_Pleasant', branchMgrMountPleasant.Id);
    createRole('(Mount Pleasant) Field Service Lead', 'Field_Service_Lead_Mount_Pleasant', branchMgrMountPleasant.Id);
    
    // Level 6: Individual Contributors - Atlanta
    createRole('(Atlanta) Senior Account Executive – Enterprise', 'Sr_AE_Enterprise_Atlanta', branchMgrAtlanta.Id);
    createRole('(Atlanta) Account Executive – Commercial', 'AE_Commercial_Atlanta', branchMgrAtlanta.Id);
    createRole('(Atlanta) Sales Operations Specialist', 'Sales_Ops_Specialist_Atlanta', branchMgrAtlanta.Id);
    createRole('(Atlanta) Service Supervisor', 'Service_Supervisor_Atlanta', branchMgrAtlanta.Id);
    
    // Level 6: Individual Contributors - Marietta
    createRole('(Marietta) Account Executive – Commercial', 'AE_Commercial_Marietta', branchMgrMarietta.Id);
    createRole('(Marietta) Operations Lead', 'Operations_Lead_Marietta', branchMgrMarietta.Id);
    createRole('(Marietta) Field Service Coordinator', 'Field_Service_Coordinator_Marietta', branchMgrMarietta.Id);
    
    // Level 6: Individual Contributors - Savannah
    createRole('(Savannah) Account Executive – Commercial', 'AE_Commercial_Savannah', branchMgrSavannah.Id);
    createRole('(Savannah) Service Supervisor', 'Service_Supervisor_Savannah', branchMgrSavannah.Id);
    
    // Level 6: Individual Contributors - Brunswick
    createRole('(Brunswick) Account Executive – SMB', 'AE_SMB_Brunswick', branchMgrBrunswick.Id);
    createRole('(Brunswick) Field Service Lead', 'Field_Service_Lead_Brunswick', branchMgrBrunswick.Id);
    
    // Level 6: Individual Contributors - Birmingham
    createRole('(Birmingham) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Birmingham', branchMgrBirmingham.Id);
    createRole('(Birmingham) Account Executive – Commercial', 'AE_Commercial_Birmingham', branchMgrBirmingham.Id);
    createRole('(Birmingham) Service Supervisor', 'Service_Supervisor_Birmingham', branchMgrBirmingham.Id);
    
    // Level 6: Individual Contributors - Hoover
    createRole('(Hoover) Account Executive – SMB', 'AE_SMB_Hoover', branchMgrHoover.Id);
    createRole('(Hoover) Field Service Lead', 'Field_Service_Lead_Hoover', branchMgrHoover.Id);
    
    // Level 6: Individual Contributors - Mobile
    createRole('(Mobile) Account Executive – Commercial', 'AE_Commercial_Mobile', branchMgrMobile.Id);
    createRole('(Mobile) Operations Lead', 'Operations_Lead_Mobile', branchMgrMobile.Id);
    
    // Level 6: Individual Contributors - Daphne
    createRole('(Daphne) Account Executive – SMB', 'AE_SMB_Daphne', branchMgrDaphne.Id);
    createRole('(Daphne) Field Service Coordinator', 'Field_Service_Coordinator_Daphne', branchMgrDaphne.Id);
    
    // Level 6: Individual Contributors - Jacksonville
    createRole('(Jacksonville) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Jacksonville', branchMgrJacksonville.Id);
    createRole('(Jacksonville) Account Executive – Commercial', 'AE_Commercial_Jacksonville', branchMgrJacksonville.Id);
    createRole('(Jacksonville) Service Supervisor', 'Service_Supervisor_Jacksonville', branchMgrJacksonville.Id);
    
    // Level 6: Individual Contributors - St. Augustine
    createRole('(St. Augustine) Account Executive – SMB', 'AE_SMB_St_Augustine', branchMgrStAugustine.Id);
    createRole('(St. Augustine) Field Service Lead', 'Field_Service_Lead_St_Augustine', branchMgrStAugustine.Id);
    
    // Level 6: Individual Contributors - Tallahassee
    createRole('(Tallahassee) Account Executive – Commercial', 'AE_Commercial_Tallahassee', branchMgrTallahassee.Id);
    createRole('(Tallahassee) Operations Lead', 'Operations_Lead_Tallahassee', branchMgrTallahassee.Id);
    
    // Level 6: Individual Contributors - Pensacola
    createRole('(Pensacola) Account Executive – SMB', 'AE_SMB_Pensacola', branchMgrPensacola.Id);
    createRole('(Pensacola) Field Service Coordinator', 'Field_Service_Coordinator_Pensacola', branchMgrPensacola.Id);
    
    // Level 6: Individual Contributors - Orlando
    createRole('(Orlando) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Orlando', branchMgrOrlando.Id);
    createRole('(Orlando) Account Executive – Commercial', 'AE_Commercial_Orlando', branchMgrOrlando.Id);
    createRole('(Orlando) Service Supervisor', 'Service_Supervisor_Orlando', branchMgrOrlando.Id);
    
    // Level 6: Individual Contributors - Kissimmee
    createRole('(Kissimmee) Account Executive – SMB', 'AE_SMB_Kissimmee', branchMgrKissimmee.Id);
    createRole('(Kissimmee) Field Service Lead', 'Field_Service_Lead_Kissimmee', branchMgrKissimmee.Id);
    
    // Level 6: Individual Contributors - Miami
    createRole('(Miami) Senior Account Executive – Enterprise', 'Sr_AE_Enterprise_Miami', branchMgrMiami.Id);
    createRole('(Miami) Account Executive – Commercial', 'AE_Commercial_Miami', branchMgrMiami.Id);
    createRole('(Miami) Service Supervisor', 'Service_Supervisor_Miami', branchMgrMiami.Id);
    
    // Level 6: Individual Contributors - Fort Lauderdale
    createRole('(Fort Lauderdale) Account Executive – Commercial', 'AE_Commercial_Fort_Lauderdale', branchMgrFortLauderdale.Id);
    createRole('(Fort Lauderdale) Field Service Coordinator', 'Field_Service_Coordinator_Fort_Lauderdale', branchMgrFortLauderdale.Id);
    
    System.debug('✅ Successfully created all UserRole records in the Southeast hierarchy!');
    System.debug('Total roles created: ' + [SELECT COUNT() FROM UserRole WHERE DeveloperName LIKE '%Charlotte%' OR DeveloperName LIKE '%Atlanta%' OR DeveloperName LIKE '%Miami%']);
    
} catch (Exception e) {
    System.debug('❌ Error creating roles: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

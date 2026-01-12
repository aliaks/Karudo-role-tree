// Anonymous Apex script to create UserRole hierarchy for Rhode Island Coastal organization
// Execute this in Developer Console or via SF CLI: sf apex run --file scripts/apex/createRoleHierarchyRI.apex

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
        WHERE Name = 'District Manager – Rhode Island Coastal' 
        LIMIT 1
    ];
    System.debug('Found existing role: ' + districtMgr.Name + ' (ID: ' + districtMgr.Id + ')');
    roleMap.put('DM_RI', districtMgr.Id);
    
    // Level 2: Market Managers
    UserRole marketMgrProvidence = createRole(
        'Market Manager – Providence Metro',
        'Market_Manager_Providence_Metro',
        districtMgr.Id
    );
    roleMap.put('MM_Providence', marketMgrProvidence.Id);
    
    UserRole marketMgrAquidneck = createRole(
        'Market Manager – Aquidneck & East Bay',
        'Market_Manager_Aquidneck_East_Bay',
        districtMgr.Id
    );
    roleMap.put('MM_Aquidneck', marketMgrAquidneck.Id);
    
    UserRole marketMgrSouthCounty = createRole(
        'Market Manager – South County Shore',
        'Market_Manager_South_County_Shore',
        districtMgr.Id
    );
    roleMap.put('MM_SouthCounty', marketMgrSouthCounty.Id);
    
    // Level 3: Branch Managers - Providence Metro
    UserRole branchMgrProvidence = createRole(
        'Branch Manager – Providence',
        'Branch_Manager_Providence',
        marketMgrProvidence.Id
    );
    roleMap.put('BM_Providence', branchMgrProvidence.Id);
    
    UserRole branchMgrCranston = createRole(
        'Branch Manager – Cranston / Warwick',
        'Branch_Manager_Cranston_Warwick',
        marketMgrProvidence.Id
    );
    roleMap.put('BM_Cranston', branchMgrCranston.Id);
    
    UserRole branchMgrPawtucket = createRole(
        'Branch Manager – Pawtucket / Central Falls',
        'Branch_Manager_Pawtucket_Central_Falls',
        marketMgrProvidence.Id
    );
    roleMap.put('BM_Pawtucket', branchMgrPawtucket.Id);
    
    // Level 3: Branch Managers - Aquidneck & East Bay
    UserRole branchMgrNewport = createRole(
        'Branch Manager – Newport',
        'Branch_Manager_Newport',
        marketMgrAquidneck.Id
    );
    roleMap.put('BM_Newport', branchMgrNewport.Id);
    
    UserRole branchMgrMiddletown = createRole(
        'Branch Manager – Middletown / Portsmouth',
        'Branch_Manager_Middletown_Portsmouth',
        marketMgrAquidneck.Id
    );
    roleMap.put('BM_Middletown', branchMgrMiddletown.Id);
    
    UserRole branchMgrBristol = createRole(
        'Branch Manager – Bristol / Warren',
        'Branch_Manager_Bristol_Warren',
        marketMgrAquidneck.Id
    );
    roleMap.put('BM_Bristol', branchMgrBristol.Id);
    
    // Level 3: Branch Managers - South County Shore
    UserRole branchMgrNarragansett = createRole(
        'Branch Manager – Narragansett',
        'Branch_Manager_Narragansett',
        marketMgrSouthCounty.Id
    );
    roleMap.put('BM_Narragansett', branchMgrNarragansett.Id);
    
    UserRole branchMgrSouthKingstown = createRole(
        'Branch Manager – South Kingstown',
        'Branch_Manager_South_Kingstown',
        marketMgrSouthCounty.Id
    );
    roleMap.put('BM_SouthKingstown', branchMgrSouthKingstown.Id);
    
    UserRole branchMgrWesterly = createRole(
        'Branch Manager – Westerly',
        'Branch_Manager_Westerly',
        marketMgrSouthCounty.Id
    );
    roleMap.put('BM_Westerly', branchMgrWesterly.Id);
    
    // Level 4: Individual Contributors - Providence Branch
    createRole('(Providence) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Providence', branchMgrProvidence.Id);
    createRole('(Providence) Account Executive – Commercial', 'AE_Commercial_Providence', branchMgrProvidence.Id);
    createRole('(Providence) Sales Operations Specialist', 'Sales_Ops_Specialist_Providence', branchMgrProvidence.Id);
    createRole('(Providence) Service Supervisor', 'Service_Supervisor_Providence', branchMgrProvidence.Id);
    
    // Level 4: Individual Contributors - Cranston/Warwick Branch
    createRole('(Cranston/Warwick) Account Executive – Commercial', 'AE_Commercial_Cranston_Warwick', branchMgrCranston.Id);
    createRole('(Cranston/Warwick) Account Executive – SMB', 'AE_SMB_Cranston_Warwick', branchMgrCranston.Id);
    createRole('(Cranston/Warwick) Field Service Lead', 'Field_Service_Lead_Cranston_Warwick', branchMgrCranston.Id);
    
    // Level 4: Individual Contributors - Pawtucket/Central Falls Branch
    createRole('(Pawtucket) Account Executive – Commercial', 'AE_Commercial_Pawtucket', branchMgrPawtucket.Id);
    createRole('(Central Falls) Sales Support Specialist', 'Sales_Support_Specialist_Central_Falls', branchMgrPawtucket.Id);
    createRole('(Pawtucket) Operations Lead', 'Operations_Lead_Pawtucket', branchMgrPawtucket.Id);
    
    // Level 4: Individual Contributors - Newport Branch
    createRole('(Newport) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Newport', branchMgrNewport.Id);
    createRole('(Newport) Account Executive – SMB', 'AE_SMB_Newport', branchMgrNewport.Id);
    createRole('(Newport) Service Supervisor', 'Service_Supervisor_Newport', branchMgrNewport.Id);
    createRole('(Newport) Field Service Coordinator', 'Field_Service_Coordinator_Newport', branchMgrNewport.Id);
    
    // Level 4: Individual Contributors - Middletown/Portsmouth Branch
    createRole('(Middletown) Account Executive – Commercial', 'AE_Commercial_Middletown', branchMgrMiddletown.Id);
    createRole('(Portsmouth) Logistics Coordinator', 'Logistics_Coordinator_Portsmouth', branchMgrMiddletown.Id);
    createRole('(Middletown/Portsmouth) Operations Lead', 'Operations_Lead_Middletown_Portsmouth', branchMgrMiddletown.Id);
    
    // Level 4: Individual Contributors - Bristol/Warren Branch
    createRole('(Bristol) Account Executive – SMB', 'AE_SMB_Bristol', branchMgrBristol.Id);
    createRole('(Warren) Sales Support Specialist', 'Sales_Support_Specialist_Warren', branchMgrBristol.Id);
    createRole('(Bristol/Warren) Field Service Supervisor', 'Field_Service_Supervisor_Bristol_Warren', branchMgrBristol.Id);
    
    // Level 4: Individual Contributors - Narragansett Branch
    createRole('(Narragansett) Account Executive – SMB', 'AE_SMB_Narragansett', branchMgrNarragansett.Id);
    createRole('(Narragansett) Field Service Lead', 'Field_Service_Lead_Narragansett', branchMgrNarragansett.Id);
    createRole('(Narragansett) Service Supervisor', 'Service_Supervisor_Narragansett', branchMgrNarragansett.Id);
    
    // Level 4: Individual Contributors - South Kingstown Branch
    createRole('(South Kingstown) Account Executive – Commercial', 'AE_Commercial_South_Kingstown', branchMgrSouthKingstown.Id);
    createRole('(South Kingstown) Operations Lead', 'Operations_Lead_South_Kingstown', branchMgrSouthKingstown.Id);
    createRole('(South Kingstown) Sales Support Specialist', 'Sales_Support_Specialist_South_Kingstown', branchMgrSouthKingstown.Id);
    
    // Level 4: Individual Contributors - Westerly Branch
    createRole('(Westerly) Senior Account Executive – Commercial', 'Sr_AE_Commercial_Westerly', branchMgrWesterly.Id);
    createRole('(Westerly) Account Executive – Commercial', 'AE_Commercial_Westerly', branchMgrWesterly.Id);
    createRole('(Westerly) Logistics Supervisor', 'Logistics_Supervisor_Westerly', branchMgrWesterly.Id);
    createRole('(Westerly) Field Service Coordinator', 'Field_Service_Coordinator_Westerly', branchMgrWesterly.Id);
    
    System.debug('✅ Successfully created all UserRole records in the Rhode Island hierarchy!');
    System.debug('Total roles created: ' + [SELECT COUNT() FROM UserRole WHERE DeveloperName LIKE '%Providence%' OR DeveloperName LIKE '%Newport%' OR DeveloperName LIKE '%Westerly%']);
    
} catch (Exception e) {
    System.debug('❌ Error creating roles: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}

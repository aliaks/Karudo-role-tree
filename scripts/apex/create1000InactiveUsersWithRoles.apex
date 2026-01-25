// Get Standard User Profile (Salesforce license)
Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

// Get all available roles
List<UserRole> roles = [SELECT Id, Name FROM UserRole];
System.debug('Found ' + roles.size() + ' roles');

if (roles.isEmpty()) {
    System.debug('ERROR: No roles found. Please create roles first.');
    return;
}

// Name lists for generating 1000 unique users
List<String> firstNames = new List<String>{
    'James', 'Mary', 'John', 'Patricia', 'Robert', 'Jennifer', 'Michael', 'Linda', 'William', 'Elizabeth',
    'David', 'Barbara', 'Richard', 'Susan', 'Joseph', 'Jessica', 'Thomas', 'Sarah', 'Charles', 'Karen',
    'Christopher', 'Nancy', 'Daniel', 'Lisa', 'Matthew', 'Betty', 'Anthony', 'Margaret', 'Mark', 'Sandra',
    'Donald', 'Ashley', 'Steven', 'Kimberly', 'Paul', 'Emily', 'Andrew', 'Donna', 'Joshua', 'Michelle',
    'Kenneth', 'Dorothy', 'Kevin', 'Carol', 'Brian', 'Amanda', 'George', 'Melissa', 'Edward', 'Deborah',
    'Timothy', 'Rebecca', 'Ronald', 'Sharon', 'Jason', 'Cynthia', 'Jeffrey', 'Kathleen', 'Ryan', 'Amy',
    'Jacob', 'Shirley', 'Gary', 'Angela', 'Nicholas', 'Helen', 'Eric', 'Anna', 'Jonathan', 'Brenda',
    'Stephen', 'Pamela', 'Larry', 'Nicole', 'Justin', 'Emma', 'Scott', 'Samantha', 'Brandon', 'Katherine',
    'Benjamin', 'Christine', 'Samuel', 'Debra', 'Raymond', 'Rachel', 'Gregory', 'Catherine', 'Frank', 'Carolyn',
    'Alexander', 'Janet', 'Patrick', 'Ruth', 'Jack', 'Maria', 'Dennis', 'Heather', 'Jerry', 'Diane'
};

List<String> lastNames = new List<String>{
    'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
    'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin',
    'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson',
    'Walker', 'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores',
    'Green', 'Adams', 'Nelson', 'Baker', 'Hall', 'Rivera', 'Campbell', 'Mitchell', 'Carter', 'Roberts',
    'Gomez', 'Phillips', 'Evans', 'Turner', 'Diaz', 'Parker', 'Cruz', 'Edwards', 'Collins', 'Reyes',
    'Stewart', 'Morris', 'Morales', 'Murphy', 'Cook', 'Rogers', 'Gutierrez', 'Ortiz', 'Morgan', 'Cooper',
    'Peterson', 'Bailey', 'Reed', 'Kelly', 'Howard', 'Ramos', 'Kim', 'Cox', 'Ward', 'Richardson',
    'Watson', 'Brooks', 'Chavez', 'Wood', 'James', 'Bennett', 'Gray', 'Mendoza', 'Ruiz', 'Hughes',
    'Price', 'Alvarez', 'Castillo', 'Sanders', 'Patel', 'Myers', 'Long', 'Ross', 'Foster', 'Jimenez'
};

// Create 1000 inactive users
List<User> usersToCreate = new List<User>();
Integer createdCount = 0;
 
for (Integer batch = 0; batch < 200; batch++) {
    
        // Randomly select first and last names
        Integer firstNameIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), firstNames.size());
        Integer lastNameIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), lastNames.size());
        
        String firstName = firstNames[firstNameIndex];
        String lastName = lastNames[lastNameIndex];
        
        // Add number suffix to ensure uniqueness
        Integer userNum = Math.mod(Math.abs(Crypto.getRandomInteger()), firstNames.size());
        String uniqueSuffix = String.valueOf(userNum);
        String email = firstName.toLowerCase() + '.' + lastName.toLowerCase() + uniqueSuffix + '@global.com';
        String username = email + '.inactive';
        
        // Generate alias (max 8 characters)
        String baseAlias = (firstName.substring(0, 1) + lastName.substring(0, Math.min(4, lastName.length()))).toLowerCase();
        String alias = baseAlias + String.valueOf(userNum).substring(0, Math.min(3, String.valueOf(userNum).length()));
        if (alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        
        // Randomly assign a role from the hierarchy
        Integer randomRoleIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), roles.size());
        Id assignedRoleId = roles[randomRoleIndex].Id;
        
        usersToCreate.add(new User(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Username = username,
            Alias = alias,
            ProfileId = stdProfile.Id,
            UserRoleId = assignedRoleId,
            IsActive = false,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        ));
    }    
    // Insert batch
    try 
    {   insert usersToCreate;
    } 
    catch (Exception e) 
    {   System.debug('ERROR ---> ' + e.getMessage());
    }


System.debug('===========================================');
System.debug('Successfully created ' + createdCount + ' inactive users');
System.debug('Users randomly assigned across ' + roles.size() + ' roles');
System.debug('===========================================');

// Query and display distribution summary
Map<Id, Integer> roleDistribution = new Map<Id, Integer>();
for (UserRole role : roles) {
    roleDistribution.put(role.Id, 0);
}

List<User> createdUsers = [SELECT Id, UserRoleId FROM User WHERE IsActive = false AND Username LIKE '%.inactive' LIMIT 1000];
for (User u : createdUsers) {
    if (roleDistribution.containsKey(u.UserRoleId)) {
        roleDistribution.put(u.UserRoleId, roleDistribution.get(u.UserRoleId) + 1);
    }
}

System.debug('Distribution across roles:');
for (UserRole role : roles) {
    System.debug('  ' + role.Name + ': ' + roleDistribution.get(role.Id) + ' users');
}

// Get Standard User Profile (Salesforce license)
Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

// Get all available roles
List<UserRole> roles = [SELECT Id, Name FROM UserRole];
System.debug('Found ' + roles.size() + ' roles');

if (roles.isEmpty()) {
    System.debug('ERROR: No roles found. Please create roles first.');
    return;
}

// Create 50 inactive users with realistic names
List<User> usersToCreate = new List<User>();
List<String> firstNames = new List<String>{
    'James', 'Mary', 'John', 'Patricia', 'Robert', 'Jennifer', 'Michael', 'Linda', 'William', 'Elizabeth',
    'David', 'Barbara', 'Richard', 'Susan', 'Joseph', 'Jessica', 'Thomas', 'Sarah', 'Charles', 'Karen',
    'Christopher', 'Nancy', 'Daniel', 'Lisa', 'Matthew', 'Betty', 'Anthony', 'Margaret', 'Mark', 'Sandra',
    'Donald', 'Ashley', 'Steven', 'Kimberly', 'Paul', 'Emily', 'Andrew', 'Donna', 'Joshua', 'Michelle',
    'Kenneth', 'Dorothy', 'Kevin', 'Carol', 'Brian', 'Amanda', 'George', 'Melissa', 'Edward', 'Deborah'
};

List<String> lastNames = new List<String>{
    'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez',
    'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin',
    'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson',
    'Walker', 'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores',
    'Green', 'Adams', 'Nelson', 'Baker', 'Hall', 'Rivera', 'Campbell', 'Mitchell', 'Carter', 'Roberts'
};

for (Integer i = 0; i < 50; i++) {
    String firstName = firstNames[i];
    String lastName = lastNames[i];
    String email = firstName.toLowerCase() + '.' + lastName.toLowerCase() + '@global.com';
    String username = email + '.inactive' + i;
    String alias = (firstName.substring(0, 1) + lastName.substring(0, Math.min(4, lastName.length()))).toLowerCase();
    
    // Randomly assign a role
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

// Insert users
insert usersToCreate;

System.debug('Successfully created ' + usersToCreate.size() + ' inactive users');
for (User u : usersToCreate) {
    System.debug('Created: ' + u.FirstName + ' ' + u.LastName + ' (ID: ' + u.Id + ', Role: ' + u.UserRoleId + ')');
}

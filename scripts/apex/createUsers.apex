// Get Standard User Profile (Salesforce license)
Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

// Create 10 users with realistic names
List<User> usersToCreate = new List<User>();

// usersToCreate.add(new User(
//     FirstName = 'Sarah',
//     LastName = 'Johnson',
//     Email = 'sarah.johnson@global.com',
//     Username = 'sarah.johnson@global.com.demo',
//     Alias = 'sjohn',
//     ProfileId = stdProfile.Id,
//     TimeZoneSidKey = 'America/New_York',
//     LocaleSidKey = 'en_US',
//     EmailEncodingKey = 'UTF-8',
//     LanguageLocaleKey = 'en_US'
// ));

// Testing with 1 user due to license constraints
// usersToCreate.add(new User(
//     FirstName = 'Michael',
//     LastName = 'Chen',
//     Email = 'michael.chen@global.com',
//     Username = 'michael.chen@global.com.demo',
//     Alias = 'mchen',
//     ProfileId = stdProfile.Id,
//     TimeZoneSidKey = 'America/New_York',
//     LocaleSidKey = 'en_US',
//     EmailEncodingKey = 'UTF-8',
//     LanguageLocaleKey = 'en_US'
// ));

// usersToCreate.add(new User(
//     FirstName = 'Emily',
//     LastName = 'Rodriguez',
//     Email = 'emily.rodriguez@global.com',
//     Username = 'emily.rodriguez@global.com.demo',
//     Alias = 'erodri',
//     ProfileId = stdProfile.Id,
//     TimeZoneSidKey = 'America/New_York',
//     LocaleSidKey = 'en_US',
//     EmailEncodingKey = 'UTF-8',
//     LanguageLocaleKey = 'en_US'
// ));


// usersToCreate.add(new User(
//     FirstName = 'David',
//     LastName = 'Thompson',
//     Email = 'david.thompson@global.com',
//     IsActive = false,
//     Username = 'david.thompson@global.com.demo',
//     Alias = 'dthom',
//     ProfileId = stdProfile.Id,
//     TimeZoneSidKey = 'America/New_York',
//     LocaleSidKey = 'en_US',
//     EmailEncodingKey = 'UTF-8',
//     LanguageLocaleKey = 'en_US'
// ));

usersToCreate.add(new User(
    FirstName = 'Jennifer',
    LastName = 'Williams',
    Email = 'jennifer.williams@global.com',
    Username = 'jennifer.williams@global.com.demo',
    Alias = 'jwill',
    IsActive = false,
    ProfileId = stdProfile.Id,
    TimeZoneSidKey = 'America/New_York',
    LocaleSidKey = 'en_US',
    EmailEncodingKey = 'UTF-8',
    LanguageLocaleKey = 'en_US'
));


// Only 4 licenses available - additional users commented out

usersToCreate.add(new User(
    FirstName = 'Robert',
    LastName = 'Martinez',
    Email = 'robert.martinez@global.com',
    Username = 'robert.martinez@global.com.demo',
    Alias = 'rmart',
    IsActive = false,
    ProfileId = stdProfile.Id,
    TimeZoneSidKey = 'America/New_York',
    LocaleSidKey = 'en_US',
    EmailEncodingKey = 'UTF-8',
    LanguageLocaleKey = 'en_US'
));

usersToCreate.add(new User(
    FirstName = 'Lisa',
    LastName = 'Anderson',
    Email = 'lisa.anderson@global.com',
    Username = 'lisa.anderson@global.com.demo',
    Alias = 'lander',
    IsActive = false,
    TimeZoneSidKey = 'America/New_York',
    LocaleSidKey = 'en_US',
    ProfileId = stdProfile.Id,
    EmailEncodingKey = 'UTF-8',
    LanguageLocaleKey = 'en_US'
));

usersToCreate.add(new User(
    FirstName = 'James',
    LastName = 'Taylor',
    Email = 'james.taylor@global.com',
    Username = 'james.taylor@global.com.demo',
    Alias = 'jtayl',
    ProfileId = stdProfile.Id,
    IsActive = false,
    TimeZoneSidKey = 'America/New_York',
    LocaleSidKey = 'en_US',
    EmailEncodingKey = 'UTF-8',
    LanguageLocaleKey = 'en_US'
));

usersToCreate.add(new User(
    FirstName = 'Amanda',
    LastName = 'Garcia',
    Email = 'amanda.garcia@global.com',
    Username = 'amanda.garcia@global.com.demo',
    Alias = 'agarc',
    ProfileId = stdProfile.Id,
    TimeZoneSidKey = 'America/New_York',
    IsActive = false,
    LocaleSidKey = 'en_US',
    EmailEncodingKey = 'UTF-8',
    LanguageLocaleKey = 'en_US'
));

usersToCreate.add(new User(
    FirstName = 'Christopher',
    LastName = 'Lee',
    Email = 'christopher.lee@global.com',
    Username = 'christopher.lee@global.com.demo',
    TimeZoneSidKey = 'America/New_York',
    Alias = 'clee',
    ProfileId = stdProfile.Id,
    IsActive = false,
    LocaleSidKey = 'en_US',
    EmailEncodingKey = 'UTF-8',
    LanguageLocaleKey = 'en_US'
));


// Insert users
insert usersToCreate;

System.debug('Successfully created ' + usersToCreate.size() + ' users');
for (User u : usersToCreate) {
    System.debug('Created: ' + u.FirstName + ' ' + u.LastName + ' (ID: ' + u.Id + ')');
}


Id urId = [select Id from UserRole where Name = '(Philadelphia) Sales Operations Specialist'].Id;
System.debug('---> ' + urId);


List<User> uList = new List<User>();

uList.add(new User(Id='005cb00000C2Aa7AAF', UserRoleId = urId));
uList.add(new User(Id='005cb00000C2Aa8AAF', UserRoleId = urId));
uList.add(new User(Id='005cb00000C2Aa9AAF', UserRoleId = urId));
uList.add(new User(Id='005cb00000C2AaAAAV', UserRoleId = urId));
uList.add(new User(Id='005cb00000C2AaBAAV', UserRoleId = urId));
uList.add(new User(Id='005cb00000C2AaCAAV', UserRoleId = urId));
update uList;
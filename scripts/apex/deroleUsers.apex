List<User> uList = [select Id from User where UserRoleId != null];
for(User u : uList){
    u.UserRoleId = null;
}
update uList;



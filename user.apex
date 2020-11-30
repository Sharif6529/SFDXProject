  
User u = [SELECT ID FROM User WHERE Name = 'User User'];
u.UserPermissionsMarketingUser = true;
u.Country = 'United States';
u.TimeZoneSidKey = 'America/New_York';
update u;

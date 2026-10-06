/*      Organization : ABC Bank
*       Created By: 
*       Created Date: 
*       Change History: 
*         			 #CH01# #Jahangeer Mohammed# #03-07-2023# Added Logic to display Users List Based on the tab selected on VF Page 
*/

global without sharing class ManageUserPageController{
    public List<User> lstUser {get;set;}
    //CH01: Start
    public List<User> lstContactCentreUser {get;set;}
    public Set<Id> lstContactCentreUserIds = new Set<Id>();
    
    public List<User> lstRMTUser {get;set;}
    public Set<Id> lstRMTUserIds = new Set<Id>();
    public Integer lstActiveRMTUserSize {get;set;}
    public Boolean ldRMTboolean{get;set;}
    public Integer ActiveRMTUserCount {get;set;}
    
    public List<User> lstOperationsUser {get;set;}
    public Set<Id> lstOperationsUserIds = new Set<Id>();
    public Integer lstActiveOperationsUserSize {get;set;}
    public Boolean ldOperationboolean{get;set;}
    public Integer ActiveOperationsUserCount {get;set;}
    
    public List<User> lstThirdLineSupportUser {get;set;}
    public Set<Id> lstThirdLineSupportUserIds = new Set<Id>();
    public Integer lstActiveThirdLineSupportUserSize {get;set;}
    public Boolean lstThirdLineSupportboolean{get;set;}
    public Integer ActiveThirdLineSupportUserCount {get;set;}
    
    public String selectedTab { get; set; }
    public String fetchingTab {get;set;}
    //CH01: END
    public Integer ActiveUserCount {get;set;}
    public Integer lstUserSize {get;set;}
    public Integer lstActiveUserSize {get;set;}
    public Boolean ldboolean{get;set;}
    public String cmemberId {get;set;}
    public String errorMessage {get;set;}
    
    public Boolean ldbooleanCCUser{get;set;}
    public Boolean ldbooleanRMTUser{get;set;}
    public Boolean ldbooleanOprUser{get;set;}
    public Boolean ldbooleanTLSUser{get;set;}
    //CH01: Start
    public Boolean blnError{get;set;}
    public Boolean blnErrorRMT{get;set;}
    public Boolean blnErrorOPS{get;set;}
    public Boolean blnErrorTLSU{get;set;}
    //CH01: END
    User usObj = new User();
    User currentUser = new User();
    public ManageUserPageController(){
        System.debug('Constructor Invoked on Page Load');
        fetchingTab = System.currentPagereference().getParameters().get('msg');
        blnError = false;
        blnErrorRMT = false;
        blnErrorOPS = false;
        blnErrorTLSU = false;
        errorMessage = '';
        if(fetchingTab != null){
            if(fetchingTab == 'CCenter'){
                selectedTab = 'CCenter';
                System.debug('User Updated Contact Center User Record & Contact Center Tab Will be the Landing Page');
            }
            else if(fetchingTab == 'RISK'){
                 selectedTab = 'RISK';
                 System.debug('User Updated Risk User Record & RMT Tab Will be the Landing Page');
            }
            else if(fetchingTab == 'OPS'){
                selectedTab = 'OPS';
                System.debug('User Updated Ila Service Desk User Record & Operation Tab Will be the Landing Page');
            }
            else if(fetchingTab == 'TLSU'){
                selectedTab = 'TLSU';
                System.debug('User Updated Third Line Support User Record & Third Line Support Tab Will be the Landing Page');
            }
        }
        else if(fetchingTab == null){
            selectedTab = 'CCenter';
            System.debug('On Default Load Contact Center Will be the Landing Page');
        }
        lstUser = [Select id, name, username, isActive,profile.Name,UserRole.Name, Email from User where overflowUser__c = true AND Region_Flag__c = 'Bahrain' ORDER BY isActive DESC];
        //CH01: Start
        if(lstUser.size()>0){
            ///////////////////////////////////////////// Start: Fetching all the Overflow user's Ids /////////////////////////////////////////////
            for(User u : lstUser){
                System.debug('User Profile Name:'+u.profile.Name);
                if(u.profile.Name == 'Contact Centre'){
                    System.debug('User Details in Contact Centre:'+u);
                    lstContactCentreUserIds.add(u.Id);
                }
                if(u.profile.Name == 'ila Risk' || (u.profile.Name == 'ila Fraud' && u.UserRole.Name == 'Risk')){
                    System.debug('User Details in Risk:'+u);
                    lstRMTUserIds.add(u.Id);
                }
                if(u.profile.Name == 'ila Digital Service Desk'){
                    System.debug('User Details in ila Digital Service Desk:'+u);
                    lstOperationsUserIds.add(u.Id);
                }
                if(u.profile.Name == 'Third Line Support'){
                    System.debug('User Details in Third Line Support:'+u);
                    lstThirdLineSupportUserIds.add(u.Id);
                }
            }//For loop Ends
           ///////////////////////////////////////////// END: Fetching all the Overflow user's Ids /////////////////////////////////////////////

        } //If Ends
        
        Map<Id,User> lstSystemAdminUser = new Map<Id,User>([Select Id, name, username from user where isActive = true AND profile.Name = 'System Administrator']);
        Id userId = (Id)UserInfo.getUserId();
        
        currentUser = [Select id,Activate_Deactivate_CRM_user_License__c, profile.Name, isActive from User where id =: userId];
        
        //////////////////////////////////////////////// Start: Fetching Contact Center List ////////////////////////////////////////////////
        if(lstContactCentreUserIds.size()>0){
            lstContactCentreUser = [Select id, name, username, isActive,profile.Name, Email from User where id =: lstContactCentreUserIds];
            ldboolean = true;
            //List<String> currentCCUser = System.Label.MANAGE_LICENSE_ROTATION_CC.split(','); //Checking for Action tab visibility on CC List
            /*if(currentCCUser.contains(userId) || lstSystemAdminUser.containsKey(userId)){
                ldbooleanCCUser = true;
            }*/
            if((currentUser.Activate_Deactivate_CRM_user_License__c == true && currentUser.profile.Name == 'Contact Centre') || lstSystemAdminUser.containsKey(userId)){
                ldbooleanCCUser = true;
            }
            System.debug('CC User or Admin User:'+ldbooleanCCUser);
            lstActiveUserSize = [Select count() from user where overflowUser__c = true and isActive = true AND Region_Flag__c = 'Bahrain' AND profile.Name = 'Contact Centre'];
        }
        //////////////////////////////////////////////// END: Fetching Contact Center List ////////////////////////////////////////////////

       //////////////////////////////////////////////// Start: Fetching Fraud List ///////////////////////////////////////////////////////
		if(lstRMTUserIds.size()>0){
            lstRMTUser = [Select id, name, username, isActive,profile.Name, Email from User where id =: lstRMTUserIds];
            ldRMTboolean = true;
            //List<String> currentRMTUser = System.Label.MANAGE_LICENSE_ROTATION_RMT.split(','); //Checking for Action tab visibility on RMT List
            /*if(currentRMTUser.contains(userId) || lstSystemAdminUser.containsKey(userId)){
                ldbooleanRMTUser = true;
            }*/
            if((currentUser.Activate_Deactivate_CRM_user_License__c == true && currentUser.profile.Name == 'ila Risk') || lstSystemAdminUser.containsKey(userId)){
                ldbooleanRMTUser = true;
            }
            System.debug('Risk User or Admin User:'+ldbooleanRMTUser);
            lstActiveRMTUserSize = [Select count() from user where overflowUser__c = true and isActive = true AND Region_Flag__c = 'Bahrain' AND (profile.Name = 'ila Risk' OR (profile.Name = 'ila Fraud' AND UserRole.Name = 'Risk'))];
        }
       //////////////////////////////////////////////// END: Fetching Fraud List ///////////////////////////////////////////////////////
 
       //////////////////////////////////////////////// Start: Fetching Ila Service Desk List ///////////////////////////////////////////////////////
		if(lstOperationsUserIds.size()>0){
            lstOperationsUser = [Select id, name, username, isActive,profile.Name, Email from User where id =: lstOperationsUserIds];
            ldOperationboolean = true;
            //List<String> currentOPSUser = System.Label.MANAGE_LICENSE_ROTATION_OPS.split(','); //Checking for Action tab visibility on OPS List
			/*if(currentOPSUser.contains(userId) || lstSystemAdminUser.containsKey(userId)){
                ldbooleanOprUser = true;
            }*/
            if((currentUser.Activate_Deactivate_CRM_user_License__c == true && currentUser.profile.Name == 'ila Digital Service Desk') || lstSystemAdminUser.containsKey(userId)){
                ldbooleanOprUser = true;
            }
            System.debug('Operation User or Admin User:'+ldbooleanOprUser);
            lstActiveOperationsUserSize = [Select count() from user where overflowUser__c = true and isActive = true AND Region_Flag__c = 'Bahrain' AND profile.Name = 'ila Digital Service Desk'];
        }
      //////////////////////////////////////////////// END: Fetching Ila Service Desk List ///////////////////////////////////////////////////////
 
      //////////////////////////////////////////////// Start: Fetching Third Line Support List ///////////////////////////////////////////////////////
		if(lstThirdLineSupportUserIds.size()>0){
           lstThirdLineSupportUser = [Select id, name, username, isActive,profile.Name, Email from User where id =: lstThirdLineSupportUserIds]; 
           lstThirdLineSupportboolean = true;
           //List<String> currentTLSUser = System.Label.MANAGE_LICENSE_ROTATION_TLS.split(','); //Checking for Action tab visibility on TLS List
           /*if(currentTLSUser.contains(userId) || lstSystemAdminUser.containsKey(userId)){
                ldbooleanTLSUser = true;
            }*/
           if((currentUser.Activate_Deactivate_CRM_user_License__c == true && currentUser.profile.Name == 'Third Line Support') || lstSystemAdminUser.containsKey(userId)){
                ldbooleanTLSUser = true;
            }
           System.debug('TLS User or Admin User:'+ldbooleanTLSUser);
           lstActiveThirdLineSupportUserSize = [Select count() from user where overflowUser__c = true and isActive = true AND Region_Flag__c = 'Bahrain' AND profile.Name = 'Third Line Support'];
        }
      //////////////////////////////////////////////// END: Fetching Third Line Support List ///////////////////////////////////////////////////////
 	//CH01: END
    } //Constructor Closed
    
    global pageReference doSearch()
    {
        PageReference pr;
        Integer usCount=0;
        system.debug('vfParam CC UserId ---->' + cmemberId);
        //CH01: Start
        ActiveUserCount = [Select id from User where isActive = True AND profile.Name = 'Contact Centre' AND overflowUser__c = true AND Region_Flag__c = 'Bahrain'].size();
        //CH01: END
        system.debug('ActiveUserCount ---->' + ActiveUserCount);
        //CH01: Start
        usObj = [Select id,Activate_Deactivate_CRM_user_License__c, profile.Name, isActive from User where id =: cmemberId];
        Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
		String currentUserProfileName = p.name;
        //CH01: END
        if(usObj !=null)
        {
            //CH01: Start
            if((currentUserProfileName == usObj.profile.Name && usObj.Activate_Deactivate_CRM_user_License__c == true) || currentUserProfileName == 'System Administrator'){
                if(usObj.isActive == true)
                {
                    usObj.isActive = false;
                    update usObj;
                    
                    pr = new PageReference('/apex/ManageUserPage');
                    pr.getParameters().put('msg',selectedTab);
                    pr.setRedirect(true);
                }
                else if(usObj.isActive == false)
                {
                    system.debug('ActiveUserCount11 ---->' + ActiveUserCount);
                    system.debug('ActiveUserCount 22---->' + Integer.valueOf(system.label.CCActiveUser));
                    usCount = Integer.valueOf(system.label.CCActiveUser) + 1;
                    if(ActiveUserCount > Integer.valueOf(system.label.CCActiveUser))
                    {
                        blnError = true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,' License limit has been exceeded. Allowed limit is '+usCount+' Active users.'));
                    }
                    else{
                        usObj.isActive = true;
                        update usObj;
                        
                        pr = new PageReference('/apex/ManageUserPage');
                        pr.getParameters().put('msg',selectedTab);
                        pr.setRedirect(true);
                    }
                }
                
            }
            else{
                blnError = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,' You dont have an access to activate or deactivate this user.'));
 			}
            //CH01: END
        }
        return pr;
        
    }
    //CH01: Start
    global pageReference doSearchRMT()
    {
        PageReference pr;
        Integer usCount=0;
        system.debug('vfParam RMT UserId ---->' + cmemberId);
        
        ActiveRMTUserCount = [Select id from User where isActive = True AND (profile.Name = 'ila Risk' OR (profile.Name = 'ila Fraud ' AND UserRole.Name = 'Risk'))  AND overflowUser__c = true AND Region_Flag__c = 'Bahrain'].size();
        system.debug('RISKActiveUserCount ---->' + ActiveRMTUserCount);
        usObj = [Select id,Activate_Deactivate_CRM_user_License__c, isActive,profile.name from User where id =: cmemberId];
        Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
		String currentUserProfileName = p.name;
        if(usObj !=null)
        {
            if((currentUserProfileName == usObj.profile.Name && usObj.Activate_Deactivate_CRM_user_License__c == true) || currentUserProfileName == 'System Administrator'){
                if(usObj.isActive == true )
                {
                    usObj.isActive = false;
                    update usObj;
                    pr = new PageReference('/apex/ManageUserPage');
                    pr.getParameters().put('msg',selectedTab);
                    pr.setRedirect(true);
                }
                else if(usObj.isActive == false)
                {
                    system.debug('RMTActiveUserCount11 ---->' + ActiveRMTUserCount);
                    system.debug('RMTActiveUserCount 22---->' + Integer.valueOf(system.label.RMTActiveUser_BH));
                    usCount = Integer.valueOf(system.label.RMTActiveUser_BH) + 1;
                    if(ActiveRMTUserCount > Integer.valueOf(system.label.RMTActiveUser_BH))
                    {
                        blnErrorRMT = true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,' License limit has been exceeded. Allowed limit is '+usCount+' Active users.'));
                    }
                    else{
                        usObj.isActive = true;
                        update usObj;
                        pr = new PageReference('/apex/ManageUserPage');
                        pr.getParameters().put('msg',selectedTab);
                        pr.setRedirect(true);
                    }
                }
            }
            else{
                blnErrorRMT = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,' You dont have an access to activate or deactivate this user.'));
 			}
            
        }
        return pr;
   }
    
    global pageReference doSearchOps()
    {
        PageReference pr;
        Integer usCount=0;
        system.debug('vfParam Ops UserId ---->' + cmemberId);
        
        ActiveOperationsUserCount = [Select id from User where isActive = True AND profile.Name = 'ila Digital Service Desk' AND overflowUser__c = true AND Region_Flag__c = 'Bahrain'].size();
        system.debug('IlaServiceUserCount ---->' + ActiveOperationsUserCount);
        usObj = [Select id,Activate_Deactivate_CRM_user_License__c, isActive,profile.name from User where id =: cmemberId];
        Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
		String currentUserProfileName = p.name;
        if(usObj !=null)
        {
            if((currentUserProfileName == usObj.profile.Name && usObj.Activate_Deactivate_CRM_user_License__c == true) || currentUserProfileName == 'System Administrator'){
                if(usObj.isActive == true )
                {
                    usObj.isActive = false;
                    update usObj;
                    pr = new PageReference('/apex/ManageUserPage');
                    pr.getParameters().put('msg',selectedTab);
                    pr.setRedirect(true);
                }
                else if(usObj.isActive == false)
                {
                    system.debug('IlaServiceActiveUserCount11 ---->' + ActiveOperationsUserCount);
                    system.debug('IlaServiceActiveUserCount 22---->' + Integer.valueOf(system.label.OPSActiveUser_BH));
                    usCount = Integer.valueOf(system.label.OPSActiveUser_BH) + 1;
                    if(ActiveOperationsUserCount > Integer.valueOf(system.label.OPSActiveUser_BH))
                    {
                        blnErrorOPS = true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,' License limit has been exceeded. Allowed limit is '+usCount+' Active users.'));
                    }
                    else{
                        usObj.isActive = true;
                        update usObj;
                        pr = new PageReference('/apex/ManageUserPage');
                        pr.getParameters().put('msg',selectedTab);
                        pr.setRedirect(true);
                    }
                }
            }
            else{
                blnErrorOPS = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,' You dont have an access to activate or deactivate this user.'));
 			}
            
        }
        return pr;
   }
   
    global pageReference doSearchSupportUsers()
    {
        PageReference pr;
        Integer usCount=0;
        system.debug('vfParam Ops UserId ---->' + cmemberId);
        
        ActiveThirdLineSupportUserCount = [Select id from User where isActive = True AND profile.Name = 'Third Line Support' AND overflowUser__c = true AND Region_Flag__c = 'Bahrain'].size();
        system.debug('ThirdLineActiveUserCount ---->' + ActiveThirdLineSupportUserCount);
        usObj = [Select id,Activate_Deactivate_CRM_user_License__c, isActive,profile.name from User where id =: cmemberId];
        Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
		String currentUserProfileName = p.name;
        if(usObj !=null)
        {
            if((currentUserProfileName == usObj.profile.Name && usObj.Activate_Deactivate_CRM_user_License__c == true) || currentUserProfileName == 'System Administrator'){
                if(usObj.isActive == true )
                {
                    usObj.isActive = false;
                    update usObj;
                    pr = new PageReference('/apex/ManageUserPage');
                    pr.getParameters().put('msg',selectedTab);
                    pr.setRedirect(true);
                }
                else if(usObj.isActive == false)
                {
                    system.debug('TLSUActiveUserCount11 ---->' + ActiveThirdLineSupportUserCount);
                    system.debug('TLSUActiveUserCount 22---->' + Integer.valueOf(system.label.TLSUActiveUser_BH));
                    usCount = Integer.valueOf(system.label.TLSUActiveUser_BH) + 1;
                    if(ActiveThirdLineSupportUserCount > Integer.valueOf(system.label.TLSUActiveUser_BH))
                    {
                        blnErrorTLSU = true;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,' License limit has been exceeded. Allowed limit is '+usCount+' Active users.'));
                    }
                    else{
                        usObj.isActive = true;
                        update usObj;
                        pr = new PageReference('/apex/ManageUserPage');
                        pr.getParameters().put('msg',selectedTab);
                        pr.setRedirect(true);
                    }
                }
            }
            else{
                blnErrorTLSU = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,' You dont have an access to activate or deactivate this user.'));
 			}
            
        }
        return pr;
   }
    //CH01: END
}
/*      Organization : ABC Bank
*       Created By: 
*       Created Date: 
*       Change History: 
*         			 #CH01# #Jahangeer Mohammed# #03-07-2023# Added Logic to display Users List Based on the tab selected on VF Page 
*/

global without sharing class ManageUserPageController_JO{
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
    
    public List<User> lstTMUSupportUser {get;set;}
    public Set<Id> lstTMUSupportUserIds = new Set<Id>();
    public Integer lstActiveTMUSupportUserSize {get;set;}
    public Boolean lstTMUSupportboolean{get;set;}
    public Integer ActiveTMUSupportUserCount {get;set;}
    
    public String selectedTab { get; set; }
    public String fetchingTab {get;set;}
    //CH01: END
    public Integer ActiveUserCount {get;set;}
    public Integer lstUserSize {get;set;}
    public Integer lstActiveUserSize {get;set;}
    public Boolean ldboolean{get;set;}
    public String cmemberId {get;set;}
    public String errorMessage {get;set;}
    //CH01: Start
    public Boolean blnError{get;set;}
    public Boolean blnErrorRMT{get;set;}
    public Boolean blnErrorOPS{get;set;}
    public Boolean blnErrorTLSU{get;set;}
    public Boolean blnErrorTMU{get;set;}
    
    public Boolean enableCCTab{get;set;}
    public Boolean enableRMTTab{get;set;}
    public Boolean enableOPSTab{get;set;}
    public Boolean enableTLSTab{get;set;}
    public Boolean enableTMUTab{get;set;}
    //CH01: END
    User usObj = new User();
    
    public ManageUserPageController_JO(){
        System.debug('Constructor Invoked on Page Load');
        fetchingTab = System.currentPagereference().getParameters().get('msg');
        blnError = false;
        blnErrorRMT = false;
        blnErrorOPS = false;
        blnErrorTLSU = false;
        blnErrorTMU = false;
        errorMessage = '';
        if(fetchingTab != null){
            if(fetchingTab == 'CCenter'){
                selectedTab = 'CCenter';
                System.debug('User Updated Contact Center User Record & Contact Center Tab Will be the Landing Page');
            }
            else if(fetchingTab == 'RMT'){
                 selectedTab = 'RMT';
                 System.debug('User Updated RMT User Record & RMT Tab Will be the Landing Page');
            }
            else if(fetchingTab == 'OPS'){
                selectedTab = 'OPS';
                System.debug('User Updated Operations User Record & Operation Tab Will be the Landing Page');
            }
            else if(fetchingTab == 'TLSU'){
                selectedTab = 'TLSU';
                System.debug('User Updated Third Line Support User Record & Third Line Support Tab Will be the Landing Page');
            }
            else if(fetchingTab == 'TMU'){
                 selectedTab = 'TMU';
                 System.debug('User Updated TMU User Record & TMU Tab Will be the Landing Page');
            }
        }
        else if(fetchingTab == null){
            selectedTab = 'CCenter';
            System.debug('On Default Load Contact Center Will be the Landing Page');
        }
        lstUser = [Select id, name, username, isActive,profile.Name, Email from User where overflowUser__c = true AND Region_Flag__c = 'Jordan' ORDER BY isActive DESC];
        //CH01: Start
        if(lstUser.size()>0){
            for(User u : lstUser){
                System.debug('User Profile Name:'+u.profile.Name);
                if(u.profile.Name == 'Contact Centre'){
                    System.debug('User Details in Contact Centre:'+u);
                    lstContactCentreUserIds.add(u.Id);
                }
                if(u.profile.Name == 'RMT'){
                    System.debug('User Details in RMT:'+u);
                    lstRMTUserIds.add(u.Id);
                }
                if(u.profile.Name == 'Operations'){
                    System.debug('User Details in Operations:'+u);
                    lstOperationsUserIds.add(u.Id);
                }
                if(u.profile.Name == 'Third Line Support'){
                    System.debug('User Details in Third Line Support:'+u);
                    lstThirdLineSupportUserIds.add(u.Id);
                }
                if(u.profile.Name == 'TMU'){
                    System.debug('User Details in TMU Support:'+u);
                    lstTMUSupportUserIds.add(u.Id);
                }
            }
        }
        LicenseRotation__c licRotSetting = LicenseRotation__c.getInstance();
        enableCCTab = licRotSetting.View_Contact_Center_Overflow_Users__c;
        enableRMTTab = licRotSetting.View_RMT_Overflow_Users__c;
        enableOPSTab = licRotSetting.View_Operations_Overflow_Users__c;
        enableTLSTab = licRotSetting.View_Third_Line_Support_Overflow_Users__c;
        enableTMUTab = licRotSetting.View_TMU_Support_Overflow_Users__c;
        
        if(lstContactCentreUserIds.size()>0){
            lstContactCentreUser = [Select id, name, username, isActive,profile.Name, Email from User where id =: lstContactCentreUserIds];
            ldboolean = true;
            lstActiveUserSize = [Select count() from user where overflowUser__c = true and isActive = true AND Region_Flag__c = 'Jordan' AND profile.Name = 'Contact Centre'];
        }
        if(lstRMTUserIds.size()>0){
            lstRMTUser = [Select id, name, username, isActive,profile.Name, Email from User where id =: lstRMTUserIds];
            ldRMTboolean = true;
            lstActiveRMTUserSize = [Select count() from user where overflowUser__c = true and isActive = true AND Region_Flag__c = 'Jordan' AND profile.Name = 'RMT'];
        }
        if(lstOperationsUserIds.size()>0){
            lstOperationsUser = [Select id, name, username, isActive,profile.Name, Email from User where id =: lstOperationsUserIds];
            ldOperationboolean = true;
            lstActiveOperationsUserSize = [Select count() from user where overflowUser__c = true and isActive = true AND Region_Flag__c = 'Jordan' AND profile.Name = 'Operations'];
        }
        if(lstThirdLineSupportUserIds.size()>0){
           lstThirdLineSupportUser = [Select id, name, username, isActive,profile.Name, Email from User where id =: lstThirdLineSupportUserIds]; 
           lstThirdLineSupportboolean = true;
           lstActiveThirdLineSupportUserSize = [Select count() from user where overflowUser__c = true and isActive = true AND Region_Flag__c = 'Jordan' AND profile.Name = 'Third Line Support'];
        }
        if(lstTMUSupportUserIds.size()>0){
           lstTMUSupportUser = [Select id, name, username, isActive,profile.Name, Email from User where id =: lstTMUSupportUserIds];
           lstTMUSupportboolean = true;
           lstActiveTMUSupportUserSize = [Select count() from user where overflowUser__c = true and isActive = true AND Region_Flag__c = 'Jordan' AND profile.Name = 'TMU'];
        }
        //CH01: END
    }
    
    global pageReference doSearch()
    {
        PageReference pr;
        Integer usCount=0;
        system.debug('vfParam CC UserId ---->' + cmemberId);
        //CH01: Start
        ActiveUserCount = [Select id from User where isActive = True AND profile.Name = 'Contact Centre' AND overflowUser__c = true AND Region_Flag__c = 'Jordan'].size();
        //CH01: END
        system.debug('ActiveUserCount ---->' + ActiveUserCount);
        //CH01: Start
        usObj = [Select id, profile.Name, isActive from User where id =: cmemberId];
        //Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
       // String currentUserProfileName = p.name;
        //CH01: END
        if(usObj !=null)
        {
            //CH01: Start
            
            if(usObj.isActive == true)
            {
                usObj.isActive = false;
                update usObj;
                
                //pr = new PageReference('/apex/ManageUserPage_JO?isdtp=p1&amp;sfdcIFrameOrigin=https://neobank--dev.lightning.force.com&amp;clc=1');
                pr = new PageReference('/apex/ManageUserPage_JO');
                pr.getParameters().put('msg',selectedTab);
                pr.setRedirect(true);
            }
            else if(usObj.isActive == false)
            {
                system.debug('ActiveUserCount11 ---->' + ActiveUserCount);
                system.debug('ActiveUserCount 22---->' + Integer.valueOf(system.label.CCActiveUser_JO));
                usCount = Integer.valueOf(system.label.CCActiveUser_JO) + 1;
                if(ActiveUserCount > Integer.valueOf(system.label.CCActiveUser_JO))
                {
                    blnError = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,' License limit has been exceeded. Allowed limit is '+usCount+' Active users.'));
                }
                else{
                    usObj.isActive = true;
                    update usObj;
                    
                    //pr = new PageReference('/apex/ManageUserPage_JO?isdtp=p1&amp;sfdcIFrameOrigin=https://neobank--dev.lightning.force.com&amp;clc=1');
                    pr = new PageReference('/apex/ManageUserPage_JO');
                    pr.getParameters().put('msg',selectedTab);
                    pr.setRedirect(true);
                }
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
        
        ActiveRMTUserCount = [Select id from User where isActive = True AND profile.Name = 'RMT' AND overflowUser__c = true AND Region_Flag__c = 'Jordan'].size();
        system.debug('RMTActiveUserCount ---->' + ActiveRMTUserCount);
        usObj = [Select id, isActive,profile.name from User where id =: cmemberId];
        //Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
        //String currentUserProfileName = p.name;
        if(usObj !=null)
        {
            
            if(usObj.isActive == true )
            {
                usObj.isActive = false;
                update usObj;
                //pr = new PageReference('/apex/ManageUserPage_JO?isdtp=p1&amp;sfdcIFrameOrigin=https://neobank--dev.lightning.force.com&amp;clc=1');
                pr = new PageReference('/apex/ManageUserPage_JO');
                pr.getParameters().put('msg',selectedTab);
                pr.setRedirect(true);
            }
            else if(usObj.isActive == false)
            {
                system.debug('RMTActiveUserCount11 ---->' + ActiveRMTUserCount);
                system.debug('RMTActiveUserCount 22---->' + Integer.valueOf(system.label.RMTActiveUser_JO));
                usCount = Integer.valueOf(system.label.RMTActiveUser_JO) + 1;
                if(ActiveRMTUserCount > Integer.valueOf(system.label.RMTActiveUser_JO))
                {
                    blnErrorRMT = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,' License limit has been exceeded. Allowed limit is '+usCount+' Active users.'));
                }
                else{
                    usObj.isActive = true;
                    update usObj;
                    //pr = new PageReference('/apex/ManageUserPage_JO?isdtp=p1&amp;sfdcIFrameOrigin=https://neobank--dev.lightning.force.com&amp;clc=1');
                    pr = new PageReference('/apex/ManageUserPage_JO');
                    pr.getParameters().put('msg',selectedTab);
                    pr.setRedirect(true);
                }
            }
            
            
        }
        return pr;
    }
    
    global pageReference doSearchOps()
    {
        PageReference pr;
        Integer usCount=0;
        system.debug('vfParam Ops UserId ---->' + cmemberId);
        
        ActiveOperationsUserCount = [Select id from User where isActive = True AND profile.Name = 'Operations' AND overflowUser__c = true AND Region_Flag__c = 'Jordan'].size();
        system.debug('OpsActiveUserCount ---->' + ActiveOperationsUserCount);
        usObj = [Select id, isActive,profile.name from User where id =: cmemberId];
       // Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
        //String currentUserProfileName = p.name;
        if(usObj !=null)
        {
            
            if(usObj.isActive == true )
            {
                usObj.isActive = false;
                update usObj;
                //pr = new PageReference('/apex/ManageUserPage_JO?isdtp=p1&amp;sfdcIFrameOrigin=https://neobank--dev.lightning.force.com&amp;clc=1');
                pr = new PageReference('/apex/ManageUserPage_JO');
                pr.getParameters().put('msg',selectedTab);
                pr.setRedirect(true);
            }
            else if(usObj.isActive == false)
            {
                system.debug('OpsActiveUserCount11 ---->' + ActiveOperationsUserCount);
                system.debug('OpsActiveUserCount 22---->' + Integer.valueOf(system.label.OPSActiveUser_JO));
                usCount = Integer.valueOf(system.label.OPSActiveUser_JO) + 1;
                if(ActiveOperationsUserCount > Integer.valueOf(system.label.OPSActiveUser_JO))
                {
                    blnErrorOPS = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,' License limit has been exceeded. Allowed limit is '+usCount+' Active users.'));
                }
                else{
                    usObj.isActive = true;
                    update usObj;
                    //pr = new PageReference('/apex/ManageUserPage_JO?isdtp=p1&amp;sfdcIFrameOrigin=https://neobank--dev.lightning.force.com&amp;clc=1');
                    pr = new PageReference('/apex/ManageUserPage_JO');
                    pr.getParameters().put('msg',selectedTab);
                    pr.setRedirect(true);
                }
            }
            
            
        }
        return pr;
    }
   
    global pageReference doSearchSupportUsers()
    {
        PageReference pr;
        Integer usCount=0;
        system.debug('vfParam Third Line Support UserId ---->' + cmemberId);
        
        ActiveThirdLineSupportUserCount = [Select id from User where isActive = True AND profile.Name = 'Third Line Support' AND overflowUser__c = true AND Region_Flag__c = 'Jordan'].size();
        system.debug('ThirdLineActiveUserCount ---->' + ActiveThirdLineSupportUserCount);
        usObj = [Select id, isActive,profile.name from User where id =: cmemberId];
       // Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
       // String currentUserProfileName = p.name;
        if(usObj !=null)
        {
            
            if(usObj.isActive == true )
            {
                usObj.isActive = false;
                update usObj;
                //pr = new PageReference('/apex/ManageUserPage_JO?isdtp=p1&amp;sfdcIFrameOrigin=https://neobank--dev.lightning.force.com&amp;clc=1');
                pr = new PageReference('/apex/ManageUserPage_JO');
                pr.getParameters().put('msg',selectedTab);
                pr.setRedirect(true);
            }
            else if(usObj.isActive == false)
            {
                system.debug('TLSUActiveUserCount11 ---->' + ActiveThirdLineSupportUserCount);
                system.debug('TLSUActiveUserCount 22---->' + Integer.valueOf(system.label.TLSUActiveUser_JO));
                usCount = Integer.valueOf(system.label.TLSUActiveUser_JO) + 1;
                if(ActiveThirdLineSupportUserCount > Integer.valueOf(system.label.TLSUActiveUser_JO))
                {
                    blnErrorTLSU = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,' License limit has been exceeded. Allowed limit is '+usCount+' Active users.'));
                }
                else{
                    usObj.isActive = true;
                    update usObj;
                    //pr = new PageReference('/apex/ManageUserPage_JO?isdtp=p1&amp;sfdcIFrameOrigin=https://neobank--dev.lightning.force.com&amp;clc=1');
                    pr = new PageReference('/apex/ManageUserPage_JO');
                    pr.getParameters().put('msg',selectedTab);
                    pr.setRedirect(true);
                }
            }
            
            
        }
        return pr;
    }
    
    global pageReference doSearchTMUSupportUsers()
    {
        PageReference pr;
        Integer usCount=0;
        system.debug('vfParam TMU Support UserId ---->' + cmemberId);
        
        ActiveTMUSupportUserCount = [Select id from User where isActive = True AND profile.Name = 'Third Line Support' AND overflowUser__c = true AND Region_Flag__c = 'Jordan'].size();
        system.debug('TMUActiveUserCount ---->' + ActiveTMUSupportUserCount);
        usObj = [Select id, isActive,profile.name from User where id =: cmemberId];
        //Profile p = [Select Name from Profile where Id =: userinfo.getProfileid()];
        //String currentUserProfileName = p.name;
        if(usObj !=null)
        {
            
            if(usObj.isActive == true )
            {
                usObj.isActive = false;
                update usObj;
                //pr = new PageReference('/apex/ManageUserPage_JO?isdtp=p1&amp;sfdcIFrameOrigin=https://neobank--dev.lightning.force.com&amp;clc=1');
                pr = new PageReference('/apex/ManageUserPage_JO');
                pr.getParameters().put('msg',selectedTab);
                pr.setRedirect(true);
            }
            else if(usObj.isActive == false)
            {
                system.debug('TMUActiveUserCount11 ---->' + ActiveTMUSupportUserCount);
                system.debug('TMUActiveUserCount 22---->' + Integer.valueOf(system.label.TMUActiveUser_JO));
                usCount = Integer.valueOf(system.label.TMUActiveUser_JO) + 1;
                if(ActiveTMUSupportUserCount > Integer.valueOf(system.label.TMUActiveUser_JO))
                {
                    blnErrorTMU = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,' License limit has been exceeded. Allowed limit is '+usCount+' Active users.'));
                }
                else{
                    usObj.isActive = true;
                    update usObj;
                    //pr = new PageReference('/apex/ManageUserPage_JO?isdtp=p1&amp;sfdcIFrameOrigin=https://neobank--dev.lightning.force.com&amp;clc=1');
                    pr = new PageReference('/apex/ManageUserPage_JO');
                    pr.getParameters().put('msg',selectedTab);
                    pr.setRedirect(true);
                }
            }
            
            
        }
        return pr;
    }
    //CH01: END
}
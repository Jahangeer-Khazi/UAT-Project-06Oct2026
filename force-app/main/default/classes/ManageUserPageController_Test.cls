@isTest
private class ManageUserPageController_Test {
    
  private static testMethod void ManageUserPageController() {
        Id profileId = [select id from Profile where name=: 'Contact Centre' Limit 1].id;
        
        User objUs = [select id, overflowuser__c from User where ProfileId =: profileId  AND isActive = true limit 1];
       
        objUs.overflowUser__c = true;
        objUs.Region_Flag__c = 'Bahrain';
        update objUs;
        
        PageReference pageRef = Page.ManageUserPage;
        Test.setCurrentPage(pageRef);
        ManageUserPageController mngUser= new ManageUserPageController();
        mngUser.cmemberId = objUs.id;
        mngUser.doSearch();
    } 
    
    private static testMethod void ManageUserPageControllerUnit1() {
        Id profileId = [select id from Profile where name=: 'Operations' Limit 1].id;
        
        User objUs = [select id, overflowuser__c from User where ProfileId =: profileId  AND isActive = true limit 1];
       
        objUs.overflowUser__c = true;
        objUs.Region_Flag__c = 'Bahrain';
        update objUs;
        
        PageReference pageRef = Page.ManageUserPage;
        Test.setCurrentPage(pageRef);
        ManageUserPageController mngUser= new ManageUserPageController();
        mngUser.cmemberId = objUs.id;
        mngUser.doSearchOps();
    }
    private static testMethod void ManageUserPageControllerUnit2() {
        Id profileId = [select id from Profile where name=: 'RMT' Limit 1].id;
        
        User objUs = [select id, overflowuser__c from User where ProfileId =: profileId  AND isActive = true limit 1];
       
        objUs.overflowUser__c = true;
        objUs.Region_Flag__c = 'Bahrain';
        update objUs;
        
        PageReference pageRef = Page.ManageUserPage;
        Test.setCurrentPage(pageRef);
        ManageUserPageController mngUser= new ManageUserPageController();
        mngUser.cmemberId = objUs.id;
        mngUser.doSearchRMT();
    } 
     private static testMethod void ManageUserPageControllerUnit3() {
        Id profileId = [select id from Profile where name=: 'Third Line Support' Limit 1].id;
        
        User objUs = [select id, overflowuser__c from User where ProfileId =: profileId  AND isActive = true limit 1];
       
        objUs.overflowUser__c = true;
        objUs.Region_Flag__c = 'Bahrain';
        update objUs;
        
        PageReference pageRef = Page.ManageUserPage;
        Test.setCurrentPage(pageRef);
        ManageUserPageController mngUser= new ManageUserPageController();
        mngUser.cmemberId = objUs.id;
        mngUser.doSearchSupportUsers();
    }
    private static testMethod void ManageUserPageController4() {
        Id profileId = [select id from Profile where name=: 'Contact Centre' Limit 1].id;
        
        User objUs = [select id, overflowuser__c from User where ProfileId =: profileId  AND isActive = false limit 1];
       
        objUs.overflowUser__c = true;
        objUs.Region_Flag__c = 'Bahrain';
        update objUs;
        
        PageReference pageRef = Page.ManageUserPage;
        Test.setCurrentPage(pageRef);
        ManageUserPageController mngUser= new ManageUserPageController();
        mngUser.cmemberId = objUs.id;
        mngUser.doSearch();
    } 
    
    private static testMethod void ManageUserPageControllerUnit5() {
        Id profileId = [select id from Profile where name=: 'Operations' Limit 1].id;
        
        User objUs = [select id, overflowuser__c from User where ProfileId =: profileId  AND isActive = false limit 1];
       
        objUs.overflowUser__c = true;
        objUs.Region_Flag__c = 'Bahrain';
        update objUs;
        
        PageReference pageRef = Page.ManageUserPage;
        Test.setCurrentPage(pageRef);
        ManageUserPageController mngUser= new ManageUserPageController();
        mngUser.cmemberId = objUs.id;
        mngUser.doSearchOps();
    }
    
     private static testMethod void ManageUserPageControllerUnit6() {
        Id profileId = [select id from Profile where name=: 'RMT' Limit 1].id;
        
        User objUs = [select id, overflowuser__c from User where ProfileId =: profileId  AND isActive = false limit 1];
       
        objUs.overflowUser__c = true;
        objUs.Region_Flag__c = 'Bahrain';
        update objUs;
        
        PageReference pageRef = Page.ManageUserPage;
        Test.setCurrentPage(pageRef);
        ManageUserPageController mngUser= new ManageUserPageController();
        mngUser.cmemberId = objUs.id;
        mngUser.doSearchRMT();
    }
    
     private static testMethod void ManageUserPageControllerUnit7() {
        Id profileId = [select id from Profile where name=: 'Third Line Support' Limit 1].id;
        
        User objUs = [select id, overflowuser__c from User where ProfileId =: profileId  AND isActive = false limit 1];
       
        objUs.overflowUser__c = true;
        objUs.Region_Flag__c = 'Bahrain';
        update objUs;
        
        PageReference pageRef = Page.ManageUserPage;
        Test.setCurrentPage(pageRef);
        ManageUserPageController mngUser= new ManageUserPageController();
        mngUser.cmemberId = objUs.id;
        mngUser.doSearchSupportUsers();
    }
    
    private static testMethod void ManageUserPageControllerJO() {
        Id profileId = [select id from Profile where name=: 'Contact Centre' Limit 1].id;
        
        User objUs = [select id, overflowuser__c from User where ProfileId =: profileId  AND isActive = true limit 1];
       
        objUs.overflowUser__c = true;
        objUs.Region_Flag__c = 'Jordan';
        update objUs;
        
        PageReference pageRef = Page.ManageUserPage;
        Test.setCurrentPage(pageRef);
        ManageUserPageController_JO mngUser= new ManageUserPageController_JO();
        mngUser.cmemberId = objUs.id;
        mngUser.doSearch();
    }  
}
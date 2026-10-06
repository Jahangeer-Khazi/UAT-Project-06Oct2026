@isTest
private class FantasyLeague_VFPageControllerTest {
    
  private static testMethod void FantasyLeague_VFPageController() {
        //Id profileId = [select id from Profile where name=: 'Contact Centre' Limit 1].id;
        Fantasy_League_Entry__c objFLE = new Fantasy_League_Entry__c();
        objFLE.Email__c = 'testClass01@test.com';
        objFLE.Fantasy_Username__c = 'testClass01';
        objFLE.Full_Name__c = 'Test Class Name';
        objFLE.Mobile_Number__c = '2334430002';
        insert objFLE;
               
        PageReference pageRef = Page.FantasyLeague_VFPage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(objFLE);
        FantasyLeague_VFPageController fanLeague = new FantasyLeague_VFPageController(sc);
        fanLeague.saveRequest();
    }  
}
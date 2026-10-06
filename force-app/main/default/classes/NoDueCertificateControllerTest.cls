@isTest
private class NoDueCertificateControllerTest {
    
  private static testMethod void NoDueCertificateController() {
        Id profileId = [select id from Profile where name=: 'Contact Centre' Limit 1].id;
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2class@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5460046';
        acc.ID_Number__pc = '1000023234';
        acc.PersonMailingStreet = 'Avenue Road';
        acc.PersonMailingCity = 'Manama';
        acc.PersonMailingState = 'Manama';
        acc.PersonMailingPostalCode ='123';
        acc.PersonMailingCountry = 'BH';
        acc.Gender__pc = 'M';
        insert acc;
        
        //Account acc1=[select id ,name,ID_Number__pc,PersonMailingStreet,PersonMailingCity,PersonMailingState,PersonMailingPostalCode,PersonMailingCountry,Address__c,Gender__pc from Account where id=:acc.id ];
        
        PageReference pageRef = Page.NoDueCertificate;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(acc);
        ApexPages.currentPage().getParameters().put('accId',acc.id);
        NoDueCertificateController mngUser= new NoDueCertificateController();
    }  
}
/**
 * @description       : 
 * @author            : AITOGRAM Omar
 * @group             : 
 * @last modified on  : 05-05-2024
 * @last modified by  : AITOGRAM Omar
**/
@isTest
private class LoanCollectionLettersControllerTest {
    
    @isTest
    static void testGetCollectionLetterCaseRecordType() {
        Id recordTypeId = LoanCollectionLettersController.getCollectionLetterCaseRecordType();
        System.assertNotEquals(null, recordTypeId);
    }
    
 
    
       @isTest
    static void testSendEmailWithPdf() {
 
       Account acc = (Account)TestDataFactory.createSObject(new Account());
 
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@gmail.com',
            AccountId = acc.Id
        );
        insert con;

        Case cs = new Case(
            Subject = 'Test Case',
            AccountId = acc.Id,
            Origin = 'Email',
            ContactId = con.Id,
            Letter_Type__c = 'Outstanding Balance'
        );
        insert cs;
 
        Test.startTest();
        String result = LoanCollectionLettersController.sendEmailWithPdf(cs.Id);
        Test.stopTest();

   
        System.assertEquals('Success', result);

 
    }

    @isTest
    static void testDownloadcasePdf() {
        Account acc = (Account)TestDataFactory.createSObject(new Account());

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@example.com',
            AccountId = acc.Id
        );
        insert con;

        Case cs = new Case(
            Subject = 'Test Case',
            AccountId = acc.Id,
            Origin = 'Email',
            ContactId = con.Id,
            Letter_Type__c = 'Outstanding Balance'
        );
        insert cs;
        Test.setMock(HttpCalloutMock.class, new PageReferenceMock());

        Test.startTest();
        String result = LoanCollectionLettersController.downloadcasePdf(cs.Id);
        Test.stopTest();

        

     
    }

   private class PageReferenceMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('Fake PDF Content');
            res.setStatusCode(200);
            return res;
        }
    }
  
}
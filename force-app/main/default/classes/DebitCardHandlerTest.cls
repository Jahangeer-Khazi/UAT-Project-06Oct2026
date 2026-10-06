@isTest
public class DebitCardHandlerTest {
    private class MyCalloutMock implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 200;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');    
            res.setHeader('Content-Type', 'application/json');
            //res.setBody
            res.setStatusCode(testStatusCode);
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
    }
     private class MyCalloutMock2 implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 400;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('NOT OK');    
            res.setHeader('Content-Type', 'application/json');
            //res.setBody
            res.setStatusCode(testStatusCode);
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
    }
     private class RestMock2 implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"meta":{"code":"TRAN-1002","message":"The created hold on transaction has been released."},"data":{"holdReference":"2018120717540001"}}');
            res.setStatusCode(200);
            return res;
        }
    }
    public static String bodyString(Case objCase){
        String body;
        if(objCase.cc_Maker__c == 'Release Hold' && objCase.Type == 'Release Hold Amount' && (objCase.Sub_Type__c == 'Release International Transfer' || objCase.Sub_Type__c == 'Release Fawri Transfer')){
            body = '{"holdReference": "'+objCase.RHA_HoldTransactionsReferenceNo__c + 
                       '","accountId":"'+objCase.ac_Iban__c +'"}';
        }  
        return body;
    }
    @isTest
    static void unitTest1(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Hold').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'Debit Card Hold';
        cs1.Description = 'Debit Card Hold Test';
        cs1.Type = 'Release Hold Amount';
        cs1.Sub_Type__c = 'Release International Transfer';
        cs1.RHA_HoldTransactionsReferenceNo__c = '4353556ADFSR';
        cs1.ac_Iban__c = 'BH0010001456252';
        cs1.RHA_AccountType__c = 'CUSTOMER_ACCOUNT';
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.Case_Nature__c = 'RC';
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Maker__c = 'Release Hold';
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
        
    }
    @isTest
    static void unitTest2(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Hold').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'Debit Card Hold';
        cs1.Description = 'Debit Card Hold Test';
        cs1.Type = 'Release Hold Amount';
        cs1.Sub_Type__c = 'Release Debit Card Transaction';
        cs1.RHA_HoldTransactionsReferenceNo__c = '4353556ADFSR';
        cs1.ac_Iban__c = 'BH0010001456252';
        cs1.RHA_AccountType__c = 'CUSTOMER_ACCOUNT';
        cs1.Case_Nature__c = 'RC';
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
       
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Checker_Result__c = 'Release Hold';
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
        
    }
     @isTest
    static void unitTest3(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Hold').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'Debit Card Hold';
        cs1.Description = 'Debit Card Hold Test';
        cs1.Type = 'Release Hold Amount';
        cs1.Sub_Type__c = 'Release Debit Card Transaction';
        cs1.RHA_HoldTransactionsReferenceNo__c = '4353556ADFSR';
        cs1.ac_Iban__c = 'BH0010001456252';
        cs1.RHA_AccountType__c = 'CUSTOMER_ACCOUNT';
        cs1.Case_Nature__c = 'RC';
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
       
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock2());
        cs1.cc_Checker_Result__c = 'Release Hold';
        cs1.Email_Status__c = 'Email Sent';
        update cs1;
        final MyCalloutMock2 mock3 = new MyCalloutMock2();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
        
    }
     @isTest
    static void unitTest4(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Hold').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'Debit Card Hold';
        cs1.Description = 'Debit Card Hold Test';
        cs1.Type = 'Release Hold Amount';
        cs1.Sub_Type__c = 'Release Debit Card Transaction';
        cs1.RHA_HoldTransactionsReferenceNo__c = '4353556ADFSR';
        cs1.ac_Iban__c = 'BH0010001456252';
        cs1.Case_Nature__c = 'RC';
        cs1.RHA_AccountType__c = 'CUSTOMER_ACCOUNT';

        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
       
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock2());
        cs1.cc_Checker_Result__c = 'Release Hold';
        cs1.Email_Status__c = 'Email Received';
        update cs1;
        final MyCalloutMock2 mock3 = new MyCalloutMock2();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
        
    }
    
    

}
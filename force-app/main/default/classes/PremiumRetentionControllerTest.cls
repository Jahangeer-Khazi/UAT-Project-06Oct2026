/*      Organization : ABC Bank
*       Created By: Swapna
*       Created Date: 
*       Change History: 
                    #CH01# #Jahangeer Mohammed# #19-07-2022# Added test class methods to increase the code coverage.
                    #CH02 Amina BENABDELKRIM  add add new field (case model) with default value 'ila'
*                 
*/
@isTest
public class PremiumRetentionControllerTest
{
    private static ApiConnection con = new ApiConnection();
    
    private class MyCalloutMock implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 200;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');    
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(testStatusCode);
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
    }
    
     private class MyCalloutMock1 implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 401;
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
    
    private class RestMock implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    private class RestMock1 implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(401);
            return res;
        }
    }
    private class RestMock2 implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"meta": {"code": "","message": "Get Discount Details Response."},"data": {"crmCaseId": "XA7867VI98329"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void PremiumRetentionControllerTest2() {
        Set<Id> setIdAcc = new Set<Id>();
     Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.Nationality__pc = 'BH';
            acc.CIF__pc = '5464546';
            acc.Segment__pc='Staff';
            insert acc;
            
            
            Account acc1 = new Account();
            acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc1.FirstName = 'Test3';
            acc1.LastName = 'Class3';
            acc1.PersonEmail = 'test3@ilatest.com';
            acc1.Nationality__pc = 'BA';
            acc1.CIF__pc = '5464547';
            acc1.Segment__pc='Staff';
            insert acc1;
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Premium Retention').getRecordTypeId();

            Account acc2 = new Account();
            acc2.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc2.FirstName = 'Test4';
            acc2.LastName = 'Class4';
            acc2.PersonEmail = 'test4@ilatest.com';
            acc2.Nationality__pc = 'BH';
            acc2.CIF__pc = '5464548';
            acc2.Segment__pc='Staff';
            insert acc2;
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Credit Card Application';
            cs1.cc_Name_on_the_Card__c = 'ABC';
            cs1.cc_Embossing_Line_4__c = 'XYZ';
            cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
            cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
            cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
            cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
            cs1.cc_Balance_Transfer_Amount__c = 1000;
            cs1.Priority = 'High';
            cs1.Awaiting_Customer_Feedback__c = false;
            cs1.Origin = 'Phone';
            cs1.AccountId = acc.Id;
            cs1.cc_Monthly_Income__c =6000;
            cs1.cc_PCI_Id__c = '8';
            cs1.cc_Passport_Number__c = 'RT546FRGF';
            cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
            cs1.cc_Residence_Permit_No__c = '546';
            cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
            cs1.cc_Credit_Pre_Screening_Result__c = 'Discrepancy in Documents';
            cs1.Case_Model__c = 'ila';//CH02
             
            insert cs1;
        test.startTest();
        PremiumRetentionController.getCustomerName(acc1.Id);
        PremiumRetentionController.getCollectionLetterCaseQueue();
        PremiumRetentionController.getPremiumRecordType();
            PremiumRetentionController.createDiscountRequest(cs1.Id, cs1.Sub_Status__c);
        
        
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"email": "'+cs1.Account.PersonEmail + 
                          '", "phone": "'+cs1.Account.Mobile_Country_Code__pc+cs1.Account.PersonMobilePhone+'"}';

        test.stopTest();
    }
    
     @isTest
    static void PremiumRetentionControllerTest3() {
        Set<Id> setIdAcc = new Set<Id>();
     Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.Nationality__pc = 'BH';
            acc.CIF__pc = '5464546';
            acc.Segment__pc='Staff';
            insert acc;
            
            
            Account acc1 = new Account();
            acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc1.FirstName = 'Test3';
            acc1.LastName = 'Class3';
            acc1.PersonEmail = 'test3@ilatest.com';
            acc1.Nationality__pc = 'BA';
            acc1.CIF__pc = '5464547';
            acc1.Segment__pc='Staff';
            insert acc1;
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Premium Retention').getRecordTypeId();

            Account acc2 = new Account();
            acc2.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc2.FirstName = 'Test4';
            acc2.LastName = 'Class4';
            acc2.PersonEmail = 'test4@ilatest.com';
            acc2.Nationality__pc = 'BH';
            acc2.CIF__pc = '5464548';
            acc2.Segment__pc='Staff';
            insert acc2;
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Credit Card Application';
            cs1.cc_Name_on_the_Card__c = 'ABC';
            cs1.cc_Embossing_Line_4__c = 'XYZ';
            cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
            cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
            cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
            cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
            cs1.cc_Balance_Transfer_Amount__c = 1000;
            cs1.Priority = 'High';
            cs1.Awaiting_Customer_Feedback__c = false;
            cs1.Origin = 'Phone';
            cs1.Case_Nature__c = 'RC';
            cs1.AccountId = acc.Id;
            cs1.cc_Monthly_Income__c =6000;
            cs1.cc_PCI_Id__c = '8';
            cs1.cc_Passport_Number__c = 'RT546FRGF';
            cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
            cs1.cc_Residence_Permit_No__c = '546';
            cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
            cs1.cc_Credit_Pre_Screening_Result__c = 'Discrepancy in Documents';
            cs1.Sub_Status__c='Pending Customer';
            cs1.Expiry_Days__c=2;
            cs1.Case_Model__c = 'ila';//CH02
        	insert cs1;
       test.startTest();
            PremiumRetentionController.updateDiscountRequest(cs1.Id, cs1.Sub_Status__c, system.Label.RMT_Queue_Id, system.today(), system.today(), system.today(), 'Closed','RETENTION');
            Test.setMock(HttpCalloutMock.class, new RestMock());
        
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"email": "'+cs1.Account.PersonEmail + 
                          '", "phone": "'+cs1.Account.Mobile_Country_Code__pc+cs1.Account.PersonMobilePhone+'"}';

        test.stopTest();
    }
    //CH01: Start
     @isTest
    static void PremiumRetentionControllerTest4() {
        Set<Id> setIdAcc = new Set<Id>();
     Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.Nationality__pc = 'BH';
            acc.CIF__pc = '5464546';
            acc.Segment__pc='Staff';
            insert acc;
            
            
            Account acc1 = new Account();
            acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc1.FirstName = 'Test3';
            acc1.LastName = 'Class3';
            acc1.PersonEmail = 'test3@ilatest.com';
            acc1.Nationality__pc = 'BA';
            acc1.CIF__pc = '5464547';
            acc1.Segment__pc='Staff';
            insert acc1;
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Premium Retention').getRecordTypeId();

            Account acc2 = new Account();
            acc2.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc2.FirstName = 'Test4';
            acc2.LastName = 'Class4';
            acc2.PersonEmail = 'test4@ilatest.com';
            acc2.Nationality__pc = 'BH';
            acc2.CIF__pc = '5464548';
            acc2.Segment__pc='Staff';
            insert acc2;
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Credit Card Application';
            cs1.cc_Name_on_the_Card__c = 'ABC';
            cs1.cc_Embossing_Line_4__c = 'XYZ';
            cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
            cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
            cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
            cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
            cs1.cc_Balance_Transfer_Amount__c = 1000;
            cs1.Priority = 'High';
            cs1.Awaiting_Customer_Feedback__c = false;
            cs1.Origin = 'Phone';
            cs1.Case_Nature__c = 'RC';
            cs1.AccountId = acc.Id;
            cs1.cc_Monthly_Income__c =6000;
            cs1.cc_PCI_Id__c = '8';
            cs1.cc_Passport_Number__c = 'RT546FRGF';
            cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
            cs1.cc_Residence_Permit_No__c = '546';
            cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
            cs1.cc_Credit_Pre_Screening_Result__c = 'Discrepancy in Documents';
            cs1.Sub_Status__c='Pending Customer';
            cs1.Expiry_Days__c=2;
            cs1.Case_Model__c = 'ila';//CH02
        	insert cs1;
       test.startTest();
            PremiumRetentionController.updateDiscountRequest(cs1.Id, cs1.Sub_Status__c, system.Label.RMT_Queue_Id, system.today(), system.today(), system.today(), 'Closed','RETENTION');
            Test.setMock(HttpCalloutMock.class, new RestMock1());
        
        //final MyCalloutMock1 mock = new MyCalloutMock1();
        //mock.testBody = '{"email": "'+cs1.Account.PersonEmail + 
                          //'", "phone": "'+cs1.Account.Mobile_Country_Code__pc+cs1.Account.PersonMobilePhone+'"}';

        test.stopTest();
    }
    
    //CH01: END

}
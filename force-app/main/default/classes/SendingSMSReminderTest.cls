@isTest
public class SendingSMSReminderTest {
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
    public static String bodyString(Case objCase){
         String sms = 'sms';
         String num = '9705912345';
         String body = '{"phoneNumber": "'+num + 
                    '","type": "'+sms +
                    '","subject": "'+null +
                    '","templateCode": "CC_REMIND_DOCS"}';
        return body;
    }
    @isTest
    static void unitTest1(){
        List<Id> csListIds = new List<Id>();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
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
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        insert cs1;
        csListIds.add(cs1.id);
        Test.startTest();
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = bodyString(cs1);
        Test.setMock(HttpCalloutMock.class, mock);
        SendingSMSReminder.sendSMSReminderCreditCard(csListIds);
        Test.stopTest();
    }
    
     @isTest
    static void unitTest2(){
        List<Id> csListIds = new List<Id>();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
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
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        insert cs1;
        csListIds.add(cs1.id);
        Test.startTest();
        final MyCalloutMock1 mock = new MyCalloutMock1();
        mock.testBody = bodyString(cs1);
        Test.setMock(HttpCalloutMock.class, mock);
        SendingSMSReminder.sendSMSReminderCreditCard(csListIds);
        Test.stopTest();
    }
    

}
/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 17/11/2022
*       Change History: 
*/
@isTest
public class walkInCustomerSendingSMSRemindersTest {
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
            String walkinCreation = 'WALKIN_CREATION';
            String tokenCounterNumber = '2';
            String num = '9701232456';
            String body = 
               '{"phoneNumber": "'+num + 
                '","type": "'+sms +
                '","subject": "'+null +
                '","templateCode": "'+walkinCreation +
                '","placeholderReplacements": [ '+
                    ' 	{ '+
                    '	  "fieldName":"tokenCounter", '+
                    '	  "fieldText":"'+tokenCounterNumber+'" '+
                    ' 	} '+
                    ' ] '+
                ' }';
        return body;
    }
     public static String bodyStringOwnerChange(Case objCase){
         String sms = 'sms';
            String walkinUpdate = 'WALKIN_UPDATE';
            String counterNum = '3';
            String ownerName = 'JOHN CENA';
          String num = '9701232456';
           String body = 
               '{"phoneNumber": "'+num + 
                '","type": "'+sms +
                '","subject": "'+null +
                '","templateCode": "'+walkinUpdate +
                '","placeholderReplacements": [ '+
                    ' 	{ '+
                    '	  "fieldName":"counterNumber", '+
                    '	  "fieldText":"'+counterNum+'" '+
                    ' 	}, '+
                	'	{ '+
                    '	  "fieldName":"owner", '+
                    '     "fieldText":"'+ownerName+'" '+
                    '   } '+
                    ' ] '+
                ' }';
        return body;
    }
    
    @isTest
    static void unitTest1(){
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
       Set<Id> setIds = new Set<Id>();
       Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Walkin Customers').getRecordTypeId();
       Case cs1 = new Case();
       cs1.RecordTypeId = recordTypeId;
       cs1.Subject = 'Walkin Customer';
       cs1.Description = 'Walkin Details';
       cs1.Type = 'Walkin Customer';
       cs1.Status = 'New';
       //cs1.Token_Counter__c = 2;
       cs1.AccountId = acc.Id;
       insert cs1;
       cs1.Token_Counter__c = 2;
       update cs1;
        
       setIds.add(cs1.id);
       Test.startTest();
       final MyCalloutMock mock = new MyCalloutMock();
       mock.testBody = bodyString(cs1);
       Test.setMock(HttpCalloutMock.class, mock);
       walkInCustomerSendingSMSReminders.sendSMSRemindersOnCaseCreation(setIds);
       Test.stopTest();

    }
     @isTest
    static void unitTest2(){
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
       Set<Id> setIds = new Set<Id>();
       Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Walkin Customers').getRecordTypeId();
       Case cs1 = new Case();
       cs1.RecordTypeId = recordTypeId;
       cs1.Subject = 'Walkin Customer';
       cs1.Description = 'Walkin Details';
       cs1.Type = 'Walkin Customer';
       cs1.Status = 'New';
       //cs1.Token_Counter__c = 2;
       cs1.AccountId = acc.Id;
       insert cs1;
       cs1.Counter_Number__c = '2';
       cs1.Assign_to_yourself__c = true;
       update cs1;
        
       setIds.add(cs1.id);
       Test.startTest();
       final MyCalloutMock mock = new MyCalloutMock();
       mock.testBody = bodyStringOwnerChange(cs1);
       Test.setMock(HttpCalloutMock.class, mock);
       walkInCustomerSendingSMSReminders.sendSMSRemindersOnChangingOwnership(setIds);
       Test.stopTest();

    }
     @isTest
    static void unitTest3(){
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
       Set<Id> setIds = new Set<Id>();
       Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Walkin Customers').getRecordTypeId();
       Case cs1 = new Case();
       cs1.RecordTypeId = recordTypeId;
       cs1.Subject = 'Walkin Customer';
       cs1.Description = 'Walkin Details';
       cs1.Type = 'Walkin Customer';
       cs1.Status = 'New';
       //cs1.Token_Counter__c = 2;
       cs1.AccountId = acc.Id;
       insert cs1;
       cs1.Counter_Number__c = '2';
       cs1.Assign_to_yourself__c = true;
       update cs1;
        
       setIds.add(cs1.id);
       Test.startTest();
       final MyCalloutMock1 mock = new MyCalloutMock1();
       mock.testBody = bodyStringOwnerChange(cs1);
       Test.setMock(HttpCalloutMock.class, mock);
       walkInCustomerSendingSMSReminders.sendSMSRemindersOnChangingOwnership(setIds);
       Test.stopTest();

    }
    @isTest
    static void unitTest4(){
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.Mobile_Country_Code__pc = '+973';
        acc.PersonMobilePhone = '6754645';
        insert acc;
        
       Set<Id> setIds = new Set<Id>();
       Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Walkin Customers').getRecordTypeId();
       Case cs1 = new Case();
       cs1.RecordTypeId = recordTypeId;
       cs1.Subject = 'Walkin Customer';
       cs1.Description = 'Walkin Details';
       cs1.Type = 'Walkin Customer';
       cs1.Status = 'New';
       //cs1.Token_Counter__c = 2;
       cs1.AccountId = acc.Id;
       insert cs1;
       cs1.Token_Counter__c = 2;
       update cs1;
        
       setIds.add(cs1.id);
       Test.startTest();
       final MyCalloutMock mock = new MyCalloutMock();
       mock.testBody = bodyString(cs1);
       Test.setMock(HttpCalloutMock.class, mock);
       walkInCustomerSendingSMSReminders.sendSMSRemindersOnCaseCreation(setIds);
       Test.stopTest();

    }
     @isTest
    static void unitTest5(){
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.Mobile_Country_Code__pc = '+973';
        acc.PersonMobilePhone = '6754645';
        insert acc;
        
       Set<Id> setIds = new Set<Id>();
       Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Walkin Customers').getRecordTypeId();
       Case cs1 = new Case();
       cs1.RecordTypeId = recordTypeId;
       cs1.Subject = 'Walkin Customer';
       cs1.Description = 'Walkin Details';
       cs1.Type = 'Walkin Customer';
       cs1.Status = 'New';
       //cs1.Token_Counter__c = 2;
       cs1.AccountId = acc.Id;
       insert cs1;
       cs1.Counter_Number__c = '2';
       cs1.Assign_to_yourself__c = true;
       update cs1;
        
       setIds.add(cs1.id);
       Test.startTest();
       final MyCalloutMock mock = new MyCalloutMock();
       mock.testBody = bodyStringOwnerChange(cs1);
       Test.setMock(HttpCalloutMock.class, mock);
       walkInCustomerSendingSMSReminders.sendSMSRemindersOnChangingOwnership(setIds);
       Test.stopTest();

    }
}
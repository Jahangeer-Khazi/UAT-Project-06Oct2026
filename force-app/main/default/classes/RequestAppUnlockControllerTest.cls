@isTest
public class RequestAppUnlockControllerTest {
     private static ApiConnection con = new ApiConnection();
    
     static testMethod void RequestAppUnlockControllerTest() {
    // Create new test lead
    Id creditcollectionRecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        Account accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        Case objCase = (Case)TestDataFactory.createSObject(new Case( sc_Card_Holder_ID_Number__c = '123' , RecordTypeId=creditcollectionRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',
                                                    Type = 'Unblock App Access'),
                                                    'TestFactoryDefaults.CaseDefaults',true);  
        

    
     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
       mock.setStaticResource('HttpStaticfakeResp');
       mock.setStatusCode(200);
       mock.setHeader('Content-Type', 'application/xml');
    
       Test.setMock(HttpCalloutMock.class, new RestMock());
       HTTPResponse res =null;
       Test.StartTest();
    	String csId=[Select Id from Case where RecordTypeId=:creditcollectionRecordTypeId].Id;
		RequestAppUnlockController.loadCardDetails(csId);
	Test.StopTest();    

    }
    private class RestMock implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{ "meta":{  "code":"PROD-1015", "message":"The user has been unblocked successfully" }}';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    static testMethod void RequestAppUnlockControllerTest1() {
     User thisUser = [Select id from User where profile.name ='RMT' and isActive = true limit 1];
    // Create new test lead
   
    Id creditcollectionRecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        Account accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        Case objCase = (Case)TestDataFactory.createSObject(new Case( sc_Card_Holder_ID_Number__c = '123' , RecordTypeId=creditcollectionRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',
                                                    Type = 'Unblock App Access'),
                                                    'TestFactoryDefaults.CaseDefaults',true);  
        

    system.runAs(thisUser){
     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
       mock.setStaticResource('HttpStaticfakeResp');
       mock.setStatusCode(200);
       mock.setHeader('Content-Type', 'application/xml');
    
       Test.setMock(HttpCalloutMock.class, new RestMock1());
       HTTPResponse res =null;
       Test.StartTest();
    	String csId=[Select Id from Case where RecordTypeId=:creditcollectionRecordTypeId].Id;
		RequestAppUnlockController.loadCardDetails(csId);
	Test.StopTest();   
   }

    }
    private class RestMock1 implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{ "meta":{  "code":"PROD-1011", "message":"The user has been unblocked successfully" }}';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    private class RestMock2 implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            //String fullJson = '{ "meta":{  "code":"PROD-1011", "message":"The user has been unblocked successfully" }}';
            String fullJson = 'your Json Response';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(401);
            return res;
        }
    }
     static testMethod void RequestAppUnlockControllerTest2() {
     User thisUser = [Select id from User where profile.name ='RMT' and isActive = true limit 1];
    // Create new test lead
   
    Id creditcollectionRecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        Account accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        Case objCase = (Case)TestDataFactory.createSObject(new Case( sc_Card_Holder_ID_Number__c = '123' , RecordTypeId=creditcollectionRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',
                                                    Type = 'Unblock App Access'),
                                                    'TestFactoryDefaults.CaseDefaults',true);  
        

    system.runAs(thisUser){
     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
       mock.setStaticResource('HttpStaticfakeResp');
       mock.setStatusCode(200);
       mock.setHeader('Content-Type', 'application/xml');
    
       Test.setMock(HttpCalloutMock.class, new RestMock2());
       HTTPResponse res =null;
       Test.StartTest();
    	String csId=[Select Id from Case where RecordTypeId=:creditcollectionRecordTypeId].Id;
		RequestAppUnlockController.loadCardDetails(csId);
	Test.StopTest();   
   }

    }
     static testMethod void RequestAppUnlockControllerTest3() {
    // Create new test lead
    Id creditcollectionRecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        Account accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        Case objCase = (Case)TestDataFactory.createSObject(new Case( sc_Card_Holder_ID_Number__c = '123' , RecordTypeId=creditcollectionRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',
                                                    Type = 'Unblock App Access'),
                                                    'TestFactoryDefaults.CaseDefaults',true);  
        

    
     StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
       mock.setStaticResource('HttpStaticfakeResp');
       mock.setStatusCode(200);
       mock.setHeader('Content-Type', 'application/xml');
    
       Test.setMock(HttpCalloutMock.class, new RestMock());
       HTTPResponse res =null;
       Test.StartTest();
        Set<Id> setCaseId = new Set<Id>();
    	String csId=[Select Id from Case where RecordTypeId=:creditcollectionRecordTypeId].Id;
        setCaseId.add(csId);
		RequestAppUnlockController.resettingRecoveryCodeSMS(setCaseId);
	Test.StopTest();    

    }
   
}
/*      Organization : ABC Bank
 *      Created By: Grok
 *      Created Date: 13/10/2025
 *      Change History: 
 */

@isTest
public class Loans_CaseReopenControllerTest {
    
    @testSetup
    static void setup() {
        Case testCase = createTestCase();
        Case testCase2 = createTestCase2();
        Case testCase3 = createTestCase3();
    }
    
    private static Case createTestCase() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',Subscription_Model__pc = 'alburaq', CustomerStatus__c=null, Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email'), 'TestFactoryDefaults.CaseDefaults',true);
        System.debug('testCase>>'+testCase);
        return testCase;
    }
    

     

    
    private static Case createTestCase2() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123455',Subscription_Model__pc = 'alburaq', CustomerStatus__c=null, Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase2 = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email'), 'TestFactoryDefaults.CaseDefaults',true);
        System.debug('testCase2>>'+testCase2);
        return testCase2;
    }
    
    private static Case createTestCase3() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123444',Subscription_Model__pc = 'alburaq', CustomerStatus__c=null, Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase3 = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email'), 'TestFactoryDefaults.CaseDefaults',true);
        System.debug('testCase2>>'+testCase3);
        return testCase3;
    }
    
    @isTest
    static void testUpdateCaseStatusSuccess() {
        Case testCase = [SELECT Id FROM Case WHERE Case_Model__c = 'alburaq' LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new SuccessHttpMock());
        
        Test.startTest();
        Loans_CaseReopenController.updateCaseStatus(testCase.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCaseStatusFailure() {
        Case testCase = [SELECT Id FROM Case WHERE Case_Model__c = 'alburaq' LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new FailureHttpMock());
        
        Test.startTest();
        Loans_CaseReopenController.updateCaseStatus(testCase.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCaseStatusAlburaqSuccess() {
        Case testCase = [SELECT Id FROM Case WHERE Case_Model__c = 'alburaq' LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new SuccessHttpMock());
        
        Test.startTest();
        Loans_CaseReopenController.updateCaseStatus(testCase.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCaseStatusCalloutException() {
        Case testCase = [SELECT Id FROM Case WHERE Case_Model__c = 'alburaq' LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new ExceptionHttpMock());
        
        Test.startTest();
        Loans_CaseReopenController.updateCaseStatus(testCase.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCaseForErrorHandling() {
        Case testCase = [SELECT Id FROM Case WHERE Case_Model__c = 'alburaq' LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new ExceptionHttpMock());
        
        Test.startTest();
        Loans_CaseReopenController.getCaseForErrorHandling(String.valueof(testCase.Id));
        Test.stopTest();
    }
    
    @isTest
    static void testHandleApiError() {
        Case testCase = [SELECT Id FROM Case WHERE Case_Model__c = 'alburaq' LIMIT 1];
        HttpResponse apiResponse = new HttpResponse();
        
        Test.startTest();
        try {
            Loans_CaseReopenController.handleApiError(apiResponse);
        } Catch(Exception e) {
            System.debug('Error -->'+e);
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testCreateSystemActionForError() {
        Case testCase = [SELECT Id, Customer_CIF__c, AccountId FROM Case WHERE Case_Model__c = 'alburaq' LIMIT 1];
        String caseId = testCase.Id;
        Exception testException = new CalloutException('Test Exception Message');
        Test.setMock(HttpCalloutMock.class, new ExceptionHttpMock());
        Test.startTest();
        Loans_CaseReopenController.createSystemActionForError(caseId,testCase,testException);
        Test.stopTest();
    }
    
    // Mock for successful HTTP response
    private class SuccessHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"success": true}');
            return res;
        }
    }
    
    // Mock for failure HTTP response
    private class FailureHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody('{"error": "Bad Request"}');
            return res;
        }
    }
    
    // Mock for throwing CalloutException
    private class ExceptionHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            throw new CalloutException('Mock Callout Exception');
        }
    }
}
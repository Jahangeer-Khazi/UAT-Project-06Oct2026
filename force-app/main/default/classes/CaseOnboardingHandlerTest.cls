@isTest
public class CaseOnboardingHandlerTest {
    
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
	
    @testSetup static void setupMethode() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('On_Boarding').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',Type='EDD',cc_Checker_Result__c='Wrong Declaration'), 'TestFactoryDefaults.CaseDefaults',true);
        Case caseObj1 = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',Type='EDD',cc_Checker_Result__c='Closed Rejected'), 'TestFactoryDefaults.CaseDefaults',true);
    }
    
    @isTest
    static void testAssignCasesUsingActiveAssignmentRule() {
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        List<Case> caseList = [SELECT Id, RecordType_DeveloperName__c, Region_Flag__c, Closure_Type__c, 
                               Case_Reject_Reason__c, AccountId, cc_Checker_Result__c FROM Case];
        
        Test.startTest();
        CaseOnboardingHandler.handleAfterUpdate(caseList);
        Test.stopTest();
    }
}
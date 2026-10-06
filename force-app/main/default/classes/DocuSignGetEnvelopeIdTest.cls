@isTest
public class DocuSignGetEnvelopeIdTest {
    
    @testSetup
    static void makeData() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',CustomerStatus__c=null,Subscription_Model__pc = 'alburaq',Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq', Type = 'Loan Application',isSubmitted__c = true), 'TestFactoryDefaults.CaseDefaults',true);
        CaseAnnex__c testRecord = new CaseAnnex__c(Case__c = testCase.Id);
        insert testRecord;
        testCase.CaseAnnex__C = testRecord.Id;
        update testCase;
    }
    
    @isTest
    static void testDocuSignGetEnvelopeIdFromFlow() {
        Case testCase = [SELECT Id, Customer_CIF__c FROM Case LIMIT 1];
        
        DocuSignGetEnvelopeId.reqWrapper req = new DocuSignGetEnvelopeId.reqWrapper();
        req.caseId = testCase.Id;
        req.cif = testCase.Customer_CIF__c;
        req.channel = 'Online';
        req.caseModel = 'alburaq';
        req.isNew = 'yes';
        req.objectSource = 'Case';
        req.changedField = 'Status';
        req.isSTP_Process = 'true';
        
        
        List<DocuSignGetEnvelopeId.reqWrapper> reqList = new List<DocuSignGetEnvelopeId.reqWrapper>{req};
        
        Test.setMock(HttpCalloutMock.class, new CombinedCalloutMock());
        
        Test.startTest();
        List<String> result = DocuSignGetEnvelopeId.docuSignGetEnvelopeIdFromFlow(reqList);
        Test.stopTest();
    }
    
    @isTest
    static void testDocuSignGetEnvelopeFuture() {
        Case testCase = [SELECT Id, Customer_CIF__c FROM Case LIMIT 1];
        
        Map<String, String> details = new Map<String, String>{
            'cif' => testCase.Customer_CIF__c,
            'channel' => 'Online',
            'caseModel' => 'alburaq',
            'isNew' => 'yes',
            'objectSource' => 'Case',
            'changedField' => 'Status',
            'isSTP_Process' =>'true'
        };
        
        Test.setMock(HttpCalloutMock.class, new DocuSignCalloutMock());
        
        Test.startTest();
        DocuSignGetEnvelopeId.docuSignGetEnvelopeFuture(testCase.Id, details);
        Test.stopTest();
    }
    
    @isTest
    static void testDocuSignGetEnvelopeFutureException() {
        Case testCase = [SELECT Id, Customer_CIF__c FROM Case LIMIT 1];
        
        Map<String, String> details = new Map<String, String>{
            'cif' => testCase.Customer_CIF__c,
            'channel' => 'Online',
            'caseModel' => 'alburaq',
            'isNew' => 'yes',
            'objectSource' => 'Case',
            'changedField' => 'Status'
        };
        
        Test.setMock(HttpCalloutMock.class, new DocuSignErrorMock());
        
        Test.startTest();
        DocuSignGetEnvelopeId.docuSignGetEnvelopeFuture(testCase.Id, details);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateLoanStatusProcessJob() {
        Account testAcc = [SELECT PersonContactId FROM Account LIMIT 1];
        Case testCase = [SELECT Id, Customer_CIF__c FROM Case LIMIT 1];
        
        Map<String, String> details = new Map<String, String>{
            'cif' => testCase.Customer_CIF__c,
            'channel' => 'Online',
            'caseModel' => 'alburaq',
            'isNew' => 'yes',
            'objectSource' => 'Case',
            'changedField' => 'Status',
            'envelopeId' => 'TESTENVELOPE123',
            'contactId' => testAcc.PersonContactId
        };
        
        Test.setMock(HttpCalloutMock.class, new LoanUpdateCalloutMock());
        
        Test.startTest();
        //System.enqueueJob(new DocuSignGetEnvelopeId.UpdateLoanStatusProcessJob(testCase.Id, details));
        Test.stopTest();
    }
    
    // Mock for DocuSign callout
    private class DocuSignCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"envelopeId":"TESTENVELOPE123","contactId":"003000000000001AAA"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    // Mock for Loan Update API callout
    private class LoanUpdateCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    // Combined mock for flow test
    private class CombinedCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            String body = req.getBody();
            String endpoint = req.getEndpoint();
            
            if (body != null && (body.contains('envelope') || endpoint.containsIgnoreCase('docusign'))) {
                res.setBody('{"envelopeId":"TESTENVELOPE123","contactId":"003000000000001AAA"}');
            } else {
                res.setBody('{"status":"success"}');
            }
            
            return res;
        }
    }
    
    // Mock to simulate error
    private class DocuSignErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error":"Server error"}');
            return res;
        }
    }
}
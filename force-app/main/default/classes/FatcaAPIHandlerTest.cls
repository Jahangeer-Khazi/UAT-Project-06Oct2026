@isTest
public class FatcaAPIHandlerTest {
    
    @testSetup
    static void setup() {
        // Create an Account
        Id customerRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acc = new Account(
            RecordTypeId = customerRT,
            FirstName = 'Test',
            LastName = 'Customer',
            PersonEmail = 'test@example.com',
            CIF__pc = '12345',
            FATCA_Declaration_Form_Type__pc = 'W-9',
            Region_Flag__c = 'Bahrain'
        );
        insert acc;
        
        // Create a Case
        Case c = new Case(
            AccountId = acc.Id,
            Status = 'New',
            Type = 'FATCA Onboarding',
            Region_Flag__c = 'Bahrain'
        );
        insert c;
    }
    
    @isTest
    static void testSendRequestSuccess() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        FatcaAPIHandler.Request req = new FatcaAPIHandler.Request();
        req.caseId = c.Id;
        req.withFatca = true;
        
        Test.setMock(HttpCalloutMock.class, new FatcaMock(200, '{"data": {}, "meta": {"code": "SUCCESS"}}'));
        
        Test.startTest();
        List<String> results = FatcaAPIHandler.sendRequest(new List<FatcaAPIHandler.Request>{req});
        Test.stopTest();
        
        System.assertEquals(1, results.size());
        System.assertEquals(c.Id, (Id)results[0]);
    }

    @isTest
    static void testExecuteCalloutSuccessWithFatcaW9() {
        Case c = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new FatcaMock(200, '{"data": {}, "meta": {"code": "SUCCESS"}}'));
        
        Test.startTest();
        FatcaAPIHandler.executeCalloutFuture(new List<Id>{c.Id}, new Map<Id, Boolean>{c.Id => true});
        Test.stopTest();
        
        Case updatedCase = [SELECT Status FROM Case WHERE Id = :c.Id];
        System.assertEquals('Approved', updatedCase.Status);
        
        Account updatedAcc = [SELECT FATCA_Customer__pc, US_Indicia__pc FROM Account WHERE Id = :c.AccountId];
        System.assertEquals(true, updatedAcc.FATCA_Customer__pc);
        System.assertEquals(false, updatedAcc.US_Indicia__pc);
    }
    
    @isTest
    static void testExecuteCalloutSuccessWithFatcaW8BEN() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        acc.FATCA_Declaration_Form_Type__pc = 'W-8 BEN';
        update acc;
        
        Case c = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new FatcaMock(200, '{"data": {}, "meta": {"code": "SUCCESS"}}'));
        
        Test.startTest();
        FatcaAPIHandler.executeCalloutFuture(new List<Id>{c.Id}, new Map<Id, Boolean>{c.Id => true});
        Test.stopTest();
        
        Case updatedCase = [SELECT Status FROM Case WHERE Id = :c.Id];
        System.assertEquals('Approved', updatedCase.Status);
        
        Account updatedAcc = [SELECT FATCA_Customer__pc FROM Account WHERE Id = :c.AccountId];
        System.assertEquals(false, updatedAcc.FATCA_Customer__pc);
    }

    @isTest
    static void testExecuteCalloutSuccessRejected() {
        Case c = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new FatcaMock(200, '{"data": {}, "meta": {"code": "SUCCESS"}}'));
        
        Test.startTest();
        FatcaAPIHandler.executeCalloutFuture(new List<Id>{c.Id}, new Map<Id, Boolean>{c.Id => false});
        Test.stopTest();
        
        Case updatedCase = [SELECT Status FROM Case WHERE Id = :c.Id];
        System.assertEquals('Rejected', updatedCase.Status);
        
        Account updatedAcc = [SELECT FATCA_Customer__pc FROM Account WHERE Id = :c.AccountId];
        System.assertEquals(false, updatedAcc.FATCA_Customer__pc);
    }

    @isTest
    static void testExecuteCalloutFailure() {
        Case c = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new FatcaMock(400, '{"error": "Bad Request"}'));
        
        Test.startTest();
        FatcaAPIHandler.executeCalloutFuture(new List<Id>{c.Id}, new Map<Id, Boolean>{c.Id => true});
        Test.stopTest();
        
        Case updatedCase = [SELECT cc_Checker_Result__c FROM Case WHERE Id = :c.Id];
    //    System.assertEquals('', updatedCase.cc_Checker_Result__c);
    }
    
    @isTest
    static void testExecuteCalloutFailureRejected() {
        Case c = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new FatcaMock(400, '{"error": "Bad Request"}'));
        
        Test.startTest();
        FatcaAPIHandler.executeCalloutFuture(new List<Id>{c.Id}, new Map<Id, Boolean>{c.Id => false});
        Test.stopTest();
        
        Case updatedCase = [SELECT cc_Maker__c FROM Case WHERE Id = :c.Id];
     //   System.assertEquals('', updatedCase.cc_Maker__c);
    }
   

    private class FatcaMock implements HttpCalloutMock {
        private Integer code;
        private String body;
        
        public FatcaMock(Integer code, String body) {
            this.code = code;
            this.body = body;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(code);
            res.setBody(body);
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
}
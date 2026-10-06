@istest
public class Loan_CrossSellingCcFinalApprovalTest {
    private class GenericHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"meta":{"code":"CCRD-12345","message":"your card application is captured successfully"},"data":{"caseId":"AJ987df344","holdRefrence":"8778679"}}');
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
    @testSetup
    static void setupData() {
        // Create an Account used by Cases
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
       
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        insert acc;
    }
    // Utility to create a Case and return it
    private static Case createTestCase() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Loan Application').getRecordTypeId();
        Case c = new Case(RecordTypeId = recordTypeId,Type = 'New Loan / Finance Application',Sub_Type__c = 'New Loan / Finance Application Request',
            			 AccountId = acc.Id,Region_Flag__c = 'Bahrain',PrimaryCardProductConfigurationId__c = '10',cc_Name_on_the_Card__c = 'Test User',
            			 cc_Requested_Credit_Limit__c = 5000);
        insert c;
        return c;
    }
    // Helper to create CaseAnnex and link to Case (and return created annex)
    private static CaseAnnex__c createAndLinkCaseAnnex(Id caseId) {
        CaseAnnex__c annex = new CaseAnnex__c(Case__c = caseId); // specific result fields will be set by each test separately if needed
        insert annex;

        // Update case to reference the annex (Case.CaseAnnex__c lookup)
        Case cToUpdate = new Case(Id = caseId, CaseAnnex__c = annex.Id);
        update cToUpdate;

        // re-query annex (so it has any relationship fields if needed)
        annex = [SELECT Id, Case__c,cx_ln_Cross_Selling_PreScreening_Result__c,cx_ln_Cross_Selling_Evaluator_Result__c,cx_ln_Cross_Selling_Verifier_Result__c,
                  cx_ln_Cross_Selling_Approver_Result__c FROM CaseAnnex__c WHERE Id = :annex.Id];
        return annex;
    }
      // Generic invocable caller helper
    private static List<String> callInvocableException(String caseId, String changedField) {
        // Build the RequestLoanCrossSelling inner-class instance
        Loan_CrossSellingCcFinalApproval.RequestLoanCrossSelling req = new Loan_CrossSellingCcFinalApproval.RequestLoanCrossSelling();
        req.caseId ='abcjkdjkdkdkdkd';
        req.changedField = changedField;
        List<Loan_CrossSellingCcFinalApproval.RequestLoanCrossSelling> payload = new List<Loan_CrossSellingCcFinalApproval.RequestLoanCrossSelling>{req};

        // call the invocable method (it will queue a future)
        return Loan_CrossSellingCcFinalApproval.updateCrossSellingCCReqApiFromFlow(payload);
    }
    // Generic invocable caller helper
    private static List<String> callInvocable(String caseId, String changedField) {
        // Build the RequestLoanCrossSelling inner-class instance
        Loan_CrossSellingCcFinalApproval.RequestLoanCrossSelling req = new Loan_CrossSellingCcFinalApproval.RequestLoanCrossSelling();
        req.caseId = caseId;
        req.changedField = changedField;
        List<Loan_CrossSellingCcFinalApproval.RequestLoanCrossSelling> payload = new List<Loan_CrossSellingCcFinalApproval.RequestLoanCrossSelling>{ req };

        // call the invocable method (it will queue a future)
        return Loan_CrossSellingCcFinalApproval.updateCrossSellingCCReqApiFromFlow(payload);
    }
    
    @isTest
    static void preScrenningUnitTest() {
        // Arrange
        Case c = createTestCase();
        CaseAnnex__c annex = createAndLinkCaseAnnex(c.Id);

        // Ensure mock is set to capture any callouts
        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());

        Test.startTest();
            List<String> returnIds = callInvocable(String.valueOf(c.Id), 'cx_ln_Cross_Selling_PreScreening_Result__c');
        Test.stopTest();
	}
       @isTest
    static void preScrenningUnitDeclineTest() {
        // Arrange
        Case c = createTestCase();
        CaseAnnex__c annex = createAndLinkCaseAnnex(c.Id);
        annex.cx_ln_Cross_Selling_PreScreening_Result__c='Decline';
        update annex;

        // Ensure mock is set to capture any callouts
        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());

        Test.startTest();
            List<String> returnIds = callInvocable(String.valueOf(c.Id), 'cx_ln_Cross_Selling_PreScreening_Result__c');
        Test.stopTest();
	}
          @isTest
    static void preScrenningUnitCancelledTest() {
        // Arrange
        Case c = createTestCase();
        CaseAnnex__c annex = createAndLinkCaseAnnex(c.Id);
        annex.cx_ln_Cross_Selling_PreScreening_Result__c='Cancelled';
        update annex;

        // Ensure mock is set to capture any callouts
        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());

        Test.startTest();
            List<String> returnIds = callInvocable(String.valueOf(c.Id), 'cx_ln_Cross_Selling_PreScreening_Result__c');
        Test.stopTest();
	}
 
    @isTest
    static void evaluatorUnitTest() {
       
        Case c = createTestCase();
        CaseAnnex__c annex = createAndLinkCaseAnnex(c.Id);

        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());
        Integer beforeCount = [SELECT count() FROM System_Action__c];

        Test.startTest();
            List<String> returnIds = callInvocable(String.valueOf(c.Id), 'cx_ln_Cross_Selling_Evaluator_Result__c');
        Test.stopTest();
	}
      @isTest
    static void evaluatorUnitDeclineTest() {
       
        Case c = createTestCase();
        CaseAnnex__c annex = createAndLinkCaseAnnex(c.Id);
        annex.cx_ln_Cross_Selling_Evaluator_Result__c='Decline';
        update annex;

        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());
        Integer beforeCount = [SELECT count() FROM System_Action__c];

        Test.startTest();
            List<String> returnIds = callInvocable(String.valueOf(c.Id), 'cx_ln_Cross_Selling_Evaluator_Result__c');
        Test.stopTest();
	}
       @isTest
    static void evaluatorUnitCancelledTest() {
       
        Case c = createTestCase();
        CaseAnnex__c annex = createAndLinkCaseAnnex(c.Id);
        annex.cx_ln_Cross_Selling_Evaluator_Result__c='Cancelled';
        update annex;

        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());
        Integer beforeCount = [SELECT count() FROM System_Action__c];

        Test.startTest();
            List<String> returnIds = callInvocable(String.valueOf(c.Id), 'cx_ln_Cross_Selling_Evaluator_Result__c');
        Test.stopTest();
	}
    @isTest
    static void verifierUnitTest() {
        
        Case c = createTestCase();
        CaseAnnex__c annex = createAndLinkCaseAnnex(c.Id);

        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());
        Integer beforeCount = [SELECT count() FROM System_Action__c];

        Test.startTest();
            List<String> returnIds = callInvocable(String.valueOf(c.Id), 'cx_ln_Cross_Selling_Verifier_Result__c');
        Test.stopTest();
	}
    @isTest
    static void verifierUnitDeclinedTest() {
        
        Case c = createTestCase();
        CaseAnnex__c annex = createAndLinkCaseAnnex(c.Id);
        annex.cx_ln_Cross_Selling_Verifier_Result__c='Decline';
        update annex;
        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());
        Integer beforeCount = [SELECT count() FROM System_Action__c];

        Test.startTest();
            List<String> returnIds = callInvocable(String.valueOf(c.Id), 'cx_ln_Cross_Selling_Verifier_Result__c');
        Test.stopTest();
	}
    @isTest
    static void verifierUnitCancelledTest() {
        
        Case c = createTestCase();
        CaseAnnex__c annex = createAndLinkCaseAnnex(c.Id);
        annex.cx_ln_Cross_Selling_Verifier_Result__c='Cancelled';
        update annex;
        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());
        Integer beforeCount = [SELECT count() FROM System_Action__c];

        Test.startTest();
            List<String> returnIds = callInvocable(String.valueOf(c.Id), 'cx_ln_Cross_Selling_Verifier_Result__c');
        Test.stopTest();
	}
     @isTest
    static void approverUnitTest() {
       
        Case c = createTestCase();
        CaseAnnex__c annex = createAndLinkCaseAnnex(c.Id);

        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());
        Integer beforeCount = [SELECT count() FROM System_Action__c];

        Test.startTest();
            List<String> returnIds = callInvocable(String.valueOf(c.Id), 'cx_ln_Cross_Selling_Approver_Result__c');
        Test.stopTest();
	}
         @isTest
    static void approverUnitDeclinedTest() {
       
        Case c = createTestCase();
        CaseAnnex__c annex = createAndLinkCaseAnnex(c.Id);
        annex.cx_ln_Cross_Selling_Approver_Result__c='Decline';
        update annex;

        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());
        Integer beforeCount = [SELECT count() FROM System_Action__c];

        Test.startTest();
            List<String> returnIds = callInvocable(String.valueOf(c.Id), 'cx_ln_Cross_Selling_Approver_Result__c');
        Test.stopTest();
	}
         @isTest
    static void approverUnitCancelledTest() {
       
        Case c = createTestCase();
        CaseAnnex__c annex = createAndLinkCaseAnnex(c.Id);
        annex.cx_ln_Cross_Selling_Approver_Result__c='Cancelled';
        update annex;

        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());
        Integer beforeCount = [SELECT count() FROM System_Action__c];

        Test.startTest();
            List<String> returnIds = callInvocable(String.valueOf(c.Id), 'cx_ln_Cross_Selling_Approver_Result__c');
        Test.stopTest();
	}
    @isTest
    static void signatureVerifierTest() {
        Case c = createTestCase();
        CaseAnnex__c annex = createAndLinkCaseAnnex(c.Id);

        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());
        Integer beforeCount = [SELECT count() FROM System_Action__c];

        Test.startTest();
            List<String> returnIds = callInvocable(String.valueOf(c.Id), 'cc_Signature_Verifier_Result__c');
        Test.stopTest();
	}
    @isTest
    static void updateCrossSellingTest() {
        
        Case c = createTestCase();
        CaseAnnex__c annex = createAndLinkCaseAnnex(c.Id);

        // Create a basic HttpRequest (the class under test will set body/header)
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.test/api');
        req.setMethod('POST');

        // Set mock for any callouts performed inside EM001_ApiCalls.updateCreditCardRequestStatusApi
        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());

        Test.startTest();
            HttpResponse res = Loan_CrossSellingCcFinalApproval.updateCrossSellingCaseStatusApi(req, c, 'APPROVED');
        Test.stopTest();
	}

}
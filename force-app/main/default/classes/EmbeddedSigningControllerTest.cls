@isTest
public class EmbeddedSigningControllerTest {
    
    @testSetup
    static void makeData() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        
        // Create and insert ILA Account as Person Account
        Account testAccountIla = (Account)TestDataFactory.createSObject(
            new Account(
                CIF__pc = '123456',
                CustomerStatus__c = null,
                Subscription_Model__pc = 'ila',
                Archived__pc = false,
                Region_Flag__pc = 'Bahrain'
            ),
            'TestFactoryDefaults.AccountDefaults',
            true
        );
        
        // NEW: Re-query to ensure PersonContactId is populated (safe practice in tests)
        testAccountIla = [SELECT Id, PersonContactId FROM Account WHERE Id = :testAccountIla.Id LIMIT 1];
        
        Case caseObj = (Case)TestDataFactory.createSObject(
            new Case(
                RecordTypeId = acRecordTypeId,
                ContactId = testAccountIla.PersonContactId,
                AccountId = testAccountIla.Id,
                Case_Model__c = 'ila',
                AIR_HaveCreditCard__c = true,isSubmitted__c = true
            ),
            'TestFactoryDefaults.CaseDefaults',
            true
        );
        
        // Create and insert Alburaq Account as Person Account
        Account testAccountAlburaq = (Account)TestDataFactory.createSObject(
            new Account(
                CIF__pc = '789102',
                CustomerStatus__c = null,
                Subscription_Model__pc = 'alburaq',
                Archived__pc = false,
                Region_Flag__pc = 'Bahrain'
            ),
            'TestFactoryDefaults.AccountDefaults',
            true
        );
        
        // NEW: Re-query to ensure PersonContactId is populated
        testAccountAlburaq = [SELECT Id, PersonContactId FROM Account WHERE Id = :testAccountAlburaq.Id LIMIT 1];
        
        Case testCase = (Case)TestDataFactory.createSObject(
            new Case(
                RecordTypeId = acRecordTypeId,
                ContactId = testAccountAlburaq.PersonContactId,
                AccountId = testAccountAlburaq.Id,
                Case_Model__c = 'alburaq',
                AIR_HaveCreditCard__c = false,isSubmitted__c = true
            ),
            'TestFactoryDefaults.CaseDefaults',
            true
        );
        
        CaseAnnex__c testCaseAnnex = new CaseAnnex__c(
            Case__c = caseObj.Id,
            cx_ln_Product__c = 'Unsecured',
            cx_ln_Requested_Liabilities__c = '[{"type":"Credit Card","outstanding":1000,"monthlyInstallment":100,"selected":true}]',
            cx_ln_Cross_Selling_Approver_Result__c = 'Approve',
            EarlyRepaymentPrincipalAmount__c = 1000,
            ApprovedLoanTopUpDuration__c = 12,
            cx_ln_Approved_Installment_Amount__c = 100,
            cx_ln_Approved_Loan_Amount__c = 5000,
            cx_ln_ApprovedInterestProfitRateReducing__c = 5,
            cx_ln_Requested_Processing_Fees__c = 50,
            cx_ln_Approved_Duration_Months__c = 12,
            cx_ln_ApprovedNewRate__c = 6,
            cx_ln_Approved_insurance__c = true,
            cx_ln_APR__c = 7,
            cx_ln_Requested_Vat_Processing_Fees__c = 5,
            cx_ln_Approved_First_installment_date__c = Date.newInstance(2025, 1, 1),
            cx_ln_Approved_Maturity_Date__c = Date.newInstance(2026, 1, 1),
            cx_Approved_Partial_payment_option__c = 'Keep same installment amount'
        );
        insert testCaseAnnex;
        
        caseObj.CaseAnnex__c = testCaseAnnex.Id;
        update caseObj;
        
        testCase.CaseAnnex__c = testCaseAnnex.Id;
        update testCase;
        
    }
    
    @isTest
    static void testSendEnvelopeIla() {
        Case testCase = [SELECT Id, Customer_CIF__c FROM Case WHERE Case_Model__c = 'ila' LIMIT 1];
        
        Test.startTest();
        String result = EmbeddedSigningController.sendEnvelope(testCase.Id, 'Email');
        Test.stopTest();
    }
    
    @isTest
    static void testSendEnvelopeAlburaq() {
        Case testCase = [SELECT Id FROM Case WHERE Case_Model__c = 'alburaq' LIMIT 1];
        Test.startTest();
        String result = EmbeddedSigningController.sendEnvelope(testCase.Id, 'In-App');
        Test.stopTest();
    }
    
    /* @isTest
static void testGetEmbeddedSigningUrl() {
String envId = 'test-env-id';
String url = 'https://example.com/returnUrl';

Test.setMock(HttpCalloutMock.class, new DocuSignSigningMock());

Test.startTest();
String result = EmbeddedSigningController.getEmbeddedSigningUrl(envId, url);
Test.stopTest();

System.assertNotEquals(null, result, 'Signing URL should be returned');
} */
    
    @isTest
    static void testSendEnvelopeException() {
        Case testCase = [SELECT Id FROM Case WHERE Case_Model__c = 'ila' LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new ErrorCalloutMock());
        
        Test.startTest();
        try {
            EmbeddedSigningController.sendEnvelope(testCase.Id, 'Email');
        } catch (Exception e) {
            // Expected for coverage
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSendEnvelopeAlburaqException() {
        Case testCase = [SELECT Id FROM Case WHERE Case_Model__c = 'alburaq' LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new ErrorCalloutMock());
        
        Test.startTest();
        try {
            EmbeddedSigningController.sendEnvelope(testCase.Id, 'In-App');
        } catch (Exception e) {
            // Expected for coverage
        }
        Test.stopTest();
    }
    
    // Mock for DocuSign signing URL
    private class DocuSignSigningMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"url":"https://example.com/signing-url"}');
            return res;
        }
    }
    
    // Mock to simulate error
    private class ErrorCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error":"Server error"}');
            return res;
        }
    }
}
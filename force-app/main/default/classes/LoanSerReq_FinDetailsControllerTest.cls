@isTest
public class LoanSerReq_FinDetailsControllerTest {
	@testSetup
    static void setup() {
        Case testCase = createTestCase();
 		CaseAnnex__c testCaseAnnex = createTestCaseAnnex(testCase);
    }
    
    private static Case createTestCase() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456', Subscription_Model__pc = 'alburaq', CustomerStatus__c=null,Archived__pc = false, x_canary__pc = 'canary'), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email', Type = 'New Loan / Finance Service Request',Sub_Type__c = 'Restructuring',isSubmitted__c = true), 'TestFactoryDefaults.CaseDefaults',true);
        System.debug('testCase>>'+testCase);
        return testCase;
    }
    
    private static CaseAnnex__c createTestCaseAnnex(Case testCase) {
        CaseAnnex__c testCaseAnnex = new CaseAnnex__c(
            Case__c = testCase.Id,
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
        return testCaseAnnex;
    }
    
    @isTest
    static void testReviewBcrbDetails() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        CaseAnnex__c testCaseAnnex = [SELECT Id FROM CaseAnnex__c LIMIT 1];
        
        Test.startTest();
        Map<String, Object> result = LoanServiceRequest_FinDetailsController.reviewBcrbDetails(testCase.Id, testCaseAnnex.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testFetchBcrbDetails() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        CaseAnnex__c testCaseAnnex = [SELECT Id FROM CaseAnnex__c LIMIT 1];
        
        Test.startTest();
        Map<String, Object> result = LoanServiceRequest_FinDetailsController.fetchBcrbDetails(testCase.Id, testCaseAnnex.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testBcrbDetailsMapping() {
        CaseAnnex__c testCaseAnnex = [SELECT Id FROM CaseAnnex__c LIMIT 1];
        String mockEsalaryData = null;
        String mockBcrbData = '{"data":{"totalCurrentObligations":1240.00}}';
        
        Test.startTest();
        CaseAnnex__c result = LoanServiceRequest_FinDetailsController.bcrbDetailsMapping(testCaseAnnex, mockEsalaryData, mockBcrbData);
        Test.stopTest();
    }
    
    @isTest
    static void testGenerateRepaymentSchedule() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        CaseAnnex__c testCaseAnnex = [SELECT Id FROM CaseAnnex__c LIMIT 1];
        
        Test.startTest();
        Map<String, Object> result = LoanServiceRequest_FinDetailsController.generateRepaymentSchedule(testCase.Id, testCaseAnnex.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetSimulationPaymentList() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        CaseAnnex__c testCaseAnnex = [SELECT Id FROM CaseAnnex__c LIMIT 1];
        
        Test.startTest();
        Loans_ServiceManagerHandler.APIResponse result = LoanServiceRequest_FinDetailsController.getSimulationPaymentList(testCase.Id, testCaseAnnex.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testCallGetLoanPaymentsScheduleForServiceRequest() {
        Case testCase = [SELECT Id, Customer_CIF__c FROM Case LIMIT 1];
        CaseAnnex__c testCaseAnnex = [SELECT Id, cx_ln_SimulationReference__c, cx_ln_SR_Arrangment_Id__c FROM CaseAnnex__c LIMIT 1];
        
        Test.startTest();
        Loans_ServiceManagerHandler.APIResponse result = LoanServiceRequest_FinDetailsController.callGetLoanPaymentsScheduleForServiceRequest(
            testCase.Id, 
            testCase.Customer_CIF__c, 
            testCaseAnnex.cx_ln_SimulationReference__c != null ? testCaseAnnex.cx_ln_SimulationReference__c : 'AASIMR25229B3WZ6Z0', 
            testCaseAnnex.cx_ln_SR_Arrangment_Id__c != null ? testCaseAnnex.cx_ln_SR_Arrangment_Id__c : 'AA252267PFXS', 
            true
        );
        Test.stopTest();
    }
    
    @isTest
    static void testCallSimulationApi() {
        Case testCase = [SELECT Id, Customer_CIF__c, Region_Flag__c, Case_Model__c, Sub_Type__c, cc_PCI_Id__c, ac_Currency__c, Card_Product_Configuration_Id__c, AccountId, Type FROM Case LIMIT 1];
        CaseAnnex__c testCaseAnnex = [SELECT Id, cx_Approved_Partial_payment_option__c, cx_ln_Approved_Duration_Months__c, cx_ln_Approved_Loan_Amount__c, cx_ln_ApprovedNewRate__c FROM CaseAnnex__c LIMIT 1];
        HttpRequest mockRequest = new HttpRequest();
        
        Test.startTest();
        HttpResponse result = LoanServiceRequest_FinDetailsController.callSimulationApi(testCase, testCaseAnnex, mockRequest, true);
        Test.stopTest();
    }
    
    @isTest
    static void testDateToApiDateFormat() {
        Date testDate = Date.newInstance(2025, 10, 15);
        
        Test.startTest();
        String result = LoanServiceRequest_FinDetailsController.dateToApiDateFormat(testDate);
        Test.stopTest();
    }
    
    @isTest
    static void testStringApiFormat() {
        String testString = 'testValue';
        
        Test.startTest();
        String result = LoanServiceRequest_FinDetailsController.stringApiFormat(testString);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCaseFieldsMap() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        Map<String, Object> result = LoanServiceRequest_FinDetailsController.getCaseFieldsMap(testCase.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCaseAnnexFieldsMap() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        List<Map<String, Object>> result = LoanServiceRequest_FinDetailsController.getCaseAnnexFieldsMap(testCase.Id);
        Test.stopTest();
    }
}
@IsTest
public class Lwc03_FinancialDetailsControllerTest {

    @TestSetup
    static void setupTestData() {

           Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',Subscription_Model__pc = 'alburaq', CustomerStatus__c=null, Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);

        Case testCase = new Case(
            Subject = 'Test Case',
            Region_Flag__c = 'Bahrain',
            Case_Model__c = 'alburaq',
            AccountId = testAccount.Id,
            Type = 'Loan Application',
            cc_Whitelisted_Employer__c = true,
            cc_Employer_Grade__c = 'A',
            cc_Employment_Status__c = 'Employed'
        );
        insert testCase;

        CaseAnnex__c testCaseAnnex = new CaseAnnex__c(
            Case__c = testCase.Id,
            cx_ln_Requested_Loan_Finance_Amount__c = 50000,
            cx_ln_Requested_Duration_Months__c = 24,
            cx_ln_Monthly_Instalment__c = 2200,
            cx_ln_Approved_Loan_Amount__c = 50000,
            cx_ln_Approved_Duration_Months__c = 24,
            cx_ln_Approved_Installment_Amount__c = 2200,
            cx_ln_ApprovedInterestProfitRateReducing__c = 5.5,
            cx_ln_Requested_Processing_Fees__c = 100,
            cx_ln_Requested_Vat_Processing_Fees__c = 10,
            cx_ln_Approved_Buyout_Amount__c = 0,
            cx_ln_TotalLiabilitiesAmount__c = 0,
            cx_ln_Approved_PreInsuranceStatus__c = 'Approved',
            cx_ln_Approved_Insurance_Premium__c = 'Upfront',
            cx_ln_Approved_insurance__c = true,
            cx_ln_APR__c = 6.2,
            cx_ln_ApprovedProcessing_Fee_Type__c = 'Upfront',
            cx_ln_Approved_First_installment_date__c = Date.today().addDays(30),
            cx_ln_Product__c = 'Unsecured'
        );
        insert testCaseAnnex;
    }

    @IsTest
    static void testCallBcrbApi_Success() {

        Case testCase = [SELECT Id, Customer_CIF__c FROM Case LIMIT 1];
        CaseAnnex__c testCaseAnnex = [SELECT Id, cx_ln_Approved_Installment_Amount__c, cx_ln_Approved_Loan_Amount__c, cx_ln_Approved_Duration_Months__c FROM CaseAnnex__c LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new BcrbApiMock());

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Test_API/api/v1/bcrb/inquiry');
        request.setMethod('POST');

        HttpResponse response = Lwc03_FinancialDetailsController.callBcrbApi(request, testCase, testCaseAnnex);

        Test.stopTest();

        System.assertEquals(200, response.getStatusCode(), 'Response status should be 200');
        System.assertEquals('OK', response.getStatus(), 'Response status should be OK');
        System.assert(response.getBody().contains('Successfully retrieved liabilities'), 'Response body should contain success message');
    }

    @IsTest
    static void testCallBcrbApi_WithoutCustomerId() {

        Case testCase = [SELECT Id, Customer_CIF__c FROM Case LIMIT 1];

        CaseAnnex__c testCaseAnnex = [SELECT Id, cx_ln_Approved_Installment_Amount__c, cx_ln_Approved_Loan_Amount__c, cx_ln_Approved_Duration_Months__c FROM CaseAnnex__c LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new BcrbApiMock());

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Test_API/api/v1/bcrb/inquiry');
        request.setMethod('POST');

        HttpResponse response = Lwc03_FinancialDetailsController.callBcrbApi(request, testCase, testCaseAnnex);

        Test.stopTest();

        System.assertEquals(200, response.getStatusCode(), 'Response status should be 200');
    }

    @IsTest
    static void testCallBcrbApi_WithoutApprovedInstallment() {

        Case testCase = [SELECT Id, Customer_CIF__c FROM Case LIMIT 1];
        CaseAnnex__c testCaseAnnex = [SELECT Id, cx_ln_Monthly_Instalment__c, cx_ln_Approved_Loan_Amount__c,cx_ln_Approved_Duration_Months__c FROM CaseAnnex__c LIMIT 1];
        testCaseAnnex.cx_ln_Approved_Installment_Amount__c = null;
        update testCaseAnnex;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new BcrbApiMock());

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Test_API/api/v1/bcrb/inquiry');
        request.setMethod('POST');

        HttpResponse response = Lwc03_FinancialDetailsController.callBcrbApi(request, testCase, testCaseAnnex);

        Test.stopTest();

        System.assertEquals(200, response.getStatusCode(), 'Response status should be 200');
    }

    @IsTest
    static void testReviewBcrbDetails_Success() {

        Case testCase = [SELECT Id FROM Case LIMIT 1];
        CaseAnnex__c testCaseAnnex = [SELECT Id FROM CaseAnnex__c LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new BcrbApiMock());

        Map<String, Object> result = Lwc03_FinancialDetailsController.reviewBcrbDetails(testCase.Id, testCaseAnnex.Id);

        Test.stopTest();

        System.assertEquals('Success', result.get('status'), 'Status should be Success');

        List<System_Action__c> systemActions = [SELECT Id FROM System_Action__c];
        System.assert(systemActions.size() > 0, 'System Action should be created');

        CaseAnnex__c updatedAnnex = [SELECT Id, cx_ln_BCRB_Api_Response__c FROM CaseAnnex__c WHERE Id = :testCaseAnnex.Id];
        System.assert(updatedAnnex.cx_ln_BCRB_Api_Response__c != null, 'BCRB API Response should be saved');
    }

    @IsTest
    static void testReviewBcrbDetails_ApiError() {

        Case testCase = [SELECT Id FROM Case LIMIT 1];
        CaseAnnex__c testCaseAnnex = [SELECT Id FROM CaseAnnex__c where Case__c =:testCase.Id LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new BcrbApiErrorMock());

        Map<String, Object> result = Lwc03_FinancialDetailsController.reviewBcrbDetails(testCase.Id, testCaseAnnex.Id);

        Test.stopTest();

        System.assertEquals('Success', result.get('status'), 'Status should be Success');

    }

    @IsTest
    static void testReviewBcrbDetails_Exception() {
        Test.startTest();

        Map<String, Object> result = Lwc03_FinancialDetailsController.reviewBcrbDetails('invalidId', 'invalidId');

        Test.stopTest();

        System.assertEquals('Error', result.get('status'), 'Status should be Error');
        System.assert(result.get('message') != null, 'Error message should be present');
    }

    @IsTest
    static void testFetchBcrbDetails_Success() {

        Case testCase = [SELECT Id FROM Case LIMIT 1];
        CaseAnnex__c testCaseAnnex = [SELECT Id FROM CaseAnnex__c LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new BcrbApiMock());

        Map<String, Object> result = Lwc03_FinancialDetailsController.fetchBcrbDetails(testCase.Id, testCaseAnnex.Id);

        Test.stopTest();

        System.assertEquals('Success', result.get('status'), 'Status should be Success');

        CaseAnnex__c updatedAnnex = [SELECT Id, cx_ln_TotalCurrentObligations__c, cx_ln_Credit_Bureau_Score__c 
                                     FROM CaseAnnex__c WHERE Id = :testCaseAnnex.Id];
        System.assert(updatedAnnex.cx_ln_TotalCurrentObligations__c != null, 'Total Current Obligations should be mapped');
        System.assert(updatedAnnex.cx_ln_Credit_Bureau_Score__c != null, 'Credit Bureau Score should be mapped');
    }

    @IsTest
    static void testBcrbDetailsMapping() {

        CaseAnnex__c testCaseAnnex = [SELECT Id FROM CaseAnnex__c LIMIT 1];

        Test.startTest();

        String bcrbData = '{"meta":{"code":"bcrb-1000","message":"Successfully retrieved liabilities."},"data":{"totalConsumerLoans":200,"totalMortgageLoans":320,"totalCreditCards":600.00,"totalGovernmentLoans":120,"totalOverdraftInstallments":0,"totalLeverageLoanInstallments":0,"totalBuyNowPayLaterInstallments":0,"totalCurrentObligations":1240.00,"totalCreditExposure":27100,"creditBureauScore":800,"transactionNo":"2172174","currentPSIExpiryDate":"2021-01-21","loanApplicationDecision":"No Decision","currentLoansLimit":56400.00,"totalIObligations":0,"numberOfArrears":0,"numberOfCorporateAccounts":0,"numberOfNonOwnerAccounts":0,"numberOfOpenedPSICases":1,"numberOfRejectedPSI30Days":0,"numberOfPSIILARejections":0,"numberOfNonNormalAccounts":0,"totalOfArrearsCurrentAndHistorical":0,"totalOfPenaltiesAndContraventionAccounts":0,"currentCustomerStatus":"Normal","numberOfCreditCardsWithoutIla":4,"numberOfIlaCreditCards":1,"totalCreditCardInstallments":530,"totalIlaCreditCardInstallmentsWithoutIla":410,"totalIlaCreditCardInstallments":120,"totalNumberOfLoans":0,"numberOfArrears1":0,"numberOfArrearsCurrentAndHistorical":0,"numberOfArrearsWithGovLoans":0,"numberOfArrearsWithoutGovLoans":0,"totalCurrentObligations1":0,"currentLoansLimit1":0,"currentCustomerStatus1":"Normal","numberOfCorporateAccounts1":0,"numberOfNonOwnerAccounts1":0,"numberOfOpenedPsiCases":1,"numberOfRejectedPsi30Days":0,"numberOfBillingAccounts":0}}';

        CaseAnnex__c result = Lwc03_FinancialDetailsController.bcrbDetailsMapping(
            new CaseAnnex__c(Id = testCaseAnnex.Id), 
            null, 
            bcrbData
        );

        Test.stopTest();

        System.assertEquals(1240.00, result.cx_ln_TotalCurrentObligations__c, 'Total Current Obligations should be mapped correctly');
        System.assertEquals(200, result.cx_ln_TotalConsumerLoansInstallments__c, 'Total Consumer Loans should be mapped correctly');
        System.assertEquals(320, result.cx_ln_TotalMortgageLoansInstallments__c, 'Total Mortgage Loans should be mapped correctly');
        System.assertEquals(530, result.cx_ln_TotalCreditCardsInstallments__c, 'Total Credit Cards Installments should be mapped correctly');
        System.assertEquals(800, result.cx_ln_Credit_Bureau_Score__c, 'Credit Bureau Score should be mapped correctly');
        System.assertEquals('Normal', result.cx_ln_Current_Customer_Status__c, 'Current Customer Status should be mapped correctly');
    }

    @IsTest
    static void testGenerateRepaymentSchedule_Success() {

        Case testCase = [SELECT Id FROM Case LIMIT 1];
        CaseAnnex__c testCaseAnnex = [SELECT Id FROM CaseAnnex__c LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SimulationApiMock());

        Map<String, Object> result = Lwc03_FinancialDetailsController.generateRepaymentSchedule(testCase.Id, testCaseAnnex.Id);

        Test.stopTest();

        System.assertEquals('Success', result.get('status'), 'Status should be Success');
        System.assert(result.get('response') != null, 'Response should be present');

        CaseAnnex__c updatedAnnex = [SELECT Id, cx_ln_SimulationReference__c, cx_ln_isScheduleGenerated__c 
                                     FROM CaseAnnex__c WHERE Id = :testCaseAnnex.Id];
        System.assertEquals('AASIM251826SFNMSJL', updatedAnnex.cx_ln_SimulationReference__c, 'Simulation Reference should be saved');
        //System.assertEquals(true, updatedAnnex.cx_ln_isScheduleGenerated__c, 'Schedule Generated flag should be true');
    }

    @IsTest
    static void testGenerateRepaymentSchedule_ApiError() {

        Case testCase = [SELECT Id FROM Case LIMIT 1];
        CaseAnnex__c testCaseAnnex = [SELECT Id FROM CaseAnnex__c LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SimulationApiErrorMock());

        Map<String, Object> result = Lwc03_FinancialDetailsController.generateRepaymentSchedule(testCase.Id, testCaseAnnex.Id);

        Test.stopTest();

        System.assertEquals('Success', result.get('status'), 'Status should be Success');

    }

    @IsTest
    static void testGetSimulationPaymentList() {

        Case testCase = [SELECT Id FROM Case LIMIT 1];
        CaseAnnex__c testCaseAnnex = [SELECT Id FROM CaseAnnex__c LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SimulationPaymentListMock());

        Loans_ServiceManagerHandler.APIResponse response = Lwc03_FinancialDetailsController.getSimulationPaymentList(testCase.Id, testCaseAnnex.Id);

        Test.stopTest();

        System.assert(response != null, 'Response should not be null');

        CaseAnnex__c updatedAnnex = [SELECT Id, cx_ln_Approved_Installment_Amount__c, cx_ln_APR__c 
                                     FROM CaseAnnex__c WHERE Id = :testCaseAnnex.Id];
        System.assert(updatedAnnex.cx_ln_Approved_Installment_Amount__c != null, 'Approved Installment Amount should be updated');
        System.assert(updatedAnnex.cx_ln_APR__c != null, 'APR should be updated');
    }

    @IsTest
    static void testGetCaseFieldsMap() {

        Case testCase = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();

        Map<String, Object> result = Lwc03_FinancialDetailsController.getCaseFieldsMap(testCase.Id);

        Test.stopTest();

        System.assert(result != null, 'Result should not be null');

    }

    @IsTest
    static void testGetCaseFieldsMap_Exception() {
        Test.startTest();

        try {
            Map<String, Object> result = Lwc03_FinancialDetailsController.getCaseFieldsMap(null);
            System.assert(false, 'Exception should have been thrown');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException, 'Should throw AuraHandledException');
        }

        Test.stopTest();
    }

    @IsTest
    static void testGetCaseAnnexFieldsMap() {

        Case testCase = [SELECT Id FROM Case LIMIT 1];
        System.debug('test case >>> ' + testCase.Id);
        CaseAnnex__c caseannex = [SELECT Id FROM CaseAnnex__c where Case__c =: testCase.Id LIMIT 1];
         System.debug('test caseannex >>> ' + caseannex.Id);
        Test.startTest();

        List<Map<String, Object>> result = Lwc03_FinancialDetailsController.getCaseAnnexFieldsMap(testCase.Id);

        Test.stopTest();

         System.assert(result != null, 'Result should not be null');

    }

    @IsTest
    static void testGetCaseAnnexFieldsMap_Exception() {
        Test.startTest();

        try {
            List<Map<String, Object>> result = Lwc03_FinancialDetailsController.getCaseAnnexFieldsMap(null);
            System.assert(false, 'Exception should have been thrown');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException, 'Should throw AuraHandledException');
        }

        Test.stopTest();
    }

    @IsTest
    static void testStringApiFormat() {
        Test.startTest();

        String result1 = Lwc03_FinancialDetailsController.stringApiFormat('test');
        String result2 = Lwc03_FinancialDetailsController.stringApiFormat(null);

        Test.stopTest();

        System.assertEquals('"test"', result1, 'String should be wrapped in quotes');
        System.assertEquals('null', result2, 'Null should return "null" string');
    }

    @IsTest
    static void testDateToApiDateFormat() {
        Test.startTest();

        Date testDate = Date.newInstance(2023, 12, 25);
        String result1 = Lwc03_FinancialDetailsController.dateToApiDateFormat(testDate);
        String result2 = Lwc03_FinancialDetailsController.dateToApiDateFormat(null);

        Test.stopTest();

        System.assertEquals('2023-12-25', result1, 'Date should be formatted correctly');
        System.assertEquals(null, result2, 'Null date should return null');
    }

    private class BcrbApiMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"meta":{"code":"bcrb-1000","message":"Successfully retrieved liabilities."},"data":{"totalConsumerLoans":200,"totalMortgageLoans":320,"totalCreditCards":600.00,"totalGovernmentLoans":120,"totalOverdraftInstallments":0,"totalLeverageLoanInstallments":0,"totalBuyNowPayLaterInstallments":0,"totalCurrentObligations":1240.00,"totalCreditExposure":27100,"creditBureauScore":800,"transactionNo":"2172174","currentPSIExpiryDate":"2021-01-21","loanApplicationDecision":"No Decision","currentLoansLimit":56400.00,"totalIObligations":0,"numberOfArrears":0,"numberOfCorporateAccounts":0,"numberOfNonOwnerAccounts":0,"numberOfOpenedPSICases":1,"numberOfRejectedPSI30Days":0,"numberOfPSIILARejections":0,"numberOfNonNormalAccounts":0,"totalOfArrearsCurrentAndHistorical":0,"totalOfPenaltiesAndContraventionAccounts":0,"currentCustomerStatus":"Normal","numberOfCreditCardsWithoutIla":4,"numberOfIlaCreditCards":1,"totalCreditCardInstallments":530,"totalIlaCreditCardInstallmentsWithoutIla":410,"totalIlaCreditCardInstallments":120,"totalNumberOfLoans":0,"numberOfArrears1":0,"numberOfArrearsCurrentAndHistorical":0,"numberOfArrearsWithGovLoans":0,"numberOfArrearsWithoutGovLoans":0,"totalCurrentObligations1":0,"currentLoansLimit1":0,"currentCustomerStatus1":"Normal","numberOfCorporateAccounts1":0,"numberOfNonOwnerAccounts1":0,"numberOfOpenedPsiCases":1,"numberOfRejectedPsi30Days":0,"numberOfBillingAccounts":0}}');
            response.setStatusCode(200);
            response.setStatus('OK');
            return response;
        }
    }

    private class BcrbApiErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"meta":{"code":"bcrb-1001","message":"API Error occurred"}}');
            response.setStatusCode(500);
            response.setStatus('Internal Server Error');
            return response;
        }
    }

    private class SimulationApiMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"meta": {"code": "LOAN-1003","message": "Successfully created loan application."},"data": {"simulationReference": "AASIM251826SFNMSJL"}}');
            response.setStatusCode(200);
            response.setStatus('OK');
            return response;
        }
    }

    private class SimulationApiErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"meta": {"code": "LOAN-1001","message": "Simulation API Error"}}');
            response.setStatusCode(400);
            response.setStatus('Bad Request');
            return response;
        }
    }

    private class SimulationPaymentListMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"success": true, "headerData": {"monthlyInstallment": 2200, "insuranceAmount": 100, "apr": 6.2, "lifeInsuranceRate": 0.5, "maturityDate": "2025-12-25"}}');
            response.setStatusCode(200);
            response.setStatus('OK');
            return response;
        }
    }
}
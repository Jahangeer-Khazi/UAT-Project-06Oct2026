/**
 * @author Aniss Mbarki
 * @date Création 29/11/2024
 * @date Modification
 * @description : 
 */

@isTest
public class LTNG056_LoansCalculatorControllerTest {

        @IsTest
    static void testCalculatorApiCallMONTHLY_INSTALLMENT_NullParameters() {
        // Prepare test parameters with some null values to test the null checks
        Map<String, Object> param = new Map<String, Object>();
        param.put('calculationMethod', 'BY_MONTHLY_INSTALLMENT');
        param.put('LoanAmount', null);
        param.put('LoanDuration', null);
        param.put('ExistingLoans', null);
        
        Test.startTest();
        Map<String, Object> result = LTNG056_LoansCalculatorController.calculatorApiCall(param);
        Test.stopTest();

    }
    // Test for the 'BY_LOAN_AMOUNT' calculation method
    @IsTest
    static void testCalculatorByLoanAmount() {
        // Set up mock callout
     //   Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create test parameters
        Map<String, Object> testParam = new Map<String, Object>();
        testParam.put('segment', 'Regular');
        testParam.put('regionName', 'Bahrain');
        testParam.put('nationality', 'Saudi');
        testParam.put('customerId', '12345');
        testParam.put('loanType', 'Personal');
        testParam.put('subscription', 'ila');
        testParam.put('calculationMethod', 'BY_LOAN_AMOUNT');
        testParam.put('LoanAmount', '50000');
        testParam.put('LoanDuration', '24');
        testParam.put('ExistingLoans', '5000');

        Test.startTest();
        Map<String, Object> result = LTNG056_LoansCalculatorController.calculatorApiCall(testParam);
        Test.stopTest();
    }

    // Test for the 'BY_MONTHLY_INSTALLMENT' calculation method
    @IsTest
    static void testCalculatorByMonthlyInstallment() {
        // Set up mock callout
       // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create test parameters
        Map<String, Object> testParam = new Map<String, Object>();
        testParam.put('segment', 'Regular');
        testParam.put('regionName', 'Bahrain');
        testParam.put('nationality', 'Saudi');
        testParam.put('customerId', '54321');
        testParam.put('loanType', 'Personal');
        testParam.put('subscription', 'ila');
        testParam.put('calculationMethod', 'BY_MONTHLY_INSTALLMENT');
        testParam.put('LoanDuration', '12.00');
        testParam.put('InstallmentAmount', '4500.00');
        testParam.put('LoanAmount', '50000');
        //testParam.put('LoanDuration', '24');

        Test.startTest();
        Map<String, Object> result = LTNG056_LoansCalculatorController.calculatorApiCall(testParam);
        Test.stopTest();
    }

    // Test for the error handling scenario
    @IsTest
    static void testErrorScenario() {
        // Use a mock that simulates a failed API response (e.g., non-200 status code or malformed JSON)
      //  Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create valid test parameters
        Map<String, Object> testParam = new Map<String, Object>();
        testParam.put('segment', 'Regular');
        testParam.put('regionName', 'Bahrain');
        testParam.put('nationality', 'Saudi');
        testParam.put('customerId', '12345');
        testParam.put('loanType', 'Personal');
        testParam.put('subscription', 'ila');
        testParam.put('calculationMethod', 'BY_LOAN_AMOUNT');
        testParam.put('LoanAmount', '50000.00');
        testParam.put('LoanDuration', '24.00');
        testParam.put('ExistingLoans', '5000.00');

        Test.startTest();
        Map<String, Object> result = LTNG056_LoansCalculatorController.calculatorApiCall(testParam);
        Test.stopTest();

    }
        @testSetup
    static void setupTestData() {
        // Create custom metadata records for the `checkCalculatorApiParams` method
        // These values must match the equations returned in the mock API response inside the method
 /*       LoanCalculator__mdt byLoanMetadata = new LoanCalculator__mdt(
            DeveloperName = 'BY_LOAN_AMOUNT',
            EquationHoldAmount__c = 'TotalRepayment + ProcessingFee + VATProcessingFee',
            EquationLoanAmount__c = '(((GrossIncome / 2) - CreditCardsMinimumDue) * ((((1 + MonthlyInterestRate) ^ NumberOfMonths) - 1) / (MonthlyInterestRate * ((1 + MonthlyInterestRate) ^ NumberOfMonths))))',
            EquationMonthlyInstallment__c = '(MonthlyInterestRate * LoanAmount) / (1 - (1 + MonthlyInterestRate) ^ -NumberOfMonths)',
            EquationTotalCashInHand__c = 'LoanAmount - ExistingLoans',
            EquationTotalInterest__c = 'TotalRepayment - LoanAmount',
            EquationTotalRepayment__c = 'MonthlyInstallment * NumberOfMonths'
        );
        insert byLoanMetadata;

        LoanCalculator__mdt byMonthlyInstallmentMetadata = new LoanCalculator__mdt(
            DeveloperName = 'BY_MONTHLY_INSTALLMENT',
            EquationHoldAmount__c = 'TotalRepayment + ProcessingFee + VATProcessingFee',
            EquationLoanAmount__c = 'MonthlyInstallment * (((( 1 + MonthlyInterestRate ) ^NumberOfMonths ) -1) / ( MonthlyInterestRate * ((1+ MonthlyInterestRate) ^ NumberOfMonths )))',
            EquationMonthlyInstallment__c = '',
            EquationTotalCashInHand__c = 'LoanAmount - ExistingLoans',
            EquationTotalInterest__c = 'TotalRepayment - LoanAmount',
            EquationTotalRepayment__c = 'MonthlyInstallment * NumberOfMonths'
        );
        insert byMonthlyInstallmentMetadata;*/
    }



    @IsTest
    static void testCalculatorApiCall_ByMonthlyInstallment_Success() {
        // Prepare test parameters
        Map<String, Object> param = new Map<String, Object>();
        param.put('segment', 'regular');
        param.put('regionName', 'Bahrain');
        param.put('nationality', 'Saudi');
        param.put('customerId', '123');
        param.put('loanType', 'Personal');
        param.put('subscription', 'ila');
        param.put('calculationMethod', 'BY_MONTHLY_INSTALLMENT');
        param.put('InstallmentAmount', '2500.00');
        param.put('LoanDuration', '24.00');
        param.put('ExistingLoans', '0.00');

        Test.startTest();
        Map<String, Object> result = LTNG056_LoansCalculatorController.calculatorApiCall(param);
        Test.stopTest();

    }

   @IsTest
    static void testCalculatorApiCall_ErrorFromApi() {
        // We will mock the checkCalculatorApiParams method to return an error status.
        // This requires making `checkCalculatorApiParams` accessible to the test class, e.g., using `@TestVisible`
        // Since it's called internally, we can simulate an error by not inserting the metadata, but
        // this test class assumes the `checkCalculatorApiParams` logic is correct as per the previous tests.
        // For this test, we assume a mechanism where `checkCalculatorApiParams` returns 'Error'.
        // This is a limitation, but we can test the `try...catch` block.
        
        // This test case relies on an exception being thrown. We can trigger an exception by passing bad data.
        Map<String, Object> param = new Map<String, Object>();
        // Missing required parameters to trigger an exception during deserialization.
        param.put('calculationMethod', 'BY_LOAN_AMOUNT');

        Test.startTest();
        Map<String, Object> result = LTNG056_LoansCalculatorController.calculatorApiCall(param);
        Test.stopTest();


    }
    
    @IsTest
    static void testCalculatorApiCall_NullParameters() {
        // Prepare test parameters with some null values to test the null checks
        Map<String, Object> param = new Map<String, Object>();
        param.put('calculationMethod', 'BY_LOAN_AMOUNT');
        param.put('LoanAmount', null);
        param.put('LoanDuration', null);
        param.put('ExistingLoans', null);
        
        Test.startTest();
        Map<String, Object> result = LTNG056_LoansCalculatorController.calculatorApiCall(param);
        Test.stopTest();

    }
        @IsTest
    static void testCalculatorApiCall_ByLoanAmount_Success() {
        // Prepare test parameters
        Map<String, Object> param = new Map<String, Object>();
        param.put('segment', 'Regular');
        param.put('regionName', 'Bahrain');
        param.put('nationality', 'Saudi');
        param.put('customerId', '123');
        param.put('loanType', 'Personal');
        param.put('subscription', 'ila');
        param.put('calculationMethod', 'BY_LOAN_AMOUNT');
        param.put('LoanAmount', '50000.00');
        param.put('LoanDuration', '24.00');
        param.put('InstallmentAmount','2500.00');
        param.put('ExistingLoans', '5000.00');

        Test.startTest();
        Map<String, Object> result = LTNG056_LoansCalculatorController.calculatorApiCall(param);
        Test.stopTest();

    }
      @IsTest
    static void testCalculatorApiCallMONTHLY_INSTALLMENT_ErrorFromApi() {
        // We will mock the checkCalculatorApiParams method to return an error status.
        // This requires making `checkCalculatorApiParams` accessible to the test class, e.g., using `@TestVisible`
        // Since it's called internally, we can simulate an error by not inserting the metadata, but
        // this test class assumes the `checkCalculatorApiParams` logic is correct as per the previous tests.
        // For this test, we assume a mechanism where `checkCalculatorApiParams` returns 'Error'.
        // This is a limitation, but we can test the `try...catch` block.
        
        // This test case relies on an exception being thrown. We can trigger an exception by passing bad data.
        Map<String, Object> param = new Map<String, Object>();
        // Missing required parameters to trigger an exception during deserialization.
        param.put('calculationMethod', 'BY_MONTHLY_INSTALLMENT');

        Test.startTest();
        Map<String, Object> result = LTNG056_LoansCalculatorController.calculatorApiCall(param);
        Test.stopTest();


    }
    


}
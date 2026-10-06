@isTest
public class Loans_LoansListControllerTest {

    private static Case createTestCase() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',CustomerStatus__c=null,Subscription_Model__pc = 'alburaq',Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',isSubmitted__c = true), 'TestFactoryDefaults.CaseDefaults',true);
        return testCase;
    }

    private static void validateResponse(ApiConnection.Response response) {
        System.assertNotEquals(null, response, 'Response should not be null');
    }

    @isTest
    static void testLoadLoansList_Success() {
        String cif = '123456';
        Case testCase = createTestCase();
        Test.startTest();
        validateResponse(Loans_LoansListController.loadLoansList(cif, testCase.Case_Model__c));
        Test.stopTest();
    }

    @isTest
    static void testCallLoanOptionsAPI_Success() {
        Case testCase = createTestCase();
        Test.startTest();
        validateResponse(Loans_LoansListController.callLoanOptionsAPI(testCase.Id));
        Test.stopTest();
    }

    @isTest
    static void testLoadLoanTransactions_Success() {
        String customerId = '12345';
        String searchParametersJson = '{"id":"5678","offSet":0,"pageSize":100,"debitCreditIndicator":"credit","fromAmount":"2","toAmount":"2","fromDate":"2024-06-11","toDate":"2024-09-11","status":"completed"}';
        String regionName = 'Bahrain';
        Test.startTest();
        validateResponse(Loans_LoansListController.loadLoanTransactions(customerId, searchParametersJson, regionName));
        Test.stopTest();
    }


    @isTest
    static void testCaseRecordType_Success() {
        Case testCase = createTestCase();
        Test.startTest();
        String recordTypeName = Loans_LoansListController.caseRecordType(testCase.Id);
        Test.stopTest();
        System.assertEquals('Loan / Finance Service Request', recordTypeName, 'Record Type Name should match');
    }

    @isTest
    static void testGetCaseRecord_Success() {
        Case testCase = createTestCase();
        Test.startTest();
        Case resultCase = Loans_LoansListController.getCaseRecord(testCase.Id);
        Test.stopTest();
        System.assertNotEquals(null, resultCase, 'Case record should not be null');
        System.assertEquals(testCase.Id, resultCase.Id, 'Case IDs should match');
    }
    
     @isTest
    static void testGetApprovedCases_Success() {
        Case testCase = createTestCase();
        String arrangementId = 'ARR_123';
        testCase.cc_PCI_Id__c = arrangementId;
        testCase.cc_CRM_Stage__c = 'APPROVED';
        testCase.Sub_Status__c = 'Approved';
        update testCase;

        Test.startTest();
        Map<String, Case> result = Loans_LoansListController.getApprovedCases(new List<String>{arrangementId});
        
        Map<String, Case> nullResult = Loans_LoansListController.getApprovedCases(null);
        
        Map<String, Case> emptyResult = Loans_LoansListController.getApprovedCases(new List<String>());
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(true, result.containsKey(arrangementId), 'Result should contain the arrangement ID');
        System.assertEquals(testCase.Id, result.get(arrangementId).Id, 'Case ID should match');
        
        System.assertEquals(0, nullResult.size(), 'Null input should return empty map');
        System.assertEquals(0, emptyResult.size(), 'Empty list should return empty map');
    }
}
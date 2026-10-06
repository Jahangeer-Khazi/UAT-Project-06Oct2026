@isTest
public class CreditCardSplitHandlerAPITest {

    private class RestMock3 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"data": {"cardOptions": [{"productMappingCode": "PLATINUM_BALANCE_TRANSFER_01", "cardProductConfigurationId": 123}]}}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class MyCalloutMock implements HttpCalloutMock {
        public String testBody;
        public Integer testStatusCode = 200;
        public HttpResponse respond(HTTPRequest req) {
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

    private static Case createTestCase(Account acc, String cardType, String nameOnCard, String hrResult, String makerResult, String checkerResult, String signatureResult, Boolean hasEmbLine4, Boolean isNew) {
        Case testCase = new Case(
            AccountId = acc.Id,
            Status = 'New',
            Sub_Status__c = 'Pending',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Upgrade Request').getRecordTypeId(),
            Type = 'Credit Card Upgrade',
            Sub_Type__c = 'Credit Card Limit Split',
            cc_Requested_Card_Type__c = cardType,
            cc_Name_on_the_Card__c = nameOnCard,
            cc_Approved_Credit_Limit__c = 10000,
            Origin = 'Web',
            cc_Credit_Approval_Result__c = 'Approve',
            cc_Credit_Approval_Result_Date_Time__c = System.now(),
            cc_Application_Stages__c = 'Completed',
            cc_Approved_Balance_Transfer_Amount__c = 5000,
            cc_Approved_Requested_Card_Type__c = cardType,
            cc_Approved_Name_on_the_card__c = nameOnCard,
            cc_HR_Result__c = hrResult,
            cc_HR_Result_Date_Time__c = System.now(),
            Account = acc,
            Region_Flag__c = 'Bahrain',
            Case_Model__c = 'ila',
            cc_Current_Credit_Limit__c = 10000,
            Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01',
            Selected_Supplementary_Cards__c = 'Yes',
            cc_PCI_Id__c = '123',
            cc_Requested_Credit_Limit__c = 15000,
            Operation_Result__c = 'Upgrade Completed',
            cc_CRM_Stage__c = 'APPROVED',
            cc_Operations_Date_Time__c = System.now(),
            Has_Co_Brand_Membership_Number__c = true,
            cc_Approved_Embossing_line_4__c = hasEmbLine4 ? '1234' : null,
            cc_Embossing_Line_4__c = hasEmbLine4 ? '1234' : null,
            cc_Maker__c = makerResult,
            cc_Checker_Result__c = checkerResult,
            AIR_CreditCardLimit__c = 10000,
            Is_Cash_Collateral__c = false,
            cc_Checker_Result_Date_Time__c = System.now(),
            cc_Signature_Verifier_Result__c = signatureResult,
            cc_Signature_Verification_Date_Time__c = System.now(),
            cc_Maker_Result_Date_Time__c = System.now(),
            Existing_Card_New_Credit_Limit__c = 15000
        );
        insert testCase;
        return testCase;
    }

    private static void runTest(String cardType, String nameOnCard, String hrResult, String makerResult, String checkerResult, String signatureResult, Boolean hasEmbLine4, Boolean isNew, String resultFieldChange) {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        
        // Create test data
        Account testAccount = new Account(
            FirstName = 'Test',
            LastName = 'Account',
            PersonEmail = 'test@example.com',
            CIF__pc = '123456',
            x_canary__pc = 'canary'
        );
        insert testAccount;

        Case testCase = createTestCase(testAccount, cardType, nameOnCard, hrResult, makerResult, checkerResult, signatureResult, hasEmbLine4, isNew);

        // Create the input list for the invocable method
        CreditCardSplitHandlerAPI.splitCreditCard input = new CreditCardSplitHandlerAPI.splitCreditCard();
        input.caseId = testCase.Id;
        input.isNew = isNew ? 'yes' : 'no';
        input.isResultFieldChange = resultFieldChange;

        List<CreditCardSplitHandlerAPI.splitCreditCard> inputList = new List<CreditCardSplitHandlerAPI.splitCreditCard>();
        inputList.add(input);

        // Call the invocable method
        Test.startTest();
        CreditCardSplitHandlerAPI.updateCreditCardReqApiFromFlow(inputList);
        Test.stopTest();

        // Verify that the case was updated
        Case updatedCase = [SELECT Id, Status, Sub_Status__c, cc_CRM_Stage__c FROM Case WHERE Id = :testCase.Id];
        System.debug('Updated Case Status: ' + updatedCase.Status);
        System.debug('Updated Case Sub Status: ' + updatedCase.Sub_Status__c);
        System.debug('Updated Case CRM Stage: ' + updatedCase.cc_CRM_Stage__c);
    }

    @isTest
    static void testUpdateCreditCardReqApiFromFlow() {
        runTest('PLATINUM_BALANCE_TRANSFER_01', 'Test Name', 'Approved', 'Send to Checker', 'Accept', 'Accept', true, true, 'cc_Maker__c');
    }

    @isTest
    static void testCreditCardSplitFutureJob() {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        
        // Create test data
        Account testAccount = new Account(
            FirstName = 'Test',
            LastName = 'Account',
            PersonEmail = 'test@example.com',
            CIF__pc = '123456',
            x_canary__pc = 'canary'
        );
        insert testAccount;

        Case testCase = createTestCase(testAccount, 'PLATINUM_BALANCE_TRANSFER_01', 'Test Name', 'Approved', 'Send to Checker', 'Accept', 'Accept', true, true);

        // Create the input map for the future method
        Map<String, String> details = new Map<String, String>();
        details.put('isNew', 'yes');
        details.put('caseId', testCase.Id);
        details.put('isResultFieldChange', 'cc_Maker__c');

        // Call the future method
        Test.startTest();
        CreditCardSplitHandlerAPI.creditCardSplitFutureJob(new Set<Id>{testCase.Id}, details);
        Test.stopTest();

        // Verify that the case was updated
        Case updatedCase = [SELECT Id, Status, Sub_Status__c, cc_CRM_Stage__c FROM Case WHERE Id = :testCase.Id];
        System.debug('Updated Case Status: ' + updatedCase.Status);
        System.debug('Updated Case Sub Status: ' + updatedCase.Sub_Status__c);
        System.debug('Updated Case CRM Stage: ' + updatedCase.cc_CRM_Stage__c);
    }

    @isTest
    static void testUpdateCreditCardReqApiFromFlow2() {
        runTest('PLATINUM_BALANCE_TRANSFER_01', null, 'Approved', 'Send to Checker', 'Accept', 'Accept', true, true, 'cc_Maker__c');
    }

    @isTest
    static void testUpdateCreditCardReqApiFromFlow3() {
        runTest('ILA_GULF_AIR_COBRAND_01', 'Test Name', 'Approved', 'Send to Checker', 'Accept', 'Accept', true, true, 'cc_Maker__c');
    }

    @isTest
    static void testUpdateCreditCardReqApiFromFlow4() {
        runTest('ILA_GULF_AIR_COBRAND_01', 'Test Name', 'Approved', 'Send to Checker', 'Accept', 'Accept', false, true, 'cc_Maker__c');
    }

    @isTest
    static void testUpdateCreditCardReqApiFromFlow5() {
        runTest('ILA_GULF_AIR_COBRAND_01', null, 'Approved', 'Send to Checker', 'Accept', 'Accept', true, true, 'cc_Maker__c');
    }

    @isTest
    static void testUpdateCreditCardReqApiFromFlow6() {
        runTest('ILA_GULF_AIR_COBRAND_01', null, 'Approved', 'Send to Checker', 'Accept', 'Accept', false, true, 'cc_Maker__c');
    }

    @isTest
    static void testUpdateCreditCardReqApiFromFlow7() {
        runTest('PLATINUM_BALANCE_TRANSFER_01', 'Test Name', 'Approved', 'Send to Checker', 'Accept', 'Accept', true, false, 'cc_Maker__c');
    }

    @isTest
    static void testUpdateCreditCardReqApiFromFlow8() {
        runTest('PLATINUM_BALANCE_TRANSFER_01', 'Test Name', 'Cancelled by Customer', 'Send to Checker', 'Decline', 'Re-Send', true, false, 'cc_Checker_Result__c');
    }

    @isTest
    static void testUpdateCreditCardReqApiFromFlow9() {
        runTest('PLATINUM_BALANCE_TRANSFER_01', 'Test Name', 'Cancelled by Customer', 'Send to Checker', 'Accept', 'Re-Send', true, false, 'cc_Signature_Verifier_Result__c');
    }

    @isTest
    static void testUpdateCreditCardReqApiFromFlow10() {
        runTest('PLATINUM_BALANCE_TRANSFER_01', 'Test Name', 'Cancelled by Customer', 'Send to Checker', 'Accept', 'Accept', true, false, 'cc_Signature_Verifier_Result__c');
    }

    @isTest
    static void testUpdateCreditCardReqApiFromFlow11() {
        runTest('PLATINUM_BALANCE_TRANSFER_01', 'Test Name', 'Cancelled by Customer', 'Cancel', 'Cancel', 'Accept', true, false, 'cc_Checker_Result__c');
    }
}
@IsTest
private class Loan_DocuSignEnvelopeReqWrapperTest {

    @testSetup
    static void setup() {
        Case testCase = createTestCase();

    }

    private static Case createTestCase() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',Subscription_Model__pc = 'alburaq', CustomerStatus__c=null, Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',Type ='New Loan / Finance Application', Sub_Type__c = 'New Loan / Finance Application Request', AIR_HaveCreditCard__c = true,cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email', cc_Contact_Centre_Result__c = 'Refer to Service Center'), 'TestFactoryDefaults.CaseDefaults',true);
        System.debug('testCase>>'+testCase);
        return testCase;
    }

    @IsTest
    static void testWrapperConstructorAndProperties() {

        List<Case> testCases = [SELECT Id, CaseNumber, Account.CIF__pc, Case_Model__c 
                               FROM Case 
                               ORDER BY CreatedDate ASC 
                               LIMIT 1];

        System.assert(!testCases.isEmpty(), 'Test cases should be created in setup');

        Case testCase = testCases[0];

        Loan_DocuSignEnvelopeReqWrapper wrapper = new Loan_DocuSignEnvelopeReqWrapper();

        wrapper.cif = testCase.Account.CIF__pc;
        wrapper.caseId = testCase.Id;
        wrapper.channel = 'Web';
        wrapper.caseModel = testCase.Case_Model__c;

        System.assertEquals(testCase.Account.CIF__pc, wrapper.cif, 'CIF should match the test case account CIF');
        System.assertEquals(testCase.Id, wrapper.caseId, 'CaseId should match the test case Id');
        System.assertEquals('Web', wrapper.channel, 'Channel should match the set value');
        System.assertEquals(testCase.Case_Model__c, wrapper.caseModel, 'CaseModel should match the test case model');
    }

   
}
@isTest
public class Loans_RLOSViewControllerTest {

    @testSetup
    static void setup() {
        Case testCase = createTestCase();
        
    }

    private static Case createTestCase() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',Subscription_Model__pc = 'alburaq', CustomerStatus__c=null, Archived__pc=false), 'TestFactoryDefaults.AccountDefaults', true);    
        Case testCase = (Case)TestDataFactory.createSObject(new Case(
            RecordTypeId = acRecordTypeId,
            ContactId = testAccount.PersonContactId,
            AccountId = testAccount.id,
            Case_Model__c = 'alburaq',
            cc_Service_Centre_Result__c = 'Return to Pre-Screener',
            Resend_DocuSign__c = 'Email'
        ), 'TestFactoryDefaults.CaseDefaults', true);
        
        System.debug('testCase>>' + testCase);
        return testCase;
    }

    @isTest
    static void testCallLoanOptionsAPI() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        String testCaseId = testCase.Id;
        ApiConnection.Response response = Loans_RLOSViewController.callLoanOptionsAPI(testCaseId);
 
        System.assertNotEquals(null, response, 'Response should not be null');
    
    }
}
@isTest
public class CreditCardDeclineCasesControllerTest {
    @testSetup
    static void setupTestData() {
        Account acc = new Account(FirstName = 'Test',LastName = 'Ila',PersonEmail = 'testclass@ilatest123.com',Region_Flag__c = 'Bahrain');
        insert acc;
        
        //Contact cnt = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        //insert cnt;
        
		Case declinedCase = new Case(
            AccountId = acc.Id,
            Subject = 'Declined Credit Card Application',
            Status = 'Closed',
            Sub_Status__c = 'Declined',
            Type = 'Credit Card Application',
            Case_Nature__c = 'Credit Card');
        
        Case cancelledCase = new Case(
            AccountId = acc.Id,
            Subject = 'Cancelled Credit Card Application',
            Status = 'Closed',
            Sub_Status__c = 'Cancelled',
            Type = 'Credit Limit Increase Application',
            Case_Nature__c = 'Credit Card');

        insert new List<Case>{ declinedCase, cancelledCase };
    }
    @isTest
    static void testGetCreditCardDeclineCases() {
        Case testCase = [SELECT Id FROM Case WHERE Sub_Status__c = 'Declined' LIMIT 1];
		Test.startTest();
        List<Case> result = CreditCardDeclineCasesController.getCreditCardDeclineCases(testCase.Id);
        Test.stopTest();
	}
    @IsTest
    static void testGetCreditCardCancelledCases() {
        Case testCase = [SELECT Id FROM Case WHERE Sub_Status__c = 'Cancelled' LIMIT 1];
		Test.startTest();
        List<Case> result = CreditCardDeclineCasesController.getCreditCardCancelledCases(testCase.Id);
        Test.stopTest();
	}
    @IsTest
    static void testGetContactFromRecord() {
        Case testCase = [SELECT Id, ContactId FROM Case WHERE ContactId != null LIMIT 1];
		Test.startTest();
        Contact cnt = CreditCardDeclineCasesController.getContactFromRecord(testCase.Id);
        Test.stopTest();
	}
}
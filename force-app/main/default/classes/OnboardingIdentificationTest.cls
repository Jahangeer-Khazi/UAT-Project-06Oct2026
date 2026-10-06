/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 11/12/2024
*       Change History: 
*/
@isTest
public class OnboardingIdentificationTest {
    @isTest
    static void testUpdateIdentificationFieldFromFlow() {
    // Create test data
        Account testAccount = new Account(
            					  FirstName = 'Test',
            					  LastName = 'User',
            					  ID_Validation_Status__pc = 'NOT_APPROVED',
            					  Nationality__pc = 'US',
            					  PersonEmail = 'test2@ilatest.com',
            					  Passport_Expiry_Date__pc = System.today().addDays(-1),
            					  Residency_Permit_Expiry__pc = System.today().addDays(-1),
            					  Place_of_Birth__pc = null
        					  );
        
    		insert testAccount;
                
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('On-Boarding').getRecordTypeId();

        Case testCase = new Case(
            AccountId = testAccount.Id,
            RecordTypeId = recordTypeId,
            Type = 'Identification',
            Region_Flag__c = 'Bahrain',
            Case_Model__c = 'ila',
            Sales_Call_Log__c = ''
        );
        insert testCase;
        
        // Create a list of UpdateIdentificationCaseField with the test Case Id
        OnboardingIdentification.UpdateIdentificationCaseField updateField = new OnboardingIdentification.UpdateIdentificationCaseField();
        updateField.caseId = testCase.Id;

        List<OnboardingIdentification.UpdateIdentificationCaseField> updateFields = new List<OnboardingIdentification.UpdateIdentificationCaseField>{updateField};

        // Call the method
        Test.startTest();
        OnboardingIdentification.updateIdentificationFieldFromFlow(updateFields);
        Test.stopTest();
    }

}
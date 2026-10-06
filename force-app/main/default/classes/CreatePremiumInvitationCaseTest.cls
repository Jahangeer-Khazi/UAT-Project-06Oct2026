@isTest
public class CreatePremiumInvitationCaseTest {
    @isTest
    static void testCreatePremiumCase() {
        // Create Account
        Account acc = new Account(
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId(),
            LastName = 'LastName new',
            PersonEmail = 'testAcc13@gmail.test',
            Mobile_Country_Code__pc = '973',
            PersonMobilePhone = '645383334000'
        );
        insert acc;
        
        Case testCase = CreatePremiumInvitationCase.createPremiumCase(acc);
    }
}
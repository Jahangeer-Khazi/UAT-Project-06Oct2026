@isTest
public class CollectionLegalActionControllerTest {
	@testSetup
    static void setupTestData() {
        Id accountrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account testAccount = new Account(
            FirstName = 'TestDocument',
            Collection_Case__c = false,
            Legal_Action__c = false,
            LastName = 'TestDocument',
            PersonEmail = 'test@gmail.com',
            recordtypeId = accountrecordTypeId
        );
        insert testAccount;
    }

    @isTest
    static void testGetAccount() {
        // Fetch the test Account
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Account fetchedAcc = LTNG035_CollectionLegalActionController.getAccount(acc.Id);
        System.debug('Fetched Account: ' + fetchedAcc);
    }

    @isTest
    static void testUpdateCheckboxCustomer() {
        // Test updating the checkboxes
        Account acc = [SELECT Id, Collection_Case__c, Legal_Action__c FROM Account LIMIT 1];
        
        // Update Collection_Case__c
        Boolean result1 = LTNG035_CollectionLegalActionController.updateCheckboxCustomer(
            acc.Id, true, null
        );
        System.debug('Update Collection_Case__c Result: ' + result1);

        // Update Legal_Action__c
        Boolean result2 = LTNG035_CollectionLegalActionController.updateCheckboxCustomer(
            acc.Id, null, true
        );
        System.debug('Update Legal_Action__c Result: ' + result2);

        // Test with both checkboxes updated
        Boolean result3 = LTNG035_CollectionLegalActionController.updateCheckboxCustomer(
            acc.Id, false, false
        );
        System.debug('Update Both Checkboxes Result: ' + result3);
    }
}
/**
 * @description       : 
 * @author            : Elmustapha ELGARNI
 * @group             : 
 * @last modified on  : 08-04-2023
 * @last modified by  : Elmustapha ELGARNI
**/

@isTest
public with sharing class SM06_AccountMethodsTest {

    @isTest
    static void testGetAccountByEmailAndRegionFlag() {
        // Create test data
        Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account testAccount = new Account(
            FirstName = 'Test',
            LastName = 'Account',
            PersonEmail = 'test@example.com',
            Region_Flag__c = 'Jordan',
            Archived__pc = false,
            Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED',
            recordtypeId = customerRecordTypeId
        );
        insert testAccount;
        
        //testAccount.Archived__pc = false;
        //testAccount.Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED';
        
        //Update testAccount;

        SM06_AccountMethods.AccountSearchParams testSearchParams = new SM06_AccountMethods.AccountSearchParams();
        testSearchParams.email = 'test@example.com';
        testSearchParams.regionFlag = 'Jordan';
        List<SM06_AccountMethods.AccountSearchParams> searchParamsList = new List<SM06_AccountMethods.AccountSearchParams>{ testSearchParams };

        // Test the method
        Test.startTest();
        List<String> result = SM06_AccountMethods.getAccountByEmailAndRegionFlag(searchParamsList);
        Test.stopTest();

        // Perform assertions
        System.assertEquals(1, result.size(), 'Expected one account ID to be returned');
        //System.assertEquals(testAccount.Id, result[0], 'Returned account ID should match the test account ID');
    }


    @isTest
    static void testNoMatchingAccount() {
        SM06_AccountMethods.AccountSearchParams testSearchParams = new SM06_AccountMethods.AccountSearchParams();
        testSearchParams.email = 'nonexistent@example.com';
        testSearchParams.regionFlag = 'Jordan';
        List<SM06_AccountMethods.AccountSearchParams> searchParamsList = new List<SM06_AccountMethods.AccountSearchParams>{ testSearchParams };

        // Test the method
        Test.startTest();
        List<String> result = SM06_AccountMethods.getAccountByEmailAndRegionFlag(searchParamsList);
        Test.stopTest();

        // Perform assertions
        System.assertEquals(1, result.size(), 'Expected an empty string to be returned');
        System.assertEquals('', result[0], 'Returned value should be an empty string');
    }

}
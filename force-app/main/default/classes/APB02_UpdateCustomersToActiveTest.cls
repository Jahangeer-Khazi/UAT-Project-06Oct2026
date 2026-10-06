@isTest
public with sharing class APB02_UpdateCustomersToActiveTest {

    @testSetup static void setupMethode() {
        Account acc1 = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',Archived__pc = false,Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED' ), 'TestFactoryDefaults.AccountDefaults',true);
        acc1.CustomerStatus__c = null;
        update acc1; 
    }

    @isTest public static void batchTest(){
        Test.startTest();
            APB02_UpdateCustomersToActive crn= new APB02_UpdateCustomersToActive();
            Id jobId = Database.executeBatch(crn,200);
        Test.stopTest();
    }

}
/*
* @author Hamza CHAOUI
 * @date Création 30-05-2022

 * @description :test  batch class that modify the new field subscription model to ila 
Version History :

*/
@isTest
public with sharing class APB03_UpdateToIlaModelCustomersTest {
    @testSetup static void setupMethode() {
        Account acc1 = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',Subscription_Model__pc=null,Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
    }

    @isTest public static void batchTest(){
        Test.startTest();
        APB03_UpdateToIlaModelForAllCustomers crn= new APB03_UpdateToIlaModelForAllCustomers();
            Id jobId = Database.executeBatch(crn,200);
        Test.stopTest();
    }
}
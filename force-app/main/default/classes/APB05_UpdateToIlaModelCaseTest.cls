/*
* @author Hamza CHAOUI
 * @date Création 20-05-2022

 * @description : test batch class that modify the new field case model to ila 
Version History :

*/
@isTest
public with sharing class APB05_UpdateToIlaModelCaseTest {
    @testSetup static void setupMethode() {
        Case case1 = (Case)TestDataFactory.createSObject(new Case(Case_Model__c=null,Status = 'Closed'), 'TestFactoryDefaults.CaseDefaults',true);
    }

    @isTest public static void batchTest(){
        Test.startTest();
        APB05_UpdateToIlaModelCase crn= new APB05_UpdateToIlaModelCase();
            Id jobId = Database.executeBatch(crn,200);
        Test.stopTest();
    }
}
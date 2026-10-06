/**
 * @author Aniss Mbarki
 * @date Création 07/05/2024
 * @date Modification
 * 
 */
@isTest
public with sharing class CivilServiceIntegrationApiTest {
  
    @testSetup static void setupMethode() {
        Id suppRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card_Supplementary').getRecordTypeId() ;
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',Region_Flag__pc='Jordan'), 'TestFactoryDefaults.AccountDefaults',true);
        Case caseObj = (Case)TestDataFactory.createSObject(new Case( 
        Region_Flag__c='Jordan',
        Case_Model__c = 'ila',
        ContactId = acc1.PersonContactId,
        AccountId = acc1.id,
        //Type='Credit Card Supplementary Application',
        sc_Card_Holder_ID_Number__c = '123',
        RecordTypeId = suppRecordTypeId), 'TestFactoryDefaults.CaseDefaults',true);
     
    }

    @isTest
    public static void civilServiceIntegApiFromFlowTest(){
        List<Id> caseIds = new List<Id>();
        caseIds.add( [SELECT Id FROM Case LIMIT 1].Id );
        test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            CivilServiceIntegrationApi.civilServiceIntegApiFromFlow(caseIds);
        test.stopTest();
    }

    @isTest
    public static void otherFctsTest(){
        List<Id> caseIds = new List<Id>();
        caseIds.add( [SELECT Id FROM Case LIMIT 1].Id );
        List<Case> cases = new List<Case>();
        if (caseIds != null && caseIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc FROM Case WHERE Id IN :caseIds';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
            Boolean tt = CivilServiceIntegrationApi.validateSuppCardFields(cases.get(0));
            String numest = CivilServiceIntegrationApi.enterIdNumberButton(caseIds.get(0),'123456',null);
        }
    }

}
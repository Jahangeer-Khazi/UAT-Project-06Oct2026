/**
 * @author Aniss Mbarki
 * @date Création 01/08/2022
 * @date Modification
 * 
 */
@IsTest
public with sharing class LTNG25_NewPrepaidCardControllerTest {
    @testSetup static void setupMethode() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ppc_Prepaid_Card').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case( 
        Region_Flag__c='Bahrain',
        Case_Model__c = 'ila',
        ContactId = acc1.PersonContactId,
        AccountId = acc1.id,
        Type='Credit Card Prepaid Application',
        RecordTypeId = acRecordTypeId), 'TestFactoryDefaults.CaseDefaults',true); 
    }
    @isTest
    public static void getPrepaidCardCaseRecordTypeTest(){  
        test.startTest();
        Id recordTypeId=LTNG25_NewPrepaidCardController.getPrepaidCardCaseRecordType();
        System.assert(recordTypeId != null);
        test.stopTest();
       
    }
    @isTest
    public static void getPrepaidCardConfigViaApiTest(){  
        Case caseObj = [SELECT Id,Case_Model__c,AccountId FROM Case LIMIT 1 ];
        String accpuntId=caseObj.AccountId;
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            Object prepaidCard = LTNG25_NewPrepaidCardController.getPrepaidCardConfigViaApi(caseObj.AccountId,caseObj.Case_Model__c);
            System.assert(prepaidCard != null);
         Test.stopTest();
       
    }

    @isTest
    public static void approvePrepaidCardApiTest(){  
        Case caseObj = [SELECT Id,Case_Model__c,AccountId FROM Case LIMIT 1 ];
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 500;
            LTNG25_NewPrepaidCardController.approvePrepaidCardApi(caseObj.Id);
         Test.stopTest();
       
    }
}
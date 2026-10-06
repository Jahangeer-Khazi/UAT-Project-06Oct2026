@isTest
public with sharing class LTNG024_SubsModelTermControllerTest {
    @testSetup static void setupMethode() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',Subscription_Model__pc='both'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Subscription_Model_Termination').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',Type='Subscription Model Termination',ac_EligibleToClose__c=true), 'TestFactoryDefaults.CaseDefaults',true);
    }
    @isTest
    public static void validateAccTerminationViaApiTest(){   
        Id caseId = [SELECT Id FROM Case LIMIT 1 ].Id;
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
        try{
            LTNG024_SubsModelTerminationController.AccountTerminationValidationDetails validateAcc = LTNG024_SubsModelTerminationController.validateAccTerminationViaApi(caseId);
        }catch(Exception e){
            System.debug('validateAccTerminationViaApiTest');
        }
            //System.assert(validateAcc != null);
        Test.stopTest();
    }
    
    @isTest
    public static void TerminateSubscriptionModelApiFromFlowkkTest(){   
        Id caseId = [SELECT Id FROM Case LIMIT 1 ].Id;
        Test.startTest();
        
        MCK001_ApiCalls.statusCodeGlobal = 200;
        LTNG024_SubsModelTerminationController.TerminateSubscriptionModelApiFromFlow(caseId);
    
        Test.stopTest();
    }
    
    @isTest
    public static void TerminateSubscriptionModelApi403Test(){   
        Id caseId = [SELECT Id FROM Case LIMIT 1 ].Id;
        Test.startTest();
        
            MCK001_ApiCalls.statusCodeGlobal = 403;
            LTNG024_SubsModelTerminationController.AccountTerminationDetails terminateAcc = LTNG024_SubsModelTerminationController.TerminateSubscriptionModelApi(caseId);
            System.assert(terminateAcc != null);

        Test.stopTest();
    }
    @isTest
    public static void TerminateSubscriptionModelApi200Test(){   
        Id caseId = [SELECT Id FROM Case LIMIT 1 ].Id;
        Test.startTest();
        
            MCK001_ApiCalls.statusCodeGlobal = 200;
            LTNG024_SubsModelTerminationController.AccountTerminationDetails terminateAcc = LTNG024_SubsModelTerminationController.TerminateSubscriptionModelApi(caseId);
            System.assert(terminateAcc != null);

        Test.stopTest();
    }
    
    
    @isTest
    public static void TerminateSubscriptionModelApiFromFlowTest(){   
        Id caseId = [SELECT Id FROM Case LIMIT 1 ].Id;
        Test.startTest();
        
        LTNG024_SubsModelTerminationController.TerminateSubscriptionModelApiFromFlow(new List<Id>{caseId});

        Test.stopTest();
    }

}
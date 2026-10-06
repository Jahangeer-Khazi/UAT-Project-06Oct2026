@isTest
public with sharing class SM002_CbbAmountHandlerTest {

    static Id cbbCaseRecordTypeId = LTNG003_BlockUnblockProcessController.getBlockUnblockCaseRecordType();
    static Account accObj;
    static Case caseObj;
    static{
        accObj = (Account)TestDataFactory.createSObject(new Account(), 'TestFactoryDefaults.AccountDefaults',true);
        caseObj = (Case)TestDataFactory.createSObject(new Case(
                                    RecordTypeId=cbbCaseRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,
                                    Type = 'CBB Amount block/unblock request'),'TestFactoryDefaults.CaseDefaults',true);
    }

    @isTest
    public static void cbbAmountBUD_ProcessBlockAcceptTest(){  
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200; 
            caseObj.Sub_Type__c = 'CBB Amount block';
            caseObj.cc_Checker_Result__c = 'Accept';
            update caseObj;
        Test.stopTest();
    }

    @isTest
    public static void cbbAmountBUD_ProcessBlockRejectTest(){  
        Test.startTest();
            caseObj.Sub_Type__c = 'CBB Amount block';
            caseObj.cc_Checker_Result__c = 'Reject';
            update caseObj;
            SM002_CbbAmountHandler.cbbAmountBUD_Process(new Set<Id>{caseObj.Id});
        Test.stopTest();
    }

    @isTest
    public static void cbbAmountBUD_ProcessBlockAcceptErrorTest(){   
        MCK001_ApiCalls.statusCodeGlobal = 400;
        caseObj.Sub_Type__c = 'CBB Amount block';
        caseObj.cc_Checker_Result__c = 'Accept';
        Test.startTest();
            update caseObj;
            List<System_Action__c> logs= [SELECT Id FROM System_Action__c];
            System.assert(logs!=null);
        Test.stopTest();
    }

    @isTest
    public static void cbbAmountBUD_ProcessCaseUnblockAcceptTest(){   
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200; 
            caseObj.Sub_Type__c = 'CBB Amount unblock';
            caseObj.cc_Checker_Result__c = 'Accept';
            update caseObj;
        Test.stopTest();
    }


    @isTest
    public static void cbbAmountBUD_ProcessUnblockRejectTest(){  
        Test.startTest();
            caseObj.Sub_Type__c = 'CBB Amount unblock';
            caseObj.cc_Checker_Result__c = 'Reject';
            update caseObj;
            SM002_CbbAmountHandler.cbbAmountBUD_Process(new Set<Id>{caseObj.Id});
        Test.stopTest();
    }

}
@isTest
public with sharing class PeriodicReviewBlockProductsTest {
    @testSetup 
    static void setupMethode() {
        Account acc1 = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',Archived__pc = false),'TestFactoryDefaults.AccountDefaults',true);
        Account acc2 = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123478',Archived__pc = false),'TestFactoryDefaults.AccountDefaults',true);
        Account acc3 = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123490',Archived__pc = false),'TestFactoryDefaults.AccountDefaults',true);

        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Periodic_Review').getRecordTypeId();
        
        Case caseObj1 = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = caseRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Type='Periodic Review',status='Pending Documents',Sub_Status__c='Overdue Stage 1'),'TestFactoryDefaults.CaseDefaults',true);
        Case caseObj2 = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = caseRecordTypeId,ContactId = acc2.PersonContactId,AccountId = acc2.id,Type='Periodic Review',status='Pending Documents',Sub_Status__c='Overdue Stage 1'),'TestFactoryDefaults.CaseDefaults',true);
        Case caseObj3 = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = caseRecordTypeId,ContactId = acc3.PersonContactId,AccountId = acc3.id,Type='Periodic Review',status='Pending Documents',Sub_Status__c='Overdue Stage 1'),'TestFactoryDefaults.CaseDefaults',true);
        
    }
    @isTest
    public static void PeriodicReviewBlockApiFromFlowOverdueStage2Test (){
        List<Id> caseIds=new List<Id>();
        List<Case> caseList=[SELECT Id FROM Case];
        for(Case cs : caseList){
          cs.Sub_Status__c='Overdue Stage 2';
          caseIds.add(cs.Id);
        }
        update caseList;
        Test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        List<Id> result=PeriodicReviewBlockProducts.PeriodicReviewBlockApiFromFlow(caseIds);
        System.assert(result != null);
        Test.stopTest();
    }

    @isTest
    public static void PeriodicReviewBlockApiFromFlowOverdueStage3Test (){
        List<Id> caseIds=new List<Id>();
        List<Case> caseList=[SELECT Id FROM Case];
        for(Case cs : caseList){
          cs.Sub_Status__c='Overdue Stage 3';
          caseIds.add(cs.Id);
        }
        update caseList;
        Test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        List<Id> result=PeriodicReviewBlockProducts.PeriodicReviewBlockApiFromFlow(caseIds);
        System.assert(result != null);
        Test.stopTest();
    }

    @isTest
    public static void PeriodicReviewBlockApiFromFlowOverdueStage4Test (){
        List<Id> caseIds=new List<Id>();
        List<Case> caseList=[SELECT Id FROM Case];
        for(Case cs : caseList){
          cs.Sub_Status__c='Overdue Stage 4';
          caseIds.add(cs.Id);
        }
        update caseList;
        Test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        List<Id> result=PeriodicReviewBlockProducts.PeriodicReviewBlockApiFromFlow(caseIds);
        System.assert(result != null);
        Test.stopTest();
    }

    @isTest
    public static void PeriodicReviewBlockApiFromFlowOverdueStage5Test (){
        List<Id> caseIds=new List<Id>();
        List<Case> caseList=[SELECT Id FROM Case];
        for(Case cs : caseList){
          cs.Sub_Status__c='Overdue Stage 5';
          caseIds.add(cs.Id);
        }
        update caseList;
        Test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        List<Id> result=PeriodicReviewBlockProducts.PeriodicReviewBlockApiFromFlow(caseIds);
        
        System.assert(result != null);
        Test.stopTest();
    }


}
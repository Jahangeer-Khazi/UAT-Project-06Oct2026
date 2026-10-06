@isTest
public with sharing class cc_CommentCleaningTest {

    @testSetup static void setupMethode() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123496', Region_Flag__c='Jordan', Region_Flag__pc='Jordan'), 'TestFactoryDefaults.AccountDefaults',true);
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case( 
        Region_Flag__c='Jordan',
        Case_Model__c = 'ila',
        ContactId = acc1.PersonContactId,
        AccountId = acc1.id,
        Type='Credit Card Application',
        cc_CPR_Number__c='Y6668',
        sc_Card_Holder_Jordan_ID_Number__c='12356789',
        cc_CPR_Expiry_Date__c= Date.newInstance(2026, 12, 9),
        cc_Passport_Number__c='Y6668',
        cc_Passport_Expiry_Date__c=Date.newInstance(2026, 12, 9),
        cc_Residence_Permit_No__c ='Y6668',
        cc_Residence_Permit_Expiry_Date__c=Date.newInstance(2026, 12, 9),
        RecordTypeId = acRecordTypeId), 'TestFactoryDefaults.CaseDefaults',false);
		
        insert caseObj;
    }

    @isTest
    public static void commentCleaningFromFlow_Test(){  
        List<Case> cases = new List<Case>();
        String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
        String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.x_canary__pc,Account.Region_Flag__pc FROM Case LIMIT 1';
        cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        cases.get(0).cc_HR_Comments__c = 'Test field';
        cc_CommentCleaning.commentCleaningFromFlow(cases);
        List<CaseComment> cmn= [SELECT Id FROM CaseComment];
        System.assert(cmn!=null);
    }

}
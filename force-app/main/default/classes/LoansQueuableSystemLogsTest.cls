@isTest
public class LoansQueuableSystemLogsTest {
	
    
    @isTest
    static void testLoansQueuableLogs() {

        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
        Account accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',Subscription_Model__pc = 'alburaq',CustomerStatus__c=null,Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id, Case_Model__c = 'alburaq',Type = 'New Loan / Finance Application',Sub_Type__c = 'New Loan / Finance Application Request',Region_Flag__c = 'Bahrain',cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email', cc_Contact_Centre_Result__c = 'Documents Uploaded'), 'TestFactoryDefaults.CaseDefaults',true);
        
        List<System_Action__c> lstSystemActions = new List<System_Action__c>();
        
        System_Action__c obj1 = new System_Action__c();
        obj1.Account__c = accObj.Id;
        obj1.Case__c = caseObj.Id;
        obj1.Account_Number__c  = '2342342342';
        obj1.Type__c = 'Credit Card';
        obj1.Action__c = 'EDD';
        lstSystemActions.add(obj1);
        
        Test.startTest();
        LoansQueuableSystemLogs qa = new LoansQueuableSystemLogs(lstSystemActions);
        qa.execute(null);
        Test.stopTest();
        
        List<System_Action__c> newRecords = [Select Id FROM System_Action__c LIMIT 1];
        System.assertEquals(newRecords.isEmpty(),false,'System Action records not created.');
    }
}
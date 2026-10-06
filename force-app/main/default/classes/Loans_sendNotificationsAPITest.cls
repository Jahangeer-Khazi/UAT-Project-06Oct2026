@isTest
public class Loans_sendNotificationsAPITest {

    @testSetup
    static void setup() {
    	Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',Subscription_Model__pc = 'alburaq',CustomerStatus__c=null,Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',Type = 'New Loan / Finance Application',Sub_Type__c = 'New Loan / Finance Application Request',Region_Flag__c = 'Bahrain',cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email', cc_Contact_Centre_Result__c = 'Documents Uploaded'), 'TestFactoryDefaults.CaseDefaults',true);
        
        CaseAnnex__c testRecord = new CaseAnnex__c(Case__c = testCase.Id);
        insert testRecord;
    }
    
    @isTest
    static void testLoanNotification(){
        Case objCase = [SELECT Id,Status,Sub_Status__c FROM Case LIMIT 1];
        
        objCase.Status = 'Closed';
        objCase.Sub_Status__c = 'Closed';
        update objCase;   
            
        Loans_sendNotificationsAPI.NotificationWrapper input = new Loans_sendNotificationsAPI.NotificationWrapper();
        input.caseId = objCase.Id;
        input.isNew = 'no';
        input.templateCode = 'PL_REQUEST_UPLOADDOCS';
        input.notifiCationType = 'sms';

        List<Loans_sendNotificationsAPI.NotificationWrapper> inputs = new List<Loans_sendNotificationsAPI.NotificationWrapper>{input};

        Test.startTest();
        List<String> result = Loans_sendNotificationsAPI.triggerNotificationFromFlow(inputs);
        Test.stopTest();
    }
}
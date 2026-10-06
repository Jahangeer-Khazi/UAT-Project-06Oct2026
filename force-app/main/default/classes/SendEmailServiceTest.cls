@isTest
public class SendEmailServiceTest {

    @testSetup
    static void setup() {
    	Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',Subscription_Model__pc = 'alburaq',CustomerStatus__c=null,Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',Type = 'New Loan / Finance Service Request',Sub_Type__c = 'Top-up',Region_Flag__c = 'Bahrain'), 'TestFactoryDefaults.CaseDefaults',true);
        
        CaseAnnex__c testRecord = new CaseAnnex__c(Case__c = testCase.Id);
        insert testRecord;
        testCase.CaseAnnex__c = testRecord.Id;
        update testCase;
        
    }
    
    @isTest 
    static void testSendEmailService(){
    	Case objCase = [SELECT Id,ContactId,Status,Sub_Status__c, CaseAnnex__c FROM Case LIMIT 1];
        System.debug('objcase >> ' + objCase.Id + ' ... '+ objCase.CaseAnnex__c);
        
        SendEmailService.EmailParamsWrapper input = new SendEmailService.EmailParamsWrapper();
        input.caseId = objCase.Id;
        input.EmailTemplateDeveloperName = 'ILA_PL_UPLOADDOCS_SLT'; 
        input.recipient = objCase.ContactId;
        input.FromOrgWideAddress = 'donotreply@ilabank.com';
        input.AdditionalEmails = new List<String>{'test@test.com'};

        List<SendEmailService.EmailParamsWrapper> inputs = new List<SendEmailService.EmailParamsWrapper>{input};

        Test.startTest();
        List<String> result = SendEmailService.SendEmailFromTemplate(inputs);
        Test.stopTest();
    }

    @isTest
    static void test_CC_sendEmailWithAtachementsMethod() {
        String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
        String soqlQuery = 'SELECT ' + fields + ',Account.PersonContactId,Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.x_canary__pc FROM Case LIMIT 1';
        List<Case> cases = new List<Case>((List<Case>)Database.query(soqlQuery));

        Test.startTest();
            SendEmailService.CC_sendEmailWithAtachements(cases.get(0),'ILA_CreditCard_Send_SignedDocs',System.Label.CreditCard_DocuSignFilesKeywords.split(';'));
        Test.stopTest();
    }
}
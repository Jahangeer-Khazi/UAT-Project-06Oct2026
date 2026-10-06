@isTest
private class Loans_SendEmailWithAttachments_Test {

    @testSetup
    static void setup() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',Subscription_Model__pc = 'alburaq',CustomerStatus__c=null,Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',Type = 'New Loan / Finance Application',Sub_Type__c = 'New Loan / Finance Application Request',Region_Flag__c = 'Bahrain',cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email', cc_Contact_Centre_Result__c = 'Documents Uploaded'), 'TestFactoryDefaults.CaseDefaults',true);
        
        CaseAnnex__c testRecord = new CaseAnnex__c(Case__c = testCase.Id);
        insert testRecord;
        
        System.debug('testCase>>'+testCase);
		//
		//
        EmailTemplate testTemplate = [SELECT Id, DeveloperName  FROM EmailTemplate LIMIT 1 ];

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test data'),
            IsMajorVersion = true
        );
        insert contentVersion;

        ContentDocumentLink contentDocLink = new ContentDocumentLink(
            LinkedEntityId = testCase.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId,
            ShareType = 'V'
        );
        insert contentDocLink;
    }

    @isTest
    static void testSendEmailWithAttachmentsMethod() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        EmailTemplate testTemplate = [SELECT DeveloperName FROM EmailTemplate LIMIT 1];
        ContentDocumentLink testContentDocumentLink = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :testCase.Id LIMIT 1];

        Loans_SendEmailWithAttachements.FlowInputs input = new Loans_SendEmailWithAttachements.FlowInputs();
        input.caseId = testCase.Id;
        input.templateDeveloperName = testTemplate.DeveloperName;
        input.keywords = 'Test';

        List<Loans_SendEmailWithAttachements.FlowInputs> inputs = new List<Loans_SendEmailWithAttachements.FlowInputs>{input};

        Test.startTest();
        List<String> result = Loans_SendEmailWithAttachements.sendEmailWithAttachmentsMethod(inputs);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Expected one case Id in result');
        System.assertEquals(testCase.Id, result[0], 'Expected case Id to match input');
        
    }
}
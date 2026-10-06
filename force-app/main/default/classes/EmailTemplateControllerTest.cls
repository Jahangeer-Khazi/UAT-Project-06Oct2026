@isTest
private class EmailTemplateControllerTest {
    
    // Helper method to create email templates in System.runAs context
    private static void createEmailTemplates() {
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p1.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser1990@testorg.com');
        insert u1;
        
        System.runAs(u1) {
            // Find an existing email folder
            List<Folder> existingFolders = [SELECT Id FROM Folder WHERE Type = 'Email' AND DeveloperName = 'Static_Templates' LIMIT 1];
            
            if(existingFolders.isEmpty()) {
                existingFolders = [SELECT Id FROM Folder WHERE Type = 'Email' LIMIT 1];
            }
            
            if(!existingFolders.isEmpty()) {
                // Create test email templates
                EmailTemplate htmlTemplate = new EmailTemplate(
                    Name = 'Test HTML Template',
                    DeveloperName = 'Test_HTML_Template_Sample',
                    TemplateType = 'custom',
                    Subject = 'Test Subject',
                    HtmlValue = '<html><body>Hello {!Case.Current_First_Name__c}</body></html>',
                    Body = 'Hello {!Case.Current_First_Name__c}',
                    FolderId = existingFolders[0].Id,
                    UiType = 'Aloha'
                );
                insert htmlTemplate;
            }
        }
    }
    
    @TestSetup
    static void setupNonSetupObjects() {
        // Setup all non-setup objects first (Accounts, Cases, etc.)
        Account acc = new Account(
            FirstName = 'Test2',
            LastName = 'Class2',
            PersonEmail = 'test@example.com',
            ID_Number__pc = '851000000',
            Nationality__pc = 'BH',
            PersonMailingCity = 'Muharraq',
            PersonMailingCountry = 'BH',
            PersonMailingState = 'Muharraq',
            PersonMailingStreet = 'Villa 2 Bldg 111 Road 222',
            PersonMailingPostalCode = '455'
        );
        insert acc;
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Request').getRecordTypeId();
        
        Case regularCase = new Case(
            RecordTypeId = caseRecordTypeId,
            AccountId = acc.Id,
            Case_Model__c = 'ila',
            Type = 'Account',
            Sub_Type__c = 'Profile Update',
            CC_Request_Type__c = 'Email',
            Previous_Email__c = 'old@example.com'
        );
        insert regularCase;
        
        Case dormantCase = new Case(
            RecordTypeId = caseRecordTypeId,
            AccountId = acc.Id,
            Case_Model__c = 'ila',
            Type = 'Account',
            Sub_Type__c = 'Dormant',
            CC_Request_Type__c = 'Reactivation'
        );
        insert dormantCase;
        
        insert new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
    }
    
    @isTest 
    static void testGetTemplatesFromSampleFolder() {
        createEmailTemplates();
        Test.startTest();
        List<EmailTemplate> templates = EmailTemplateController.getTemplatesFromSampleFolder();
        Test.stopTest();
    }
    
    @isTest
    static void testGetCaseDetailsAndTemplates() {
        createEmailTemplates();
        Case testCase = [SELECT Id FROM Case WHERE Sub_Type__c = 'Profile Update' LIMIT 1];
        
        Test.startTest();
        Map<String, Object> result = EmailTemplateController.getCaseDetailsAndTemplates(testCase.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testSendEmailWithAttachment() {
        createEmailTemplates();
        
        Case testCase = [SELECT Id FROM Case WHERE Sub_Type__c = 'Profile Update' LIMIT 1];
        EmailTemplate template = [SELECT Id FROM EmailTemplate LIMIT 1];
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1];
        
        Test.startTest();
        EmailTemplateController.sendEmailWithAttachment(
            template.Id,
            testCase.Id,
            cv.ContentDocumentId,
            'test@example.com',
            'support@ilabank.com',
            'Test Subject'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testSendEmailWithPreviousEmail() {
        createEmailTemplates();
        Case testCase = [SELECT Id FROM Case WHERE Sub_Type__c = 'Profile Update' LIMIT 1];
        EmailTemplate template = [SELECT Id FROM EmailTemplate LIMIT 1];
        
        Test.startTest();
        EmailTemplateController.sendEmailWithAttachment(
            template.Id,
            testCase.Id,
            null,
            'test@example.com',
            'support@ilabank.com',
            'Test Subject'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testSendEmailWithDormantCase() {
        createEmailTemplates();
        
        Case testCase = [SELECT Id FROM Case WHERE Sub_Type__c = 'Dormant' LIMIT 1];
        EmailTemplate template = [SELECT Id FROM EmailTemplate LIMIT 1];
        
        Test.startTest();
        EmailTemplateController.sendEmailWithAttachment(
            template.Id,
            testCase.Id,
            null,
            'test@example.com',
            'support@ilabank.com',
            'Test Subject'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testProcessMergeFields() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        String processedHtml = EmailTemplateController.processMergeFields(
            'Hello {!Case.Current_First_Name__c}', 
            testCase.Id
        );
        Test.stopTest();
    }
    
    @isTest
    static void testGetLogoHtml() {
        Test.startTest();
        String ilaLogo = EmailTemplateController.getLogoHtml('ila');
        String alburaqLogo = EmailTemplateController.getLogoHtml('alburaq');
        String emptyLogo = EmailTemplateController.getLogoHtml('invalid');
        Test.stopTest();
    }
    
    @isTest
    static void testCheckFileSizeAndDelete() {
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1];
        
        Test.startTest();
        EmailTemplateController.FileSizeResult result = EmailTemplateController.checkFileSizeAndDelete(
            cv.ContentDocumentId, 
            5000000
        );
        Test.stopTest();
    }
    
    @isTest
    static void testCheckLargeFileSizeAndDelete() {
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1];
        
        Test.startTest();
        EmailTemplateController.FileSizeResult result = EmailTemplateController.checkFileSizeAndDelete(
            cv.ContentDocumentId, 
            5
        );
        Test.stopTest();
    }
    
    @isTest
    static void testSendEmailWithException() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        try {
            EmailTemplateController.sendEmailWithAttachment(
                null,
                testCase.Id,
                null,
                'test@example.com',
                'support@ilabank.com',
                'Test Subject'
            );
        } catch(Exception e) {
            System.assert(e instanceof AuraHandledException);
        }
        Test.stopTest();
    }
}
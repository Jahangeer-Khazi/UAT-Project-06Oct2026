@isTest
private class EmailTemplatePreviewControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test account and case first
        Account acc1 = (Account)TestDataFactory.createSObject(
            new Account(CIF__pc='1293779'), 
            'TestFactoryDefaults.AccountDefaults',
            true
        );
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Issue').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(
            new Case(
                RecordTypeId = acRecordTypeId,
                ContactId = acc1.PersonContactId,
                AccountId = acc1.id,
                Case_Model__c='ila'
            ), 
            'TestFactoryDefaults.CaseDefaults',
            true
        );
    }
    
    // Separate method to create email templates (setup objects)
    static void createEmailTemplates() {
        // Create test email templates
        EmailTemplate htmlTemplate = new EmailTemplate(
            Name = 'Test HTML Template',
            DeveloperName = 'Test_HTML_Template',
            TemplateType = 'custom',
            Subject = 'Test Subject',
            HtmlValue = '<html><body>Hello {!Case.Current_First_Name__c}</body></html>',
            Body = 'Hello {!Case.Current_First_Name__c}',
            FolderId = UserInfo.getUserId() // Using user folder for test
        );
        insert htmlTemplate;
        
        EmailTemplate textTemplate = new EmailTemplate(
            Name = 'Test Text Template',
            DeveloperName = 'Test_Text_Template',
            TemplateType = 'custom',
            Subject = 'Test Subject',
            Body = 'Hello {!Case.Current_First_Name__c}',
            FolderId = UserInfo.getUserId() // Using user folder for test
        );
        insert textTemplate;
    }
    
    @isTest 
    static void testHtmlTemplateWithIlaCase() {
        // Create templates in a separate transaction
        createEmailTemplates();
        
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Test_HTML_Template' LIMIT 1];
        Case testCase = [SELECT Id FROM Case WHERE Case_Model__c = 'ila' LIMIT 1];
        
        Test.setCurrentPage(Page.EmailTemplatePreview);
        ApexPages.currentPage().getParameters().put('id', template.Id);
        ApexPages.currentPage().getParameters().put('caseId', testCase.Id);
        
        Test.startTest();
        EmailTemplatePreviewController controller = new EmailTemplatePreviewController();
        String processedBody = controller.processMergeFields(controller.templateBody);
        Test.stopTest();
    }
    
    @isTest
    static void testTemplateWithNoCase() {
        // Create templates in a separate transaction
        createEmailTemplates();
        
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Test_HTML_Template' LIMIT 1];
        
        Test.setCurrentPage(Page.EmailTemplatePreview);
        ApexPages.currentPage().getParameters().put('id', template.Id);
        
        Test.startTest();
        EmailTemplatePreviewController controller = new EmailTemplatePreviewController();
        String processedBody = controller.processMergeFields(controller.templateBody);
        Test.stopTest();
    }
    
    @isTest
    static void testNoTemplateId() {
        Test.setCurrentPage(Page.EmailTemplatePreview);
        
        Test.startTest();
        EmailTemplatePreviewController controller = new EmailTemplatePreviewController();
        Test.stopTest();
    }
    
    @isTest
    static void testProcessMergeFieldsWithException() {
        // Create templates in a separate transaction
        createEmailTemplates();
        
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Test_HTML_Template' LIMIT 1];
        
        Test.setCurrentPage(Page.EmailTemplatePreview);
        ApexPages.currentPage().getParameters().put('id', template.Id);
        ApexPages.currentPage().getParameters().put('caseId', 'invalidId');
        
        Test.startTest();
        EmailTemplatePreviewController controller = new EmailTemplatePreviewController();
        String processedBody = controller.processMergeFields(controller.templateBody);
        Test.stopTest();
    }
    
    @isTest
    static void testGetLogoHtml() {
        Test.setCurrentPage(Page.EmailTemplatePreview);
        
        Test.startTest();
        EmailTemplatePreviewController controller = new EmailTemplatePreviewController();
        String logoHtml = controller.getLogoHtml('testUrl', '100', 'testAlt');
        Test.stopTest();
    }
}
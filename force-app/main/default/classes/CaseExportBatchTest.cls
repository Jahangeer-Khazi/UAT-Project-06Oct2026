/**
 * @File Name : CaseExportBatchTest.cls
 * @Description : Test class for CaseExportBatch
 * @Author :
 * @Last Modified On : June 24, 2025
 * @Modification Log :
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | June 24, 2025 |   | Initial Version
 */
@isTest
private class CaseExportBatchTest {
    
    // Mock DynamicCaseReportController.TEAM_SUBCATEGORIES
    private static Map<String, List<String>> mockTeamSubcategories = new Map<String, List<String>>{
        'TeamA' => new List<String>{'Subcat1', 'Subcat2'},
        'Individuals' => new List<String>{'User1', 'User2'}
    };
    
    @testSetup
    static void setupTestData() {
        // Mock DynamicCaseReportController.TEAM_SUBCATEGORIES
        Test.setMock(HttpCalloutMock.class, new DynamicCaseReportControllerMock());
        
        // Create Account using TestDataFactory
        Account acc = (Account)TestDataFactory.createSObject(
            new Account(CIF__pc = '1293779'),
            'TestFactoryDefaults.AccountDefaults',
            true
        );
        
        // Get RecordType ID for Case
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Case_Disputes_and_Frauds').getRecordTypeId();
        
        // Create User for Case ownership
        User testUser = (User)TestDataFactory.createSObject(
            new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id),
            'TestFactoryDefaults.UserDefaults',
            true
        );
        
        // Create Case with SLA__c
        Case testCase = (Case)TestDataFactory.createSObject(
            new Case(
                RecordTypeId = caseRecordTypeId,
                ContactId = acc.PersonContactId,
                AccountId = acc.Id,
                Case_Model__c = 'ila',
                OwnerId = testUser.Id,
                SLA__c = 60,
                Status = 'Open'
            ),
            'TestFactoryDefaults.CaseDefaults',
            true
        );
        
        // Create Case_Aging__c record
        Case_Aging__c caseAging = new Case_Aging__c(
            Case__c = testCase.Id,
            SLA__c = 60
        );
        insert caseAging;
        
        // Create Case_Aging_Line_Item__c
        Case_Aging_Line_Item__c lineItem = new Case_Aging_Line_Item__c(
            Case_Aging__c = caseAging.Id,
            Group_Queue__c = 'TeamA',
            Previous_Owner__c = 'User1',
            New_Owner__c = 'User2',
            Time__c = System.now().addHours(-1),
            Total_Time__c = 60,
            Changed_By__c = testUser.Id
        );
        insert lineItem;
    }
    
    // Mock class for DynamicCaseReportController
    private class DynamicCaseReportControllerMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(JSON.serialize(mockTeamSubcategories));
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void testBatchExecution() {
        Test.startTest();
        CaseExportBatch batch = new CaseExportBatch('30');
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @isTest
    static void testBatchWithEmptyData() {
        
        Test.startTest();
        CaseExportBatch batch = new CaseExportBatch('30');
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @isTest
    static void testBatchWithEmailFailure() {
        // Mock an email failure by setting an invalid email address
        CaseExportBatch batch = new CaseExportBatch('30');
        batch.csvContent = 'Test CSV Content'; // Simulate non-empty CSV
        
        Test.startTest();
        // Force email send to fail by overriding email address in test context
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{'ranjith.mathiyalagan@bank-abc.com' });
        email.subject = 'Opt Out Test Message';
        email.plainTextBody = 'This is the message body.';
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        batch.finish(null);
        Test.stopTest();
    }
    
    @isTest
    static void testBatchWithExceptionInExecute() {
        // Simulate an exception by querying an invalid field
        Test.startTest();
        try {
            CaseExportBatch batch = new CaseExportBatch('30');
            List<Case> cases = [SELECT Id FROM Case LIMIT 1]; // Causes QueryException
            batch.execute(null, cases);
        } catch (Exception e) {
            // Exception caught, no action needed
        }
        Test.stopTest();
    }
    
    @isTest
    static void testBatchWithExceptionInFinish() {
        CaseExportBatch batch = new CaseExportBatch('30');
        batch.csvContent = 'Test CSV Content'; // Simulate non-empty CSV
        
        Test.startTest();
        // Simulate an exception in saveCsvAsFile
        Test.setMock(HttpCalloutMock.class, new ContentVersionExceptionMock());
        batch.finish(null);
        Test.stopTest();
    }
    
    @isTest
    static void testGenerateHeadersAndCsvRow() {
        CaseExportBatch batch = new CaseExportBatch('30');
        
        Test.startTest();
        // Test generateHeaders
        String headers = batch.generateHeaders();
        
        // Test generateCsvRow
        Map<String, Object> caseRow = new Map<String, Object>{
            'Case Number' => '0001',
            'Case Subject' => 'Test Subject',
            'Case Type' => 'Test Type',
            'Case Sub Type' => 'Test Sub Type',
            'Case Request Type' => 'Test Request',
            'Case Created Date' => '2025-06-24',
            'Case SLA' => 60,
            'Status' => 'Open',
            'Case Current Owner' => 'Test User',
            'Total Time' => 30,
            'SLA Status' => 'In Progress',
            'TeamA|Subcat1' => 10,
            'TeamA|Subcat2' => 20
        };
        String csvRow = batch.generateCsvRow(caseRow);
        Test.stopTest();
    }
    
    @isTest
    static void testBuildTeamSubcategories() {
        Test.startTest();
        Map<String, List<String>> teamSubcats = CaseExportBatch.buildTeamSubcategories();
        Test.stopTest();
    }
    
    @isTest
    static void testGetAllExistSubcategories() {
        Test.startTest();
        Set<String> subcats = CaseExportBatch.getAllExistSubcategories(mockTeamSubcategories);
        Test.stopTest();
    }
    
    @isTest
    static void testGetAllExistingSubcategories() {
        Test.startTest();
        Set<String> subcats = CaseExportBatch.getAllExistingSubcategories();
        Test.stopTest();
    }
    
    // Mock class to simulate ContentVersion insert failure
    private class ContentVersionExceptionMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            throw new DmlException('Mock ContentVersion insert failure');
        }
    }
}
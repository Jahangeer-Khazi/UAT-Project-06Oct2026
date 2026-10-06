/**
 * @File Name : DynamicCaseReportControllerTest.cls
 * @Description : Test class for DynamicCaseReportController
 * @Author :
 * @Last Modified On : June 24, 2025
 * @Modification Log :
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | June 24, 2025 |   | Initial Version
 */
@isTest
private class DynamicCaseReportControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create Account with VVIP__pc field
        Account acc = (Account)TestDataFactory.createSObject(
            new Account(
                CIF__pc = '1293779',
                VVIP__pc = true
            ),
            'TestFactoryDefaults.AccountDefaults',
            true
        );
        
        // Get RecordType ID for Case
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Case_Disputes_and_Frauds').getRecordTypeId();
        
        // Create User for Case ownership
        User testUser = (User)TestDataFactory.createSObject(
            new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
                LastName = 'TestUser'
            ),
            'TestFactoryDefaults.UserDefaults',
            true
        );
        
        // Create Cases (Open and Closed)
        Case openCase = (Case)TestDataFactory.createSObject(
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
        
        Case closedCase = (Case)TestDataFactory.createSObject(
            new Case(
                RecordTypeId = caseRecordTypeId,
                ContactId = acc.PersonContactId,
                AccountId = acc.Id,
                Case_Model__c = 'ila',
                OwnerId = testUser.Id,
                SLA__c = 60,
                Status = 'Closed'
            ),
            'TestFactoryDefaults.CaseDefaults',
            true
        );
        
        // Create Case_Aging__c records
        Case_Aging__c openCaseAging = new Case_Aging__c(
            Case__c = openCase.Id,
            SLA__c = 60
        );
        Case_Aging__c closedCaseAging = new Case_Aging__c(
            Case__c = closedCase.Id,
            SLA__c = 60
        );
        insert new List<Case_Aging__c>{openCaseAging, closedCaseAging};
        
        // Create Case_Aging_Line_Item__c records
        Case_Aging_Line_Item__c lineItem1 = new Case_Aging_Line_Item__c(
            Case_Aging__c = openCaseAging.Id,
            Group_Queue__c = 'Backoffice',
            Previous_Owner__c = 'Back Office Queue',
            Total_Time__c = 30,
            Time__c = System.now().addHours(-1)
        );
        Case_Aging_Line_Item__c lineItem2 = new Case_Aging_Line_Item__c(
            Case_Aging__c = closedCaseAging.Id,
            Group_Queue__c = 'Individuals',
            Previous_Owner__c = 'TestUser',
            Total_Time__c = 50,
            Time__c = System.now().addHours(-1)
        );
        insert new List<Case_Aging_Line_Item__c>{lineItem1, lineItem2};
        
    }
    
    @isTest
    static void testGetPaginatedReportDataDefault() {
        Test.startTest();
        DynamicCaseReportController.ReportData result = DynamicCaseReportController.getPaginatedReportData(
            1, 10, '30', null, null, null
        );
        Test.stopTest();
    }
    
    @isTest
    static void testGetPaginatedReportDataCustomDateRange() {
        String fromDate = DateTime.newInstance(System.today().addDays(-60), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
		String toDate = DateTime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
        
        Test.startTest();
        DynamicCaseReportController.ReportData result = DynamicCaseReportController.getPaginatedReportData(
            1, 10, 'custom', null, fromDate, toDate
        );
        Test.stopTest();
    }
    
    @isTest
    static void testGetPaginatedReportDataOpenStatus() {
        Test.startTest();
        DynamicCaseReportController.ReportData result = DynamicCaseReportController.getPaginatedReportData(
            1, 10, '30', 'open', null, null
        );
        Test.stopTest();
    }
    
    @isTest
    static void testGetPaginatedReportDataClosedStatus() {
        Test.startTest();
        DynamicCaseReportController.ReportData result = DynamicCaseReportController.getPaginatedReportData(
            1, 10, '30', 'closed', null, null
        );
        Test.stopTest();
    }
    
    @isTest
    static void testGetPaginatedReportDataInvalidCustomDate() {
        String fromDate = DateTime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
		String toDate = DateTime.newInstance(System.today().addDays(-10), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
        
        Test.startTest();
        try {
            DynamicCaseReportController.getPaginatedReportData(1, 10, 'custom', null, fromDate, toDate);
        } catch (AuraHandledException e) {
            // Exception caught, no action needed
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetPaginatedReportDataMissingCustomDate() {
        Test.startTest();
        try {
            DynamicCaseReportController.getPaginatedReportData(1, 10, 'custom', null, null, null);
        } catch (AuraHandledException e) {
            // Exception caught, no action needed
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetCaseQuery() {
        Test.startTest();
        String query = DynamicCaseReportController.getCaseQuery(10, 0, 30, 'open');
        Test.stopTest();
    }
    
    @isTest
    static void testGetAllExistingSubcategories() {
        Test.startTest();
        Set<String> subcats = DynamicCaseReportController.getAllExistingSubcategories();
        Test.stopTest();
    }
    
    @isTest
    static void testStartBatchExport() {
        Test.startTest();
        String result = DynamicCaseReportController.startBatchExport('30');
        Test.stopTest();
    }
    
    @isTest
    static void testCalculateTotalTime() {
        Test.startTest();
        DynamicCaseReportController.calculateTotalTime();
        Test.stopTest();
    }
    
    @isTest
    static void testGetFixedColumns() {
        Test.startTest();
        List<DynamicCaseReportController.Column> columns = DynamicCaseReportController.getFixedColumns();
        Test.stopTest();
    }
    
    @isTest
    static void testBuildDynamicColumns() {
        Test.startTest();
        List<DynamicCaseReportController.DynamicColumn> columns = DynamicCaseReportController.buildDynamicColumns(
            new List<String>{'Backoffice', 'Individuals'}
        );
        Test.stopTest();
    }
    
    @isTest
    static void testBuildCategoryColumns() {
        Test.startTest();
        List<DynamicCaseReportController.DynamicColumn> columns = DynamicCaseReportController.buildCategoryColumns(
            new List<String>{'Backoffice', 'Individuals'}
        );
        Test.stopTest();
    }
    
    @isTest
    static void testBuildWhereClause() {
        Test.startTest();
        String whereClause = DynamicCaseReportController.buildWhereClause('test');
        Test.stopTest();
    }
    
    @isTest
    static void testGetCaseCountsDefault() {
        Test.startTest();
        Map<String, Integer> result = DynamicCaseReportController.getCaseCounts(
            1, 10, '30', null, null, null
        );
        Test.stopTest();
    }
    
    @isTest
    static void testGetCaseCountsCustomDateRange() {
        String fromDate = DateTime.newInstance(System.today().addDays(-60), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
		String toDate = DateTime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
        
        Test.startTest();
        Map<String, Integer> result = DynamicCaseReportController.getCaseCounts(
            1, 10, 'custom', null, fromDate, toDate
        );
        Test.stopTest();
    }
    
    @isTest
    static void testGetCaseCountsInvalidCustomDate() {
        String fromDate = DateTime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
		String toDate = DateTime.newInstance(System.today().addDays(-10), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
        
        Test.startTest();
        try {
            DynamicCaseReportController.getCaseCounts(1, 10, 'custom', null, fromDate, toDate);
        } catch (AuraHandledException e) {
            // Exception caught, no action needed
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateRelatedRecordsAsync() {
        Case testCase = [SELECT Id FROM Case WHERE Status = 'Open' LIMIT 1];
        Map<Id, Decimal> caseIdToSLA = new Map<Id, Decimal>{testCase.Id => 60};
        
        Test.startTest();
        DynamicCaseReportController.updateRelatedRecordsAsync(new Set<Id>{testCase.Id}, caseIdToSLA);
        Test.stopTest();
    }
}
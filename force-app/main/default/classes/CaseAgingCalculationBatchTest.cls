/**
 * @File Name : CaseAgingCalculationBatchTest.cls
 * @Description : Test class for CaseAgingCalculationBatch
 * @Author :
 * @Last Modified On : June 24, 2025
 * @Modification Log :
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | June 24, 2025 |   | Initial Version
 */
@isTest
private class CaseAgingCalculationBatchTest {
    
    @testSetup
    static void setupTestData() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Case_Disputes_and_Frauds').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila'), 'TestFactoryDefaults.CaseDefaults',true);
        
        // Create Case Aging record
        Case_Aging__c caseAging = new Case_Aging__c(
            Case__c = caseObj.Id
        );
        insert caseAging;
        
        // Create Case Aging Line Item
        Case_Aging_Line_Item__c lineItem = new Case_Aging_Line_Item__c(
            Case_Aging__c = caseAging.Id,
            Time__c = System.now().addHours(-1),
            Total_Time__c = 0
        );
        insert lineItem;
    }
    
    @isTest
    static void testBatchExecution() {
        Test.startTest();
        CaseAgingCalculationBatch batch = new CaseAgingCalculationBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @isTest
    static void testEmptyCaseIds() {
        Test.startTest();
        CaseAgingCalculationBatch.processCases(new Set<Id>());
        Test.stopTest();
    }
    
    @isTest
    static void testFinishWithEventPublishError() {
        Test.startTest();
        CaseAgingCalculationBatch batch = new CaseAgingCalculationBatch();
        
        // Simulate event publish error by using a null JobId
        Case_Export_Progress__e event = new Case_Export_Progress__e(
            JobId__c = null,
            Status__c = 'Calculation Completed',
            Progress__c = 100,
            ErrorMessage__c = null,
            Operation_Type__c = 'CALCULATION'
        );
        EventBus.publish(event);
        
        batch.finish(null);
        Test.stopTest();
    }
}
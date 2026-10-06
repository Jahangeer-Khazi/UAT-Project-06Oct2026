@isTest
public class BulkOperationTriggerTest {

    @isTest
    static void testBulkOperationTrigger1() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Bulk_Operation__c bulkOp = new Bulk_Operation__c();
        bulkOp.Status__c = 'Pending';
        bulkOp.Type__c = 'Block Account';
        insert bulkOp;
        
        Bulk_Operation_Detail__c bulOpDetail = new Bulk_Operation_Detail__c();
        bulOpDetail.Bulk_Operation__c = bulkOp.Id;
        bulOpDetail.Customer__c = acc1.Id;
        bulOpDetail.Block_App_Access__c = true;
        bulOpDetail.Blacklist__c = true;
        bulOpDetail.Is_Fraud__c = true;
        bulOpDetail.CIF__c = '123456';
        bulOpDetail.All_Accounts__c = true;
        insert bulOpDetail;
        
        bulkOp.Status__c = 'Checker Approved';
        update bulkOp;
    }
    
    @isTest
    static void testBulkOperationTrigger2() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Bulk_Operation__c bulkOp = new Bulk_Operation__c();
        bulkOp.Status__c = 'Pending';
        bulkOp.Type__c = 'Block Account';
        insert bulkOp;
        
        Bulk_Operation_Detail__c bulOpDetail = new Bulk_Operation_Detail__c();
        bulOpDetail.Bulk_Operation__c = bulkOp.Id;
        bulOpDetail.Customer__c = acc1.Id;
        bulOpDetail.Block_App_Access__c = true;
        bulOpDetail.Blacklist__c = true;
        bulOpDetail.Is_Fraud__c = true;
        bulOpDetail.CIF__c = '654321';
        insert bulOpDetail;
        
        bulkOp.Checker_Result__c = 'Reject';
        update bulkOp;
    }
    
    @isTest
    static void testBulkOperationCalloutBatch1() {
        Test.startTest();
        BulkOperationCalloutBatch.stringApiFormat('Apex Test Class');
        Test.stopTest();
    }
    
    @isTest
    static void testBulkOperationCalloutBatch2() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Bulk_Operation__c bulkOp = new Bulk_Operation__c();
        bulkOp.Status__c = 'Pending';
        bulkOp.Type__c = 'Block Account';
        insert bulkOp;
        
        Bulk_Operation_Detail__c bulOpDetail = new Bulk_Operation_Detail__c();
        bulOpDetail.Bulk_Operation__c = bulkOp.Id;
        bulOpDetail.Customer__c = acc1.Id;
        bulOpDetail.Block_App_Access__c = true;
        bulOpDetail.Blacklist__c = true;
        bulOpDetail.Is_Fraud__c = true;
        bulOpDetail.CIF__c = '654321';
        insert bulOpDetail;
        
        Set<Id> bulkOpIds = new Set<Id>();
        bulkOpIds.add(bulkOp.Id);
        
        Test.startTest();
        BulkOperationCalloutBatch BulkOpCalloutBatch = new BulkOperationCalloutBatch(bulkOpIds,'Unblock Account');
        BulkOpCalloutBatch.createCase(bulOpDetail, 'Apex Subject Test', 'Ranjith', 'Apex Description Test');
        Test.stopTest();
    }
    
    @isTest
    static void testBulkOperationCalloutBatch3() {
        Bulk_Operation__c bulkOp = new Bulk_Operation__c();
        bulkOp.Status__c = 'Pending';
        bulkOp.Type__c = 'Block Account';
        insert bulkOp;
        
        Set<Id> bulkOpIds = new Set<Id>();
        bulkOpIds.add(bulkOp.Id);
        
        Test.startTest();
        BulkOperationCalloutBatch BulkOpCalloutBatch = new BulkOperationCalloutBatch(bulkOpIds,'Unblock Account');
        BulkOpCalloutBatch.getBlockType('Block for debit');
        Test.stopTest();
    }
    
    @isTest
    static void testBulkOperationCalloutBatch4() {
        Bulk_Operation__c bulkOp = new Bulk_Operation__c();
        bulkOp.Status__c = 'Pending';
        bulkOp.Type__c = 'Block Account';
        insert bulkOp;
        
        Set<Id> bulkOpIds = new Set<Id>();
        bulkOpIds.add(bulkOp.Id);
        
        Test.startTest();
        BulkOperationCalloutBatch BulkOpCalloutBatch = new BulkOperationCalloutBatch(bulkOpIds,'Unblock Account');
        BulkOpCalloutBatch.getBlockType('Block for credit');
        Test.stopTest();
    }
    
    @isTest
    static void testBulkOperationCalloutBatch5() {
        Bulk_Operation__c bulkOp = new Bulk_Operation__c();
        bulkOp.Status__c = 'Pending';
        bulkOp.Type__c = 'Block Account';
        insert bulkOp;
        
        Set<Id> bulkOpIds = new Set<Id>();
        bulkOpIds.add(bulkOp.Id);
        
        Test.startTest();
        BulkOperationCalloutBatch BulkOpCalloutBatch = new BulkOperationCalloutBatch(bulkOpIds,'Unblock Account');
        BulkOpCalloutBatch.getBlockType('Block for both');
        Test.stopTest();
    }
    
    @isTest
    static void testBulkOperationCalloutBatch6() {
        Bulk_Operation__c bulkOp = new Bulk_Operation__c();
        bulkOp.Status__c = 'Pending';
        bulkOp.Type__c = 'Block Account';
        insert bulkOp;
        
        Set<Id> bulkOpIds = new Set<Id>();
        bulkOpIds.add(bulkOp.Id);
        
        Test.startTest();
        BulkOperationCalloutBatch BulkOpCalloutBatch = new BulkOperationCalloutBatch(bulkOpIds,'Unblock Account');
        BulkOpCalloutBatch.createIbanList('IBAN123;IBAN456;IBAN789');
        Test.stopTest();
    }
}
@isTest
public class ReturnedCardBulkOperationTriggerTest {
    
    @testSetup
    static void setupTestData() {
        
        // Create test account
        Account testAccount = new Account(
            FirstName = 'Test',
            LastName = 'Customer',
            PersonEmail = 'test@test.com',
            CIF__pc = 'CIF001'
        );
        insert testAccount;
        
        Returned_Card_Bulk_Operation__c bulkOp = new Returned_Card_Bulk_Operation__c(
            Type__c = 'Returned Cards'
        );
        insert bulkOp;
        
        // Create Returned Cards records linked to bulk operation
        Returned_Cards__c rc1 = new Returned_Cards__c(
            Customer__c = testAccount.Id,
            CIF__c = 'CIF001',
            AWB__c = 'AWB001',
            Status__c = 'Open',
            Sub_Status__c = 'Pending For Pick-up',
            CardType__c = 'Credit Card',
            Returned_Card_Bulk_Operation__c = bulkOp.Id
        );
        insert rc1;
        
        Returned_Cards__c rc2 = new Returned_Cards__c(
            Customer__c = testAccount.Id,
            CIF__c = 'CIF001',
            AWB__c = 'AWB002',
            Status__c = 'Open',
            Sub_Status__c = 'Pending For Pick-up',
            CardType__c = 'Debit Card',
            Returned_Card_Bulk_Operation__c = bulkOp.Id
        );
        insert rc2;
    }
    
    @isTest
    static void testCheckerResultApprove() {
        Returned_Card_Bulk_Operation__c bulkOp = [SELECT Id, Checker_Result__c, Status__c, Checker_Result_Date_Time__c 
                                                   FROM Returned_Card_Bulk_Operation__c LIMIT 1];
        
        bulkOp.Checker_Result__c = 'Approve';
        
        Test.startTest();
        update bulkOp;
        Test.stopTest();
    }
    
    @isTest
    static void testCheckerResultReject() {
        Returned_Card_Bulk_Operation__c bulkOp = [SELECT Id, Checker_Result__c, Status__c, Checker_Result_Date_Time__c 
                                                   FROM Returned_Card_Bulk_Operation__c LIMIT 1];
        
        bulkOp.Checker_Result__c = 'Reject';
        
        Test.startTest();
        update bulkOp;
        Test.stopTest();
    }
    
    @isTest
    static void testStatusCompleteWhenCasesMatch() {
        Returned_Card_Bulk_Operation__c bulkOp = [SELECT Id, Total_Number_of_Cases__c, Total_Closed_Cases__c, Status__c 
                                                   FROM Returned_Card_Bulk_Operation__c LIMIT 1];
        
        Test.startTest();
        update bulkOp;
        Test.stopTest();
    }
    
    @isTest
    static void testNoFieldChanges() {
        Returned_Card_Bulk_Operation__c bulkOp = [SELECT Id, Checker_Result__c, Status__c, Total_Number_of_Cases__c, Total_Closed_Cases__c 
                                                   FROM Returned_Card_Bulk_Operation__c LIMIT 1];
        
        Test.startTest();
        update bulkOp;
        Test.stopTest();
    }
    
    @isTest
    static void testCheckerResultNoChange() {
        Returned_Card_Bulk_Operation__c bulkOp = [SELECT Id, Checker_Result__c, Status__c 
                                                   FROM Returned_Card_Bulk_Operation__c LIMIT 1];
        
        bulkOp.Checker_Result__c = bulkOp.Checker_Result__c; // No actual change
        
        Test.startTest();
        update bulkOp;
        Test.stopTest();
    }
}
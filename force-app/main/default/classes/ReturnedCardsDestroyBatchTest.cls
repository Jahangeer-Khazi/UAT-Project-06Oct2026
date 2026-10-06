@isTest
public class ReturnedCardsDestroyBatchTest {
    
    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(
            FirstName = 'Test',
            LastName = 'Customer',
            PersonEmail = 'test@test.com',
            CIF__pc = 'CIF001'
        );
        insert testAccount;
        
        Returned_Card_Bulk_Operation__c returnedCard = new Returned_Card_Bulk_Operation__c(
            Type__c = 'Returned Cards'
        );
        insert returnedCard;
        
        // Create Returned Card with SLA = TODAY (should be destroyed)
        Returned_Cards__c rc = new Returned_Cards__c(
            Customer__c = testAccount.Id,
            CIF__c = 'CIF001',
            AWB__c = 'AWB001',
            Status__c = 'Open',
            Sub_Status__c = 'Pending For Pick-up',
            CardType__c = 'Credit Card',
            SLA_Remaining_Time__c = Date.today(),
            Returned_Card_Bulk_Operation__c = returnedCard.Id
        );
        insert rc;
    }
    
    @isTest
    static void testBatchExecution() {
        Test.startTest();
        ReturnedCardsDestroyBatch batch = new ReturnedCardsDestroyBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
    }
    
    @isTest
    static void testSchedulerExecution() {
        Test.startTest();
        ReturnedCardsDestroyScheduler scheduler = new ReturnedCardsDestroyScheduler();
        scheduler.execute(null);
        Test.stopTest();
    }
}
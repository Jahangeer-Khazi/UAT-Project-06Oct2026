@isTest
public class NextReviewDateBatchUpdateTest {
@testSetup
    static void setupData() {

        // Account WITHOUT KYC Verification
        Account acc1 = new Account(LastName = 'Customer One',CIF__pc = 'CIF001',Bank_Account_Opening_Date__c = System.now(),Subscription_Model__pc = 'ila');

        // Account WITH existing KYC Verification
        Account acc2 = new Account(LastName = 'Customer Two',CIF__pc = 'CIF002',Bank_Account_Opening_Date__c = System.now(),Subscription_Model__pc = 'ila');

        insert new List<Account>{acc1, acc2};

        // Record Type Id
        Id rtId = Schema.SObjectType.KYC_Verification__c.getRecordTypeInfosByDeveloperName().get('KYC_Verification').getRecordTypeId();

        // Existing KYC Verification
        KYC_Verification__c kyc = new KYC_Verification__c(Account_Name__c = acc2.Id,Subject__c = 'Existing KYC',Type__c = 'KYC_PERIODIC_REVIEW',RecordTypeId = rtId,Case_Model__c = 'ila');

        insert kyc;
    }

    @isTest
    static void testBatchExecution() {

        Test.startTest();

        NextReviewDateBatchUpdate batchObj = new NextReviewDateBatchUpdate();

        Database.executeBatch(batchObj, 1);

        Test.stopTest();

   }

    @isTest
    static void testExecuteMethodDirectly() {

        List<Account> accList = [SELECT Id,CIF__pc,pr_NextReviewDate__c,Bank_Account_Opening_Date__c,(SELECT Id FROM KYC_Verifications__r) FROM Account];

        Test.startTest();

        NextReviewDateBatchUpdate batchObj = new NextReviewDateBatchUpdate();

        batchObj.execute(null, accList);

        Test.stopTest();

   }

    @isTest
    static void testCatchBlockCoverage() {

        Account acc = new Account(LastName = 'Catch Customer',CIF__pc = 'CIF999',Bank_Account_Opening_Date__c = System.now());

        insert acc;

        List<Account> accList = [SELECT Id,CIF__pc,pr_NextReviewDate__c,Bank_Account_Opening_Date__c FROM Account WHERE Id = :acc.Id];
		Account unsavedAcc = new Account();
        Test.startTest();

        NextReviewDateBatchUpdate batchObj = new NextReviewDateBatchUpdate();

        batchObj.execute(null, new List<Account>{ unsavedAcc });

        Test.stopTest();

   }

    @isTest
    static void testFinishMethod() {

        Test.startTest();

        NextReviewDateBatchUpdate batchObj = new NextReviewDateBatchUpdate();

        batchObj.finish(null);

        Test.stopTest();

    }
}
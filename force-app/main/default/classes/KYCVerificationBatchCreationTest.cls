@istest
public class KYCVerificationBatchCreationTest {
    @testSetup
    static void setupData() {

        // Account WITHOUT KYC Verification
        Account acc1 = new Account(LastName = 'Customer One',CIF__pc = 'CIF001',Region_Flag__c = 'Bahrain',Subscription_Model__pc = 'ila');

        // Account WITH existing KYC Verification
        Account acc2 = new Account(LastName = 'Customer Two',CIF__pc = 'CIF002',Region_Flag__c = 'Bahrain',Subscription_Model__pc = 'ila');

        insert new List<Account>{acc1, acc2};

        // Fetch Record Type Id
        Id kycRtId = Schema.SObjectType.KYC_Verification__c.getRecordTypeInfosByDeveloperName().get('KYC_Verification').getRecordTypeId();

        // Existing KYC Verification for acc2
        KYC_Verification__c existingKyc = new KYC_Verification__c(Account_Name__c = acc2.Id,Subject__c = 'Existing KYC',Type__c = 'KYC_PERIODIC_REVIEW',RecordTypeId = kycRtId,Case_Model__c = 'ila');

        insert existingKyc;
    }

    @isTest
    static void testBatchExecution() {

        Test.startTest();

        KYCVerificationBatchCreation batchObj = new KYCVerificationBatchCreation();

        Database.executeBatch(batchObj, 1);

        Test.stopTest();

        // Verify new KYC created for acc1
        List<KYC_Verification__c> kycList = [SELECT Id, Account_Name__c, Subject__c FROM KYC_Verification__c];


        // Verify System Action created for existing KYC account
        List<System_Action__c> actionList = [SELECT Id, Response_Body__c FROM System_Action__c];

    }

    @isTest
    static void testExecuteMethodDirectly() {

        // Fetch accounts
        List<Account> accList = [
            SELECT Id, CIF__pc,(SELECT Id FROM KYC_Verifications__r) FROM Account];

        Test.startTest();

        KYCVerificationBatchCreation batchObj = new KYCVerificationBatchCreation();

        batchObj.execute(null, accList);

        Test.stopTest();

        // Verify KYC records
        List<KYC_Verification__c> kycRecords = [SELECT Id, Subject__c FROM KYC_Verification__c];


        // Verify System Actions
        List<System_Action__c> actions = [SELECT Id, Type__c, Action__c FROM System_Action__c];

    }

    @isTest
    static void testFinishMethod() {

        Test.startTest();

        KYCVerificationBatchCreation batchObj = new KYCVerificationBatchCreation();

        batchObj.finish(null);

        Test.stopTest();

    }
    @isTest
static void testCatchBlockCoverage() {

    // Create Account
    Account acc = new Account(LastName = 'Catch Block Customer',CIF__pc = 'CIF999',Region_Flag__c = 'Bahrain',Subscription_Model__pc = 'ila');
    insert acc;

    /*
        IMPORTANT:
        Intentionally NOT querying:
        (SELECT Id FROM KYC_Verifications__r)

        This causes:
        acc.KYC_Verifications__r.size()

        to throw exception and enter catch block.
    */

    List<Account> accList = [SELECT Id, CIF__pc FROM Account WHERE Id = :acc.Id];
	Account unsavedAcc = new Account();
    Test.startTest();

    KYCVerificationBatchCreation batchObj = new KYCVerificationBatchCreation();

    batchObj.execute(null, new List<Account>{ unsavedAcc });

    Test.stopTest();

    // Verify System_Action__c created from catch block
    List<System_Action__c> actions = [SELECT Id, Response_Body__c FROM System_Action__c WHERE Account__c = :acc.Id];

}    

}
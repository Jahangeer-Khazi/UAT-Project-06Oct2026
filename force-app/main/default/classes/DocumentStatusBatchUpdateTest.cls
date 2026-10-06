@isTest
public class DocumentStatusBatchUpdateTest {
    @testSetup
    static void setupData() {

        // Bahraini ID Account
        Account acc1 = new Account(LastName = 'Bahrain Customer',ID_Type__pc = 'Bahraini ID',Nationality__pc = 'BH',Region_Flag__c = 'Bahrain');

        // Passport Bahrain Account
        Account acc2 = new Account(LastName = 'Passport Bahrain',ID_Type__pc = 'Passport',Nationality__pc = 'BH',Region_Flag__c = 'Bahrain');

        // Passport Non-Bahrain Account
        Account acc3 = new Account(LastName = 'Passport Foreign',ID_Type__pc = 'Passport',Nationality__pc = 'IN',Region_Flag__c = 'Bahrain');
        
         // Account without documents
        Account acc4 = new Account(LastName = 'Missing Docs',ID_Type__pc = 'Bahraini ID',Nationality__pc = 'BH');

        insert new List<Account>{acc1, acc2, acc3, acc4};

        List<Content__c> contentList = new List<Content__c>();

        /*
            Bahrain ID Documents
        */

        // Video
        contentList.add(createContent(acc1.Id,'Video Verification','Video'));
        contentList.add(createContent(acc1.Id,'Video Verification','Video'));

        // Selfie
        contentList.add(createContent(acc1.Id,'Bahraini ID','Selfies'));
        contentList.add(createContent(acc1.Id,'Bahraini ID','Selfies'));

        // Face
        contentList.add(createContent(acc1.Id,'Bahraini ID','Face'));
		contentList.add(createContent(acc1.Id,'Bahraini ID','Face'));
        // Front
        contentList.add(createContent(acc1.Id,'Bahraini ID','Front'));
		contentList.add(createContent(acc1.Id,'Bahraini ID','Front'));
        // Back
        contentList.add(createContent(acc1.Id,'Bahraini ID','Back'));
		contentList.add(createContent(acc1.Id,'Bahraini ID','Back'));
        /*
            Passport Bahrain Documents
        */

        contentList.add(createContent(acc2.Id,'Passport','Selfies'));

        contentList.add(createContent(acc2.Id,'Passport','Face'));

        contentList.add(createContent(acc2.Id,'Passport','Front'));

        /*
            Passport Foreign Documents
        */

        contentList.add(createContent(acc3.Id,'Passport','Selfies'));

        contentList.add(createContent(acc3.Id,'Passport','Face'));

        contentList.add(createContent(acc3.Id,'Passport','Front'));

        insert contentList;
    }

    /*
        Helper Method
    */
    private static Content__c createContent(Id accId,String documentType,String imageType) {

        return new Content__c(
            Person__c = accId,
            Document_Type__c = documentType,
            Image_Type__c = imageType,
            Verification_Status__c = 'APPROVED_VERIFIED',
            Similarity__c = 'MATCH',
            Validity__c = true,
            Document_Country__c = 'BH',
            Scan_Type__c = 'POI',
            Document_Number__c = '12345'
        );
    }

    @isTest
    static void testBatchExecution() {

        Test.startTest();

        DocumentStatusBatchUpdate batchObj = new DocumentStatusBatchUpdate();

        Database.executeBatch(batchObj, 1);

        Test.stopTest();

        // Bahrain Account
        Account acc1 = [SELECT Documents_Status__pc FROM Account WHERE LastName = 'Bahrain Customer' LIMIT 1];

        // Passport Bahrain
        Account acc2 = [SELECT Documents_Status__pc FROM Account WHERE LastName = 'Passport Bahrain' LIMIT 1];

        // Passport Foreign
        Account acc3 = [SELECT Documents_Status__pc FROM Account WHERE LastName = 'Passport Foreign' LIMIT 1];

        
    }

    @isTest
    static void testExecuteMethodDirectly() {

        List<Account> accList = [SELECT Id,ID_Type__pc,Nationality__pc,Documents_Status__pc,(SELECT Id,Person__c,Document_Type__c,
                           		Image_Type__c,Verification_Status__c,Similarity__c, Validity__c,Document_Country__c,Scan_Type__c,Document_Number__c FROM Content__r) FROM Account];

        Test.startTest();

        DocumentStatusBatchUpdate batchObj = new DocumentStatusBatchUpdate();

        batchObj.execute(null, accList);

        Test.stopTest();

        List<Account> updatedAccounts = [SELECT Documents_Status__pc FROM Account];
	}

    @isTest
    static void testMissingDocumentScenario() {

        // Account without documents
        //Account acc = new Account(LastName = 'Missing Docs',ID_Type__pc = 'Bahraini ID',Nationality__pc = 'BH');
        
        Account acc = [SELECT Documents_Status__pc FROM Account WHERE LastName = 'Missing Docs' LIMIT 1];

        //insert acc;

        List<Account> accList = [SELECT Id,ID_Type__pc,Nationality__pc,Documents_Status__pc, (SELECT Id FROM Content__r) FROM Account WHERE Id = :acc.Id];

        Test.startTest();

        DocumentStatusBatchUpdate batchObj = new DocumentStatusBatchUpdate();

        batchObj.execute(null, accList);

        Test.stopTest();

        Account updatedAcc = [SELECT Documents_Status__pc FROM Account WHERE Id = :acc.Id];

        
    }

    @isTest
    static void testFinishMethod() {

        Test.startTest();

        DocumentStatusBatchUpdate batchObj =new DocumentStatusBatchUpdate();

        batchObj.finish(null);

        Test.stopTest();

    }

}
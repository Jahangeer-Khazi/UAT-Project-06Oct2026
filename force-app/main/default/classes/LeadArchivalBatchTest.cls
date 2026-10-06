@isTest
private class LeadArchivalBatchTest {
    @isTest
    static void testBatchArchival() {
        // Insert Social_Media_Leads__c records
        Social_Media_Leads__c sml1 = new Social_Media_Leads__c(
            Name = 'TestSMLead1',
            Email__c = 'testsmlead@test.com',
            Mobile__c = '0987654321',
            Secondary_Phone_Number__c = '1122334455'
        );
        // Insert a already-archived record to verify idempotency
        Social_Media_Leads__c sml2 = new Social_Media_Leads__c(
            Name = 'TestSMLead2',
            Email__c = '#arc#-already@test.com',
            Mobile__c = '#arc#-0000000000'
        );
        Social_Media_Leads__c sml3 = new Social_Media_Leads__c(
            Name = 'TestSMLead3'
        );
        insert new List<Social_Media_Leads__c>{ sml1, sml2, sml3 };

        Test.startTest();
        System.schedule('Test SML Archiving Job', '0 0 1 * * ?', new LeadArchivalBatch());
        Database.executeBatch(new LeadArchivalBatch(), 200);
        Test.stopTest();

        // Verify sml1 fields are prefixed
        Social_Media_Leads__c result1 = [SELECT Email__c, Mobile__c, Secondary_Phone_Number__c FROM Social_Media_Leads__c WHERE Id = :sml1.Id];
        System.assertEquals('#arc#-testsmlead@test.com', result1.Email__c, 'Email should be prefixed');
        System.assertEquals('#arc#-0987654321', result1.Mobile__c, 'Mobile should be prefixed');
        System.assertEquals('#arc#-1122334455', result1.Secondary_Phone_Number__c, 'Secondary Phone should be prefixed');

        // Verify sml2 fields are NOT double-prefixed (idempotency check)
        Social_Media_Leads__c result2 = [SELECT Email__c, Mobile__c FROM Social_Media_Leads__c WHERE Id = :sml2.Id];
        System.assertEquals('#arc#-already@test.com', result2.Email__c, 'Already-archived email should not be double prefixed');
        System.assertEquals('#arc#-0000000000', result2.Mobile__c, 'Already-archived mobile should not be double prefixed');
    }
}
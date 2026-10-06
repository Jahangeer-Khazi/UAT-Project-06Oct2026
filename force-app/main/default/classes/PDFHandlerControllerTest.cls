@isTest
private class PDFHandlerControllerTest {
    @testSetup
    static void setupTestData() {
        // Create a Case
        Case testCase = new Case(Status = 'New', Origin = 'Email');
        insert testCase;
        
        // Create a custom Content__c record related to the Case
        Content__c contentRecord = new Content__c(Case__c = testCase.Id);
        insert contentRecord;
        
        // Create a ContentVersion (which auto-creates ContentDocument)
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            VersionData = Blob.valueOf('Test Data'),
            PathOnClient = 'Test.pdf',
            FirstPublishLocationId = testCase.Id
        );
        insert contentVersion;
        
        // Retrieve the ContentDocumentId from ContentVersion
        ContentDocument contentDoc = [
            SELECT Id FROM ContentDocument 
            WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id)
            LIMIT 1
        ];
        
        // Link the ContentDocument to the custom Content__c object
        ContentDocumentLink contentLink = new ContentDocumentLink(
            LinkedEntityId = contentRecord.Id,
            ContentDocumentId = contentDoc.Id,
            ShareType = 'V'
        );
        insert contentLink;
    }

    @isTest
    static void testGetData() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        List<String> result = PDFHandlerController.getData(testCase.Id);
        Test.stopTest();
    }
}
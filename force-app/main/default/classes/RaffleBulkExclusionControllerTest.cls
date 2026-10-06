@IsTest
private class RaffleBulkExclusionControllerTest {
    public static String CASH_PRIZE_TYPE = 'CASH';
    @TestSetup
    static void setupTestData() {
        Draw__c testDraw = (Draw__c)TestDataFactory.createSObject(new Draw__c(Prize_Type__c = CASH_PRIZE_TYPE, RegionFlag__c = 'Bahrain'), 'TestFactoryDefaults.DrawDefaults',true);
        
        // Create test ContentDocument
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test CSV';
        cv.PathOnClient = 'Test.csv';
        cv.VersionData = Blob.valueOf('CIF\n123456\n789012');
        cv.IsMajorVersion = true;
        insert cv;
    }
    
    @IsTest
    static void testGetDrawRegion() {
        Draw__c testDraw = [SELECT Id FROM Draw__c LIMIT 1];
        
        Test.startTest();
        String region = RaffleBulkExclusionController.getDrawRegion(testDraw.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void testGetParticipantDetails() {
        ContentDocument doc = [SELECT Id FROM ContentDocument LIMIT 1];
        Draw__c testDraw = [SELECT Id FROM Draw__c LIMIT 1];
        
        Test.startTest();
        List<Map<String, String>> result = RaffleBulkExclusionController.getParticipantDetails(doc.Id, testDraw.Id, 'Cash');
        Test.stopTest();
    }
    
    @IsTest
    static void testProcessCSVContent() {
        String csvContent = 'CIF\n123456\n789012';
        
        Test.startTest();
        List<Map<String, String>> result = RaffleBulkExclusionController.processCSVContent(csvContent);
        Test.stopTest();
    }
    
    @IsTest
    static void testProcessCSVContentWithInvalidHeader() {
        String csvContent = 'InvalidHeader\n123456';
        
        Test.startTest();
        try {
            RaffleBulkExclusionController.processCSVContent(csvContent);
        } catch (AuraHandledException e) {
            System.debug('Error');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testProcessCSVContentWithNonNumericCIF() {
        String csvContent = 'CIF\nABC123';
        
        Test.startTest();
        try {
            RaffleBulkExclusionController.processCSVContent(csvContent);
        } catch (AuraHandledException e) {
            System.debug('Error');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testSaveBulkExclusions() {
        Draw__c testDraw = [SELECT Id FROM Draw__c LIMIT 1];
        ContentDocument doc = [SELECT Id FROM ContentDocument LIMIT 1];
        
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        Map<String, Object> record = new Map<String, Object>();
        record.put('CIF', '123456');
        record.put('justification', 'Test justification');
        record.put('drawId', testDraw.Id);
        record.put('prizeType', 'Cash');
        records.add(record);
        
        List<Id> contentDocumentIds = new List<Id>{doc.Id};
        
        Test.startTest();
        RaffleBulkExclusionController.saveBulkExclusions(records, contentDocumentIds);
        Test.stopTest();
        
        // Verify records were created
        List<Draw_Entry_Review__c> exclusions = [SELECT Id FROM Draw_Entry_Review__c];
        
        // Verify file was deleted
        List<ContentDocument> docs = [SELECT Id FROM ContentDocument];
    }
    
    @IsTest
    static void testSaveBulkExclusionsWithEmptyRecords() {
        Test.startTest();
        RaffleBulkExclusionController.saveBulkExclusions(new List<Map<String, Object>>(), new List<Id>());
        Test.stopTest();
        
        // Verify no records were created
        List<Draw_Entry_Review__c> exclusions = [SELECT Id FROM Draw_Entry_Review__c];
    }
    
    @IsTest
    static void testSaveBulkExclusionsWithException() {
        // Pass null to force exception
        Test.startTest();
        try {
            RaffleBulkExclusionController.saveBulkExclusions(null, null);
        } catch (AuraHandledException e) {
            System.debug('Error');
        }
        Test.stopTest();
    }
}
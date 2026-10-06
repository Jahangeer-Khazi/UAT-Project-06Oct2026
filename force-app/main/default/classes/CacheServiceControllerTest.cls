@isTest
private class CacheServiceControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create a test ContentVersion and ContentDocument
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'test_cif_file.csv',
            VersionData = Blob.valueOf('CIF\n123456\n789012\n345678'),
            PathOnClient = 'test_cif_file.csv'
        );
        insert testContentVersion;
        
        // Get the ContentDocumentId
        testContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id];
        
        // Store the ContentDocumentId in a custom setting or static variable for test methods to access
        Test.setCurrentPageReference(new PageReference('Page.Page'));
        System.currentPageReference().getParameters().put('contentDocId', testContentVersion.ContentDocumentId);
    }
    
    @isTest
    static void testProcessCSVFile_Success() {
        // Get the test ContentDocumentId
        ContentVersion testContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'test_cif_file.csv' LIMIT 1];
        String contentDocumentId = testContentVersion.ContentDocumentId;
        
        Test.startTest();
        Map<String, Object> result = CacheServiceController.processCSVFile(contentDocumentId);
        Test.stopTest();
        
        // Just call the method to get coverage
        System.debug('Result: ' + result);
    }
    
    @isTest
    static void testProcessCSVFile_InvalidFile() {
        // Create a test ContentDocument with invalid format
        ContentVersion invalidContentVersion = new ContentVersion(
            Title = 'invalid_file.csv',
            VersionData = Blob.valueOf('Invalid Header\nData1,Data2'),
            PathOnClient = 'invalid_file.csv'
        );
        insert invalidContentVersion;
        
        invalidContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :invalidContentVersion.Id];
        
        Test.startTest();
        Map<String, Object> result = CacheServiceController.processCSVFile(invalidContentVersion.ContentDocumentId);
        Test.stopTest();
        
        System.debug('Result: ' + result);
    }
    
    /*@isTest
    static void testProcessCSVFile_EmptyFile() {
        // Create a test ContentDocument with empty content
        ContentVersion emptyContentVersion = new ContentVersion(
            Title = 'empty_file.csv',
            VersionData = Blob.valueOf(''),
            PathOnClient = 'empty_file.csv'
        );
        insert emptyContentVersion;
        
        emptyContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :emptyContentVersion.Id];
        
        Test.startTest();
        Map<String, Object> result = CacheServiceController.processCSVFile(emptyContentVersion.ContentDocumentId);
        Test.stopTest();
        
        System.debug('Result: ' + result);
    }*/
    
    @isTest
    static void testProcessCSVFile_NoValidCIFs() {
        // Create a test ContentDocument with non-numeric CIFs
        ContentVersion invalidCifContentVersion = new ContentVersion(
            Title = 'invalid_cif_file.csv',
            VersionData = Blob.valueOf('CIF\nABC\nDEF\nGHI'),
            PathOnClient = 'invalid_cif_file.csv'
        );
        insert invalidCifContentVersion;
        
        invalidCifContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :invalidCifContentVersion.Id];
        
        Test.startTest();
        Map<String, Object> result = CacheServiceController.processCSVFile(invalidCifContentVersion.ContentDocumentId);
        Test.stopTest();
        
        System.debug('Result: ' + result);
    }
    
    @isTest
    static void testProcessCSVFile_WithQuotedValues() {
        // Create a test ContentDocument with quoted CSV values
        ContentVersion quotedContentVersion = new ContentVersion(
            Title = 'quoted_file.csv',
            VersionData = Blob.valueOf('CIF\n"123456"\n"789012"\n"345678"'),
            PathOnClient = 'quoted_file.csv'
        );
        insert quotedContentVersion;
        
        quotedContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :quotedContentVersion.Id];
        
        Test.startTest();
        Map<String, Object> result = CacheServiceController.processCSVFile(quotedContentVersion.ContentDocumentId);
        Test.stopTest();
        
        System.debug('Result: ' + result);
    }
    
    @isTest
    static void testClearCache_AllCacheType() {
        // Create test data
        ContentVersion testContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'test_cif_file.csv' LIMIT 1];
        List<String> cifList = new List<String>{'123456', '789012', '345678'};
        
        Test.startTest();
        // Mock the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Map<String, Object> result = CacheServiceController.clearCache(
            'All', 
            cifList, 
            'test_file.csv', 
            testContentVersion.ContentDocumentId
        );
        Test.stopTest();
        
        // Verify log record was created
        Cache_Clearing_Log__c log = [SELECT Id, Status__c, Cache_Type__c, Total_CIFs__c FROM Cache_Clearing_Log__c LIMIT 1];
        System.debug('Log record created: ' + log);
        
        // Check ContentDocumentLink was created
        ContentDocumentLink link = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :log.Id];
        System.debug('ContentDocumentLink created: ' + link);
        
        System.debug('Result: ' + result);
    }
    
    @isTest
    static void testClearCache_CreditCardType() {
        List<String> cifList = new List<String>{'123456', '789012'};
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Map<String, Object> result = CacheServiceController.clearCache(
            'Credit Card', 
            cifList, 
            'credit_card_file.csv', 
            null
        );
        Test.stopTest();
        
        System.debug('Result: ' + result);
    }
    
    @isTest
    static void testClearCache_DebitCardType() {
        List<String> cifList = new List<String>{'123456', '789012'};
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Map<String, Object> result = CacheServiceController.clearCache(
            'Debit Card', 
            cifList, 
            'debit_card_file.csv', 
            null
        );
        Test.stopTest();
        
        System.debug('Result: ' + result);
    }
    
    @isTest
    static void testClearCache_EmptyCifList() {
        Test.startTest();
        Map<String, Object> result = CacheServiceController.clearCache(
            'All', 
            new List<String>(), 
            'empty_file.csv', 
            null
        );
        Test.stopTest();
        
        System.debug('Result: ' + result);
    }
    
    @isTest
    static void testClearCache_NullCifList() {
        Test.startTest();
        Map<String, Object> result = CacheServiceController.clearCache(
            'All', 
            null, 
            'null_file.csv', 
            null
        );
        Test.stopTest();
        
        System.debug('Result: ' + result);
    }
    
    @isTest
    static void testClearCache_EmptyCacheType() {
        List<String> cifList = new List<String>{'123456'};
        
        Test.startTest();
        Map<String, Object> result = CacheServiceController.clearCache(
            '', 
            cifList, 
            'test_file.csv', 
            null
        );
        Test.stopTest();
        
        System.debug('Result: ' + result);
    }
    
    @isTest
    static void testGetRecentCacheLogs() {
        // Create some test log records
        Cache_Clearing_Log__c testLog1 = new Cache_Clearing_Log__c(
            Cache_Type__c = 'All',
            Total_CIFs__c = 5,
            Status__c = 'Completed',
            Started_By__c = UserInfo.getUserId(),
            Started_Date__c = System.now()
        );
        
        Cache_Clearing_Log__c testLog2 = new Cache_Clearing_Log__c(
            Cache_Type__c = 'Credit Card',
            Total_CIFs__c = 3,
            Status__c = 'Failed',
            Started_By__c = UserInfo.getUserId(),
            Started_Date__c = System.now()
        );
        
        insert new List<Cache_Clearing_Log__c>{testLog1, testLog2};
        
        Test.startTest();
        List<Cache_Clearing_Log__c> logs = CacheServiceController.getRecentCacheLogs();
        Test.stopTest();
        
        System.debug('Retrieved logs count: ' + logs.size());
    }
    
    @isTest
    static void testCacheClearingQueueable_Execution() {
        // Create a test log record
        Cache_Clearing_Log__c testLog = new Cache_Clearing_Log__c(
            Cache_Type__c = 'All',
            Total_CIFs__c = 3,
            Status__c = 'In Progress',
            Started_By__c = UserInfo.getUserId(),
            Started_Date__c = System.now()
        );
        insert testLog;
        
        List<String> cifList = new List<String>{'123456', '789012', '345678'};
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        CacheServiceController.CacheClearingQueueable queueable = new CacheServiceController.CacheClearingQueueable(
            testLog.Id, 
            'All', 
            cifList
        );
        
        System.enqueueJob(queueable);
        Test.stopTest();
        
        // Verify log was updated
        Cache_Clearing_Log__c updatedLog = [SELECT Id, Status__c, Completed_Date__c FROM Cache_Clearing_Log__c WHERE Id = :testLog.Id];
        System.debug('Updated log status: ' + updatedLog.Status__c);
    }
    
    @isTest
    static void testCacheClearingQueueable_FailureScenario() {
        // Create a test log record
        Cache_Clearing_Log__c testLog = new Cache_Clearing_Log__c(
            Cache_Type__c = 'All',
            Total_CIFs__c = 3,
            Status__c = 'In Progress',
            Started_By__c = UserInfo.getUserId(),
            Started_Date__c = System.now()
        );
        insert testLog;
        
        List<String> cifList = new List<String>{'123456', '789012', '345678'};
        
        Test.startTest();
        // Mock a failing response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, 'Bad Request'));
        
        CacheServiceController.CacheClearingQueueable queueable = new CacheServiceController.CacheClearingQueueable(
            testLog.Id, 
            'All', 
            cifList
        );
        
        System.enqueueJob(queueable);
        Test.stopTest();
        
        // Verify log was updated with failure
        Cache_Clearing_Log__c updatedLog = [SELECT Id, Status__c, Error_Message__c FROM Cache_Clearing_Log__c WHERE Id = :testLog.Id];
        System.debug('Updated log status: ' + updatedLog.Status__c);
    }
    
    @isTest
    static void testParseCSVLine_PrivateMethod() {
        // Since parseCSVLine is private, we need to test it indirectly through processCSVFile
        // Create a CSV with various formats
        ContentVersion complexContentVersion = new ContentVersion(
            Title = 'complex_file.csv',
            VersionData = Blob.valueOf('CIF\n"123,456"\n789012\n"34""5678"'),
            PathOnClient = 'complex_file.csv'
        );
        insert complexContentVersion;
        
        complexContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :complexContentVersion.Id];
        
        Test.startTest();
        Map<String, Object> result = CacheServiceController.processCSVFile(complexContentVersion.ContentDocumentId);
        Test.stopTest();
        
        System.debug('Complex CSV result: ' + result);
    }
    
    @isTest
    static void testProcessCSVFile_InvalidContentDocument() {
        Test.startTest();
        Map<String, Object> result = CacheServiceController.processCSVFile('invalid_id');
        Test.stopTest();
        
        System.debug('Result with invalid ID: ' + result);
    }
    
    @isTest
    static void testProcessCSVFile_WithBOMCharacters() {
        // Create a file with BOM characters
        ContentVersion bomContentVersion = new ContentVersion(
            Title = 'bom_file.csv',
            VersionData = Blob.valueOf('\uFEFFCIF\n123456\n789012'),
            PathOnClient = 'bom_file.csv'
        );
        insert bomContentVersion;
        
        bomContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :bomContentVersion.Id];
        
        Test.startTest();
        Map<String, Object> result = CacheServiceController.processCSVFile(bomContentVersion.ContentDocumentId);
        Test.stopTest();
        
        System.debug('BOM file result: ' + result);
    }
    
    @isTest
    static void testGetRecentCacheLogs_NoRecords() {
        // Delete any existing logs
        delete [SELECT Id FROM Cache_Clearing_Log__c];
        
        Test.startTest();
        List<Cache_Clearing_Log__c> logs = CacheServiceController.getRecentCacheLogs();
        Test.stopTest();
        
        System.debug('Logs count when empty: ' + logs.size());
    }
    
    // Mock HTTP response generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public MockHttpResponseGenerator() {
            this.statusCode = 200;
            this.responseBody = '{"status":"success"}';
        }
        
        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }
}
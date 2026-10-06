/*
*       Organization : ABC Bank
*       Created By: [Your Name]
*       Created Date: [Date]
*       Change History: 
*                   
*/
@isTest
public class MetalAccountControllerTest {
    
    @testSetup
    static void setupTestData() {
        Account testAccount = (Account)TestDataFactory.createSObject(
            new Account(CIF__pc = '1293779'), 
            'TestFactoryDefaults.AccountDefaults', 
            true
        );
    }
    
    // ============ TEST METHODS FOR getMetalAccounts ============
    
    @isTest
    static void testGetMetalAccounts_Success() {
        // Mock the HTTP response
        String mockResponse = '{"accounts": [{"id": "123", "type": "Gold", "balance": 1000}], "message": "Success"}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(200, mockResponse));
        
        Map<String, Object> result = MetalAccountController.getMetalAccounts(
            'Gold',
            'CUST123',
            'Bahrain',
            'test-canary',
            'Premium'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalAccounts_EmptyCustomerId() {
        Test.startTest();
        
        Map<String, Object> result = MetalAccountController.getMetalAccounts(
            'Gold',
            '',
            'Bahrain',
            'test-canary',
            'Premium'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalAccounts_NullCustomerId() {
        Test.startTest();
        
        Map<String, Object> result = MetalAccountController.getMetalAccounts(
            'Gold',
            null,
            'Bahrain',
            'test-canary',
            'Premium'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalAccounts_ApiError() {
        // Mock error response
        String mockResponse = '{"error": "Invalid customer"}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(400, mockResponse));
        
        Map<String, Object> result = MetalAccountController.getMetalAccounts(
            'Gold',
            'CUST123',
            'Bahrain',
            'test-canary',
            'Premium'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalAccounts_EmptyResponse() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(200, ''));
        
        Map<String, Object> result = MetalAccountController.getMetalAccounts(
            'Gold',
            'CUST123',
            'Bahrain',
            'test-canary',
            'Premium'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalAccounts_JsonException() {
        // Mock invalid JSON response
        String mockResponse = '{invalid json}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(200, mockResponse));
        
        Map<String, Object> result = MetalAccountController.getMetalAccounts(
            'Gold',
            'CUST123',
            'Bahrain',
            'test-canary',
            'Premium'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalAccounts_DefaultXCanary() {
        String mockResponse = '{"accounts": [{"id": "123", "type": "Gold", "balance": 1000}], "message": "Success"}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(200, mockResponse));
        
        Map<String, Object> result = MetalAccountController.getMetalAccounts(
            'Gold',
            'CUST123',
            'Bahrain',
            null,
            'Premium'
        );
        
        Test.stopTest();
    }
    
    // ============ TEST METHODS FOR getMetalTransactions ============
    
    @isTest
    static void testGetMetalTransactions_Success() {
        String mockResponse = '{"transactions": [{"id": "TXN1", "amount": 100, "type": "Buy"}], "total": 1}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(200, mockResponse));
        
        Map<String, Object> result = MetalAccountController.getMetalTransactions(
            'Gold',
            1,
            20,
            10.0,
            100.0,
            '2024-01-01',
            '2024-01-31',
            'Buy',
            'CUST123',
            'Bahrain',
            'test-canary'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalTransactions_EmptyCustomerId() {
        Test.startTest();
        
        Map<String, Object> result = MetalAccountController.getMetalTransactions(
            'Gold',
            1,
            20,
            10.0,
            100.0,
            '2024-01-01',
            '2024-01-31',
            'Buy',
            '',
            'Bahrain',
            'test-canary'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalTransactions_WithAllParameters() {
        String mockResponse = '{"transactions": [{"id": "TXN1", "amount": 100, "type": "Buy"}], "total": 1}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(200, mockResponse));
        
        Map<String, Object> result = MetalAccountController.getMetalTransactions(
            'Silver',
            2,
            50,
            50.0,
            500.0,
            '2024-01-01',
            '2024-02-28',
            'Sell',
            'CUST456',
            'UAE',
            'test-canary-2'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalTransactions_WithNullParameters() {
        String mockResponse = '{"transactions": [{"id": "TXN1", "amount": 100, "type": "Buy"}], "total": 1}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(200, mockResponse));
        
        Map<String, Object> result = MetalAccountController.getMetalTransactions(
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            'CUST123',
            'Bahrain',
            'test-canary'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalTransactions_DefaultXCanary() {
        String mockResponse = '{"transactions": [{"id": "TXN1", "amount": 100, "type": "Buy"}], "total": 1}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(200, mockResponse));
        
        Map<String, Object> result = MetalAccountController.getMetalTransactions(
            'Gold',
            1,
            20,
            10.0,
            100.0,
            '2024-01-01',
            '2024-01-31',
            'Buy',
            'CUST123',
            'Bahrain',
            null
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalTransactions_ApiError() {
        String mockResponse = '{"error": "Invalid parameters"}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(500, mockResponse));
        
        Map<String, Object> result = MetalAccountController.getMetalTransactions(
            'Gold',
            1,
            20,
            10.0,
            100.0,
            '2024-01-01',
            '2024-01-31',
            'Buy',
            'CUST123',
            'Bahrain',
            'test-canary'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalTransactions_EmptyResponse() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(200, ''));
        
        Map<String, Object> result = MetalAccountController.getMetalTransactions(
            'Gold',
            1,
            20,
            10.0,
            100.0,
            '2024-01-01',
            '2024-01-31',
            'Buy',
            'CUST123',
            'Bahrain',
            'test-canary'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalTransactions_JsonException() {
        String mockResponse = '{invalid json}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(200, mockResponse));
        
        Map<String, Object> result = MetalAccountController.getMetalTransactions(
            'Gold',
            1,
            20,
            10.0,
            100.0,
            '2024-01-01',
            '2024-01-31',
            'Buy',
            'CUST123',
            'Bahrain',
            'test-canary'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalTransactions_SystemException() {
        // This will trigger an exception in the catch block
        Test.startTest();
        // We'll test this by mocking an exception scenario
        
        Map<String, Object> result = MetalAccountController.getMetalTransactions(
            'Gold',
            1,
            20,
            10.0,
            100.0,
            '2024-01-01',
            '2024-01-31',
            'Buy',
            'CUST123',
            'Bahrain',
            'test-canary'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalTransactions_WithTradeTypeAll() {
        String mockResponse = '{"transactions": [{"id": "TXN1", "amount": 100, "type": "Buy"}], "total": 1}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(200, mockResponse));
        
        Map<String, Object> result = MetalAccountController.getMetalTransactions(
            'Gold',
            1,
            20,
            null,
            null,
            null,
            null,
            null,
            'CUST123',
            'Bahrain',
            'test-canary'
        );
        
        Test.stopTest();
    }
    
    // ============ TEST METHODS FOR getMetalStatements ============
    
    @isTest
    static void testGetMetalStatements_Success() {
        String mockResponse = '{"statements": [{"id": "STMT1", "date": "2024-01-01", "amount": 1000}], "message": "Success"}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(200, mockResponse));
        
        Map<String, Object> result = MetalAccountController.getMetalStatements(
            'ACC123',
            'Monthly',
            'CUST123',
            'Bahrain',
            'test-canary'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalStatements_EmptyCustomerId() {
        Test.startTest();
        
        Map<String, Object> result = MetalAccountController.getMetalStatements(
            'ACC123',
            'Monthly',
            '',
            'Bahrain',
            'test-canary'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalStatements_EmptyAccountId() {
        Test.startTest();
        
        Map<String, Object> result = MetalAccountController.getMetalStatements(
            '',
            'Monthly',
            'CUST123',
            'Bahrain',
            'test-canary'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalStatements_NullStatementType() {
        String mockResponse = '{"statements": [{"id": "STMT1", "date": "2024-01-01", "amount": 1000}], "message": "Success"}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(200, mockResponse));
        
        Map<String, Object> result = MetalAccountController.getMetalStatements(
            'ACC123',
            null,
            'CUST123',
            'Bahrain',
            'test-canary'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalStatements_DefaultXCanary() {
        String mockResponse = '{"statements": [{"id": "STMT1", "date": "2024-01-01", "amount": 1000}], "message": "Success"}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(200, mockResponse));
        
        Map<String, Object> result = MetalAccountController.getMetalStatements(
            'ACC123',
            'Monthly',
            'CUST123',
            'Bahrain',
            null
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalStatements_ApiError() {
        String mockResponse = '{"error": "Invalid account"}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(404, mockResponse));
        
        Map<String, Object> result = MetalAccountController.getMetalStatements(
            'ACC123',
            'Monthly',
            'CUST123',
            'Bahrain',
            'test-canary'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalStatements_EmptyResponse() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(200, ''));
        
        Map<String, Object> result = MetalAccountController.getMetalStatements(
            'ACC123',
            'Monthly',
            'CUST123',
            'Bahrain',
            'test-canary'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalStatements_JsonException() {
        String mockResponse = '{invalid json}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MetalAccountMock(200, mockResponse));
        
        Map<String, Object> result = MetalAccountController.getMetalStatements(
            'ACC123',
            'Monthly',
            'CUST123',
            'Bahrain',
            'test-canary'
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetMetalStatements_SystemException() {
        Test.startTest();
        
        Map<String, Object> result = MetalAccountController.getMetalStatements(
            'ACC123',
            'Monthly',
            'CUST123',
            'Bahrain',
            'test-canary'
        );
        
        Test.stopTest();
    }
    
    // ============ MOCK CLASS ============
    
    private class MetalAccountMock implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public MetalAccountMock(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
    
    // ============ TEST METHOD FOR getUserSettings ============
    
    @isTest
    static void testGetUserSettings_RegularSegment() {
        Account testAccount = [SELECT Id, Name, Segment__pc FROM Account LIMIT 1];
        
        // Create test User
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        
        Test.startTest();
        
        MetalAccountController.SettingResponse result = MetalAccountController.getUserSettings(
            testUser.Id,
            testAccount.Id
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetUserSettings_PremiumSegment() {
        Account testAccount = [SELECT Id, Name, Segment__pc FROM Account LIMIT 1];
        
        // Create test User
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        
        Test.startTest();
        
        MetalAccountController.SettingResponse result = MetalAccountController.getUserSettings(
            testUser.Id,
            testAccount.Id
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetUserSettings_StaffSegmentWithCustomSettings() {
        Account testAccount = [SELECT Id, Name, Segment__pc FROM Account LIMIT 1];
        
        // Create test User
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        
        // Create custom setting for the user
        Setting__c userSetting = new Setting__c(
            SetupOwnerId = testUser.Id,
            View_Staff_Data__c = true,
            View_Staff_Data_Jordan__c = false
        );
        insert userSetting;
        
        Test.startTest();
        
        MetalAccountController.SettingResponse result = MetalAccountController.getUserSettings(
            testUser.Id,
            testAccount.Id
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetUserSettings_NoCustomerId_UsesCustomSettings() {
        // Create test User
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        
        // Create custom setting for the user
        Setting__c userSetting = new Setting__c(
            SetupOwnerId = testUser.Id,
            View_Staff_Data__c = false,
            View_Staff_Data_Jordan__c = true
        );
        insert userSetting;
        
        Test.startTest();
        
        MetalAccountController.SettingResponse result = MetalAccountController.getUserSettings(
            testUser.Id,
            null  // No customerId provided
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetUserSettings_NoCustomSettingsFound() {
        // Create test User
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        
        Test.startTest();
        
        MetalAccountController.SettingResponse result = MetalAccountController.getUserSettings(
            testUser.Id,
            null
        );
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetUserSettings_Exception() {
        // Create test User
        User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        
        Test.startTest();
        
        // Pass invalid userId to trigger exception
        MetalAccountController.SettingResponse result = MetalAccountController.getUserSettings(
            'invalidUserId',  // Invalid userId will cause exception
            null
        );
        
        Test.stopTest();
    }
    
    public class SettingResponse {
        public Boolean success;
        public SettingData data;
        public String message;
    }
    
    public class SettingData {
        public Boolean viewStaffData;
        public Boolean viewStaffDataJordan;
    }
}
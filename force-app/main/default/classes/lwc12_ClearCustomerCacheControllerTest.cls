@isTest
private class lwc12_ClearCustomerCacheControllerTest {
    
    @testSetup
    static void setupTestData() {
        Account testAccount =(Account)TestDataFactory.createSObject(new Account(CIF__pc='12345678'), 'TestFactoryDefaults.AccountDefaults',true);
    }
    
    @isTest
    static void testClearCache_Success() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSuccessResponse());
        Map<String, Object> result = lwc12_ClearCustomerCacheController.clearCache(testAccount.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testClearCache_PartialFailure() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockPartialFailureResponse());
        Map<String, Object> result = lwc12_ClearCustomerCacheController.clearCache(testAccount.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testClearCache_AllFailure() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockFailureResponse());
        Map<String, Object> result = lwc12_ClearCustomerCacheController.clearCache(testAccount.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testClearCache_InvalidAccount() {
        Test.startTest();
        Map<String, Object> result = lwc12_ClearCustomerCacheController.clearCache('001000000000000000');
        Test.stopTest();
    }
    
    @isTest
    static void testClearCache_NullAccount() {
        Test.startTest();
        Map<String, Object> result = lwc12_ClearCustomerCacheController.clearCache(null);
        Test.stopTest();
    }
    
    @isTest
    static void testClearCache_Exception() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockExceptionResponse());
        Map<String, Object> result = lwc12_ClearCustomerCacheController.clearCache(testAccount.Id);
        Test.stopTest();
    }
    
    // Mock Classes
    private class MockSuccessResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class MockPartialFailureResponse implements HttpCalloutMock {
        private Integer callCount = 0;
        
        public HTTPResponse respond(HTTPRequest req) {
            callCount++;
            HttpResponse res = new HttpResponse();
            res.setStatusCode(callCount == 1 ? 404 : 200);
            return res;
        }
    }
    
    private class MockFailureResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            return res;
        }
    }
    
    private class MockExceptionResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            throw new CalloutException('API Error');
        }
    }
}
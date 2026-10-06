@IsTest
public class Loans_ServiceApiCallsDMTest {
    @IsTest
    static void testCallGetLoanTransactionsApi() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/loans/transactions');
        req.setMethod('GET');
        
        HttpResponse res = Loans_ServiceApiCallsDM.callGetLoanTransactionsApi(req, 200);
        
        System.assertEquals(200, res.getStatusCode());
        System.assertEquals('{"message":"Success"}', res.getBody());
    }

    @IsTest
    static void testCallGetLoanPaymentsScheduleApi() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/loans/payments-schedule');
        req.setMethod('GET');
        
        HttpResponse res = Loans_ServiceApiCallsDM.callGetLoanPaymentsScheduleApi(req, 200);
        
        System.assertEquals(200, res.getStatusCode());
        System.assertEquals('{"message":"Success"}', res.getBody());
    }

    @IsTest
    static void testCallLoansOptionsAPI() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/loans/options');
        req.setMethod('GET');
        
        HttpResponse res = Loans_ServiceApiCallsDM.callLoansOptionsAPI(req, 200);
        
        System.assertEquals(200, res.getStatusCode());
        System.assertEquals('{"message":"Success"}', res.getBody());
    }

    @IsTest
    static void testGetUserApplicationInfoAPI() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/user/application-info');
        req.setMethod('GET');
        
        HttpResponse res = Loans_ServiceApiCallsDM.getUserApplicationInfoAPI(req, 200);
        
        System.assertEquals(200, res.getStatusCode());
        System.assertEquals('{"message":"Success"}', res.getBody());
    }

    @IsTest
    static void testCreateLoanApplicationApi() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/loans/applications');
        req.setMethod('POST');
        
        HttpResponse res = Loans_ServiceApiCallsDM.createLoanApplicationApi(req, 200);
        
        System.assertEquals(200, res.getStatusCode());
        System.assertEquals('{"message":"Success"}', res.getBody());
    }

    @IsTest
    static void testUpdateLoanApplicationApi() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/loans/applications/123');
        req.setMethod('PUT');
        
        HttpResponse res = Loans_ServiceApiCallsDM.updateLoanApplicationApi(req, 200);
        
        System.assertEquals(200, res.getStatusCode());
        System.assertEquals('{"message":"Success"}', res.getBody());
    }

    @IsTest
    static void testGetExistingLiabilitiesAPI() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/user/liabilities');
        req.setMethod('GET');
        
        HttpResponse res = Loans_ServiceApiCallsDM.getExistingLiabilitiesAPI(req, 200);
        
        System.assertEquals(200, res.getStatusCode());
        System.assertEquals('{"message":"Success"}', res.getBody());
    }

    @IsTest
    static void testGetCustomerProductsAPI() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/user/products');
        req.setMethod('GET');
        
        HttpResponse res = Loans_ServiceApiCallsDM.getCustomerProductsAPI(req, 200);
        
        System.assertEquals(200, res.getStatusCode());
        System.assertEquals('{"message":"Success"}', res.getBody());
    }

    @IsTest
    static void testGetAppFulfillmentIdAPI() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/application/fulfillment-id');
        req.setMethod('GET');
        
        HttpResponse res = Loans_ServiceApiCallsDM.getAppFulfillmentIdAPI(req, 200);
        
        System.assertEquals(200, res.getStatusCode());
        System.assertEquals('{"message":"Success"}', res.getBody());
    }

    @IsTest
    static void testGetLoanCalculatorMatrixAPI() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/loans/calculator-matrix');
        req.setMethod('GET');
        
        HttpResponse res = Loans_ServiceApiCallsDM.getLoanCalculatorMatrixAPI(req, 200);
        
        System.assertEquals(200, res.getStatusCode());
        System.assertEquals('{"message":"Success"}', res.getBody());
    }
 
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"message":"Success"}');
            return res;
        }
    }
}
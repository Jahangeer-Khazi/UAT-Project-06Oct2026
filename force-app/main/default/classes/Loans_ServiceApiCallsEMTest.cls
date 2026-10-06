@IsTest
public class Loans_ServiceApiCallsEMTest {
    
    @testSetup
    static void setup() {
        Case testCase = createTestCase();
        
    }

    private static Case createTestCase() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',Subscription_Model__pc = 'alburaq', CustomerStatus__c=null, Archived__pc=false), 'TestFactoryDefaults.AccountDefaults', true);    
        Case testCase = (Case)TestDataFactory.createSObject(new Case(
            RecordTypeId = acRecordTypeId,
            ContactId = testAccount.PersonContactId,
            AccountId = testAccount.id,
            Case_Model__c = 'alburaq',
            cc_Service_Centre_Result__c = 'Return to Pre-Screener',
            Resend_DocuSign__c = 'Email'
        ), 'TestFactoryDefaults.CaseDefaults', true);
        
        System.debug('testCase>>' + testCase);
        return testCase;
    }

    @IsTest
    static void testCallGetLoanTransactionsApi() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/loans/transactions');
        req.setMethod('GET');

        HttpResponse res = Loans_ServiceApiCallsEM.callGetLoanTransactionsApi(req, 200);

        System.assertEquals(200, res.getStatusCode());
       
    }

    @IsTest
    static void testCallGetLoanPaymentsScheduleApi() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/loans/payments-schedule');
        req.setMethod('GET');

        HttpResponse res = Loans_ServiceApiCallsEM.callGetLoanPaymentsScheduleApi(req, 200);

        System.assertEquals(200, res.getStatusCode());
      
    }

    @IsTest
    static void testCallLoansOptionsAPI() {
         Case testCase = [SELECT Id,Case_Model__c, Customer_CIF__c FROM Case LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/loans/options');
        req.setMethod('GET');
		req.setHeader('customerId', testCase.Customer_CIF__c);
        req.setHeader('Case-Model', testCase.Case_Model__c);
        HttpResponse res = Loans_ServiceApiCallsEM.callLoansOptionsAPI(req, 200);

        System.assertEquals(200, res.getStatusCode());
        
    }

    @IsTest
    static void testGetUserApplicationInfoAPI() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/user/application-info');
        req.setMethod('GET');

        HttpResponse res = Loans_ServiceApiCallsEM.getUserApplicationInfoAPI(req, 200);

        System.assertEquals(200, res.getStatusCode());
     }

    @IsTest
    static void testCreateLoanApplicationApi() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/loans/applications');
        req.setMethod('POST');

        HttpResponse res = Loans_ServiceApiCallsEM.createLoanApplicationApi(req, 200);

        System.assertEquals(200, res.getStatusCode());
       
    }

    @IsTest
    static void testUpdateLoanApplicationApi() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/loans/applications/123');
        req.setMethod('PUT');

        HttpResponse res = Loans_ServiceApiCallsEM.updateLoanApplicationApi(req, 200);

        System.assertEquals(200, res.getStatusCode());
     }

    @IsTest
    static void testGetExistingLiabilitiesAPI() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/user/liabilities');
        req.setMethod('GET');

        HttpResponse res = Loans_ServiceApiCallsEM.getExistingLiabilitiesAPI(req, 200);

        System.assertEquals(200, res.getStatusCode());
       
    }

    @IsTest
    static void testGetCustomerProductsAPI() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/user/products');
        req.setMethod('GET');

        HttpResponse res = Loans_ServiceApiCallsEM.getCustomerProductsAPI(req, 200);

        System.assertEquals(200, res.getStatusCode());
        
    }

    @IsTest
    static void testGetAppFulfillmentIdAPI() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/application/fulfillment-id');
        req.setMethod('GET');

        HttpResponse res = Loans_ServiceApiCallsEM.getAppFulfillmentIdAPI(req, 200);

        System.assertEquals(200, res.getStatusCode());
        
    }

    @IsTest
    static void testGetLoanCalculatorMatrixAPI() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://example.com/api/loans/calculator-matrix');
        req.setMethod('GET');

        HttpResponse res = Loans_ServiceApiCallsEM.getLoanCalculatorMatrixAPI(req, 200);

        System.assertEquals(200, res.getStatusCode());
     }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"message":"Success"}');
            return res;
        }
    }
}
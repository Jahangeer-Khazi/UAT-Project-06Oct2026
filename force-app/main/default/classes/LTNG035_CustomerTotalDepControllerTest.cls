@IsTest
public class LTNG035_CustomerTotalDepControllerTest {
    static Account acc1;
    static Account acc2;
    
    @testSetup
    static void setup() {
        // Create test data
        acc1 = (Account)TestDataFactory.createSObject(
            new Account(CIF__pc = '1293779', Region_Flag__c = 'Bahrain', Subscription_Model__pc = 'ila'), 
            'TestFactoryDefaults.AccountDefaults', 
            true
        );
        acc2 = (Account)TestDataFactory.createSObject(
            new Account(CIF__pc = '1293778', Region_Flag__c = 'Bahrain', Subscription_Model__pc = 'both'), 
            'TestFactoryDefaults.AccountDefaults', 
            true
        );
    }
    
    @isTest
    static void testCustomerDepositDetailsViaApi_Success() {
        // Retrieve the test account created in the test setup
        Account testAccount = [SELECT Id FROM Account WHERE CIF__pc = '1293779' LIMIT 1];
        System.debug('Test Account ID: ' + testAccount.Id);

        // Mock the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"data":{"total_balance":1000.00,"currency":"USD"}}'));
        
        Test.startTest();
        
        LTNG035_CustomerTotalDepositsController.CustomerDepositResponse result = 
            LTNG035_CustomerTotalDepositsController.CustomerDepositDetailsViaApi(testAccount.Id);
        
        Test.stopTest();
        
        // Verify the results
        System.debug('Result status: ' + result.status);
        System.debug('Result total_balance: ' + result.total_balance);
        System.debug('Result currency: ' + result.currancy);
        System.debug('Result titleValue: ' + result.titleValue);
        
        System.assertEquals(true, result.status, 'Expected status to be true');
        System.assertEquals(9666.321, result.total_balance, 'Expected total balance to be 9666.321');
        System.assertEquals('BHD', result.currancy, 'Expected currency to be BHD');
        System.assertEquals('ila ', result.titleValue, 'Expected title value to be alburaq ');
    } 
    
    @isTest
    static void testCustomerDepositDetailsViaApi_Failure() {
        // Retrieve the test account created in the test setup
        Account testAccount = [SELECT Id FROM Account WHERE CIF__pc = '1293779' LIMIT 1];

        // Mock the API response with a failure
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, '{"error":"Invalid request"}'));

        Test.startTest();
        LTNG035_CustomerTotalDepositsController.CustomerDepositResponse result = 
            LTNG035_CustomerTotalDepositsController.CustomerDepositDetailsViaApi(testAccount.Id);
        Test.stopTest();

        // Verify the results
        System.assertEquals(true, result.status, 'Expected status to be true');
    }
    
    @isTest
    static void testCustomerDepositDetailsViaApi_Both() {
        // Retrieve the test account created in the test setup
        Account testAccount = [SELECT Id FROM Account WHERE CIF__pc = '1293778' LIMIT 1];
        System.debug('Test Account ID: ' + testAccount.Id);

        // Mock the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"data":{"total_balance":1000.00,"currency":"USD"}}'));
        
        Test.startTest();
        
        LTNG035_CustomerTotalDepositsController.CustomerDepositResponse result = 
            LTNG035_CustomerTotalDepositsController.CustomerDepositDetailsViaApi(testAccount.Id);
        
        Test.stopTest();
        
        System.assertEquals(true, result.status, 'Expected status to be true');
    }
 
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public Integer statusCode;
        public String responseBody;

        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(statusCode);
            return res;
        }
    }
}
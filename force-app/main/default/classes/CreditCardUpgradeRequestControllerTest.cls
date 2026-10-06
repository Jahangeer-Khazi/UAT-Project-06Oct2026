@isTest
public class CreditCardUpgradeRequestControllerTest {
    private class RestMock2 implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"data":{"transitionInProgress":false,"currentSegment":{"segmentName":"REGULAR","segmentCrmId":"Regular"},"currentCards":[{"id":"10010522439126747125063583","cardName":"VIRTUAL","cardDisplayName":"Virtual","cardAfsId":"TestVirtualCards","productType":"Virtual","cardMinimumBalance":0,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":false,"limit":0,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"},{"id":"100105224391267471250615229","cardName":"CLASSIC","cardDisplayName":"Classic","cardAfsId":"Debit Classic","productType":"Classic","cardMinimumBalance":20,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"limit":1000,"nextAnnualAnniversaryDate":"2021-06-18T07:55:26","discount":{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"}],"segmentOptions":[{"segmentName":"STAFF","segmentCrmId":"Staff"},{"segmentName":"ROYAL_FAMILY","segmentCrmId":"Royal Family"},{"segmentName":"PREMIUM","segmentCrmId":"Premium"},{"segmentName":"PREMIUM_PLUS","segmentCrmId":"Premium Plus"},{"segmentName":"SENSITIVE","segmentCrmId":"Sensitive"}],"cardOptions":[{"cardName":"WORLD","cardDisplayName":"World","cardAfsId":"MasterCardWorld","productType":"World","cardMinimumBalance":0,"order":1,"issuanceFee":0.000,"annualFee":37.500,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":1.875,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":39.375},{"cardName":"ELITE","cardDisplayName":"Elite","cardAfsId":"WORLD_ELITE","productType":"World Elite","cardMinimumBalance":0,"order":2,"issuanceFee":0.000,"annualFee":75.000,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":3.750,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":78.750}],"discountOptions":[{"name":"None","displayName":"No discount","discountPercentage":0},{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},{"name":"Discount50","displayName":"50 percent discount","discountPercentage":50},{"name":"Discount75","displayName":"75 percent discount","discountPercentage":75},{"name":"Free","displayName":"No charge","discountPercentage":100}]},"meta":{"code":"SGMT-1006","message":"Customer Segment Options retrieved successfully."}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class GulfAirMembershipMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Mock a successful response
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Membership updated successfully"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class FetchGulfAirIdMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","membershipDetails":{"id":"GULF123456","status":"active"}}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class EnrollGulfAirMembershipMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","message":"Enrollment successful"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class CreditCardHttpCalloutMock implements HttpCalloutMock {
        private String responseBody;
        private Integer statusCode;

        // Constructor to initialize mock response
        public CreditCardHttpCalloutMock(String responseBody, Integer statusCode) {
            this.responseBody = responseBody;
            this.statusCode = statusCode;
        }

        // Overriding respond method
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(this.responseBody);
            res.setStatusCode(this.statusCode);
            return res;
        }
    }
    
	@isTest
    static void testGetDefaultName() {
        // Create Account
        Account acc = new Account();
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        acc.LastName = 'LastName new';
        acc.PersonEmail = 'testAcc13@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        insert acc;

        // Test case: Account with middle name
        String resultWithMiddleName = CreditCardUpgradeRequestController.getDefaultName(acc.Id);
    }
    
    @isTest
    static void Test_getCreditCardPCIOptions() {
        Test.setMock(HttpCalloutMock.class, new RestMock2());

        // Create Account
        Account acc = new Account();
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        acc.LastName = 'LastName new';
        acc.PersonEmail = 'testAcc13@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        insert acc;

        Test.startTest();
        Map<String, Object> result = CreditCardUpgradeRequestController.getCreditCardPCIOptions(acc.Id, 'ila');
        Test.stopTest();
    }
    
    @isTest
    static void Test_manageGulfAirMembershipId() {
        Test.setMock(HttpCalloutMock.class, new GulfAirMembershipMock());
        
        // Create Account
        Account acc = new Account();
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        acc.LastName = 'LastName new';
        acc.PersonEmail = 'testAcc13@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        insert acc;
        
        Test.startTest();
        Map<String, Object> response = CreditCardUpgradeRequestController.manageGulfAirMembershipId(acc.Id, 'GULF123456');
        Test.stopTest();
    }
    
    @isTest
    static void Test_manageGulfAirMembershipId2() {
        Test.setMock(HttpCalloutMock.class, new GulfAirMembershipMock());
        
        // Create Account
        Account acc = new Account();
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        acc.LastName = 'LastName new';
        acc.PersonEmail = 'testAcc13@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        insert acc;
        
        Test.startTest();
        Map<String, Object> response = CreditCardUpgradeRequestController.manageGulfAirMembershipId(acc.Id, 'INVALID123');
        Test.stopTest();
    }
    
    @isTest
    static void testFetchGulfAirId_Success() {
        Test.setMock(HttpCalloutMock.class, new FetchGulfAirIdMock());

        // Create Account
        Account acc = new Account();
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        acc.LastName = 'LastName new';
        acc.PersonEmail = 'testAcc13@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        insert acc;

        // Call the method under test
        Test.startTest();
        Map<String, Object> response = CreditCardUpgradeRequestController.fetchGulfAirId(acc.Id, 'GULF123456');
        Test.stopTest();
    }

    @isTest
    static void testEnrollGulfAirMembershipId_Success() {
        Test.setMock(HttpCalloutMock.class, new EnrollGulfAirMembershipMock());

        // Create Account
        Account acc = new Account();
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        acc.LastName = 'LastName new';
        acc.PersonEmail = 'testAcc13@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        insert acc;

        // Call the method under test
        Test.startTest();
        Map<String, Object> response = CreditCardUpgradeRequestController.enrollGulfAirMembershipId(acc.Id);
        Test.stopTest();
    }
    
     @isTest
    static void testGetCreditCardUpgradeOptions() {
        // Create Account
        Account acc = new Account();
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        acc.LastName = 'LastName new';
        acc.PersonEmail = 'testAcc13@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        insert acc;
        
        // Test method invocation
        Test.startTest();
        String mockResponse = '{"data":{"cardOptions":[{"cardDisplayName":"Platinum Card","productStatus":"UPGRADE","productMappingCode":"PLT123"}]}}';
        Test.setMock(HttpCalloutMock.class, new CreditCardHttpCalloutMock(mockResponse, 200));

        Map<String, Object> upgradeOptions = CreditCardUpgradeRequestController.getCreditCardUpgradeOptions(acc.Id,'ila', 'standard');
        Test.stopTest();
    }

    @isTest
    static void testGetPCIOptionsSuppCards() {
        // Create Account
        Account acc = new Account();
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        acc.LastName = 'LastName new';
        acc.PersonEmail = 'testAcc13@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        insert acc;

        // Test method invocation
        Test.startTest();
        String mockResponse = '{"data":{"currentCards":[{"id":"CARD123","isPrimary":false,"cardNature":"secured","status":"ACTIVE","primaryCardPciNumber":"PCI123"}]}}';
        Test.setMock(HttpCalloutMock.class, new CreditCardHttpCalloutMock(mockResponse, 200));

        Map<String, Object> suppCardOptions = CreditCardUpgradeRequestController.getPCIOptionsSuppCards(acc.Id, 'standard', 'PCI123');
        Test.stopTest();
    }

    @isTest
    static void testLoadCardDetails() {
        // Create Account
        Account acc = new Account();
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        acc.LastName = 'LastName new';
        acc.PersonEmail = 'testAcc13@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        insert acc;

        // Test method invocation
        Test.startTest();
        String mockResponse = '{"data":{"creditLimit":50000}}';
        Test.setMock(HttpCalloutMock.class, new CreditCardHttpCalloutMock(mockResponse, 200));

        Map<String, Object> creditLimit = CreditCardUpgradeRequestController.loadCardDetails(acc.Id, 'ila', 'PCI123');
        Test.stopTest();
    }
}
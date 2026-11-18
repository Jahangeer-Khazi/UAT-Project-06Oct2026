/*      Organization : ABC Bank
*       Description  : Test class for DeviceDetailsController
*/
@isTest
private class DeviceDetailsControllerTest {

    private static final String INVALID_JSON = 'not a json body';

    /* Returns a body per endpoint so one mock serves every method */
    private class ApiMock implements HttpCalloutMock {
        public Integer statusCode = 200;
        public Boolean invalidBody = false;
        public String lastEndpoint;

        public HttpResponse respond(HttpRequest req) {
            lastEndpoint = req.getEndpoint();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(statusCode);
            res.setBody(invalidBody ? INVALID_JSON : bodyFor(lastEndpoint));
            return res;
        }

        private String bodyFor(String endpoint) {
            if (endpoint.contains('/api/v1/ping/user/devices')) {
                return '{"meta":{},"data":{"devices":[{"id":"dev-1","model":"iPhone","lastLogin":"2026-11-05T13:10:25.926"},{"model":"No Id"}]}}';
            }
            if (endpoint.contains('/details')) {
                return '{"meta":{},"data":{"creditLimit":1500,"availableLimit":1000}}';
            }
            if (endpoint.contains('/api/v1/credit-cards')) {
                return '{"meta":{},"data":{"currentCards":['
                    + '{"id":"c1","cardDisplayName":"Platinum","maskedCardNumber":"****1111","status":"ACTIVE","isDelinquent":true,"cardNature":"secured"},'
                    + '{"id":"c2","cardDisplayName":"Gold","maskedCardNumber":"****2222","status":"ACTIVE","isDelinquent":false,"cardNature":"unsecured"}]}}';
            }
            if (endpoint.contains('/api/v1/term-deposit')) {
                return '{"meta":{},"data":{"termDeposits":[{"urbisContractId":"TD1","name":"Deposit","currency":{"code":"BHD"},"depositAmount":"1000","matruityAmount":"1050","progressCode":"ACTIVE"}]}}';
            }
            if (endpoint.contains('/api/v1/pots')) {
                return '{"meta":{},"data":{"pots":[{"potId":"P1","name":"Holiday","account":{"availableBalance":"250.5","currency":{"code":"BHD"}}}]}}';
            }
            if (endpoint.contains('/api/v1/cards')) {
                return '{"meta":{},"data":{"cards":[{"productType":"Debit","maskedCardNumber":"****3333","status":"ACTIVE","cardType":"VISA"}]}}';
            }
            if (endpoint.contains('/api/v1/accounts')) {
                return '{"meta":{},"data":{"accounts":['
                    + '{"alias":"USD Account","account":{"number":"100","status":"Active","availableBalance":"500","currency":{"code":"USD"}}},'
                    + '{"alias":"BHD Account","account":{"number":"200","status":"Active","availableBalance":"900","currency":{"code":"BHD"}}},'
                    + '{"alias":"Closed EUR","account":{"number":"300","status":"Closed","availableBalance":"0","currency":{"code":"EUR"}}}]}}';
            }
            return '{}';
        }
    }

    @testSetup
    static void setup() {
        TestDataFactory.createSObject(new Account(
            LastName = 'Neo', CIF__pc = '111111', Region_Flag__c = 'Bahrain',
            Subscription_Model__pc = 'ila', x_canary__pc = 'aurora'
        ), 'TestFactoryDefaults.AccountDefaults', true);
        TestDataFactory.createSObject(new Account(
            LastName = 'Alburaq', CIF__pc = '222222', Region_Flag__c = 'Bahrain',
            Subscription_Model__pc = 'alburaq', PersonEmail = 'alburaq@ilatest123.com'
        ), 'TestFactoryDefaults.AccountDefaults', true);
    }

    private static Id accountId(String cif) {
        return [SELECT Id FROM Account WHERE CIF__pc = :cif LIMIT 1].Id;
    }

    private static ApiMock setMock(Integer statusCode, Boolean invalidBody) {
        ApiMock mock = new ApiMock();
        mock.statusCode = statusCode;
        mock.invalidBody = invalidBody;
        Test.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    @isTest
    static void loadDeviceListReturnsDevicesWithAnId() {
        ApiMock mock = setMock(200, false);
        Test.startTest();
        Map<String, Object> devices = DeviceDetailsController.loadDeviceList(accountId('222222'));
        Test.stopTest();
        System.assertEquals(1, devices.size(), 'Only the device with an id is returned');
        System.assert(devices.containsKey('dev-1'));
        System.assert(mock.lastEndpoint.contains('unit=alburaq'), 'Alburaq customers use the alburaq unit');
    }

    @isTest
    static void loadDeviceListReturnsEmptyMapOnError() {
        setMock(500, false);
        Id accId = accountId('111111');
        Test.startTest();
        Map<String, Object> devices = DeviceDetailsController.loadDeviceList(accId);
        Test.stopTest();
        System.assert(devices.isEmpty());
    }

    @isTest
    static void getCurrentCardsMapsCardTypeAndDelinquency() {
        setMock(200, false);
        Test.startTest();
        List<DeviceDetailsController.CardWrapper> cards = DeviceDetailsController.getCurrentCards(accountId('111111'));
        Test.stopTest();
        System.assertEquals(2, cards.size());
        System.assertEquals('Cash Collateral', cards[0].cardType);
        System.assertEquals('utility:check', cards[0].delinquentIcon);
        System.assertEquals('Credit Card', cards[1].cardType);
        System.assertEquals('utility:close', cards[1].delinquentIcon);
        System.assertEquals('Platinum', cards[0].cardClassification);
        System.assertEquals('****1111', cards[0].cardNumber);
    }

    @isTest
    static void getCurrentCardsThrowsOnInvalidResponse() {
        setMock(200, true);
        Id accId = accountId('111111');
        Boolean thrown = false;
        Test.startTest();
        try {
            DeviceDetailsController.getCurrentCards(accId);
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();
        System.assert(thrown, 'An invalid response is raised as an AuraHandledException');
    }

    @isTest
    static void loadCardDetailsToFetchLimitReturnsData() {
        setMock(200, false);
        Test.startTest();
        Map<String, Object> details = DeviceDetailsController.loadCardDetailsToFetchLimit(accountId('111111'), 'c1');
        Test.stopTest();
        System.assertEquals(1500, details.get('creditLimit'));
    }

    @isTest
    static void loadCardDetailsToFetchLimitReturnsEmptyOnError() {
        setMock(404, false);
        Id accId = accountId('222222');
        Test.startTest();
        Map<String, Object> details = DeviceDetailsController.loadCardDetailsToFetchLimit(accId, 'c1');
        Test.stopTest();
        System.assert(details.isEmpty());
    }

    @isTest
    static void getFixedDepositsMapsDeposits() {
        setMock(200, false);
        Test.startTest();
        List<DeviceDetailsController.FixedDepositWrapper> deposits = DeviceDetailsController.getFixedDeposits(accountId('222222'));
        Test.stopTest();
        System.assertEquals(1, deposits.size());
        System.assertEquals('TD1', deposits[0].id);
        System.assertEquals('BHD', deposits[0].currencyCode);
        System.assertEquals(1000, deposits[0].depositAmount);
        System.assertEquals(1050, deposits[0].maturityAmount);
        System.assertEquals('ACTIVE', deposits[0].status);
    }

    @isTest
    static void getFixedDepositsThrowsOnInvalidResponse() {
        setMock(200, true);
        Id accId = accountId('111111');
        Boolean thrown = false;
        Test.startTest();
        try {
            DeviceDetailsController.getFixedDeposits(accId);
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();
        System.assert(thrown);
    }

    @isTest
    static void getSavingPotsMapsPots() {
        setMock(200, false);
        Test.startTest();
        List<DeviceDetailsController.SavingPotWrapper> pots = DeviceDetailsController.getSavingPots(accountId('111111'));
        Test.stopTest();
        System.assertEquals(1, pots.size());
        System.assertEquals('P1', pots[0].id);
        System.assertEquals('Holiday', pots[0].name);
        System.assertEquals(250.5, pots[0].availableBalance);
        System.assertEquals('BHD', pots[0].currencyCode);
    }

    @isTest
    static void getSavingPotsThrowsOnInvalidResponse() {
        setMock(200, true);
        Id accId = accountId('222222');
        Boolean thrown = false;
        Test.startTest();
        try {
            DeviceDetailsController.getSavingPots(accId);
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();
        System.assert(thrown);
    }

    @isTest
    static void getCurrentDebitCardsMapsCards() {
        setMock(200, false);
        Test.startTest();
        List<DeviceDetailsController.DebitWrapper> cards = DeviceDetailsController.getCurrentDebitCards(accountId('222222'));
        Test.stopTest();
        System.assertEquals(1, cards.size());
        System.assertEquals('Debit', cards[0].productName);
        System.assertEquals('****3333', cards[0].cardNumber);
        System.assertEquals('ACTIVE', cards[0].status);
        System.assertEquals('VISA', cards[0].cardType);
    }

    @isTest
    static void getCurrentDebitCardsThrowsOnInvalidResponse() {
        setMock(200, true);
        Id accId = accountId('111111');
        Boolean thrown = false;
        Test.startTest();
        try {
            DeviceDetailsController.getCurrentDebitCards(accId);
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();
        System.assert(thrown);
    }

    @isTest
    static void getForeignAccountsReturnsOnlyActiveNonBhdAccounts() {
        setMock(200, false);
        Test.startTest();
        List<DeviceDetailsController.BankAccountWrapper> accts = DeviceDetailsController.getForeignAccounts(accountId('111111'));
        Test.stopTest();
        System.assertEquals(1, accts.size(), 'BHD and closed accounts are left out');
        System.assertEquals('USD Account', accts[0].aliasName);
        System.assertEquals('100', accts[0].accNumber);
        System.assertEquals('USD', accts[0].currencyCode);
        System.assertEquals(500, accts[0].availableBalance);
    }

    @isTest
    static void getForeignAccountsThrowsOnInvalidResponse() {
        setMock(200, true);
        Id accId = accountId('222222');
        Boolean thrown = false;
        Test.startTest();
        try {
            DeviceDetailsController.getForeignAccounts(accId);
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();
        System.assert(thrown);
    }

    @isTest
    static void non200ResponsesReturnEmptyLists() {
        setMock(500, false);
        Id accId = accountId('111111');
        Test.startTest();
        System.assert(DeviceDetailsController.getCurrentCards(accId).isEmpty());
        System.assert(DeviceDetailsController.getFixedDeposits(accId).isEmpty());
        System.assert(DeviceDetailsController.getSavingPots(accId).isEmpty());
        System.assert(DeviceDetailsController.getCurrentDebitCards(accId).isEmpty());
        System.assert(DeviceDetailsController.getForeignAccounts(accId).isEmpty());
        Test.stopTest();
    }
}

@isTest(isParallel=true)
private class SavingPotControllerTest {
    private static final String BAHRAIN_REGION = 'Bahrain';
    private static final String JORDAN_REGION = 'Jordan';

    @testSetup
    static void setupData(){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acc = new Account(LastName='Test Account', RecordTypeId=devRecordTypeId, CIF__pc='cus_XXX', Segment__pc='Premium');
        insert acc;


        acc.Segment__pc = 'Staff';
        update acc;

        // acc.Segment__pc = 'Premium';
        // update acc;

        Setting__c setting = new Setting__c(View_Staff_Data__c = false);
        insert setting;
    }

     @isTest
    static void testloadSavingPots_Bahrain () {
         testloadSavingPots(BAHRAIN_REGION);
     }
     @isTest
    static void testloadSavingPots_Jordan () {
          testloadSavingPots(JORDAN_REGION);
     }

    static void testloadSavingPots (String regionName) {

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta":{"code":"SPOT-1004","message":"List of Savings Pot  (32 more) ..."},"data":{"pots":[ {' +
                                                                                                                        '"account" : {' +
                                                                                                                        '"overdraftReviewDate" : "1957-01-01",' +
                                                                                                                        '"holdAmount" : 0,' +
                                                                                                                        '"valueBalance" : 0,' +
                                                                                                                        '"maximumBalance" : 0,' +
                                                                                                                        '"minimumBalance" : 0,' +
                                                                                                                        '"debitGLAccountDescription" : "LIAB POTS ACCT  ACCT - REGULAR",' +
                                                                                                                        '"debitGLAccount" : "2011224",' +
                                                                                                                        '"creditGLAccountDescription" : "LIAB POTS ACCT  ACCT - REGULAR",' +
                                                                                                                        '"creditGLAccount" : "2011224",' +
                                                                                                                        '"debitInterestFrequency" : "MONTHLY",' +
                                                                                                                        '"debitInterestFrequencyCode" : "200001",' +
                                                                                                                        '"creditInterestFrequency" : "MONTHLY",' +
                                                                                                                        '"creditInterestFrequencyCode" : "200001",' +
                                                                                                                        '"status" : "closed",' +
                                                                                                                        '"paymentsAllowed" : false,' +
                                                                                                                        '"overdraftAvailableLimit" : 0.0,' +
                                                                                                                        '"overdraftExpiryDate" : "2020-06-22",' +
                                                                                                                        '"overdraftLimit" : 0.0,' +
                                                                                                                        '"endDate" : "2020-06-10",' +
                                                                                                                        '"startDate" : "2020-06-10",' +
                                                                                                                        '"ledgerBalance" : 0,' +
                                                                                                                        '"availableBalance" : 0,' +
                                                                                                                        '"iban" : "BH47ABCO11814409124101",' +
                                                                                                                        '"currency" : {' +
                                                                                                                        '    "decimalPlaces" : "3",' +
                                                                                                                        '    "code" : "BHD"' +
                                                                                                                        '},' +
                                                                                                                        '"number" : "118144091241",' +
                                                                                                                        '"branch" : "91084710"' +
                                                                                                                        '},' +
                                                                                                                        '"category2" : "",' +
                                                                                                                        '"category1" : "",' +
                                                                                                                        '"productName" : "BHDSaving Pot",' +
                                                                                                                        '"productType" : "potAccount",' +
                                                                                                                        '"customerId" : "1181440",' +
                                                                                                                        '"status" : "closed",' +
                                                                                                                        '"earnInterest" : true,' +
                                                                                                                        '"linkedAccountId" : "XXXXXXX",' +
                                                                                                                        '"potAccountId" : "XXXXXXXXX",' +
                                                                                                                        '"icon" : "01",' +
                                                                                                                        '"type" : "regular",' +
                                                                                                                        '"description" : "Hchb",' +
                                                                                                                        '"name" : "Trst",' +
                                                                                                                        '"potId" : 2931' +
                                                                                                                        '}]}}';

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        ApiConnection.Response response = SavingPotController.loadSavingPots('cus_XXX', regionName);
        Test.stopTest();
        System.assertEquals(true, response.isSuccess, 'expected successful response');

    }

         @isTest
    static void testloadPotDetails_Bahrain () {
         testloadPotDetails(BAHRAIN_REGION);
     }
     @isTest
    static void testloadPotDetails_Jordan () {
          testloadPotDetails(JORDAN_REGION);
     }

    static void testloadPotDetails (String regionName) {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta":{"code":"SPOT-1001","message":"Savings pot details  (33 more) ..."},"data":'+
                            '{' +
                            '"account" : {' +
                            '    "swiftCode" : "XXXXXXXXXX",' +
                            '   "overdraftReviewDate" : "1957-01-01",' +
                            '   "holdAmount" : 0,' +
                            '   "valueBalance" : 0,' +
                            '  "maximumBalance" : 0,' +
                            '   "minimumBalance" : 0,' +
                            '   "debitGLAccountDescription" : "LIAB POTS ACCT  ACCT - REGULAR",' +
                            '   "debitGLAccount" : "2011224",' +
                            '   "creditGLAccountDescription" : "LIAB POTS ACCT  ACCT - REGULAR",' +
                            '   "creditGLAccount" : "2011224",' +
                            '   "debitInterestFrequency" : "MONTHLY",' +
                            '   "debitInterestFrequencyCode" : "200001",' +
                            '   "creditInterestFrequency" : "MONTHLY",' +
                            '   "creditInterestFrequencyCode" : "200001",' +
                            '   "status" : "closed",' +
                            '   "paymentsAllowed" : false,' +
                            '   "overdraftAvailableLimit" : 0.0,' +
                            '   "overdraftExpiryDate" : "2020-06-22",' +
                            '   "overdraftLimit" : 0.0,' +
                            '   "endDate" : "2020-06-10",' +
                            '   "startDate" : "2020-06-10",' +
                            '   "ledgerBalance" : 0,' +
                            '   "availableBalance" : 0,' +
                            '   "iban" : "xxxxxxxxxxx",' +
                            '   "currency" : {' +
                            '   "decimalPlaces" : "3",' +
                            '   "code" : "BHD"' +
                            '   },' +
                            '   "number" : "118144091241",' +
                            '   "branch" : "91084710"' +
                            '},' +
                            '"category2" : "",' +
                            '"category1" : "",' +
                            '"productName" : "Current Account",' +
                            '"productType" : "account",' +
                            '"customerId" : "1181440",' +
                            '"alias" : "Current Account",' +
                            '"status" : "closed",' +
                            '"earnInterest" : true,' +
                            '"linkedAccountId" : "XXXXXXXXXXX",' +
                            '"potAccountId" : "XXXXXXXXXXXXX",' +
                            '"icon" : "01",' +
                            '"type" : "regular",' +
                            '"description" : "Hchb",' +
                            '"name" : "Trst",' +
                            '"potId" : 2931' +
                            '}' +
                        '}';

        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        final ApiConnection.Response response = SavingPotController.loadPotDetails('cus_XXX', 'potId_xxxxx', regionName);
        Test.stopTest();
        System.assertEquals(true, response.isSuccess, 'expected successful response');
    }

         @isTest
    static void testloadPotTransactions_Bahrain () {
         testloadPotTransactions(BAHRAIN_REGION);
     }
     @isTest
    static void testloadPotTransactions_Jordan () {
          testloadPotTransactions(JORDAN_REGION);
     }
    
    static void testloadPotTransactions (String regionName) {

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta":{"code":"SPOT-1006","message":"List of transactions for Savings Pot has been retrieved successfully."},'+
                        '"data":{"potId":3001,"name":"Bcgxy","description":"Hcyfy","icon":"06","type":"regular","potAccountId":"BH62ABCO11814409124801","linkedAccountId":"BH37ABCO11814409101001","earnInterest":true,"status":"new",'+
                        '"transactions":['+
                            '{'+
                                '"id": "1309825",'+
                                '"transactionDate": "2020-06-08T11:14:06",'+
                                '"valueDate": "2020-06-08",'+
                                '"transactionType": "",'+
                                '"transactionCurrency": {'+
                                '"code": "BHD",'+
                                    '"decimalPlaces": "3"'+
                                    '},'+
                                '"accountCurrency": {'+
                                '"code": "BHD",'+
                                    '"decimalPlaces": "3"'+
                                    '},'+
                                '"transactionDescription1": "TRANSFERRED TO 116215191011 BHD",'+
                                '"transactionDescription2": "",'+
                                '"transactionDescription3": "",'+
                                '"transactionDescription4": "",'+
                                '"transactionDescription5": "",'+
                                '"transactionDescription6": "",'+
                                '"amount": -1000001.000,'+
                                '"originalAmount": -1000001.000000,'+
                                '"reference": "",'+
                                '"previousBalance": 1000001.000,'+
                                '"currentBalance": 0.000,'+
                                '"generateAdvice": true,'+
                                '"status": "Completed"'+
                                '}'+
                        ']}}';

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();


            final ApiConnection.Response response = SavingPotController.loadPotTransactions('cus_XXX', 'potId_XXXX', '{"potId": "potId_XXXX", "offSet": 0, "pageSize": 100}', regionName);
        Test.stopTest();
        System.assertEquals(true, response.isSuccess, 'expected successful response');
    }

    private class MyCalloutMock implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 200;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(testStatusCode);
            res.setBody('{' +
                        '    "meta": {' +
                        '        "code": "COMP-1002",' +
                        '        "message": "Case status has been retrieved successfully."' +
                        '    },' +
                        '    "data": {' +
                            '        "status": "released",' +
                                '        "screeningResults": "P",' +
                                '        "decision": "EDD"' +
                                '    }'+
                        '}');
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
    }

}
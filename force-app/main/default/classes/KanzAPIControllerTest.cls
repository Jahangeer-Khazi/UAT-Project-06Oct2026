/**
 * @description       :
 * @author            : Jose Caballero
 * @group             :
 * @last modified on  : 14/10/2021
 * @last modified by  : Jose Caballero
**/
@isTest
public with sharing class KanzAPIControllerTest {

    final static String ACCOUNT_KEY_PREFIX = Schema.SObjectType.Account.getKeyPrefix();
    final static String ACCOUNT_ID_1 = ACCOUNT_KEY_PREFIX + '000000000001';
    final static String CASE_KEY_PREFIX = Schema.SObjectType.Case.getKeyPrefix();
    final static String CASE_ID_1 = CASE_KEY_PREFIX + '000000000001';

    private class MyCalloutMock implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 200;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(testStatusCode);
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
    }

    @isTest
    static void testLoadPrizeLinkedAccount () {

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{'+
                            '"meta": { "code": "PLAS-1000", "message": "Kanz details has been retrieved successfully." },'+
                            '"data": {' +
                                    '"status" : "EXISITING",'+
                                    '"account": {'+
                                            '"iban": "BH66ABCO00200002308131",'+
                                            '"balance": 1000.000,'+
                                            '"currency": {'+
                                                '"code":"BHD",'+
                                                '"decimalPlaces": 3'+
                                            '},'+
                                            '"status": "active"'+
                                    '},'+
                                    '"draws":['+
                                        '{'+
                                            '"id": 1230,'+
                                            '"code" : "WINTER",'+
                                            '"startDate" : "2021-09-01T00:00:00",'+
                                            '"retentionStart" : "2021-09-15T00:00:00",'+
                                            '"drawDate" : "2021-09-15T00:00:00",'+
                                            '"status": "",'+
                                            '"drawAmount" : 50,'+
                                            '"customerAmount":500,'+
                                            '"currency": {'+
                                                '"code":"BHD",'+
                                                '"decimalPlaces": 3'+
                                            '},'+
                                            '"timeZone": "+03:00",'+
                                            '"noOfChances": 205,'+
                                            '"prizes":[{'+
                                                '"order":1,'+
                                                '"noOfWinner": 1,'+
                                                '"amount" : 250'+
                                            '},'+
                                            '{'+
                                                '"order":2,'+
                                                '"noOfWinner": 5,'+
                                                '"amount" : 1000'+
                                            '},'+
                                            '{'+
                                                '"order":3,'+
                                                '"noOfWinner": 10,'+
                                                '"amount" : 250'+
                                        '}]'+
                                    '}]'+
                            '}'+
                        '}';

        Test.setMock(HttpCalloutMock.class, mock);
        Case testCase = new Case(Id = CASE_ID_1, AccountId = ACCOUNT_ID_1);
        ApiConnection.Response response = KanzAPIController.loadPrizeLinkedAccount('testCustomerId',CASE_ID_1,'Bahrain');
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);
    }

    @isTest
    static void testLoadKanzAccountTransaction() {

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody =  '{"meta": { "code": "10009", "message":"Transaction Details for Account Id has been retrieved successfully." },'+
                        '"data": {'+
                                '"transactions":[{"id":"xxxxxx","transactionDate":"2020-06-18T10:51:00","valueDate":"2020-06-18","transactionType":"ACTD","transactionCurrency":{"code":"BHD","decimalPlaces":"3"},"accountCurrency":{"code":"BHD","decimalPlaces":"3"},"transactionDescription1":"From Prashant Mohite","transactionDescription2":"xxxxxxxxxxxxx","transactionDescription3":"PERSONAL TRANSFER BHD","transactionDescription4":"","transactionDescription5":"","transactionDescription6":"","amount":75.000,"originalAmount":75.000000,"reference":"820043210000","previousBalance":0.000,"currentBalance":75.000,"generateAdvice":true,"status":"Completed"}]}}'+
                            '}'+
                        '}';

        Test.setMock(HttpCalloutMock.class, mock);
        Case testCase = new Case(Id = CASE_ID_1, AccountId = ACCOUNT_ID_1);
        ApiConnection.Response response = KanzAPIController.loadKanzAccountTransactions('testCustomerId', '{}','Bahrain');
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);
    }
}
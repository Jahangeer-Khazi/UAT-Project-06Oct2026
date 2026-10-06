/**
 *  @author: Andrey Gavrikov (westbrook)
 *  @date: 2019-03-04 17:30:21
 *  @description:
 *      Test methods for BankInformationController
 *
 *  Version History :
 *           #CH01 Amina BENABDELKRIM  add add new field (case model) with default value 'ila'
 * 			 #CH02 #Jahangeer Mohammed# #06-12-2023# Added two unit test methods for the code coverage
 *
 */
@isTest(isParallel=true)
public class BankInformationControllerTest  {
    private static final String BAHRAIN_REGION = 'Bahrain';
    private static final String JORDAN_REGION = 'Jordan';
    private class MyDao extends BankInformationController {
        public Account testAccount;
        public Case testCase;

        protected override Account loadAccount(final Id recordId) {
            try{ super.loadAccount(recordId); } catch (Exception eIgnore) {System.debug('The following exception has occurred: ' + eIgnore.getMessage());}
            return testAccount;
        }
        protected override Case loadCase(final Id recordId) {
            try{ super.loadCase(recordId); } catch (Exception eIgnore) {System.debug('The following exception has occurred: ' + eIgnore.getMessage());}
            return testCase;
        }
    }
    final static String ACCOUNT_KEY_PREFIX = Schema.SObjectType.Account.getKeyPrefix();
    final static String ACCOUNT_ID_1 = ACCOUNT_KEY_PREFIX + '000000000001';
    final static String CASE_KEY_PREFIX = Schema.SObjectType.Case.getKeyPrefix();
    final static String CASE_ID_1 = CASE_KEY_PREFIX + '000000000001';

    /**
     *
     */
    @isTest
    static void testLoadRecord () {
        final MyDao dao = new MyDao();
        BankInformationController.DAO = dao;
        dao.testAccount = new Account(Name = 'Test Account');
        dao.testCase = new Case(Subject = 'Test Case');

        final ApiConnection.Response response = BankInformationController.loadRecord(Account_ID_1);
        System.assertEquals(true, response.isSuccess, 'expected successful response');
        System.assertNotEquals(null, response.responseData, 'expected not empty response');

        final SObject loadedAccount = (SObject)response.responseData;
        System.assertEquals(Account.sObjectType, loadedAccount.getSObjectType(),
                'expected Account to be returned because recordId was Id of account');

        final ApiConnection.Response response2 = BankInformationController.loadRecord(Case_ID_1);
        System.assertEquals(true, response2.isSuccess, 'expected successful response');
        System.assertNotEquals(null, response2.responseData, 'expected not empty response');

        final SObject loadedCase = (SObject)response2.responseData;
        System.assertEquals(Case.sObjectType, loadedCase.getSObjectType(),
                'expected Case to be returned because recordId was Id of case');

    }

    @isTest
    static void testLoadTabsConfig () {
        final ApiConnection.Response response = BankInformationController.loadTabsConfig();
        System.assertEquals(true, response.isSuccess, 'expected successful response');
    }

    @isTest
    static void testCallout() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();

        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');

        System.assertEquals(200, res.getStatusCode());
    }


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

    /**
     *
     */
    @isTest
    static void testSendVerificationRequest () {
        final MyCalloutMock mock = new MyCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);

        ApiConnection.Response response = BankInformationController.sendVerificationRequest(Case_ID_1, 'testCustomerId', '', 'testAction', 'test@test.com', BAHRAIN_REGION);
        System.assertEquals(true, response.isSuccess);
    }

    private class RestMock implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
     private class RestMock2 implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"Name": "sForceTest1"}');
            res.setStatusCode(200);
            return res;
        }
    }

   @isTest
    static void unitTest2(){
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.CIF__pc = '12345';
       // acc.Region_Flag__c = 'Bahrain';
       // acc.Region_Flag__pc = 'Bahrain';
        insert acc;

        Case cs1 = new Case();
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.Status = 'In Progress';
        cs1.Priority = 'High';
        cs1.Origin = 'Phone';
        cs1.Case_Model__c='ila';//CH01
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =1500;
        cs1.cc_PCI_Id__c = '2';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Amount__c = 170.2;
        cs1.cc_Balance_Transfer_Card_Number__c = '1234567891011123';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test';
        insert cs1;

        test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        BankInformationController.cardStatusFilter(cs1.id,'A');
        test.stopTest();

    }
    //CH02: Start
    @isTest
    static void unitTest3 () {
           testLoadCardList (BAHRAIN_REGION);
    }
    static void testLoadCardList (String regionName) {
        final MyCalloutMock mock = new MyCalloutMock();
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        //Case caseObj = (Case)TestDataFactory.createSObject(new Case(ContactId = acc1.PersonContactId,AccountId = acc1.id), 'TestFactoryDefaults.CaseDefaults',true);

        mock.testBody = '{"meta": { "code": "10009", "displayMessage": "The card list retrieved successfully." },'+
                        '"data": {'+
                            '"cards": [ '+
                            '    { '+
                            '        "customerId": "989248099", '+
                            '        "id": "12f67bbd-8ace-4412-85bf-49cbc8178271", '+
                            '        "productType": "Classic", '+
                            '        "cardType": "Primary", '+
                            '        "status": "Active", '+
                            '        "embossName": "M. Hansen", '+
                            '        "companyName": "Bank ABC", '+
                            '        "maskedCardNumber": "123456 **** **** 1234", '+
                            '        "issueDate": "21/12/2019", '+
                            '        "activationDate": "21/12/2019", '+
                            '        "provider": "Visa" '+
                            '    } '+
                            ' ] ' +
                            '}'+
                        '}';
		test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = BankInformationController.loadDebitCardList(acc1.Id, 'A');
        test.stopTest();
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);

       
    }
     @isTest
    static void unitTest4 () {
           testLoadCardPurgeList (BAHRAIN_REGION);
    }
    static void testLoadCardPurgeList (String regionName) {
        final MyCalloutMock mock = new MyCalloutMock();
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        //Case caseObj = (Case)TestDataFactory.createSObject(new Case(ContactId = acc1.PersonContactId,AccountId = acc1.id), 'TestFactoryDefaults.CaseDefaults',true);

        mock.testBody = '{"meta": { "code": "10009", "displayMessage": "The card list retrieved successfully." },'+
                        '"data": {'+
                            '"cards": [ '+
                            '    { '+
                            '        "customerId": "989248099", '+
                            '        "id": "12f67bbd-8ace-4412-85bf-49cbc8178271", '+
                            '        "productType": "Classic", '+
                            '        "cardType": "Primary", '+
                            '        "status": "Active", '+
                            '        "embossName": "M. Hansen", '+
                            '        "companyName": "Bank ABC", '+
                            '        "maskedCardNumber": "123456 **** **** 1234", '+
                            '        "issueDate": "21/12/2019", '+
                            '        "activationDate": "21/12/2019", '+
                            '        "provider": "Visa" '+
                            '    } '+
                            ' ] ' +
                            '}'+
                        '}';
		test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = BankInformationController.loadDebitCardPurgeList(acc1.Id, 'A');
        test.stopTest();
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);
	}
    //CH02: END
}
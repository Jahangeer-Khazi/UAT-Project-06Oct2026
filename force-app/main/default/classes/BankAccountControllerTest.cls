/**
 *  @author: Andrey Gavrikov (westbrook)
 *  @date: 2019-02-12 11:58:45
 *  @description:
 *      Test methods for BankAccountController
 *
 *  Version History :
 *      CH01 Added by Amina BENABDELKRIM 20-06-2022 *** to add new field (case model)
 *      CH02 added by Aniss Mbarki 22-06-2022
 *      CH03 added by Imane Tsioucha 10-05-2023
 *      CH04 added by Imane Tsioucha 15-09-2023
 * 		CH05 added by Ranjith Raja 12-10-2024
 * 		CH06 added by Maksud Ali 27-04-2024
 *
 */
@isTest(isParallel=true)
public class BankAccountControllerTest  {

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
    private class MySensitiveDataCleanerDAO extends SensitiveDataCleaner {
        public Boolean testIsAllowedToViewStaffData = false;
        public Account testAccount = new Account();

        protected override List<Account> loadAccountByCif(final String cif) {
            super.loadAccountByCif(cif);
            return new List<Account>{testAccount};
        }
    }
    private static final String BAHRAIN_REGION = 'Bahrain';
    private static final String JORDAN_REGION = 'Jordan';



    //CH06 START
    @isTest
    static void testLoadHysaAccountList() {
        final MySensitiveDataCleanerDAO dao = new MySensitiveDataCleanerDAO();
        SensitiveDataCleaner.DAO = dao;
        // by default - clean is required
        dao.testAccount = new Account(Segment__pc = 'Staff');

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": { "code": "10009", "displayMessage": "The hysa account list retrieved successfully." },'+
                        '"data": {'+
                            '"accounts": [ '+
                            '    { '+
                            '    } '+
                            ' ] ' +
                            '}'+
                        '}';

        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = BankAccountController.loadHysaList('testCustomerId', BAHRAIN_REGION );
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);

    }
    @isTest
    static void testLoadHysaAccountDetails() {
        final MySensitiveDataCleanerDAO dao = new MySensitiveDataCleanerDAO();
        SensitiveDataCleaner.DAO = dao;
        // by default - clean is required
        dao.testAccount = new Account(Segment__pc = 'Staff');

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": { "code": "10009", "displayMessage": "The hysa account details retrieved successfully." },'+
                        '"data": {'+
                            '}'+
                        '}';

        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = BankAccountController.loadHysaAccountDetails('testCustomerId', 'testAccountId' ,BAHRAIN_REGION);
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);

    }
    //CH06 END
    
    @isTest
    static void testLoadAccountListBahrain() {
        final MySensitiveDataCleanerDAO dao = new MySensitiveDataCleanerDAO();
        SensitiveDataCleaner.DAO = dao;
        // by default - clean is required
        dao.testAccount = new Account(Segment__pc = 'Staff');

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": { "code": "10009", "displayMessage": "The account list retrieved successfully." },'+
                        '"data": {'+
                            '"accounts": [ '+
                            '    { '+
                            '    } '+
                            ' ] ' +
                            '}'+
                        '}';

        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = BankAccountController.loadAccountList('testCustomerId', BAHRAIN_REGION );
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);

    }

    @isTest
    static void testLoadAccountListJordan() {
        final MySensitiveDataCleanerDAO dao = new MySensitiveDataCleanerDAO();
        SensitiveDataCleaner.DAO = dao;
        // by default - clean is required
        dao.testAccount = new Account(Segment__pc = 'Staff');

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": { "code": "10009", "displayMessage": "The account list retrieved successfully." },'+
                        '"data": {'+
                            '"accounts": [ '+
                            '    { '+
                            '    } '+
                            ' ] ' +
                            '}'+
                        '}';

        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = BankAccountController.loadAccountList('testCustomerId', JORDAN_REGION );
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);

    }
    @isTest
    static void testLoadAccountDetails_Bahrain () {
        final MySensitiveDataCleanerDAO dao = new MySensitiveDataCleanerDAO();
        SensitiveDataCleaner.DAO = dao;
        // by default - clean is required
        dao.testAccount = new Account(Segment__pc = 'Staff');

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": { "code": "10009", "displayMessage": "The account details retrieved successfully." },'+
                        '"data": {'+
                            '}'+
                        '}';

        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = BankAccountController.loadAccountDetails('testCustomerId', 'testAccountId' ,BAHRAIN_REGION);
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);

    }
    @isTest
    static void testLoadAccountDetails_Jordan () {
        final MySensitiveDataCleanerDAO dao = new MySensitiveDataCleanerDAO();
        SensitiveDataCleaner.DAO = dao;
        // by default - clean is required
        dao.testAccount = new Account(Segment__pc = 'Staff');

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": { "code": "10009", "displayMessage": "The account details retrieved successfully." },'+
                        '"data": {'+
                            '}'+
                        '}';

        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = BankAccountController.loadAccountDetails('testCustomerId', 'testAccountId', JORDAN_REGION);
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);

    }
 /* Code Commented by Imane Tsioucha(Minimum Balance Project on Hold)
    // CH04 Added by Imane Tsioucha -->
    @isTest
    static void loadAccountDetailsMinimumBalanceTest () {
        final MySensitiveDataCleanerDAO dao = new MySensitiveDataCleanerDAO();
        SensitiveDataCleaner.DAO = dao;
        // by default - clean is required
        dao.testAccount = new Account(Segment__pc = 'Staff');

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": {"code": "ACCO-1012","message": "Minimum Balance Fees Account Details for given account has been retrieved successfully."},' +
        '"data": {"customerId": "989248099","id": "BH09ABCO00929029882","minimumBalance": { "averageBalance" : 100.0,"showAverageBalance" : true,"threshold" : 20.0,' +
        '"fee" : 1.0,"currency" : "BHD","feeWaiver" : false,"feeWaiverReason" : "Salary below 250"}' +
        '}' +
        '}';

        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = BankAccountController.loadAccountDetailsMinimumBalance('testCustomerId' ,'554445891010','BHD','testAccountId',BAHRAIN_REGION );
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);

    }
*/

    @isTest
    static void testLoadAccountTransactions_Bahrain () {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": { "code": "10009", "message":"Transaction Details for Account Id has been retrieved successfully." },'+
                        '"data": {'+
                                '"transactions":[{"id":"xxxxxx","transactionDate":"2020-06-18T10:51:00","valueDate":"2020-06-18","transactionType":"ACTD","transactionCurrency":{"code":"BHD","decimalPlaces":"3"},"accountCurrency":{"code":"BHD","decimalPlaces":"3"},"transactionDescription1":"From Prashant Mohite","transactionDescription2":"xxxxxxxxxxxxx","transactionDescription3":"PERSONAL TRANSFER BHD","transactionDescription4":"","transactionDescription5":"","transactionDescription6":"","amount":75.000,"originalAmount":75.000000,"reference":"820043210000","previousBalance":0.000,"currentBalance":75.000,"generateAdvice":true,"status":"Completed"}]}}'+
                            '}'+
                        '}';

        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = BankAccountController.loadAccountTransactions('testCustomerId', '{}', BAHRAIN_REGION);
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);

        //mock.testStatusCode = 500;
        //response = BankAccountController.loadAccountDetails('testCustomerId', '{}');
        //System.assertEquals(false, response.isSuccess);

    }
     @isTest
    static void testLoadAccountTransactions_Jordan () {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": { "code": "10009", "message":"Transaction Details for Account Id has been retrieved successfully." },'+
                        '"data": {'+
                                '"transactions":[{"id":"xxxxxx","transactionDate":"2020-06-18T10:51:00","valueDate":"2020-06-18","transactionType":"ACTD","transactionCurrency":{"code":"BHD","decimalPlaces":"3"},"accountCurrency":{"code":"BHD","decimalPlaces":"3"},"transactionDescription1":"From Prashant Mohite","transactionDescription2":"xxxxxxxxxxxxx","transactionDescription3":"PERSONAL TRANSFER BHD","transactionDescription4":"","transactionDescription5":"","transactionDescription6":"","amount":75.000,"originalAmount":75.000000,"reference":"820043210000","previousBalance":0.000,"currentBalance":75.000,"generateAdvice":true,"status":"Completed"}]}}'+
                            '}'+
                        '}';

        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = BankAccountController.loadAccountTransactions('testCustomerId', '{}', JORDAN_REGION);
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);

        //mock.testStatusCode = 500;
        //response = BankAccountController.loadAccountDetails('testCustomerId', '{}');
        //System.assertEquals(false, response.isSuccess);

    }

    final static String ACCOUNT_KEY_PREFIX = Schema.SObjectType.Account.getKeyPrefix();
    final static String ACCOUNT_ID_1 = ACCOUNT_KEY_PREFIX + '000000000001';
    final static String CASE_KEY_PREFIX = Schema.SObjectType.Case.getKeyPrefix();
    final static String CASE_ID_1 = CASE_KEY_PREFIX + '000000000001';

    @isTest
    static void testRequestCashCollectionOrDelivery_Bahrain () {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{}';

        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = BankAccountController.requestCashCollectionOrDelivery('testCustomerId', CASE_ID_1, '{}', 'Cash Collection', BAHRAIN_REGION);
        System.assertEquals(true, response.isSuccess);
    }

    @isTest
    static void testRequestCashCollectionOrDelivery_Jordan() {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{}';

        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = BankAccountController.requestCashCollectionOrDelivery('testCustomerId', CASE_ID_1, '{}', 'Cash Collection', JORDAN_REGION);
        System.assertEquals(true, response.isSuccess);
    }


    private class MyDao extends BankAccountController {
        public Account testAccount;
        public Case testCase;

        protected override Account loadAccount(final String cif) {
            try{ super.loadAccount(cif); } catch (Exception eIgnore) {
                System.assert(true, 'The following exception has occurred: ' + eIgnore.getMessage());
                System.debug('The following exception has occurred: ' + eIgnore.getMessage());}
            return testAccount;
        }
    }

    @isTest
    static void testLoadAccountByCif () {
        final MyDao DAO = new MyDao();
        BankAccountController.DAO = DAO;
        DAO.testAccount = new Account(Name = 'Test');

        System.assertNotEquals(null, BankAccountController.loadAccountByCif('testCif1'));
        System.assertEquals('Test', BankAccountController.loadAccountByCif('testCif1').Name);
    }
    @isTest
    static void testLoadCountryPicklistValues () {
        // code coverage for method with no logic
        BankAccountController.loadCurrencyPicklistValues();

        System.assertNotEquals(null, BankAccountController.loadCountryPicklistValues());
    }

    private class CardListControllerDao extends BankCardListController {
        List<SObject> updatedRecs;
        protected override List<String> updateRecords(final List<SObject> recs) {
            try{ super.updateRecords(recs); } catch (Exception eIgnore){
                System.assert(true, 'The following exception has occurred: ' + eIgnore.getMessage());
                System.debug('The following exception has occurred: ' + eIgnore.getMessage());}
            updatedRecs = recs;
            return new List<String>();
        }
    }

    @isTest
    static void testRequestNewCard () {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = null;

        Test.setMock(HttpCalloutMock.class, mock);
        final Map<String, String> requestTextJson = new Map<String, String>{
            'accountNumber' => '989248099',
            'productType'=> 'Classic'
        };

        final CardListControllerDao DAO = new CardListControllerDao();
        BankCardListController.DAO = DAO;

        final String extraParameters = '{ "systemActionType": "testAction", "caseType": "test type" , "caseSubType": "test subtype", "isCaseClosureRequired": true}';
        ApiConnection.Response response = BankAccountController.requestNewCard('testCustomerId',
                                                                                JSON.serialize(requestTextJson),
                                                                                Case_ID_1,
                                                                                extraParameters,
                                                                                'testabc@mail.com',
                                                                                BAHRAIN_REGION
                                                                                );
        System.assertEquals(true, response.isSuccess);
    }

   @isTest
    static  void sendEmailWithPdf(){

        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Class';
        acc.PersonEmail = 'aws@ilabank.com';
        acc.RecordtypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        acc.Onboarding_Stage__pc = 'MOBILE_VERIFIED';
        acc.Onboarding_Group__pc = 'Registration';
        acc.Region_Flag__c  = BAHRAIN_REGION;   //We need to set the flag for Region_Flag__c and Region_Flag__pc because of automation will consider the user (running the test classes) regionflag. These only applies to account, because accounts are always created by integration user and it has always region flag set.
        acc.Region_Flag__pc  = BAHRAIN_REGION;

        //acc.Referred_By__c =
        insert acc;

        Case cs = new Case();
        cs.Subject = 'Test Case';
        cs.Description = 'Test Description';
        cs.Type = 'IBAN Certificate';
        // CH01 Added by Amina BENABDELKRIM 20-06-2022 *** to add new field (case model) -->
        cs.Case_Model__c='ila';
         // CH01 END-->
        cs.Status = 'In Progress';
        cs.Priority = 'High';
        cs.Origin = 'Phone';
        cs.ContactId = acc.PersonContactId;
        cs.AccountId = acc.id;
        insert cs;
        Test.StartTest();
        BankAccountController obj01 = new BankAccountController();
         // CH03 Case Id parameter
        BankAccountController.sendEmailWithPdf('IBAN43849347','2020-12-12','BH',String.valueOf(acc.id),acc.PersonEmail,'Test Class',cs.Id);
        BankAccountController.updateCaseStatus(cs.id);
        Test.stopTest();
  }


    // CH02 Added by Aniss -->
    @isTest
    static  void visibilityOptionsCheckTest(){
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Block_Unblock_Account').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id), 'TestFactoryDefaults.CaseDefaults',true);
        Map<String, String> responseData = BankAccountController.visibilityOptionsCheck(caseObj.Id);
        System.assert(responseData!=null);

    }
    // CH02 End -->

    @isTest
    static void loadAccountLastTransactionTest () {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": { "code": "10009", "message":"Transaction Details for Account Id has been retrieved successfully." },'+
                        '"data": {'+
                                '"transactions":[{"id":"xxxxxx","transactionDate":"2020-06-18T10:51:00","valueDate":"2020-06-18","transactionType":"ACTD","transactionCurrency":{"code":"BHD","decimalPlaces":"3"},"accountCurrency":{"code":"BHD","decimalPlaces":"3"},"transactionDescription1":"From Prashant Mohite","transactionDescription2":"xxxxxxxxxxxxx","transactionDescription3":"PERSONAL TRANSFER BHD","transactionDescription4":"","transactionDescription5":"","transactionDescription6":"","amount":75.000,"originalAmount":75.000000,"reference":"820043210000","previousBalance":0.000,"currentBalance":75.000,"generateAdvice":true,"status":"Completed"}]}}'+
                            '}'+
                        '}';

        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = BankAccountController.loadAccountLastTransaction('BH85ABCO55444589101001', '{}', 'Bahrain');
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);

    }

    @isTest
    static void downloadIBAN_Test(){
        Account acc =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        test.startTest();
         final MyCalloutMock mock = new MyCalloutMock();
         mock.testBody = '{"customerId": "5544458","accountId":"0013N00001BKpO8QAL"}';
        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = BankAccountController.downloadIBAN(acc.CIF__pc,'0013N00001BKpO8QAL','Bahrain');

       test.stopTest();
    }
    
    // CH05: Start
    @isTest
    static  void sendEmailWithIBANCertificatePdfTest(){

        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Class';
        acc.PersonEmail = 'aws@ilabank.com';
        acc.RecordtypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        acc.Onboarding_Stage__pc = 'MOBILE_VERIFIED';
        acc.Onboarding_Group__pc = 'Registration';
        acc.Region_Flag__c  = BAHRAIN_REGION;   //We need to set the flag for Region_Flag__c and Region_Flag__pc because of automation will consider the user (running the test classes) regionflag. These only applies to account, because accounts are always created by integration user and it has always region flag set.
        acc.Region_Flag__pc  = BAHRAIN_REGION;

        //acc.Referred_By__c =
        insert acc;

        Case cs = new Case();
        cs.Subject = 'Test Case';
        cs.Description = 'Test Description';
        cs.Type = 'IBAN Certificate';
        cs.Case_Model__c='ila';
        cs.Status = 'In Progress';
        cs.Priority = 'High';
        cs.Origin = 'Phone';
        cs.ContactId = acc.PersonContactId;
        cs.AccountId = acc.id;
        insert cs;
        
        Contact cnt = TestFactory.createContact('Test_2024');
        cnt.Email = 'ranjith.mathiyalagan@bank-abc.com';
        insert cnt;
        
        Test.StartTest();
        BankAccountController obj01 = new BankAccountController();
         // CH03 Case Id parameter
        //BankAccountController.sendEmailWithIBANCertificatePdf('ranjith.mathiyalagan@bank-abc.com','',String.valueOf(acc.id),cs.Id);
        Test.stopTest();
  }
    // CH05: End

}
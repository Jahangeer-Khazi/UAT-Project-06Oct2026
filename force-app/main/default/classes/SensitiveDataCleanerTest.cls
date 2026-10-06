/**
 *  @author: Andrey Gavrikov (westbrook)
 *  @date: 2019-02-14 12:31:11
 *  @description:
 *      Test methods for SensitiveDataCleaner
 *
 *  Version History :
 *
 */
@isTest
public class SensitiveDataCleanerTest  {
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
    private static final String BAHRAIN_REGION = 'Bahrain';
    private static final String JORDAN_REGION = 'Jordan';

    private class MyDAO extends SensitiveDataCleaner {
        public Boolean testIsAllowedToViewStaffData = false;
        public Account testAccount = new Account();

        protected override Boolean isAllowedToViewStaffData(final String regionFlag) {
            super.isAllowedToViewStaffData(regionFlag);
            return testIsAllowedToViewStaffData;
        }

        protected override List<Account> loadAccountByCif(final String cif) {
            super.loadAccountByCif(cif);
            return new List<Account>{testAccount};
        }
    }

    @isTest
    static void testSetObjectFieldToBlank () {
        Map<String, Object> obj = (Map<String, Object>)JSON.deserializeUntyped(
                    '{' +
                    '    "field1": "value1", ' +
                    '    "field2": { ' +
                    '        "f2": "field2.f2", ' +
                    '        "f3": "field2.f3", ' +
                    '        "f4": {' +
                    '            "ff4": "field2.f4.ff4", ' +
                    '            "ff3": "field2.f4.ff3"  ' +
                    '        }    ' +
                    '    }, ' +
                    '    "field3": "value3" ' +
                    '}'
                );

        System.assertEquals('value1', obj.get('field1'), 'Incorrect test data setup');

        SensitiveDataCleaner.setObjectFieldToBlank(obj, 'field1');
        System.assertEquals('', obj.get('field1'), 'Expected blank field value');
        System.assertEquals('value3', obj.get('field3'), 'Expected NOT blank field value');


        // nested 1 level
        SensitiveDataCleaner.setObjectFieldToBlank(obj, 'field2.f3');
        System.assertEquals('', ((Map<String, Object>)obj.get('field2')).get('f3'), 'Expected blank field value');
        // check that other fields have not been changed
        System.assertEquals('field2.f2', ((Map<String, Object>)obj.get('field2')).get('f2'), 'Expected NON blank field value');

        // nested 2 levels
        SensitiveDataCleaner.setObjectFieldToBlank(obj, 'field2.f4.ff4');
        System.assertEquals('', ((Map<String, Object>)((Map<String, Object>)obj.get('field2')).get('f4')).get('ff4'), 'Expected blank field value');

        //code coverage
        SensitiveDataCleaner.setObjectFieldToBlank(null, '');
    }

    @isTest
    static void testRemoveSensitiveData () {
        final Map<String, Object> valueByKey = new Map<String, Object>{
            'field1' => 'value1',
            'field2' => 'value2'
        };
        SensitiveDataCleaner.removeSensitiveData(new Object[] {valueByKey}, new List<String>{'field1'});
        System.assertEquals('', valueByKey.get('field1'), 'expected blank value');
        System.assertEquals('value2', valueByKey.get('field2'), 'expected value to be preserved');

    }
    @isTest
    static void testLoadIsCleanRequired () {
        final MyDAO dao = new MyDAO();
        SensitiveDataCleaner.DAO = dao;
        // by default - clean is required
        dao.testAccount = new Account(Segment__pc = 'Staff');
        System.assert(SensitiveDataCleaner.loadIsDataCleaningRequired('testCustomerId'), 'Expected TRUE because Segment = Staff');

        // check that bypass via custom setting is taken into account
        dao.testIsAllowedToViewStaffData = true;

        System.assertEquals(false, SensitiveDataCleaner.loadIsDataCleaningRequired('testCustomerId'), 'Expected FALSE because Segment = Staff');
    }

    @isTest
    static void testGetStaffHideTransactionDate(){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acc = new Account(LastName='Test Account', RecordTypeId=devRecordTypeId, CIF__pc='cus_XXX', Segment__pc='Staff', PersonEmail='Test@gmail.com');
        insert acc;
        Test.startTest();
        List<Map<String, Datetime>> lstBannedDates1 = SensitiveDataCleaner.getStaffHideTransactionDate('cus_XXX');

        List<Object> testObject1 = new List<Object>();

        List<Map<String, Datetime>> testBannedDate1 = new List<Map<String, Datetime>>();
        SensitiveDataCleaner.filterBannedDate('field1',lstBannedDates1,testObject1);


        acc.Segment__pc = 'Regular';
        update acc;

        insert new AccountHistory(AccountId=acc.Id, Field = 'Segment__pc');
        acc.Segment__pc = 'Staff';
        update acc;
        insert new AccountHistory(AccountId=acc.Id, Field = 'Segment__pc');
        acc.Segment__pc = 'Regular';
        update acc;
        insert new AccountHistory(AccountId=acc.Id, Field = 'Segment__pc');
            List<Map<String, Datetime>> lstBannedDates = SensitiveDataCleaner.getStaffHideTransactionDate('cus_XXX');

       List<Object> testObject = new List<Object>();

       List<Map<String, Datetime>> testBannedDate = new List<Map<String, Datetime>>();
        SensitiveDataCleaner.filterBannedDate('field1',lstBannedDates,testObject);
        Test.stopTest();

        System.debug('>>>>>>>>>>' + lstBannedDates);

    }
    @isTest
    static void testBolloeanMethods(){
        SensitiveDataCleaner.isAllowedViewStaffData('cus_XXX');
    }

    @isTest
    static void testLoadAccountTransactions_Bahrain () {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": { "code": "10009", "message":"Transaction Details for Account Id has been retrieved successfully." },'+
                        '"data": {'+
                                '"transactions":[{"id":"xxxxxx","transactionDate":"2020-06-18T10:51:00","valueDate":"2020-06-18","transactionType":"ACTD","transactionCurrency":{"code":"BHD","decimalPlaces":"3"},"accountCurrency":{"code":"BHD","decimalPlaces":"3"},"transactionDescription1":"From Prashant Mohite","transactionDescription2":"xxxxxxxxxxxxx","transactionDescription3":"PERSONAL TRANSFER BHD","transactionDescription4":"","transactionDescription5":"","transactionDescription6":"","amount":75.000,"originalAmount":75.000000,"reference":"820043210000","previousBalance":0.000,"currentBalance":75.000,"generateAdvice":true,"status":"Completed"}]}}'+
                            '}'+
                        '}';

        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = BankAccountController.loadAccountTransactions('testCustomerId', '{}',BAHRAIN_REGION);
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

   @isTest
    static void checkStaffVisibilityForStatementsTest () {
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account acc = new Account(LastName='Test Account Regular', RecordTypeId=devRecordTypeId, CIF__pc='cus_XXX', Segment__pc='Regular', PersonEmail='Test1@gmail.com');
        insert acc;
        
        // test if never was staff
        System.assertEquals(SensitiveDataCleaner.checkStaffVisibilityForStatements(acc.Id), true);

        insert new AccountHistory(AccountId=acc.Id, Field = 'Segment__pc');
        acc.Segment__pc = 'Staff';
        update acc;
        // test if is staff && have access to custom setting 
        System.assertEquals(SensitiveDataCleaner.checkStaffVisibilityForStatements(acc.Id), true);

        //check when accoun empty
        System.assertEquals(SensitiveDataCleaner.checkStaffVisibilityForStatements(UserInfo.getUserId()), false);

    }
   
}
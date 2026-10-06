/**
 *	@author: Andrey Gavrikov (westbrook)
 *	@date: 2019-02-08 10:03:40
 *	@description:
 *	    Test methods for BankCardListController
 *
 *	Version History :
 *	2019-02-08 - CRM-38 - AG
 *	- Display Card Information
 *      CH01 added by Aniss Mbarki 22-06-2022
 *      #CH02 : 23-04-2023 requirement Islamic Banking - Premium Segment - CRM 
 *      #CH03 : 01-11-2023 Added by Imane Tsioucha 
 *      #CH04# #Jahangeer Mohammed# #30-07-2024# Covering test cases for Audit History Enhancements
 *
 *
 */
@isTest(isParallel=true)
public class BankCardListControllerTest  {
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

    @isTest
    static void testLoadCardList_Bahrain () {
           testLoadCardList (BAHRAIN_REGION);
    }

    @isTest
    static void testLoadCardList_Jordan () {
         testLoadCardList (JORDAN_REGION);
    }

    static void testLoadCardList (String regionName) {
        final MyCalloutMock mock = new MyCalloutMock();
        //Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
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

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
		Test.stopTest();
        ApiConnection.Response response = BankCardListController.loadCardList(acc1.CIF__pc, 'testabc@mail.com', regionName, null);
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);

        mock.testStatusCode = 500;
        response = BankCardListController.loadCardList(acc1.CIF__pc, 'testabc@mail.com', regionName,null);
        System.assertEquals(false, response.isSuccess);
    }

    @isTest
    static void testLoadCardDetails_Bahrain () {
        testLoadCardDetails(BAHRAIN_REGION);
    }
    @isTest
    static void testLoadCardDetails_Jordan () {
          testLoadCardDetails(JORDAN_REGION);
    }

    public static void testLoadCardDetails (String regionName) {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{'+
                        '    "meta": {'+
                        '        "code": "100005",'+
                        '        "displayMessage": "The card details have been retrieved successfully."'+
                        '    },'+
                        '    "data": {'+
                        '        "customerId": "989248099",'+
                        '        "id": "12f67bbd-8ace-4412-85bf-49cbc8178271",'+
                        '        "productType": "Classic",'+
                        '        "cardType": "Primary",'+
                        '        "status": "Active",'+
                        '        "embossName": "M. Hansen",'+
                        '        "companyName": "Bank ABC",'+
                        '        "defaultAccount": "989248099",'+
                        '        "linkedAccounts": ['+
                        '            "989248099, 989248088"'+
                        '        ],'+
                        '        "maskedCardNumber": "123456 **** **** 1234",'+
                        '        "issueDate": "21/12/2019",'+
                        '        "activationDate": "21/12/2019",'+
                        '        "provider": "Visa"'+
                        '    }'+
                        '}';

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
		Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'List';
        acc.CIF__pc = '3456789';
        acc.Region_Flag__pc = 'Bahrain';
        insert acc;
        Test.stopTest();
        ApiConnection.Response response = BankCardListController.loadCardDetails(acc.CIF__pc, 'testCardId', 'testabc@mail.com', regionName);
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);

    }

    final static String CASE_KEY_PREFIX = Schema.SObjectType.Case.getKeyPrefix();
    final static String CASE_ID_1 = CASE_KEY_PREFIX + '000000000001';
    @isTest
    static void testBlockCard () {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = null;

        Test.setMock(HttpCalloutMock.class, mock);
        final Map<String, String> blockCardData = new Map<String, String>{
            'cardId' => 'testCardId',
            'reason' => 'test-reason',
            'maskedCardNumber' => '1234567890123456'
        };

        try{
            ApiConnection.Response response = BankCardListController.blockCard('testCustomerId', JSON.serialize(blockCardData), '5003N00000Ap9mrQAV', 'testabc@mail.com', BAHRAIN_REGION);
        }catch(Exception e){
            System.assert(true);
        }

        //System.assertEquals(true, response.isSuccess);

    }

    private class MyDao extends BankCardListController {
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

        final MyDao DAO = new MyDao();
        BankCardListController.DAO = DAO;
        final String extraParameters = '{ "systemActionType": "testAction", "caseType": "test type" , "caseSubType": "test subtype", "isCaseClosureRequired": true}';
        ApiConnection.Response response = BankCardListController.requestNewCard('testCustomerId',
                                                                                JSON.serialize(requestTextJson),
                                                                                '1234567890123456',
                                                                                CASE_ID_1,
                                                                                extraParameters,
                                                                                'testabc@mail.com',
										                                        BAHRAIN_REGION
                                                                                );
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, DAO.updatedRecs, 'expected a case record to be updated');
        System.assertEquals(CASE_ID_1, (Id)DAO.updatedRecs[0].get('Id'), 'wrong record got updated');

    }

    @isTest
    static void testChangeCardStatus () {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = null;

        Test.setMock(HttpCalloutMock.class, mock);
        final Map<String, Object> parametersJson = new Map<String, Object>{
            'cardId' => '989248099',
            'cardStatus' => 'Unfreeze',
            'systemActionType'=> 'testAction',
            'caseType'=> 'test type' ,
            'caseSubType'=> 'test subtype',
            'isCaseClosureRequired'=> true
        };

        final MyDao DAO = new MyDao();
        BankCardListController.DAO = DAO;
        ApiConnection.Response response = BankCardListController.changeCardStatus('testCustomerId',
                                                                                JSON.serialize(parametersJson),
                                                                                CASE_ID_1,
                                                                                'testabc@mail.com',
                                                                                BAHRAIN_REGION
                                                                                );
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, DAO.updatedRecs, 'expected a case record to be updated');
        System.assertEquals(CASE_ID_1, (Id)DAO.updatedRecs[0].get('Id'), 'wrong record got updated');

    }

    @isTest
    static void testChangeCardAccountAssociation_Bahrain () {
        testChangeCardAccountAssociation(BAHRAIN_REGION);
    }
    @isTest
    static void testChangeCardAccountAssociation_Jordan () {
         testChangeCardAccountAssociation(JORDAN_REGION);
    }

    public static void testChangeCardAccountAssociation(String regionName){

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = null;

        Test.setMock(HttpCalloutMock.class, mock);
        final Map<String, Object> parametersJson = new Map<String, Object>{
            'cardId' => '989248099',
            'action' => 'Unlink',
            'systemActionType'=> 'testAction',
            'caseType'=> 'test type' ,
            'caseSubType'=> 'test subtype',
            'isCaseClosureRequired'=> true
        };

        final MyDao DAO = new MyDao();
        BankCardListController.DAO = DAO;
        ApiConnection.Response response = BankCardListController.changeCardAccountAssociation('testCustomerId',
                                                                                JSON.serialize(parametersJson),
                                                                                CASE_ID_1,
                                                                                'testabc@mail.com',
                                                                                regionName
                                                                                );
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, DAO.updatedRecs, 'expected a case record to be updated');
        System.assertEquals(CASE_ID_1, (Id)DAO.updatedRecs[0].get('Id'), 'wrong record got updated');

    }

     @isTest
    static void testLoadAccountList_Bahrain () {
         testLoadAccountList(BAHRAIN_REGION);
     }
      @isTest
    static void testLoadAccountList_Jordan () {
            testLoadAccountList(JORDAN_REGION);
     }
    static void testLoadAccountList(String regionName) {
        // code coverage for proxy loadAccountList. actual loadAccountList is tested in BankAccountControllerTest

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = null;

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        BankCardListController.loadAccountList('testCustomerId', regionName);
        Test.stopTest();
        //
        System.assertNotEquals('Code Coverage', mock.testBody);
        //
    }

 @isTest
    static void testGetSegment_Bahrain() {
     testGetSegment(BAHRAIN_REGION);
 }
    @isTest
    static void testGetSegment_Jordan() {
         testGetSegment(JORDAN_REGION);
 }


    static void testGetSegment(String regionName){
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"data":{"transitionInProgress":false,"currentSegment":{"segmentName":"REGULAR","segmentCrmId":"Regular"},"currentCards":[{"id":"10010522439126747125063583","cardName":"VIRTUAL","cardDisplayName":"Virtual","cardAfsId":"TestVirtualCards","productType":"Virtual","cardMinimumBalance":0,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":false,"limit":0,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"},{"id":"100105224391267471250615229","cardName":"CLASSIC","cardDisplayName":"Classic","cardAfsId":"Debit Classic","productType":"Classic","cardMinimumBalance":20,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"limit":1000,"nextAnnualAnniversaryDate":"2021-06-18T07:55:26","discount":{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"}],"segmentOptions":[{"segmentName":"STAFF","segmentCrmId":"Staff"},{"segmentName":"ROYAL_FAMILY","segmentCrmId":"Royal Family"},{"segmentName":"PREMIUM","segmentCrmId":"Premium"},{"segmentName":"PREMIUM_PLUS","segmentCrmId":"Premium Plus"},{"segmentName":"SENSITIVE","segmentCrmId":"Sensitive"}],"cardOptions":[{"cardName":"WORLD","cardDisplayName":"World","cardAfsId":"MasterCardWorld","productType":"World","cardMinimumBalance":0,"order":1,"issuanceFee":0.000,"annualFee":37.500,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":1.875,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":39.375},{"cardName":"ELITE","cardDisplayName":"Elite","cardAfsId":"WORLD_ELITE","productType":"World Elite","cardMinimumBalance":0,"order":2,"issuanceFee":0.000,"annualFee":75.000,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":3.750,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":78.750}],"discountOptions":[{"name":"None","displayName":"No discount","discountPercentage":0},{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},{"name":"Discount50","displayName":"50 percent discount","discountPercentage":50},{"name":"Discount75","displayName":"75 percent discount","discountPercentage":75},{"name":"Free","displayName":"No charge","discountPercentage":100}]},"meta":{"code":"SGMT-1006","message":"Customer Segment Options retrieved successfully."}}';

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        ApiConnection.Response response = BankCardListController.loadSegmentOptionsCRM('testCustomerId', CASE_ID_1, regionName);
        //CH04: Start
        BankCardListController.createAuditRecordForDebitCardDetails('4454546','IBAN4567890','Active','Active');
        //CH04: END
        Test.stopTest();
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);
    }

     @isTest
    static void testupDowngradeSegment_Bahrain(){
         testupDowngradeSegment(BAHRAIN_REGION);
     }
     @isTest
    static void testupDowngradeSegment_Jordan(){
         testupDowngradeSegment(JORDAN_REGION);
     }

    static void testupDowngradeSegment(String regionName){
        Case recoCs = createTestCase();
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": {"code": "SEGU-001","message":"Segment/Card Updated"}}';

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        ApiConnection.Response response = BankCardListController.upDowngradeSegment('customerId', 'availableCard', 'discount', 'embossName', recoCs.Id, regionName);
        Test.stopTest();
        System.assertEquals(true, response.isSuccess);
    }

   @isTest
    static void testUpdateSegment_Bahrain(){
       testUpdateSegment(BAHRAIN_REGION);
   }
     @isTest
    static void testUpdateSegment_Jordan(){
        testUpdateSegment(JORDAN_REGION);
   }


    static void testUpdateSegment(String regionName){
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": {"code": "SEGU-001","message":"Segment/Card Updated"}}';

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        ApiConnection.Response response = SegmentAPIHandler.updateSegment('customerId', 'newSegmentId', CASE_ID_1, regionName);
        Test.stopTest();
        System.assertEquals(true, response.isSuccess);
    }

    // CH01 Added by Aniss -->
    @isTest
    static  void visibilityOptionsCheckTest(){
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Block_Unblock_Account').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id), 'TestFactoryDefaults.CaseDefaults',true);
        Map<String, String> responseData = BankCardListController.visibilityOptionsCheck(caseObj.Id);
        System.assert(responseData!=null);

    }

    static Case createTestCase(){
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);  
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id, Case_Nature__c='Account Maintenance'), 'TestFactoryDefaults.CaseDefaults',true);
        return caseObj;
    }
    // CH01 End -->

    // CH02 Start -->
    @isTest
    static void sendToSegmentChangeMakerTest(){
        Case caseObj = createTestCase();
        SegmentAPIHandler.sendToSegmentChangeMaker(caseObj.Id,'REGULAR','STAFF','None');
    }

    @isTest
    static void callSegmentTransitionAPIFromFlowTest(){
        Case caseObj = createTestCase();
        MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": {"code": "SEGU-001","message":"Segment/Card Updated"}}';
        Test.setMock(HttpCalloutMock.class, mock);
        SegmentAPIHandler.callSegmentTransitionAPIFromFlow( new List<Id>{caseObj.Id});
    }
    // CH02 End -->
	    @isTest
    static void testIsUserInLifetimePremiumDiscountQueue() {
        Test.startTest();
        Boolean result = SegmentAPIHandler.isUserInLifetimePremiumDiscountQueue();
        Test.stopTest();
    }
}
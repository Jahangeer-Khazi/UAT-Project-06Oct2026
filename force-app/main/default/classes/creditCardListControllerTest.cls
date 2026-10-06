/**
*  @author: Shashank
*  @date: 25/05/2021
*  @description:
*      test class for controller for aura components related to Credit cards
*       #CH01 : Added #Jahangeer Mohammed# #21-01-2022# Added fake success response for test coverage
*       #CH02# Added by Amina BENABDELKRIM  20-06-2022 *** adding case model & region Name parameter to the method 
*       #CH03# Added #Jahangeer Mohammed# #30-11-2022# method to increase code coverage
*		#CH04# Added #Maksud Ali# #08-04-2025# method to increase code coverage for Cash Collateral
*/

@isTest
public class creditCardListControllerTest {
    private static final String BAHRAIN_REGION = 'Bahrain';
    private static final String JORDAN_REGION = 'Jordan';

    private class MyCalloutMock implements HttpCalloutMock{
        public Integer testStatusCode = 400;
        public string testBody;

        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(testStatusCode);
            if(testBody == NULL){
                res.setBody('Get Callout');
            }else{
                system.debug('not null->'+testBody);
                res.setBody(testBody);
            }
            return res;
        }
    }
     //CH01: Start
    private class MyCalloutMockSuccess implements HttpCalloutMock{
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
    //CH01 : END
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

    final static String ACCOUNT_KEY_PREFIX = Schema.SObjectType.Account.getKeyPrefix();
    final static String ACCOUNT_ID_1 = ACCOUNT_KEY_PREFIX + '000000000001';
    final static String CASE_KEY_PREFIX = Schema.SObjectType.Case.getKeyPrefix();
    final static String CASE_ID_1 = CASE_KEY_PREFIX + '000000000001';

     @isTest
    static void testLoadCardList_Bahrain(){
        testLoadCardList(BAHRAIN_REGION);
     }
    @isTest
    static void testLoadCardList_Jordan(){
         testLoadCardList(JORDAN_REGION);
     }

    static void testLoadCardList(String regionName){
        //List<Sobject> testList = new <SObject>();
        Account acc = createAccount();
        Case objCase = createCase(acc);

        //testList.add(acc);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        system.debug('STATUS CODE'+res.getStatusCode());
        ApiConnection.Response response = creditCardListController.loadCardList(acc.CIF__pc,acc.PersonEmail, regionName);
        //creditCardListController.loadCardDetails(acc.CIF__pc,'123abc098xyz',acc.PersonEmail);
        //creditCardListController.loadRecord(acc.Id);
        //creditCardListController.loadRecord(objCase.Id);
        //creditCardListController.loadTabsConfig();
        //creditCardListController.updateRecords();
        test.stopTest();
    }


    @isTest
    static void testLoadCardDetails(){
        Account acc = createAccount();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        system.debug('STATUS CODE'+res.getStatusCode());
        ApiConnection.Response response = creditCardListController.loadCardDetails(acc.CIF__pc,'123abc098xyz',acc.PersonEmail, BAHRAIN_REGION);
        test.stopTest();
    }
     //CH01: Start
    @isTest
    static void eppListUnitTest(){
        Account acc = createAccount();
        test.startTest();
         final MyCalloutMockSuccess mock = new MyCalloutMockSuccess();
         mock.testBody = '{"meta": { "code": "10009", "displayMessage": "EPP list has been retrieved successfully." },'+
                        '"data": {'+
                            '"eppList": [ '+
                            '    { '+
                            '        "planNumber": "989248099", '+
                            '        "sequence": "12f67bbd-8ace-4412-85bf-49cbc8178271", '+
                            '        "transactionAmount": "1000", '+
                            '        "merchant": "Main account (BHD)", '+
                            '        "remainingBalance": "200", '+
                            '        "installementAmount": "100", '+
                            '        "tenor": "12", '+
                            '        "installementBookingDate": "21/12/2019", '+
                            '        "numberOfInstallementsPaid": "3", '+
                            '        "numberOfInstallementsRemaining": "9" '+
                            '    } '+ 
                            ' ] ' + 
                            '}'+
                        '}';
        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = creditCardListController.loadEPPList(acc.CIF__pc,'5789404212345678','Bahrain');
        Test.stopTest();
        
    }
    //CH01: END
    @isTest
    static void testBlockCard(){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        system.debug('STATUS CODE'+res.getStatusCode());
        Map<String, Object> testBlockData  = new Map<String,Object>();
        testBlockData.put('cardId', (Object)'testObj1');
        testBlockData.put('actionType',(Object)'testObj2');
        testBlockData.put('reason',(Object)'testObj3');
        testBlockData.put('maskedCardNumber',(Object)'testObj4');
        String blockdata = (String)JSON.serialize(testBlockData);
        ApiConnection.Response response = creditCardListController.blockCard(acc.CIF__pc,blockdata,objCase.Id,acc.PersonEmail, BAHRAIN_REGION);
        test.stopTest();
    }
    @isTest
    static void testrequestNewCard(){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        String requestData = '"{"'+
            '"accountId": "defaultAccount",'+
            '"productType": "productType",'+
            '"cardType":  "existingCardDetails",'+
            '"deliveryType": "deliveryType",'+
            '"status": "Inactive",'+
        '"}"';
        Test.startTest();
        Map<String, Object> extraParametersData  = new Map<String,Object>();
        extraParametersData.put('systemActionType', (Object)'testObj1');
        extraParametersData.put('caseSubType',(Object)'testObj2');
        extraParametersData.put('isCaseClosureRequired',(Object)'testObj3');
        extraParametersData.put('caseType',(Object)'testObj4');
        String extraParameters = (String)JSON.serialize(extraParametersData);
        creditCardListController.requestNewCard(acc.CIF__pc,requestData,'maskedCardNumber',objCase.Id,extraParameters,acc.PersonEmail, BAHRAIN_REGION);
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = requestData;
        test.stopTest();
    }
    @isTest
    static void testChangeCardStatus_Bahrain(){
        testChangeCardStatus(BAHRAIN_REGION);
    }
     @isTest
    static void testChangeCardStatus_Jordan(){
        testChangeCardStatus(JORDAN_REGION);
    }

    static void testChangeCardStatus(String regionName){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        Test.startTest();
        Map<String, Object> parameterData  = new Map<String,Object>();
        parameterData.put('cardId', (Object)'testObj1');
        parameterData.put('actionType',(Object)'testObj2');
        parameterData.put('cardStatus',(Object)'testObj3');
        parameterData.put('maskedCardNumber',(Object)'testObj4');
        parameterData.put('isCaseClosureRequired',(Object)true);
        parameterData.put('caseType',(Object)'Credit Card Application');
        parameterData.put('caseSubType',(Object)'New Credit Card');

        String parameter = (String)JSON.serialize(ParameterData);
        final Map<String, String> requestObject = new Map<String, String>{
            'id' => 'cardId',
                'status' => 'status'
                };
        final String requestText = JSON.serialize(requestObject);
        creditCardListController.changeCardStatus(acc.CIF__pc,parameter,objCase.Id,acc.PersonEmail, regionName);
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = requestText;
        test.stopTest();

    }

    @isTest
    static void testChangeCardAccountAssociation_Bahrain() {
        testChangeCardAccountAssociation(BAHRAIN_REGION);
    }
    @isTest
    static void testChangeCardAccountAssociation_Jordan() {
         testChangeCardAccountAssociation(JORDAN_REGION);
    }

    static void testChangeCardAccountAssociation(String regionName){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        Test.startTest();
        Map<String, Object> parameterData  = new Map<String,Object>();
        parameterData.put('cardId', (Object)'testObj1');
        parameterData.put('actionType',(Object)'testObj2');
        parameterData.put('cardStatus',(Object)'testObj3');
        parameterData.put('maskedCardNumber',(Object)'testObj4');
        parameterData.put('isCaseClosureRequired',(Object)true);
        parameterData.put('caseType',(Object)'Credit Card Application');
        parameterData.put('caseSubType',(Object)'New Credit Card');

        String parameter = (String)JSON.serialize(ParameterData);
        final Map<String, String> requestObject = new Map<String, String>{
            'id' => 'cardId',
                'accountId' => 'accountId',
                'action' => 'action',
                'customerId' => 'customerId'
                };
        final String requestText = JSON.serialize(requestObject);
        creditCardListController.changeCardAccountAssociation(acc.CIF__pc,parameter,objCase.Id,acc.PersonEmail, regionName);

        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = requestText;
        test.stopTest();

    }
     @isTest
    static void testGetCaseSubType(){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        creditCardListController.getCaseSubType(objCase.Id);
        creditCardListController.caseType(objCase.Id);
        creditCardListController.getDefaultName(acc.Id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        creditCardListController.getCardOptions(acc.Id,'ila');//CH02
        creditCardListController.getPCIOptions(acc.Id,'ila');//CH02
        creditCardListController.getPCIOptionsV2(acc.Id,null);//CH02
        creditCardListController.getPCIOptionsCashCollateralLimitIncrease(acc.Id,'ila');
        try {
            creditCardListController.termDepositList(acc.Id,null);//CH02
        } catch (Exception exp) {}
      // creditCardListController.getPCIOptionsCashCollateralLimitIncrease(acc.Id);
        test.stopTest();
    }
      @isTest
    static void testGetCaseSubTypeRestMock2(){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        //HttpResponse res = CalloutClass.getInfoFromExternalService();
        creditCardListController.getCardOptions(acc.Id,'ila');
        creditCardListController.getPCIOptions(acc.Id,'ila');
        creditCardListController.getPCIOptionsV2(acc.Id,'ila');
        creditCardListController.getPCIOptionsCashCollateralLimitIncrease(acc.Id,'ila');
         //creditCardListController.getPCIOptionsCashCollateralLimitIncrease(acc.Id);
        test.stopTest();
    }
    @isTest
    static void testLoadAccountTransactionse_Bahrain(){
        testLoadAccountTransactionse(BAHRAIN_REGION);
    }
      @isTest
    static void testLoadAccountTransactionse_Jordan(){
         testLoadAccountTransactionse(JORDAN_REGION);
    }

    static void testLoadAccountTransactionse(String regionName){
        String transactionParam = '"fromDate":"jsonToDate",'+
            '"toDate":"jsonFromDate",'+
           '"debitCreditIndicator": "ALL",'+
            '"fromAmount": 0,'+
           '"toAmount": 1000,'+
           '"cardAccountIndicator": "ALL",'+
            '"offset": 1,'+
            '"pageSize": 20';
        test.startTest();
        Map<String, Object> parameterData  = new Map<String,Object>();
        parameterData.put('cardId', (Object)'testObj1');
        parameterData.put('actionType',(Object)'testObj2');
        parameterData.put('cardStatus',(Object)'testObj3');
        parameterData.put('maskedCardNumber',(Object)'testObj4');
        parameterData.put('isCaseClosureRequired',(Object)true);
        parameterData.put('caseType',(Object)'Credit Card Application');
        parameterData.put('caseSubType',(Object)'New Credit Card');

        String parameter = (String)JSON.serialize(ParameterData);

        Account acc = createAccount();

        creditCardListController.loadAccountTransactions(acc.CIF__pc,transactionParam, regionName);
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = transactionParam;
        test.stopTest();

    }

    @isTest
    static void testCreditCardStatusListWithAccount(){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        //creditCardListController.creditCardStatusList('{}',acc.Id);
        test.stopTest();
    }
    @isTest
    static void testCreditCardStatusListWithCase(){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        //creditCardListController.creditCardStatusList('{}',objCase.Id);
        test.stopTest();
    }
     @isTest
    static void testcreditCardFCRAPI1(){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        Map<String, Object> parameterData  = new Map<String,Object>();
        parameterData.put('cardId', (Object)'testObj1');
        parameterData.put('actionType',(Object)'Freeze Card');
        parameterData.put('cardStatus',(Object)'testObj3');
        parameterData.put('reason',(Object)'testObj4');
        parameterData.put('isCaseClosureRequired',(Object)true);

        String parameter = (String)JSON.serialize(ParameterData);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        creditCardListController.creditCardFCRAPI(acc.CIF__pc,parameter,objCase.Id,acc.PersonEmail, 'Bahrain');
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody ='{"pciNumber": "'+acc.CIF__pc + '","status": "FREEZE"}';
        test.stopTest();
    }
    @isTest
    static void testcreditCardFCRAPI2(){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        Map<String, Object> parameterData  = new Map<String,Object>();
        parameterData.put('cardId', (Object)'testObj1');
        parameterData.put('actionType',(Object)'Unfreeze Card');
        parameterData.put('cardStatus',(Object)'testObj3');
        parameterData.put('reason',(Object)'testObj4');
        parameterData.put('isCaseClosureRequired',(Object)true);

        String parameter = (String)JSON.serialize(ParameterData);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        creditCardListController.creditCardFCRAPI(acc.CIF__pc,parameter,objCase.Id,acc.PersonEmail,'Bahrain');//CH02
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody ='{"pciNumber": "'+acc.CIF__pc + '","status": "UNFREEZE"}';
        test.stopTest();
    }
    @isTest
    static void testcreditCardFCRAPI3(){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        Map<String, Object> parameterData  = new Map<String,Object>();
        parameterData.put('cardId', (Object)'testObj1');
        parameterData.put('actionType',(Object)'temporaryBlock');
        parameterData.put('cardStatus',(Object)'testObj3');
        parameterData.put('reason',(Object)'testObj4');
        parameterData.put('isCaseClosureRequired',(Object)true);

        String parameter = (String)JSON.serialize(ParameterData);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        creditCardListController.creditCardFCRAPI(acc.CIF__pc,parameter,objCase.Id,acc.PersonEmail,'Bahrain');//CH02
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody ='{"pciNumber": "'+acc.CIF__pc + '","reason":"reason"}';
        test.stopTest();
    }
    @isTest
    static void testcreditCardFCRAPI4(){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        Map<String, Object> parameterData  = new Map<String,Object>();
        parameterData.put('cardId', (Object)'testObj1');
        parameterData.put('actionType',(Object)'Unblock');
        parameterData.put('cardStatus',(Object)'testObj3');
        parameterData.put('reason',(Object)'testObj4');
        parameterData.put('isCaseClosureRequired',(Object)true);

        String parameter = (String)JSON.serialize(ParameterData);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        creditCardListController.creditCardFCRAPI(acc.CIF__pc,parameter,objCase.Id,acc.PersonEmail,'Bahrain');//CH02
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody ='{"pciNumber": "'+acc.CIF__pc + '","reason":"reason"}';
        test.stopTest();
    }
    @isTest
    static void testcreditCardFCRAPI5(){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        Map<String, Object> parameterData  = new Map<String,Object>();
        parameterData.put('cardId', (Object)'testObj1');
        parameterData.put('actionType',(Object)'Replace Card');
        parameterData.put('cardStatus',(Object)'testObj3');
        parameterData.put('reason',(Object)'testObj4');
        parameterData.put('isCaseClosureRequired',(Object)true);

        String parameter = (String)JSON.serialize(ParameterData);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        creditCardListController.creditCardFCRAPI(acc.CIF__pc,parameter,objCase.Id,acc.PersonEmail,'Bahrain');//CH02
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody ='{"pciNumber": "'+acc.CIF__pc + '","reason":"reason"}';
        test.stopTest();
    }
    //CH03: Start
    @isTest
    static void testcreditCardFCRAPI6(){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        Map<String, Object> parameterData  = new Map<String,Object>();
        parameterData.put('cardId', (Object)'testObj1');
        parameterData.put('actionType',(Object)'ReactivateDormantCard');
        parameterData.put('cardStatus',(Object)'testObj3');
        parameterData.put('reason',(Object)'testObj4');
        parameterData.put('isCaseClosureRequired',(Object)true);

        String parameter = (String)JSON.serialize(ParameterData);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        creditCardListController.creditCardFCRAPI(acc.CIF__pc,parameter,objCase.Id,acc.PersonEmail,'Bahrain');//CH02
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody ='{"pciNumber": "'+acc.CIF__pc + '","reason":"reason"}';
        test.stopTest();
    }
    //CH03: END

    public static Account createAccount(){
        Account acc = new Account();
        //acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.LastName = 'LastName new';
        acc.PersonEmail= 'testAcc11@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        acc.CIF__pc = '1234567';
        acc.Referral_Code__pc='abc1234';
        acc.Segment__pc = 'Regular';
        insert acc;

        return acc;
    }
    public static Case createCase(Account acc){
        Case objCase = new Case();
        objCase.Subject = 'Stop Jamiyah Account';
        objCase.Jamiyah_Id__c = 2134;
        objCase.Description = 'A technical issue has occurred at an API level.';
        objCase.Type = 'Stop Jamiyah';
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
        objCase.OwnerId = userInfo.getUserId();
        objCase.Origin = 'CRM';
        objCase.ContactId = acc.PersonContactId;
        objCase.AccountId = acc.id;
        objCase.Case_Model__c = 'ila';
        
        insert objCase;
        return objCase;
    }

   static testMethod void sendEmailWithPdf(){

        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Class';
        acc.PersonEmail = 'aws@ilabank.com';
        acc.RecordtypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        acc.Onboarding_Stage__pc = 'MOBILE_VERIFIED';
        acc.Onboarding_Group__pc = 'Registration';
        //acc.Referred_By__c =
        insert acc;

        Case cs = new Case();
        cs.Subject = 'Test Case';
        cs.Description = 'Test Description';
        cs.Type = 'IBAN Certificate';
        cs.Status = 'In Progress';
        cs.Priority = 'High';
        cs.Origin = 'Phone';
        cs.ContactId = acc.PersonContactId;
        cs.AccountId = acc.id;
        cs.Case_Model__c = 'ila';

        insert cs;

        creditCardListController obj01 = new creditCardListController();
        creditCardListController.sendEmailWithPdf(cs.Id,'IBAN43849347','2020-12-12','BH');
        //creditCardListController.sendEmailWithPdf(cs.Id);
        creditCardListController.sendForRejection(cs.id);
        creditCardListController.sendToBusinessApproval(cs.id);
  }
    
   /* static testMethod void sendEmailWithPdfAlburaq(){
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Class';
        acc.PersonEmail = 'aws@ilabank.com';
        acc.RecordtypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        acc.Onboarding_Stage__pc = 'MOBILE_VERIFIED';
        acc.Onboarding_Group__pc = 'Registration';
        acc.Subscription_Model__pc='alburaq';
        //acc.Referred_By__c =
        insert acc;
        Case cs = new Case();
        cs.Subject = 'Test Case';
        cs.Description = 'Test Description';
        cs.Type = 'IBAN Certificate';
        cs.Status = 'In Progress';
        cs.Priority = 'High';
        cs.Origin = 'Phone';
        cs.ContactId = acc.PersonContactId;
        cs.AccountId = acc.id;
        cs.Case_Model__c = 'alburaq';
        insert cs;
        creditCardListController obj01 = new creditCardListController();
        creditCardListController.sendEmailWithPdf(cs.Id,'IBAN43849347','2020-12-12','BH');
        //creditCardListController.sendEmailWithPdf(cs.Id);
        creditCardListController.sendForRejection(cs.id);
        creditCardListController.sendToBusinessApproval(cs.id);
  }*/
     //CH03: Start
    @isTest
    static void testcreditCardRewardCASHBACK(){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        creditCardListController.loadRewardDetails(acc.CIF__pc,'testObj1','Bahrain','CASHBACK');//CH02
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody ='{"isSuccess":true,"data":{"paymentOptionHistory":[{"prefrerredPaymentOption": "ILA_TOKENS","requestedDate": "2022-10-05 09:09:09","effectiveDate": "2022-10-05 09:09:09"},{"prefrerredPaymentOption": "CASHBACK","requestedDate": "2022-09-05 09:09:09","effectiveDate": "2022-09-21 09:09:09"}]}}}}';
        test.stopTest();
    }
     @isTest
    static void testcreditCardRewardILA_TOKENS(){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        creditCardListController.loadRewardDetails(acc.CIF__pc,'testObj1','Bahrain','ILA_TOKENS');//CH02
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody ='{"isSuccess":true,"data":{"paymentOptionHistory":[{"prefrerredPaymentOption": "ILA_TOKENS","requestedDate": "2022-10-05 09:09:09","effectiveDate": "2022-10-05 09:09:09"},{"prefrerredPaymentOption": "CASHBACK","requestedDate": "2022-09-05 09:09:09","effectiveDate": "2022-09-21 09:09:09"}]}}}}';
        test.stopTest();
    }
	  @isTest
    static void testcreditCardRewardAIRLINE_MILES(){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        creditCardListController.loadRewardDetails(acc.CIF__pc,'testObj1','Bahrain','AIRLINE_MILES');//CH02
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody ='{"isSuccess":true,"data":{"paymentOptionHistory":[{"prefrerredPaymentOption": "ILA_TOKENS","requestedDate": "2022-10-05 09:09:09","effectiveDate": "2022-10-05 09:09:09"},{"prefrerredPaymentOption": "CASHBACK","requestedDate": "2022-09-05 09:09:09","effectiveDate": "2022-09-21 09:09:09"}]}}}}';
        test.stopTest();
    }

    @isTest
    static void testtermDepositList(){
        Account acc = createAccount();
        Case objCase = createCase(acc);
        Test.startTest(); 
        
        final MyCalloutMockSuccess mock = new MyCalloutMockSuccess();
        mock.testBody = '{"meta": { "code": "10009", "displayMessage": "EPP list has been retrieved successfully." },'+
                        '"data": {'+
                            '"termDeposits": [ '+
                            '    { '+
                            '        "planNumber": "989248099", '+
                            '        "sequence": "12f67bbd-8ace-4412-85bf-49cbc8178271", '+
                            '        "transactionAmount": "1000", '+
                            '        "merchant": "Main account (BHD)", '+
                            '        "remainingBalance": "200", '+
                            '        "installementAmount": "100", '+
                            '        "tenor": "12", '+
                            '        "installementBookingDate": "21/12/2019", '+
                            '        "numberOfInstallementsPaid": "3", '+
                            '        "numberOfInstallementsRemaining": "9" '+
                            '    } '+ 
                            ' ] ' + 
                            '}'+
                        '}';
        Test.setMock(HttpCalloutMock.class, mock);
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        creditCardListController.termDepositList(acc.Id,'alburaq');
        test.stopTest();

    }
    
    //CH04:START
    @isTest
    static void downloadCashCollateralCertTest(){
        CashCollateralCertificateControllerTest.createAccountAndContact();
        CashCollateralCertificateControllerTest.createCreditCardFCRCase();
    	Case c = [Select Id,OwnerId FROM Case WHERE Subject = 'test case - cash collateral' LIMIT 1];
        Map<String,Object> cardDetails = CashCollateralCertificateControllerTest.getCreditCardDetailMap();
        
        String isCreditCardUser = creditCardListController.checkCreditCardUser();
        System.debug('isCreditCardUser ' + isCreditCardUser);
        ApiConnection.Response response = creditCardListController.downloadCashCollateral(c.Id,cardDetails);
        System.assertEquals(true,response.isSuccess,'Download Cash Collateral Method Failed.');
    }
    
    @isTest
    static void emailCashCollateralCertTest(){
        CashCollateralCertificateControllerTest.createAccountAndContact();
        CashCollateralCertificateControllerTest.createCreditCardFCRCase();
    	Case c = [Select Id,OwnerId FROM Case WHERE Subject = 'test case - cash collateral' LIMIT 1];
        Map<String,Object> cardDetails = CashCollateralCertificateControllerTest.getCreditCardDetailMap();
        
        String response = creditCardListController.sendEmailWithCashCollateralCert(c.Id,cardDetails);
        System.assertEquals('success',response,'Email Cash Collateral Certificate Failed.');
        
        String caseUpdateRes = creditCardListController.updateCaseStatus(c.Id);
        System.assertEquals('Success',caseUpdateRes,'Error while closing the case.');
    }
    //CH04:END
}
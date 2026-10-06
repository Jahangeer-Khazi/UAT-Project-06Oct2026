/**
 #CH01# Added by Imane tsioucha 20-06-2022 *** to add new field (case model) 
 #CH02# #Jahangeer Mohammed# #12-06-2023# Increase the Code Coverage of a Class
 */
@isTest
public class initiateManualOnboardingTest
{
   @testSetup
    static void dataSetup() {

        Profile p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User[] userList = new User[]{};
            User u = new User();

        u.FirstName = 'Test';
        u.LastName = 'Integration';
        u.Email = 'test@wexeurope.com';
        u.Username = 'astest@wexeurope.com';
        u.Alias = 'astest';
        u.ProfileId = p1.Id;
        u.TimeZoneSidKey    = 'America/Denver';
        u.LocaleSidKey      = 'en_US';
        u.EmailEncodingKey  = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        userList.add(u);

        insert userList;
    }
    private static ApiConnection con = new ApiConnection();
    
    private class MyCalloutMock implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 200;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');    
            res.setHeader('Content-Type', 'application/json');
            //res.setBody
            res.setStatusCode(testStatusCode);
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
    }
    
     private class MyCalloutMock1 implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 401;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('NOT OK');    
            res.setHeader('Content-Type', 'application/json');
            //res.setBody
            res.setStatusCode(testStatusCode);
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
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
    private class RestMock1 implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(401);
            return res;
        }
    }
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
    
    /* @isTest
    static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        
        System.assertEquals(200, res.getStatusCode());
    }
    
    
    @isTest
    static void testCallout1() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock1());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        
        System.assertEquals(401, res.getStatusCode());
    } */

    
    
    /* @isTest
    static void initiateManualOnboardingTest1 () {
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc.LastName = 'LastName';
        acc.PersonEmail= 'testAcc@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383000';
        insert acc;
        
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"email": "'+acc.PersonEmail + 
                          '","customerId": "'+acc.CIF__pc + 
                          '", "phone": "'+acc.Mobile_Country_Code__pc+acc.PersonMobilePhone+'"}';

    
    } */

    @isTest
    static void initiateManualOnboardingTest2() {
        Set<Id> setIdAcc = new Set<Id>();
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc1.LastName = 'LastName new';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        setIdAcc.add(acc1.id);
        
        List<Case> lstCreateCase=new List<Case>();
        Set<Id> setId = new Set<Id>();
        Case objCase = new Case();
        objCase.Subject = 'Technical failure to start Orchestration Layer';
        objCase.Description = 'A technical issue has occurred at an API level.';
        objCase.Type = 'Technical';
        objCase.Case_Model__c='ila';//CH01
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
        objCase.OwnerId = system.label.IT_Queue;
        objCase.Origin = 'OL';
        objCase.Case_Nature__c = 'RC';
        objCase.ContactId = acc1.PersonContactId;
        objCase.AccountId = acc1.id;
        lstCreateCase.add(objCase);
        
        Case objCaseEKYC = new Case();
        objCaseEKYC.Subject = 'eKYC Signoff';
        objCaseEKYC.Description = 'eKYC Signoff';
        objCaseEKYC.Type = 'eKYC';
        objCaseEKYC.Case_Model__c='ila';//CH01
        objCaseEKYC.Status = 'In Progress';
        objCaseEKYC.Priority = 'High';
        objCaseEKYC.Origin = 'EKYC-SIGNOFF';
        objCaseEKYC.Case_Nature__c = 'RC';

        objCaseEKYC.ContactId = acc1.PersonContactId;
        objCaseEKYC.AccountId = acc1.id;
        lstCreateCase.add(objCaseEKYC);

        //added
        Case objCaseEKYC1 = new Case();
        objCaseEKYC1.Subject = 'eKYC Signoff';
        objCaseEKYC1.Description = 'eKYC Signoff';
        objCaseEKYC1.Type = 'eKYC';
        objCaseEKYC1.Status = 'In Progress';
        objCaseEKYC1.Case_Model__c='ila';//CH01
        objCaseEKYC1.Priority = 'High';
        objCaseEKYC1.Origin = 'EKYC-UPLOAD';
        objCaseEKYC1.Case_Nature__c = 'RC';

        objCaseEKYC1.ContactId = acc1.PersonContactId;
        objCaseEKYC1.AccountId = acc1.id;
        lstCreateCase.add(objCaseEKYC1);

        Case objCaseEKYC2 = new Case();
        objCaseEKYC2.Subject = 'eKYC Signoff';
        objCaseEKYC2.Description = 'eKYC Signoff';
        objCaseEKYC2.Type = 'eKYC';
        objCaseEKYC2.Case_Model__c='ila';//CH01
        objCaseEKYC2.Status = 'In Progress';
        objCaseEKYC2.Priority = 'High';
        objCaseEKYC2.Origin = 'EKYC-FETCH';
        objCaseEKYC2.Case_Nature__c = 'RC';

        objCaseEKYC2.ContactId = acc1.PersonContactId;
        objCaseEKYC2.AccountId = acc1.id;
        lstCreateCase.add(objCaseEKYC2);
        
        insert lstCreateCase;
        setId.add(objCase.id);
        setId.add(objCaseEKYC.id);
        setId.add(objCaseEKYC1.id);
        setId.add(objCaseEKYC2.id);
        
        objCase.Status = 'Closed';
        objCase.Type = 'Technical';
        update objCase;
        
        objCaseEKYC.Status = 'Closed';
        update objCaseEKYC;
        
        initiateManualOnboarding.ManualOnboarding(setIdAcc);
        initiateManualOnboarding.continueManualOnboarding(setId);
        initiateManualOnboarding.reTriggerManualOnboarding(setId);
        initiateManualOnboarding.EKYCManualClosure(setId);
        initiateManualOnboarding.EKYCManualClosure(setId);
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"email": "'+objCase.Account.PersonEmail + 
                          '", "phone": "'+objCase.Account.Mobile_Country_Code__pc+objCase.Account.PersonMobilePhone+'"}';

    
    }
    
     @isTest
    static void stopJamiyahCase2() {
        Set<Id> setIdAcc = new Set<Id>();
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc1.LastName = 'LastName new';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        setIdAcc.add(acc1.id);
        
        List<Case> lstCreateCase=new List<Case>();
        Set<Id> setId1 = new Set<Id>();
        Set<Id> setId = new Set<Id>();
        Case objCase = new Case();
        objCase.Subject = 'Stop Jamiyah Account';
        objCase.Jamiyah_Id__c = 2134;
        objCase.Description = 'A technical issue has occurred at an API level.';
        objCase.Type = 'Stop Jamiyah';
        objCase.Case_Model__c='ila';//CH01
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
       // objCase.OwnerId = system.label.IT_Queue;
        objCase.Origin = 'CRM';
        objCase.Case_Nature__c = 'RC';
        objCase.Case_Nature__c = 'Credit Card';
        objCase.ContactId = acc1.PersonContactId;
        objCase.AccountId = acc1.id;
        lstCreateCase.add(objCase);
        
        Case objCaseEKYC = new Case();
        objCaseEKYC.Subject = 'eKYC Signoff';
        objCaseEKYC.Description = 'eKYC Signoff';
        objCaseEKYC.Type = 'eKYC';
        objCaseEKYC.Case_Model__c='ila';//CH01
        objCaseEKYC.Status = 'In Progress';
        objCaseEKYC.Priority = 'High';
        objCaseEKYC.Origin = 'EKYC-FETCH';
        objCaseEKYC.Case_Nature__c = 'RC';

        objCaseEKYC.ContactId = acc1.PersonContactId;
        objCaseEKYC.AccountId = acc1.id;
        lstCreateCase.add(objCaseEKYC);
        
        insert lstCreateCase;
        setId.add(objCase.id);
        setId1.add(objCaseEKYC.id);
        
        objCase.Status = 'Closed';
        //objCase.Type = 'Technical';
        update objCase;
        
        objCaseEKYC.Status = 'Closed';
        update objCaseEKYC;
        
        initiateManualOnboarding.ManualOnboarding(setIdAcc);
       // initiateManualOnboarding.continueManualOnboarding(setId1);
       // initiateManualOnboarding.reTriggerManualOnboarding(setId1);
        initiateManualOnboarding.EKYCManualClosure(setId1);
        initiateManualOnboarding.stopJamiyahCase(setId);
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"email": "'+objCase.Account.PersonEmail + 
                          '", "phone": "'+objCase.Account.Mobile_Country_Code__pc+objCase.Account.PersonMobilePhone+'"}';

    
    }
    
    
     @isTest
    static void initiateManualOnboardingTest3() {
        Set<Id> setIdAcc = new Set<Id>();
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc1.LastName = 'LastName new';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        setIdAcc.add(acc1.id);
        
        List<Case> lstCreateCase=new List<Case>();
        Set<Id> setId = new Set<Id>();
        Case objCase = new Case();
        objCase.Subject = 'Technical failure to start Orchestration Layer';
        objCase.Description = 'A technical issue has occurred at an API level.';
        objCase.Type = 'Technical';
        objCase.Case_Model__c='ila';//CH01
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
        objCase.OwnerId = system.label.IT_Queue;
        objCase.Origin = 'OL';
        objCase.ContactId = acc1.PersonContactId;
        objCase.AccountId = acc1.id;
        objCase.Case_Nature__c = 'FCR';
        lstCreateCase.add(objCase);
        insert lstCreateCase;
        setId.add(objCase.id);
        
        objCase.Status = 'Closed';
        objCase.Type = 'Technical';
        update objCase;
        
        initiateManualOnboarding.ManualOnboarding(setIdAcc);
        initiateManualOnboarding.continueManualOnboarding(setId);
        initiateManualOnboarding.reTriggerManualOnboarding(setId);
        
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"email": "'+objCase.Account.PersonEmail + 
                          '", "phone": "'+objCase.Account.Mobile_Country_Code__pc+objCase.Account.PersonMobilePhone+'"}';

    
    }
    @isTest
    static void initiateManualOnboardingTest4() {
        Test.startTest();
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc1.LastName = 'LastName new ';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        Case testCase1 = testCaseSet(acc1,'Manual Retry','EKYC-UPLOAD');
        Set<Id> caseIdSet1 = new Set<Id>();
        caseIdSet1.add(testCase1.Id);
        initiateManualOnboarding.EKYCManualRetry_IDCase(caseIdSet1);
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        
        final MyCalloutMock mock1 = new MyCalloutMock();
        mock1.testBody = bodyString(testCase1);
        
        /////////////////////////////////////////////////
        Case testCase2 = testCaseSet(acc1,'Convert to Identification Case','EKYC-UPLOAD');
        Set<Id> caseIdSet2 = new Set<Id>();
        caseIdSet2.add(testCase2.Id);
        initiateManualOnboarding.EKYCManualRetry_IDCase(caseIdSet2);
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        
        final MyCalloutMock mock2 = new MyCalloutMock();
        mock2.testBody = bodyString(testCase2);
        ///////////////////////////////////////////////////
        Case testCase3 = testCaseSet(acc1,'Manual Retry','EKYC-FETCH');
        Set<Id> caseIdSet3 = new Set<Id>();
        caseIdSet3.add(testCase3.Id);
        initiateManualOnboarding.EKYCManualRetry_IDCase(caseIdSet3);
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(testCase3);
        ///////////////////////////////////////////////////////////
        Case testCase4 = testCaseSet(acc1,'Convert to Identification Case','EKYC-FETCH');
        Set<Id> caseIdSet4 = new Set<Id>();
        caseIdSet4.add(testCase4.Id);
        initiateManualOnboarding.EKYCManualRetry_IDCase(caseIdSet4);
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        
        final MyCalloutMock mock4 = new MyCalloutMock();
        mock3.testBody = bodyString(testCase4);
        ////////////////////////////////////////////////////////////
        Case testCase5 = testCaseSet(acc1,'Convert to Identification Case','EKYC-SIGNOFF');
        Set<Id> caseIdSet5 = new Set<Id>();
        caseIdSet5.add(testCase5.Id);
        initiateManualOnboarding.EKYCManualRetry_IDCase(caseIdSet5);
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        
        final MyCalloutMock mock5 = new MyCalloutMock();
        mock5.testBody = bodyString(testCase5);
        test.stopTest();
    }

    @isTest
    static void initiateManualOnboardingTest8(){
        test.startTest();
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc1.LastName = 'LastName new ';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        Case caseObj1 = testCaseSet1(acc1,'In-Progress',NULL,NULL,NULL,NULL,'ABC');
        Set<Id> caseIdSet1 = new Set<Id>();
        caseIdSet1.add(caseObj1.Id);
        initiateManualOnboarding.CCCaseCreation(caseIdSet1);
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = bodyString(caseObj1);
        ////////////////////////////////////////////////////
        Case caseObj1a = testCaseSet1(acc1,'In-Progress',NULL,NULL,NULL,NULL,NULL);
        Set<Id> caseIdSet1a = new Set<Id>();
        caseIdSet1a.add(caseObj1a.Id);
        initiateManualOnboarding.CCCaseCreation(caseIdSet1a);
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        
        final MyCalloutMock mock1a = new MyCalloutMock();
        mock1a.testBody = bodyString(caseObj1a);
        ////////////////////////////////////////////////////
        Case caseObj2 = testCaseSet1(acc1,'Pending',NULL,NULL,NULL,NULL,'ABC');
        Set<Id> caseIdSet2 = new Set<Id>();
        caseIdSet2.add(caseObj2.Id);
        initiateManualOnboarding.CCCaseCreation(caseIdSet2);
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        
        final MyCalloutMock mock2 = new MyCalloutMock();
        mock2.testBody = bodyString(caseObj2);
        /////////////////////////////////////////////
        Case caseObj2a = testCaseSet1(acc1,'Pending',NULL,NULL,NULL,NULL,NULL);
        Set<Id> caseIdSet2a = new Set<Id>();
        caseIdSet2.add(caseObj2a.Id);
        initiateManualOnboarding.CCCaseCreation(caseIdSet2a);
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        
        final MyCalloutMock mock2a = new MyCalloutMock();
        mock2a.testBody = bodyString(caseObj2a);
        /////////////////////////////////////////////
        //objCase.Sub_Status__c == 'Discrepancies'
        Case caseObj3 = testCaseSet1(acc1,'Discrepancies',NULL,NULL,NULL,NULL,'ABC');
        Set<Id> caseIdSet3 = new Set<Id>();
        caseIdSet1.add(caseObj3.Id);
        initiateManualOnboarding.CCCaseCreation(caseIdSet3);
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(caseObj3);
        test.stopTest();
    }
    public static Case testCaseSet1(Account acc1, String subStatus, String approvalResult, String evaluationResult, String Businessapproval, String creditVerification, String nameOnTheCard){
         Case objCase = new Case();
        objCase.Subject = 'Technical failure to start Orchestration Layer';
        objCase.Description = 'A technical issue has occurred at an API level.';
        objCase.Type = 'Technical';
        objCase.Case_Model__c='ila';//CH01
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
        objCase.OwnerId = system.label.IT_Queue;
        objCase.Origin = 'Phone';
        objCase.ContactId = acc1.PersonContactId;
        objCase.AccountId = acc1.id;
        objCase.cc_HR_Result__c =NULL;
        objCase.Sub_Status__c = subStatus ;
        objCase.cc_Credit_Approval_Result__c = approvalResult;
        objCase.cc_Credit_Evaluation_Result__c = evaluationResult;
        objCase.cc_Business_Approval_Result__c = Businessapproval;
        objCase.cc_Credit_Verification_Result__c = creditVerification;
        objCase.cc_Name_on_the_Card__c =nameOnTheCard;
        objCase.cc_CPR_Expiry_Date__c = system.today() +365;
        objCase.cc_CPR_Number__c = '237623823229323';
        insert objCase;
        return objCase;
    }
    public static Case testCaseSet(Account acc1 ,String eKYC_Decision, String  Origin){
        Case objCase = new Case();
        objCase.Subject = 'Technical failure to start Orchestration Layer';
        objCase.Description = 'A technical issue has occurred at an API level.';
        objCase.Type = 'Technical';
        objCase.Case_Model__c='ila';//CH01
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
        objCase.OwnerId = system.label.IT_Queue;
        objCase.Origin = Origin;
        objCase.ContactId = acc1.PersonContactId;
        objCase.AccountId = acc1.id;
        objCase.eKYC_Decision__c = eKYC_Decision;
        objCase.Case_Nature__c = 'RC';
             
        insert objCase;
      
        return  objCase;
    }
    @isTest
    static void initiateManualOnboardingTest6(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Case').getRecordTypeId();
         Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc1.LastName = 'LastName new ';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        Case objCase = new Case();
        objCase.Subject = 'eKYC Signoff';
        objCase.Description = 'eKYC Signoff.';
        objCase.Type = 'Technical';
        objCase.Case_Model__c='ila';//CH01
        objCase.Case_Nature__c='RC';
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
        objCase.OwnerId = system.label.IT_Queue;
        objCase.Origin = 'Phone';
        objCase.ContactId = acc1.PersonContactId;
        objCase.AccountId = acc1.id;
        objCase.RecordTypeId = recordTypeId;
        insert objCase;
        Set<Id> accIds = new Set<Id>();
        accIds.add(acc1.id);
        
        
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = bodyString(objCase);
        initiateManualOnboarding.eKYCSignCaseClosure(accIds);
    }
    
    @isTest
    static void initiateManualOnboardingTest7(){
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc1.LastName = 'LastName new ';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        Case objCase = new Case();
        objCase.Subject = 'eKYC Signoff';
        objCase.Description = 'eKYC Signoff.';
        objCase.Type = 'Technical';
        objCase.Case_Model__c='ila';//CH01
        objCase.Case_Nature__c = 'RC';
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
        objCase.OwnerId = system.label.IT_Queue;
        objCase.Origin = 'Phone';
        objCase.ContactId = acc1.PersonContactId;
        objCase.AccountId = acc1.id;
        insert objCase;
        
        HttpRequest request = new HttpRequest();
        //initiateManualOnboarding.getFCRresponse(request,true,objCase.Id,'12345','Unfreeze Card');
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = bodyString(objCase);
    }
    
    //Added by Jahangeer Mohammed
     @isTest
    static void initiateManualOnboardingTest9(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        insert acc;
        System.debug('Account Personel Email:'+acc.PersonEmail);
        System.debug('Account Personel CIF:'+acc.CIF__pc);
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
         cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.Priority = 'High';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Credit_Pre_Screening_Result__c = 'Discrepancy in Documents';
        
        test.startTest();
        insert cs1;
        
        cs1.cc_Credit_Pre_Screening_Result__c = 'Discrepancy in Documents';
        cs1.Sub_Status__c = 'Discrepancies';
        update cs1;
        Set<Id> setIds = new Set<Id>();
        setIds.add(cs1.id);
        initiateManualOnboarding.CCCaseActivateReminders(setIds);
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void initiateManualOnboardingTest10(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
       
        test.startTest();
        insert cs1;
        //cs1.cc_Credit_Pre_Screening_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        update cs1;
        
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void initiateManualOnboardingTest11(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
       
        test.startTest();
        insert cs1;
        //cs1.cc_Credit_Pre_Screening_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        update cs1;
        
        cs1.cc_Service_Centre_Result__c = 'Return to Pre-Screener';
        cs1.cc_Application_Stages__c = 'Credit Service Centre';
        update cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void initiateManualOnboardingTest12(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
       
        test.startTest();
        insert cs1;
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_Credit_Bureau_Score__c = 70;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        update cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void initiateManualOnboardingTest13(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        insert cs1;
        test.startTest();
        //insert cs1;
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_Credit_Bureau_Score__c = 70;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;

        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c = 500;
        cs1.cc_Final_DBR__c = 70;
        update cs1;
       
        cs1.cc_Credit_Verification_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void initiateManualOnboardingTest14(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        insert cs1;
        test.startTest();
        //insert cs1;
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_Credit_Bureau_Score__c = 70;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;

        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c = 500;
        cs1.cc_Final_DBR__c = 70;
        update cs1;

        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
        
        //cs1.cc_Credit_Approval_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void initiateManualOnboardingTest15(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        insert cs1;
        test.startTest();
        //insert cs1;
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_Credit_Bureau_Score__c = 70;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;
		
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c = 500;
        cs1.cc_Final_DBR__c = 70;
        update cs1;

        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
       	User u = [Select Id from user where lastName='Integration' limit 1];
        System.runas(u){
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        }
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void initiateManualOnboardingTest16(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        //cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        insert cs1;
        test.startTest();
        //insert cs1;
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_Credit_Bureau_Score__c = 70;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;

        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c = 500;
        cs1.cc_Final_DBR__c = 70;
        cs1.cc_Approved_Name_on_the_card__c = 'TESTCARD';
        update cs1;
        
        
        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
        User u = [Select Id from user where lastName='Integration' limit 1];
        System.runas(u){
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        }
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void initiateManualOnboardingTest17(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        insert cs1;
        test.startTest();
        //insert cs1;
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_Credit_Bureau_Score__c = 70;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c = 500;
        cs1.cc_Final_DBR__c = 70;
        cs1.cc_Approved_Name_on_the_card__c = 'TESTCARD';
        update cs1;
        
        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
        User u = [Select Id from user where lastName='Integration' limit 1];
        System.runas(u){
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        }
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void initiateManualOnboardingTest18(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        insert cs1;
        test.startTest();
        //insert cs1;
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_Credit_Bureau_Score__c = 70;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c = 500;
        cs1.cc_Final_DBR__c = 70;
        cs1.cc_Approved_Name_on_the_card__c = 'TESTCARD';
        update cs1;
        
        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
        User u = [Select Id from user where lastName='Integration' limit 1];
        System.runas(u){
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        }
        
        cs1.cc_Signature_Verifier_Result__c = 'Re-Send';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void initiateManualOnboardingTest19(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        insert cs1;
        test.startTest();
        //insert cs1;
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_Credit_Bureau_Score__c = 70;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c = 500;
        cs1.cc_Final_DBR__c = 70;
        cs1.cc_Approved_Name_on_the_card__c = 'TESTCARD';
        update cs1;
        
        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
        
        User u = [Select Id from user where lastName='Integration' limit 1];
        System.runas(u){
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        }
        
        cs1.cc_Signature_Verifier_Result__c = 'Refer To Service Center';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void initiateManualOnboardingTest20(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        insert cs1;
        test.startTest();
        //insert cs1;
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_Credit_Bureau_Score__c = 70;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c = 500;
        cs1.cc_Final_DBR__c = 70;
        cs1.cc_Approved_Name_on_the_card__c = 'TESTCARD';
        update cs1;
        
        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
        
      	User u = [Select Id from user where lastName='Integration' limit 1];
        System.runas(u){
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        }
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        cs1.cc_Operations_Result__c = 'Balance Transfer Processed';
        cs1.cc_Balance_Transfer_Reference_Number__c = '546454';
        cs1.cc_Application_Stages__c = 'Credit Buyout';
        update cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void initiateManualOnboardingTest21(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Type__c = 'Buy Out';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        insert cs1;
        test.startTest();
        //insert cs1;
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_Credit_Bureau_Score__c = 70;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c = 500;
        cs1.cc_Final_DBR__c = 70;
        cs1.cc_Approved_Name_on_the_card__c = 'TESTCARD';
        update cs1;
        
        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
        
        User u = [Select Id from user where lastName='Integration' limit 1];
        System.runas(u){
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        }
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        cs1.cc_Operations_Result__c = 'Balance Transfer Processed';
        cs1.cc_Balance_Transfer_Reference_Number__c = '546454';
        cs1.cc_Application_Stages__c = 'Credit Buyout';
        update cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void initiateManualOnboardingTest22(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Type__c = 'Buy Out';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        insert cs1;
        test.startTest();
        //insert cs1;
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_Credit_Bureau_Score__c = 70;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c = 500;
        cs1.cc_Final_DBR__c = 70;
        cs1.cc_Approved_Name_on_the_card__c = 'TESTCARD';
        update cs1;
        
        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
        
        User u = [Select Id from user where lastName='Integration' limit 1];
        System.runas(u){
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        }
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        cs1.cc_Operations_Result__c = 'Balance Transfer Processed';
        cs1.cc_Balance_Transfer_Reference_Number__c = '546454';
        cs1.cc_Application_Stages__c = 'Credit Buyout';
        update cs1;
        
        cs1.cc_Service_Centre_Result__c = 'Release Letter Received';
        cs1.cc_Application_Stages__c = 'Credit Service Centre';
        update cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
      @isTest
    static void initiateManualOnboardingTest23(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        insert cs1;
        test.startTest();
        //insert cs1;
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_Credit_Bureau_Score__c = 70;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c = 500;
        cs1.cc_Final_DBR__c = 70;
        cs1.cc_Approved_Name_on_the_card__c = 'TESTCARD';
        update cs1;
        
        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
        
        User u = [Select Id from user where lastName='Integration' limit 1];
        System.runas(u){
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        }
        
        cs1.cc_Signature_Verifier_Result__c = 'Re-Send';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        cs1.cc_Service_Centre_Result__c = 'Return to Signature Verifier';
        cs1.cc_Application_Stages__c = 'Credit Service Centre';
        update cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void initiateManualOnboardingTest24(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        insert acc;
        System.debug('Account Personel Email:'+acc.PersonEmail);
        System.debug('Account Personel CIF:'+acc.CIF__pc);
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        //cs1.cc_Credit_Pre_Screening_Result__c = 'Discrepancy in Documents';
        
        test.startTest();
        insert cs1;
        
        //cs1.cc_Credit_Pre_Screening_Result__c = 'Discrepancy in Documents';
        //cs1.Sub_Status__c = 'Discrepancies';
        cs1.Is_Doc_Dicrepancy__c = true;
        cs1.Status = 'All Documents Uploaded';
        update cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void initiateManualOnboardingTest25(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card - Staff  Application').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        acc.Segment__pc = 'Staff';
        insert acc;
        System.debug('Account Personel Email:'+acc.PersonEmail);
        System.debug('Account Personel CIF:'+acc.CIF__pc);
        System.debug('Segment of Customer:'+acc.Segment__pc);
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Sub_Type__c = 'New Credit Card';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
       
        
        test.startTest();
        insert cs1;
        //cs1.cc_Approved_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        //cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c  = 500;
        cs1.cc_HR_Result__c = 'Approved';
        update cs1;
        
        System.debug('---->HR Result:'+cs1.cc_HR_Result__c );
        System.debug('---->HR Result Record Type:'+cs1.RecordTypeId);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void initiateManualOnboardingTest26(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card - Staff  Application').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        acc.Segment__pc = 'Staff';
        insert acc;
        System.debug('Account Personel Email:'+acc.PersonEmail);
        System.debug('Account Personel CIF:'+acc.CIF__pc);
        System.debug('Segment of Customer:'+acc.Segment__pc);
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Sub_Type__c = 'New Credit Card';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        //cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        
        test.startTest();
        insert cs1;
        //cs1.cc_Approved_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        //cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c  = 500;
        cs1.cc_HR_Result__c = 'Approved';
        update cs1;
        
        System.debug('---->HR Result:'+cs1.cc_HR_Result__c );
        System.debug('---->HR Result Record Type:'+cs1.RecordTypeId);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void initiateManualOnboardingTest27(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card - Staff  Application').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        acc.Segment__pc = 'Staff';
        insert acc;
        System.debug('Account Personel Email:'+acc.PersonEmail);
        System.debug('Account Personel CIF:'+acc.CIF__pc);
        System.debug('Segment of Customer:'+acc.Segment__pc);
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Sub_Type__c = 'New Credit Card';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
       
        
        test.startTest();
        insert cs1;
        //cs1.cc_Approved_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        //cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c  = 500;
        cs1.cc_HR_Result__c = 'Approved';
        update cs1;
        
        cs1.cc_HR_Result__c = 'Accept Release Letter';
        update cs1;
        
        System.debug('---->HR Result:'+cs1.cc_HR_Result__c );
        System.debug('---->HR Result Record Type:'+cs1.RecordTypeId);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void initiateManualOnboardingTest28(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card - Staff  Application').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        acc.Segment__pc = 'Staff';
        insert acc;
        System.debug('Account Personel Email:'+acc.PersonEmail);
        System.debug('Account Personel CIF:'+acc.CIF__pc);
        System.debug('Segment of Customer:'+acc.Segment__pc);
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Sub_Type__c = 'New Credit Card';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        //cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
       
        
        test.startTest();
        insert cs1;
        //cs1.cc_Approved_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        //cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c  = 500;
        cs1.cc_HR_Result__c = 'Decline';
        update cs1;
        
        System.debug('---->HR Result:'+cs1.cc_HR_Result__c );
        System.debug('---->HR Result Record Type:'+cs1.RecordTypeId);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void initiateManualOnboardingTest29(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
       
        test.startTest();
        insert cs1;
        //cs1.cc_Credit_Pre_Screening_Result__c = 'Refer to service center';
        //cs1.cc_Pre_screener_Decline_Reason__c = 'Blacklisted Customer';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        update cs1;
        
        cs1.cc_Service_Centre_Result__c = 'Return to Pre-Screener';
        cs1.cc_Application_Stages__c = 'Credit Service Centre';
        update cs1;
        
        /*cs1.cc_Credit_Pre_Screening_Result__c = 'Decline';
        cs1.cc_Pre_screener_Decline_Reason__c = 'Below Minimum Score';
        update cs1;*/
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
      @isTest
    static void initiateManualOnboardingTest30(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
       
        test.startTest();
        insert cs1;
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_Credit_Bureau_Score__c = 70;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Decline';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        update cs1;
        
       
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void initiateManualOnboardingTest31(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        insert cs1;
        test.startTest();
        //insert cs1;
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.cc_Credit_Bureau_Score__c = 70;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c = 500;
        cs1.cc_Final_DBR__c = 70;
        update cs1;
        
        cs1.cc_Credit_Verification_Result__c = 'Decline';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void initiateManualOnboardingTest32(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        insert cs1;
        test.startTest();
        //insert cs1;
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.cc_Credit_Bureau_Score__c = 70;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c = 500;
        cs1.cc_Final_DBR__c = 70;
        update cs1;
        
        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
        
        //cs1.cc_Credit_Approval_Result__c = 'Decline';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void initiateManualOnboardingTest33(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
       
        test.startTest();
        insert cs1;
        //cs1.cc_Credit_Pre_Screening_Result__c = 'Refer to service center';
        //cs1.cc_Pre_screener_Decline_Reason__c = 'Blacklisted Customer';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        update cs1;
        
        cs1.cc_Service_Centre_Result__c = 'Return to Pre-Screener';
        cs1.cc_Application_Stages__c = 'Credit Service Centre';
        update cs1;
        
        //cs1.cc_Credit_Pre_Screening_Result__c = 'Expired';
        //cs1.cc_Pre_screener_Decline_Reason__c = 'Blacklisted Customer';
        //update cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
      @isTest
    static void initiateManualOnboardingTest34() {
        Set<Id> setIdAcc = new Set<Id>();
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc1.LastName = 'LastName new';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        setIdAcc.add(acc1.id);
        
        List<Case> lstCreateCase=new List<Case>();
        Set<Id> setId1 = new Set<Id>();
        Set<Id> setId = new Set<Id>();
        Case objCase = new Case();
        objCase.Subject = 'Stop Jamiyah Account';
        objCase.Jamiyah_Id__c = 2134;
        objCase.Description = 'A technical issue has occurred at an API level.';
        objCase.Type = 'Stop Jamiyah';
        objCase.Case_Model__c='ila';//CH01
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
       // objCase.OwnerId = system.label.IT_Queue;
        objCase.Origin = 'CRM';
        objCase.Case_Nature__c = 'Credit Card';

        objCase.ContactId = acc1.PersonContactId;
        objCase.AccountId = acc1.id;
        lstCreateCase.add(objCase);
        
        Case objCaseEKYC = new Case();
        objCaseEKYC.Subject = 'eKYC Signoff';
        objCaseEKYC.Description = 'eKYC Signoff';
        objCaseEKYC.Type = 'eKYC';
        objCaseEKYC.Case_Model__c='ila';//CH01
        objCaseEKYC.Status = 'In Progress';
        objCaseEKYC.Priority = 'High';
        objCaseEKYC.Origin = 'EKYC-UPLOAD';
        objCaseEKYC.Case_Nature__c = 'RC';
        objCaseEKYC.ContactId = acc1.PersonContactId;
        objCaseEKYC.AccountId = acc1.id;
        lstCreateCase.add(objCaseEKYC);
        
        insert lstCreateCase;
        setId.add(objCase.id);
        setId1.add(objCaseEKYC.id);
        
        objCase.Status = 'Closed';
        //objCase.Type = 'Technical';
        update objCase;
        
        objCaseEKYC.Status = 'Closed';
        update objCaseEKYC;
        
        initiateManualOnboarding.ManualOnboarding(setIdAcc);
       // initiateManualOnboarding.continueManualOnboarding(setId1);
       // initiateManualOnboarding.reTriggerManualOnboarding(setId1);
        initiateManualOnboarding.EKYCManualClosure(setId1);
        initiateManualOnboarding.stopJamiyahCase(setId);
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"email": "'+objCase.Account.PersonEmail + 
                          '", "phone": "'+objCase.Account.Mobile_Country_Code__pc+objCase.Account.PersonMobilePhone+'"}';

    
    }
     @isTest
    static void initiateManualOnboardingTest35() {
        Set<Id> setIdAcc = new Set<Id>();
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc1.LastName = 'LastName new';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        setIdAcc.add(acc1.id);
        
        List<Case> lstCreateCase=new List<Case>();
       
        Case objCase = new Case();
        objCase.Subject = 'Stop Jamiyah Account';
        objCase.Jamiyah_Id__c = 2134;
        objCase.Description = 'A technical issue has occurred at an API level.';
        objCase.Type = 'Stop Jamiyah';
        objCase.Case_Model__c='ila';//CH01
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
        objCase.Currency__c = 'BHD';
        objCase.Case_Nature__c = 'RC';
       // objCase.OwnerId = system.label.IT_Queue;
        objCase.Origin = 'CRM';
        objCase.ContactId = acc1.PersonContactId;
        objCase.AccountId = acc1.id;
        lstCreateCase.add(objCase);
        
        Case objCaseEKYC = new Case();
        objCaseEKYC.Subject = 'eKYC Signoff';
        objCaseEKYC.Description = 'eKYC Signoff';
        objCaseEKYC.Type = 'eKYC';
        objCaseEKYC.Status = 'In Progress';
        objCaseEKYC.Priority = 'High';
        objCaseEKYC.Origin = 'EKYC-UPLOAD';
        objCaseEKYC.ContactId = acc1.PersonContactId;
        objCaseEKYC.AccountId = acc1.id;
        lstCreateCase.add(objCaseEKYC);
        
        insert lstCreateCase;
        Set<Id> setIds = new Set<Id>();
        setIds.add(objCase.Id);
        initiateManualOnboarding.secondBHDAccountRequest(setIds);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"currency": {"code":"'+objCase.Currency__c+'","decimalPlaces": "3"},"templateId": "CA",'+ 
                            '"alias":"'+objCase.Alias_account__c+'",'+    
                            '"earnInterest":"'+objCase.Interest_Option__c+'"}';  

    
    }
    
    //added
    @isTest
    static void initiateManualOnboardingTest50(){
        test.startTest();
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc1.LastName = 'LastName new ';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        Case caseObj1 = testCaseSet1(acc1,'In-Progress',NULL,NULL,NULL,NULL,'ABC');
        Set<Id> caseIdSet1 = new Set<Id>();
        caseIdSet1.add(caseObj1.Id);
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        initiateManualOnboarding.CCCaseCreation(caseIdSet1);
        test.stopTest();
    }
    
    @isTest
    static void initiateManualOnboardingTest51(){
        test.startTest();
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc1.LastName = 'LastName new ';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        Case caseObj1 = testCaseSet10(acc1,'Pending','Return to Verifier','Accept',NULL,'Approve','ABC');
        caseObj1.Type = 'Credit Card Application';
        caseObj1.Case_Nature__c = 'RC';
        caseObj1.cc_CPR_Expiry_Date__c = system.today() +365;
        caseObj1.cc_CPR_Number__c = '237623823229323';
        caseObj1.Sub_Type__c = 'New Credit Card';
        caseObj1.Case_Model__c='ila';//CH01
        caseObj1.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        insert caseObj1;
        Set<Id> caseIdSet1 = new Set<Id>();
        caseIdSet1.add(caseObj1.Id);
        initiateManualOnboarding.CCCaseUpdate(caseIdSet1);
        
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = bodyString(caseObj1);
    
        test.stopTest();
    }

    @isTest
    static void initiateManualOnboardingTest52(){
        test.startTest();
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc1.LastName = 'LastName new ';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        Case caseObj1 = testCaseSet10(acc1,'Pending','Return to Verifier','Accept',NULL,'Approve','ABC');
        caseObj1.Type = 'Credit Card Application';
        caseObj1.Sub_Type__c = 'New Credit Card';
        caseObj1.Case_Model__c='ila';//CH01
        caseObj1.Sub_Status__c = 'Release Letter Received';
        caseObj1.Case_Nature__c = 'RC';
        caseObj1.cc_CPR_Expiry_Date__c = system.today() +365;
        caseObj1.cc_CPR_Number__c = '237623823229323';
        //caseObj1.cc_Credit_Pre_Screening_Result__c = 'Refer to Service Center';
        caseObj1.cc_Operations_Result__c = 'Balance Transfer Processed';
        caseObj1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        caseObj1.cc_Approved_Transfer_Type__c = 'Buy Out';
        caseObj1.cc_Approved_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        caseObj1.cc_Balance_Transfer_Amount__c = 100.00;
        caseObj1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        caseObj1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        caseObj1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        caseObj1.Priority = 'High';
        caseObj1.cc_CPR_Expiry_Date__c = system.today() +365;
        caseObj1.cc_CPR_Number__c = '237623823229323';
        caseObj1.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        insert caseObj1;
        Set<Id> caseIdSet1 = new Set<Id>();
        caseIdSet1.add(caseObj1.Id);
        initiateManualOnboarding.CCCaseUpdate(caseIdSet1);
        
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = bodyString(caseObj1);
    
        test.stopTest();
    }

    @isTest
    static void initiateManualOnboardingTest53(){
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc1.LastName = 'LastName new ';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        Case objCase = new Case();
        objCase.Subject = 'eKYC Signoff';
        objCase.Description = 'eKYC Signoff.';
        objCase.Type = 'Technical';
        objCase.Case_Model__c='ila';//CH01
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
        objCase.OwnerId = system.label.IT_Queue;
        objCase.Origin = 'Phone';
        objCase.ContactId = acc1.PersonContactId;
        objCase.AccountId = acc1.id;
        objCase.Case_Nature__c = 'RC';
        objCase.cc_Email_Sent_Flag__c = true;
        objCase.cc_signature_sms_sent_flag__c = true;
        insert objCase;
        
        HttpRequest request = new HttpRequest();
        initiateManualOnboarding.sendSMSReminder(new Set<Id>{objCase.Id});
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = bodyString(objCase);
    }

    public static Case testCaseSet10(Account acc1, String subStatus, String approvalResult, String evaluationResult, String Businessapproval, String creditVerification, String nameOnTheCard){
        Case objCase = new Case();
       objCase.Subject = 'Technical failure to start Orchestration Layer';
       objCase.Description = 'A technical issue has occurred at an API level.';
       objCase.Type = 'Technical';
       objCase.Status = 'In Progress';
       objCase.Priority = 'High';
       objCase.OwnerId = system.label.IT_Queue;
       objCase.Origin = 'Phone';
       objCase.ContactId = acc1.PersonContactId;
       objCase.AccountId = acc1.id;
       objCase.cc_HR_Result__c =NULL;
       objCase.Sub_Status__c = subStatus ;
       objCase.Case_Nature__c = 'RC';
       objCase.cc_CPR_Expiry_Date__c = system.today() +365;
       objCase.cc_CPR_Number__c = '237623823229323';
       objCase.cc_Credit_Approval_Result__c = approvalResult;
       objCase.cc_Credit_Evaluation_Result__c = evaluationResult;
       objCase.cc_Business_Approval_Result__c = Businessapproval;
       objCase.cc_Credit_Verification_Result__c = creditVerification;
       objCase.cc_Name_on_the_Card__c =nameOnTheCard;
       return objCase;
   }
    //END
    public static String bodyString(Case objCase){
        String body;
        if(objCase.Origin == 'EKYC-UPLOAD' && objCase.eKYC_Decision__c == 'Manual Retry'){
        body = '{"caseId": "'+objCase.Id + 
                          '","email": "'+objCase.Account.PersonEmail + 
                          '","caseType": "'+objCase.Type + 
                          '","caseStatus": "ContinueUpload"}';
        }
        else if(objCase.Origin == 'EKYC-UPLOAD' && objCase.eKYC_Decision__c == 'Convert to Identification Case'){
          body =  '{"caseId": "'+objCase.Id + 
                          '","email": "'+objCase.Account.PersonEmail + 
                          '","caseType": "'+objCase.Type + 
                          '","caseStatus": "FailedUpload"}';
        }
        else if(objCase.Origin == 'EKYC-FETCH' && objCase.eKYC_Decision__c == 'Manual Retry'){
            body = '{"caseId": "'+objCase.Id + 
                          '","email": "'+objCase.Account.PersonEmail + 
                          '","caseType": "'+objCase.Type + 
                          '","caseStatus": "ContinueFetch"}';
        }
        else if(objCase.Origin == 'EKYC-FETCH' && objCase.eKYC_Decision__c == 'Convert to Identification Case'){
            body = '{"caseId": "'+objCase.Id + 
                          '","email": "'+objCase.Account.PersonEmail + 
                          '","caseType": "'+objCase.Type + 
                          '","caseStatus": "FailedFetch"}';
        }
        else if(objCase.Origin == 'EKYC-SIGNOFF'){
            body = '{"caseId": "'+objCase.Id + 
                          '","email": "'+objCase.Account.PersonEmail + 
                          '","caseType": "'+objCase.Type + 
                          '","caseStatus": "ContinueSignOff"}';
        }
        else if(objCase.Origin == 'EKYC-SIGNOFF'){
            body = '{"caseId": "'+objCase.Id + 
                          '","email": "'+objCase.Account.PersonEmail + 
                          '","caseType": "'+objCase.Type + 
                          '","caseStatus": "ContinueSignOff"}';
        }
        else if(objCase.Sub_Status__c == 'In-Progress' && objCase.cc_Name_on_the_Card__c != NULL){
            body = '{"crmCaseId": "'+objCase.Id +                             
                                '","status":"IN_PROGRESS"}';
        }
        else if(objCase.Sub_Status__c == 'In-Progress' && objCase.cc_Name_on_the_Card__c == NULL){
            body = '{"crmCaseId": "'+objCase.Id +
                                '","embossName": "'+null +
                                ',"status":"IN_PROGRESS"}';
        }
        else if(objCase.Sub_Status__c == 'Pending' && objCase.cc_Name_on_the_Card__c == NULL){
            body = '{"crmCaseId": "'+objCase.Id +
                                '","embossName": "'+null +
                                ',"status":"PENDING"}';
        }
        else if(objCase.Sub_Status__c == 'Pending' && objCase.cc_Name_on_the_Card__c != NULL){
            body = '{"crmCaseId": "'+objCase.Id +
                                '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                                '","status":"PENDING"}';
        }
        else if(objCase.Sub_Status__c == 'Documents Received' && objCase.cc_Name_on_the_Card__c != NULL){
            body = '{"crmCaseId": "'+objCase.Id +
                                '","status":"IN_PROGRESS"}';
        }
        else if(objCase.Sub_Status__c == 'Documents Received' && objCase.cc_Name_on_the_Card__c != NULL){
            body = '{"crmCaseId": "'+objCase.Id +
                                '","status":"IN_PROGRESS"}';
        }
        else if(objCase.Subject == 'eKYC Signoff'){
        body = '{"mockURL":null}';
        }
        //Added by Jahangeer Mohammed
        else if(objCase.Sub_Status__c == 'Discrepancies' && objCase.cc_Name_on_the_Card__c != NULL){
              body = '{"crmCaseId": "'+objCase.Id +
                                '","status":"DISCREPANCIES"}';
         }
        else if(objCase.Sub_Status__c == 'Referred  by Pre-Screener' && objCase.cc_Name_on_the_Card__c != NULL){
              body = '{"crmCaseId": "'+objCase.Id +
                                    '","status":"REFERRED_BY_PRESCREENER"}';
         }
        else if(objCase.Sub_Status__c == 'Referred by Evaluator' && objCase.cc_Name_on_the_Card__c != NULL){
              body = '{"crmCaseId": "'+objCase.Id +
                                    '","status":"REFERRED_BY_EVALUATOR"}';
         }
         else if(objCase.Sub_Status__c == 'Referred by Verifier' && objCase.cc_Name_on_the_Card__c != NULL){
              body = '{"crmCaseId": "'+objCase.Id +
                                    '","status":"REFERRED_BY_VERIFIER"}';
         }
        else if(objCase.Sub_Status__c == 'Referred by Approver' && objCase.cc_Name_on_the_Card__c != NULL){
                    body = '{"crmCaseId": "'+objCase.Id +
                                    '","status":"REFERRED_BY_APPROVER"}';
                }
        else if(objCase.Sub_Status__c == 'Pending Signature Verification' && objCase.cc_Name_on_the_Card__c != NULL){
             body = '{"crmCaseId": "'+objCase.Id +
                                    '","status":"APPROVED_PENDING_SIGNATURE"}';
         }
        else if(objCase.Sub_Status__c == 'Approved' && objCase.cc_Name_on_the_Card__c != NULL){
              body = '{"cardProductConfigurationId": "'+665756 +
                            '","crmCaseId": "'+objCase.Id +
                            '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                            '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                            '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                            '","status":"APPROVED"}';
         }
        else if(objCase.Sub_Status__c == 'Pending Balance Transfer' && objCase.cc_Name_on_the_Card__c != NULL){
            body = '{"cardProductConfigurationId": "'+665756 +
                            '","crmCaseId": "'+objCase.Id +
                            '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                            '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                            '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                            '","status":"APPROVED_PENDING_BT_PROCESSING"}';
         }
         else if(objCase.Sub_Status__c == 'Referred by Signature Verifier'  && objCase.cc_Name_on_the_Card__c != NULL ){
             body = '{"crmCaseId": "'+objCase.Id +
                                '","status":"REFERRED_BY_SIGNATURE_VERIFIER"}';
         }
        else if(objCase.cc_Operations_Result__c == 'Balance Transfer Processed' && objCase.cc_Name_on_the_Card__c != NULL ){
            body = '{"crmCaseId": "'+objCase.Id +
                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                '","status":"APPROVED"}';
        }
        else if(objCase.Sub_Status__c == 'Pending Release Letter' && objCase.cc_Name_on_the_Card__c != NULL){
             body = '{"crmCaseId": "'+objCase.Id +
                                    '","status":"APPROVED_PENDING_BT_LETTER"}';
         }
         else if(objCase.Sub_Status__c == 'Release Letter Received' && objCase.cc_Name_on_the_Card__c != NULL){
             body = '{"crmCaseId": "'+objCase.Id +
                                    '","status":"APPROVED_PENDING_BT_LETTER_RECEIVED"}';
         }
         else if(objCase.Sub_Status__c == 'Declined' && objCase.cc_Name_on_the_Card__c != NULL){
             body = '{"crmCaseId": "'+objCase.Id +
                                    '","status":"DECLINED"}';
         }
        return body;
        
        //END
    }

    //************************************ */
    //CH02: Conmmented by Jahangeer Mohammed 12-06-2023 due to Restricted Picklist value removed the value cc_Maker__c = 'Send to Pre-Screener'
    @isTest
    static void initiateManualOnboardingTest54(){
        Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId() ;
        Id suppRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card_Supplementary').getRecordTypeId() ;
        Account accObj = (Account)TestDataFactory.createSObject(new Account(RecordTypeId = customerRecordtypeId ),'TestFactoryDefaults.AccountDefaults',true);
        Case objCase = (Case)TestDataFactory.createSObject(new Case(sc_Card_Holder_ID_Number__c = '123', cc_Name_on_the_Card__c='test name',RecordTypeId=suppRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',cc_Credit_Approval_Result__c ='Approve',
                                                    Type = 'Credit Card Supplementary Application',Sub_Type__c = 'New Supplementary Card',cc_Credit_Pre_Screening_Result__c = 'Accept'/*,cc_Maker__c = 'Send to Pre-Screener'*/),
                                                    'TestFactoryDefaults.CaseDefaults',true);    
                                    
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            Test.setMock(HttpCalloutMock.class, new RestMock1());
            update objCase;
            initiateManualOnboarding.CCCaseUpdate(new Set<Id>{objCase.Id});
            MCK001_ApiCalls.nameScreening = false ;
            initiateManualOnboarding.CCCaseUpdate(new Set<Id>{objCase.Id});
        Test.stopTest();
    }
    //CH02: END
    
   //CH02: Commented by Jahangeer Mohammed 12-06-2023 due to Restricted Picklist value removed the value cc_Maker__c = 'Send to Pre-Screener'
   @isTest
    static void initiateManualOnboardingTest55(){
        Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId() ;
        Id suppRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card_Supplementary').getRecordTypeId() ;
        Account accObj = (Account)TestDataFactory.createSObject(new Account(RecordTypeId = customerRecordtypeId ),'TestFactoryDefaults.AccountDefaults',true);
        Case objCase = (Case)TestDataFactory.createSObject(new Case( sc_Card_Holder_ID_Number__c = '123' , RecordTypeId=suppRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',cc_Credit_Approval_Result__c ='Approve',
                                                    Type = 'Credit Card Supplementary Application',Sub_Type__c = 'New Supplementary Card',cc_Credit_Pre_Screening_Result__c = 'Accept'/*,cc_Maker__c = 'Send to Pre-Screener'*/),
                                                    'TestFactoryDefaults.CaseDefaults',true);    
                                    
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            MCK001_ApiCalls.nameScreening = false ;
            Test.setMock(HttpCalloutMock.class, new RestMock1());
            update objCase;
            initiateManualOnboarding.CCCaseUpdate(new Set<Id>{objCase.Id});
        Test.stopTest();
    }
    //CH02: END

    @isTest
    static void initiateManualOnboardingTest56(){
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId() ;
        Id creditRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Limit_Increase').getRecordTypeId() ;
        Id suppRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card_Supplementary').getRecordTypeId() ;
        Account accObj = (Account)TestDataFactory.createSObject(new Account(RecordTypeId = customerRecordtypeId ),'TestFactoryDefaults.AccountDefaults',true);
        
        Case objCase = (Case)TestDataFactory.createSObject(new Case( RecordTypeId=creditRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',cc_Credit_Approval_Result__c ='Approve',
                                                    Type = 'Credit Limit Increase Application',Sub_Type__c = 'Credit Limit Increase',cc_Name_on_the_Card__c='test',Sub_Status__c = 'In-Progress'),
                                                    'TestFactoryDefaults.CaseDefaults',true);
        Case objCase2 = (Case)TestDataFactory.createSObject(new Case( RecordTypeId=suppRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',
                                                    Type = 'Credit Card Supplementary Application',Sub_Type__c = 'New Supplementary Card',cc_Name_on_the_Card__c='test',Sub_Status__c = 'In-Progress'),
                                                    'TestFactoryDefaults.CaseDefaults',true);
        Case objCase3 = (Case)TestDataFactory.createSObject(new Case( ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',
                                                    Type = 'Credit Limit Increase Application',Sub_Type__c = 'Credit Limit Increase',cc_Name_on_the_Card__c='test',Sub_Status__c = 'Pending'),
                                                    'TestFactoryDefaults.CaseDefaults',true);     
        Case objCase4 = (Case)TestDataFactory.createSObject(new Case( RecordTypeId=suppRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',
                                                    Type = 'Credit Card Supplementary Application',Sub_Type__c = 'New Supplementary Card',cc_Name_on_the_Card__c='test',Sub_Status__c = 'Pending'),
                                                    'TestFactoryDefaults.CaseDefaults',true);    
    }

    @isTest
    static void initiateManualOnboardingTest57(){
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        Set<Id> caseIds = new Set<Id>();
        Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId() ;
        Id suppRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card_Supplementary').getRecordTypeId() ;
        Account accObj = (Account)TestDataFactory.createSObject(new Account(RecordTypeId = customerRecordtypeId ),'TestFactoryDefaults.AccountDefaults',true);
        Case objCase1 = (Case)TestDataFactory.createSObject(new Case( RecordTypeId=suppRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',
                                                    Type = 'Credit Card Supplementary Application',Sub_Type__c = 'New Supplementary Card',cc_Name_on_the_Card__c='test',Sub_Status__c = 'Referred by Maker'),
                                                    'TestFactoryDefaults.CaseDefaults',true);    
        caseIds.add(objCase1.Id);
		//CH02: Commented by Jahangeer Mohammed 12-06-2023 due to Restricted Picklist value removed the value cc_Maker__c = 'Send to Pre-Screener'
        Case objCase2 = (Case)TestDataFactory.createSObject(new Case( RecordTypeId=suppRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',/*cc_Maker__c = 'Send to Pre-Screener',*/
                                                    Type = 'Credit Card Supplementary Application',Sub_Type__c = 'New Supplementary Card',cc_Name_on_the_Card__c='test',Sub_Status__c = 'In-Progress'),
                                                    'TestFactoryDefaults.CaseDefaults',true);    
        caseIds.add(objCase2.Id);


        Case objCase3 = (Case)TestDataFactory.createSObject(new Case( RecordTypeId=suppRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',cc_Maker__c = 'Pending Relationship Establishment',
                                                    Type = 'Credit Card Supplementary Application',Sub_Type__c = 'New Supplementary Card',cc_Name_on_the_Card__c='test',Sub_Status__c = 'Pending Relationship'),
                                                    'TestFactoryDefaults.CaseDefaults',true);    
        caseIds.add(objCase3.Id);


        Case objCase4 = (Case)TestDataFactory.createSObject(new Case( RecordTypeId=suppRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',cc_Credit_Pre_Screening_Result__c = 'Pending Relationship Establishment',
                                                    Type = 'Credit Card Supplementary Application',Sub_Type__c = 'New Supplementary Card',cc_Name_on_the_Card__c='test',Sub_Status__c = 'Pending Relationship'),
                                                    'TestFactoryDefaults.CaseDefaults',true);    
        caseIds.add(objCase4.Id);


        Case objCase5 = (Case)TestDataFactory.createSObject(new Case( RecordTypeId=suppRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,cc_Credit_Pre_Screening_Result__c = 'Refer to Service Center',
                                                    Type = 'Credit Card Supplementary Application',Sub_Type__c = 'New Supplementary Card',cc_Name_on_the_Card__c='test',Sub_Status__c = 'Referred  by Pre-Screener'),
                                                    'TestFactoryDefaults.CaseDefaults',true);    
        caseIds.add(objCase5.Id);
        initiateManualOnboarding.CCCaseUpdate(caseIds);
    }

    @isTest
    static void initiateManualOnboardingTest58(){
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        Set<Id> caseIds = new Set<Id>();
        Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId() ;
        Id creditRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Limit_Increase').getRecordTypeId() ;
        Account accObj = (Account)TestDataFactory.createSObject(new Account(RecordTypeId = customerRecordtypeId ),'TestFactoryDefaults.AccountDefaults',true);
        Case objCase1 = (Case)TestDataFactory.createSObject(new Case( RecordTypeId=creditRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',cc_Signature_Verifier_Result__c='Accept',
                                                    Type = 'Credit Limit Increase Application',Sub_Type__c = 'Credit Limit Increase',cc_Name_on_the_Card__c='test',Sub_Status__c = 'In-Progress',cc_Credit_Approval_Result__c='Approve'),
                                                    'TestFactoryDefaults.CaseDefaults',true);    
        caseIds.add(objCase1.Id);
        initiateManualOnboarding.CCCaseUpdate(caseIds);
    }

    @isTest
    static void initiateManualOnboardingTest59(){
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        Set<Id> caseIds = new Set<Id>();
        Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId() ;
        Id creditRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId() ;
        Account accObj = (Account)TestDataFactory.createSObject(new Account(RecordTypeId = customerRecordtypeId ),'TestFactoryDefaults.AccountDefaults',true);
        Case objCase1 = (Case)TestDataFactory.createSObject(new Case( 
            RecordTypeId=creditRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',Sub_Status__c = 'In-Progress',cc_Requested_Card_Type__c='PLATINUM_BALANCE_TRANSFER_01',
            Type = 'Credit Card Application',Sub_Type__c = 'New Credit Card',cc_Name_on_the_Card__c='test',cc_Credit_Approval_Result__c='Approve',cc_Approved_Transfer_Type__c = 'Buy Out',cc_Balance_Transfer_Amount__c=100,
            cc_Balance_Transfer_Card_Number__c = '5464564546000045',cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',
            cc_Credit_Evaluation_Result__c = 'Accept Release Letter',cc_Service_Centre_Result__c='Release Letter Received',cc_Operations_Result__c='Balance Transfer Processed',cc_Signature_Verifier_Result__c='Accept',cc_Approved_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01'),
            'TestFactoryDefaults.CaseDefaults',true
        );    
        caseIds.add(objCase1.Id);
        initiateManualOnboarding.CCCaseUpdate(caseIds);
    }

    @isTest
    static void initiateManualOnboardingTest60(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Set<Id> caseIds = new Set<Id>();
        Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId() ;
        Id creditRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId() ;
        Id creditIncRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Limit_Increase').getRecordTypeId() ;
        Account accObj = (Account)TestDataFactory.createSObject(new Account(RecordTypeId = customerRecordtypeId ),'TestFactoryDefaults.AccountDefaults',true);
        Case objCase1 = (Case)TestDataFactory.createSObject(new Case( 
            RecordTypeId=creditRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',Sub_Status__c = 'In-Progress',cc_Requested_Card_Type__c='PLATINUM_BALANCE_TRANSFER_01',
            Type = 'Credit Card Application',Sub_Type__c = 'New Credit Card',cc_Name_on_the_Card__c='test',cc_Credit_Approval_Result__c='Approve',cc_Approved_Transfer_Type__c = 'Buy Out',cc_Balance_Transfer_Amount__c=100,
            cc_Balance_Transfer_Card_Number__c = '5464564546000045',cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',
            cc_Credit_Evaluation_Result__c = 'Accept Release Letter',cc_Service_Centre_Result__c='Release Letter Received',cc_Operations_Result__c='Balance Transfer Processed',cc_Signature_Verifier_Result__c='Accept',cc_Approved_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01'),
            'TestFactoryDefaults.CaseDefaults',true
        );    
        caseIds.add(objCase1.Id);

        Case objCase2 = (Case)TestDataFactory.createSObject(new Case( 
            RecordTypeId=creditRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',Sub_Status__c = 'In-Progress',cc_Requested_Card_Type__c='PLATINUM_BALANCE_TRANSFER_01',
            Type = 'Credit Card Application',Sub_Type__c = 'New Credit Card',cc_Name_on_the_Card__c='test',cc_Credit_Approval_Result__c='Approve',cc_Approved_Transfer_Type__c = 'Buy Out',cc_Balance_Transfer_Amount__c=100,
            cc_HR_Result__c = 'Approved',cc_Balance_Transfer_Card_Number__c = '5464564546000045',cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',
            cc_Approved_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01'),
            'TestFactoryDefaults.CaseDefaults',true
        );    
        caseIds.add(objCase2.Id);
        initiateManualOnboarding.CCCaseUpdate(caseIds);
    }

    @isTest
    static void initiateManualOnboardingTest61(){
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        Set<Id> caseIds = new Set<Id>();
        Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId() ;
        Id creditRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Limit_Increase').getRecordTypeId() ;
        Account accObj = (Account)TestDataFactory.createSObject(new Account(RecordTypeId = customerRecordtypeId ),'TestFactoryDefaults.AccountDefaults',true);
        Case objCase1 = (Case)TestDataFactory.createSObject(new Case( 
            RecordTypeId = creditRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',Sub_Status__c = 'In-Progress',
            Type = 'Credit Limit Increase Application',Sub_Type__c = 'Credit Limit Increase',cc_HR_Result__c = 'Approved',cc_Credit_Approval_Result__c='Approve'),
            'TestFactoryDefaults.CaseDefaults',true
        );    
        caseIds.add(objCase1.Id);

        Case objCase2 = (Case)TestDataFactory.createSObject(new Case( 
            RecordTypeId = creditRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',Sub_Status__c = 'In-Progress',
            Type = 'Credit Limit Increase Application',Sub_Type__c = 'Credit Limit Increase',cc_HR_Result__c = 'Approved',cc_Credit_Approval_Result__c='Approve',
            cc_Requested_Card_Type__c='PLATINUM_BALANCE_TRANSFER_01',cc_Approved_Requested_Card_Type__c='PLATINUM_BALANCE_TRANSFER_01',cc_Approved_Transfer_Type__c='Balance Transfer'),
            'TestFactoryDefaults.CaseDefaults',true
        );    
        caseIds.add(objCase2.Id);
        initiateManualOnboarding.CCCaseUpdate(caseIds);
    }

    @isTest
    static void initiateManualOnboardingTest62(){
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        Set<Id> caseIds = new Set<Id>();
        Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId() ;
        Id creditIncRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Limit_Increase').getRecordTypeId() ;
        Account accObj = (Account)TestDataFactory.createSObject(new Account(RecordTypeId = customerRecordtypeId ),'TestFactoryDefaults.AccountDefaults',true);
        Case objCase3 = (Case)TestDataFactory.createSObject(new Case( 
            RecordTypeId=creditIncRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',Sub_Status__c = 'In-Progress',cc_Requested_Card_Type__c='PLATINUM_BALANCE_TRANSFER_01',
            Type = 'Credit Limit Increase Application',Sub_Type__c = 'Credit Limit Increase',cc_Name_on_the_Card__c='test',cc_Credit_Approval_Result__c='Approve',cc_Approved_Transfer_Type__c = 'Buy Out',cc_Balance_Transfer_Amount__c=100,
            cc_HR_Result__c = 'Approved',cc_Balance_Transfer_Card_Number__c = '5464564546000045',cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',
            cc_Approved_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01'),
            'TestFactoryDefaults.CaseDefaults',true
        );    
        caseIds.add(objCase3.Id);

        Case objCase4 = (Case)TestDataFactory.createSObject(new Case( 
            RecordTypeId=creditIncRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',Sub_Status__c = 'In-Progress',cc_Requested_Card_Type__c='PLATINUM_BALANCE_TRANSFER_01',
            Type = 'Credit Limit Increase Application',Sub_Type__c = 'Credit Limit Increase',cc_Name_on_the_Card__c='test',cc_Credit_Approval_Result__c='Approve',cc_Approved_Transfer_Type__c = 'Buy Out',cc_Balance_Transfer_Amount__c=100,
            cc_Balance_Transfer_Card_Number__c = '5464564546000045',cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',cc_Credit_Pre_Screening_Result__c='Decline',
            cc_HR_Result__c = 'Accept Release Letter',cc_Operations_Result__c='Balance Transfer Processed',cc_Signature_Verifier_Result__c='Accept',cc_Approved_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01'),
            'TestFactoryDefaults.CaseDefaults',true
        );    
        caseIds.add(objCase4.Id);
        initiateManualOnboarding.CCCaseUpdate(caseIds);
    }

    @isTest
    static void initiateManualOnboardingTest63(){
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock1());
        Set<Id> caseIds = new Set<Id>();
        Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId() ;
        Id creditIncRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Limit_Increase').getRecordTypeId() ;
        Account accObj = (Account)TestDataFactory.createSObject(new Account(RecordTypeId = customerRecordtypeId ),'TestFactoryDefaults.AccountDefaults',true);

        Case objCase4 = (Case)TestDataFactory.createSObject(new Case( 
            RecordTypeId=creditIncRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',Sub_Status__c = 'In-Progress',cc_Requested_Card_Type__c='PLATINUM_BALANCE_TRANSFER_01',
            Type = 'Credit Limit Increase Application',Sub_Type__c = 'Credit Limit Increase',cc_Name_on_the_Card__c='test',cc_Credit_Approval_Result__c='Approve',cc_Approved_Transfer_Type__c = 'Buy Out',cc_Balance_Transfer_Amount__c=100,
            cc_Balance_Transfer_Card_Number__c = '5464564546000045',cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',cc_Credit_Pre_Screening_Result__c='Decline',
            cc_HR_Result__c = 'Accept Release Letter',cc_Operations_Result__c='Balance Transfer Processed',cc_Signature_Verifier_Result__c='Accept',cc_Approved_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01'),
            'TestFactoryDefaults.CaseDefaults',true
        );    
        caseIds.add(objCase4.Id);
        initiateManualOnboarding.CCCaseUpdate(caseIds);
    }

    @isTest
    static void initiateManualOnboardingTest64(){
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock1());
        Set<Id> caseIds = new Set<Id>();
        Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId() ;
        Id creditIncRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Limit_Increase').getRecordTypeId() ;
        Account accObj = (Account)TestDataFactory.createSObject(new Account(RecordTypeId = customerRecordtypeId ),'TestFactoryDefaults.AccountDefaults',true);

        Case objCase4 = (Case)TestDataFactory.createSObject(new Case( 
            RecordTypeId=creditIncRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',Sub_Status__c = 'In-Progress',cc_Requested_Card_Type__c='PLATINUM_BALANCE_TRANSFER_01',
            Type = 'Credit Limit Increase Application',Sub_Type__c = 'Credit Limit Increase',cc_Name_on_the_Card__c='test',cc_Approved_Transfer_Type__c = 'Buy Out',cc_Balance_Transfer_Amount__c=100,
            cc_Balance_Transfer_Card_Number__c = '5464564546000045',cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',
            cc_HR_Result__c = 'Cancelled by Customer',cc_Operations_Result__c='Balance Transfer Processed',cc_Approved_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01'),
            'TestFactoryDefaults.CaseDefaults',true
        );    
        caseIds.add(objCase4.Id);
        initiateManualOnboarding.CCCaseUpdate(caseIds);
    }

    @isTest
    static void initiateManualOnboardingTest65(){
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        Set<Id> caseIds = new Set<Id>();
        Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId() ;
        Id creditIncRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Limit_Increase').getRecordTypeId() ;
        Account accObj = (Account)TestDataFactory.createSObject(new Account(RecordTypeId = customerRecordtypeId ),'TestFactoryDefaults.AccountDefaults',true);

        Case objCase4 = (Case)TestDataFactory.createSObject(new Case( 
            RecordTypeId=creditIncRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',Sub_Status__c = 'In-Progress',cc_Requested_Card_Type__c='PLATINUM_BALANCE_TRANSFER_01',
            Type = 'Credit Limit Increase Application',Sub_Type__c = 'Credit Limit Increase',cc_Name_on_the_Card__c='test',cc_Approved_Transfer_Type__c = 'Buy Out',cc_Balance_Transfer_Amount__c=100,
            cc_Balance_Transfer_Card_Number__c = '5464564546000045',cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',
            cc_HR_Result__c = 'Cancelled by Customer',cc_Operations_Result__c='Balance Transfer Processed',cc_Approved_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01'),
            'TestFactoryDefaults.CaseDefaults',true
        );    
        caseIds.add(objCase4.Id);
        initiateManualOnboarding.CCCaseUpdate(caseIds);
    }

    @isTest
    static void initiateManualOnboardingTest66(){
        MyCalloutMock1 mck = new MyCalloutMock1();
        mck.testBody = 'test';
        Test.setMock(HttpCalloutMock.class, mck);
        Set<Id> caseIds = new Set<Id>();
        Id customerRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId() ;
        Id creditIncRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Limit_Increase').getRecordTypeId() ;
        Id creditRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId() ;
        Account accObj = (Account)TestDataFactory.createSObject(new Account(RecordTypeId = customerRecordtypeId ),'TestFactoryDefaults.AccountDefaults',true);

        Case objCase4 = (Case)TestDataFactory.createSObject(new Case( 
            RecordTypeId=creditIncRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',Sub_Status__c = 'In-Progress',cc_Requested_Card_Type__c='PLATINUM_BALANCE_TRANSFER_01',
            cc_SMS_Sent_Flag__c = true,cc_signature_sms_sent_flag__c=true,Type = 'Credit Limit Increase Application',Sub_Type__c = 'Credit Limit Increase',cc_Name_on_the_Card__c='test',cc_Approved_Transfer_Type__c = 'Buy Out',cc_Balance_Transfer_Amount__c=100,
            cc_Balance_Transfer_Card_Number__c = '5464564546000045',cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',
            cc_HR_Result__c = 'Cancelled by Customer',cc_Operations_Result__c='Balance Transfer Processed',cc_Approved_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01'),
            'TestFactoryDefaults.CaseDefaults',true
        );    
        caseIds.add(objCase4.Id);

        Case objCase5 = (Case)TestDataFactory.createSObject(new Case( 
            RecordTypeId=creditRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',Sub_Status__c = 'In-Progress',cc_Requested_Card_Type__c='PLATINUM_BALANCE_TRANSFER_01',
            cc_SMS_Sent_Flag__c = true,cc_signature_sms_sent_flag__c=true,
            Type = 'Credit Card Application',Sub_Type__c = 'New Credit Card',cc_Name_on_the_Card__c='test',cc_Credit_Approval_Result__c='Approve',cc_Approved_Transfer_Type__c = 'Buy Out',cc_Balance_Transfer_Amount__c=100,
            cc_HR_Result__c = 'Approved',cc_Balance_Transfer_Card_Number__c = '5464564546000045',cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',
            cc_Approved_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01'),
            'TestFactoryDefaults.CaseDefaults',true
        );    
        caseIds.add(objCase5.Id);
        initiateManualOnboarding.sendSMSReminder(caseIds);
    }

    @isTest
    static void initiateManualOnboardingTest67(){
        MyCalloutMock1 mck = new MyCalloutMock1();
        mck.testBody = 'test';
        Test.setMock(HttpCalloutMock.class, mck);
        Account accObj = (Account)TestDataFactory.createSObject(new Account(),'TestFactoryDefaults.AccountDefaults',true);

        Case objCase = (Case)TestDataFactory.createSObject(new Case( 
            ContactId = accObj.PersonContactId,AccountId = accObj.id),
            'TestFactoryDefaults.CaseDefaults',true
        );
        test.startTest();
        initiateManualOnboarding.getFCRresponse( con.createRequest('POST','/api/v1/notifications?', ''),true,objCase.Id,'','Freeze Card');
        test.stopTest();
    }

    @isTest
    static void initiateManualOnboardingTest68(){
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        Account accObj = (Account)TestDataFactory.createSObject(new Account(),'TestFactoryDefaults.AccountDefaults',true);
        Case objCase = (Case)TestDataFactory.createSObject(new Case( 
            ContactId = accObj.PersonContactId,AccountId = accObj.id,Case_Nature__c = 'Credit Card'),
            'TestFactoryDefaults.CaseDefaults',true
        );
        test.startTest();
        initiateManualOnboarding.getFCRresponse( con.createRequest('POST','/api/v1/notifications?', ''),true,objCase.Id,'','');
        test.stopTest();
    }
     @isTest
    static void initiateManualOnboardingTest69() {
        Set<Id> setIdAcc = new Set<Id>();
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc1.LastName = 'LastName new';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        setIdAcc.add(acc1.id);
        
        List<Case> lstCreateCase=new List<Case>();
       
        Case objCase = new Case();
        objCase.Subject = 'Stop Jamiyah Account';
        objCase.Jamiyah_Id__c = 2134;
        objCase.Description = 'A technical issue has occurred at an API level.';
        objCase.Type = 'Stop Jamiyah';
        //objCase.Case_Model__c='alburaq';//CH01
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
        objCase.Currency__c = 'BHD';
        objCase.Case_Nature__c = 'RC';
       // objCase.OwnerId = system.label.IT_Queue;
        objCase.Origin = 'CRM';
        objCase.ContactId = acc1.PersonContactId;
        objCase.AccountId = acc1.id;
        lstCreateCase.add(objCase);
        //CH02: Commented by Jahangeer Mohammed #12-06-2023#
        /*Case objCaseEKYC = new Case();
        objCaseEKYC.Subject = 'eKYC Signoff';
        objCaseEKYC.Description = 'eKYC Signoff';
        objCaseEKYC.Type = 'eKYC';
        objCaseEKYC.Status = 'In Progress';
        objCaseEKYC.Priority = 'High';
        objCaseEKYC.Origin = 'EKYC-UPLOAD';
        objCaseEKYC.ContactId = acc1.PersonContactId;
        objCaseEKYC.AccountId = acc1.id;
        lstCreateCase.add(objCaseEKYC);*/
        
        insert lstCreateCase;
        Set<Id> setIds = new Set<Id>();
        setIds.add(objCase.Id);
        initiateManualOnboarding.secondBHDAccountRequest(setIds);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"currency": {"code":"'+objCase.Currency__c+'","decimalPlaces": "3"},"templateId": "CA",'+ 
                            '"alias":"'+objCase.Alias_account__c+'",'+    
                            '"earnInterest":"'+objCase.Interest_Option__c+'"}';  

    
    }
    //CH02: Start
    @isTest
    static void initiateManualOnboardingTest400(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        Set<Id> setIds = new Set<Id>();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Sub_Type__c = 'New Credit Card';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
       
        test.startTest();
        insert cs1;
        cs1.cc_Credit_Pre_Screening_Result__c = 'Offer Cash Collateral';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_Credit_Bureau_Score__c = 70;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;
        setIds.add(cs1.id);
        initiateManualOnboarding.CCCaseUpdate(setIds);
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void initiateManualOnboardingTest401(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        Set<Id> setIds = new Set<Id>();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Sub_Type__c = 'New Credit Card';
        cs1.Case_Model__c='ila';//CH01
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
       
        test.startTest();
        insert cs1;
        
        setIds.add(cs1.id);
        initiateManualOnboarding.CCCaseCreation(setIds);
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void initiateManualOnboardingTest402(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.ID_Type__pc = 'Bahraini ID';
        acc.ID_Expiry_Date__pc = System.today() + 200 ;
        insert acc;
        Set<Id> setIds = new Set<Id>();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Sub_Type__c = 'New Credit Card';
        cs1.Case_Model__c='ila';//CH01
        //cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
       
        test.startTest();
        insert cs1;
        
        setIds.add(cs1.id);
        initiateManualOnboarding.CCCaseCreation(setIds);
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void initiateManualOnboardingTest403(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Limit Increase').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        Set<Id> setIds = new Set<Id>();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Credit Limit Increase';
        cs1.Case_Model__c='ila';//CH01
        //cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
       
        test.startTest();
        insert cs1;
        
        setIds.add(cs1.id);
        initiateManualOnboarding.CCCaseCreation(setIds);
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void initiateManualOnboardingTest404(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Limit Increase').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        Set<Id> setIds = new Set<Id>();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Credit Limit Increase';
        cs1.Case_Model__c='ila';//CH01
        //cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
       
        test.startTest();
        insert cs1;
        
        cs1.cc_Credit_Pre_Screening_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        update cs1;
        
        setIds.add(cs1.id);
        initiateManualOnboarding.CCCaseUpdate(setIds);
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void initiateManualOnboardingTest405(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Limit Increase').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        Set<Id> setIds = new Set<Id>();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Credit Limit Increase';
        cs1.Case_Model__c='ila';//CH01
        //cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
       
        test.startTest();
        insert cs1;
        
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        update cs1;
        
        setIds.add(cs1.id);
        initiateManualOnboarding.CCCaseUpdate(setIds);
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    
     @isTest
    static void initiateManualOnboardingTest406(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Limit Increase').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        Set<Id> setIds = new Set<Id>();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Credit Limit Increase';
        cs1.Case_Model__c='ila';//CH01
        //cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
       
        test.startTest();
        insert cs1;
        
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 400;
        update cs1;
        
        cs1.cc_Credit_Verification_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
        
        setIds.add(cs1.id);
        initiateManualOnboarding.CCCaseUpdate(setIds);
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    
     @isTest
    static void initiateManualOnboardingTest407(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Limit Increase').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        Set<Id> setIds = new Set<Id>();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Credit Limit Increase';
        cs1.Case_Model__c='ila';//CH01
        //cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
       
        test.startTest();
        insert cs1;
        
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 400;
        update cs1;
        
        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        setIds.add(cs1.id);
        initiateManualOnboarding.CCCaseUpdate(setIds);
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
  //CH02: END   

  @isTest
    static void UpdateCustomerDetailsForDNDupdate_TESTSuccess() {
        Set<Id> setIdAcc = new Set<Id>();
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc1.LastName = 'LastName new';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        setIdAcc.add(acc1.id);

        List<Case> lstCreateCase=new List<Case>();

        Case objCase = new Case();
        objCase.Subject = 'Add to DND';
        // objCase.Jamiyah_Id__c = 2134;
        objCase.Description = 'Add to DND';
        objCase.Type = 'Marketing Preference';
        objCase.sub_type__c = 'Add to DND List';
        // objCase.Case_Model__c='ila';
        objCase.Case_Nature__c = 'DND';
        // objCase.Case_Model__c = 'alburaq';
        objCase.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FCR').getRecordTypeId() ;
        objCase.Origin = 'CRM';
        objCase.ContactId = acc1.PersonContactId;
        objCase.AccountId = acc1.id;
        lstCreateCase.add(objCase);

        insert lstCreateCase;
        Set<Id> setIds = new Set<Id>();
        setIds.add(objCase.Id);
        initiateManualOnboarding.UpdateCustomerDetailsForDNDupdate(setIds);
        
    }

    @isTest
    static void UpdateCustomerDetailsForDNDupdate_TESTFail() {
        Set<Id> setIdAcc = new Set<Id>();
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc1.LastName = 'LastName new';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        acc1.Subscription_Model__pc  = 'alburaq';
        insert acc1;
        setIdAcc.add(acc1.id);

        List<Case> lstCreateCase=new List<Case>();

        Case objCase = new Case();
        objCase.Subject = 'Add to DND';
        // objCase.Jamiyah_Id__c = 2134;
        objCase.Description = 'Add to DND';
        objCase.Type = 'Marketing Preference';
        objCase.sub_type__c = 'Add to DND List';
        // objCase.Case_Model__c='ila';
        objCase.Case_Nature__c = 'DND';
        objCase.Case_Model__c = 'alburaq';
        objCase.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FCR').getRecordTypeId() ;
        objCase.Origin = 'CRM';
        objCase.ContactId = acc1.PersonContactId;
        objCase.AccountId = acc1.id;
        lstCreateCase.add(objCase);

        insert lstCreateCase;
        Set<Id> setIds = new Set<Id>();
        setIds.add(objCase.Id);
        MCK001_ApiCalls.statusCodeGlobal = 400;
        initiateManualOnboarding.UpdateCustomerDetailsForDNDupdate(setIds);
        
    }
     
}
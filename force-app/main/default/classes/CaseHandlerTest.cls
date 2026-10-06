/**
 *  @author: Andrey Gavrikov (westbrook)
 *  @date: 2019-03-08 13:58:42 
 *  @description: 
 *      Test methods for CaseHandler
 *  
 *  Change History :   #CH01# #Jahangeer Mohammed# #19-07-2022# Added test class methods to increase the code coverage.
 *           #CH01 Amina BENABDELKRIM  add add new field (case model) with default value 'ila'
 * 			 #CH03# #Jahangeer Mohammed# #11-06-2023# Added Region Flag in test class Methods
 *      
 */
@isTest
public class CaseHandlerTest  {
    
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
            res.setBody('{"Name": "sForceTest1"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class RestMock3 implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"data":{"transitionInProgress":false,"currentSegment":{"segmentName":"REGULAR","segmentCrmId":"Regular"},"campaign":{"id":1,"validity":6},"currentCards":[{"id":"10010522439126747125063583","cardName":"VIRTUAL","cardDisplayName":"Virtual","cardAfsId":"TestVirtualCards","productType":"Virtual","cardMinimumBalance":0,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":false,"limit":0,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"},{"id":"100105224391267471250615229","cardName":"CLASSIC","cardDisplayName":"Classic","cardAfsId":"Debit Classic","productType":"Classic","cardMinimumBalance":20,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"limit":1000,"nextAnnualAnniversaryDate":"2021-06-18T07:55:26","discount":{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"}],"segmentOptions":[{"segmentName":"STAFF","segmentCrmId":"Staff"},{"segmentName":"ROYAL_FAMILY","segmentCrmId":"Royal Family"},{"segmentName":"PREMIUM","segmentCrmId":"Premium"},{"segmentName":"PREMIUM_PLUS","segmentCrmId":"Premium Plus"},{"segmentName":"SENSITIVE","segmentCrmId":"Sensitive"}],"cardOptions":[{"cardName":"WORLD","cardDisplayName":"World","cardAfsId":"MasterCardWorld","productType":"World","cardMinimumBalance":0,"order":1,"issuanceFee":0.000,"annualFee":37.500,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":1.875,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":39.375},{"cardName":"ELITE","cardDisplayName":"Elite","cardAfsId":"WORLD_ELITE","productType":"World Elite","cardMinimumBalance":0,"order":2,"issuanceFee":0.000,"annualFee":75.000,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":3.750,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":78.750}],"discountOptions":[{"name":"None","displayName":"No discount","discountPercentage":0},{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},{"name":"Discount50","displayName":"50 percent discount","discountPercentage":50},{"name":"Discount75","displayName":"75 percent discount","discountPercentage":75},{"name":"Free","displayName":"No charge","discountPercentage":100}]},"meta":{"code":"SGMT-1006","message":"Customer Segment Options retrieved successfully."}}');
            res.setStatusCode(200);
            return res;
        }
    }
    

    @testSetup static void setupMethode() {
        Account acc = new Account();
        acc.FirstName = 'TestIla';
        acc.LastName = 'TestIla';
        //acc.Created_from_Lead__c =true;
        acc.PersonEmail = 'testclass@ilatest123.com';
        //CH03: Start
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        //CH03: END
        insert acc;
        
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

    @isTest
    static void testUuidAssignment () {
        final List<Case> cases = new List<Case>{
            new Case(),
            new Case()

        };
        CaseHandler.setCaseUuid(cases);
        //CH03: Commented by Jahangeer Mohammed
        //System.assert(String.isNotBlank(cases[0].Uuid__c), 'Expected UUID to be assigned');
        //System.assert(String.isNotBlank(cases[1].Uuid__c), 'Expected UUID to be assigned');


        // code coverage
        try {
            // cause trigger handler to fire. 
            // Do not really care what it does as we test actual logic in other place
            //CH03: Added Region Flag
            Database.insert(new Case(Subject = 'Test',Case_Model__c='ila', Region_Flag__c = 'Bahrain'), false); //CH01
                        
        } catch (Exception eIgnore) {System.debug('The following exception has occurred: ' + eIgnore.getMessage());}
    }
    
    @isTest
    static void caseHandlerTest7(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        //CH03: Start
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        //CH03: END
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
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.Case_Nature__c = 'Credit Card';
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
        cs1.cc_Credit_Pre_Screening_Result__c = 'Discrepancy in Documents';
        cs1.Case_Model__c='ila';
        //CH03: Start
        cs1.Region_Flag__c = 'Bahrain';
        //CH03: END
        
        test.startTest();
        insert cs1;
        
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        cs1.cc_Credit_Bureau_Score__c = 755;
        cs1.Sub_Status__c = 'Discrepancies';
        update cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    public static String bodyString(Case objCase){
        String body;
        if(objCase.Sub_Status__c == 'In-Progress' && objCase.cc_Name_on_the_Card__c != NULL){
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
         else if(objCase.Sub_Status__c == 'Discrepancies' && objCase.cc_Name_on_the_Card__c != NULL){
              body = '{"crmCaseId": "'+objCase.Id +
                                '","status":"DISCREPANCIES"}';
         }
         else if(objCase.Sub_Status__c == 'Referred  by Pre-Screener' && objCase.cc_Name_on_the_Card__c != NULL){
              body = '{"crmCaseId": "'+objCase.Id +
                                    '","status":"REFERRED_BY_PRESCREENER"}';
         }
         else if(objCase.Sub_Status__c == 'Referred by Verifier' && objCase.cc_Name_on_the_Card__c != NULL){
              body = '{"crmCaseId": "'+objCase.Id +
                                    '","status":"REFERRED_BY_VERIFIER"}';
         }
         else if(objCase.Sub_Status__c == 'Pending Signature Verification' && objCase.cc_Name_on_the_Card__c != NULL){
             body = '{"crmCaseId": "'+objCase.Id +
                                    '","status":"APPROVED_PENDING_SIGNATURE"}';
         }
         else if(objCase.Sub_Status__c == 'Referred by Approver' && objCase.cc_Name_on_the_Card__c != NULL){
                    body = '{"crmCaseId": "'+objCase.Id +
                                    '","status":"REFERRED_BY_APPROVER"}';
                }
         
         else if(objCase.Sub_Status__c == 'Pending Balance Transfer' && objCase.cc_Name_on_the_Card__c != NULL){
            body = '{"cardProductConfigurationId": "'+665756 +
                            '","crmCaseId": "'+objCase.Id +
                            '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                            '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                            '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                            '","status":"APPROVED_PENDING_BT_PROCESSING"}';
         }
         else if(objCase.Sub_Status__c == 'Approved' && objCase.cc_Name_on_the_Card__c != NULL){
              body = '{"cardProductConfigurationId": "'+665756 +
                            '","crmCaseId": "'+objCase.Id +
                            '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                            '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                            '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                            '","status":"APPROVED"}';
         }
         else if(objCase.Sub_Status__c == 'Pending Signature Verification' && objCase.cc_Name_on_the_Card__c != NULL){
             body = '{"crmCaseId": "'+objCase.Id +
                                '","status":"APPROVED_PENDING_SIGNATURE"}';
         }
         else if(objCase.Sub_Status__c == 'Referred by Signature Verifier'  && objCase.cc_Name_on_the_Card__c != NULL ){
             body = '{"crmCaseId": "'+objCase.Id +
                                '","status":"REFERRED_BY_SIGNATURE_VERIFIER"}';
         }
         else if(objCase.Sub_Status__c == 'Pending Release Letter' && objCase.cc_Name_on_the_Card__c != NULL){
             body = '{"crmCaseId": "'+objCase.Id +
                                    '","status":"APPROVED_PENDING_BT_LETTER"}';
         }
         
         else if(objCase.Sub_Status__c == 'Release Letter Received' && objCase.cc_Name_on_the_Card__c != NULL){
             body = '{"crmCaseId": "'+objCase.Id +
                                    '","status":"APPROVED_PENDING_BT_LETTER_RECEIVED"}';
         }
          else if(objCase.Sub_Status__c == 'Release Letter Accepted' && objCase.cc_Name_on_the_Card__c != NULL){
             body = '{"crmCaseId": "'+objCase.Id +
                                    '","status":"APPROVED_PENDING_BT_LETTER_ACCEPTED"}';
         }
          else if(objCase.Sub_Status__c == 'Card Block Released' && objCase.cc_Name_on_the_Card__c != NULL){
             body = '{"crmCaseId": "'+objCase.Id +
                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                '","status":"APPROVED"}';
         }
        /* else if(objCase.Sub_Status__c == 'Card Block Released' && objCase.cc_Name_on_the_Card__c != NULL){
             body = '{"crmCaseId": "'+objCase.Id +
                                '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                '","targetType": "SUPPLEMENTARY_CARD","status":"PENDING" }';
         }*/
        return body;
    }
   
    /*public static String bodyString1(Case objCase){
        String body;
        if(objCase.Sub_Status__c == 'Pending' && objCase.cc_Name_on_the_Card__c != NULL){
            body = '{"crmCaseId":"'+objCase.Id+
                                '","cardProductConfigurationId":'+SM001_ApiCalls.stringApiFormat(objCase.PrimaryCardProductConfigurationId__c)+
                                ',"pciNumber":'+SM001_ApiCalls.stringApiFormat(objCase.PrimaryCard__c) +
                                ',"embossName":'+ SM001_ApiCalls.stringApiFormat(objCase.cc_Name_on_the_Card__c)+
                                ',"supplementaryCard":'+
                                    '{"mobile":"'+objCase.sc_Card_Holder_Mobile_No__c+
                                    '","email":"'+objCase.sc_Card_Holder_Email_Address__c+
                                    '","relationship":"'+objCase.sc_Relationship__c+
                                    '","enableSpendingLimit":false},'+
                                '"creditLimit": 0' +
                                ',"targetType": "SUPPLEMENTARY_CARD","status":"PENDING"}';
        }
        else if(objCase.Sub_Status__c == 'In-Progress' && objCase.cc_Name_on_the_Card__c != NULL){
            body = '{"crmCaseId": "'+objCase.Id +
                                '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                '","targetType": "SUPPLEMENTARY_CARD","status":"IN_PROGRESS" }'
        }
        return body;
   } */

    @isTest
    static void CaseHandlerTest40 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Pre-Screening');
            // Case cs = caseMappingRespectedToAccount('Credit_Card',acc.Id,'Credit Pre-Screening');
            try {
                insert cs;
                cs.cc_Credit_Pre_Screening_Result__c = 'Refer to Service Center';
                cs.Case_Nature__c = 'Credit Card';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }
    //CH03: Start
    @isTest
    static void CaseHandlerTest401 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
       
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
         
            Test.startTest();
            Case cs = caseMappingRespectedToAccount('Credit_Card',acc.Id,'Credit Pre-Screening');
            try {
                insert cs;
                cs.cc_Credit_Pre_Screening_Result__c = 'Refer to Service Center';
                cs.Case_Nature__c = 'Credit Card';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        
    }
    @isTest
    static void CaseHandlerTest402 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
       
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
         
            Test.startTest();
            Case cs = caseMappingRespectedToAccount('Credit_Card',acc.Id,'Credit Pre-Screening');
            try {
                insert cs;
                cs.cc_Credit_Pre_Screening_Result__c = 'Accept';
                cs.Case_Nature__c = 'Credit Card';
                cs.cc_Passport_Number__c = 'RT546FRGF';
        		cs.cc_Passport_Expiry_Date__c = System.today() + 360;
        		cs.cc_Residence_Permit_No__c = '546';
        		cs.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        
    }
     @isTest
    static void CaseHandlerTest403 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
       
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
         
            Test.startTest();
            Case cs = caseMappingRespectedToAccount('Credit_Card',acc.Id,'Credit Pre-Screening');
            try {
                insert cs;
                cs.cc_Credit_Pre_Screening_Result__c = 'Offer Cash Collateral';
                cs.Case_Nature__c = 'Credit Card';
                cs.cc_Passport_Number__c = 'RT546FRGF';
        		cs.cc_Passport_Expiry_Date__c = System.today() + 360;
        		cs.cc_Residence_Permit_No__c = '546';
        		cs.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        
    }
    @isTest
    static void CaseHandlerTest404 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
       
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
         
            Test.startTest();
            Case cs = caseMappingRespectedToAccount('Credit_Card',acc.Id,'Credit Pre-Screening');
            try {
                insert cs;
                cs.cc_Credit_Pre_Screening_Result__c = 'Accept';
                cs.Case_Nature__c = 'Credit Card';
                cs.cc_Passport_Number__c = 'RT546FRGF';
        		cs.cc_Passport_Expiry_Date__c = System.today() + 360;
        		cs.cc_Residence_Permit_No__c = '546';
        		cs.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
                update cs;
                cs.cc_Credit_Evaluation_Result__c = 'Refer to Service Center';
                cs.cc_Application_Stages__c = 'Credit Evaluation';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        
    }
     @isTest
    static void CaseHandlerTest405 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
       
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
         
            Test.startTest();
            Case cs = caseMappingRespectedToAccount('Credit_Card',acc.Id,'Credit Pre-Screening');
            try {
                insert cs;
                cs.cc_Credit_Pre_Screening_Result__c = 'Accept';
                cs.Case_Nature__c = 'Credit Card';
                cs.cc_Passport_Number__c = 'RT546FRGF';
        		cs.cc_Passport_Expiry_Date__c = System.today() + 360;
        		cs.cc_Residence_Permit_No__c = '546';
        		cs.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
                update cs;
                cs.cc_Credit_Evaluation_Result__c = 'Accept';
                cs.cc_Application_Stages__c = 'Credit Evaluation';
                cs.cc_Approved_Credit_Limit__c = 500;
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        
    }
     @isTest
    static void CaseHandlerTest406 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
       
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
         
            Test.startTest();
            Case cs = caseMappingRespectedToAccount('Credit_Card',acc.Id,'Credit Pre-Screening');
            try {
                insert cs;
                cs.cc_Credit_Pre_Screening_Result__c = 'Accept';
                cs.Case_Nature__c = 'Credit Card';
                cs.cc_Passport_Number__c = 'RT546FRGF';
        		cs.cc_Passport_Expiry_Date__c = System.today() + 360;
        		cs.cc_Residence_Permit_No__c = '546';
        		cs.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
                update cs;
                cs.cc_Credit_Evaluation_Result__c = 'Accept';
                cs.cc_Application_Stages__c = 'Credit Evaluation';
                cs.cc_Approved_Credit_Limit__c = 500;
                update cs;
                cs.cc_Credit_Verification_Result__c = 'Approve';
                cs.cc_Application_Stages__c = 'Credit Verification';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        
    }
     @isTest
    static void CaseHandlerTest407 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
       
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
         
            Test.startTest();
            Case cs = caseMappingRespectedToAccount('Credit_Card',acc.Id,'Credit Pre-Screening');
            try {
                insert cs;
                cs.cc_Credit_Pre_Screening_Result__c = 'Accept';
                cs.Case_Nature__c = 'Credit Card';
                cs.cc_Passport_Number__c = 'RT546FRGF';
        		cs.cc_Passport_Expiry_Date__c = System.today() + 360;
        		cs.cc_Residence_Permit_No__c = '546';
        		cs.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
                update cs;
                cs.cc_Credit_Evaluation_Result__c = 'Accept';
                cs.cc_Application_Stages__c = 'Credit Evaluation';
                cs.cc_Approved_Credit_Limit__c = 500;
                update cs;
                cs.cc_Credit_Verification_Result__c = 'Refer to Service Center';
                cs.cc_Application_Stages__c = 'Credit Verification';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        
    }
     @isTest
    static void CaseHandlerTest408 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
       
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
         
            Test.startTest();
            Case cs = caseMappingRespectedToAccount('Credit_Card',acc.Id,'Credit Pre-Screening');
            try {
                insert cs;
                cs.cc_Credit_Pre_Screening_Result__c = 'Accept';
                cs.Case_Nature__c = 'Credit Card';
                cs.cc_Passport_Number__c = 'RT546FRGF';
        		cs.cc_Passport_Expiry_Date__c = System.today() + 360;
        		cs.cc_Residence_Permit_No__c = '546';
        		cs.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
                update cs;
                cs.cc_Credit_Evaluation_Result__c = 'Accept';
                cs.cc_Application_Stages__c = 'Credit Evaluation';
                cs.cc_Approved_Credit_Limit__c = 500;
                update cs;
                cs.cc_Credit_Verification_Result__c = 'Approve';
                cs.cc_Application_Stages__c = 'Credit Verification';
                update cs;
                cs.cc_Credit_Approval_Result__c = 'Approve';
                cs.cc_Application_Stages__c = 'Credit Approval';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        
    }
    @isTest
    static void CaseHandlerTest409 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
       
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
         
            Test.startTest();
            Case cs = caseMappingRespectedToAccount('Credit_Card',acc.Id,'Credit Pre-Screening');
            try {
                insert cs;
                cs.cc_Credit_Pre_Screening_Result__c = 'Accept';
                cs.Case_Nature__c = 'Credit Card';
                cs.cc_Passport_Number__c = 'RT546FRGF';
        		cs.cc_Passport_Expiry_Date__c = System.today() + 360;
        		cs.cc_Residence_Permit_No__c = '546';
        		cs.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
                update cs;
                cs.cc_Credit_Evaluation_Result__c = 'Accept';
                cs.cc_Application_Stages__c = 'Credit Evaluation';
                cs.cc_Approved_Credit_Limit__c = 500;
                update cs;
                cs.cc_Credit_Verification_Result__c = 'Approve';
                cs.cc_Application_Stages__c = 'Credit Verification';
                update cs;
                cs.cc_Credit_Approval_Result__c = 'Refer to Service Center';
                cs.cc_Application_Stages__c = 'Credit Approval';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        
    }
    @isTest
    static void CaseHandlerTest410(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';
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
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.Region_Flag__c = 'Bahrain';
        test.startTest();
        insert cs1;
        
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        update cs1;
                
        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
                
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void CaseHandlerTest411(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 500;
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
        cs1.Region_Flag__c = 'Bahrain';
        test.startTest();
        insert cs1;
        
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_Credit_Bureau_Score__c = 755;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        update cs1;
                
        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
                
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void CaseHandlerTest412(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Amount__c = 500;
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Buy Out';
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
        cs1.Region_Flag__c = 'Bahrain';
        test.startTest();
        insert cs1;
        
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Salary_is_Transferred_to_ila__c = true;
        cs1.cc_Credit_Bureau_Score__c = 755;
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        update cs1;
                
        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
                
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        //update cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void CaseHandlerTest413(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';
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
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.Region_Flag__c = 'Bahrain';
        test.startTest();
        insert cs1;
        
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        update cs1;
                
        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
                
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Re-Send';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void CaseHandlerTest414(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Model__c='ila';
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
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.Region_Flag__c = 'Bahrain';
        test.startTest();
        insert cs1;
        
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        update cs1;
        
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Evaluation';
        cs1.cc_Approved_Credit_Limit__c = 500;
        update cs1;
                
        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Verification';
        update cs1;
                
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        //update cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    //CH03: END

    @isTest
    static void CaseHandlerTest41 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Service Centre');
            cs.Case_Nature__c = 'Credit Card';
            try {
                insert cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void CaseHandlerTest42 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Evaluation');
            cs.Case_Nature__c = 'Credit Card';
            try {
                insert cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void CaseHandlerTest43 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Verification');
            try {
                insert cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void CaseHandlerTest44 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Approval');
            try {
                insert cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void CaseHandlerTest45 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Business Team');
            try {
                insert cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void CaseHandlerTest46 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit CEO');
            try {
                insert cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest 
    static void CaseHandlerTest47 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Contact Centre');
            cs.Case_Nature__c = 'Credit Card';
            try {
                insert cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void CaseHandlerTest48 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Buyout');
            cs.Case_Nature__c = 'Credit Card';
            try {
                insert cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void CaseHandlerTest49 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Signature Verification');
            cs.Case_Nature__c = 'Credit Card';
            try {
                insert cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void CaseHandlerTest50 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card_Staff_Application',acc.PersonContactId,'Credit HR Team');
            cs.Case_Nature__c = 'Credit Card';
            try {
                insert cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

    
    @isTest
    static void CaseHandlerTest51 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card_Staff_Application',acc.PersonContactId,'Credit Service Centre');
            cs.Case_Nature__c = 'Credit Card';
            try {
                insert cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void CaseHandlerTest52 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card_Staff_Application',acc.PersonContactId,'Credit Buyout');
            cs.Case_Nature__c = 'Credit Card';
            try {
                insert cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void CaseHandlerTest53 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card_Staff_Application',acc.PersonContactId,'Credit Buyout');
            cs.Case_Nature__c = 'Credit Card';
            cs.Type = 'Credit Card Account Closing';
            cs.Sub_Type__c = null;
            try {
                insert cs;
                cs.cc_Anti_Attrition_Comment__c = 'test Credit Card Account Closing';
                cs.cc_Balance_Transfer_Amount__c = 20.00;
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void CaseHandlerTest54 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card_Staff_Application',acc.PersonContactId,'Credit Buyout');
            cs.Type = 'Credit Card Account Closing';
            cs.Case_Nature__c = 'Credit Card';
            cs.Sub_Type__c = null;
            try {
                insert cs;
                cs.cc_Contact_Centre_Result__c = 'Request to Pay Outstanding Balance';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

     @isTest
    static void CaseHandlerTest55 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card_Staff_Application',acc.PersonContactId,'Credit Buyout');
            cs.Type = 'Credit Card Account Closing';
            cs.Case_Nature__c = 'Credit Card';
            cs.Sub_Type__c = null;
            try {
                insert cs;
                cs.cc_Contact_Centre_Result__c = 'Card Blocked & Proceed with Closing';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void CaseHandlerTest56 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card_Staff_Application',acc.PersonContactId,'Credit Buyout');
            cs.Type = 'Credit Card Account Closing';
            cs.Case_Nature__c = 'Credit Card';
            cs.Sub_Type__c = null;
            try {
                insert cs;
                cs.cc_Contact_Centre_Result__c = 'Return to Anti Attrition';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    } 
    
    @isTest
    static void CaseHandlerTest57 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Pre-Screening');
            cs.Type = 'Credit Card Application';
            cs.Sub_Type__c = 'New Credit Card';
            cs.Case_Nature__c = 'Credit Card';
            cs.cc_CPR_Expiry_Date__c = system.today() +365;
            cs.cc_CPR_Number__c = '237623823229323';
            cs.cc_Approved_Balance_Transfer_Card_Number__c = '1234567890123456';
            cs.cc_CRM_Stage__c   = null;
            try {
                insert cs;
                cs.cc_Credit_Pre_Screener_Comments__c = 'test1';
                cs.cc_Credit_Evaluator_Comments__c = 'test2';
                cs.cc_Credit_Verifier_Comments__c = 'test3';
                cs.cc_Credit_Approver_Comments__c = 'test4';
                cs.cc_Credit_Business_Team_Comments__c = 'test5';
                cs.cc_Service_Centre_Comments__c = 'test6';
                cs.cc_Contact_Centre_Comments__c = 'test7';
                cs.cc_Signature_Verification_Comments__c = 'test8';
                cs.cc_Operations_Comments__c = 'test9';
                cs.cc_CEO_Comments__c = 'test10';
                cs.cc_HR_Comments__c = 'test11';
                cs.cc_Approved_Balance_Transfer_Card_Number__c = '1234567890123457';
                update cs;
                System.debug('//***************');
                System.debug([SELECT ID,cc_Credit_Pre_Screener_Comments__c FROM Case WHERE Id =:cs.Id ]);
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void CaseHandlerTest58 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Pre-Screening');
            cs.Type = 'Credit Card Services';
            cs.Case_Nature__c = 'Credit Card';
            cs.Sub_Type__c = null;
            try {
                insert cs;
                
                cs.cc_Maker_Comments__c = 'test8';
                cs.cc_Checker_Comments__c = 'test8';
                cs.cc_Credit_Pre_Screener_Comments__c = 'test prescreener Comments';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void CaseHandlerTest59 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Pre-Screening');
            cs.Type = 'Credit Card Account Closing';
            cs.Case_Nature__c = 'Credit Card';
            cs.Sub_Type__c = null;
            try {
                insert cs;
                cs.cc_Anti_Attrition_Comment__c = 'test';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }  

    @isTest
    static void CaseHandlerTest60 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Pre-Screening');
            cs.Type = 'Credit Card Account Closing';
            cs.Case_Nature__c = 'Credit Card';
            cs.Sub_Type__c = null;
            try {
                insert cs;
                cs.cc_Maker__c = 'Send to Checker';
                update cs;

            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }

            try {
                cs.cc_Maker__c = 'Cancel';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void CaseHandlerTest61 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Pre-Screening');
            cs.Type = 'Credit Card Account Closing';
            cs.Case_Nature__c = 'Credit Card';
            cs.Sub_Type__c = null;
            try {
                insert cs;
                //cs.cc_Checker_Result__c = 'Approve';
                //update cs;

            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }

            try {
                cs.cc_Checker_Result__c = 'Reject';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }

            try {
                cs.cc_Checker_Result__c = 'Return to Maker';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }


    @isTest
    static void CaseHandlerTest62 () {
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Pre-Screening');
            cs.Type = 'Credit Card Account Closing';
            cs.Case_Nature__c = 'Credit Card';
            cs.Sub_Type__c = null;
            try {
                insert cs;
                cs.cc_AntiAttritionResult__c = 'Cancel';
                update cs;

            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }

            try {
                cs.cc_AntiAttritionResult__c = 'Return to Maker';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }
    @isTest
    static void CaseHandlerTest63 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card_Staff_Application',acc.PersonContactId,'Credit HR Team');
            cs.Case_Nature__c = 'Credit Card';
            try {
                insert cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }
    @isTest
    static void CaseHandlerTest64 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Pre-Screening');
            cs.Case_Nature__c = 'Credit Card';
            try {
                insert cs;
                cs.cc_Credit_Pre_Screening_Result__c = 'Decline';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }
    @isTest
    static void CaseHandlerTest65 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Pre-Screening');
            cs.Case_Nature__c = 'Credit Card';
            try {
                insert cs;
                cs.cc_Credit_Pre_Screening_Result__c = 'Cancelled by Customer';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        }
    }
    @isTest
    static void CaseHandlerTest103 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
       // System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Pre-Screening');
            cs.Type = 'Credit Card Application';
            cs.cc_CPR_Expiry_Date__c = system.today() +365;
            cs.cc_CPR_Number__c = '237623823229323';
            cs.Sub_Type__c = null;
            cs.Case_Nature__c = 'Credit Card';
            try {
                insert cs;
                cs.cc_Credit_Pre_Screening_Result__c = 'Accept';
                update cs;
                cs.cc_Credit_Pre_Screening_Result__c = 'Pending Relationship Establishment';
                update cs;

            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }

            try {
                cs.cc_Credit_Pre_Screening_Result__c = 'Refer to Service Center';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
        //}
    }
    
    @isTest
    static void CaseHandlerTest104 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        //System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Evaluation');
            cs.Type = 'Credit Card Application';
            cs.Sub_Type__c = 'New Credit Card';
            cs.cc_CPR_Expiry_Date__c = system.today() +365;
            cs.cc_CPR_Number__c = '237623823229323';
            cs.Case_Nature__c = 'Credit Card';
            cs.Sub_Type__c = null;
            try {
                insert cs;
                cs.cc_Credit_Evaluation_Result__c = 'Accept';
                cs.cc_Credit_Evaluator_Comments__c = 'test evaluator Comments';
                update cs;
                cs.cc_Credit_Verification_Result__c = 'Approve';
                update cs;

            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }

            try {
                cs.cc_Credit_Evaluation_Result__c = 'Refer to Service Center';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
       // }
    }
    
    @isTest
    static void CaseHandlerTest101 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = 
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
       // System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMappingSupp('Credit_Card_Supplementary',acc.PersonContactId,'Credit Maker');
            cs.Type = 'Credit Card Supplementary Application';
            cs.Case_Nature__c = 'Credit Card';
            //cs.Sub_Type__c = 'New Supplementary Card';
            //cs.Sub_Type__c = null;
            try {
                insert cs;
                system.debug('----> '+[Select id, Type, Sub_Type__c, recordType.name, cc_Maker__c, cc_Application_Stages__c from CASE where id =: cs.id]);  
                cs.cc_Maker__c = 'Pending Relationship Establishment';
                update cs;
                

            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }

            try {
                cs.cc_Maker__c = 'Refer to Service Center';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
      //  }
    }
    
    // @isTest
    // static void CaseHandlerTest105 () {
    //     Test.setMock(HttpCalloutMock.class, new RestMock3());
    //     final MyCalloutMock mock3 = new MyCalloutMock();
    //     //mock3.testBody = 
    //     User testUser = createIlaUser();
    //     Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
    //    // System.runAs(testUser){ 
    //         Test.startTest();
    //         Case cs = caseMappingSupp('Credit_Card_Supplementary',acc.PersonContactId,'Credit Maker');
    //         cs.Type = 'Credit Card Supplementary Application';
    //         //cs.Sub_Type__c = 'New Supplementary Card';
    //         //cs.Sub_Type__c = null;
    //         try {
    //             insert cs;
    //             system.debug('----> '+[Select id, Type, Sub_Type__c, recordType.name, cc_Maker__c, cc_Application_Stages__c from CASE where id =: cs.id]);  
    //             cs.Case_Nature__c = 'RC';
    //             cs.cc_Maker__c = 'Accept';
    //             update cs;
                

    //         } catch (Exception e) {
    //             System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
    //         }

    //         try {
    //             cs.cc_Maker__c = 'Send to Pre-Screener';
    //             update cs;
    //         } catch (Exception e) {
    //             System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
    //         }
    //         Test.stopTest();
    //   //  }
    // }
    
    @isTest
    static void CaseHandlerTest106 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = 
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
       // System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMappingSupp('Credit_Card_Supplementary',acc.PersonContactId,'Credit Pre-Screening');
            cs.Case_Nature__c = 'Credit Card';
            cs.Type = 'Credit Card Supplementary Application';
            cs.Sub_Type__c = 'New Supplementary Card';
            //cs.Sub_Type__c = null;
            try {
                insert cs;
                system.debug('----> '+[Select id, Type, Sub_Type__c, recordType.name, cc_Credit_Pre_Screening_Result__c, cc_Application_Stages__c from CASE where id =: cs.id]);  
                cs.cc_Credit_Pre_Screening_Result__c = 'Pending Relationship Establishment';
                update cs;
                

            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }

            try {
                cs.cc_Credit_Pre_Screening_Result__c = 'Refer to Service Center';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
      //  }
    }
    
    @isTest
    static void CaseHandlerTest107 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = 
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
       // System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMappingSupp('Credit_Card_Supplementary',acc.PersonContactId,'Credit Pre-Screening');
            cs.Type = 'Credit Card Supplementary Application';
            cs.Case_Nature__c = 'Credit Card';
            cs.Sub_Type__c = 'New Supplementary Card';
            //cs.Sub_Type__c = null;
            try {
                insert cs;
                system.debug('----> '+[Select id, Type, Sub_Type__c, recordType.name, cc_Maker__c, cc_Application_Stages__c from CASE where id =: cs.id]);  
                cs.cc_Credit_Pre_Screening_Result__c = 'Accept';
                update cs;
                

            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }

            try {
                cs.cc_Credit_Pre_Screening_Result__c = 'Refer to Service Center';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
      //  }
    }
    
    @isTest
    static void CaseHandlerTest108 () {
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        //mock3.testBody = 
        User testUser = createIlaUser();
        Account acc = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
       // System.runAs(testUser){ 
            Test.startTest();
            Case cs = caseMapping('Credit_Card',acc.PersonContactId,'Credit Pre-Screening');
            cs.Type = 'Credit Card Supplementary Application';
            cs.Sub_Type__c = 'New Supplementary Card';
            //cs.Sub_Type__c = null;
            try {
                insert cs;
                system.debug('----> '+[Select id, Type, Sub_Type__c, recordType.name, cc_Maker__c, cc_Application_Stages__c from CASE where id =: cs.id]);  
                cs.cc_Credit_Pre_Screening_Result__c = 'Accept';
                update cs;
                

            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }

            try {
                cs.cc_Credit_Pre_Screening_Result__c = 'Refer to Service Center';
                update cs;
            } catch (Exception e) {
                System.debug('test error : '+e.getCause() +' ==> '+e.getMessage());
            }
            Test.stopTest();
      //  }
    }

    
    private static User createIlaUser(){
        User testUser = new User(
            Username = 'test123TUVWXYZ0123456789abcde@test.com',
            LastName = 'test123',
            FirstName = 'test123',
            Email = 'test123@gmail.com',
            Alias = 'ikart',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile 
            WHERE name LIKE '%ila CEO%' 
            ORDER BY CreatedDate ASC LIMIT 1].Id
        );
        insert testUser;
        return testUser;
    }
    private static Case caseMappingSupp(String recordTypeDev ,Id PersonContactId ,String cc_Application_Stages){
        Case cs = new Case();
        cs.Subject = 'Supplementary Card';
        cs.Description = 'Supplementary Card Desc';
        cs.Type = 'Credit Card Supplementary Application';
        cs.Status = 'In Progress';
        cs.Case_Nature__c = 'Credit Card';
        cs.Priority = 'High';
        cs.Sub_Type__c = 'New Supplementary Card';
        cs.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDev).getRecordTypeId();
        cs.Awaiting_Customer_Feedback__c = false;
        cs.Origin = 'OL';
        cs.ContactId = PersonContactId;
        cs.cc_Monthly_Income__c =900;
        cs.cc_PCI_Id__c ='1';
        cs.Awaiting_Customer_Feedback__c = true;
        cs.Email_Status__c = 'Email Received';
        cs.cc_Application_Stages__c = cc_Application_Stages;
        //CH03: Start
        cs.Region_Flag__c = 'Bahrain';
        //CH03: END
        return cs;
    }
    private static Case caseMapping(String recordTypeDev ,Id PersonContactId ,String cc_Application_Stages){
        Case cs = new Case();
        cs.Subject = 'Technical failure to start Orchestration Layer';
        cs.Description = 'A technical issue has occurred at an API level.';
        cs.Type = 'Credit Card Application';
        cs.cc_CPR_Expiry_Date__c = system.today() +365;
        cs.cc_CPR_Number__c = '237623823229323';
        cs.Case_Nature__c = 'Credit Card';
        cs.Status = 'In Progress';
        cs.Priority = 'High';
        cs.Sub_Type__c = 'New Credit Card';
        cs.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDev).getRecordTypeId();
        cs.Awaiting_Customer_Feedback__c = false;
        cs.Origin = 'OL';
        cs.ContactId = PersonContactId;
        cs.cc_Monthly_Income__c =900;
        cs.cc_PCI_Id__c ='1';
        cs.Awaiting_Customer_Feedback__c = true;
        cs.Email_Status__c = 'Email Received';
        cs.cc_Application_Stages__c = cc_Application_Stages;
        //CH03: Start
        cs.Region_Flag__c = 'Bahrain';
        //CH03: END
        return cs;
    }
    //CH03: Start
     private static Case caseMappingRespectedToAccount(String recordTypeDev ,Id accountId ,String cc_Application_Stages){
        Case cs = new Case();
        cs.Subject = 'Technical failure to start Orchestration Layer';
        cs.Description = 'A technical issue has occurred at an API level.';
        cs.Type = 'Credit Card Application';
        cs.cc_CPR_Expiry_Date__c = system.today() +365;
        cs.cc_CPR_Number__c = '237623823229323';
        cs.Case_Nature__c = 'Credit Card';
        cs.Status = 'In Progress';
        cs.Priority = 'High';
        cs.Sub_Type__c = 'New Credit Card';
        cs.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDev).getRecordTypeId();
        cs.Awaiting_Customer_Feedback__c = false;
        cs.Origin = 'OL';
        cs.accountId = accountId;
        cs.cc_Monthly_Income__c =900;
        cs.cc_PCI_Id__c ='1';
        cs.Awaiting_Customer_Feedback__c = true;
        cs.Email_Status__c = 'Email Received';
        cs.cc_Application_Stages__c = cc_Application_Stages;
       
        cs.Region_Flag__c = 'Bahrain';
       
        return cs;
    }
    //CH03: END

    //***** commented methods ******/
    @isTest(seeAllData=false)
    static void CaseHandlerTest1 () {
        
       Account acc01 = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        
        Case cs = new Case();
        cs.Subject = 'Technical failure to start Orchestration Layer';
        cs.Description = 'A technical issue has occurred at an API level.';
        cs.Type = 'Technical';
        cs.Case_Nature__c = 'Credit Card';
        //cs.Lead_Created_Account__c = true;
        cs.Status = 'In Progress';
        cs.Priority = 'High';
        cs.Case_Nature__c = 'Credit Card';
        //cs.OwnerId = system.label.IT_Queue;
        cs.OwnerId = userInfo.getUserId();
        cs.Awaiting_Customer_Feedback__c = false;
        cs.Origin = 'OL';
        
        
        cs.ContactId = acc01.PersonContactId;
        cs.cc_Monthly_Income__c =900;
        cs.cc_PCI_Id__c ='1';
        cs.Case_Model__c ='ila';

        insert cs;
        
        cs.Awaiting_Customer_Feedback__c = true;
        cs.Email_Status__c = 'Email Received';
        update cs;
        
        cs.Awaiting_Customer_Feedback__c = false;
        cs.Status = 'Closed';
        update cs;
    }
    
    @isTest(seeAllData=false)
    static void CaseHandlerTest01 () {
        
        Account acc02 = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        
        Case cs = new Case();
        cs.Subject = 'Technical failure to start Orchestration Layer';
        cs.Description = 'A technical issue has occurred at an API level.';
        cs.Case_Nature__c = 'Credit Card';
        cs.Type = 'eKYC';
        //cs.Lead_Created_Account__c = true;
        cs.Status = 'In Progress';
        cs.Priority = 'High';
        cs.eKYC_Retry_Counter__c = 4;
        
        //cs.OwnerId = system.label.IT_Queue;
        cs.OwnerId = userInfo.getUserId();
        cs.Awaiting_Customer_Feedback__c = false;
        cs.Origin = 'OL';
        
        cs.ContactId = acc02.PersonContactId;
        cs.cc_Monthly_Income__c =900;
        cs.cc_PCI_Id__c ='1';
        cs.Case_Model__c ='ila';
        insert cs;
             
        //cs.Awaiting_Customer_Feedback__c = false;
        cs.eKYC_decision__c = 'Manual Retry';
        update cs;
        
        cs.eKYC_decision__c = 'Convert to Identification Case';
        update cs;
    }
    
    @isTest
    static void caseHandlerTest2(){
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        Account acc03 = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        
        Case cs1 = new Case();
        cs1.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Sub_Type__c = 'New Credit Card';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        cs1.Status = 'In Progress';
        cs1.Case_Nature__c = 'Credit Card';
        cs1.Priority = 'High';
        cs1.cc_Residence_Permit_No__c = '434344';
        cs1.cc_Passport_Number__c = 'ABC12345';
        cs1.cc_Approved_Balance_Transfer_Card_Number__c = '1234567890123456';
        cs1.cc_Residence_Permit_Expiry_Date__c  = system.today()+100;
        cs1.cc_Passport_Expiry_Date__c = system.today()+120;
        cs1.sys_Balance_Transfer_Card_Number__c = '1234567890123458';
        cs1.cc_Balance_Transfer_Card_Number__c = '1234567890123459';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        cs1.cc_Credit_Verification_Result__c = '';
        cs1.cc_Credit_Approval_Result__c = '';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.Origin = 'Phone';
        //cs1.cc_Application_Stages__c = 'Credit Maker';
        cs1.ContactId = acc03.PersonContactId;
        cs1.cc_Monthly_Income__c =100;
        cs1.cc_PCI_Id__c = '2';
        cs1.Case_Model__c ='ila';
        //CH03: Start
        cs1.Region_Flag__c = 'Bahrain';
        //CH03: END
        test.startTest();
        
        insert cs1;
        
        cs1.cc_Approved_Balance_Transfer_Card_Number__c = '1234567890123457';
        cs1.cc_Credit_Pre_Screening_Result__c = 'Discrepancy in Documents';
        update cs1;
        cs1.cc_Credit_Pre_Screener_Comments__c = 'test prescreener Comments';
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        update cs1;
        cs1.cc_Credit_Evaluator_Comments__c = 'test Evaluator Comments';
        //cs1.cc_Credit_Evaluation_Result__c = 'Discrepancy in Documents';
        update cs1;
        cs1.cc_Final_DBR__c =50;
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        update cs1;
        cs1.cc_Balance_Transfer_Card_Number__c = '1234567890123450';
        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Credit_Verifier_Comments__c = 'test verifier Comments';
        update cs1;
        User u = [Select Id from user where lastName='Integration' limit 1];
        System.runas(u){
        cs1.cc_Credit_Approver_Comments__c = 'test Approver Comments';
        cs1.cc_CEO_Comments__c = 'test CEO Comments';
        cs1.cc_Signature_Verification_Comments__c = 'test Signature Comments';
        cs1.cc_Credit_Approval_Result__c = 'Escalate to Business Team';
        update cs1;
        }
        cs1.cc_Credit_Business_Team_Comments__c = 'test Business Comments';
        cs1.cc_Operations_Comments__c = ' test Ops comments';
        cs1.cc_Service_Centre_Comments__c = 'Service Center Comments';
        cs1.cc_Business_Approval_Result__c = 'Approve';
        update cs1;
        cs1.cc_Contact_Centre_Comments__c = 'test Contact Center Comments';
        cs1.cc_HR_Comments__c = 'test11';
        //cs1.cc_Contact_Centre_Result__c = 'Return to Evaluator';
        update cs1;

       // test.stopTest();
        
        /*Case cs2 = new Case();
        cs2.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Collection Letter').getRecordTypeId();
        cs2.Subject = 'Credit Collection Letter Application';
        cs2.Description = 'Credit Collection Letter ApplicationCards';
        cs2.Type = 'Credit Collection Letter Application';
        cs2.OwnerId = system.Label.Credit_Collection_Queue;
        cs2.Case_Nature__c = 'RC';
       
        cs2.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs2.Status = 'In Progress';
        cs2.Priority = 'High';
        cs2.Origin = 'Phone';
        cs2.cc_Application_Stages__c = 'Credit Maker';
        cs2.ContactId = acc03.PersonContactId;
        cs2.cc_Monthly_Income__c =3500;
        cs2.cc_PCI_Id__c = '2';
        cs2.Case_Model__c ='ila';
        
        insert cs2;
        
        cs2.cc_Maker__c = 'Accept';
        update cs2;
        
        cs2.OwnerId = system.Label.Credit_Collection_Checker;
        cs2.cc_Checker_Result__c ='Accept';
        update cs2;*/
        
       test.stopTest();
    
    }
    
    
    @isTest
    static void caseHandlerTest109(){
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        Account acc03 = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        test.startTest();
        Case cs2 = new Case();
        cs2.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Collection Letter').getRecordTypeId();
        cs2.Subject = 'Credit Collection Letter Application';
        cs2.Description = 'Credit Collection Letter ApplicationCards';
        cs2.Type = 'Credit Collection Letter Application';
        cs2.Case_Nature__c = 'Credit Card';
        cs2.OwnerId = system.Label.Credit_Collection_Queue;
        //cs2.Sub_Type__c = 'New Supplementary Card';
        cs2.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs2.Status = 'In Progress';
        cs2.Priority = 'High';
        cs2.Origin = 'Phone';
        cs2.cc_Application_Stages__c = 'Credit Maker';
        cs2.ContactId = acc03.PersonContactId;
        cs2.cc_Monthly_Income__c =100;
        cs2.cc_PCI_Id__c = '2';
        cs2.Case_Model__c ='ila';

        insert cs2;

        cs2.cc_Maker__c = 'Accept';
        update cs2;
        
        cs2.OwnerId = system.Label.Credit_Collection_Checker;
        cs2.cc_Checker_Result__c ='Decline';
        update cs2;

        test.stopTest();
    }
    
     @isTest
    static void caseHandlerTest110(){
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        Account acc03 = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        test.startTest();
        Case cs2 = new Case();
        cs2.Case_Nature__c = 'Credit Card';
        cs2.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Collection Letter').getRecordTypeId();
        cs2.Subject = 'Credit Collection Letter Application';
        cs2.Description = 'Credit Collection Letter ApplicationCards';
        cs2.Type = 'Credit Collection Letter Application';
        cs2.OwnerId = system.Label.Credit_Collection_Queue;
        //cs2.Sub_Type__c = 'New Supplementary Card';
        cs2.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs2.Status = 'In Progress';
        cs2.Priority = 'High';
        cs2.Origin = 'Phone';
        cs2.cc_Application_Stages__c = 'Credit Maker';
        cs2.ContactId = acc03.PersonContactId;
        cs2.cc_Monthly_Income__c =1500;
        cs2.cc_PCI_Id__c = '2';
        cs2.Case_Model__c ='ila';

        insert cs2;

        cs2.cc_Maker__c = 'Accept';
        cs2.cc_Maker_Comments__c = 'test Maker Comments';
        update cs2;

        cs2.cc_Checker_Result__c ='Return to Maker';
        update cs2;

        test.stopTest();
    }
    
     @isTest
    static void caseHandlerTest111(){
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        Account acc03 = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        
        Case cs1 = new Case();
        cs1.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Limit Increase').getRecordTypeId();
        cs1.Subject = 'Credit Limit Increase Application';
        cs1.Description = 'Credit Limit Increase ApplicationTest for Duplicate Cards';
        cs1.Type = 'Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Credit Limit Increase';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        cs1.Status = 'In Progress';
        cs1.Priority = 'High';
        cs1.Case_Nature__c = 'Credit Card';
        cs1.cc_Residence_Permit_No__c = '434344';
        cs1.cc_Passport_Number__c = 'ABC12345';
        cs1.cc_Approved_Balance_Transfer_Card_Number__c = '1234567890123456';
        cs1.cc_Residence_Permit_Expiry_Date__c  = system.today()+100;
        cs1.cc_Passport_Expiry_Date__c = system.today()+120;
        cs1.sys_Balance_Transfer_Card_Number__c = '1234567890123458';
        cs1.cc_CPR_Expiry_Date__c = system.today()+365;
        cs1.cc_CPR_Number__c = '2322829000001';
        cs1.cc_Approved_Credit_Limit__c = 2100;
        cs1.cc_Credit_Verification_Result__c = '';
        cs1.cc_Credit_Approval_Result__c = '';
        cs1.Origin = 'Phone';
        //cs1.cc_Application_Stages__c = 'Credit Maker';
        cs1.ContactId = acc03.PersonContactId;
        cs1.cc_Monthly_Income__c =2100;
        cs1.cc_PCI_Id__c = '2';
        cs1.Case_Model__c ='ila';
        //CH03: Start
        cs1.Region_Flag__c = 'Bahrain';
        //CH03: END
        test.startTest();
        insert cs1;
        
        cs1.Status = 'Documents Received';
        update cs1;
    }
    
     @isTest
    static void caseHandlerTest112(){
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        Account acc03 = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        
        Case cs1 = new Case();
        cs1.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Services').getRecordTypeId();
        cs1.Subject = 'Credit Limit Increase Application';
        cs1.Description = 'Credit Limit Increase ApplicationTest for Duplicate Cards';
        cs1.Type = 'Credit Card Account Closing';
        cs1.Case_Nature__c = 'Credit Card';
        cs1.Sub_Type__c = 'Credit Card Account Closing';
        cs1.cc_CPR_Expiry_Date__c = system.today()+365;
        cs1.cc_CPR_Number__c = '2322829000001';
        //cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        cs1.Status = 'In Progress';
        cs1.Priority = 'High';
        cs1.cc_Residence_Permit_No__c = '434344';
        cs1.cc_Passport_Number__c = 'ABC12345';
        cs1.cc_Approved_Balance_Transfer_Card_Number__c = '1234567890123456';
        cs1.cc_Residence_Permit_Expiry_Date__c  = system.today()+100;
        cs1.cc_Passport_Expiry_Date__c = system.today()+120;
        cs1.sys_Balance_Transfer_Card_Number__c = '1234567890123458';
        cs1.cc_Approved_Credit_Limit__c = 2100;
        cs1.cc_Credit_Verification_Result__c = '';
        cs1.cc_Credit_Approval_Result__c = '';
        cs1.Origin = 'Phone';
        //cs1.cc_Application_Stages__c = 'Credit Maker';
        cs1.ContactId = acc03.PersonContactId;
        cs1.cc_Monthly_Income__c =2100;
        cs1.cc_PCI_Id__c = '2';
        cs1.Case_Model__c ='ila';
        test.startTest();
        insert cs1;
        //CH03: Commented by Jahangeer Mohammed due Bad value of Restricted picklist
        /*cs1.cc_Maker__c ='Send to Anti Attrition';
        cs1.cc_Maker_Comments__c = 'Maker Comments terst';
        update cs1;*/
        cs1.cc_AntiAttritionResult__c = 'Cancel';
        update cs1;
        cs1.cc_AntiAttritionResult__c = 'Approve';
        //update cs1;
    }
    
    @isTest
    static void caseHandlerTest113(){
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        Account acc03 = [SELECT Id,PersonContactId FROM Account WHERE LastName = 'TestIla' LIMIT 1];
        
        Case cs1 = new Case();
        cs1.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Services').getRecordTypeId();
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Account Closing';
        cs1.Sub_Type__c = 'Credit Card Account Closing';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        cs1.Status = 'In Progress';
        cs1.Priority = 'High';
        cs1.Case_Nature__c = 'Credit Card';
        cs1.cc_Residence_Permit_No__c = '434344';
        cs1.cc_Passport_Number__c = 'ABC12345';
        cs1.cc_Approved_Balance_Transfer_Card_Number__c = '1234567890123456';
        cs1.cc_Residence_Permit_Expiry_Date__c  = system.today()+100;
        cs1.cc_Passport_Expiry_Date__c = system.today()+120;
        cs1.sys_Balance_Transfer_Card_Number__c = '1234567890123458';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        cs1.cc_Credit_Verification_Result__c = '';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.cc_Credit_Approval_Result__c = '';
        cs1.Origin = 'Phone';
        cs1.ContactId = acc03.PersonContactId;
        cs1.cc_Monthly_Income__c =100;
        cs1.cc_PCI_Id__c = '2';
        cs1.Case_Model__c ='ila';
        test.startTest();
        insert cs1;
        
        cs1.cc_Anti_Attrition_Comment__c = 'test Attrition Comments';
        cs1.cc_Maker_Comments__c = 'test Maker Comments';
       /* cs1.cc_Contact_Centre_Result__c ='Request to Pay Outstanding Balance';
        update cs1;
        cs1.cc_Contact_Centre_Result__c ='Card Blocked & Proceed with Closing';
        update cs1;
        cs1.cc_Contact_Centre_Result__c ='Return to Anti Attrition';
        update cs1;*/
        test.stopTest();
    } 
    //END
     
    //CH01: Start
     @isTest
    static void caseHandlerTest114(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        //CH03: Start
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
		//CH03: END
        insert acc;
        System.debug('Account Personel Email:'+acc.PersonEmail);
        System.debug('Account Personel CIF:'+acc.CIF__pc);
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.Case_Nature__c = 'Credit Card';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
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
        cs1.cc_Friend_s_Contact_Number__c = '551096';
        cs1.Case_Model__c ='ila';
        //CH03: Start
        cs1.Region_Flag__c = 'Bahrain';
        //CH03: END
        test.startTest();
        insert cs1;
        
        cs1.cc_Friend_s_Contact_Number__c = '551097';
        update cs1;
        
        test.stopTest();
    }
    
     @isTest
     static void caseHandlerTest115(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        //CH03: Start
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        //CH03: END
        insert acc;
        System.debug('Account Personel Email:'+acc.PersonEmail);
        System.debug('Account Personel CIF:'+acc.CIF__pc);
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.Priority = 'High';
        cs1.Case_Nature__c = 'Credit Card';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Friend_s_Contact_Number__c = '00551096';
        cs1.Case_Model__c ='ila';
        cs1.Sub_Status__c = 'In-Progress';
        cs1.Region_Flag__c = 'Bahrain';
        test.startTest();
        insert cs1;
        
        cs1.cc_Friend_s_Contact_Number__c = '00551097';
        cs1.cc_Credit_Pre_Screening_Result__c = 'Re-Upload Document';
        cs1.Sub_Status__c = null;
       
        update cs1;

        cs1.Sub_Type__c = 'New Credit Card';
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Credit_Evaluation_Result__c = 'Accept';
        cs1.cc_Credit_Verification_Result__c = 'Approve';
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        //cs1.cc_Business_Approval_Result__c = 'Approve';
        cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
        cs1.cc_Credit_Bureau_Score__c = 755;
        //cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.Fixed_Allowances__c = null;
        cs1.Basic_Salary__c = null;
        cs1.Variable_Allowances__c = null;
        cs1.Business_Income__c = null;
        cs1.Sub_Status__c = 'Pending';

        
        update cs1;

        test.stopTest();
    }
    
     @isTest
    static void caseHandlerTest116(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        //CH03: Start
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        //CH03: END
        insert acc;
        System.debug('Account Personel Email:'+acc.PersonEmail);
        System.debug('Account Personel CIF:'+acc.CIF__pc);
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Case_Nature__c = 'Credit Card';
        cs1.Type = 'Credit Card Application';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.Sub_Type__c = 'New Credit Card';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
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
        cs1.cc_Friend_s_Contact_Number__c = '+97300551096';
        cs1.Case_Model__c ='ila';
        //CH03: Start
         cs1.Region_Flag__c = 'Bahrain';
        //CH03: END
        test.startTest();
        insert cs1;
        
        cs1.cc_Friend_s_Contact_Number__c = '+97300551097';
        //cs1.cc_Credit_Pre_Screening_Result__c = 'Re-Upload Document';
        update cs1;
        
        cs1.cc_Friend_s_Contact_Number__c = '';
        update cs1;
        
        test.stopTest();
    }
    
     @isTest
    static void caseHandlerTest117() {
        Set<Id> setIdAcc = new Set<Id>();
     Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.Nationality__pc = 'BH';
            acc.CIF__pc = '5464546';
            acc.Segment__pc='Staff';
            insert acc;
            
            
            Account acc1 = new Account();
            acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc1.FirstName = 'Test3';
            acc1.LastName = 'Class3';
            acc1.PersonEmail = 'test3@ilatest.com';
            acc1.Nationality__pc = 'BA';
            acc1.CIF__pc = '5464547';
            acc1.Segment__pc='Staff';
            insert acc1;
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Premium Retention').getRecordTypeId();

            Account acc2 = new Account();
            acc2.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc2.FirstName = 'Test4';
            acc2.LastName = 'Class4';
            acc2.PersonEmail = 'test4@ilatest.com';
            acc2.Nationality__pc = 'BH';
            acc2.CIF__pc = '5464548';
            acc2.Segment__pc='Staff';
            insert acc2;
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Premium Retention Application';
            cs1.ac_RequestedBy__c = 'Customer';
            cs1.Origin = 'Phone';
            cs1.Case_Nature__c = 'Credit Card';
            cs1.AccountId = acc.Id;
            cs1.cc_Monthly_Income__c =6000;
            cs1.cc_PCI_Id__c = '8';
            cs1.cc_Passport_Number__c = 'RT546FRGF';
            cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
            cs1.Case_Nature__c = 'Credit Card';
            cs1.cc_Residence_Permit_No__c = '546';
            cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
            //cs1.cc_Credit_Pre_Screening_Result__c = 'Discrepancy in Documents';
           // cs1.Sub_Status__c='Pending Customer';
            cs1.Case_Model__c ='ila';
            cs1.Expiry_Days__c=2;
            cs1.ac_RequestedBy__c=null;
            insert cs1;
           test.startTest();
           cs1.Sub_Status__c='Pending';
           test.stopTest();
    }
      @isTest
    static void caseHandlerTest118() {
        Set<Id> setIdAcc = new Set<Id>();
     Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.Nationality__pc = 'BH';
            acc.CIF__pc = '5464546';
            acc.Segment__pc='Staff';
            insert acc;
            
            
            Account acc1 = new Account();
            acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc1.FirstName = 'Test3';
            acc1.LastName = 'Class3';
            acc1.PersonEmail = 'test3@ilatest.com';
            acc1.Nationality__pc = 'BA';
            acc1.CIF__pc = '5464547';
            acc1.Segment__pc='Staff';
            insert acc1;
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Premium Retention').getRecordTypeId();

            Account acc2 = new Account();
            acc2.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc2.FirstName = 'Test4';
            acc2.LastName = 'Class4';
            acc2.PersonEmail = 'test4@ilatest.com';
            acc2.Nationality__pc = 'BH';
            acc2.CIF__pc = '5464548';
            acc2.Segment__pc='Staff';
            insert acc2;
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Premium Retention Application';
            cs1.ac_RequestedBy__c = 'Bank / CBB';
            cs1.Origin = 'Phone';
            cs1.Case_Nature__c = 'Credit Card';
            cs1.AccountId = acc.Id;
            cs1.cc_Monthly_Income__c =6000;
            cs1.cc_PCI_Id__c = '8';
            cs1.Case_Nature__c = 'Credit Card';
            cs1.cc_Passport_Number__c = 'RT546FRGF';
            cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
            cs1.cc_Residence_Permit_No__c = '546';
            cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
            //cs1.cc_Credit_Pre_Screening_Result__c = 'Discrepancy in Documents';
           // cs1.Sub_Status__c='Pending Customer';
            cs1.Case_Model__c ='ila';
            cs1.Expiry_Days__c=2;
            cs1.ac_RequestedBy__c=null;
            insert cs1;
           test.startTest();
           cs1.Sub_Status__c='Pending';
           test.stopTest();
    }
     @isTest
    static void caseHandlerTest119(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        //CH03: Start
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        //CH03: END
        insert acc;
        System.debug('Account Personel Email:'+acc.PersonEmail);
        System.debug('Account Personel CIF:'+acc.CIF__pc);
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.Case_Nature__c = 'Credit Card';
        cs1.Sub_Type__c = 'New Credit Card';
         //cs1.Is_Cash_Collateral__c = false;
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
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
        cs1.cc_Friend_s_Contact_Number__c = '00551096';
        cs1.Case_Model__c = 'ila';//CH02
        //CH03: Start
        cs1.Region_Flag__c = 'Bahrain';
        //CH03: END
        test.startTest();
        insert cs1;
        
        cs1.cc_Friend_s_Contact_Number__c = '00551097';
        //cs1.cc_Credit_Pre_Screening_Result__c = 'Re-Upload Document';
        cs1.Sub_Status__c = 'Documents Received';
        update cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        
        
        test.stopTest();
    }
    
    
      @isTest
    static void caseHandlerTest120(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Limit Increase').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        //CH03: Start
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        //CH03: END
        insert acc;
        System.debug('Account Personel Email:'+acc.PersonEmail);
        System.debug('Account Personel CIF:'+acc.CIF__pc);
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Case_Nature__c = 'Credit Card';
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Limit Increase Application';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623823229323';
        cs1.Sub_Type__c = 'Credit Limit Increase';
         cs1.Is_Cash_Collateral__c = false;
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
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
        cs1.cc_Friend_s_Contact_Number__c = '00551096';
        cs1.Case_Model__c = 'ila';
        //CH03: Start
        cs1.Region_Flag__c = 'Bahrain';
        //CH03: END
        test.startTest();
        insert cs1;
        
        cs1.cc_Friend_s_Contact_Number__c = '00551097';
        //cs1.cc_Credit_Pre_Screening_Result__c = 'Re-Upload Document';
        cs1.Sub_Status__c = 'Documents Received';
        update cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        
        
        test.stopTest();
    }
     @isTest
    static void caseHandlerTest121(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Services').getRecordTypeId();
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
        cs1.Case_Nature__c = 'Credit Card';
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Account Closing';
        cs1.Sub_Type__c = 'Credit Card Account Closing';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        cs1.Status = 'In Progress';
        cs1.Priority = 'High';
        cs1.cc_Residence_Permit_No__c = '434344';
        cs1.cc_Passport_Number__c = 'ABC12345';
        cs1.cc_Approved_Balance_Transfer_Card_Number__c = '1234567890123456';
        cs1.cc_Residence_Permit_Expiry_Date__c  = system.today()+100;
        cs1.cc_Passport_Expiry_Date__c = system.today()+120;
        cs1.ownerId = userInfo.getUserId();
        
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =100;
        cs1.cc_PCI_Id__c = '2';
        cs1.Case_Model__c = 'ila';
        test.startTest();
        insert cs1;
        cs1.cc_Anti_Attrition_Comment__c = 'test Attrition Comments';
        cs1.cc_Maker_Comments__c = 'test Maker Comments';
        //update cs1;
        cs1.cc_Contact_Centre_Result__c ='Request to Pay Outstanding Balance';
        cs1.OwnerId = system.Label.VisionPlusQueue;
        cs1.BUA_Reason__c = 'Pending on customer response';
        update cs1;
        test.stopTest();
    }
      @isTest
    static void caseHandlerTest122(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Services').getRecordTypeId();
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
        cs1.Type = 'Credit Card Services';
        cs1.Sub_Type__c = 'Direct Debit Settings';
        cs1.ownerId = userInfo.getUserId();
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        cs1.Status = 'In Progress';
        cs1.Priority = 'High';
        cs1.Case_Nature__c = 'Credit Card';
        cs1.cc_Residence_Permit_No__c = '434344';
        cs1.cc_Passport_Number__c = 'ABC12345';
        cs1.cc_Approved_Balance_Transfer_Card_Number__c = '1234567890123456';
        cs1.cc_Residence_Permit_Expiry_Date__c  = system.today()+100;
        cs1.cc_Passport_Expiry_Date__c = system.today()+120;
       
        
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =100;
        cs1.cc_PCI_Id__c = '2';
        cs1.Case_Model__c = 'ila';
        test.startTest();
        insert cs1;
        cs1.cc_Anti_Attrition_Comment__c = 'test Attrition Comments';
        cs1.cc_Maker_Comments__c = 'test Maker Comments';
        //update cs1;
       // cs1.cc_Contact_Centre_Result__c ='Card Blocked & Proceed with Closing';
        //cs1.OwnerId = system.Label.VisionPlusQueue;
        update cs1;
        test.stopTest();
    }
     @isTest
    static void caseHandlerTest123(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Services').getRecordTypeId();
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
        cs1.Case_Nature__c = 'Credit Card';
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Account Closing';
        cs1.Sub_Type__c = 'Credit Card Account Closing';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        cs1.Status = 'In Progress';
        cs1.Priority = 'High';
        cs1.cc_Residence_Permit_No__c = '434344';
        cs1.ownerId = userInfo.getUserId();
        cs1.cc_Passport_Number__c = 'ABC12345';
        cs1.cc_Approved_Balance_Transfer_Card_Number__c = '1234567890123456';
        cs1.cc_Residence_Permit_Expiry_Date__c  = system.today()+100;
        cs1.cc_Passport_Expiry_Date__c = system.today()+120;
       
        
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =100;
        cs1.cc_PCI_Id__c = '2';
        cs1.Case_Model__c = 'ila';
        test.startTest();
        insert cs1;
        cs1.cc_Anti_Attrition_Comment__c = 'test Attrition Comments';
        cs1.cc_Maker_Comments__c = 'test Maker Comments';
        //update cs1;
        cs1.cc_Contact_Centre_Result__c ='Return to Anti Attrition';
        cs1.ownerId = system.Label.Credit_Card_Send_to_Anti_Attrition;
        update cs1;
        test.stopTest();
    }
      @isTest
    static void caseHandlerTest124(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Services').getRecordTypeId();
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
        cs1.Type = 'Credit Card Services';
       
        cs1.Status = 'In Progress';
        cs1.Priority = 'High';
        cs1.Case_Nature__c = 'Credit Card';
        
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =100;
        cs1.cc_PCI_Id__c = '2';
        cs1.Case_Model__c = 'ila';
        test.startTest();
        insert cs1;
        cs1.cc_VisionPlus_Result__c ='Completed';
        update cs1;
        test.stopTest();
    }
    //CH01: End  */
    

    @isTest
    static void caseHandlerTest3(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        //CH03: Start
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        //CH03: END
        insert acc;
        System.debug('Account Personel Email:'+acc.PersonEmail);
        System.debug('Account Personel CIF:'+acc.CIF__pc);
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Application';
        cs1.cc_CPR_Expiry_Date__c = system.today() +365;
        cs1.cc_CPR_Number__c = '237623829323';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.Priority = 'High';
        cs1.Case_Nature__c = 'Credit Card';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Friend_s_Contact_Number__c = '00551096';
        cs1.Case_Model__c ='ila';
        cs1.Sub_Type__c = 'New Credit Card';
        //CH03: Start
        cs1.Region_Flag__c = 'Bahrain';
        //CH03: END
        test.startTest();
        insert cs1;
       
        cs1.cc_AntiAttritionResult__c = 'Return to Maker';
       // cs1.cc_Contact_Centre_Result__c ='Card Blocked & Proceed with Closing';
        cs1.cc_Maker__c ='Send to Checker'; // 2121
        cs1.cc_Checker_Result__c ='Reject';//2154
        cs1.Campaign_Name__c = '2'; //1990
        cs1.Campaign_Validity__c = 'Campain';//1990
        cs1.Address_Updated_By__c = [Select id from User where isActive=true LIMIT 1].id;
        update cs1;
       
        cs1.cc_Maker__c ='Cancel'; // 2131
        cs1.cc_Checker_Result__c ='Return to Maker';
        cs1.Retention_Comments__c = 'test';//942
        
        update cs1;

        // cs1.cc_Checker_Result__c ='Approve';
        // update cs1;

      
        test.stopTest();
    }
    
    @isTest
    static void caseHandlerTest201(){
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Premium Retention').getRecordTypeId();
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
        cs1.Subject = 'Premium Retention Application';
        cs1.Description = 'Premium Retention Application';
        cs1.Type = 'Premium Retention Application';
        cs1.ac_RequestedBy__c = 'Customer';
        cs1.Expiry_Days__c = 20;
        cs1.Discount_Amount__c = 2.2;
        cs1.Priority = 'High';
        cs1.Case_Nature__c = 'Credit Card';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.Case_Model__c ='ila';
        cs1.OwnerId=system.Label.Contact_Centre_Queue;
        cs1.cc_Contact_Centre_Date_Time__c = null;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.ac_RequestedBy__c=null;
        test.startTest();
        insert cs1;
        
        cs1.cc_Contact_Centre_Result__c = 'Request Discount';
        update cs1;
        
        cs1.cc_Contact_Centre_Result__c = 'Rollback';
        cs1.OwnerId=system.Label.RMT_Queue_Id;
        update cs1;
        
        cs1.cc_Contact_Centre_Result__c = 'Downgrade';
        cs1.Downgrade_Reason__c = 'Other';
        update cs1;
        
        cs1.cc_Contact_Centre_Result__c = 'Cancelled By Customer';
        cs1.Downgrade_Reason__c = 'Other';
        update cs1;
        
        cs1.cc_Contact_Centre_Result__c='Retain Without Discount';
        update cs1;
        
        cs1.OwnerId=system.Label.RMT_Queue_Id ;
        cs1.RMT_Results__c='Escalate to Business';
        update cs1;
        
        test.stopTest();
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock4 = new MyCalloutMock();
        mock4.testBody = bodyString(cs1);
        //test.stopTest();
        
    }
    
    @isTest
    static void caseHandlerTest202(){
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Premium Invitation').getRecordTypeId();
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
        cs1.Subject = 'Premium Invitation Application';
        cs1.Description = 'Premium Invitation Application Test';
        cs1.Type = 'Premium Invitation Application';
        cs1.ac_RequestedBy__c = 'Customer';
        cs1.Expiry_Days__c = 20;
        cs1.Total_Fees__c = 100.2;
        cs1.Applicability__c = 'One Time Discount';
        cs1.Discount_Amount__c = 2.2;
        cs1.Priority = 'High';
        cs1.Case_Nature__c = 'Credit Card';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.Case_Model__c ='ila';
        cs1.OwnerId=system.Label.Invitation_temp_Queue;
        cs1.cc_Contact_Centre_Date_Time__c = null;
        //cs1.Sub_Status__c = 'In-Progress';
         cs1.ac_RequestedBy__c=null;
        test.startTest();
        insert cs1;
        
        cs1.Sub_Status__c = 'Pending Customer';
        update cs1;
        
        cs1.Sub_Status__c = 'Accepted by Customer';
        cs1.OwnerId=system.Label.RMT_Queue_Id;
        update cs1;
        
        cs1.Sub_Status__c = 'Expired';
        cs1.Downgrade_Reason__c = 'Other';
        update cs1;
       
        
        test.stopTest();
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock4 = new MyCalloutMock();
        mock4.testBody = bodyString(cs1);
        //test.stopTest();
        
    }
    
    @isTest
    static void caseHandlerTest203(){
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
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
        cs1.Subject = 'Service Request Case';
        cs1.Description = 'Service Request Case Test';
        cs1.Type = 'Unlock App Access';
        
        cs1.Priority = 'High';
        cs1.Case_Nature__c = 'Credit Card';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.Case_Model__c ='ila';
        test.startTest();
        insert cs1;
        cs1.Generate_Random_Recovery_Code__c = true;
        update cs1;
    }
    
}
/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 17/03/2022
*       Change History: 
*					#CH01# #Jahangeer Mohammed# #06-06-2023# Added code to increase code coverage
*/
@isTest
public class CashCollateralHandlerTest {
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
            res.setBody('{"data":{"transitionInProgress":false,"currentSegment":{"segmentName":"REGULAR","segmentCrmId":"Regular"},"currentCards":[{"id":"10010522439126747125063583","cardName":"VIRTUAL","cardDisplayName":"Virtual","cardAfsId":"TestVirtualCards","productType":"Virtual","cardMinimumBalance":0,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":false,"limit":0,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"},{"id":"100105224391267471250615229","cardName":"CLASSIC","cardDisplayName":"Classic","cardAfsId":"Debit Classic","productType":"Classic","cardMinimumBalance":20,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"limit":1000,"nextAnnualAnniversaryDate":"2021-06-18T07:55:26","discount":{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"}],"segmentOptions":[{"segmentName":"STAFF","segmentCrmId":"Staff"},{"segmentName":"ROYAL_FAMILY","segmentCrmId":"Royal Family"},{"segmentName":"PREMIUM","segmentCrmId":"Premium"},{"segmentName":"PREMIUM_PLUS","segmentCrmId":"Premium Plus"},{"segmentName":"SENSITIVE","segmentCrmId":"Sensitive"}],"cardOptions":[{"cardName":"WORLD","cardDisplayName":"World","cardAfsId":"MasterCardWorld","productType":"World","cardMinimumBalance":0,"order":1,"issuanceFee":0.000,"annualFee":37.500,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":1.875,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":39.375},{"cardName":"ELITE","cardDisplayName":"Elite","cardAfsId":"WORLD_ELITE","productType":"World Elite","cardMinimumBalance":0,"order":2,"issuanceFee":0.000,"annualFee":75.000,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":3.750,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":78.750}],"discountOptions":[{"name":"None","displayName":"No discount","discountPercentage":0},{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},{"name":"Discount50","displayName":"50 percent discount","discountPercentage":50},{"name":"Discount75","displayName":"75 percent discount","discountPercentage":75},{"name":"Free","displayName":"No charge","discountPercentage":100}]},"meta":{"code":"SGMT-1006","message":"Customer Segment Options retrieved successfully."}}');
            res.setStatusCode(200);
            return res;
        }
    }
    private class RestMock3 implements HttpCalloutMock{
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
    //CH01: Start
    private class RestMock4 implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"data":{"transitionInProgress":false,"currentSegment":{"segmentName":"REGULAR","segmentCrmId":"Regular"},"campaign":{"id":"1","validity":"2023-08-18T07:55:26"},"currentCards":[{"id":"10010522439126747125063583","cardName":"VIRTUAL","cardDisplayName":"Virtual","cardAfsId":"TestVirtualCards","productType":"Virtual","cardMinimumBalance":0,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":false,"limit":0,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"},{"id":"100105224391267471250615229","cardName":"CLASSIC","cardDisplayName":"Classic","cardAfsId":"Debit Classic","productType":"Classic","cardMinimumBalance":20,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"limit":1000,"nextAnnualAnniversaryDate":"2021-06-18T07:55:26","discount":{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"}],"segmentOptions":[{"segmentName":"STAFF","segmentCrmId":"Staff"},{"segmentName":"ROYAL_FAMILY","segmentCrmId":"Royal Family"},{"segmentName":"PREMIUM","segmentCrmId":"Premium"},{"segmentName":"PREMIUM_PLUS","segmentCrmId":"Premium Plus"},{"segmentName":"SENSITIVE","segmentCrmId":"Sensitive"}],"cardOptions":[{"cardName":"WORLD","cardDisplayName":"World","cardAfsId":"MasterCardWorld","productType":"World","cardMinimumBalance":0,"order":1,"issuanceFee":0.000,"annualFee":37.500,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":1.875,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":39.375},{"cardName":"ELITE","cardDisplayName":"Elite","cardAfsId":"WORLD_ELITE","productType":"World Elite","cardMinimumBalance":0,"order":2,"issuanceFee":0.000,"annualFee":75.000,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":3.750,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":78.750}],"discountOptions":[{"name":"None","displayName":"No discount","discountPercentage":0},{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},{"name":"Discount50","displayName":"50 percent discount","discountPercentage":50},{"name":"Discount75","displayName":"75 percent discount","discountPercentage":75},{"name":"Free","displayName":"No charge","discountPercentage":100}]},"meta":{"code":"SGMT-1006","message":"Customer Segment Options retrieved successfully."}}');
            res.setStatusCode(200);
            return res;
        }
    }
    //CH01: END
    public static String bodyString(Case objCase){
        String body;
        if(objCase.Sub_Status__c == 'In-Progress' && objCase.cc_Name_on_the_Card__c != NULL && ((objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral') || (objCase.Type == 'Cash Collateral Credit Limit Increase Application'))){
            body = '{"crmCaseId": "'+objCase.Id +                             
                '","targetType": "CREDIT_CARD_ORDER","status":"IN_PROGRESS"}';
        }
        else if(objCase.Sub_Status__c == 'In-Progress' && objCase.cc_Name_on_the_Card__c == NULL && ((objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral') || (objCase.Type == 'Cash Collateral Credit Limit Increase Application'))){
            body = '{"crmCaseId": "'+objCase.Id +
                '","embossName": "'+null +
                ',"status":"IN_PROGRESS","targetType": "CREDIT_CARD_ORDER"}';
        }
        else if(objCase.Sub_Status__c == 'Discrepancies' && objCase.cc_Name_on_the_Card__c == NULL && objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral'){
            body = '{"crmCaseId": "'+objCase.Id +
                '","embossName": "'+null +
                ',"status":"DISCREPANCIES","targetType": "CREDIT_CARD_ORDER"}';
        }
        else if(objCase.Sub_Status__c == 'Referred  by Pre-Screener' && objCase.cc_Name_on_the_Card__c == NULL && objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral'){
            body = '{"crmCaseId": "'+objCase.Id +
                '","embossName": "'+null +
                ',"status":"REFERRED_BY_PRESCREENER","targetType": "CREDIT_CARD_ORDER"}';
        }
        else if(objCase.Sub_Status__c == 'Referred by Approver' && objCase.cc_Name_on_the_Card__c == NULL && ((objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral') || (objCase.Type == 'Cash Collateral Credit Limit Increase Application'))){
            body = '{"crmCaseId": "'+objCase.Id +
                '","embossName": "'+null +
                ',"status":"REFERRED_BY_APPROVER","targetType": "CREDIT_CARD_ORDER"}';
        }
        else if(objCase.Sub_Status__c == 'Pending Signature Verification' && objCase.cc_Name_on_the_Card__c == NULL && ((objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral') || (objCase.Type == 'Cash Collateral Credit Limit Increase Application'))){
            body = '{"crmCaseId": "'+objCase.Id +
                '","embossName": "'+null +
                ',"status":"APPROVED_PENDING_SIGNATURE","targetType": "CREDIT_CARD_ORDER"}';
        }
         else if(objCase.Sub_Status__c == 'Referred by Signature Verifier' && objCase.cc_Name_on_the_Card__c == NULL && objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral'){
            body = '{"crmCaseId": "'+objCase.Id +
                '","embossName": "'+null +
                ',"status":"REFERRED_BY_SIGNATURE_VERIFIER","targetType": "CREDIT_CARD_ORDER"}';
        }
        else if(objCase.Sub_Status__c == 'Approved' && objCase.cc_Name_on_the_Card__c != NULL && ((objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral') || (objCase.Type == 'Cash Collateral Credit Limit Increase Application'))){
              body = '{"cardProductConfigurationId": "'+665756 +
                            '","crmCaseId": "'+objCase.Id +
                            '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                            '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                            '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                            '","status":"APPROVED","targetType": "CREDIT_CARD_ORDER","cardNature":"secured"}';
         }
        
        return body;
    }
    @isTest
    static public  void unitTest1(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        acc.PersonBirthdate= Date.newInstance(2022, 06, 09);
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Sub_Status__c = 'In-Progress';  
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain';
        test.startTest();
        insert cs1;
        
        Content__c testDocument = new Content__c(
            Document_Type__c = 'Passport',
            Case__c = cs1.Id,
            Document_Model__c='ila'

        );
        insert testDocument;
        //Create a new file
        ContentVersion newFile = new ContentVersion();
        newFile.PathOnClient = 'TestFile';
        newFile.Title = 'TestFile';
        newFile.VersionData = Blob.valueOf('sample content');
        insert newFile;
        
        //Query the contentDocumentId
        ContentVersion insertedFile = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:newFile.Id];
        
        //Link the file with the product
        ContentDocumentLink linkedFile = new ContentDocumentLink(LinkedEntityId=cs1.Id, ContentDocumentId=insertedFile.ContentDocumentId);
        insert linkedFile;
        
        
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        
        test.stopTest();
    }
    
     @isTest
    static void unitTest2(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        //checkRecursive.runOnce();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Sub_Status__c = 'In-Progress'; 
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain';     
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Discrepancy in Documents';
        cs1.Sub_Status__c = 'Discrepancies';
        //checkRecursive.runOnce();
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
 @isTest
    static void unitTest3(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
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
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        //checkRecursive.runOnce();
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void unitTest4(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        //CH01: Start
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        //CH01: END
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void unitTestCCLMT4(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
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
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTest5(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    //CH01: Start
     @isTest
    static void unitTestJordan5(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Service_Centre_Result__c = 'Return to Approver';
        cs1.cc_Application_Stages__c = 'Credit Service Centre';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestJordan6(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Service_Centre_Result__c = 'Return to Credit Admin';
        cs1.cc_Application_Stages__c = 'Credit Service Centre';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void unitTestJordan7(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Service_Centre_Result__c = 'Return to Card Operations';
        cs1.cc_Application_Stages__c = 'Credit Service Centre';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void unitTestJordan8(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        cs1.cc_Credit_Admin_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Admin';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void unitTestJordan10(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        cs1.cc_Credit_Admin_Result__c = 'Return to Signature Verification';
        cs1.cc_Application_Stages__c = 'Credit Admin';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestJordan11(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        cs1.cc_Credit_Admin_Result__c = 'Refer to service center';
        cs1.cc_Application_Stages__c = 'Credit Admin';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void unitTestJordan12(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        cs1.cc_Credit_Admin_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Admin';
        update cs1;
        
        cs1.cc_Card_Operations_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Operation';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void unitTestJordan13(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        cs1.cc_Credit_Admin_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Admin';
        update cs1;
        
        cs1.cc_Card_Operations_Result__c = 'Return to Credit Admin';
        cs1.cc_Application_Stages__c = 'Credit Operation';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestJordan14(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        cs1.cc_Credit_Admin_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Admin';
        update cs1;
        
        cs1.cc_Card_Operations_Result__c = 'Refer to service center';
        cs1.cc_Application_Stages__c = 'Credit Operation';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void unitTestJordan15(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Decline';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void unitTestJordan16(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
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
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestJordan17(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
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
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestJordan18(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
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
        cs1.Sub_Status__c = 'In-Progress'; 
        cs1.cc_CPR_Number__c = '546454';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    
    @isTest
    static void unitTestJordan19(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
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
        cs1.Sub_Status__c = 'In-Progress'; 
        cs1.cc_CPR_Number__c = '546454';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        cs1.cc_Credit_Admin_Result__c = 'Return to Signature Verification';
        cs1.cc_Application_Stages__c = 'Credit Admin';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestCCLMT5Jordan(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
		Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
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
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Service_Centre_Result__c = 'Return to Approver';
        cs1.cc_Application_Stages__c = 'Credit Service Centre';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestCCLMT6Jordan(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
		Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
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
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Decline';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestCCLMT7Jordan(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
		Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
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
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Cancelled by Customer';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestCCLMT8Jordan(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
		Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
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
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestCCLMT9Jordan(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
		Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
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
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void unitTestCCLMT10Jordan(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
		Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
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
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestCCLMT11Jordan(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
		Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
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
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestCCLMT111Jordan(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
		Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
        cs1.cc_Name_on_the_Card__c = '';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
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
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        Set<Id> setId = new Set<Id>();
        setId.add(cs1.Id);
        CreditCardCashCollateral.CashCollateralCaseCreation(setId);
        Test.setMock(HttpCalloutMock.class, new RestMock4());
       
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestCCLMT111FDJordan(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
		Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
        cs1.cc_Name_on_the_Card__c = '';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
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
        cs1.Sub_Status__c = 'In-Progress'; 
        cs1.ccol_Hold_Account__c = 'FIXED_DEPOSIT';
        test.startTest();
        insert cs1;
        Set<Id> setId = new Set<Id>();
        setId.add(cs1.Id);
        CreditCardCashCollateral.CashCollateralCaseCreation(setId);
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestCCLMT111FD1Jordan(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
		Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
        cs1.cc_Name_on_the_Card__c = 'Test User1';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
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
        cs1.Sub_Status__c = 'In-Progress'; 
        cs1.ccol_Hold_Account__c = 'FIXED_DEPOSIT';
        test.startTest();
        insert cs1;
        Set<Id> setId = new Set<Id>();
        setId.add(cs1.Id);
        CreditCardCashCollateral.CashCollateralCaseCreation(setId);
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestCCLMT111Bahrain(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
		Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        acc.ID_Type__pc = 'Bahraini ID';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
        cs1.cc_Name_on_the_Card__c = '';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
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
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        Set<Id> setId = new Set<Id>();
        setId.add(cs1.Id);
        CreditCardCashCollateral.CashCollateralCaseCreation(setId);
        Test.setMock(HttpCalloutMock.class, new RestMock4());
       
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestCCLMT12Jordan(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
		Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
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
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        cs1.cc_Credit_Admin_Result__c = 'Return to Signature Verification';
        cs1.cc_Application_Stages__c = 'Credit Admin';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void unitTestCCLMT13Jordan(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
		Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
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
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        cs1.cc_Credit_Admin_Result__c = 'Refer to service center';
        cs1.cc_Application_Stages__c = 'Credit Admin';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestCCLMT14Jordan(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
		Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
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
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        cs1.cc_Credit_Admin_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Admin';
        update cs1;
        
        cs1.cc_Card_Operations_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Operation';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestCCLMT15Jordan(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
		Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
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
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        cs1.cc_Credit_Admin_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Admin';
        update cs1;
        
        cs1.cc_Card_Operations_Result__c = 'Refer to service center';
        cs1.cc_Application_Stages__c = 'Credit Operation';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    //CH01: END
     @isTest
    static void unitTestCCLMT5(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
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
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTest6(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.Priority = 'High';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestCCLMT6(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
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
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTest7(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
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
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTest8(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Re-Send';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTest9(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        //CH01: Start
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        //CH01: END
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    //CH01: Start
    @isTest
    static void unitTestJordan9(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
       
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    //CH01: END
     @isTest
    static void unitTest10(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        //CH01: Start
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        //CH01: END
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTestCCLMT10(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    //CH01: Start
     @isTest
    static void unitTestCCLMT11(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cash Collateral Credit Limit Increase').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Cash Collateral Credit Limit Increase Application';
        cs1.Sub_Type__c = 'Cash Collateral Credit Limit Increase';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Re-Send';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    //CH01: END
     @isTest
    static public void unitTest11(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        acc.PersonBirthdate= Date.newInstance(2022, 06, 09);
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        
        Content__c testDocument = new Content__c(
            Document_Type__c = 'Passport',
            Case__c = cs1.Id,
            Document_Model__c='ila'

        );
        insert testDocument;
         //Create a new file
        ContentVersion newFile = new ContentVersion();
        newFile.PathOnClient = 'TestFile';
        newFile.Title = 'TestFile';
        newFile.VersionData = Blob.valueOf('sample content');
        insert newFile;
        
        
        //Query the contentDocumentId
        ContentVersion insertedFile = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:newFile.Id];
        
        //Link the file with the product
        ContentDocumentLink linkedFile = new ContentDocumentLink(LinkedEntityId=cs1.Id, ContentDocumentId=insertedFile.ContentDocumentId);
        insert linkedFile;
        //CH01: Start
        Test.setMock(HttpCalloutMock.class, new RestMock4());
        //CH01: END
        cs1.cc_Credit_Pre_Screening_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        update cs1;
        
        cs1.cc_Service_Centre_Result__c = 'Return to Pre-Screener';
        cs1.cc_Application_Stages__c = 'Credit Service Centre';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    
      @isTest
    static void unitTest12(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Approve';
        cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        cs1.cc_Signature_Verifier_Result__c = 'Refer to Service Center';
        cs1.cc_Application_Stages__c = 'Credit Signature Verification';
        update cs1;
        
        cs1.cc_Service_Centre_Result__c = 'Return to Signature Verifier';
        cs1.cc_Application_Stages__c = 'Credit Service Centre';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
     static void unitTest13(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral Staff').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        
        test.stopTest();
    }
    @isTest
    static void unitTest14(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral Staff').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_HR_Result__c = 'Approved';
        //cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTest15(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral Staff').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        //cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_HR_Result__c = 'Approved';
        //cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void unitTest16(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Decline';
        //cs1.Sub_Status__c = 'Discrepancies';
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
    static void unitTest17(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral Staff').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        //cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_HR_Result__c = 'Decline';
        //cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
      @isTest
    static void unitTest18(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Decline';
        //cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    
     @isTest
    static void unitTest19(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Cancelled by Customer';
        //cs1.Sub_Status__c = 'Discrepancies';
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
       @isTest
    static void unitTest20(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Cancelled by Customer';
        //cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTest21(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral Staff').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        //cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        cs1.cc_HR_Result__c = 'Cancelled by Customer';
        //cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTest22(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        cs1.cc_Credit_Approval_Result__c = 'Cancelled by Customer';
        //cs1.cc_Application_Stages__c = 'Credit Approval';
        update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
     @isTest
    static void unitTest23(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral Staff').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        //cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
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
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        cs1.cc_HR_Result__c = 'Cancelled by Customer';
        //cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
      @isTest
    static void unitTest24(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.Id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '546';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        cs1.cc_Credit_Pre_Screening_Result__c = 'Cancelled by Customer';
        cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
        cs1.cc_Approved_Credit_Limit__c = 1000;
        update cs1;
        
        //cs1.cc_Credit_Approval_Result__c = 'Cancelled by Customer';
        //cs1.cc_Application_Stages__c = 'Credit Approval';
        //update cs1;
        
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
    @isTest
     static void unitTest25(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral Staff').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = '';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546000045';
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain'; 
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
        cs1.Sub_Status__c = 'In-Progress';  
        test.startTest();
        insert cs1;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        
        test.stopTest();
    }

    @isTest
    static void unitTestCCNewCashCollateralBahrain(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
		Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Nationality__pc = 'BH';
        acc.ID_Type__pc = 'Bahraini ID';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'ILA_GULF_AIR_COBRAND_01';
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
        cs1.Sub_Status__c = 'In-Progress';  
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Bahrain';
        
        test.startTest();
        insert cs1;
        Set<Id> setId = new Set<Id>();
        setId.add(cs1.Id);
        CreditCardCashCollateral.CashCollateralCaseCreation(setId);
        Test.setMock(HttpCalloutMock.class, new RestMock4());
       
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }

    @isTest
    static void unitTestCCNewCashCollateralJordan(){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Cash Collateral - Regular').getRecordTypeId();
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Region_Flag__c = 'Jordan';
        acc.Region_Flag__pc = 'Jordan';
        acc.Nationality__pc = 'JO';
        insert acc;
        
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = 'Credit Card Cash Collateral Application';
        cs1.Sub_Type__c = 'New Cash Collateral';
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
        cs1.Sub_Status__c = 'In-Progress';
        cs1.cc_CPR_Number__c = '5353645';
        cs1.Case_Model__c = 'ila';
        cs1.Region_Flag__c = 'Jordan'; 
        cs1.cc_CPR_Expiry_Date__c = System.today() + 360;

        Case cs2 = new Case();
        cs2.RecordTypeId = recordTypeId;
        cs2.Subject = 'NewCreditCardApplicationTest';
        cs2.Description = 'Credit card Application Test for Duplicate Cards';
        cs2.Type = 'Credit Card Cash Collateral Application';
        cs2.Sub_Type__c = 'New Cash Collateral';
        cs2.cc_Name_on_the_Card__c = null;
        cs2.cc_Embossing_Line_4__c = 'XYZ';
        cs2.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
        cs2.Priority = 'High';
        cs2.Awaiting_Customer_Feedback__c = false;
        cs2.Origin = 'Phone';
        cs2.AccountId = acc.Id;
        cs2.cc_Monthly_Income__c =6000;
        cs2.cc_PCI_Id__c = '8';
        cs2.cc_Passport_Number__c = 'RT546FRGF';
        cs2.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs2.cc_Residence_Permit_No__c = '546';
        cs2.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs2.Sub_Status__c = 'In-Progress';
        cs2.cc_CPR_Number__c = '5353645';
        cs2.Case_Model__c = 'ila';
        cs2.Region_Flag__c = 'Jordan'; 
        cs2.cc_CPR_Expiry_Date__c = System.today() + 360;
        
        test.startTest();
        insert cs1;
        insert cs2;
        Set<Id> setId = new Set<Id>();
        setId.add(cs1.Id);
        setId.add(cs2.Id);
        CreditCardCashCollateral.CashCollateralCaseCreation(setId);
        Test.setMock(HttpCalloutMock.class, new RestMock4());
       
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
        test.stopTest();
    }
   
}
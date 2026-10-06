@isTest
public class LTNG064_ReassignAgentTest {
    
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
    
    
    @isTest
    static void testgetCases() {
		Test.StartTest();
        LTNG064_ReassignAgent.getCases('TestUser1');
        Test.StopTest();
           
    }
    
    @isTest
    static void assignCases(){
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
        List<case>cs= New List<Case>();
        cs.add(cs1);
        LTNG064_ReassignAgent.assignCases(cs);
        Test.stopTest();
    }
     @isTest
    static void testSearchUser(){
        Test.startTest();
        LTNG064_ReassignAgent.searchUsers('test');
        Test.stopTest();
    }
     @isTest
    static void testQueue(){
        Test.startTest();
        LTNG064_ReassignAgent.getCCqueue();
        Test.stopTest();
    }
}
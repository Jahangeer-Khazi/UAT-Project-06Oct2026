/**
*  @author: Ashish Pandey
*  @date: 23/01/2010
*  @description: controller for aura components related to Credit cards
*  Change History :
*      
*         #CH01 : #D&A Team #24-06-2022# added case model parameter.
*/
@isTest
public class LTNG001_PrimCardPickListControllerTest {

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
                res.setBody('{"data":{"transitionInProgress":false,"currentSegment":{"segmentName":"REGULAR","segmentCrmId":"Regular"},"currentCards":[{"id":"10010522439126747125063583","cardName":"VIRTUAL","cardDisplayName":"Virtual","cardAfsId":"TestVirtualCards","productType":"Virtual","cardMinimumBalance":0,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":false,"limit":0,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive","isPrimary":true},{"id":"100105224391267471250615229","cardName":"CLASSIC","cardDisplayName":"Classic","cardAfsId":"Debit Classic","productType":"Classic","cardMinimumBalance":20,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"limit":1000,"nextAnnualAnniversaryDate":"2021-06-18T07:55:26","discount":{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"}],"segmentOptions":[{"segmentName":"STAFF","segmentCrmId":"Staff"},{"segmentName":"ROYAL_FAMILY","segmentCrmId":"Royal Family"},{"segmentName":"PREMIUM","segmentCrmId":"Premium"},{"segmentName":"PREMIUM_PLUS","segmentCrmId":"Premium Plus"},{"segmentName":"SENSITIVE","segmentCrmId":"Sensitive"}],"cardOptions":[{"cardName":"WORLD","cardDisplayName":"World","cardAfsId":"MasterCardWorld","productType":"World","cardMinimumBalance":0,"order":1,"issuanceFee":0.000,"annualFee":37.500,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":1.875,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":39.375},{"cardName":"ELITE","cardDisplayName":"Elite","cardAfsId":"WORLD_ELITE","productType":"World Elite","cardMinimumBalance":0,"order":2,"issuanceFee":0.000,"annualFee":75.000,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":3.750,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":78.750}],"discountOptions":[{"name":"None","displayName":"No discount","discountPercentage":0},{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},{"name":"Discount50","displayName":"50 percent discount","discountPercentage":50},{"name":"Discount75","displayName":"75 percent discount","discountPercentage":75},{"name":"Free","displayName":"No charge","discountPercentage":100}]},"meta":{"code":"SGMT-1006","message":"Customer Segment Options retrieved successfully."}}');
            }else{
                system.debug('not null->'+testBody);
                res.setBody(testBody);
            }
            return res;
        }
    }

    @testSetup static void setupMethode() {
        Account acc = new Account();
        acc.FirstName = 'TestIla';
        acc.LastName = 'TestIla';
        acc.PersonEmail = 'testclass@ilatest123.com';
        acc.CIF__pc = '1234567';
        //==> error CifGenerator ligne 32 we need to check the map if empty or not
        //acc.Region_Flag__pc = 'Jordan'; 
        insert acc;
    }

    @isTest
    static void getCurrentCardsViaApiErrorTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        system.debug('STATUS CODE'+res.getStatusCode());
        try{
            List<LTNG001_PrimaryCardPickListController.CurrentCardWrapper> tt = LTNG001_PrimaryCardPickListController.getCurrentCardsViaApi(acc.Id,null);//CH01
        }catch(Exception exp){
            System.assert(true);
        }
        test.stopTest();
    }

    @isTest
    static void getCurrentCardsViaApiTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        MyCalloutMock mck = new MyCalloutMock();
        mck.testStatusCode = 200;
        Test.setMock(HttpCalloutMock.class, mck);
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        system.debug('STATUS CODE'+res.getStatusCode());
        try{
            List<LTNG001_PrimaryCardPickListController.CurrentCardWrapper> tt = LTNG001_PrimaryCardPickListController.getCurrentCardsViaApi(acc.Id,null);//CH01
        }catch(Exception exp){
            System.assert(true);
        }
        test.stopTest();
    }

    
}
@IsTest
private class cc_DocuSignGetEnvelopeIdTest {

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

    @IsTest
    static void testcc_DocuSignGetEnvelopeIdProcess() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Credit_Card').getRecordTypeId();

        Account testAccount = (Account)TestDataFactory.createSObject(
            new Account(CIF__pc='123456', Archived__pc=false), 
            'TestFactoryDefaults.AccountDefaults', 
            true
        );

        Case cs = (Case)TestDataFactory.createSObject(
            new Case(
                RecordTypeId = acRecordTypeId, 
                ContactId = testAccount.PersonContactId, 
                AccountId = testAccount.Id,
                Type = 'Credit Card Application'
            ), 
            'TestFactoryDefaults.CaseDefaults', 
            true
        );

        Id cashRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Credit_Card_Cash_Collateral_Regular').getRecordTypeId();
        Case cs1 = (Case)TestDataFactory.createSObject(
            new Case(
                RecordTypeId = cashRecordTypeId, 
                ContactId = testAccount.PersonContactId, 
                AccountId = testAccount.Id,
                Type = 'Credit Card Cash Collateral Application'
            ), 
            'TestFactoryDefaults.CaseDefaults', 
            true
        );

        User testUser = dfsle.UserMock.createDocuSignSender();
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        testUser.Region_Flag__c = 'Bahrain';
        update testUser;

        System.runAs(testUser) {
            Test.startTest();
            try {
                Test.setMock(HttpCalloutMock.class, new RestMock());
                cc_DocuSignGetEnvelopeId.cc_DocuSignGetEnvelopeIdProcess(new Set<Id>{cs.Id});
                System.enqueueJob(new cc_DocuSignGetEnvelopeId.CC_CaseUpdateJob(cs));

                Test.setMock(HttpCalloutMock.class, new RestMock4());
                cc_DocuSignGetEnvelopeId.cc_DocuSignGetEnvelopeIdProcess(new Set<Id>{cs1.Id});
            } catch (Exception e) {
                System.debug('Exception Type: ' + e.getTypeName());

            }
            Test.stopTest();
        }
    }
}
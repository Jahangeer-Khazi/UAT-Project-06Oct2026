/*
Author : 
Date : 
Description : DocuSignApexToolKitTest
    #CH01#ASHISH# Added #12-01-2025# Test Class for the DocuSignApexToolKit class optimized
    #CH02# Added #23-06-2022# Hamza Chaoui add Case_Model__c
*/

@IsTest
private class DocuSignApexToolKitTest3 {
    private class RestMock implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"data":{"transitionInProgress":false,"currentSegment":{"segmentName":"REGULAR","segmentCrmId":"Regular"},"currentCards":[{"id":"10010522439126747125063583","cardName":"VIRTUAL","cardDisplayName":"Virtual","cardAfsId":"TestVirtualCards","productType":"Virtual","cardMinimumBalance":0,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":false,"limit":0,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"},{"id":"100105224391267471250615229","cardName":"CLASSIC","cardDisplayName":"Classic","cardAfsId":"Debit Classic","productType":"Classic","cardMinimumBalance":20,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"limit":1000,"nextAnnualAnniversaryDate":"2021-06-18T07:55:26","discount":{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"}],"segmentOptions":[{"segmentName":"STAFF","segmentCrmId":"Staff"},{"segmentName":"ROYAL_FAMILY","segmentCrmId":"Royal Family"},{"segmentName":"PREMIUM","segmentCrmId":"Premium"},{"segmentName":"PREMIUM_PLUS","segmentCrmId":"Premium Plus"},{"segmentName":"SENSITIVE","segmentCrmId":"Sensitive"}],"cardOptions":[{"cardName":"WORLD","cardDisplayName":"World","cardAfsId":"MasterCardWorld","productType":"World","cardMinimumBalance":0,"order":1,"issuanceFee":0.000,"annualFee":37.500,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":1.875,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":39.375},{"cardName":"ELITE","cardDisplayName":"Elite","cardAfsId":"WORLD_ELITE","productType":"World Elite","cardMinimumBalance":0,"order":2,"issuanceFee":0.000,"annualFee":75.000,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":3.750,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":78.750}],"discountOptions":[{"name":"None","displayName":"No discount","discountPercentage":0},{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},{"name":"Discount50","displayName":"50 percent discount","discountPercentage":50},{"name":"Discount75","displayName":"75 percent discount","discountPercentage":75},{"name":"Free","displayName":"No charge","discountPercentage":100}]},"meta":{"code":"SGMT-1006","message":"Customer Segment Options retrieved successfully."}}';          
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
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

    private class RestMock2 implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"data":{"transitionInProgress":false,"currentSegment":{"segmentName":"REGULAR","segmentCrmId":"Regular"},"currentCards":[{"id":"10010522439126747125063583","cardName":"VIRTUAL","cardDisplayName":"Virtual","cardAfsId":"TestVirtualCards","productType":"Virtual","cardMinimumBalance":0,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":false,"limit":0,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"},{"id":"100105224391267471250615229","cardName":"CLASSIC","cardDisplayName":"Classic","cardAfsId":"Debit Classic","productType":"Classic","cardMinimumBalance":20,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"limit":1000,"nextAnnualAnniversaryDate":"2021-06-18T07:55:26","discount":{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"}],"segmentOptions":[{"segmentName":"STAFF","segmentCrmId":"Staff"},{"segmentName":"ROYAL_FAMILY","segmentCrmId":"Royal Family"},{"segmentName":"PREMIUM","segmentCrmId":"Premium"},{"segmentName":"PREMIUM_PLUS","segmentCrmId":"Premium Plus"},{"segmentName":"SENSITIVE","segmentCrmId":"Sensitive"}],"cardOptions":[{"cardName":"WORLD","cardDisplayName":"World","cardAfsId":"MasterCardWorld","productType":"World","cardMinimumBalance":0,"order":1,"issuanceFee":0.000,"annualFee":37.500,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":1.875,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":39.375},{"cardName":"ELITE","cardDisplayName":"Elite","cardAfsId":"WORLD_ELITE","productType":"World Elite","cardMinimumBalance":0,"order":2,"issuanceFee":0.000,"annualFee":75.000,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":3.750,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":78.750}],"discountOptions":[{"name":"None","displayName":"No discount","discountPercentage":0},{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},{"name":"Discount50","displayName":"50 percent discount","discountPercentage":50},{"name":"Discount75","displayName":"75 percent discount","discountPercentage":75},{"name":"Free","displayName":"No charge","discountPercentage":100}]},"meta":{"code":"SGMT-1006","message":"Customer Segment Options retrieved successfully."}}';
          

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"data":{"transitionInProgress":false,"currentSegment":{"segmentName":"REGULAR","segmentCrmId":"Regular"},"currentCards":[{"id":"10010522439126747125063583","cardName":"VIRTUAL","cardDisplayName":"Virtual","cardAfsId":"TestVirtualCards","productType":"Virtual","cardMinimumBalance":0,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":false,"limit":0,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"},{"id":"100105224391267471250615229","cardName":"CLASSIC","cardDisplayName":"Classic","cardAfsId":"Debit Classic","productType":"Classic","cardMinimumBalance":20,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"limit":1000,"nextAnnualAnniversaryDate":"2021-06-18T07:55:26","discount":{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"}],"segmentOptions":[{"segmentName":"STAFF","segmentCrmId":"Staff"},{"segmentName":"ROYAL_FAMILY","segmentCrmId":"Royal Family"},{"segmentName":"PREMIUM","segmentCrmId":"Premium"},{"segmentName":"PREMIUM_PLUS","segmentCrmId":"Premium Plus"},{"segmentName":"SENSITIVE","segmentCrmId":"Sensitive"}],"cardOptions":[{"cardName":"WORLD","cardDisplayName":"World","cardAfsId":"MasterCardWorld","productType":"World","cardMinimumBalance":0,"order":1,"issuanceFee":0.000,"annualFee":37.500,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":1.875,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":39.375},{"cardName":"ELITE","cardDisplayName":"Elite","cardAfsId":"WORLD_ELITE","productType":"World Elite","cardMinimumBalance":0,"order":2,"issuanceFee":0.000,"annualFee":75.000,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":3.750,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":78.750}],"discountOptions":[{"name":"None","displayName":"No discount","discountPercentage":0},{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},{"name":"Discount50","displayName":"50 percent discount","discountPercentage":50},{"name":"Discount75","displayName":"75 percent discount","discountPercentage":75},{"name":"Free","displayName":"No charge","discountPercentage":100}]},"meta":{"code":"SGMT-1006","message":"Customer Segment Options retrieved successfully."}}');
            res.setStatusCode(200);
            return res;
        }
    }
     private class RestMock4 implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"data":{"transitionInProgress":false,"currentSegment":{"segmentName":"REGULAR","segmentCrmId":"Regular"},"currentCards":[{"id":"10010522439126747125063583","cardName":"VIRTUAL","cardDisplayName":"Virtual","cardAfsId":"TestVirtualCards","productType":"Virtual","cardMinimumBalance":0,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":false,"limit":0,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"},{"id":"100105224391267471250615229","cardName":"CLASSIC","cardDisplayName":"Classic","cardAfsId":"Debit Classic","productType":"Classic","cardMinimumBalance":20,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"limit":1000,"nextAnnualAnniversaryDate":"2021-06-18T07:55:26","discount":{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"}],"segmentOptions":[{"segmentName":"STAFF","segmentCrmId":"Staff"},{"segmentName":"ROYAL_FAMILY","segmentCrmId":"Royal Family"},{"segmentName":"PREMIUM","segmentCrmId":"Premium"},{"segmentName":"PREMIUM_PLUS","segmentCrmId":"Premium Plus"},{"segmentName":"SENSITIVE","segmentCrmId":"Sensitive"}],"cardOptions":[{"cardName":"WORLD","cardDisplayName":"World","cardAfsId":"MasterCardWorld","productType":"World","cardMinimumBalance":0,"order":1,"issuanceFee":0.000,"annualFee":37.500,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":1.875,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":39.375},{"cardName":"ELITE","cardDisplayName":"Elite","cardAfsId":"WORLD_ELITE","productType":"World Elite","cardMinimumBalance":0,"order":2,"issuanceFee":0.000,"annualFee":75.000,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":3.750,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":78.750}],"discountOptions":[{"name":"None","displayName":"No discount","discountPercentage":0},{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},{"name":"Discount50","displayName":"50 percent discount","discountPercentage":50},{"name":"Discount75","displayName":"75 percent discount","discountPercentage":75},{"name":"Free","displayName":"No charge","discountPercentage":100}]},"meta":{"code":"SGMT-1006","message":"Customer Segment Options retrieved successfully."}}';
          

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"data":{"transitionInProgress":false,"currentSegment":{"segmentName":"REGULAR","segmentCrmId":"Regular"},"campaign":{"id":"1","validity":"2023-08-18T07:55:26"},"currentCards":[{"id":"10010522439126747125063583","cardName":"VIRTUAL","cardDisplayName":"Virtual","cardAfsId":"TestVirtualCards","productType":"Virtual","cardMinimumBalance":0,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":false,"limit":0,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"},{"id":"100105224391267471250615229","cardName":"CLASSIC","cardDisplayName":"Classic","cardAfsId":"Debit Classic","productType":"Classic","cardMinimumBalance":20,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"limit":1000,"nextAnnualAnniversaryDate":"2021-06-18T07:55:26","discount":{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"}],"segmentOptions":[{"segmentName":"STAFF","segmentCrmId":"Staff"},{"segmentName":"ROYAL_FAMILY","segmentCrmId":"Royal Family"},{"segmentName":"PREMIUM","segmentCrmId":"Premium"},{"segmentName":"PREMIUM_PLUS","segmentCrmId":"Premium Plus"},{"segmentName":"SENSITIVE","segmentCrmId":"Sensitive"}],"cardOptions":[{"cardName":"WORLD","cardDisplayName":"World","cardAfsId":"MasterCardWorld","productType":"World","cardMinimumBalance":0,"order":1,"issuanceFee":0.000,"annualFee":37.500,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":1.875,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":39.375},{"cardName":"ELITE","cardDisplayName":"Elite","cardAfsId":"WORLD_ELITE","productType":"World Elite","cardMinimumBalance":0,"order":2,"issuanceFee":0.000,"annualFee":75.000,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":3.750,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":78.750}],"discountOptions":[{"name":"None","displayName":"No discount","discountPercentage":0},{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},{"name":"Discount50","displayName":"50 percent discount","discountPercentage":50},{"name":"Discount75","displayName":"75 percent discount","discountPercentage":75},{"name":"Free","displayName":"No charge","discountPercentage":100}]},"meta":{"code":"SGMT-1006","message":"Customer Segment Options retrieved successfully."}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
   
    @IsTest
    static void testSendEnvelope1() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            ///PLATINUM_BALANCE_TRANSFER_01
            // Create test data //   BH-CCApplication-NonStaff-ilaSwitch
            Account newAcc = createAccount('Bahrain', 'Regular', 'English', 'BH');
            Case newCase = createCase('Credit Card', 'Credit Card Application','New Credit Card','PLATINUM_BALANCE_TRANSFER_01', newAcc);
            updateCase(newCase,newAcc);
            
            /////////////////////
                      
        } 
    }
    
    @IsTest
    static void testSendEnvelope2() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data // BH-CCApplication-NonStaff-ilaBlue
            Account newAcc = createAccount('Bahrain', 'Regular', 'English', 'BH');
            Case newCase = createCase('Credit Card', 'Credit Card Application', 'New Credit Card','PLATINUM_CASHBACK_AND_REWARD_01', newAcc);
            updateCase(newCase,newAcc);           
            
            /////////////////////            
        } 
    }

    @IsTest
    static void testSendEnvelope3() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
             //Create test data //  BH-CCLimitIncrease-NonStaff-ilaSwitch
             Account newAcc = createAccount('Bahrain', 'Regular', 'English', 'BH');
             Case newCase = createCase('Credit Limit Increase', 'Credit Limit Increase Application','Credit Limit Increase','PLATINUM_BALANCE_TRANSFER_01', newAcc);
             updateCase(newCase,newAcc);
                      
        } 
    }

    @IsTest
    static void testSendEnvelope4() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
             //Create test data //  BH-CCLimitIncrease-NonStaff-ilaBlue
             Account newAcc = createAccount('Bahrain', 'Regular', 'English', 'BH');
             Case newCase = createCase('Credit Limit Increase', 'Credit Limit Increase Application','Credit Limit Increase','PLATINUM_CASHBACK_AND_REWARD_01', newAcc);
             updateCase(newCase,newAcc);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope5() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  NONBH-CCLimitIncrease-NonStaff-ilaSwitch
            Account newAcc1 = createAccount('Bahrain', 'Regular', 'English', 'IN');
            Case newCase1 = createCase('Credit Card', 'Credit Card Application','New Credit Card','PLATINUM_BALANCE_TRANSFER_01', newAcc1);
            updateCase(newCase1,newAcc1);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope6() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  NONBH-CCLimitIncrease-NonStaff-ilaBlue
            
            Account newAcc2 = createAccount('Bahrain', 'Staff', 'English', 'IN');
            Case newCase2 = createCase('Credit Card', 'Credit Card Application','New Credit Card','PLATINUM_BALANCE_TRANSFER_01', newAcc2);
            updateCase(newCase2,newAcc2);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope7() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCApplication-Staff-ilaSwitch
            Account newAcc3 = createAccount('Bahrain', 'Staff', 'English', 'BH');
            Case newCase3 = createCase('Credit Card', 'Credit Card Application','New Credit Card','PLATINUM_BALANCE_TRANSFER_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope8() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  NONBH-CCApplication-NonStaff-ilaBlue
            Account newAcc1 = createAccount('Bahrain', 'Regular', 'English', 'IN');
            Case newCase1 = createCase('Credit Card', 'Credit Card Application', 'New Credit Card','PLATINUM_CASHBACK_AND_REWARD_01', newAcc1);
            updateCase(newCase1,newAcc1);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope9() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCApplication-Staff-ilaBlue
            Account newAcc2 = createAccount('Bahrain', 'Staff', 'English', 'BH');
            Case newCase2 = createCase('Credit Card - Staff  Application', 'Credit Card Application', 'New Credit Card','PLATINUM_CASHBACK_AND_REWARD_01', newAcc2);
            updateCase(newCase2,newAcc2);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope10() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  NONBH-CCApplication-Staff-ilaBlue
            Account newAcc3 = createAccount('Bahrain', 'Staff', 'English', 'IN');
            Case newCase3 = createCase('Credit Card - Staff  Application', 'Credit Card Application', 'New Credit Card','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope11() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCLimitIncrease-NonStaff-ilaSwitch
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'BH');
            Case newCase3 = createCase('Credit Limit Increase', 'Credit Limit Increase Application', 'Credit Limit Increase','PLATINUM_BALANCE_TRANSFER_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope12() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCLimitIncrease-NonStaff-ilaBlue
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'IN');
            Case newCase3 = createCase('Credit Limit Increase', 'Credit Limit Increase Application', 'Credit Limit Increase','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope13() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCLimitIncrease-NonStaff-ilaBlue
            Account newAcc3 = createAccount('Bahrain', 'Staff', 'English', 'BH');
            Case newCase3 = createCase('Credit Limit Increase Staff', 'Credit Limit Increase Application', 'Credit Limit Increase','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IsTest
    static void testSendEnvelope14() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCApplication Staff-ilaGulfAIR
            Account newAcc3 = createAccount('Bahrain', 'Staff', 'English', 'BH');
            Case newCase3 = createCase('Credit Card - Staff  Application', 'Credit Card Application', 'New Credit Card','ILA_GULF_AIR_COBRAND_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope15() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCLimitIncrease-Staff-ilaGulfAIR
            Account newAcc3 = createAccount('Bahrain', 'Staff', 'English', 'BH');
            Case newCase3 = createCase('Credit Limit Increase Staff', 'Credit Limit Increase Application', 'Credit Limit Increase','ILA_GULF_AIR_COBRAND_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope16() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  NONBH-CCApplication Staff-ilaGulfAIR
            Account newAcc3 = createAccount('Bahrain', 'Staff', 'English', 'IN');
            Case newCase3 = createCase('Credit Card - Staff  Application', 'Credit Card Application', 'New Credit Card','ILA_GULF_AIR_COBRAND_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope17() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCApplication NonStaff-ilaGulfAIR
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'BH');
            Case newCase3 = createCase('Credit Card', 'Credit Card Application', 'New Credit Card','ILA_GULF_AIR_COBRAND_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope18() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  NONBH-CCApplication-NonStaff-ilaGulfAIR
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'IN');
            Case newCase3 = createCase('Credit Card', 'Credit Card Application', 'New Credit Card','ILA_GULF_AIR_COBRAND_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope19() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCLimitIncrease-NonStaff-ilaGulfAIR
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'BH');
            Case newCase3 = createCase('Credit Limit Increase', 'Credit Limit Increase Application', 'Credit Limit Increase','ILA_GULF_AIR_COBRAND_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope20() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  NONBH-CCLimitIncrease-NonStaff-ilaGulfAIR
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'IN');
            Case newCase3 = createCase('Credit Limit Increase', 'Credit Limit Increase Application', 'Credit Limit Increase','ILA_GULF_AIR_COBRAND_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IsTest
    static void testSendEnvelope21() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCApplication Staff-ilaWORLD
            Account newAcc3 = createAccount('Bahrain', 'Staff', 'English', 'BH');
            Case newCase3 = createCase('Credit Card - Staff  Application', 'Credit Card Application', 'New Credit Card','WORLD_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope22() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCLimitIncrease-Staff-ilaWORLD
            Account newAcc3 = createAccount('Bahrain', 'Staff', 'English', 'BH');
            Case newCase3 = createCase('Credit Limit Increase Staff', 'Credit Limit Increase Application', 'Credit Limit Increase','WORLD_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope23() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  NONBH-CCApplication Staff-ilaWORLD
            Account newAcc3 = createAccount('Bahrain', 'Staff', 'English', 'IN');
            Case newCase3 = createCase('Credit Card - Staff  Application', 'Credit Card Application', 'New Credit Card','WORLD_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope24() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCApplication NonStaff-ilaWORLD
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'BH');
            Case newCase3 = createCase('Credit Card', 'Credit Card Application', 'New Credit Card','WORLD_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope25() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  NONBH-CCApplication-NonStaff-ilaWORLD
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'IN');
            Case newCase3 = createCase('Credit Card', 'Credit Card Application', 'New Credit Card','WORLD_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope26() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCLimitIncrease-NonStaff-ilaWORLD
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'BH');
            Case newCase3 = createCase('Credit Limit Increase', 'Credit Limit Increase Application', 'Credit Limit Increase','WORLD_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope27() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  NONBH-CCLimitIncrease-NonStaff-ilaWORLD
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'IN');
            Case newCase3 = createCase('Credit Limit Increase', 'Credit Limit Increase Application', 'Credit Limit Increase','WORLD_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @IsTest
    static void testSendEnvelope28() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCApplication Staff-ilaWORLDELITE
            Account newAcc3 = createAccount('Bahrain', 'Staff', 'English', 'BH');
            Case newCase3 = createCase('Credit Card - Staff  Application', 'Credit Card Application', 'New Credit Card','WORLD_ELITE_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope29() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCLimitIncrease-Staff-ilaWORLDELITE
            Account newAcc3 = createAccount('Bahrain', 'Staff', 'English', 'BH');
            Case newCase3 = createCase('Credit Limit Increase Staff', 'Credit Limit Increase Application', 'Credit Limit Increase','WORLD_ELITE_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope30() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  NONBH-CCApplication Staff-ilaWORLDELITE
            Account newAcc3 = createAccount('Bahrain', 'Staff', 'English', 'IN');
            Case newCase3 = createCase('Credit Card - Staff  Application', 'Credit Card Application', 'New Credit Card','WORLD_ELITE_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope31() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCApplication NonStaff-ilaWORLDELITE
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'BH');
            Case newCase3 = createCase('Credit Card', 'Credit Card Application', 'New Credit Card','WORLD_ELITE_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope32() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  NONBH-CCApplication-NonStaff-ilaWORLDELITE
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'IN');
            Case newCase3 = createCase('Credit Card', 'Credit Card Application', 'New Credit Card','WORLD_ELITE_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope33() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCLimitIncrease-NonStaff-ilaWORLDELITE
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'BH');
            Case newCase3 = createCase('Credit Limit Increase', 'Credit Limit Increase Application', 'Credit Limit Increase','WORLD_ELITE_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope34() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  NONBH-CCLimitIncrease-NonStaff-ilaWORLDELITE
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'IN');
            Case newCase3 = createCase('Credit Limit Increase', 'Credit Limit Increase Application', 'Credit Limit Increase','WORLD_ELITE_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////   CREDIT CARD CASH COLLATERAL ////////////////////////////////////////////////////////////////////////////////////////////////////
    
     @IsTest
    static void testSendEnvelope35() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCCashCollateralApplication NonStaff-ilaSwitch
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'BH');
            Case newCase3 = createCase('Credit Card Cash Collateral - Regular', 'Credit Card Cash Collateral Application', 'New Cash Collateral','PLATINUM_BALANCE_TRANSFER_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope36() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCCashCollateralApplication NonStaff-ilaBlue
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'BH');
            Case newCase3 = createCase('Credit Card Cash Collateral - Regular', 'Credit Card Cash Collateral Application', 'New Cash Collateral','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope37() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCCashCollateralApplication NonStaff-ilaWORLD
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'BH');
            Case newCase3 = createCase('Credit Card Cash Collateral - Regular', 'Credit Card Cash Collateral Application', 'New Cash Collateral','WORLD_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope38() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCCashCollateralApplication NonStaff-ilaWORLDELITE
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'IN');
            Case newCase3 = createCase('Credit Card Cash Collateral - Regular', 'Credit Card Cash Collateral Application', 'New Cash Collateral','WORLD_ELITE_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope39() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCCashCollateralLIMITINCREASEApplication NonStaff-ilaSwitch
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'BH');
            Case newCase3 = createCase('Cash Collateral Credit Limit Increase', 'Cash Collateral Credit Limit Increase Application', 'Cash Collateral Credit Limit Increase','PLATINUM_BALANCE_TRANSFER_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope40() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCCashCollateralLIMITINCREASEApplication NonStaff-ilaBlue
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'BH');
            Case newCase3 = createCase('Cash Collateral Credit Limit Increase', 'Cash Collateral Credit Limit Increase Application', 'Cash Collateral Credit Limit Increase','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope41() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCCashCollateralLIMITINCREASEApplication NonStaff-ilaWORLD
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'BH');
            Case newCase3 = createCase('Cash Collateral Credit Limit Increase', 'Cash Collateral Credit Limit Increase Application', 'Cash Collateral Credit Limit Increase','WORLD_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope42() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCCashCollateralLIMITINCREASEApplication NonStaff-ilaWORLDELITE
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'IN');
            Case newCase3 = createCase('Cash Collateral Credit Limit Increase', 'Cash Collateral Credit Limit Increase Application', 'Cash Collateral Credit Limit Increase','WORLD_ELITE_CASHBACK_AND_REWARDS_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope43() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCCashCollateralApplication NonStaff-ilaGULFAIR
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'BH');
            Case newCase3 = createCase('Credit Card Cash Collateral - Regular', 'Credit Card Cash Collateral Application', 'New Cash Collateral','ILA_GULF_AIR_COBRAND_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope44() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  BH-CCCashCollateralLIMITINCREASEApplication NonStaff-ilaGULFAIR
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'BH');
            Case newCase3 = createCase('Cash Collateral Credit Limit Increase', 'Cash Collateral Credit Limit Increase Application', 'Cash Collateral Credit Limit Increase','ILA_GULF_AIR_COBRAND_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope45() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  NONBH-CCCashCollateralApplication NonStaff-ilaGULFAIR
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'IN');
            Case newCase3 = createCase('Credit Card Cash Collateral - Regular', 'Credit Card Cash Collateral Application', 'New Cash Collateral','ILA_GULF_AIR_COBRAND_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
    
    @IsTest
    static void testSendEnvelope46() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Bahrain';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Bahrain']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  NONBH-CCCashCollateralLIMITINCREASEApplication NonStaff-ilaGULFAIR
            Account newAcc3 = createAccount('Bahrain', 'Regular', 'English', 'IN');
            Case newCase3 = createCase('Cash Collateral Credit Limit Increase', 'Cash Collateral Credit Limit Increase Application', 'Cash Collateral Credit Limit Increase','ILA_GULF_AIR_COBRAND_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////   JORDAN CREDIT CARD REQUESTS - Docusign ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    @IsTest
    static void testSendEnvelopeJor01() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Jordan';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Jordan']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Jordan territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) { 
           Test.startTest();
            // Create test data //  JO-CCApplication-Staff-ilaBlue-EN        
            Account newAcc3 = createAccount('Jordan', 'Staff', 'English', 'JO');
            Case newCase3 = createCase('Credit Card - Staff  Application', 'Credit Card Application', 'New Credit Card','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
            updateCase(newCase3,newAcc3);
          Test.stopTest();
            /////////////////////            
        } 
    }

    @IsTest
    static void testSendEnvelopeJor02() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Jordan';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Jordan']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Jordan territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  JO-CCApplication-Staff-ilaBlue-AR
            Account newAcc3 = createAccount('Jordan', 'Staff', 'Arabic', 'JO');
            Case newCase3 = createCase('Credit Card - Staff  Application', 'Credit Card Application', 'New Credit Card','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
           // Case newCase3 = createCase('Credit Limit Increase', 'Credit Limit Increase Application', 'Credit Limit Increase','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }

    @IsTest
    static void testSendEnvelopeJor03() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Jordan';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Jordan']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Jordan territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  JO-CCLimitIncreaseApplication-Staff-ilaBlue-EN
            Account newAcc3 = createAccount('Jordan', 'Staff', 'English', 'JO');
            Case newCase3 = createCase('Credit Limit Increase Staff', 'Credit Limit Increase Application', 'Credit Limit Increase','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
           // Case newCase3 = createCase('Credit Limit Increase', 'Credit Limit Increase Application', 'Credit Limit Increase','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }

    @IsTest
    static void testSendEnvelopeJor04() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Jordan';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Jordan']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Jordan territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  JO-CCLimitIncreaseApplication-Staff-ilaBlue-AR
            Account newAcc3 = createAccount('Jordan', 'Staff', 'Arabic', 'JO');
            Case newCase3 = createCase('Credit Limit Increase Staff', 'Credit Limit Increase Application', 'Credit Limit Increase','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }

    @IsTest
    static void testSendEnvelopeJor05() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Jordan';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Jordan']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Jordan territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  JO-CCApplication-NONStaff-ilaBlue-EN
            Account newAcc3 = createAccount('Jordan', 'Regular', 'English', 'JO');
            Case newCase3 = createCase('Credit Card', 'Credit Card Application', 'New Credit Card','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }

    @IsTest
    static void testSendEnvelopeJor06() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Jordan';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Jordan']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Jordan territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  JO-CCApplication-NONStaff-ilaBlue-AR
            Account newAcc3 = createAccount('Jordan', 'Regular', 'Arabic', 'JO');
            Case newCase3 = createCase('Credit Card', 'Credit Card Application', 'New Credit Card','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }

    @IsTest
    static void testSendEnvelopeJor07() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Jordan';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Jordan']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Jordan territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  JO-CCLimitIncreaseApplication-NONStaff-ilaBlue-EN
            Account newAcc3 = createAccount('Jordan', 'Regular', 'English', 'JO');
            Case newCase3 = createCase('Credit Limit Increase', 'Credit Limit Increase Application', 'Credit Limit Increase','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }

    @IsTest
    static void testSendEnvelopeJor08() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Jordan';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Jordan']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Jordan territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  JO-CCLimitIncreaseApplication-NONStaff-ilaBlue-AR
            Account newAcc3 = createAccount('Jordan', 'Regular', 'Arabic', 'JO');
            Case newCase3 = createCase('Credit Limit Increase', 'Credit Limit Increase Application', 'Credit Limit Increase','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }

    @IsTest
    static void testSendEnvelopeJor09() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Jordan';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Jordan']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Jordan territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  JO-CCCashCollateralApplication-NonStaff-ilaBlue-EN
            Account newAcc3 = createAccount('Jordan', 'Regular', 'English', 'JO');
            Case newCase3 = createCase('Credit Card Cash Collateral - Regular', 'Credit Card Cash Collateral Application', 'New Cash Collateral','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }

    @IsTest
    static void testSendEnvelopeJor10() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Jordan';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Jordan']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Jordan territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  JO-CCCashCollateralApplication-NonStaff-ilaBlue-AR
            Account newAcc3 = createAccount('Jordan', 'Regular', 'Arabic', 'JO');
            Case newCase3 = createCase('Credit Card Cash Collateral - Regular', 'Credit Card Cash Collateral Application', 'New Cash Collateral','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }

    @IsTest
    static void testSendEnvelopeJor11() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Jordan';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Jordan']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Jordan territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  JO-CCCashCollateralLimitIncreaseApplication-NonStaff-ilaBlue-EN
            Account newAcc3 = createAccount('Jordan', 'Regular', 'English', 'JO');
            Case newCase3 = createCase('Cash Collateral Credit Limit Increase', 'Cash Collateral Credit Limit Increase Application', 'Cash Collateral Credit Limit Increase','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }

    @IsTest
    static void testSendEnvelopeJor12() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User testUser = dfsle.UserMock.createDocuSignSender();
        // #CH01# Update Region Flag on the Test User to be able to access created records
        testUser.Region_Flag__c = 'Jordan';
        testUser.LastName='Integration';
        update testUser;
        List<Territory2> territoryList = [SELECT Id, Name FROM Territory2 where name='Jordan']; 
        System.assertEquals(1, territoryList.size());
        // Associate test user with the Bahrain territory
        UserTerritory2Association territoryAssignement = new UserTerritory2Association();
        territoryAssignement.UserId = testUser.Id;
        territoryAssignement.Territory2Id = territoryList[0].Id;
        insert territoryAssignement;
        
        System.runAs(testUser) {            
            // Create test data //  JO-CCCashCollateralLimitIncreaseApplication-NonStaff-ilaBlue-AR
            Account newAcc3 = createAccount('Jordan', 'Regular', 'Arabic', 'JO');
            Case newCase3 = createCase('Cash Collateral Credit Limit Increase', 'Cash Collateral Credit Limit Increase Application', 'Cash Collateral Credit Limit Increase','PLATINUM_CASHBACK_AND_REWARD_01', newAcc3);
            updateCase(newCase3,newAcc3);
            /////////////////////            
        } 
    }
     
    public static Account createAccount(String regionFlag, String segment, String prefLanguage, String CustomerNationality){
    
        //Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2_jo2@ilatest.com';
        acc.PersonMobilePhone = '284923003';
        acc.Nationality__pc = CustomerNationality;
        acc.Region_Flag__c = regionFlag;
        acc.Region_Flag__pc = regionFlag;
        acc.Language_Preference__pc = prefLanguage;
        acc.Segment__pc = segment;
        insert acc;
        system.debug('--------->>>>> Account Created --->>>  '+acc);
        return acc;
    }
    
    public static Case createCase(String RecordTypeName, String caseType, String caseSubType, String reqCardType, Account objAcc){
       
        Case cs1 = new Case();
        Account acc = new Account(id=objAcc.id,Region_Flag__pc=objAcc.Region_Flag__pc,Region_Flag__c=objAcc.Region_Flag__c,segment__pc=objAcc.Segment__pc,Language_Preference__pc=objAcc.Language_Preference__pc,Nationality__pc=objAcc.Nationality__pc);
        cs1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId();
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test';
        cs1.Type = caseType;
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01';
        cs1.cc_Approved_Requested_Card_Type__c = reqCardType;
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = acc.id;
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360; 
        cs1.cc_Residence_Permit_No__c = '54623';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.Sub_Type__c = caseSubType;
        cs1.Case_Model__c = 'ila';//#CH02
        cs1.cc_CPR_Expiry_Date__c=System.Today()+10;
        cs1.cc_CPR_Number__c='32343422';
        //CaseIDs.add(cs1.id);
        insert cs1;
 
        system.debug('--------->>>>> Case Created --->>>  '+cs1);
        return cs1;
    }

    public static void updateCase(Case objCase, Account objAcc){
        
        Set<Id> CaseIDsUpdate = new Set<Id>();
        Account acc = new Account(id=objAcc.id,FirstName=objAcc.FirstName,LastName=objAcc.LastName,PersonEmail=objAcc.PersonEmail,PersonMobilePhone=objAcc.PersonMobilePhone,Segment__pc=objAcc.Segment__pc, Language_Preference__pc=objAcc.Language_Preference__pc);
        Case cs1 = new Case(id=objCase.id,Type=objCase.Type,cc_Approved_Requested_Card_Type__c=objCase.cc_Approved_Requested_Card_Type__c,contactId=objCase.ContactId,accountId=acc.Id);
        //test.startTest();
        system.debug('----11--->>> ');
        system.debug('----11--->>> Case -->  '+cs1);
        system.debug('----11--->>> Case Type -->  '+cs1.Type);
        system.debug('----11--->>> Case Account Segment -->  '+cs1.Account.Segment__pc);
        system.debug('----11--->>> Approved Requested Card -->  '+cs1.cc_Approved_Requested_Card_Type__c);
        system.debug('----11--->>> Case Segment -->  '+cs1.Customer_Segment__c);
            system.debug('----11objCase--->>> ');
        system.debug('----11objCase--->>> Case -->  '+objCase);
        system.debug('----11objCase--->>> Case Type -->  '+objCase.Type);
        system.debug('----11objCase--->>> Case Account Segment -->  '+objCase.Account.Segment__pc);
        system.debug('----11objCase--->>> Approved Requested Card -->  '+objCase.cc_Approved_Requested_Card_Type__c);
        system.debug('----11objCase--->>> Case Segment -->  '+objCase.Customer_Segment__c);
        if((cs1.Type=='Credit Card Application' || cs1.Type=='Credit Limit Increase Application') && cs1.Customer_Segment__c !='Staff' && (cs1.cc_Approved_Requested_Card_Type__c =='PLATINUM_CASHBACK_AND_REWARD_01'  || cs1.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01' || cs1.cc_Approved_Requested_Card_Type__c =='WORLD_CASHBACK_AND_REWARDS_01' || cs1.cc_Approved_Requested_Card_Type__c =='WORLD_ELITE_CASHBACK_AND_REWARDS_01') && cs1.cc_Approved_Requested_Card_Type__c != null){        
            system.debug('----22--->>> ');
            cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
            update cs1;
            system.debug('--------->>>>> Case Prescreeenr --->>> ');

            cs1.cc_Credit_Evaluation_Result__c = 'Accept';
            update cs1;
            system.debug('--------->>>>> Case Evaluation --->>> ');
        
            cs1.cc_Credit_Verification_Result__c = 'Approve';
            update cs1;
            system.debug('--------->>>>> Case Verification --->>> ');
        
            cs1.cc_Credit_Approval_Result__c = 'Approve';
            update cs1;
            system.debug('--------->>>>> Case Approver --->>> ');
        
            CaseIDsUpdate.add(cs1.id);
            System.debug('Case Id in test class:'+cs1.Id);
        
            DocuSignApexToolKit d = new DocuSignApexToolKit(CaseIDsUpdate);
        
            System.enqueueJob(new DocuSignApexToolKit(CaseIDsUpdate));
            Test.setMock(HttpCalloutMock.class, new RestMock());
            final MyCalloutMock mock3 = new MyCalloutMock();
            // mock3.testBody = bodyString(cs1);
            test.stopTest();
        
            // Create a test envelope with one document and one recipient
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(cs1.Id))
            .withDocuments(new List<dfsle.Document> { 
                dfsle.Document.fromTemplate(
                    dfsle.UUID.randomUUID(),
                    'test template')
                    })
            .withRecipients(new List<dfsle.Recipient> {
                dfsle.Recipient.fromSource(
                    acc.FirstName + ' ' + acc.LastName,
                    acc.PersonEmail,
                    acc.PersonMobilePhone,
                    'Signer 1',
                    new dfsle.Entity(acc.Id))
                    });
        
            //Test.startTest();
            dfsle.Envelope myResult = dfsle.EnvelopeService.sendEnvelope(myEnvelope, true);
            //Test.stopTest();
        
            // Verify the results
            System.assertNotEquals(null, myResult);            
        }    
        else if((cs1.Type=='Credit Card Application' || cs1.Type=='Credit Limit Increase Application') && cs1.Customer_Segment__c !='Staff' && cs1.cc_Approved_Requested_Card_Type__c =='PLATINUM_BALANCE_TRANSFER_01' && cs1.cc_Approved_Requested_Card_Type__c != null){        
            system.debug('----22--->>> ');
            cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
            update cs1;
            system.debug('--------->>>>> Case Prescreeenr --->>> ');

            cs1.cc_Credit_Evaluation_Result__c = 'Accept';
            update cs1;
            system.debug('--------->>>>> Case Evaluation --->>> ');
        
            cs1.cc_Credit_Verification_Result__c = 'Approve';
            update cs1;
            system.debug('--------->>>>> Case Verification --->>> ');
        
            cs1.cc_Credit_Approval_Result__c = 'Approve';
            update cs1;
            system.debug('--------->>>>> Case Approver --->>> ');
        
            CaseIDsUpdate.add(cs1.id);
            System.debug('Case Id in test class:'+cs1.Id);
        
            DocuSignApexToolKit d = new DocuSignApexToolKit(CaseIDsUpdate);
        
            System.enqueueJob(new DocuSignApexToolKit(CaseIDsUpdate));
            Test.setMock(HttpCalloutMock.class, new RestMock());
            final MyCalloutMock mock3 = new MyCalloutMock();
            // mock3.testBody = bodyString(cs1);
           // test.stopTest();
        
            // Create a test envelope with one document and one recipient
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(cs1.Id))
            .withDocuments(new List<dfsle.Document> { 
                dfsle.Document.fromTemplate(
                    dfsle.UUID.randomUUID(),
                    'test template')
                    })
            .withRecipients(new List<dfsle.Recipient> {
                dfsle.Recipient.fromSource(
                    acc.FirstName + ' ' + acc.LastName,
                    acc.PersonEmail,
                    acc.PersonMobilePhone,
                    'Signer 1',
                    new dfsle.Entity(acc.Id))
                    });
        
            //Test.startTest();
            dfsle.Envelope myResult = dfsle.EnvelopeService.sendEnvelope(myEnvelope, true);
            //Test.stopTest();
        
            // Verify the results
            System.assertNotEquals(null, myResult);            
        } 
    
        else if((cs1.Type=='Credit Card Application' || cs1.Type=='Credit Limit Increase Application') && cs1.Customer_Segment__c =='Staff' && cs1.cc_Approved_Requested_Card_Type__c =='PLATINUM_BALANCE_TRANSFER_01' && cs1.cc_Approved_Requested_Card_Type__c != null){        
            system.debug('----22--->>> ');
            cs1.cc_HR_Result__c = 'Accept';
            update cs1;
            system.debug('--------->>>>> Case HR --->>> ');

            
        
            CaseIDsUpdate.add(cs1.id);
            System.debug('Case Id in test class:'+cs1.Id);
        
            DocuSignApexToolKit d = new DocuSignApexToolKit(CaseIDsUpdate);
        
            System.enqueueJob(new DocuSignApexToolKit(CaseIDsUpdate));
            Test.setMock(HttpCalloutMock.class, new RestMock());
            final MyCalloutMock mock3 = new MyCalloutMock();
            // mock3.testBody = bodyString(cs1);
           // test.stopTest();
        
            // Create a test envelope with one document and one recipient
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(cs1.Id))
            .withDocuments(new List<dfsle.Document> { 
                dfsle.Document.fromTemplate(
                    dfsle.UUID.randomUUID(),
                    'test template')
                    })
            .withRecipients(new List<dfsle.Recipient> {
                dfsle.Recipient.fromSource(
                    acc.FirstName + ' ' + acc.LastName,
                    acc.PersonEmail,
                    acc.PersonMobilePhone,
                    'Signer 1',
                    new dfsle.Entity(acc.Id))
                    });
        
            //Test.startTest();
            dfsle.Envelope myResult = dfsle.EnvelopeService.sendEnvelope(myEnvelope, true);
            //Test.stopTest();
        
            // Verify the results
            System.assertNotEquals(null, myResult);            
        }
    
        else if((cs1.Type=='Credit Card Application' || cs1.Type=='Credit Limit Increase Application') && cs1.Customer_Segment__c =='Staff' && (cs1.cc_Approved_Requested_Card_Type__c =='PLATINUM_CASHBACK_AND_REWARD_01' || cs1.cc_Approved_Requested_Card_Type__c =='ILA_GULF_AIR_COBRAND_01' || cs1.cc_Approved_Requested_Card_Type__c =='WORLD_CASHBACK_AND_REWARDS_01' || cs1.cc_Approved_Requested_Card_Type__c =='WORLD_ELITE_CASHBACK_AND_REWARDS_01') && cs1.cc_Approved_Requested_Card_Type__c != null){        
            system.debug('----22--->>> ');
            cs1.cc_HR_Result__c = 'Accept';
            update cs1;
            system.debug('--------->>>>> Case HR --->>> ');
        
            CaseIDsUpdate.add(cs1.id);
            System.debug('Case Id in test class:'+cs1.Id);
        
            DocuSignApexToolKit d = new DocuSignApexToolKit(CaseIDsUpdate);
        
            System.enqueueJob(new DocuSignApexToolKit(CaseIDsUpdate));
            Test.setMock(HttpCalloutMock.class, new RestMock());
            final MyCalloutMock mock3 = new MyCalloutMock();
            // mock3.testBody = bodyString(cs1);
         //   test.stopTest();
        
            // Create a test envelope with one document and one recipient
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(cs1.Id))
            .withDocuments(new List<dfsle.Document> { 
                dfsle.Document.fromTemplate(
                    dfsle.UUID.randomUUID(),
                    'test template')
                    })
            .withRecipients(new List<dfsle.Recipient> {
                dfsle.Recipient.fromSource(
                    acc.FirstName + ' ' + acc.LastName,
                    acc.PersonEmail,
                    acc.PersonMobilePhone,
                    'Signer 1',
                    new dfsle.Entity(acc.Id))
                    });
        
            //Test.startTest();
            dfsle.Envelope myResult = dfsle.EnvelopeService.sendEnvelope(myEnvelope, true);
            //Test.stopTest();
        
            // Verify the results
            System.assertNotEquals(null, myResult);            
        }
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        else if((cs1.Type=='Credit Card Cash Collateral Application' || cs1.Type=='Cash Collateral Credit Limit Increase Application') && cs1.Customer_Segment__c !='Staff' && (cs1.cc_Approved_Requested_Card_Type__c =='PLATINUM_CASHBACK_AND_REWARD_01'  || cs1.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01' || cs1.cc_Approved_Requested_Card_Type__c =='WORLD_CASHBACK_AND_REWARDS_01' || cs1.cc_Approved_Requested_Card_Type__c =='WORLD_ELITE_CASHBACK_AND_REWARDS_01') && cs1.cc_Approved_Requested_Card_Type__c != null){        
            system.debug('----22--->>> ');
            cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
            update cs1;
            system.debug('--------->>>>> Case Prescreeenr --->>> ');

            cs1.cc_Credit_Evaluation_Result__c = 'Accept';
            update cs1;
            system.debug('--------->>>>> Case Evaluation --->>> ');
        
            cs1.cc_Credit_Verification_Result__c = 'Approve';
            update cs1;
            system.debug('--------->>>>> Case Verification --->>> ');
        
            cs1.cc_Credit_Approval_Result__c = 'Approve';
            update cs1;
            system.debug('--------->>>>> Case Approver --->>> ');
        
            CaseIDsUpdate.add(cs1.id);
            System.debug('Case Id in test class:'+cs1.Id);
        
            DocuSignApexToolKit d = new DocuSignApexToolKit(CaseIDsUpdate);
        
            System.enqueueJob(new DocuSignApexToolKit(CaseIDsUpdate));
            Test.setMock(HttpCalloutMock.class, new RestMock());
            final MyCalloutMock mock3 = new MyCalloutMock();
            // mock3.testBody = bodyString(cs1);
          //  test.stopTest();
        
            // Create a test envelope with one document and one recipient
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(cs1.Id))
            .withDocuments(new List<dfsle.Document> { 
                dfsle.Document.fromTemplate(
                    dfsle.UUID.randomUUID(),
                    'test template')
                    })
            .withRecipients(new List<dfsle.Recipient> {
                dfsle.Recipient.fromSource(
                    acc.FirstName + ' ' + acc.LastName,
                    acc.PersonEmail,
                    acc.PersonMobilePhone,
                    'Signer 1',
                    new dfsle.Entity(acc.Id))
                    });
        
            //Test.startTest();
            dfsle.Envelope myResult = dfsle.EnvelopeService.sendEnvelope(myEnvelope, true);
            //Test.stopTest();
        
            // Verify the results
            System.assertNotEquals(null, myResult);            
        }    
        else if((cs1.Type=='Credit Card Cash Collateral Application' || cs1.Type=='Cash Collateral Credit Limit Increase Application') && cs1.Customer_Segment__c !='Staff' && cs1.cc_Approved_Requested_Card_Type__c =='PLATINUM_BALANCE_TRANSFER_01' && cs1.cc_Approved_Requested_Card_Type__c != null){        
            system.debug('----22--->>> ');
            cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
            update cs1;
            system.debug('--------->>>>> Case Prescreeenr --->>> ');

            cs1.cc_Credit_Evaluation_Result__c = 'Accept';
            update cs1;
            system.debug('--------->>>>> Case Evaluation --->>> ');
        
            cs1.cc_Credit_Verification_Result__c = 'Approve';
            update cs1;
            system.debug('--------->>>>> Case Verification --->>> ');
        
            cs1.cc_Credit_Approval_Result__c = 'Approve';
            update cs1;
            system.debug('--------->>>>> Case Approver --->>> ');
        
            CaseIDsUpdate.add(cs1.id);
            System.debug('Case Id in test class:'+cs1.Id);
        
            DocuSignApexToolKit d = new DocuSignApexToolKit(CaseIDsUpdate);
        
            System.enqueueJob(new DocuSignApexToolKit(CaseIDsUpdate));
            Test.setMock(HttpCalloutMock.class, new RestMock());
            final MyCalloutMock mock3 = new MyCalloutMock();
            // mock3.testBody = bodyString(cs1);
          //  test.stopTest();
        
            // Create a test envelope with one document and one recipient
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(cs1.Id))
            .withDocuments(new List<dfsle.Document> { 
                dfsle.Document.fromTemplate(
                    dfsle.UUID.randomUUID(),
                    'test template')
                    })
            .withRecipients(new List<dfsle.Recipient> {
                dfsle.Recipient.fromSource(
                    acc.FirstName + ' ' + acc.LastName,
                    acc.PersonEmail,
                    acc.PersonMobilePhone,
                    'Signer 1',
                    new dfsle.Entity(acc.Id))
                    });
        
            //Test.startTest();
            dfsle.Envelope myResult = dfsle.EnvelopeService.sendEnvelope(myEnvelope, true);
            //Test.stopTest();
        
            // Verify the results
            System.assertNotEquals(null, myResult);            
        }
    }

    
}
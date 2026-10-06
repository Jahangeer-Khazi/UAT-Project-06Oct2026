/*
Author : 
Date : 
Description : DocuSignApexToolKitTest
#CH01# Added #27-11-2021# test user needs to be assigned to a Territory to be able to access records specific to a Region - YZ
#CH02# Added #23-06-2022# Hamza Chaoui add Case_Model__c
*/

@IsTest
private class DocuSignApexToolKitTest1 {
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
            String fullJson = 'your Json Response';

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
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"data":{"transitionInProgress":false,"currentSegment":{"segmentName":"REGULAR","segmentCrmId":"Regular"},"campaign":{"id":"1","validity":"2023-08-18T07:55:26"},"currentCards":[{"id":"10010522439126747125063583","cardName":"VIRTUAL","cardDisplayName":"Virtual","cardAfsId":"TestVirtualCards","productType":"Virtual","cardMinimumBalance":0,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":false,"limit":0,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"},{"id":"100105224391267471250615229","cardName":"CLASSIC","cardDisplayName":"Classic","cardAfsId":"Debit Classic","productType":"Classic","cardMinimumBalance":20,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"limit":1000,"nextAnnualAnniversaryDate":"2021-06-18T07:55:26","discount":{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"}],"segmentOptions":[{"segmentName":"STAFF","segmentCrmId":"Staff"},{"segmentName":"ROYAL_FAMILY","segmentCrmId":"Royal Family"},{"segmentName":"PREMIUM","segmentCrmId":"Premium"},{"segmentName":"PREMIUM_PLUS","segmentCrmId":"Premium Plus"},{"segmentName":"SENSITIVE","segmentCrmId":"Sensitive"}],"cardOptions":[{"cardName":"WORLD","cardDisplayName":"World","cardAfsId":"MasterCardWorld","productType":"World","cardMinimumBalance":0,"order":1,"issuanceFee":0.000,"annualFee":37.500,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":1.875,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":39.375},{"cardName":"ELITE","cardDisplayName":"Elite","cardAfsId":"WORLD_ELITE","productType":"World Elite","cardMinimumBalance":0,"order":2,"issuanceFee":0.000,"annualFee":75.000,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":3.750,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":78.750}],"discountOptions":[{"name":"None","displayName":"No discount","discountPercentage":0},{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},{"name":"Discount50","displayName":"50 percent discount","discountPercentage":50},{"name":"Discount75","displayName":"75 percent discount","discountPercentage":75},{"name":"Free","displayName":"No charge","discountPercentage":100}]},"meta":{"code":"SGMT-1006","message":"Customer Segment Options retrieved successfully."}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest
    static void testSendEnvelope() {
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
            // Create test data
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.PersonMobilePhone = '284923833';
            acc.Nationality__pc = 'BH';
            acc.Region_Flag__c = 'Bahrain';
            acc.Region_Flag__pc = 'Bahrain';
            acc.Segment__pc = 'Regular';
            insert acc;
            
            Set<Id> CaseIDs = new Set<Id>();
            Set<Id> CaseIDsUpdate = new Set<Id>();
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Credit Card Application';
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
            cs1.Sub_Type__c = 'New Credit Card';
            cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
            cs1.Case_Model__c = 'ila';//#CH02
            cs1.cc_CPR_Expiry_Date__c=System.Today()+10;
            cs1.cc_CPR_Number__c='32343422';
            //CaseIDs.add(cs1.id);
            insert cs1;
            
            
            test.startTest();
            //insert cs1;
            cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
            cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
            cs1.cc_Salary_is_Transferred_to_ila__c = true;
            cs1.cc_Credit_Bureau_Score__c = 700;
            cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
            cs1.cc_Approved_Requested_Card_Type__c='PLATINUM_CASHBACK_AND_REWARD_01';
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
            
            cs1.cc_Credit_Approval_Result__c = 'Approve';
            cs1.cc_Application_Stages__c = 'Credit Approval';
            update cs1;
            
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
        
        System.runAs(testUser) {            
            // Create test data
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.PersonMobilePhone = '284923833';
            acc.Nationality__pc = 'BH';
            acc.Region_Flag__c = 'Bahrain';
            acc.Region_Flag__pc = 'Bahrain';
            acc.Segment__pc = 'Regular';
            insert acc;
            
            Set<Id> CaseIDs = new Set<Id>();
            Set<Id> CaseIDsUpdate = new Set<Id>();
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Credit Card Application';
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
            cs1.Sub_Type__c = 'New Credit Card';
            cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
            cs1.Case_Model__c = 'ila';//#CH02
            cs1.cc_CPR_Expiry_Date__c=System.Today()+10;
            cs1.cc_CPR_Number__c='32343422';
            //CaseIDs.add(cs1.id);
            insert cs1;
            
            
            test.startTest();
            //insert cs1;
            cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
            cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
            cs1.cc_Salary_is_Transferred_to_ila__c = true;
            cs1.cc_Credit_Bureau_Score__c = 700;
            cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
            cs1.cc_Approved_Requested_Card_Type__c='WORLD_CASHBACK_AND_REWARDS_01';
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
            
            cs1.cc_Credit_Approval_Result__c = 'Approve';
            cs1.cc_Application_Stages__c = 'Credit Approval';
            update cs1;
            
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
            // Create test data
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.PersonMobilePhone = '284923833';
            acc.Nationality__pc = 'BH';
            acc.Region_Flag__c = 'Bahrain';
            acc.Region_Flag__pc = 'Bahrain';
            acc.Segment__pc = 'Regular';
            insert acc;
            
            Set<Id> CaseIDs = new Set<Id>();
            Set<Id> CaseIDsUpdate = new Set<Id>();
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Credit Card Application';
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
            cs1.Sub_Type__c = 'New Credit Card';
            cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
            cs1.Case_Model__c = 'ila';//#CH02
            cs1.cc_CPR_Expiry_Date__c=System.Today()+10;
            cs1.cc_CPR_Number__c='32343422';
            //CaseIDs.add(cs1.id);
            insert cs1;
            
            
            test.startTest();
            //insert cs1;
            cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
            cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
            cs1.cc_Salary_is_Transferred_to_ila__c = true;
            cs1.cc_Credit_Bureau_Score__c = 700;
            cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
            cs1.cc_Approved_Requested_Card_Type__c='WORLD_ELITE_CASHBACK_AND_REWARDS_01';
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
            
            cs1.cc_Credit_Approval_Result__c = 'Approve';
            cs1.cc_Application_Stages__c = 'Credit Approval';
            update cs1;
            
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
            // Create test data
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.PersonMobilePhone = '284923833';
            acc.Nationality__pc = 'BH';
            acc.Region_Flag__c = 'Bahrain';
            acc.Region_Flag__pc = 'Bahrain';
            acc.Segment__pc = 'Regular';
            insert acc;
            
            Set<Id> CaseIDs = new Set<Id>();
            Set<Id> CaseIDsUpdate = new Set<Id>();
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Credit Card Application';
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
            cs1.Sub_Type__c = 'New Credit Card';
            cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
            cs1.Case_Model__c = 'ila';//#CH02
            cs1.cc_CPR_Expiry_Date__c=System.Today()+10;
            cs1.cc_CPR_Number__c='32343422';
            //CaseIDs.add(cs1.id);
            insert cs1;
            
            
            test.startTest();
            //insert cs1;
            cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
            cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
            cs1.cc_Salary_is_Transferred_to_ila__c = true;
            cs1.cc_Credit_Bureau_Score__c = 700;
            cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
            cs1.cc_Approved_Requested_Card_Type__c='ILA_GULF_AIR_COBRAND_01';
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
            
            cs1.cc_Credit_Approval_Result__c = 'Approve';
            cs1.cc_Application_Stages__c = 'Credit Approval';
            update cs1;
            
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
    }
    @IsTest
    static void testSendEnvelopeJO() {
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
            // Create test data
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2_jo1@ilatest.com';
            acc.PersonMobilePhone = '400023833';
            acc.Nationality__pc = 'BH';
            acc.Region_Flag__c = 'Jordan';
            acc.Region_Flag__pc = 'Jordan';
            acc.Language_Preference__pc = 'English';
            acc.Segment__pc = 'Regular';
            insert acc;
            
            
            Set<Id> CaseIDs = new Set<Id>();
            Set<Id> CaseIDsUpdate = new Set<Id>();
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Credit Card Application';
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
            cs1.Sub_Type__c = 'New Credit Card';
            cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
            cs1.Case_Model__c = 'ila';//#CH02
            cs1.cc_CPR_Expiry_Date__c=System.Today()+10;
            cs1.cc_CPR_Number__c='32343422';
            //CaseIDs.add(cs1.id);
            insert cs1;
            
            
            
            test.startTest();
            //insert cs1;
            cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
            cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
            cs1.cc_Salary_is_Transferred_to_ila__c = true;
            cs1.cc_Credit_Bureau_Score__c = 700;
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
            
            cs1.cc_Credit_Approval_Result__c = 'Approve';
            cs1.cc_Application_Stages__c = 'Credit Approval';
            update cs1;
            
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
    }
  /*  @IsTest
    static void testSendEnvelopelimit1() {
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
         Set<Id> setIds = new Set<Id>();
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
            // Create test data
            test.startTest();
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Limit Increase').getRecordTypeId();
            
            
            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test12@ilatest.com';
            acc.PersonMobilePhone = '284923833';
            acc.Nationality__pc = 'BH';
            acc.Region_Flag__c = 'Bahrain';
            acc.Region_Flag__pc = 'Bahrain';
            acc.Segment__pc = 'Regular';
            insert acc;

            
            Set<Id> CaseIDs = new Set<Id>();
            Set<Id> CaseIDsUpdate = new Set<Id>();
            Case cs1 = new Case();
            cs1.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Limit Increase').getRecordTypeId();
            cs1.Subject = 'Credit Limit Increase Application';
            cs1.Description = 'Credit Limit Increase ApplicationTest for Duplicate Cards';
            cs1.Type = 'Credit Limit Increase Application';
            cs1.Sub_Type__c = 'Credit Limit Increase';
            cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
            cs1.Status = 'In Progress';
            cs1.Priority = 'High';
            cs1.Case_Nature__c = 'Password';
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
            cs1.ContactId = acc.PersonContactId;
            cs1.AccountId=acc.Id;
            cs1.cc_Monthly_Income__c =2100;
            cs1.cc_PCI_Id__c = '2';
            cs1.Case_Model__c ='ila';
            //CH03: Start
            cs1.Region_Flag__c = 'Bahrain';
            cs1.cc_Request_Type__c='Permanent';
            cs1.Is_Cash_Collateral__c=False;
            //cs1.ContactEmail='test12@ilatest.com';
            //CH03: END
            
            insert cs1;
             setIds.add(cs1.id);
       //     initiateManualOnboarding.CCCaseUpdate(setIds);
       
      //  final MyCalloutMock mock4 = new MyCalloutMock();
       // mock4.testBody = bodyString(cs1);
            cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
            cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
            cs1.cc_Salary_is_Transferred_to_ila__c = true;
            cs1.cc_Credit_Bureau_Score__c = 700;
            cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
            cs1.cc_Approved_Requested_Card_Type__c='WORLD_CASHBACK_AND_REWARDS_01';
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
            
            cs1.cc_Credit_Approval_Result__c = 'Approve';
            cs1.cc_Application_Stages__c = 'Credit Approval';
            update cs1;
            
            CaseIDsUpdate.add(cs1.id);
            System.debug('Case Id in test class:'+cs1.Id);
            
            DocuSignApexToolKit d = new DocuSignApexToolKit(CaseIDsUpdate);
            
            System.enqueueJob(new DocuSignApexToolKit(CaseIDsUpdate));
            Test.setMock(HttpCalloutMock.class, new RestMock2());
            final MyCalloutMock mock4 = new MyCalloutMock();
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
    }
    @IsTest
    static void testSendEnvelopelimit2() {
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
            // Create test data
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Limit Increase').getRecordTypeId();
            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test13@ilatest.com';
            acc.PersonMobilePhone = '284923833';
            acc.Nationality__pc = 'BH';
            acc.Region_Flag__c = 'Bahrain';
            acc.Region_Flag__pc = 'Bahrain';
            acc.Segment__pc = 'Regular';
            insert acc;
            
            Set<Id> CaseIDs = new Set<Id>();
            Set<Id> CaseIDsUpdate = new Set<Id>();
            Case cs1 = new Case();
            cs1.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Limit Increase').getRecordTypeId();
            cs1.Subject = 'Credit Limit Increase Application';
            cs1.Description = 'Credit Limit Increase ApplicationTest for Duplicate Cards';
            cs1.Type = 'Credit Limit Increase Application';
            cs1.Sub_Type__c = 'Credit Limit Increase';
            cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
            cs1.Status = 'In Progress';
            cs1.Priority = 'High';
            cs1.Case_Nature__c = 'Password';
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
            cs1.ContactId = acc.PersonContactId;
            cs1.cc_Monthly_Income__c =2100;
            cs1.cc_PCI_Id__c = '2';
            cs1.Case_Model__c ='ila';
            //CH03: Start
            cs1.Region_Flag__c = 'Bahrain';
            // insert cs1;
            
            
            test.startTest();
            insert cs1;
            cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
            cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
            cs1.cc_Salary_is_Transferred_to_ila__c = true;
            cs1.cc_Credit_Bureau_Score__c = 700;
            cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
            cs1.cc_Approved_Requested_Card_Type__c='WORLD_ELITE_CASHBACK_AND_REWARDS_01';
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
            
            cs1.cc_Credit_Approval_Result__c = 'Approve';
            cs1.cc_Application_Stages__c = 'Credit Approval';
            update cs1;
            
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
    }
    @IsTest
    static void testSendEnvelopelimit3() {
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
            // Create test data
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Limit Increase').getRecordTypeId();
            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test14@ilatest.com';
            acc.PersonMobilePhone = '284923833';
            acc.Nationality__pc = 'BH';
            acc.Region_Flag__c = 'Bahrain';
            acc.Region_Flag__pc = 'Bahrain';
            acc.Segment__pc = 'Regular';
            insert acc;
            
            Set<Id> CaseIDs = new Set<Id>();
            Set<Id> CaseIDsUpdate = new Set<Id>();
            Case cs1 = new Case();
            cs1.recordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Limit Increase').getRecordTypeId();
            cs1.Subject = 'Credit Limit Increase Application';
            cs1.Description = 'Credit Limit Increase ApplicationTest for Duplicate Cards';
            cs1.Type = 'Credit Limit Increase Application';
            cs1.Sub_Type__c = 'Credit Limit Increase';
            cs1.cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01';
            cs1.Status = 'In Progress';
            cs1.Priority = 'High';
            cs1.Case_Nature__c = 'Password';
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
            cs1.ContactId = acc.PersonContactId;
            cs1.cc_Monthly_Income__c =2100;
            cs1.cc_PCI_Id__c = '2';
            cs1.Case_Model__c ='ila';
            //CH03: Start
            cs1.Region_Flag__c = 'Bahrain';
            //  insert cs1;
            
            
            test.startTest();
            insert cs1;
            cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
            cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
            cs1.cc_Salary_is_Transferred_to_ila__c = true;
            cs1.cc_Credit_Bureau_Score__c = 700;
            cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
            cs1.cc_Approved_Requested_Card_Type__c='ILA_GULF_AIR_COBRAND_01';
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
            
            cs1.cc_Credit_Approval_Result__c = 'Approve';
            cs1.cc_Application_Stages__c = 'Credit Approval';
            update cs1;
            
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
    }*/
    @IsTest
    static void testSendEnvelopeJO_AR() {
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
            // Create test data
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2_jo2@ilatest.com';
            acc.PersonMobilePhone = '284923003';
            acc.Nationality__pc = 'BH';
            acc.Region_Flag__c = 'Jordan';
            acc.Region_Flag__pc = 'Jordan';
            acc.Language_Preference__pc = 'Arabic';
            acc.Segment__pc = 'Regular';
            insert acc;
            
            Set<Id> CaseIDs = new Set<Id>();
            Set<Id> CaseIDsUpdate = new Set<Id>();
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Credit Card Application';
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
            cs1.Sub_Type__c = 'New Credit Card';
            cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
            cs1.Case_Model__c = 'ila';//#CH02
            cs1.cc_CPR_Expiry_Date__c=System.Today()+10;
            cs1.cc_CPR_Number__c='32343422';
            //CaseIDs.add(cs1.id);
            insert cs1;
            
            test.startTest();
            //insert cs1;
            cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
            cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
            cs1.cc_Salary_is_Transferred_to_ila__c = true;
            cs1.cc_Credit_Bureau_Score__c = 700;
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
            
            cs1.cc_Credit_Approval_Result__c = 'Approve';
            cs1.cc_Application_Stages__c = 'Credit Approval';
            update cs1;
            
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
      @IsTest
    static void testSendEnvelopeNONBH1() {
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
            // Create test data
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.PersonMobilePhone = '284923833';
            acc.Nationality__pc = 'IN';
            acc.Region_Flag__c = 'Bahrain';
            acc.Region_Flag__pc = 'Bahrain';
            acc.Segment__pc = 'Regular';
            insert acc;
            
            Set<Id> CaseIDs = new Set<Id>();
            Set<Id> CaseIDsUpdate = new Set<Id>();
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Credit Card Application';
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
            cs1.Sub_Type__c = 'New Credit Card';
            cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
            cs1.Case_Model__c = 'ila';//#CH02
            cs1.cc_CPR_Expiry_Date__c=System.Today()+10;
            cs1.cc_CPR_Number__c='32343422';
            //CaseIDs.add(cs1.id);
            insert cs1;
            
            
            test.startTest();
            //insert cs1;
            cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
            cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
            cs1.cc_Salary_is_Transferred_to_ila__c = true;
            cs1.cc_Credit_Bureau_Score__c = 700;
            cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
            cs1.cc_Approved_Requested_Card_Type__c='WORLD_CASHBACK_AND_REWARDS_01';
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
            
            cs1.cc_Credit_Approval_Result__c = 'Approve';
            cs1.cc_Application_Stages__c = 'Credit Approval';
            update cs1;
            
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
    }
    
    @IsTest
    static void testSendEnvelopeNONBH2() {
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
            // Create test data
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.PersonMobilePhone = '284923833';
            acc.Nationality__pc = 'IN';
            acc.Region_Flag__c = 'Bahrain';
            acc.Region_Flag__pc = 'Bahrain';
            acc.Segment__pc = 'Regular';
            insert acc;
            
            Set<Id> CaseIDs = new Set<Id>();
            Set<Id> CaseIDsUpdate = new Set<Id>();
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Credit Card Application';
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
            cs1.Sub_Type__c = 'New Credit Card';
            cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
            cs1.Case_Model__c = 'ila';//#CH02
            cs1.cc_CPR_Expiry_Date__c=System.Today()+10;
            cs1.cc_CPR_Number__c='32343422';
            //CaseIDs.add(cs1.id);
            insert cs1;
            
            
            test.startTest();
            //insert cs1;
            cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
            cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
            cs1.cc_Salary_is_Transferred_to_ila__c = true;
            cs1.cc_Credit_Bureau_Score__c = 700;
            cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
            cs1.cc_Approved_Requested_Card_Type__c='WORLD_ELITE_CASHBACK_AND_REWARDS_01';
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
            
            cs1.cc_Credit_Approval_Result__c = 'Approve';
            cs1.cc_Application_Stages__c = 'Credit Approval';
            update cs1;
            
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
    }
    @IsTest
    static void testSendEnvelopeNONBH3() {
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
            // Create test data
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.PersonMobilePhone = '284923833';
            acc.Nationality__pc = 'IN';
            acc.Region_Flag__c = 'Bahrain';
            acc.Region_Flag__pc = 'Bahrain';
            acc.Segment__pc = 'Regular';
            insert acc;
            
            Set<Id> CaseIDs = new Set<Id>();
            Set<Id> CaseIDsUpdate = new Set<Id>();
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Credit Card Application';
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
            cs1.Sub_Type__c = 'New Credit Card';
            cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
            cs1.Case_Model__c = 'ila';//#CH02
            cs1.cc_CPR_Expiry_Date__c=System.Today()+10;
            cs1.cc_CPR_Number__c='32343422';
            //CaseIDs.add(cs1.id);
            insert cs1;
            
            
            test.startTest();
            //insert cs1;
            cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
            cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
            cs1.cc_Salary_is_Transferred_to_ila__c = true;
            cs1.cc_Credit_Bureau_Score__c = 700;
            cs1.cc_Credit_Bureau_Risk_Rating__c = 'Low Risk 750-850';
            cs1.cc_Approved_Requested_Card_Type__c='ILA_GULF_AIR_COBRAND_01';
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
            
            cs1.cc_Credit_Approval_Result__c = 'Approve';
            cs1.cc_Application_Stages__c = 'Credit Approval';
            update cs1;
            
            CaseIDsUpdate.add(cs1.id);
            System.debug('Case Id in test class:'+cs1.Id);
            
            DocuSignApexToolKit d = new DocuSignApexToolKit(CaseIDsUpdate);
            
            System.enqueueJob(new DocuSignApexToolKit(CaseIDsUpdate));
            Test.setMock(HttpCalloutMock.class, new RestMock());
            final MyCalloutMock mock3 = new MyCalloutMock();
            mock3.testBody = bodyString(cs1);
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
    }
          @IsTest
    static void testSendEnvelopeStaff1() {
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
            // Create test data
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card - Staff  Application').getRecordTypeId();
            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.PersonMobilePhone = '284923833';
            acc.Nationality__pc = 'IN';
            acc.Region_Flag__c = 'Bahrain';
            acc.Region_Flag__pc = 'Bahrain';
            acc.Segment__pc = 'Staff';
            insert acc;
            
            Set<Id> CaseIDs = new Set<Id>();
            Set<Id> CaseIDsUpdate = new Set<Id>();
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Credit Card Application';
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
            cs1.Sub_Type__c = 'New Credit Card';
            cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
            cs1.Case_Model__c = 'ila';//#CH02
            cs1.cc_CPR_Expiry_Date__c=System.Today()+10;
            cs1.cc_CPR_Number__c='32343422';

test.startTest();
         insert cs1;
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c  = 500;
        cs1.cc_Approved_Requested_Card_Type__c='WORLD_CASHBACK_AND_REWARDS_01';
        cs1.cc_HR_Result__c = 'Approved';
        update cs1;
        
        System.debug('---->HR Result:'+cs1.cc_HR_Result__c );
        System.debug('---->HR Result Record Type:'+cs1.RecordTypeId);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
            
            CaseIDsUpdate.add(cs1.id);
            System.debug('Case Id in test class:'+cs1.Id);
            
            DocuSignApexToolKit d = new DocuSignApexToolKit(CaseIDsUpdate);
            
            System.enqueueJob(new DocuSignApexToolKit(CaseIDsUpdate));
            Test.setMock(HttpCalloutMock.class, new RestMock());
            final MyCalloutMock mock5 = new MyCalloutMock();
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
    }
    
    @IsTest
    static void testSendEnvelopeStaff2() {
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
            // Create test data
           Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card - Staff  Application').getRecordTypeId();
            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.PersonMobilePhone = '284923833';
            acc.Nationality__pc = 'IN';
            acc.Region_Flag__c = 'Bahrain';
            acc.Region_Flag__pc = 'Bahrain';
            acc.Segment__pc = 'Staff';
            insert acc;
            
            Set<Id> CaseIDs = new Set<Id>();
            Set<Id> CaseIDsUpdate = new Set<Id>();
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Credit Card Application';
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
            cs1.Sub_Type__c = 'New Credit Card';
            cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
            cs1.Case_Model__c = 'ila';//#CH02
            cs1.cc_CPR_Expiry_Date__c=System.Today()+10;
            cs1.cc_CPR_Number__c='32343422';
            //CaseIDs.add(cs1.id);
            
test.startTest();
         insert cs1;
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c  = 500;
        cs1.cc_Approved_Requested_Card_Type__c='WORLD_ELITE_CASHBACK_AND_REWARDS_01';
        cs1.cc_HR_Result__c = 'Approved';
        update cs1;
        
        System.debug('---->HR Result:'+cs1.cc_HR_Result__c );
        System.debug('---->HR Result Record Type:'+cs1.RecordTypeId);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock5 = new MyCalloutMock();
        mock5.testBody = bodyString(cs1);
            
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
    }
    @IsTest
    static void testSendEnvelopeStaff3() {
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
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card - Staff  Application').getRecordTypeId();
            Account acc = new Account();
            acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
            acc.FirstName = 'Test2';
            acc.LastName = 'Class2';
            acc.PersonEmail = 'test2@ilatest.com';
            acc.PersonMobilePhone = '284923833';
            acc.Nationality__pc = 'IN';
            acc.Region_Flag__c = 'Bahrain';
            acc.Region_Flag__pc = 'Bahrain';
            acc.Segment__pc = 'Staff';
            insert acc;
            
            Set<Id> CaseIDs = new Set<Id>();
            Set<Id> CaseIDsUpdate = new Set<Id>();
            Case cs1 = new Case();
            cs1.RecordTypeId = recordTypeId;
            cs1.Subject = 'NewCreditCardApplicationTest';
            cs1.Description = 'Credit card Application Test for Duplicate Cards';
            cs1.Type = 'Credit Card Application';
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
            cs1.Sub_Type__c = 'New Credit Card';
            cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
            cs1.Case_Model__c = 'ila';//#CH02
            cs1.cc_CPR_Expiry_Date__c=System.Today()+10;
            cs1.cc_CPR_Number__c='32343422';
            //CaseIDs.add(cs1.id);
            
            
         test.startTest();
         insert cs1;
        cs1.cc_Approved_Credit_Limit__c = 500;
        cs1.cc_Approved_Balance_Transfer_Amount__c  = 500;
        cs1.cc_Approved_Requested_Card_Type__c='ILA_GULF_AIR_COBRAND_01';
        cs1.cc_HR_Result__c = 'Approved';
        update cs1;
        
        System.debug('---->HR Result:'+cs1.cc_HR_Result__c );
        System.debug('---->HR Result Record Type:'+cs1.RecordTypeId);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock3 = new MyCalloutMock();
        mock3.testBody = bodyString(cs1);
            CaseIDsUpdate.add(cs1.id);
            System.debug('Case Id in test class:'+cs1.Id);
            
            DocuSignApexToolKit d = new DocuSignApexToolKit(CaseIDsUpdate);
            
            System.enqueueJob(new DocuSignApexToolKit(CaseIDsUpdate));
            Test.setMock(HttpCalloutMock.class, new RestMock());
            final MyCalloutMock mock5 = new MyCalloutMock();
            mock3.testBody = bodyString(cs1);
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
    }
    public ID createAccount(String regionFlag, String segment, String prefLanguage, String CustomerNationality){
    
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
        return acc.id;
    }
    
    public Case createCase(String RecordTypeName, String caseType, String reqCardType){
       
        Case cs1 = new Case();
        cs1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId();
        cs1.Subject = 'NewCreditCardApplicationTest';
        cs1.Description = 'Credit card Application Test for Duplicate Cards';
        cs1.Type = caseType;
        cs1.cc_Name_on_the_Card__c = 'ABC';
        cs1.cc_Embossing_Line_4__c = 'XYZ';
        cs1.cc_Requested_Card_Type__c = reqCardType;
        cs1.Priority = 'High';
        cs1.Awaiting_Customer_Feedback__c = false;
        cs1.Origin = 'Phone';
        cs1.AccountId = createAccount ('','','','');
        cs1.cc_Monthly_Income__c =6000;
        cs1.cc_PCI_Id__c = '8';
        cs1.cc_Passport_Number__c = 'RT546FRGF';
        cs1.cc_Passport_Expiry_Date__c = System.today() + 360;
        cs1.cc_Residence_Permit_No__c = '54623';
        cs1.cc_Residence_Permit_Expiry_Date__c = System.today() + 360;
        cs1.cc_Balance_Transfer_Card_Provider__c = 'Test Bank';
        cs1.cc_Balance_Transfer_Card_Number__c = '5464564546wert45';
        cs1.cc_Balance_Transfer_Amount__c = 1000;
        cs1.cc_Balance_Transfer_Type__c = 'Balance Transfer';
        cs1.Sub_Type__c = 'New Credit Card';
        cs1.cc_Approved_Transfer_Type__c = 'Balance Transfer';
        cs1.Case_Model__c = 'ila';//#CH02
        cs1.cc_CPR_Expiry_Date__c=System.Today()+10;
        cs1.cc_CPR_Number__c='32343422';
        //CaseIDs.add(cs1.id);
        insert cs1;
        return cs1;
    }

    public void updateCase(Case objCase){
        
        Set<Id> CaseIDsUpdate = new Set<Id>();
        Case cs1 = new Case(id=objCase.id);
        test.startTest();
        
        if((cs1.Type=='Credit Card Application' || cs1.Type=='Credit Limit Increase Application') && cs1.Account.Segment__pc !='Staff' && cs1.cc_Approved_Requested_Card_Type__c =='PLATINUM_BALANCE_TRANSFER_01' && cs1.cc_Approved_Requested_Card_Type__c != null){        
            cs1.cc_Credit_Pre_Screening_Result__c = 'Accept';
            cs1.cc_Application_Stages__c = 'Credit Pre-Screening';
            update cs1;
        
            cs1.cc_Credit_Evaluation_Result__c = 'Accept';
            cs1.cc_Application_Stages__c = 'Credit Evaluation';
            update cs1;
        
            cs1.cc_Credit_Verification_Result__c = 'Approve';
            cs1.cc_Application_Stages__c = 'Credit Verification';
            update cs1;
        
            cs1.cc_Credit_Approval_Result__c = 'Approve';
            cs1.cc_Application_Stages__c = 'Credit Approval';
            update cs1;
        
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
                    });
            /*.withRecipients(new List<dfsle.Recipient> {
                dfsle.Recipient.fromSource(
                    acc.FirstName + ' ' + acc.LastName,
                    acc.PersonEmail,
                    acc.PersonMobilePhone,
                    'Signer 1',
                    new dfsle.Entity(acc.Id))
                    });*/
        
            //Test.startTest();
            dfsle.Envelope myResult = dfsle.EnvelopeService.sendEnvelope(myEnvelope, true);
            //Test.stopTest();
        
            // Verify the results
            System.assertNotEquals(null, myResult);            
    } 
}



}
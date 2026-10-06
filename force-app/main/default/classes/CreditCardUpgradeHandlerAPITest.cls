@isTest
public class CreditCardUpgradeHandlerAPITest {
    public class MyCalloutMock implements HttpCalloutMock {
        public String testBody = '{"success": true, "message": "Credit card updated successfully"}'; // Default mock response
        public Integer testStatusCode = 200;

        public HttpResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"data":{"transitionInProgress":false,"currentSegment":{"segmentName":"REGULAR","segmentCrmId":"Regular"},"currentCards":[{"id":"10010522439126747125063583","cardName":"VIRTUAL","cardDisplayName":"Virtual","cardAfsId":"TestVirtualCards","productType":"Virtual","cardMinimumBalance":0,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":false,"limit":0,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"},{"id":"100105224391267471250615229","cardName":"CLASSIC","cardDisplayName":"Classic","cardAfsId":"Debit Classic","productType":"Classic","cardMinimumBalance":20,"order":0,"issuanceFee":0,"annualFee":0,"renewalFee":0,"replacementFee":0,"issuanceFeeVat":0.000,"annualFeeVat":0.000,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"limit":1000,"nextAnnualAnniversaryDate":"2021-06-18T07:55:26","discount":{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":true,"status":"Inactive"}],"segmentOptions":[{"segmentName":"STAFF","segmentCrmId":"Staff"},{"segmentName":"ROYAL_FAMILY","segmentCrmId":"Royal Family"},{"segmentName":"PREMIUM","segmentCrmId":"Premium"},{"segmentName":"PREMIUM_PLUS","segmentCrmId":"Premium Plus"},{"segmentName":"SENSITIVE","segmentCrmId":"Sensitive"}],"cardOptions":[{"cardName":"WORLD","cardDisplayName":"World","cardAfsId":"MasterCardWorld","productType":"World","cardMinimumBalance":0,"order":1,"issuanceFee":0.000,"annualFee":37.500,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":1.875,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":39.375},{"cardName":"ELITE","cardDisplayName":"Elite","cardAfsId":"WORLD_ELITE","productType":"World Elite","cardMinimumBalance":0,"order":2,"issuanceFee":0.000,"annualFee":75.000,"renewalFee":0.000,"replacementFee":0.000,"issuanceFeeVat":0.000,"annualFeeVat":3.750,"renewalFeeVat":0.000,"replacementFeeVat":0.000,"physical":true,"promotionStatus":"UPGRADE","limit":1000,"canBeOrdered":false,"canBeCancelled":false,"canBeBlocked":false,"canBeReissued":false,"canBeFrozen":false,"canBeUnFrozen":false,"mustBeActivated":false,"minimumBalanceIncludingVat":78.750}],"discountOptions":[{"name":"None","displayName":"No discount","discountPercentage":0},{"name":"Discount25","displayName":"25 percent discount","discountPercentage":25},{"name":"Discount50","displayName":"50 percent discount","discountPercentage":50},{"name":"Discount75","displayName":"75 percent discount","discountPercentage":75},{"name":"Free","displayName":"No charge","discountPercentage":100}]},"meta":{"code":"SGMT-1006","message":"Customer Segment Options retrieved successfully."}}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testUpdateCreditCardReqApiFromFlow() {
        // Create Account
        Account acc = new Account(
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId(),
            LastName = 'LastName new',
            PersonEmail = 'testAcc13@gmail.test',
            Mobile_Country_Code__pc = '973',
            PersonMobilePhone = '645383334000'
        );
        insert acc;

        // Create Credit Card Case
        Case creditCardCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId(),
            Subject = 'NewCreditCardApplicationTest',
            Description = 'Credit card Application Test for Duplicate Cards',
            Type = 'Credit Limit Increase Application',
            Sub_Type__c = 'Credit Limit Increase',
            Case_Model__c = 'ila',
            cc_Name_on_the_Card__c = 'ABC',
            cc_Embossing_Line_4__c = 'XYZ',
            cc_Requested_Card_Type__c = 'ILA_GULF_AIR_COBRAND_01',
            cc_Balance_Transfer_Amount__c = 1000,
            cc_Balance_Transfer_Card_Number__c = '5464564546000045',
            cc_Balance_Transfer_Type__c = 'Balance Transfer',
            cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',
            Priority = 'High',
            Awaiting_Customer_Feedback__c = false,
            Origin = 'Phone',
            AccountId = acc.Id,
            cc_Monthly_Income__c = 6000,
            cc_Passport_Number__c = 'RT546FRGF',
            cc_Passport_Expiry_Date__c = System.today() + 360,
            cc_Residence_Permit_No__c = '546',
            cc_Residence_Permit_Expiry_Date__c = System.today() + 360,
            cc_CPR_Expiry_Date__c = System.today() + 365,
            cc_CPR_Number__c = '237623823229323',
            Sub_Status__c = 'Pending',
            cc_Request_Type__c = 'permanent'
        );
        insert creditCardCase;

        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());

        Test.startTest();

        Case testCase = [SELECT Id FROM Case LIMIT 1];

        // Create a test data for UpgradeCreditCard
        CreditCardUpgradeHandlerAPI.UpgradeCreditCard testUpgradeCard = new CreditCardUpgradeHandlerAPI.UpgradeCreditCard();
        testUpgradeCard.caseId = testCase.Id; // Example Case Id
        testUpgradeCard.isNew = 'yes';
        testUpgradeCard.isResultFieldChange = 'no';

        // Add the test data to a list
        List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard> upgradeCardList = new List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard>{ testUpgradeCard };

        // Test the invocable method
        CreditCardUpgradeHandlerAPI.updateCreditCardReqApiFromFlow(upgradeCardList);
		CreditCardUpgradeHandlerAPI.SupplementaryCard supplementaryCard = new CreditCardUpgradeHandlerAPI.SupplementaryCard('1234567890', 'Test Cardholder');
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCreditCardReqApiFromFlow2() {
        // Create Account
        Account acc = new Account(
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId(),
            LastName = 'LastName new',
            PersonEmail = 'testAcc13@gmail.test',
            Mobile_Country_Code__pc = '973',
            PersonMobilePhone = '645383334000'
        );
        insert acc;

        // Create Credit Card Case
        Case creditCardCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId(),
            Subject = 'NewCreditCardApplicationTest',
            Description = 'Credit card Application Test for Duplicate Cards',
            Type = 'Credit Limit Increase Application',
            Sub_Type__c = 'Credit Limit Increase',
            Case_Model__c = 'ila',
            cc_Name_on_the_Card__c = 'ABC',
            cc_Embossing_Line_4__c = 'XYZ',
            cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01',
            cc_Balance_Transfer_Amount__c = 1000,
            cc_Balance_Transfer_Card_Number__c = '5464564546000045',
            cc_Balance_Transfer_Type__c = 'Balance Transfer',
            cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',
            Priority = 'High',
            Awaiting_Customer_Feedback__c = false,
            Origin = 'Phone',
            AccountId = acc.Id,
            cc_Monthly_Income__c = 6000,
            cc_Passport_Number__c = 'RT546FRGF',
            cc_Passport_Expiry_Date__c = System.today() + 360,
            cc_Residence_Permit_No__c = '546',
            cc_Residence_Permit_Expiry_Date__c = System.today() + 360,
            cc_CPR_Expiry_Date__c = System.today() + 365,
            cc_CPR_Number__c = '237623823229323',
            Sub_Status__c = 'Pending',
            cc_Request_Type__c = 'permanent'
        );
        insert creditCardCase;

        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());

        Test.startTest();

        Case testCase = [SELECT Id FROM Case LIMIT 1];

        // Create a test data for UpgradeCreditCard
        CreditCardUpgradeHandlerAPI.UpgradeCreditCard testUpgradeCard = new CreditCardUpgradeHandlerAPI.UpgradeCreditCard();
        testUpgradeCard.caseId = testCase.Id; // Example Case Id
        testUpgradeCard.isNew = 'yes';
        testUpgradeCard.isResultFieldChange = 'no';

        // Add the test data to a list
        List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard> upgradeCardList = new List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard>{ testUpgradeCard };

        // Test the invocable method
        CreditCardUpgradeHandlerAPI.updateCreditCardReqApiFromFlow(upgradeCardList);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCreditCardReqApiFromFlow3() {
        // Create Account
        Account acc = new Account(
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId(),
            LastName = 'LastName new',
            PersonEmail = 'testAcc13@gmail.test',
            Mobile_Country_Code__pc = '973',
            PersonMobilePhone = '645383334000'
        );
        insert acc;

        // Create Credit Card Case
        Case creditCardCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId(),
            Subject = 'NewCreditCardApplicationTest',
            Description = 'Credit card Application Test for Duplicate Cards',
            Type = 'Credit Limit Increase Application',
            Sub_Type__c = 'Credit Limit Increase',
            Case_Model__c = 'ila',
            cc_Name_on_the_Card__c = null,
            cc_Embossing_Line_4__c = 'XYZ',
            cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01',
            cc_Balance_Transfer_Amount__c = 1000,
            cc_Balance_Transfer_Card_Number__c = '5464564546000045',
            cc_Balance_Transfer_Type__c = 'Balance Transfer',
            cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',
            Priority = 'High',
            Awaiting_Customer_Feedback__c = false,
            Origin = 'Phone',
            AccountId = acc.Id,
            cc_Monthly_Income__c = 6000,
            cc_Passport_Number__c = 'RT546FRGF',
            cc_Passport_Expiry_Date__c = System.today() + 360,
            cc_Residence_Permit_No__c = '546',
            cc_Residence_Permit_Expiry_Date__c = System.today() + 360,
            cc_CPR_Expiry_Date__c = System.today() + 365,
            cc_CPR_Number__c = '237623823229323',
            Sub_Status__c = 'Pending',
            cc_Request_Type__c = 'permanent'
        );
        insert creditCardCase;

        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());

        Test.startTest();

        Case testCase = [SELECT Id FROM Case LIMIT 1];

        // Create a test data for UpgradeCreditCard
        CreditCardUpgradeHandlerAPI.UpgradeCreditCard testUpgradeCard = new CreditCardUpgradeHandlerAPI.UpgradeCreditCard();
        testUpgradeCard.caseId = testCase.Id; // Example Case Id
        testUpgradeCard.isNew = 'yes';
        testUpgradeCard.isResultFieldChange = 'no';

        // Add the test data to a list
        List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard> upgradeCardList = new List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard>{ testUpgradeCard };

        // Test the invocable method
        CreditCardUpgradeHandlerAPI.updateCreditCardReqApiFromFlow(upgradeCardList);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCreditCardReqApiFromFlow4() {
        // Create Account
        Account acc = new Account(
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId(),
            LastName = 'LastName new',
            PersonEmail = 'testAcc13@gmail.test',
            Mobile_Country_Code__pc = '973',
            PersonMobilePhone = '645383334000'
        );
        insert acc;

        // Create Credit Card Case
        Case creditCardCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId(),
            Subject = 'NewCreditCardApplicationTest',
            Description = 'Credit card Application Test for Duplicate Cards',
            Type = 'Credit Limit Increase Application',
            Sub_Type__c = 'Credit Limit Increase',
            Case_Model__c = 'ila',
            cc_Name_on_the_Card__c = null,
            cc_Embossing_Line_4__c = 'XYZ',
            cc_Requested_Card_Type__c = 'ILA_GULF_AIR_COBRAND_01',
            cc_Balance_Transfer_Amount__c = 1000,
            cc_Balance_Transfer_Card_Number__c = '5464564546000045',
            cc_Balance_Transfer_Type__c = 'Balance Transfer',
            cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',
            Priority = 'High',
            Awaiting_Customer_Feedback__c = false,
            Origin = 'Phone',
            AccountId = acc.Id,
            cc_Monthly_Income__c = 6000,
            cc_Passport_Number__c = 'RT546FRGF',
            cc_Passport_Expiry_Date__c = System.today() + 360,
            cc_Residence_Permit_No__c = '546',
            cc_Residence_Permit_Expiry_Date__c = System.today() + 360,
            cc_CPR_Expiry_Date__c = System.today() + 365,
            cc_CPR_Number__c = '237623823229323',
            Sub_Status__c = 'Pending',
            cc_Request_Type__c = 'permanent'
        );
        insert creditCardCase;

        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());

        Test.startTest();

        Case testCase = [SELECT Id FROM Case LIMIT 1];

        // Create a test data for UpgradeCreditCard
        CreditCardUpgradeHandlerAPI.UpgradeCreditCard testUpgradeCard = new CreditCardUpgradeHandlerAPI.UpgradeCreditCard();
        testUpgradeCard.caseId = testCase.Id; // Example Case Id
        testUpgradeCard.isNew = 'yes';
        testUpgradeCard.isResultFieldChange = 'no';

        // Add the test data to a list
        List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard> upgradeCardList = new List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard>{ testUpgradeCard };

        // Test the invocable method
        CreditCardUpgradeHandlerAPI.updateCreditCardReqApiFromFlow(upgradeCardList);
		CreditCardUpgradeHandlerAPI.SupplementaryCard supplementaryCard = new CreditCardUpgradeHandlerAPI.SupplementaryCard('1234567890', 'Test Cardholder');
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCreditCardReqApiFromFlow5() {
        // Create Account
        Account acc = new Account(
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId(),
            LastName = 'LastName new',
            PersonEmail = 'testAcc13@gmail.test',
            Mobile_Country_Code__pc = '973',
            PersonMobilePhone = '645383334000'
        );
        insert acc;

        // Create Credit Card Case
        Case creditCardCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId(),
            Subject = 'NewCreditCardApplicationTest',
            Description = 'Credit card Application Test for Duplicate Cards',
            Type = 'Credit Limit Increase Application',
            Sub_Type__c = 'Credit Limit Increase',
            Case_Model__c = 'ila',
            cc_Name_on_the_Card__c = 'ABC',
            cc_Embossing_Line_4__c = 'XYZ',
            cc_Requested_Card_Type__c = 'ILA_GULF_AIR_COBRAND_01',
            cc_Balance_Transfer_Amount__c = 1000,
            cc_Balance_Transfer_Card_Number__c = '5464564546000045',
            cc_Balance_Transfer_Type__c = 'Balance Transfer',
            cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',
            Priority = 'High',
            Awaiting_Customer_Feedback__c = false,
            Origin = 'Phone',
            AccountId = acc.Id,
            cc_Monthly_Income__c = 6000,
            cc_Passport_Number__c = 'RT546FRGF',
            cc_Passport_Expiry_Date__c = System.today() + 360,
            cc_Residence_Permit_No__c = '546',
            cc_Residence_Permit_Expiry_Date__c = System.today() + 360,
            cc_CPR_Expiry_Date__c = System.today() + 365,
            cc_CPR_Number__c = '237623823229323',
            Sub_Status__c = 'Pending',
            cc_Request_Type__c = 'permanent',
            cc_Credit_Approval_Result__c = 'Approve'
        );
        insert creditCardCase;

        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());

        Test.startTest();

        Case testCase = [SELECT Id FROM Case LIMIT 1];

        // Create a test data for UpgradeCreditCard
        CreditCardUpgradeHandlerAPI.UpgradeCreditCard testUpgradeCard = new CreditCardUpgradeHandlerAPI.UpgradeCreditCard();
        testUpgradeCard.caseId = testCase.Id; // Example Case Id
        testUpgradeCard.isNew = 'no';
        testUpgradeCard.isResultFieldChange = 'cc_Credit_Approval_Result__c';

        // Add the test data to a list
        List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard> upgradeCardList = new List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard>{ testUpgradeCard };

        // Test the invocable method
        CreditCardUpgradeHandlerAPI.updateCreditCardReqApiFromFlow(upgradeCardList);
		CreditCardUpgradeHandlerAPI.SupplementaryCard supplementaryCard = new CreditCardUpgradeHandlerAPI.SupplementaryCard('1234567890', 'Test Cardholder');
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCreditCardReqApiFromFlow6() {
        // Create Account
        Account acc = new Account(
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId(),
            LastName = 'LastName new',
            PersonEmail = 'testAcc13@gmail.test',
            Mobile_Country_Code__pc = '973',
            PersonMobilePhone = '645383334000'
        );
        insert acc;

        // Create Credit Card Case
        Case creditCardCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId(),
            Subject = 'NewCreditCardApplicationTest',
            Description = 'Credit card Application Test for Duplicate Cards',
            Type = 'Credit Limit Increase Application',
            Sub_Type__c = 'Credit Limit Increase',
            Case_Model__c = 'ila',
            cc_Name_on_the_Card__c = 'ABC',
            cc_Embossing_Line_4__c = 'XYZ',
            cc_Requested_Card_Type__c = 'ILA_GULF_AIR_COBRAND_01',
            cc_Balance_Transfer_Amount__c = 1000,
            cc_Balance_Transfer_Card_Number__c = '5464564546000045',
            cc_Balance_Transfer_Type__c = 'Balance Transfer',
            cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',
            Priority = 'High',
            Awaiting_Customer_Feedback__c = false,
            Origin = 'Phone',
            AccountId = acc.Id,
            cc_Monthly_Income__c = 6000,
            cc_Passport_Number__c = 'RT546FRGF',
            cc_Passport_Expiry_Date__c = System.today() + 360,
            cc_Residence_Permit_No__c = '546',
            cc_Residence_Permit_Expiry_Date__c = System.today() + 360,
            cc_CPR_Expiry_Date__c = System.today() + 365,
            cc_CPR_Number__c = '237623823229323',
            Sub_Status__c = 'Pending',
            cc_Request_Type__c = 'permanent',
            cc_Credit_Approval_Result__c = 'Decline'
        );
        insert creditCardCase;

        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());

        Test.startTest();

        Case testCase = [SELECT Id FROM Case LIMIT 1];

        // Create a test data for UpgradeCreditCard
        CreditCardUpgradeHandlerAPI.UpgradeCreditCard testUpgradeCard = new CreditCardUpgradeHandlerAPI.UpgradeCreditCard();
        testUpgradeCard.caseId = testCase.Id; // Example Case Id
        testUpgradeCard.isNew = 'no';
        testUpgradeCard.isResultFieldChange = 'cc_Credit_Approval_Result__c';

        // Add the test data to a list
        List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard> upgradeCardList = new List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard>{ testUpgradeCard };

        // Test the invocable method
        CreditCardUpgradeHandlerAPI.updateCreditCardReqApiFromFlow(upgradeCardList);
		CreditCardUpgradeHandlerAPI.SupplementaryCard supplementaryCard = new CreditCardUpgradeHandlerAPI.SupplementaryCard('1234567890', 'Test Cardholder');
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCreditCardReqApiFromFlow7() {
        // Create Account
        Account acc = new Account(
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId(),
            LastName = 'LastName new',
            PersonEmail = 'testAcc13@gmail.test',
            Mobile_Country_Code__pc = '973',
            PersonMobilePhone = '645383334000'
        );
        insert acc;

        // Create Credit Card Case
        Case creditCardCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId(),
            Subject = 'NewCreditCardApplicationTest',
            Description = 'Credit card Application Test for Duplicate Cards',
            Type = 'Credit Limit Increase Application',
            Sub_Type__c = 'Credit Limit Increase',
            Case_Model__c = 'ila',
            cc_Name_on_the_Card__c = 'ABC',
            cc_Embossing_Line_4__c = 'XYZ',
            cc_Requested_Card_Type__c = 'ILA_GULF_AIR_COBRAND_01',
            cc_Balance_Transfer_Amount__c = 1000,
            cc_Balance_Transfer_Card_Number__c = '5464564546000045',
            cc_Balance_Transfer_Type__c = 'Balance Transfer',
            cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',
            Priority = 'High',
            Awaiting_Customer_Feedback__c = false,
            Origin = 'Phone',
            AccountId = acc.Id,
            cc_Monthly_Income__c = 6000,
            cc_Passport_Number__c = 'RT546FRGF',
            cc_Passport_Expiry_Date__c = System.today() + 360,
            cc_Residence_Permit_No__c = '546',
            cc_Residence_Permit_Expiry_Date__c = System.today() + 360,
            cc_CPR_Expiry_Date__c = System.today() + 365,
            cc_CPR_Number__c = '237623823229323',
            Sub_Status__c = 'Pending',
            cc_Request_Type__c = 'permanent',
            cc_HR_Result__c = 'Cancelled by Customer'
        );
        insert creditCardCase;

        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());

        Test.startTest();

        Case testCase = [SELECT Id FROM Case LIMIT 1];

        // Create a test data for UpgradeCreditCard
        CreditCardUpgradeHandlerAPI.UpgradeCreditCard testUpgradeCard = new CreditCardUpgradeHandlerAPI.UpgradeCreditCard();
        testUpgradeCard.caseId = testCase.Id; // Example Case Id
        testUpgradeCard.isNew = 'no';
        testUpgradeCard.isResultFieldChange = 'cc_Credit_Approval_Result__c';

        // Add the test data to a list
        List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard> upgradeCardList = new List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard>{ testUpgradeCard };

        // Test the invocable method
        CreditCardUpgradeHandlerAPI.updateCreditCardReqApiFromFlow(upgradeCardList);
		CreditCardUpgradeHandlerAPI.SupplementaryCard supplementaryCard = new CreditCardUpgradeHandlerAPI.SupplementaryCard('1234567890', 'Test Cardholder');
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCreditCardReqApiFromFlow8() {
        // Create Account
        Account acc = new Account(
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId(),
            LastName = 'LastName new',
            PersonEmail = 'testAcc13@gmail.test',
            Mobile_Country_Code__pc = '973',
            PersonMobilePhone = '645383334000'
        );
        insert acc;

        // Create Credit Card Case
        Case creditCardCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Upgrade Request').getRecordTypeId(),
            Subject = 'NewCreditCardApplicationTest',
            Description = 'Credit card Application Test for Duplicate Cards',
            Type = 'Credit Card Upgrade',
            Sub_Type__c = 'Credit Card Upgrade - No Limit Increase',
            Case_Model__c = 'ila',
            cc_Name_on_the_Card__c = 'ABC',
            cc_Embossing_Line_4__c = 'XYZ',
            cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01',
            cc_Balance_Transfer_Amount__c = 1000,
            cc_Balance_Transfer_Card_Number__c = '5464564546000045',
            cc_Balance_Transfer_Type__c = 'Balance Transfer',
            cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',
            Priority = 'High',
            Awaiting_Customer_Feedback__c = false,
            Origin = 'Phone',
            AccountId = acc.Id,
            cc_Monthly_Income__c = 6000,
            cc_Passport_Number__c = 'RT546FRGF',
            cc_Passport_Expiry_Date__c = System.today() + 360,
            cc_Residence_Permit_No__c = '546',
            cc_Residence_Permit_Expiry_Date__c = System.today() + 360,
            cc_CPR_Expiry_Date__c = System.today() + 365,
            cc_CPR_Number__c = '237623823229323',
            Sub_Status__c = 'Pending',
            Operation_Result__c = 'Upgrade Completed'
        );
        insert creditCardCase;

        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());

        Test.startTest();

        Case testCase = [SELECT Id FROM Case LIMIT 1];

        // Create a test data for UpgradeCreditCard
        CreditCardUpgradeHandlerAPI.UpgradeCreditCard testUpgradeCard = new CreditCardUpgradeHandlerAPI.UpgradeCreditCard();
        testUpgradeCard.caseId = testCase.Id; // Example Case Id
        testUpgradeCard.isNew = 'no';
        testUpgradeCard.isResultFieldChange = 'Operation_Result__c';

        // Add the test data to a list
        List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard> upgradeCardList = new List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard>{ testUpgradeCard };

        // Test the invocable method
        CreditCardUpgradeHandlerAPI.updateCreditCardReqApiFromFlow(upgradeCardList);
		CreditCardUpgradeHandlerAPI.SupplementaryCard supplementaryCard = new CreditCardUpgradeHandlerAPI.SupplementaryCard('1234567890', 'Test Cardholder');
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCreditCardReqApiFromFlow9() {
        // Create Account
        Account acc = new Account(
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId(),
            LastName = 'LastName new',
            PersonEmail = 'testAcc13@gmail.test',
            Mobile_Country_Code__pc = '973',
            PersonMobilePhone = '645383334000'
        );
        insert acc;

        // Create Credit Card Case
        Case creditCardCase = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card Upgrade Request').getRecordTypeId(),
            Subject = 'NewCreditCardApplicationTest',
            Description = 'Credit card Application Test for Duplicate Cards',
            Type = 'Credit Card Upgrade',
            Sub_Type__c = 'Credit Card Upgrade - No Limit Increase',
            Case_Model__c = 'ila',
            cc_Name_on_the_Card__c = 'ABC',
            cc_Embossing_Line_4__c = 'XYZ',
            cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01',
            cc_Balance_Transfer_Amount__c = 1000,
            cc_Balance_Transfer_Card_Number__c = '5464564546000045',
            cc_Balance_Transfer_Type__c = 'Balance Transfer',
            cc_Balance_Transfer_Card_Provider__c = 'Test ABC Bank',
            Priority = 'High',
            Awaiting_Customer_Feedback__c = false,
            Origin = 'Phone',
            AccountId = acc.Id,
            cc_Monthly_Income__c = 6000,
            cc_Passport_Number__c = 'RT546FRGF',
            cc_Passport_Expiry_Date__c = System.today() + 360,
            cc_Residence_Permit_No__c = '546',
            cc_Residence_Permit_Expiry_Date__c = System.today() + 360,
            cc_CPR_Expiry_Date__c = System.today() + 365,
            cc_CPR_Number__c = '237623823229323',
            Sub_Status__c = 'Pending',
            Operation_Result__c = 'Cancelled by Customer'
        );
        insert creditCardCase;

        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());

        Test.startTest();

        Case testCase = [SELECT Id FROM Case LIMIT 1];

        // Create a test data for UpgradeCreditCard
        CreditCardUpgradeHandlerAPI.UpgradeCreditCard testUpgradeCard = new CreditCardUpgradeHandlerAPI.UpgradeCreditCard();
        testUpgradeCard.caseId = testCase.Id; // Example Case Id
        testUpgradeCard.isNew = 'no';
        testUpgradeCard.isResultFieldChange = 'Operation_Result__c';

        // Add the test data to a list
        List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard> upgradeCardList = new List<CreditCardUpgradeHandlerAPI.UpgradeCreditCard>{ testUpgradeCard };

        // Test the invocable method
        CreditCardUpgradeHandlerAPI.updateCreditCardReqApiFromFlow(upgradeCardList);
		CreditCardUpgradeHandlerAPI.SupplementaryCard supplementaryCard = new CreditCardUpgradeHandlerAPI.SupplementaryCard('1234567890', 'Test Cardholder');
        Test.stopTest();
    }
}
@isTest
public class ConvertCreditCardCreationTest {
    public class SuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
    public class FailureMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setBody('{"status":"error"}');
            res.setStatusCode(400);
            return res;
        }
    }
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
    static void unitTest1() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardCreation.convertCreditCard wrapper = new ConvertCreditCardCreation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'yes';
        wrapper.isResultFieldChange = 'no';
        
        List<ConvertCreditCardCreation.convertCreditCard> inputList = new List<ConvertCreditCardCreation.convertCreditCard>{wrapper};
            
            ConvertCreditCardCreation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
     @isTest
    static void unitTest2() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Pre_Screening_Result__c = 'Accept');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Pre_Screening_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
     @isTest
    static void unitTest3() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Pre_Screening_Result__c = 'Discrepancy in Documents');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Pre_Screening_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
     @isTest
    static void unitTest4() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Pre_Screening_Result__c = 'Request Documents');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Pre_Screening_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
     @isTest
    static void unitTest5() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Pre_Screening_Result__c = 'Request Documents');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Pre_Screening_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
      @isTest
    static void unitTest6() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Pre_Screening_Result__c = 'Refer to Service Center');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Pre_Screening_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
     @isTest
    static void unitTest7() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Evaluation_Result__c = 'Accept');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Evaluation_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
    @isTest
    static void unitTest8() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Evaluation_Result__c = 'Refer to Service Center');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Evaluation_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
    @isTest
    static void unitTest9() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Verification_Result__c = 'Approve');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Verification_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
     @isTest
    static void unitTest10() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Verification_Result__c = 'Refer to Service Center');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Verification_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
     @isTest
    static void unitTest11() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Approval_Result__c = 'Approve');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Approval_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
     @isTest
    static void unitTest12() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Approval_Result__c = 'Refer to Service Center');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Approval_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
    @isTest
    static void unitTest13() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123',Nationality__pc = 'BH',Segment__pc = 'Regular');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Approval_Result__c = 'Send to Signature Verification',cc_Approved_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Approval_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
     @isTest
    static void unitTest14() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Service_Centre_Result__c = 'Return to Pre-Screener');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Service_Centre_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
     @isTest
    static void unitTest15() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Signature_Verifier_Result__c = 'Accept');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Signature_Verifier_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
     @isTest
    static void unitTest16() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Signature_Verifier_Result__c = 'Cancelled by Customer');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = '';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
	 @isTest
    static void unitTest17() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Signature_Verifier_Result__c = 'Decline');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = '';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
	 @isTest
    static void unitTest18() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Approval_Result__c = 'Decline');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = '';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
	 @isTest
    static void unitTest19() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Verification_Result__c = 'Decline');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = '';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
	@isTest
    static void unitTest20() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Evaluation_Result__c = 'Decline');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = '';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }

	@isTest
    static void unitTest21() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Pre_Screening_Result__c = 'Decline');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = '';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
@isTest
    static void unitTest22() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Pre_Screening_Result__c = 'Cancelled by Customer');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = '';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
@isTest
    static void unitTest23() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Evaluation_Result__c = 'Cancelled by Customer');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = '';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
@isTest
    static void unitTest24() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Verification_Result__c = 'Cancelled by Customer');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = '';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
    @isTest
    static void unitTest25() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Approval_Result__c = 'Cancelled by Customer');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = '';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
     @isTest
    static void unitTest26() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Pre_Screening_Result__c = 'Accept',Campaign_Name__c = 'Ila Blue Secured');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Pre_Screening_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
     @isTest
    static void unitTest27() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Evaluation_Result__c = 'Accept',Campaign_Name__c = 'Ila Blue Secured');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Evaluation_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
     @isTest
    static void unitTest28() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Verification_Result__c = 'Approve',Campaign_Name__c = 'Ila Blue Secured');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Verification_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
    @isTest
    static void unitTest29() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Approval_Result__c = 'Approve',Campaign_Name__c = 'Ila Blue Secured');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Approval_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
    @isTest
    static void unitTest30() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Approval_Result__c = 'Send to Signature Verification',Approved_Campaign_Name__c = 'Ila Blue Secured');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Approval_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
    @isTest
    static void unitTest31() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Requested_Card_Type__c = 'PLATINUM_BALANCE_TRANSFER_01',cc_Embossing_Line_4__c = 'Frank',cc_Balance_Transfer_Card_Provider__c = 'Ila Bank',
                            cc_Balance_Transfer_Amount__c = 2000.00,cc_Balance_Transfer_Type__c = 'Balance Transfer',ccol_Hold_Account_IBAN__c = 'BH345435444554',ccol_Hold_Account__c = 'Account',cc_Balance_Transfer_Card_Number__c = '************7645');
        insert cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardCreation.convertCreditCard wrapper = new ConvertCreditCardCreation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'yes';
        wrapper.isResultFieldChange = 'no';
        
        List<ConvertCreditCardCreation.convertCreditCard> inputList = new List<ConvertCreditCardCreation.convertCreditCard>{wrapper};
            
            ConvertCreditCardCreation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
    @isTest
    static void unitTest32() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Pre_Screening_Result__c = 'Discrepancy in Documents',cc_Credit_Pre_Screener_Comments__c = 'Test Comments 1');
        insert cse;
        
        cse.cc_Credit_Pre_Screening_Result__c = 'Refer to Service Center';
        cse.cc_CPR_Number__c = '4355332';
        cse.cc_CPR_Expiry_Date__c = system.today() + 100;
        cse.cc_Credit_Pre_Screener_Comments__c = 'Test Comments 2';
        update cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Pre_Screening_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
     @isTest
    static void unitTest33() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Pre_Screening_Result__c = 'Accept',cc_Approved_Credit_Limit__c = 1000,cc_Credit_Evaluation_Result__c = 'Refer to Service Center',cc_Credit_Evaluator_Comments__c = 'Test Comments 1');
        insert cse;
        
        cse.cc_Credit_Evaluation_Result__c = 'Accept';
        cse.cc_CPR_Number__c = '4355332';
        cse.cc_CPR_Expiry_Date__c = system.today() + 100;
        cse.cc_Credit_Evaluator_Comments__c = 'Test Comments 2';
        update cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Evaluation_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
      @isTest
    static void unitTest34() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Pre_Screening_Result__c = 'Accept',cc_Approved_Credit_Limit__c = 1000,cc_Credit_Evaluation_Result__c = 'Accept',cc_Credit_Verification_Result__c = 'Refer to Service Center');
        insert cse;
        
        cse.cc_Credit_Verification_Result__c = 'Approve';
        cse.cc_CPR_Number__c = '4355332';
        cse.cc_CPR_Expiry_Date__c = system.today() + 100;
        cse.cc_Credit_Verifier_Comments__c = 'Test Comments 2';
        update cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Verification_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
    @isTest
    static void unitTest35() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Pre_Screening_Result__c = 'Accept',cc_Approved_Credit_Limit__c = 1000,cc_Credit_Evaluation_Result__c = 'Accept',cc_Credit_Verification_Result__c = 'Approve',cc_Credit_Approval_Result__c = 'Refer to Service Center',cc_Credit_Approver_Comments__c = 'Test Comments 1');
        insert cse;
        
        cse.cc_Credit_Approval_Result__c = 'Approve';
        cse.cc_CPR_Number__c = '4355332';
        cse.cc_CPR_Expiry_Date__c = system.today() + 100;
        cse.cc_Credit_Approver_Comments__c = 'Test Comments 2';
        update cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Credit_Approval_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
    @isTest
    static void unitTest36() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Pre_Screening_Result__c = 'Accept',cc_Approved_Credit_Limit__c = 1000,cc_Credit_Evaluation_Result__c = 'Accept',cc_Credit_Verification_Result__c = 'Approve',cc_Credit_Approval_Result__c = 'Refer to Service Center');
        insert cse;
        
        cse.cc_Service_Centre_Result__c = 'Return to Approver';
        cse.cc_CPR_Number__c = '4355332';
        cse.cc_CPR_Expiry_Date__c = system.today() + 100;
        cse.cc_Service_Centre_Comments__c = 'Test Comments 2';
        update cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Service_Centre_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
    
    @isTest
    static void unitTest37() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Pre_Screening_Result__c = 'Accept',cc_Approved_Credit_Limit__c = 1000,cc_Credit_Evaluation_Result__c = 'Accept',cc_Credit_Verification_Result__c = 'Approve',cc_Credit_Approval_Result__c = 'Send to Signature Verification');
        insert cse;
        
        cse.cc_Signature_Verifier_Result__c = 'Accept';
        cse.cc_CPR_Number__c = '4355332';
        cse.cc_CPR_Expiry_Date__c = system.today() + 100;
        cse.cc_Signature_Verification_Comments__c = 'Test Comments 2';
        update cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = 'cc_Signature_Verifier_Result__c';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
     @isTest
    static void unitTest38() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Pre_Screening_Result__c = 'Accept',cc_Approved_Credit_Limit__c = 1000,cc_Credit_Evaluation_Result__c = 'Accept',cc_Credit_Verification_Result__c = 'Approve',cc_Credit_Approval_Result__c = 'Escalate to Business Team');
        insert cse;
        
        cse.cc_Business_Approval_Result__c = 'Approve';
        cse.cc_CPR_Number__c = '4355332';
        cse.cc_CPR_Expiry_Date__c = system.today() + 100;
        cse.cc_Credit_Business_Team_Comments__c = 'Test Comments 2';
        update cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = '';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
    @isTest
    static void unitTest39() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila',cc_Credit_Pre_Screening_Result__c = 'Accept',cc_Approved_Credit_Limit__c = 1000,cc_Credit_Evaluation_Result__c = 'Accept',cc_Credit_Verification_Result__c = 'Approve',cc_Credit_Approval_Result__c = 'Escalate to CEO');
        insert cse;
        
        cse.cc_CEO_Result__c = 'Accept';
        cse.cc_CPR_Number__c = '4355332';
        cse.cc_CPR_Expiry_Date__c = system.today() + 100;
        cse.cc_CEO_Comments__c = 'Test Comments 2';
        update cse;
        
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        
        Test.startTest();
        Case c = [SELECT Id FROM Case LIMIT 1];
        System.debug('Case Id in test Class:'+c);
        ConvertCreditCardUpdation.convertCreditCard wrapper = new ConvertCreditCardUpdation.convertCreditCard();
        
        wrapper.caseId = c.Id;
        wrapper.isNew = 'no';
        wrapper.isResultFieldChange = '';
        
        List<ConvertCreditCardUpdation.convertCreditCard> inputList = new List<ConvertCreditCardUpdation.convertCreditCard>{wrapper};
            
            ConvertCreditCardUpdation.createCreditCardReqApiFromFlow(inputList);
        
        Test.stopTest();
    }
    
    
}
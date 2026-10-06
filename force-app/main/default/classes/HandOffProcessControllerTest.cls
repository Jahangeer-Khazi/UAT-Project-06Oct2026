@isTest
private class HandOffProcessControllerTest {

    @isTest
    static void testSubmitForm_EarlySettlement() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',CustomerStatus__c=null,Subscription_Model__pc = 'alburaq',Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',isSubmitted__c = true), 'TestFactoryDefaults.CaseDefaults',true);

        Map<Object, Object> loanObj = new Map<Object, Object>{
            'monthlyInstallment' => 2500,
            'transactProduct' => 'Loan001',
            'currency' => 'BHD'
        };

        Test.startTest();
        HandOffProcessController.submitForm(
            testCase.Id, 'Reason1', 100.0, 'FEE1', 'Reversal1',
            'Deferment1', 2, 'Keep same installment amount', 5000, 12, 6.5, 1,
            'Customer requested advance pay', 'Advance Payment', 'Change loan term', 'LN001', loanObj
        );
        Test.stopTest();
    }

    @isTest
    static void testSubmitForm_PartialSettlement() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',CustomerStatus__c=null,Subscription_Model__pc = 'alburaq',Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',isSubmitted__c = true), 'TestFactoryDefaults.CaseDefaults',true);

        Map<Object, Object> loanObj = new Map<Object, Object>{
            'monthlyInstallment' => 3000,
            'transactProduct' => 'Loan002',
            'currency' => 'BHD'
        };

        Test.startTest();
        HandOffProcessController.submitForm(
            testCase.Id, 'Reason2', 200.0, 'FEE2', 'Reversal2',
            'Deferment2', 3, 'Keep same installment amount', 6000, 10, 7.0, 2,
            'Customer requested advance pay', 'Advance Payment', 'Change loan term', 'LN002', loanObj
        );
        Test.stopTest();
    }

    @isTest
    static void testSubmitForm_Topup() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',CustomerStatus__c=null,Subscription_Model__pc = 'alburaq',Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',Type = 'New Loan / Finance Service Request',Sub_Type__c = 'Advance Payment',isSubmitted__c = true), 'TestFactoryDefaults.CaseDefaults',true);

        Map<Object, Object> loanObj = new Map<Object, Object>{
            'monthlyInstallment' => 3500,
            'transactProduct' => 'Loan003',
            'currency' => 'BHD'
        };

        Test.startTest();
        HandOffProcessController.submitForm(
            testCase.Id, 'Reason3', 300.0, 'FEE3', 'Reversal3',
            'Deferment3', 4, 'Keep same installment amount', 7000, 8, 8.0, 3,
            'Customer requested advance pay', 'Advance Payment', 'Change loan term', 'LN003', loanObj
        );
        Test.stopTest();
    }

    @isTest
    static void testSubmitForm_Restructuring() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',CustomerStatus__c=null,Subscription_Model__pc = 'alburaq',Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',Type = 'New Loan / Finance Service Request',Sub_Type__c = 'Partial Settlement',isSubmitted__c = true), 'TestFactoryDefaults.CaseDefaults',true);

        Map<Object, Object> loanObj = new Map<Object, Object>{
            'monthlyInstallment' => 4000,
            'transactProduct' => 'Loan004',
            'currency' => 'BHD'
        };

        Test.startTest();
        HandOffProcessController.submitForm(
            testCase.Id, 'Reason4', 400.0, 'FEE4', 'Reversal4',
            'Deferment4', 5, 'Keep same installment amount', 8000, 6, 9.0, 4,
            'Customer requested advance pay', 'Advance Payment', 'Change loan term', 'LN004', loanObj
        );
        Test.stopTest();
    }

    @isTest
    static void testSubmitForm_Deferment() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',CustomerStatus__c=null,Subscription_Model__pc = 'alburaq',Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',Type = 'New Loan / Finance Service Request',Sub_Type__c = 'Instalment Deferment / Postponement',isSubmitted__c = true), 'TestFactoryDefaults.CaseDefaults',true);

        Map<Object, Object> loanObj = new Map<Object, Object>{
            'monthlyInstallment' => 4500,
            'transactProduct' => 'Loan005',
            'currency' => 'BHD'
        };

        Test.startTest();
        HandOffProcessController.submitForm(
            testCase.Id, 'Reason5', 500.0, 'FEE5', 'Reversal5',
            'Deferment5', 6, 'Keep same installment amount', 9000, 5, 10.0, 5,
            'Customer requested advance pay', 'Advance Payment', 'Change loan term', 'LN005', loanObj
        );
        Test.stopTest();
    }

    @isTest
    static void testSubmitForm_FeesReversal() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',CustomerStatus__c=null,Subscription_Model__pc = 'alburaq',Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',isSubmitted__c = true), 'TestFactoryDefaults.CaseDefaults',true);

        Map<Object, Object> loanObj = new Map<Object, Object>{
            'monthlyInstallment' => 2800,
            'transactProduct' => 'Loan006',
            'currency' => 'BHD'
        };

        Test.startTest();
        HandOffProcessController.submitForm(
            testCase.Id, 'Reason6', 600.0, 'FEE6', 'Reversal6',
            'Deferment6', 7, 'Keep same installment amount', 10000, 9, 11.0, 1,
            'Customer requested advance pay', 'Advance Payment', 'Change loan term', 'LN006', loanObj
        );
        Test.stopTest();
    }

    @isTest
    static void testSubmitForm_AdvancePayment() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',CustomerStatus__c=null,Subscription_Model__pc = 'alburaq',Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',Type = 'New Loan / Finance Service Request',Sub_Type__c = 'Early Settlement',isSubmitted__c = true), 'TestFactoryDefaults.CaseDefaults',true);

        Map<Object, Object> loanObj = new Map<Object, Object>{
            'monthlyInstallment' => 3100,
            'transactProduct' => 'Loan007',
            'currency' => 'BHD'
        };

        Test.startTest();
        HandOffProcessController.submitForm(
            testCase.Id, 'Reason7', 700.0, 'FEE7', 'Reversal7',
            'Deferment7', 8, 'Keep same installment amount', 11000, 7, 12.0, 2,
            'Customer requested advance pay', 'Advance Payment', 'Change loan term', 'LN007', loanObj
        );
        Test.stopTest();
    }

    @isTest
    static void testSubmitForm_UnknownSubtype() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',CustomerStatus__c=null,Subscription_Model__pc = 'alburaq',Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',Type = 'New Loan / Finance Service Request',Sub_Type__c = 'Restructuring',isSubmitted__c = true), 'TestFactoryDefaults.CaseDefaults',true);

        Map<Object, Object> loanObj = new Map<Object, Object>{
            'monthlyInstallment' => 3200,
            'transactProduct' => 'Loan008',
            'currency' => 'BHD'
        };

        Test.startTest();
        HandOffProcessController.submitForm(
            testCase.Id, 'Reason8', 800.0, 'FEE8', 'Reversal8',
            'Deferment8', 9, 'Keep same installment amount', 12000, 4, 13.0, 3,
            'Customer requested advance pay', 'Advance Payment', 'Change loan term', 'LN008', loanObj
        );
        Test.stopTest();
    }
    
    @isTest static void testGetCaseAnnexFields() { 
        Case testCase = (Case)TestDataFactory.createSObject(new Case(), true); 
        CaseAnnex__c testCaseAnnex = new CaseAnnex__c( Case__c = testCase.Id, TotalTopUpAmount__c = 100, TotalNumberOfInstallments__c = 5 ); 
        insert testCaseAnnex; 
        Map<String, Object> result = HandOffProcessController.getCaseAnnexFields(testCase.Id); 
    }
    
    
     @isTest
    static void testSyncForm_EarlySettlement() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',CustomerStatus__c=null,Subscription_Model__pc = 'alburaq',Archived__pc = false, Region_Flag__pc = 'Bahrain'), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',Type = 'New Loan / Finance Service Request', Sub_Type__c = 'Early Settlement', isSubmitted__c = true, cc_PCI_Id__c = 'LN001'), 'TestFactoryDefaults.CaseDefaults',true);
        Map<Object, Object> loanObj = new Map<Object, Object>{
            'monthlyInstallment' => 2500,
            'transactProduct' => 'Loan001',
            'currency' => 'BHD'
        };
        Test.setMock(HttpCalloutMock.class, new Loans_ServiceApiCallsMock());
        Test.startTest();
        HandOffProcessController.syncForm(testCase.Id, 'LN001', loanObj);
        Test.stopTest();
        
        Case updatedCase = [SELECT Last_Api_Call_Status__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('Success', updatedCase.Last_Api_Call_Status__c);
    }
    @isTest
    static void testSyncForm_PartialSettlement() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',CustomerStatus__c=null,Subscription_Model__pc = 'alburaq',Archived__pc = false, Region_Flag__pc = 'Bahrain'), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq', Type = 'New Loan / Finance Service Request', Sub_Type__c = 'Partial Settlement', isSubmitted__c = true, cc_PCI_Id__c = 'LN002'), 'TestFactoryDefaults.CaseDefaults',true);
        Map<Object, Object> loanObj = new Map<Object, Object>{
            'monthlyInstallment' => 3000,
            'transactProduct' => 'Loan002',
            'currency' => 'BHD'
        };
        Test.setMock(HttpCalloutMock.class, new Loans_ServiceApiCallsMock());
        Test.startTest();
        HandOffProcessController.syncForm(testCase.Id, 'LN002', loanObj);
        Test.stopTest();
        
        Case updatedCase = [SELECT Last_Api_Call_Status__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('Success', updatedCase.Last_Api_Call_Status__c);
    }
    @isTest
    static void testSyncForm_Topup() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',CustomerStatus__c=null,Subscription_Model__pc = 'alburaq',Archived__pc = false, Region_Flag__pc = 'Bahrain'), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq', Type = 'New Loan / Finance Service Request', Sub_Type__c = 'Top-up', isSubmitted__c = true, cc_PCI_Id__c = 'LN003'), 'TestFactoryDefaults.CaseDefaults',true);
        Map<Object, Object> loanObj = new Map<Object, Object>{
            'monthlyInstallment' => 3500,
            'transactProduct' => 'Loan003',
            'currency' => 'BHD'
        };
        Test.setMock(HttpCalloutMock.class, new Loans_ServiceApiCallsMock());
        Test.startTest();
        HandOffProcessController.syncForm(testCase.Id, 'LN003', loanObj);
        Test.stopTest();
        
        Case updatedCase = [SELECT Last_Api_Call_Status__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('Success', updatedCase.Last_Api_Call_Status__c);
    }
    @isTest
    static void testSyncForm_Restructuring() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',CustomerStatus__c=null,Subscription_Model__pc = 'alburaq',Archived__pc = false, Region_Flag__pc = 'Bahrain'), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq', Type = 'New Loan / Finance Service Request', Sub_Type__c = 'Restructuring', isSubmitted__c = true, cc_PCI_Id__c = 'LN004'), 'TestFactoryDefaults.CaseDefaults',true);
        Map<Object, Object> loanObj = new Map<Object, Object>{
            'monthlyInstallment' => 4000,
            'transactProduct' => 'Loan004',
            'currency' => 'BHD'
        };
        Test.setMock(HttpCalloutMock.class, new Loans_ServiceApiCallsMock());
        Test.startTest();
        HandOffProcessController.syncForm(testCase.Id, 'LN004', loanObj);
        Test.stopTest();
        
        Case updatedCase = [SELECT Last_Api_Call_Status__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('Success', updatedCase.Last_Api_Call_Status__c);
    }
    @isTest
    static void testSyncForm_Deferment() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',CustomerStatus__c=null,Subscription_Model__pc = 'alburaq',Archived__pc = false, Region_Flag__pc = 'Bahrain'), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq', Type = 'New Loan / Finance Service Request', Sub_Type__c = 'Instalment Deferment / Postponement', isSubmitted__c = true, cc_PCI_Id__c = 'LN005'), 'TestFactoryDefaults.CaseDefaults',true);
        Map<Object, Object> loanObj = new Map<Object, Object>{
            'monthlyInstallment' => 4500,
            'transactProduct' => 'Loan005',
            'currency' => 'BHD'
        };
        Test.setMock(HttpCalloutMock.class, new Loans_ServiceApiCallsMock());
        Test.startTest();
        HandOffProcessController.syncForm(testCase.Id, 'LN005', loanObj);
        Test.stopTest();
        
        Case updatedCase = [SELECT Last_Api_Call_Status__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals('Success', updatedCase.Last_Api_Call_Status__c);
    }

}
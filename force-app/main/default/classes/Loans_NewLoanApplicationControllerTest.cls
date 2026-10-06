@isTest
public class Loans_NewLoanApplicationControllerTest {

    @testSetup
    static void setup() {
        Case testCase = createTestCase();
 
    }
    
    private static Case createTestCase() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456', Subscription_Model__pc = 'alburaq', CustomerStatus__c=null,Archived__pc = false, x_canary__pc = 'canary'), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email'), 'TestFactoryDefaults.CaseDefaults',true);
        System.debug('testCase>>'+testCase);
        return testCase;
    }
    @isTest
    static void testCallLoanOptionsAPI() {
         Case testCase = [SELECT Id, Account.CIF__pc, Case_Model__c FROM Case LIMIT 1];
        String cif = testCase.Account.CIF__pc;
        String caseModel = testCase.Case_Model__c;

        Test.startTest();
  
        ApiConnection.Response response = Loans_NewLoanApplicationController.callLoanOptionsAPI(cif, caseModel);
 
        System.assertNotEquals(null, response);
         
        Test.stopTest();
    }
     @isTest
    static void testGetUserApplicationInfoAPI() {
       
         Case testCase = [SELECT Id, Account.CIF__pc, Case_Model__c FROM Case LIMIT 1];
        String cif = testCase.Account.CIF__pc;
        String caseModel = testCase.Case_Model__c;
        Test.startTest();
 
        ApiConnection.Response response = Loans_NewLoanApplicationController.getUserApplicationInfoAPI(cif, '67890',caseModel);
         
         System.assertNotEquals(null, response);
       
        Test.stopTest();
    }
    
    
    
    
    
       @isTest
    static void testGetExistingLiabilitiesAPI() {
     
        Case testCase = [SELECT Id, Account.CIF__pc, Case_Model__c FROM Case LIMIT 1];
        String cif = testCase.Account.CIF__pc;
        String caseModel = testCase.Case_Model__c;
        Test.startTest();
       
        ApiConnection.Response response = Loans_NewLoanApplicationController.getExistingLiabilitiesAPI(cif, caseModel,null,null,null);
        
        System.assertNotEquals(null, response);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCustomerProductsAPI() {
        Case testCase = [SELECT Id, Account.CIF__pc, Case_Model__c FROM Case LIMIT 1];
        String cif = testCase.Account.CIF__pc;
        String caseModel = testCase.Case_Model__c;
        Test.startTest();
         
        ApiConnection.Response response = Loans_NewLoanApplicationController.getCustomerProductsAPI(cif, caseModel);
        System.assertNotEquals(null, response);
     
        Test.stopTest();
    }
    
    @isTest
    static void testGetLoanCalculatorMatrixAPI() {
        Case testCase = [SELECT Id, Account.CIF__pc, Case_Model__c FROM Case LIMIT 1];
        String cif = testCase.Account.CIF__pc;
        String caseModel = testCase.Case_Model__c;
        Test.startTest(); 
        ApiConnection.Response response = Loans_NewLoanApplicationController.getLoanCalculatorMatrixAPI(cif, caseModel);
         System.assertNotEquals(null, response);
        Test.stopTest();
    }
    
    @isTest
    static void testGetAccountRecordPositiveUsecase() {
        Case testCase = [SELECT Id, AccountId, Account.CIF__pc, Case_Model__c FROM Case LIMIT 1];
        Test.startTest(); 
        Account response = Loans_NewLoanApplicationController.getAccountRecord(testCase.AccountId);
        Test.stopTest();
    }
    
    @isTest
    static void testGetAccountRecordNegativeUsecase() {
        Case testCase = [SELECT Id, AccountId, Account.CIF__pc, Case_Model__c FROM Case LIMIT 1];
        Test.startTest(); 
        try {
            Account response = Loans_NewLoanApplicationController.getAccountRecord(null);
        } Catch (Exception ex) {
            System.debug('Error -->'+ex);
        }
        
        Test.stopTest();
    }
}
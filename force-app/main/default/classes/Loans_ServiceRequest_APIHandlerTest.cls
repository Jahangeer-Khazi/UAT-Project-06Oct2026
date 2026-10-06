@isTest
public class Loans_ServiceRequest_APIHandlerTest {

    @testSetup
    static void setup() {
        Case testCase = createTestCase();
    }

    private static Case createTestCase() {
        /*Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',Subscription_Model__pc = 'alburaq',CustomerStatus__c=null,Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',Type = 'Top-up',Region_Flag__c = 'Bahrain', Resend_DocuSign__c = 'Email'), 'TestFactoryDefaults.CaseDefaults',true);
        CaseAnnex__c testRecord = new CaseAnnex__c(Case__c = testCase.Id);
        insert testRecord;*/
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',Subscription_Model__pc = 'alburaq',CustomerStatus__c=null,Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',Type = 'New Loan / Finance Service Request',Sub_Type__c = 'Top-up', cc_Business_Approval_Result__c  = 'Approve',Region_Flag__c = 'Bahrain', Resend_DocuSign__c = 'Email'), 'TestFactoryDefaults.CaseDefaults',true);
        CaseAnnex__c testRecord = new CaseAnnex__c(Case__c = testCase.Id);
        insert testRecord;
        testCase.CaseAnnex__C = testRecord.Id;
        update testCase;
        return testCase;
    }
    
    @isTest
    static void testServiceRequestHandlerMethod() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Loans_ServiceRequest_APIHandler.LoanWrapper input = new Loans_ServiceRequest_APIHandler.LoanWrapper();
        input.caseId = testCase.Id;
        input.isNew = 'no';
        input.objectSource = 'Case';
		input.changedField = 'cc_Business_Approval_Result__c';
        List<Loans_ServiceRequest_APIHandler.LoanWrapper> inputs = new List<Loans_ServiceRequest_APIHandler.LoanWrapper>{input};

        Test.startTest();
        List<String> result = Loans_ServiceRequest_APIHandler.serviceRequestHandlerFromFlow(inputs);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Expected one case Id in result');
        System.assertEquals(testCase.Id, result[0], 'Expected case Id to match input');
        
    }
    
    @isTest
    static void testServiceRequestHandlerExceptionMethod() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Loans_ServiceRequest_APIHandler.LoanWrapper input = new Loans_ServiceRequest_APIHandler.LoanWrapper();
        input.caseId = testCase.Id;
        input.isNew = 'no';
        input.objectSource = 'Case';
		input.changedField = 'cc_Contact_Centre_Result__c';
        List<Loans_ServiceRequest_APIHandler.LoanWrapper> inputs = new List<Loans_ServiceRequest_APIHandler.LoanWrapper>{input};

        Test.startTest();
        List<String> result = Loans_ServiceRequest_APIHandler.serviceRequestHandlerFromFlow(inputs);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Expected one case Id in result');
        System.assertEquals(testCase.Id, result[0], 'Expected case Id to match input');
        
    }
    @isTest
    static void testServiceRequestHandlerCaseAnnexnMethod() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Loans_ServiceRequest_APIHandler.LoanWrapper input = new Loans_ServiceRequest_APIHandler.LoanWrapper();
        input.caseId = testCase.Id;
        input.isNew = 'no';
        input.objectSource = 'CaseAnnex__c';
		input.changedField = 'cx_ln_Approved_Insurance_Premium__c';
        List<Loans_ServiceRequest_APIHandler.LoanWrapper> inputs = new List<Loans_ServiceRequest_APIHandler.LoanWrapper>{input};

        Test.startTest();
        List<String> result = Loans_ServiceRequest_APIHandler.serviceRequestHandlerFromFlow(inputs);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Expected one case Id in result');
        System.assertEquals(testCase.Id, result[0], 'Expected case Id to match input');
        
    }
    
    @isTest
    static void testEvalCriteira() {
        Case caseObj = [SELECT Id FROM Case LIMIT 1];
        CaseAnnex__c annex = [Select Id FROM CaseAnnex__c WHERE Case__c  =: caseObj.Id];
        annex.cx_ln_Product__c = 'Unsecured';
        annex.cx_ln_Business_Nature_Type__c = 'New Loan/Finance';
        
    	Boolean b = Loans_ServiceRequest_APIHandler.evaluateCriteria('Case',caseObj,annex,'CaseAnnex__c.cx_ln_Product__c;==;Unsecured&&CaseAnnex__c.cx_ln_Business_Nature_Type__c;!=;Buyout Loan/Finance');
    }
    
}
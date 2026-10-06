@isTest
private class CaseRelatedListControllerTest {
    @TestSetup
    static void setupTestData() {
        Account testEmployer = (Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        
        //String loanAppRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId(); //commented for Loans - NBA-13013
        String issueRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Issue').getRecordTypeId();
        
       // Case loanCase1 = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = loanAppRecordTypeId,ContactId = testEmployer.PersonContactId,AccountId = testEmployer.id, Case_Model__c = 'ila',Loan_Application_ID__c = '1234'), 'TestFactoryDefaults.CaseDefaults',true);//commented for Loans - NBA-13013
        Case issueCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = issueRecordTypeId,ContactId = testEmployer.PersonContactId,AccountId = testEmployer.id,Case_Model__c='ila'), 'TestFactoryDefaults.CaseDefaults',true);
    }
    
    @isTest
    static void testGetCaseRecordsForLoanApplication() {
        Account testEmployer = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
       // ApiConnection.Response response = CaseRelatedListController.getCaseRecords(testEmployer.Id, 'Loan_Application');//commented for Loans - NBA-13013
        Test.stopTest();
    }
    
    @isTest
    static void testGetCaseRecordsForCreditCard() {
        Account testEmployer = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        ApiConnection.Response response = CaseRelatedListController.getCaseRecords(testEmployer.Id, 'Issue');
        Test.stopTest();
    }
    
    @isTest
    static void testGetCaseRecordsNoResults() {
        Account testEmployer = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
       // ApiConnection.Response response = CaseRelatedListController.getCaseRecords(testEmployer.Id, 'Loan_Application');//commented for Loans - NBA-13013
        Test.stopTest();
    }
    
    @isTest
    static void testGetPicklistKeyValueMap() {
        Test.startTest();
        Map<String,String> result = CaseRelatedListController.getPicklistKeyValueMap('Case', 'Status');
        Test.stopTest();
    }
}
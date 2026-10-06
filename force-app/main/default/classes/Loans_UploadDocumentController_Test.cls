@isTest
private class Loans_UploadDocumentController_Test {
     @testSetup
    static void setup() {
        Case testCase = createTestCase();
 
    }
    
    private static Case createTestCase() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456', Subscription_Model__pc = 'alburaq', CustomerStatus__c=null,Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',Loan_Application_ID__c = '1234'), 'TestFactoryDefaults.CaseDefaults',true);
        System.debug('testCase>>'+testCase);
        return testCase;
    }

    @isTest
    static void testUploadDocument() {
       Case testCase = [SELECT Id FROM Case LIMIT 1];
	   String fileContent = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed blandit diam nec tortor vestibulum';
 
        Test.startTest();
        ApiConnection.Response response = Loans_UploadDocumentController.uploadDocument(testCase.Id, 'pdf', 'TestFileName', fileContent);
        Test.stopTest();

      
        System.assertEquals(true, response.isSuccess);
    }
    
      @isTest
    static void testUploadDocumentFailure() {
       Case testCase = [SELECT Id FROM Case LIMIT 1];
	   String fileContent = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed blandit diam nec tortor vestibulum';
 
        Test.startTest();
     
        Loans_UploadDocumentController.statusCode = 500;
        ApiConnection.Response response = Loans_UploadDocumentController.uploadDocument(testCase.Id, 'pdf', 'TestFileName', fileContent);
        
        Test.stopTest();

      
        System.assertEquals(false, response.isSuccess);
    }
    
  
    @isTest
    static void testConfirmAllDocumentUploaded() {
       Case testCase = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
       
        ApiConnection.Response response = Loans_UploadDocumentController.confirmAllDocumentUploaded(testCase.Id);
        Test.stopTest();

        System.assertEquals(true, response.isSuccess);
    }
 
  @isTest
    static void testConfirmAllDocumentUploadedFailure() {
       Case testCase = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
         Loans_UploadDocumentController.statusCode = 500;
        ApiConnection.Response response = Loans_UploadDocumentController.confirmAllDocumentUploaded(testCase.Id);
        Test.stopTest();

        System.assertEquals(false, response.isSuccess);
    }
 @isTest
    static void testuploadDocumentFutureMethod() {
       Case testCase = [SELECT Id FROM Case LIMIT 1];
 		String fileContent = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed blandit diam nec tortor vestibulum';
         
        Test.startTest();
         Loans_UploadDocumentController.uploadDocumentFutureMethod(testCase.Id, 'pdf', 'TestFileName', fileContent);
        Test.stopTest();

        
    }
    
    

}
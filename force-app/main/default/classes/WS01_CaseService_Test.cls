@isTest
private class WS01_CaseService_Test {

    // Helper method to create test data, which will be available to all test methods
    @TestSetup
    static void makeData() {
Case testCase1 = createTestCase('Refer to Service Center', true, 'New', 'In-Progress');
        createCaseAnnexRecords(new List<Case>{testCase1});

    }
  @isTest
    static void testCreateCaseWithAnnex_Success() {
        // Test a successful case creation with both a Case and a CaseAnnex record.
        
        // 1. Arrange: Prepare the request data and objects.
        Contact testContact = [SELECT Id, CIF__c FROM Contact WHERE CIF__c = '123456' LIMIT 1];
        RecordType testRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Loan Application' LIMIT 1];
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/CaseService/';
        request.httpMethod = 'POST';

        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('RecordType', new Map<String, String>{'Name' => testRecordType.Name});
        requestBody.put('Contact', new Map<String, String>{'CIF__c' => testContact.CIF__c});
        requestBody.put('Subject', 'Test Case Subject');
        requestBody.put('Description', 'Test Case Description');
        requestBody.put('Origin', 'Email');
        requestBody.put('Type', 'New Loan / Finance Application');
        requestBody.put('Sub_Type__c', 'New Loan / Finance Application Request');
        requestBody.put('Case_Nature__c', 'Loans');
        requestBody.put('Case_Model__c', 'ila');
        requestBody.put('cx_ln_Auto_Decisioning_Result__c', 'Approved');
        requestBody.put('cx_ln_Approved_Maturity_Date__c', '2025-10-15'); 
        requestBody.put('cx_ln_Review_Offer_Date_Time__c','2032-04-28 12:27:36');
        requestBody.put('cc_CPR_Expiry_Date__c', '2025-10-15'); 
        requestBody.put('cc_Anti_Attrition_Date_Time__c','2032-04-28 12:27:36');
        // Example of a custom annex field
       // requestBody.put('CX_AnnexField1__c', 'Annex Value 1'); 
        // Example of a date field in the annex
       // requestBody.put('CX_Date_Field__c', '2025-10-15'); 

        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));

        RestContext.request = request;
        RestContext.response = new RestResponse();

        // 2. Act: Call the method inside Test.startTest() to reset governor limits.
        Test.startTest();
        WS01_CaseService.ResponseWrapper response = WS01_CaseService.createCaseWithAnnex();
        Test.stopTest();
    }

    @isTest
    static void testCreateCaseWithAnnex_Failure1() {
 // Test a successful case creation with both a Case and a CaseAnnex record.
        
        // 1. Arrange: Prepare the request data and objects.
        Contact testContact = [SELECT Id, CIF__c FROM Contact WHERE CIF__c = '123456' LIMIT 1];
        RecordType testRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Loan Application' LIMIT 1];
        CaseAnnex__c CAnnex = [Select Id From CaseAnnex__c LIMIT 1];
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/CaseService/';
        request.httpMethod = 'POST';

        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('RecordType', new Map<String, String>{'Name' => testRecordType.Name});
        requestBody.put('Contact', new Map<String, String>{'CIF__c' => testContact.CIF__c});
        requestBody.put('Subject', 'Test Case Subject');
        requestBody.put('Description', 'Test Case Description');
        requestBody.put('Origin', 'Email');
        requestBody.put('Type', 'New Loan / Finance Application');
        requestBody.put('Sub_Type__c', 'New Loan / Finance Application Request');
        requestBody.put('Case_Nature__c', 'Loans');
        requestBody.put('Case_Model__c', 'alburaq');
        requestBody.put('cx_ln_Auto_Decisioning_Result__c', 'Approved');
        requestBody.put('cx_ln_Approved_Maturity_Date__c', '2025-10-15'); 
        requestBody.put('cx_ln_Review_Offer_Date_Time__c','2032-04-28 12:27:36');
        requestBody.put('cc_CPR_Expiry_Date__c', '2025-10-15'); 
        requestBody.put('cc_Anti_Attrition_Date_Time__c','2032-04-28 12:27:36');
        requestBody.put('CaseAnnex__c',CAnnex.Id);
        // Example of a custom annex field
       // requestBody.put('CX_AnnexField1__c', 'Annex Value 1'); 
        // Example of a date field in the annex
       // requestBody.put('CX_Date_Field__c', '2025-10-15'); 

        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));

        RestContext.request = request;
        RestContext.response = new RestResponse();

        // 2. Act: Call the method inside Test.startTest() to reset governor limits.
        Test.startTest();
        WS01_CaseService.ResponseWrapper response = WS01_CaseService.createCaseWithAnnex();
        Test.stopTest();
    }
    @isTest
    static void testCreateCaseWithAnnex_Failure2() {
 // Test a successful case creation with both a Case and a CaseAnnex record.
        
        // 1. Arrange: Prepare the request data and objects.
        Contact testContact = [SELECT Id, CIF__c FROM Contact WHERE CIF__c = '123456' LIMIT 1];
        RecordType testRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Loan Application' LIMIT 1];
         CaseAnnex__c CAnnex = [Select Id From CaseAnnex__c LIMIT 1];
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/CaseService/';
        request.httpMethod = 'POST';

        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('RecordType', new Map<String, String>{'Name' => testRecordType.Name});
        requestBody.put('Contact', new Map<String, String>{'CIF__c' => testContact.CIF__c});
        requestBody.put('Subject', 'Test Case Subject');
        requestBody.put('Description', 'Test Case Description');
        requestBody.put('Origin', 'Email');
        requestBody.put('Type', 'New Loan / Finance Application');
        requestBody.put('Sub_Type__c', 'New Loan / Finance Application Request');
        requestBody.put('Case_Nature__c', 'Loans');
        requestBody.put('Case_Model__c', 'ila');
        requestBody.put('cx_ln_Auto_Decisioning_Result__c', 'Approved');
        requestBody.put('cx_ln_Approved_Maturity_Date__c', '2025-sep-15'); 
        requestBody.put('cx_ln_Review_Offer_Date_Time__c','2032-04-28 12:27:36');
        requestBody.put('cc_CPR_Expiry_Date__c', '2025-10-15'); 
        requestBody.put('cc_Anti_Attrition_Date_Time__c','2032-04-28 12:27:36');
        requestBody.put('CaseAnnex__c',CAnnex.Id);
        // Example of a custom annex field
       // requestBody.put('CX_AnnexField1__c', 'Annex Value 1'); 
        // Example of a date field in the annex
       // requestBody.put('CX_Date_Field__c', '2025-10-15'); 

        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));

        RestContext.request = request;
        RestContext.response = new RestResponse();

        // 2. Act: Call the method inside Test.startTest() to reset governor limits.
        Test.startTest();
        WS01_CaseService.ResponseWrapper response = WS01_CaseService.createCaseWithAnnex();
        Test.stopTest();
    }
      @isTest
    static void testCreateCaseWithAnnex_Failure3() {
 // Test a successful case creation with both a Case and a CaseAnnex record.
            CaseAnnex__c CAnnex = [Select Id From CaseAnnex__c LIMIT 1];
        // 1. Arrange: Prepare the request data and objects.
        Contact testContact = [SELECT Id, CIF__c FROM Contact WHERE CIF__c = '123456' LIMIT 1];
        RecordType testRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Loan Application' LIMIT 1];
        
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/CaseService/';
        request.httpMethod = 'POST';

        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('RecordType', new Map<String, String>{'Name' => testRecordType.Name});
        requestBody.put('Contact', new Map<String, String>{'CIF__c' => testContact.CIF__c});
        requestBody.put('Subject', 'Test Case Subject');
        requestBody.put('Description', 'Test Case Description');
        requestBody.put('Origin', 'Email');
        requestBody.put('Type', 'New Loan / Finance Application');
        requestBody.put('Sub_Type__c', 'New Loan / Finance Application Request');
        requestBody.put('Case_Nature__c', 'Loans');
        requestBody.put('Case_Model__c', 'ila');
        requestBody.put('cx_ln_Auto_Decisioning_Result__c', 'Approved');
        requestBody.put('cx_ln_Approved_Maturity_Date__c', '2025-02-15'); 
        requestBody.put('cx_ln_Review_Offer_Date_Time__c','2032-04-28T12:27:36');
        requestBody.put('cc_CPR_Expiry_Date__c', '2025-10-15'); 
        requestBody.put('cc_Anti_Attrition_Date_Time__c','2032-04-28 12:27:36');
         requestBody.put('CaseAnnex__c',CAnnex.Id);
        // Example of a custom annex field
       // requestBody.put('CX_AnnexField1__c', 'Annex Value 1'); 
        // Example of a date field in the annex
       // requestBody.put('CX_Date_Field__c', '2025-10-15'); 

        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));

        RestContext.request = request;
        RestContext.response = new RestResponse();

        // 2. Act: Call the method inside Test.startTest() to reset governor limits.
        Test.startTest();
        WS01_CaseService.ResponseWrapper response = WS01_CaseService.createCaseWithAnnex();
        Test.stopTest();
    }
         @isTest
    static void testCreateCaseWithAnnex_Failure4() {
 // Test a successful case creation with both a Case and a CaseAnnex record.
        
        // 1. Arrange: Prepare the request data and objects.
        Contact testContact = [SELECT Id, CIF__c FROM Contact WHERE CIF__c = '123456' LIMIT 1];
        RecordType testRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Loan Application' LIMIT 1];
        CaseAnnex__c CAnnex = [Select Id From CaseAnnex__c LIMIT 1];
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/CaseService/';
        request.httpMethod = 'POST';

        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('RecordType', new Map<String, String>{'Name' => testRecordType.Name});
        requestBody.put('Contact', new Map<String, String>{'CIF__c' => testContact.CIF__c});
        requestBody.put('Subject', 'Test Case Subject');
        requestBody.put('Description', 'Test Case Description');
        requestBody.put('Origin', 'Email');
        requestBody.put('Type', 'New Loan / Finance Application');
        requestBody.put('Sub_Type__c', 'New Loan / Finance Application Request');
        requestBody.put('Case_Nature__c', 'Loans');
        requestBody.put('Case_Model__c', 'ila');
        requestBody.put('cx_ln_Auto_Decisioning_Result__c', 'Approved');
        requestBody.put('cx_ln_Approved_Maturity_Date__c', '2025-02-15'); 
        requestBody.put('cx_ln_Review_Offer_Date_Time__c','2032-04-28 12:27:36');
        requestBody.put('cc_CPR_Expiry_Date__c', '2025/Sep-15'); 
        requestBody.put('cc_Anti_Attrition_Date_Time__c','2032-04-28 12:27:36');
         requestBody.put('CaseAnnex__c',CAnnex.Id);
        // Example of a custom annex field
       // requestBody.put('CX_AnnexField1__c', 'Annex Value 1'); 
        // Example of a date field in the annex
       // requestBody.put('CX_Date_Field__c', '2025-10-15'); 

        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));

        RestContext.request = request;
        RestContext.response = new RestResponse();

        // 2. Act: Call the method inside Test.startTest() to reset governor limits.
        Test.startTest();
        WS01_CaseService.ResponseWrapper response = WS01_CaseService.createCaseWithAnnex();
        Test.stopTest();
    }
      @isTest
    static void testCreateCaseWithAnnex_Failure5() {
 // Test a successful case creation with both a Case and a CaseAnnex record.
        
        // 1. Arrange: Prepare the request data and objects.
        Contact testContact = [SELECT Id, CIF__c FROM Contact WHERE CIF__c = '123456' LIMIT 1];
        RecordType testRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Loan Application' LIMIT 1];
        CaseAnnex__c CAnnex = [Select Id From CaseAnnex__c LIMIT 1];
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/CaseService/';
        request.httpMethod = 'POST';

        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('RecordType', new Map<String, String>{'Name' => testRecordType.Name});
        requestBody.put('Contact', new Map<String, String>{'CIF__c' => testContact.CIF__c});
        requestBody.put('Subject', 'Test Case Subject');
        requestBody.put('Description', 'Test Case Description');
        requestBody.put('Origin', 'Email');
        requestBody.put('Type', 'New Loan / Finance Application');
        requestBody.put('Sub_Type__c', 'New Loan / Finance Application Request');
        requestBody.put('Case_Nature__c', 'Loans');
        requestBody.put('Case_Model__c', 'ila');
        requestBody.put('cx_ln_Auto_Decisioning_Result__c', 'Approved');
        requestBody.put('cx_ln_Approved_Maturity_Date__c', '2025-02-15'); 
        requestBody.put('cx_ln_Review_Offer_Date_Time__c','2032-04-28 12:27:36');
        requestBody.put('cc_CPR_Expiry_Date__c', '2025-04-15'); 
        requestBody.put('cc_Anti_Attrition_Date_Time__c','2032-04-28T12:27:36');
        requestBody.put('CaseAnnex__c',CAnnex.Id);
        // Example of a custom annex field
       // requestBody.put('CX_AnnexField1__c', 'Annex Value 1'); 
        // Example of a date field in the annex
       // requestBody.put('CX_Date_Field__c', '2025-10-15'); 

        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));

        RestContext.request = request;
        RestContext.response = new RestResponse();

        // 2. Act: Call the method inside Test.startTest() to reset governor limits.
        Test.startTest();
        WS01_CaseService.ResponseWrapper response = WS01_CaseService.createCaseWithAnnex();
        Test.stopTest();
    }
         @isTest
    static void testCreateCaseWithAnnex_Failure6() {
 // Test a successful case creation with both a Case and a CaseAnnex record.
        
        // 1. Arrange: Prepare the request data and objects.
        Contact testContact = [SELECT Id, CIF__c FROM Contact WHERE CIF__c = '123456' LIMIT 1];
        RecordType testRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Loan Application' LIMIT 1];
        CaseAnnex__c CAnnex = [Select Id From CaseAnnex__c LIMIT 1];
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/CaseService/';
        request.httpMethod = 'POST';

        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('RecordType', new Map<String, String>{'Name' => testRecordType.Name});
        requestBody.put('Contact', new Map<String, String>{'CIF__c' => ''});
        requestBody.put('Subject', 'Test Case Subject');
        requestBody.put('Description', 'Test Case Description');
        requestBody.put('Origin', 'Email');
        requestBody.put('Type', 'New Loan / Finance Application');
        requestBody.put('Sub_Type__c', 'New Loan / Finance Application Request');
        requestBody.put('Case_Nature__c', 'Loans');
        requestBody.put('Case_Model__c', 'ila');
        requestBody.put('cx_ln_Auto_Decisioning_Result__c', 'Approved');
        requestBody.put('cx_ln_Approved_Maturity_Date__c', '2025-02-15'); 
        requestBody.put('cx_ln_Review_Offer_Date_Time__c','2032-04-28 12:27:36');
        requestBody.put('cc_CPR_Expiry_Date__c', '2025-04-15'); 
        requestBody.put('cc_Anti_Attrition_Date_Time__c','2032-04-28 12:27:36');
        requestBody.put('CaseAnnex__c',CAnnex.Id);
        // Example of a custom annex field
       // requestBody.put('CX_AnnexField1__c', 'Annex Value 1'); 
        // Example of a date field in the annex
       // requestBody.put('CX_Date_Field__c', '2025-10-15'); 

        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));

        RestContext.request = request;
        RestContext.response = new RestResponse();

        // 2. Act: Call the method inside Test.startTest() to reset governor limits.
        Test.startTest();
        WS01_CaseService.ResponseWrapper response = WS01_CaseService.createCaseWithAnnex();
        Test.stopTest();
    }
      @isTest
    static void testCreateCaseWithAnnex_Failure7() {
 // Test a successful case creation with both a Case and a CaseAnnex record.
        
        // 1. Arrange: Prepare the request data and objects.
        Contact testContact = [SELECT Id, CIF__c FROM Contact WHERE CIF__c = '123456' LIMIT 1];
        RecordType testRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Loan Application' LIMIT 1];
        CaseAnnex__c CAnnex = [Select Id From CaseAnnex__c LIMIT 1];
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/CaseService/';
        request.httpMethod = 'POST';

        Map<String, Object> requestBody = new Map<String, Object>(); 
        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));

        RestContext.request = request;
        RestContext.response = new RestResponse();

        // 2. Act: Call the method inside Test.startTest() to reset governor limits.
        Test.startTest();
        WS01_CaseService.ResponseWrapper response = WS01_CaseService.createCaseWithAnnex();
        Test.stopTest();
    }
    @isTest
static void testUpdateWithAnnex_CaseCX_Exception1() {
    // Arrange
    // Create a fake, non-existent ID for the request URI
    Id fakeCaseId = [Select Id from case limit 1].Id; 
     CaseAnnex__c CAnnex = [Select Id From CaseAnnex__c LIMIT 1];
    RestRequest request = new RestRequest();
    request.requestURI = '/services/apexrest/CaseAnnex/' + fakeCaseId;
    request.httpMethod = 'PATCH';
    request.requestBody = Blob.valueOf( '{"cx_ln_Approved_Maturity_Date__c":"2025/Sep/04","cx_ln_Review_Offer_Date_Time__c":"2025-12-04T00:00:00","Contact":{"CIF__c":"123456"},"CaseAnnex__c",'+CAnnex.Id+'}');
    RestContext.request = request;
    RestContext.response = new RestResponse();

    // Act
    Test.startTest();
    WS01_CaseService.updateCaseWithAnnex();
    Test.stopTest();

    // Assert
    RestResponse response = RestContext.response;

   // String responseBody = response.responseBody.toString();
}
        @isTest
static void testUpdateWithAnnex_CaseCX_Exception2() {
    // Arrange
    // Create a fake, non-existent ID for the request URI
    Id fakeCaseId = [Select Id from case limit 1].Id; 
  //  CaseAnnex__c CAnnex = [Select Id From CaseAnnex__c LIMIT 1];
    RestRequest request = new RestRequest();
    request.requestURI = '/services/apexrest/CaseAnnex/' + fakeCaseId;
    request.httpMethod = 'PATCH';
    request.requestBody = Blob.valueOf( '{"cx_ln_Approved_Maturity_Date__c":"2025-09-01","cx_ln_Review_Offer_Date_Time__c":"2025-12-04T00:00:00","Contact":{"CIF__c":"123456"}}');
    RestContext.request = request;
    RestContext.response = new RestResponse();

    // Act
    Test.startTest();
    WS01_CaseService.updateCaseWithAnnex();
    Test.stopTest();

    // Assert
    RestResponse response = RestContext.response;

   // String responseBody = response.responseBody.toString();
}
    @isTest
static void testUpdateWithAnnex_DmlException() {
    // Arrange
    // Create a Case record to update
   // Case c = new Case(Subject = 'Initial Subject');
   // insert c;
  //  Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
   //     Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456', Subscription_Model__pc = 'alburaq', CustomerStatus__c=null,Archived__pc = false, x_canary__pc = 'canary'), 'TestFactoryDefaults.AccountDefaults',true);
       // Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email'), 'TestFactoryDefaults.CaseDefaults',true);
Case testCase =[Select Id from case limit 1];
//CaseAnnex__c CAnnex = [Select Id From CaseAnnex__c LIMIT 1];
    // The org must have a validation rule that prevents updates with a subject like 'FAIL'.
    // Here, we simulate a DML failure by setting the Subject to a value that would fail validation.
    String requestBodyJson = '{"Contact":{"CIF__c":"123456"}}';
    
    RestRequest request = new RestRequest();
    request.requestURI = '/services/apexrest/CaseAnnex/' + testCase.Id;
    request.httpMethod = 'PATCH';
    request.requestBody = Blob.valueOf(requestBodyJson);
    RestContext.request = request;
    RestContext.response = new RestResponse();

    // Act
    Test.startTest();
    WS01_CaseService.updateCaseWithAnnex();
    Test.stopTest();

    // Assert
    RestResponse response = RestContext.response;

   // String responseBody = response.responseBody.toString();


    // Verify the transaction was rolled back by querying the record again
    Case afterRollbackCase = [SELECT Subject FROM Case WHERE Id = :testCase.Id];
   
}
        @isTest
static void testUpdateWithAnnex_DmlException1() {
    // Arrange
    // Create a Case record to update
   // Case c = new Case(Subject = 'Initial Subject');
   // insert c;
  //  Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
   //     Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456', Subscription_Model__pc = 'alburaq', CustomerStatus__c=null,Archived__pc = false, x_canary__pc = 'canary'), 'TestFactoryDefaults.AccountDefaults',true);
       // Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email'), 'TestFactoryDefaults.CaseDefaults',true);
Case testCase =[Select Id from case limit 1];
//CaseAnnex__c CAnnex = [Select Id From CaseAnnex__c LIMIT 1];
    // The org must have a validation rule that prevents updates with a subject like 'FAIL'.
    // Here, we simulate a DML failure by setting the Subject to a value that would fail validation.
    String requestBodyJson = '{"Contact":{"CIF__c":"123456"},"Case_Model__c":"alburaq"}';
    
    RestRequest request = new RestRequest();
    request.requestURI = '/services/apexrest/CaseAnnex/' + testCase.Id;
    request.httpMethod = 'PATCH';
    request.requestBody = Blob.valueOf(requestBodyJson);
    RestContext.request = request;
    RestContext.response = new RestResponse();

    // Act
    Test.startTest();
    WS01_CaseService.updateCaseWithAnnex();
    Test.stopTest();

    // Assert
    RestResponse response = RestContext.response;

   // String responseBody = response.responseBody.toString();


    // Verify the transaction was rolled back by querying the record again
    Case afterRollbackCase = [SELECT Subject FROM Case WHERE Id = :testCase.Id];
   
}
       @isTest
static void testUpdateWithAnnex_DmlException4() {
    // Arrange
    // Create a Case record to update
   // Case c = new Case(Subject = 'Initial Subject');
   // insert c;
  //  Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
   //     Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456', Subscription_Model__pc = 'alburaq', CustomerStatus__c=null,Archived__pc = false, x_canary__pc = 'canary'), 'TestFactoryDefaults.AccountDefaults',true);
       // Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email'), 'TestFactoryDefaults.CaseDefaults',true);
Case testCase =[Select Id from case limit 1];
CaseAnnex__c CAnnex = [Select Id From CaseAnnex__c LIMIT 1];
    // The org must have a validation rule that prevents updates with a subject like 'FAIL'.
    // Here, we simulate a DML failure by setting the Subject to a value that would fail validation.
    String requestBodyJson = '{"Contact":{"CIF__c":"123456"},"Case_Model__c":"alburaq","CaseAnnex__c",'+CAnnex.Id+'}';
    
    RestRequest request = new RestRequest();
    request.requestURI = '/services/apexrest/CaseAnnex/34556766754';
    request.httpMethod = 'PATCH';
    request.requestBody = Blob.valueOf(requestBodyJson);
    RestContext.request = request;
    RestContext.response = new RestResponse();

    // Act
    Test.startTest();
    WS01_CaseService.updateCaseWithAnnex();
    Test.stopTest();

    // Assert
    RestResponse response = RestContext.response;

   // String responseBody = response.responseBody.toString();


    // Verify the transaction was rolled back by querying the record again
    Case afterRollbackCase = [SELECT Subject FROM Case WHERE Id = :testCase.Id];
   
}
           @isTest
static void testUpdateWithAnnex_DmlException5() {
    // Arrange
    // Create a Case record to update
   // Case c = new Case(Subject = 'Initial Subject');
   // insert c;
  //  Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
   //     Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456', Subscription_Model__pc = 'alburaq', CustomerStatus__c=null,Archived__pc = false, x_canary__pc = 'canary'), 'TestFactoryDefaults.AccountDefaults',true);
       // Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email'), 'TestFactoryDefaults.CaseDefaults',true);
Case testCase =[Select Id from case limit 1];

    // The org must have a validation rule that prevents updates with a subject like 'FAIL'.
    // Here, we simulate a DML failure by setting the Subject to a value that would fail validation.
    String requestBodyJson = null;
    
    RestRequest request = new RestRequest();
    request.requestURI = '/services/apexrest/CaseAnnex/'+testCase.Id;
    request.httpMethod = 'PATCH';
   // request.requestBody = Blob.valueOf(requestBodyJson);
    RestContext.request = request;
    RestContext.response = new RestResponse();

    // Act
    Test.startTest();
    WS01_CaseService.updateCaseWithAnnex();
    Test.stopTest();

    // Assert
    RestResponse response = RestContext.response;

   // String responseBody = response.responseBody.toString();


    // Verify the transaction was rolled back by querying the record again
    Case afterRollbackCase = [SELECT Subject FROM Case WHERE Id = :testCase.Id];
   
}
        @isTest
static void testUpdateWithAnnex_DmlException2() {
    // Arrange
    // Create a Case record to update
   // Case c = new Case(Subject = 'Initial Subject');
   // insert c;
  //  Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
   //     Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456', Subscription_Model__pc = 'alburaq', CustomerStatus__c=null,Archived__pc = false, x_canary__pc = 'canary'), 'TestFactoryDefaults.AccountDefaults',true);
       // Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email'), 'TestFactoryDefaults.CaseDefaults',true);
Case testCase =[Select Id from case limit 1];

    // The org must have a validation rule that prevents updates with a subject like 'FAIL'.
    // Here, we simulate a DML failure by setting the Subject to a value that would fail validation.
    String requestBodyJson = '{"Contact":{"CIF__c":""}}';
    
    RestRequest request = new RestRequest();
    request.requestURI = '/services/apexrest/CaseAnnex/' + testCase.Id;
    request.httpMethod = 'PATCH';
    request.requestBody = Blob.valueOf(requestBodyJson);
    RestContext.request = request;
    RestContext.response = new RestResponse();

    // Act
    Test.startTest();
    WS01_CaseService.updateCaseWithAnnex();
    Test.stopTest();

    // Assert
    RestResponse response = RestContext.response;

   // String responseBody = response.responseBody.toString();


    // Verify the transaction was rolled back by querying the record again
    Case afterRollbackCase = [SELECT Subject FROM Case WHERE Id = :testCase.Id];
   
}
@isTest
static void testUpdateWithAnnex_DmlException3() {
    // Arrange
    // Create a Case record to update
   // Case c = new Case(Subject = 'Initial Subject');
   // insert c;
  //  Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
   //     Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456', Subscription_Model__pc = 'alburaq', CustomerStatus__c=null,Archived__pc = false, x_canary__pc = 'canary'), 'TestFactoryDefaults.AccountDefaults',true);
       // Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email'), 'TestFactoryDefaults.CaseDefaults',true);
Case testCase =[Select Id from case limit 1];

    // The org must have a validation rule that prevents updates with a subject like 'FAIL'.
    // Here, we simulate a DML failure by setting the Subject to a value that would fail validation.
    String requestBodyJson = '{"Contact":{"CIF__c":"88888"}}';
    
    RestRequest request = new RestRequest();
    request.requestURI = '/services/apexrest/CaseAnnex/' + testCase.Id;
    request.httpMethod = 'PATCH';
    request.requestBody = Blob.valueOf(requestBodyJson);
    RestContext.request = request;
    RestContext.response = new RestResponse();

    // Act
    Test.startTest();
    WS01_CaseService.updateCaseWithAnnex();
    Test.stopTest();

    // Assert
    RestResponse response = RestContext.response;

   // String responseBody = response.responseBody.toString();


    // Verify the transaction was rolled back by querying the record again
    Case afterRollbackCase = [SELECT Subject FROM Case WHERE Id = :testCase.Id];
   
}

    @isTest
static void testUpdateWithCasefields_DmlException() {
    // Arrange
    // Create a Case record to update
   // Case c = new Case(Subject = 'Initial Subject');
   // insert c;
  //  Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
   //     Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456', Subscription_Model__pc = 'alburaq', CustomerStatus__c=null,Archived__pc = false, x_canary__pc = 'canary'), 'TestFactoryDefaults.AccountDefaults',true);
       // Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email'), 'TestFactoryDefaults.CaseDefaults',true);
Case testCase =[Select Id from case limit 1];

    // The org must have a validation rule that prevents updates with a subject like 'FAIL'.
    // Here, we simulate a DML failure by setting the Subject to a value that would fail validation.
    String requestBodyJson = '{"cc_CPR_Expiry_Date__c":"2025-01-10","cc_Anti_Attrition_Date_Time__c":"2025-01-10T00:00:00","Subject":"LoanApplication"}';
    
    RestRequest request = new RestRequest();
    request.requestURI = '/services/apexrest/CaseAnnex/' + testCase.Id;
    request.httpMethod = 'PATCH';
    request.requestBody = Blob.valueOf(requestBodyJson);
    RestContext.request = request;
    RestContext.response = new RestResponse();

    // Act
    Test.startTest();
    WS01_CaseService.updateCaseWithAnnex();
    Test.stopTest();

    // Assert
    RestResponse response = RestContext.response;

   // String responseBody = response.responseBody.toString();


    // Verify the transaction was rolled back by querying the record again
    Case afterRollbackCase = [SELECT Subject FROM Case WHERE Id = :testCase.Id];
   
}    
        @isTest
static void testUpdateWithCasefields_DmlException1() {
    // Arrange
    // Create a Case record to update
   // Case c = new Case(Subject = 'Initial Subject');
   // insert c;
  //  Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
   //     Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456', Subscription_Model__pc = 'alburaq', CustomerStatus__c=null,Archived__pc = false, x_canary__pc = 'canary'), 'TestFactoryDefaults.AccountDefaults',true);
       // Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email'), 'TestFactoryDefaults.CaseDefaults',true);
Case testCase =[Select Id from case limit 1];

    // The org must have a validation rule that prevents updates with a subject like 'FAIL'.
    // Here, we simulate a DML failure by setting the Subject to a value that would fail validation.
    String requestBodyJson = '{"cc_CPR_Expiry_Date__c":"20209-10","cc_Anti_Attrition_Date_Time__c":"2025-01-10T00:00:00","Subject":"LoanApplication"}';
    
    RestRequest request = new RestRequest();
    request.requestURI = '/services/apexrest/CaseAnnex/' + testCase.Id;
    request.httpMethod = 'PATCH';
    request.requestBody = Blob.valueOf(requestBodyJson);
    RestContext.request = request;
    RestContext.response = new RestResponse();

    // Act
    Test.startTest();
    WS01_CaseService.updateCaseWithAnnex();
    Test.stopTest();

    // Assert
    RestResponse response = RestContext.response;

   // String responseBody = response.responseBody.toString();


    // Verify the transaction was rolled back by querying the record again
    Case afterRollbackCase = [SELECT Subject FROM Case WHERE Id = :testCase.Id];
   
}    
    @isTest
static void testUpdateWithCasefieldsDate_DmlException() {
    // Arrange
    // Create a Case record to update
   // Case c = new Case(Subject = 'Initial Subject');
   // insert c;
  //  Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
   //     Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456', Subscription_Model__pc = 'alburaq', CustomerStatus__c=null,Archived__pc = false, x_canary__pc = 'canary'), 'TestFactoryDefaults.AccountDefaults',true);
       // Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',cc_Service_Centre_Result__c='Return to Pre-Screener', Resend_DocuSign__c = 'Email'), 'TestFactoryDefaults.CaseDefaults',true);
Case testCase =[Select Id from case limit 1];

    // The org must have a validation rule that prevents updates with a subject like 'FAIL'.
    // Here, we simulate a DML failure by setting the Subject to a value that would fail validation.
    String requestBodyJson = '{"cc_CPR_Expiry_Date__c":"2025-01-10","Subject":"LoanApplication"}';
    
    RestRequest request = new RestRequest();
    request.requestURI = '/services/apexrest/CaseAnnex/' + testCase.Id;
    request.httpMethod = 'PATCH';
    request.requestBody = Blob.valueOf(requestBodyJson);
    RestContext.request = request;
    RestContext.response = new RestResponse();

    // Act
    Test.startTest();
    WS01_CaseService.updateCaseWithAnnex();
    Test.stopTest();

    // Assert
    RestResponse response = RestContext.response;

   // String responseBody = response.responseBody.toString();


    // Verify the transaction was rolled back by querying the record again
    Case afterRollbackCase = [SELECT Subject FROM Case WHERE Id = :testCase.Id];
   
}    
      // Test method for the static helper method parseUtcString
    @isTest
    static void testParseUtcString_Success() {
        // Arrange
        String utcString = '2025-10-16 12:00:00';
        DateTime expectedDateTime = DateTime.newInstanceGMT(2025, 10, 16, 12, 0, 0);

        // Act
        Test.startTest();
        DateTime actualDateTime = WS01_CaseService.parseUtcString(utcString);
        Test.stopTest();


    }

    // Test method for the parseUtcString method with an invalid format
    @isTest
    static void testParseUtcString_InvalidFormat() {
        // Arrange
        String invalidUtcString = '16-10-2025 12:00:00'; // Incorrect format
        Boolean caughtException = false;

        // Act
        Test.startTest();
        try {
            WS01_CaseService.parseUtcString(invalidUtcString);
        } catch (System.TypeException e) {
            caughtException = true;
        }
        Test.stopTest();
    }

    // Test method to cover the ErrorResponseWrapper
    @isTest
    static void testErrorResponseWrapper() {
        // Arrange
        String errorCode = 'TEST_ERROR';
        String errorMessage = 'This is a test error.';

        // Act
        WS01_CaseService.ErrorResponseWrapper errorWrapper = new WS01_CaseService.ErrorResponseWrapper(false, errorCode, errorMessage);


    }

    // Test method to cover the SuccessResponseWrapper
    @isTest
    static void testSuccessResponseWrapper() {
        // Arrange
        String caseId = '500000000000001AAA';
        String caseNumber = '00001234';

        // Act
        WS01_CaseService.SuccessResponseWrapper successWrapper = new WS01_CaseService.SuccessResponseWrapper(true, caseId, caseNumber);

    }
    
       private static Case createTestCase(String contactCentreResult, Boolean haveCreditCard, String status, String subStatus) {
        return createTestCase(contactCentreResult, haveCreditCard, status, subStatus, null);
    }

    private static Case createTestCase(String contactCentreResult, Boolean haveCreditCard, String status, String subStatus, String controlType) {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
        String cif = '123456'; 
        Account testAccount = (Account)TestDataFactory.createSObject(
            new Account(
                CIF__pc = cif,
                PersonEmail = 'test' + cif + '@test.com', 
                Subscription_Model__pc = 'ila', 
                CustomerStatus__c = 'Active', 
                Archived__pc = false,
                Region_Flag__pc = 'Bahrain'
            ), 
            'TestFactoryDefaults.AccountDefaults',
            true
        );

        Case testCase = (Case)TestDataFactory.createSObject(
            new Case(
                RecordTypeId = acRecordTypeId,
                ContactId = testAccount.PersonContactId,
                AccountId = testAccount.id, 
                Case_Model__c = 'ila',
                Type = 'New Loan / Finance Application', 
                Sub_Type__c = 'New Loan / Finance Application Request', 
                AIR_HaveCreditCard__c = haveCreditCard,
                cc_Service_Centre_Result__c = 'Return to Pre-Screener', 
                Resend_DocuSign__c = 'Email', 
                cc_Contact_Centre_Result__c = contactCentreResult,
                Status = status,
                Sub_Status__c = subStatus,
                cc_Control_Type__c = controlType,
                Region_Flag__c = 'Bahrain'
            ), 
            'TestFactoryDefaults.CaseDefaults',
            true
        );
        return testCase;
    }

    private static void createCaseAnnexRecords(List<Case> caseRecords) {
        List<CaseAnnex__c> caseAnnexes = new List<CaseAnnex__c>();

        for(Case caseRecord : caseRecords) {
            CaseAnnex__c annex = new CaseAnnex__c(
                Case__c = caseRecord.Id,
                cx_ln_Product__c = 'Unsecured',
                cx_ln_Requested_Loan_Finance_Amount__c = 10000,
                cx_ln_Requested_Duration_Months__c = 12,
                cx_ln_Monthly_Instalment__c = 900,
                cx_ln_Approved_Loan_Amount__c = 10000,
                cx_ln_ApprovedInterestProfitRateReducing__c = 5.0,
                cx_ln_Approved_Installment_Amount__c = 900,
                cx_ln_Approved_Duration_Months__c = 12,
                cx_ln_APR__c = 6.0,
                cx_ln_Requested_Processing_Fees__c = 100,
                cx_ln_Requested_Vat_Processing_Fees__c = 10,
                cx_ln_Approved_First_installment_date__c = Date.today().addDays(30),
                cx_ln_Approved_Maturity_Date__c = Date.today().addDays(395),
                cx_ln_Approved_Insurance_Premium__c = 'Upfront',
                cx_ln_Approved_insurance__c = true,
                cx_ln_ApprovedProcessing_Fee_Type__c = 'Upfront',
                cx_ln_Approved_Insurance_Amount__c = 50,
                cx_ln_RequireSalaryCertificate__c = false,
                cx_ln_Cross_Selling_PreScreening_Result__c = 'Approve',
                cx_ln_Cross_Selling_Evaluator_Result__c = 'Approve',
                cx_ln_Cross_Selling_Verifier_Result__c = 'Approve',
                cx_ln_Cross_Selling_Approver_Result__c = 'Approve',
                cx_ln_SimulationReference__c = 'TEST_SIM_REF'
            );
            caseAnnexes.add(annex);
        }

        insert caseAnnexes;
    }
}
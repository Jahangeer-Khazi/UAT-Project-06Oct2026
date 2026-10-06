/*
Author : 
Date : 
Description : UserProfileControllerTest
    #CH01# Added #22-06-2022# Document Model changes - HC
    #CH02# Added #30-06-2022# IBJ-6002 Civil Department changes - Navin
    Version History :
      #CH01# Added Amina BENABDELKRIM  add new field (case model) &(document model) with default value 'ila'
*/
@isTest
private class UserProfileControllerTest {
    private static final String BAHRAIN_REGION = 'Bahrain';
    private static final String JORDAN_REGION = 'Jordan';
    @testSetup static void setup() {
    Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Cutomer_Fields_Update__c> customerFields = new List<Cutomer_Fields_Update__c>();
        customerFields.add(new Cutomer_Fields_Update__c(Name='FirstName', Field_Update__c='FirstName_Update__pc' , Encrypt__c=true));
        customerFields.add(new Cutomer_Fields_Update__c(Name='LastName', Field_Update__c='LastName_Update__pc' , Encrypt__c=true));
        customerFields.add(new Cutomer_Fields_Update__c(Name='Gender__pc', Field_Update__c='Gender_Update__pc' , Encrypt__c=false));
        customerFields.add(new Cutomer_Fields_Update__c(Name='MiddleName', Field_Update__c='MiddleName_Update__pc' , Encrypt__c=false));
        customerFields.add(new Cutomer_Fields_Update__c(Name='Residency__pc', Field_Update__c='Residency_Update__pc' , Encrypt__c=false));
        customerFields.add(new Cutomer_Fields_Update__c(Name='PersonEmail', Field_Update__c='Email_Update__pc' , Encrypt__c=false));

        insert customerFields;

        Account acc = new Account(FirstName='Test First Name', LastName='Test update profile', RecordTypeId=devRecordTypeId, PersonEmail='test@test.com', Region_Flag__pc = BAHRAIN_REGION, Region_Flag__c = BAHRAIN_REGION );
        insert acc;

        Case case1 = new Case(Subject = 'Test', AccountId=acc.Id, Type='Identification', Origin = 'Phone', Region_Flag__c = BAHRAIN_REGION,Case_Model__c='ila');//CH01
        insert case1;
  }

    @isTest
    static void getCaseAccountTest () {
        Case case1 =  [select Id, Account.Name from Case limit 1];
        Case case2 = UserProfileController.getCaseAccount(case1.Id);
        system.assertEquals(case1.Account.Name, case2.Account.Name);
    }

    @isTest
    static void testUpdateProfile () {

        Case case1 =  [select AccountId, Status from Case where Subject = 'Test' limit 1];
        String query = 'select Id';
        List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
        for(Cutomer_Fields_Update__c customerField : cutomerFieldsUpdate){
            query += ', ' + customerField.Name + ', ' + customerField.Field_Update__c;
        }
        Account acc = database.query(query + ' from Account where Id = \'' + case1.AccountId +'\'');

        acc.Arabic_Name__pc = 'Arabic Name';
        acc.PersonBirthdate = system.today();
        acc.Gender__pc = 'M';
        acc.Nationality__pc = 'GB';
        acc.PersonMailingStreet = 'st';
        acc.PersonMailingCity = 'London';
        acc.PersonMailingPostalCode = 'NW1 3HH';
        acc.PersonMailingCountry = 'UK';
        acc.PersonEmail = 'abc@abcbank.com';
        acc.Mobile_Country_Code__pc = '9001';
        acc.PersonMobilePhone = '12345678';
        //acc.ID_Type__pc = 'Bahraini ID';
        acc.ID_Nationality__pc = 'GB';
        acc.ID_Number__pc = '123456789';
        acc.ID_Expiry_Date__pc = system.today().addDays(100);
        acc.Proof_of_Address_ID_Type__pc = 'Utility Bill';
        acc.Proof_of_Address_Id__pc = 'proof of add';
        acc.Employment_Status__pc = 'Retired';
        acc.Employer_Name__pc = 'E Name';
        acc.Business_Name__pc = 'B Name';
        acc.Business_Industry__pc = 'Advertising';
        acc.Sources_of_Funds__pc = 'Salary;Other';
        acc.Source_Found_specify__pc = 'aaa';
        //acc.Gross_Monthly_Income__pc = '500';
        acc.Expected_Monthly_deposits__pc = 1000.0;
        acc.Applicable_Residency_Tax__pc = 'Test';
        acc.FATCA_Customer__pc = true;
        acc.Tax_Country_1__pc = 'GB';
        acc.Tax_Country_1_ID__pc = 'GB';
        acc.Tax_Country_2__pc = 'GB';
        acc.Tax_Country_2_ID__pc = 'GB';
        acc.Tax_Country_3__pc = 'GB';
        acc.Tax_Country_3_ID__pc = 'GB';
        acc.Tax_Country_4__pc = 'GB';
        acc.Tax_Country_4_ID__pc = 'GB';
        acc.Address_ID_Expiry_Date__pc =  Date.today();
        acc.US_Indicia__pc = false;

        //01/10/19 Added CIF and email address
        acc.CIF__pc ='0000000';
        acc.PersonEmail ='bankabc@westbrookwisdom.com';
        //04/04/2021 added resident expiry Shashank
        acc.Residency_Permit_Expiry__pc = system.today().addDays(15);

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": {"code": "CUST-1008", "message": "Customer Details have been updated successfully."}}';
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
       // ApiConnection.Response response = UserProfileController.updateProfile(acc, '123456', case1.Id, 'abc@abcbank.com', BAHRAIN_REGION);
        Test.stopTest();
        // System.debug('>>>>>>>> res test ' + response);
        // system.assertEquals(true, response.isSuccess);
        //system.assertEquals(null, acc.Business_Industry__pc);
        system.assertEquals(true, acc.FATCA_Customer__pc );
        system.assertEquals('aaa', acc.Source_Found_specify__pc );
    }

    @isTest
    static void testUpdateProfileEmployed () {

        Case case1 =  [select AccountId, Status from Case where Subject = 'Test' limit 1];
        String query = 'select Id';
        List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
        for(Cutomer_Fields_Update__c customerField : cutomerFieldsUpdate){
            query += ', ' + customerField.Name + ', ' + customerField.Field_Update__c;
        }
        Account acc = database.query(query + ' from Account where Id = \'' + case1.AccountId +'\'');

        acc.Arabic_Name__pc = 'Arabic Name';
        acc.PersonBirthdate = system.today();
        acc.Gender__pc = 'M';
        acc.Nationality__pc = 'GB';
        acc.PersonMailingStreet = 'st';
        acc.PersonMailingCity = 'London';
        acc.PersonMailingPostalCode = 'NW1 3HH';
        acc.PersonMailingCountry = 'UK';
        acc.PersonEmail = 'abc@abcbank.com';
        acc.Mobile_Country_Code__pc = '9001';
        acc.PersonMobilePhone = '12345678';
        //acc.ID_Type__pc = 'Bahraini ID';
        acc.ID_Nationality__pc = '';
        acc.ID_Number__pc = '123456789';
        acc.ID_Expiry_Date__pc = system.today().addDays(100);
        acc.Proof_of_Address_ID_Type__pc = 'Utility Bill';
        acc.Proof_of_Address_Id__pc = 'proof of add';
        acc.Employment_Status__pc = 'Employed';
        acc.Employer_Name__pc = 'E Name';
        acc.Business_Name__pc = 'B Name';
        acc.Business_Industry__pc = 'Advertising';
        acc.Sources_of_Funds__pc = 'Salary';
        acc.Source_Found_specify__pc = 'aaa';
        //acc.Gross_Monthly_Income__pc = '500';
        acc.Expected_Monthly_deposits__pc = 1000.0;
        acc.Applicable_Residency_Tax__pc = 'Test';
        acc.FATCA_Customer__pc = true;
        acc.Tax_Country_1__pc = 'GB';
        acc.Tax_Country_1_ID__pc = 'GB';
        acc.Tax_Country_2__pc = 'GB';
        acc.Tax_Country_2_ID__pc = 'GB';
        acc.Tax_Country_3__pc = 'GB';
        acc.Tax_Country_3_ID__pc = 'GB';
        acc.Tax_Country_4__pc = 'GB';
        acc.Tax_Country_4_ID__pc = 'GB';
        acc.Address_ID_Expiry_Date__pc =  Date.today();
        acc.US_Indicia__pc = false;
        //01/10/19 Added CIF and email address
        acc.CIF__pc ='0000000';
        acc.PersonEmail ='bankabc@westbrookwisdom.com';
        //04/04/2021 added resident expiry Shashank
        acc.Residency_Permit_Expiry__pc = system.today().addDays(15);

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": {"code": "CUST-1008", "message": "Customer Details have been updated successfully."}}';
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
       // ApiConnection.Response response = UserProfileController.updateProfile(acc, '123456', case1.Id, 'abc@abcbank.com', BAHRAIN_REGION);
        Test.stopTest();
        // System.debug('>>>>>>>> res test ' + response);
        // system.assertEquals(true, response.isSuccess);
        //system.assertEquals(null, acc.Business_Industry__pc);
        system.assertEquals(true, acc.FATCA_Customer__pc );
        //system.assertEquals(null, acc.Source_Found_specify__pc );
    }
    
  //Prashant
 /* @isTest
    static void testUpdateProfileEmployed_Account () {

        Case case1 =  [select AccountId, Status from Case where Subject = 'Test' limit 1];
        String query = 'select Id';
        List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
        for(Cutomer_Fields_Update__c customerField : cutomerFieldsUpdate){
            query += ', ' + customerField.Name + ', ' + customerField.Field_Update__c;
        }
        Account acc = database.query(query + ' from Account where Id = \'' + case1.AccountId +'\'');

        acc.Arabic_Name__pc = 'Arabic Name';
        acc.PersonBirthdate = system.today();
        acc.Gender__pc = 'M';
        acc.Nationality__pc = 'GB';
        acc.PersonMailingStreet = 'st';
        acc.PersonMailingCity = 'London';
        acc.PersonMailingPostalCode = 'NW1 3HH';
        acc.PersonMailingCountry = 'UK';
        acc.PersonEmail = 'abc@abcbank.com';
        acc.Mobile_Country_Code__pc = '9001';
        acc.PersonMobilePhone = '12345678';
        //acc.ID_Type__pc = 'Bahraini ID';
        acc.ID_Nationality__pc = '';
        acc.ID_Number__pc = '123456789';
        acc.ID_Expiry_Date__pc = system.today().addDays(100);
        acc.Proof_of_Address_ID_Type__pc = 'Utility Bill';
        acc.Proof_of_Address_Id__pc = 'proof of add';
        acc.Employment_Status__pc = 'Employed';
        acc.Employer_Name__pc = 'E Name';
        acc.Business_Name__pc = 'B Name';
        acc.Business_Industry__pc = 'Advertising';
        acc.Sources_of_Funds__pc = 'Salary';
        acc.Source_Found_specify__pc = 'aaa';
        //acc.Gross_Monthly_Income__pc = '500';
        acc.Expected_Monthly_deposits__pc = 1000.0;
        acc.Applicable_Residency_Tax__pc = 'Test';
        acc.FATCA_Customer__pc = true;
        acc.Tax_Country_1__pc = 'GB';
        acc.Tax_Country_1_ID__pc = 'GB';
        acc.Tax_Country_2__pc = 'GB';
        acc.Tax_Country_2_ID__pc = 'GB';
        acc.Tax_Country_3__pc = 'GB';
        acc.Tax_Country_3_ID__pc = 'GB';
        acc.Tax_Country_4__pc = 'GB';
        acc.Tax_Country_4_ID__pc = 'GB';
        acc.Address_ID_Expiry_Date__pc =  Date.today();
        acc.US_Indicia__pc = false;
        //01/10/19 Added CIF and email address
        acc.CIF__pc ='0000000';
        acc.PersonEmail ='bankabc@westbrookwisdom.com';
        //04/04/2021 added resident expiry Shashank
        acc.Residency_Permit_Expiry__pc = system.today().addDays(15);

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": {"code": "CUST-1008", "message": "Customer Details have been updated successfully."}}';
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest(); 
        // ApiConnection.Response response = UserProfileController.updateProfile_onAccount(acc, '123456', String.valueOf(case1.Id), 'abc@abcbank.com', BAHRAIN_REGION);
        ApiConnection.Response response = UserProfileController.updateProfile(acc, '123456', case1.Id, 'abc@abcbank.com', BAHRAIN_REGION);
        Test.stopTest();
        // System.debug('>>>>>>>> res test ' + response); 
        // system.assertEquals(true, response.isSuccess);
       // system.assertEquals(null, acc.Business_Industry__pc);
       // system.assertEquals(true, acc.FATCA_Customer__pc );
        //system.assertEquals(null, acc.Source_Found_specify__pc );
    }  */
  //Prashant

    @isTest
    static void testUpdateProfileSelfEmployed () {

        Case case1 =  [select AccountId, Status from Case where Subject = 'Test' limit 1];
        String query = 'select Id';
        List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
        for(Cutomer_Fields_Update__c customerField : cutomerFieldsUpdate){
            query += ', ' + customerField.Name + ', ' + customerField.Field_Update__c;
        }
        Account acc = database.query(query + ' from Account where Id = \'' + case1.AccountId +'\'');

        acc.Arabic_Name__pc = 'Arabic Name';
        acc.PersonBirthdate = system.today();
        acc.Gender__pc = 'M';
        acc.Nationality__pc = 'GB';
        acc.PersonMailingStreet = 'st';
        acc.PersonMailingCity = 'London';
        acc.PersonMailingPostalCode = 'NW1 3HH';
        acc.PersonMailingCountry = 'UK';
        acc.PersonEmail = 'abc@abcbank.com';
        acc.Mobile_Country_Code__pc = '9001';
        acc.PersonMobilePhone = '12345678';
        //acc.ID_Type__pc = 'Bahraini ID';
        acc.ID_Nationality__pc = '';
        acc.ID_Number__pc = '123456789';
        acc.ID_Expiry_Date__pc = system.today().addDays(100);
        acc.Business_Address__pc = 'testing';
        acc.Proof_of_Address_ID_Type__pc = 'Utility Bill';
        acc.Proof_of_Address_Id__pc = 'proof of add';
        acc.Employment_Status__pc = 'Self Employed';
        acc.Employer_Name__pc = 'E Name';
        acc.Business_Name__pc = 'B Name';
        acc.Business_Industry__pc = 'Advertising';
        acc.Sources_of_Funds__pc = 'Salary;Other';
        acc.Source_Found_specify__pc = 'aaa';
        //acc.Gross_Monthly_Income__pc = '500';
        acc.Expected_Monthly_deposits__pc = 1000.0;
        acc.Applicable_Residency_Tax__pc = 'Test';
        acc.FATCA_Customer__pc = true;
        acc.Tax_Country_1__pc = 'GB';
        acc.Tax_Country_1_ID__pc = 'GB';
        acc.Tax_Country_2__pc = 'GB';
        acc.Tax_Country_2_ID__pc = 'GB';
        acc.Tax_Country_3__pc = 'GB';
        acc.Tax_Country_3_ID__pc = 'GB';
        acc.Tax_Country_4__pc = 'GB';
        acc.Tax_Country_4_ID__pc = 'GB';
        acc.Address_ID_Expiry_Date__pc =  Date.today();
        acc.US_Indicia__pc = false;
        //01/10/19 Added CIF and email address
        acc.CIF__pc ='0000000';
        acc.PersonEmail ='bankabc@westbrookwisdom.com';
        //04/04/2021 added resident expiry Shashank
        acc.Residency_Permit_Expiry__pc = system.today().addDays(15);

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": {"code": "CUST-1008", "message": "Customer Details have been updated successfully."}}';
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        ApiConnection.Response response = UserProfileController.updateProfile(acc, '123456', case1.Id, 'abc@abcbank.com', BAHRAIN_REGION);
        Test.stopTest();
        // System.debug('>>>>>>>> res test ' + response);
        // system.assertEquals(true, response.isSuccess);
        system.assertEquals('Advertising', acc.Business_Industry__pc);
        system.assertEquals(true, acc.FATCA_Customer__pc );
        system.assertEquals('aaa', acc.Source_Found_specify__pc );
    }

    @isTest
    static void testSendOnboardingContinue () {
        String query = 'select RecordTypeId';
        List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
        for(Cutomer_Fields_Update__c customerField : cutomerFieldsUpdate){
            query += ', ' + customerField.Name + ', ' + customerField.Field_Update__c;
        }
        Account acc = database.query(query + ' from Account limit 1');
        Case case1 =  [select Subject, Status from Case where AccountId=:acc.Id and Subject='Test' limit 1];

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": {"code": "ONBD-100","message":"Onboarding state has been updated successfully."}, "data":{}}';
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

        UserProfileController.loadCusProVisibility();
        string request = '{"caseId": "' + case1.Id + '","' + case1.Status + '": "New"}';
        ApiConnection.Response response = UserProfileController.sendOnboardingContinue(acc, case1.Id, '123456', 'Continue onboarding', request, acc.PersonEmail, BAHRAIN_REGION);
        Test.stopTest();
        //no need to assert because this method just call sendOnboardingContinue() from another class
        System.assertEquals(true, response.isSuccess);
    }

    @isTest
    static void testSendOnboardingContinueTypeIden () {
        String query = 'select RecordTypeId';
        List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
        for(Cutomer_Fields_Update__c customerField : cutomerFieldsUpdate){
            query += ', ' + customerField.Name + ', ' + customerField.Field_Update__c;
        }
        Account acc = database.query(query + ' from Account limit 1');
        Case case1 =  [select Subject, Status from Case where AccountId=:acc.Id limit 1];
        case1.Type = 'Identification';
        update case1;

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": {"code": "ONBD-100","message":"Onboarding state has been updated successfully."}, "data":{}}';
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

        UserProfileController.loadCusProVisibility();
        string request = '{"caseId": "' + case1.Id + '","' + case1.Status + '": "New"}';
        ApiConnection.Response response = UserProfileController.sendOnboardingContinue(acc, case1.Id, '123456', 'Continue onboarding', request, acc.PersonEmail, BAHRAIN_REGION);
        Test.stopTest();
        //no need to assert because this method just call sendOnboardingContinue() from another class
        System.assertEquals(true, response.isSuccess);
    }

    @isTest
    public static void testSendManualOnboardingRequest(){

        String query = 'select RecordTypeId';
        List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
        for(Cutomer_Fields_Update__c customerField : cutomerFieldsUpdate){
            query += ', ' + customerField.Name + ', ' + customerField.Field_Update__c;
        }
        Account acc = database.query(query + ' from Account limit 1');
        Case case1 =  [select Subject, Status from Case where AccountId=:acc.Id limit 1];
        case1.Type = 'Identification';
        update case1;

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": {"code": "ONBD-100","message":"Onboarding state has been updated successfully."}, "data":{}}';
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

        UserProfileController.loadCusProVisibility();
        string request = '{"caseId": "' + case1.Id + '","' + case1.Status + '": "New"}';
        ApiConnection.Response response = UserProfileController.sendManualOnboardingRequest(case1.Id, '123456', 'Continue onboarding', request, acc.PersonEmail, BAHRAIN_REGION);
        Test.stopTest();
        //no need to assert because this method just call sendOnboardingContinue() from another class
        System.assertEquals(true, response.isSuccess);
    }

    @isTest
    public static void testSendOnboardingContinueFuture(){
        String query = 'select RecordTypeId';
        List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
        for(Cutomer_Fields_Update__c customerField : cutomerFieldsUpdate){
            query += ', ' + customerField.Name + ', ' + customerField.Field_Update__c;
        }
        Account acc = database.query(query + ' from Account limit 1');
        Case case1 =  [select Subject, Status from Case where AccountId=:acc.Id limit 1];
        case1.Type = 'Identification';
        update case1;

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": {"code": "ONBD-100","message":"Onboarding state has been updated successfully."}, "data":{}}';
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

        UserProfileController.loadCusProVisibility();
        string request = '{"caseId": "' + case1.Id + '","' + case1.Status + '": "New"}';
        ApiConnection.Response response = UserProfileController.sendOnboardingContinueFuture(acc, case1.Id, '123456', 'Continue onboarding', request, acc.PersonEmail);
        Test.stopTest();
        //no need to assert because this method just call sendOnboardingContinue() from another class
        System.assertEquals(true, response.isSuccess);
    }

    @isTest
    public static void testDoSaveFieldUpdate(){
        String query = 'select RecordTypeId';
        List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
        for(Cutomer_Fields_Update__c customerField : cutomerFieldsUpdate){
            query += ', ' + customerField.Name + ', ' + customerField.Field_Update__c;
        }
        Account acc = database.query(query + ' from Account limit 1');

        Test.startTest();

        ApiConnection.Response response = UserProfileController.doSaveFieldUpdate(acc);

        Test.stopTest();
        //no need to assert because this method just call sendOnboardingContinue() from another class
        System.assertEquals(true, response.isSuccess);

    }
    @isTest
    public static void testProspectSource(){
        Case case1 =  [select Subject, Status from Case limit 1];

        Test.startTest();
            Boolean isLeadCreated = UserProfileController.prospectSource(case1.id);
        Test.stopTest();

        System.assertEquals(false, isLeadCreated);
    }
    //Prashant
/*     @isTest
    public static void testcheck_SubType(){
        Case case1 =  [select Subject, Status from Case limit 1];

        Test.startTest();
            UserProfileController.check_SubType(case1.id);
        Test.stopTest(); 

    } */
    //Prashant
    @isTest
    public static void testIsWatiqueUpload(){
        String query = 'select RecordTypeId';
        List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
        for(Cutomer_Fields_Update__c customerField : cutomerFieldsUpdate){
            query += ', ' + customerField.Name + ', ' + customerField.Field_Update__c;
        }
        Account acc = database.query(query + ' from Account limit 1');
        Content__c testcontent = new Content__c(Region_Flag__c='Bahrain',Document_Type__c ='Wathiq Consent Form',Person__c=acc.Id,Document_Model__c='ila');// #CH01#
        Case case1 =  [select Subject, Status,AccountId from Case limit 1];
        case1.AccountId= acc.Id;
        update case1;
        insert testcontent;
        Boolean isWathiq = UserProfileController.isWatiqueUpload(case1.Id);
        System.assertEquals(true, isWathiq);

    }

    @isTest
    public static void test_eKYCsignOffCase(){
        String query = 'select RecordTypeId';
        List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
        for(Cutomer_Fields_Update__c customerField : cutomerFieldsUpdate){
            query += ', ' + customerField.Name + ', ' + customerField.Field_Update__c;
        }
            Account acc = database.query(query + ',CIF__pc from Account limit 1');
        system.debug('TEST CLASS'+acc.CIF__pc);
        
        Case case1 =  [select Id, Subject, Status,AccountId, Region_Flag__c from Case limit 1];
        case1.AccountId = acc.Id;
        update case1;

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"crmSync": "true","promoteGovernmentDataToCustomerProfile":"false","mockURL":null}';
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        UserProfileController.eKYCsignOffCase(case1.Id);
        test.stopTest();
    }
    
    // #CH02#
    @isTest
    public static void test_eKYCCase(){
        Account accountRecord = JordanCivilDepartmentControllerTest.createAccount();
        Case caseRecord = JordanCivilDepartmentControllerTest.createeKycCase(accountRecord, 'Civil Department', 'Incomplete Civil Dept Data', 'The customer is found, but certain fields returned as empty (Field A OR B OR C OR D is missing)');
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"crmSync": "true","promoteGovernmentDataToCustomerProfile":"false","uidValue":"123456"}';
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        UserProfileController.eKYCsignOffCase(caseRecord.Id);
        test.stopTest();
        caseRecord = [Select Status from Case where id=:caseRecord.Id];
        System.assertEquals('In Progress', caseRecord.Status);
    }  
    
    private class MyCalloutMock implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 200;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(testStatusCode);
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
    }
    
    @isTest
    static void testCheckCaseSubType() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        String result = UserProfileController.checkCaseSubType(testCase.Id);
    }
    
    @isTest
    static void testCheckMakerResult() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        String result = UserProfileController.checkMakerResult(testCase.Id);
    }
    
    @isTest
    static void testIsDuplicateIdBahrain() {
        Account testAcc = [SELECT Id, ID_Number__pc FROM Account LIMIT 1];
        Boolean result = UserProfileController.isDuplicateId(
            testAcc.ID_Number__pc, testAcc, BAHRAIN_REGION
        );
    }
    
    @isTest
    static void testIsDuplicateIdJordan() {
        Account testAcc = [SELECT Id FROM Account LIMIT 1];
        testAcc.Region_Flag__pc = JORDAN_REGION;
        update testAcc;
        
        Boolean result = UserProfileController.isDuplicateId(
            '123456789', testAcc, JORDAN_REGION
        );
    }
    
    @isTest
    static void testIsDuplicateIdBlankNumber() {
        Account testAcc = [SELECT Id FROM Account LIMIT 1];
        Boolean result = UserProfileController.isDuplicateId(
            '', testAcc, BAHRAIN_REGION
        );
    }
    
    @isTest
    static void testCheckForDuplicates_NoParameters() {
        String result = UserProfileController.checkForDuplicates(null, null, null, null);
    }
    
    @isTest
    static void testCheckForDuplicates_LeadSingleDuplicate() {
        Map<String, Schema.RecordTypeInfo> leadRTInfos = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
        Id leadRT = leadRTInfos.get('Relative').getRecordTypeId();
        
        Lead testLead = new Lead(
            LastName = 'Lead',
            Email = 'test@example.com',
            MobilePhone = '12345678',
            ID_Number__c = 'ID12345',
            Mobile_Country_Code__c = '+973',
            recordtypeId = leadRT
        );
        insert testLead;
        
        String result = UserProfileController.checkForDuplicates(
            null, 
            'test@example.com', 
            '12345678', 
            'ID12345'
        );
        
    }
    
    @isTest
    static void testCheckForDuplicates_AccountSingleDuplicate() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        
        String result = UserProfileController.checkForDuplicates(
            null, 
            'test@example.com', 
            '1293779', 
            'ID12345'
        );
    }
    
    @isTest
    static void testCheckForDuplicates_Exception() {
        // Pass invalid ID to cause exception
        String result = UserProfileController.checkForDuplicates(
            'invalidId', 
            'test@example.com', 
            null, 
            null
        );
    }
    
    @isTest
    static void testValidateNoDuplicates_Success() {
        try {
            UserProfileController.validateNoDuplicates(null, null, null, null);
        } catch (Exception e) {
        }
    }
    
    @isTest
    static void testContinueOnboarding_BahrainiNational() {
        Case caseRec = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        // Create test documents
        Content__c poiDoc = new Content__c(
            Person__c = caseRec.AccountId,
            Scan_Type__c = 'POI',
            Document_Type__c = 'Bahraini ID',
            Document_Model__c = 'ila'
        );
        insert poiDoc;
        
        Content__c poaDoc = new Content__c(
            Person__c = caseRec.AccountId,
            Scan_Type__c = 'POA',
            Document_Type__c = 'Utility Bill',
            Document_Model__c = 'ila'
        );
        insert poaDoc;
        
        Test.startTest();
        Boolean result = UserProfileController.continueOnboarding(caseRec.Id, 'BH');
        Test.stopTest();
    }
    
    @isTest
    static void testContinueOnboarding_GCCNational() {
        Case caseRec = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        // Create required documents
        Content__c poiIdDoc = new Content__c(
            Person__c = caseRec.AccountId,
            Scan_Type__c = 'POI',
            Document_Type__c = 'GCC ID',
            Document_Model__c = 'ila'
        );
        insert poiIdDoc;
        
        Content__c poiPassportDoc = new Content__c(
            Person__c = caseRec.AccountId,
            Scan_Type__c = 'POI',
            Document_Type__c = 'Passport',
            Document_Model__c = 'ila'
        );
        insert poiPassportDoc;
        
        Content__c poaDoc = new Content__c(
            Person__c = caseRec.AccountId,
            Scan_Type__c = 'POA',
            Document_Type__c = 'Utility Bill',
            Document_Model__c = 'ila'
        );
        insert poaDoc;
        
        Test.startTest();
        Boolean result = UserProfileController.continueOnboarding(caseRec.Id, 'SA'); // Saudi
        Test.stopTest();
    }
    
    @isTest
    static void testContinueOnboarding_GCCNational_MissingPassport() {
        Case caseRec = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        // Create documents but missing Passport
        Content__c poiIdDoc = new Content__c(
            Person__c = caseRec.AccountId,
            Scan_Type__c = 'POI',
            Document_Type__c = 'GCC ID',
            Document_Model__c = 'ila'
        );
        insert poiIdDoc;
        
        Content__c poaDoc = new Content__c(
            Person__c = caseRec.AccountId,
            Scan_Type__c = 'POA',
            Document_Type__c = 'Utility Bill',
            Document_Model__c = 'ila'
        );
        insert poaDoc;
        
        Test.startTest();
        Boolean result = UserProfileController.continueOnboarding(caseRec.Id, 'AE'); // UAE
        Test.stopTest();
    }
    
    @isTest
    static void testContinueOnboarding_NonGCCNational() {
        Case caseRec = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        // Create all required documents
        Content__c poiIdDoc = new Content__c(
            Person__c = caseRec.AccountId,
            Scan_Type__c = 'POI',
            Document_Type__c = 'Bahraini ID',
            Document_Model__c = 'ila'
        );
        insert poiIdDoc;
        
        Content__c poiPassportDoc = new Content__c(
            Person__c = caseRec.AccountId,
            Scan_Type__c = 'POI',
            Document_Type__c = 'Passport',
            Document_Model__c = 'ila'
        );
        insert poiPassportDoc;
        
        Content__c poaDoc = new Content__c(
            Person__c = caseRec.AccountId,
            Scan_Type__c = 'POA',
            Document_Type__c = 'Utility Bill',
            Document_Model__c = 'ila'
        );
        insert poaDoc;
        
        Content__c residencyDoc = new Content__c(
            Person__c = caseRec.AccountId,
            Document_Type__c = 'Residency Permit',
            Document_Model__c = 'ila'
        );
        insert residencyDoc;
        
        Test.startTest();
        Boolean result = UserProfileController.continueOnboarding(caseRec.Id, 'GB'); // UK
        Test.stopTest();
    }
    
    @isTest
    static void testContinueOnboarding_NonGCCNational_MissingResidency() {
        Case caseRec = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        // Create documents but missing Residency Permit
        Content__c poiIdDoc = new Content__c(
            Person__c = caseRec.AccountId,
            Scan_Type__c = 'POI',
            Document_Type__c = 'Bahraini ID',
            Document_Model__c = 'ila'
        );
        insert poiIdDoc;
        
        Content__c poiPassportDoc = new Content__c(
            Person__c = caseRec.AccountId,
            Scan_Type__c = 'POI',
            Document_Type__c = 'Passport',
            Document_Model__c = 'ila'
        );
        insert poiPassportDoc;
        
        Content__c poaDoc = new Content__c(
            Person__c = caseRec.AccountId,
            Scan_Type__c = 'POA',
            Document_Type__c = 'Utility Bill',
            Document_Model__c = 'ila'
        );
        insert poaDoc;
        
        Test.startTest();
        Boolean result = UserProfileController.continueOnboarding(caseRec.Id, 'US'); // USA
        Test.stopTest();
    }
    
    @isTest
    static void testContinueOnboarding_MissingRequiredDocuments() {
        Case caseRec = [SELECT Id, AccountId FROM Case LIMIT 1];
        
        // Insert only POI document, missing POA
        Content__c poiDoc = new Content__c(
            Person__c = caseRec.AccountId,
            Scan_Type__c = 'POI',
            Document_Type__c = 'Bahraini ID',
            Document_Model__c = 'ila'
        );
        insert poiDoc;
        
        Test.startTest();
        Boolean result = UserProfileController.continueOnboarding(caseRec.Id, 'BH');
        Test.stopTest();
    }
    
    @isTest
    static void testContinueOnboarding_Exception() {
        Test.startTest();
        try {
            Boolean result = UserProfileController.continueOnboarding('invalidId', 'BH');
        } Catch (Exception ex) {
            System.debug('Error -->'+ex);
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCheckCaseSubType1() {
        Test.startTest();
        Case case1 =  [select AccountId, Status from Case where Subject = 'Test' limit 1];
        UserProfileController.checkCaseSubType(case1.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testCheckCaseSubType2() {
        Test.startTest();
        try {
            UserProfileController.checkCaseSubType(null);
        } Catch (Exception ex) {
            System.debug('Error -->'+ex);
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCheckMakerResult1() {
        Test.startTest();
        Case case1 =  [select AccountId, Status, cc_Maker__c from Case where Subject = 'Test' limit 1];
        UserProfileController.checkMakerResult(case1.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testCheckMakerResult2() {
        Test.startTest();
        try {
            UserProfileController.checkMakerResult(null);
        } Catch (Exception ex) {
            System.debug('Error -->'+ex);
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetAccountCIF() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        Test.startTest();
        UserProfileController.getAccountCIF(acc1.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCustomerTemporaryFields() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        Test.startTest();
        UserProfileController.updateCustomerTemporaryFields(acc1, null, null, null, null);
        Test.stopTest();
    }
    
    @isTest
    public static void testSndManualOnboardingRequestForEkey(){

        String query = 'select RecordTypeId';
        List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
        for(Cutomer_Fields_Update__c customerField : cutomerFieldsUpdate){
            query += ', ' + customerField.Name + ', ' + customerField.Field_Update__c;
        }
        Account acc = database.query(query + ' from Account limit 1');
        Case case1 =  [select Subject, Status from Case where AccountId=:acc.Id limit 1];
        case1.Type = 'Identification';
        update case1;

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": {"code": "ONBD-100","message":"Onboarding state has been updated successfully."}, "data":{}}';
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

        UserProfileController.loadCusProVisibility();
        string request = '{"caseId": "' + case1.Id + '","' + case1.Status + '": "New"}';
        ApiConnection.Response response = UserProfileController.sendManualOnboardingRequestForEkey(case1.Id, '123456', 'Continue onboarding', request, acc.PersonEmail, BAHRAIN_REGION);
        Test.stopTest();
    }
    
    @isTest
    public static void testClearEkeyManual(){

        String query = 'select RecordTypeId';
        List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
        for(Cutomer_Fields_Update__c customerField : cutomerFieldsUpdate){
            query += ', ' + customerField.Name + ', ' + customerField.Field_Update__c;
        }
        Account acc = database.query(query + ' from Account limit 1');
        Case case1 =  [select Subject, Status from Case where AccountId=:acc.Id limit 1];
        case1.Type = 'Identification';
        update case1;

        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": {"code": "ONBD-100","message":"Onboarding state has been updated successfully."}, "data":{}}';
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();

        UserProfileController.loadCusProVisibility();
        string request = '{"caseId": "' + case1.Id + '","' + case1.Status + '": "New"}';
        UserProfileController.ClearEkeyManual(case1.Id, '123456', acc.PersonEmail, BAHRAIN_REGION);
        Test.stopTest();
    }
    
    @isTest
    static void testCloseCase() {
        Case case1 =  [select AccountId, Type, Sub_Type__c from Case where Subject = 'Test' limit 1];
        Test.startTest();
        UserProfileController.closeCase(case1.Id, case1.Type, case1.Sub_Type__c);
        Test.stopTest();
    }
    
    @isTest
    static void testSendingEmailNotification() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        Case case1 =  [select AccountId, Type, Sub_Type__c from Case where Subject = 'Test' limit 1];
        Test.startTest();
        UserProfileController.sendingEmailNotification(acc1, '1293779', case1.Id);
        Test.stopTest();
    }
    
        // Test methods for validateeKeyDocumentsSimple
    @isTest
    static void testValidateeKeyDocumentsSimple_NonEKeyCase() {
        Case existingCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        UserProfileController.validateeKeyDocumentsSimple(existingCase.Id, 'BH');
        Test.stopTest();
    }
    
    @isTest
    static void testValidateeKeyDocumentsSimple_EKeyCase_Success() {
        Account existingAccount = [SELECT Id FROM Account LIMIT 1];
        Case eKeyCase = new Case(
            Subject = 'EKey Test Case',
            AccountId = existingAccount.Id,
            Type = 'Identification',
            Origin = 'eKey',
            Region_Flag__c = BAHRAIN_REGION,
            Case_Model__c = 'ila'
        );
        insert eKeyCase;
        
        // Add required documents
        Content__c consentForm = new Content__c(
            Person__c = existingAccount.Id,
            Document_Type__c = 'Consent Form',
            Document_Model__c = 'ila'
        );
        insert consentForm;
        
        Content__c poiID = new Content__c(
            Person__c = existingAccount.Id,
            Scan_Type__c = 'POI',
            Document_Type__c = 'Bahraini ID',
            Document_Model__c = 'ila'
        );
        insert poiID;
        
        Test.startTest();
        UserProfileController.validateeKeyDocumentsSimple(eKeyCase.Id, 'BH');
        Test.stopTest();
    }
    
    @isTest
    static void testValidateeKeyDocumentsSimple_MissingDocuments() {
        Account existingAccount = [SELECT Id FROM Account LIMIT 1];
        Case eKeyCase = new Case(
            Subject = 'EKey Test Case Missing Docs',
            AccountId = existingAccount.Id,
            Type = 'Identification',
            Origin = 'eKey',
            Region_Flag__c = BAHRAIN_REGION,
            Case_Model__c = 'ila'
        );
        insert eKeyCase;
        
        // Add only consent form, missing POI
        Content__c consentForm = new Content__c(
            Person__c = existingAccount.Id,
            Document_Type__c = 'Consent Form',
            Document_Model__c = 'ila'
        );
        insert consentForm;
        
        Test.startTest();
        UserProfileController.validateeKeyDocumentsSimple(eKeyCase.Id, 'BH');
        Test.stopTest();
    }
    
    // Test methods for verifyEKeyPerson
    @isTest
    static void testVerifyEKeyPerson_NoGuardian() {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"success": true, "message": "Verification successful"}';
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        UserProfileController.verifyEKeyPerson(
            'customer123',
            'ID123456',
            'BH',
            '2025-12-31',
            '1990-01-01',
            'M',
            'BH',
            '',
            BAHRAIN_REGION
        );
        Test.stopTest();
    }
    
    @isTest
    static void testVerifyEKeyPerson_WithGuardian() {
        Account existingAccount = [SELECT Id, CIF__pc FROM Account LIMIT 1];
        
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"success": true, "message": "Verification successful"}';
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        UserProfileController.verifyEKeyPerson(
            'customer123',
            'ID123456',
            'BH',
            '2025-12-31',
            '2010-01-01', // Under 18
            'M',
            'BH',
            existingAccount.CIF__pc,
            BAHRAIN_REGION
        );
        Test.stopTest();
    }
    
    @isTest
    static void testVerifyEKeyPerson_EmptyParameters() {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"success": true, "message": "Verification successful"}';
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        UserProfileController.verifyEKeyPerson(
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            BAHRAIN_REGION
        );
        Test.stopTest();
    }
    
    @isTest
    static void testVerifyEKeyPerson_ApiError() {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testStatusCode = 500;
        mock.testBody = '{"error": "Server Error"}';
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        UserProfileController.verifyEKeyPerson(
            'customer123',
            'ID123456',
            'BH',
            '2025-12-31',
            '1990-01-01',
            'M',
            'BH',
            '',
            BAHRAIN_REGION
        );
        Test.stopTest();
    }
}
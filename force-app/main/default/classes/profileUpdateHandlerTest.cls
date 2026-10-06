/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:27-02-2023
 * 		Change History: 
 *			  
*/
@isTest
public class profileUpdateHandlerTest {
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
    private class MyCalloutMockFailure implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 400;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('NOT OK');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(testStatusCode);
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
    }
    
    @testSetup static void setup(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
         Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
         User u = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);
    }
    @isTest
    static void unitTest1(){
         Id custRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
         Id custProfileUpdateRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Profile Update').getRecordTypeId();

         Account acc = new Account();
         acc.RecordTypeId = custRecordTypeId;
         acc.FirstName='John';
         acc.LastName = 'Cena';
         acc.PersonEmail = 'johncena@gmail.com';
         acc.PersonMobilePhone = '76575658';
         acc.Mobile_Country_Code__pc = '+973';
         acc.Mobile_Update__pc = '89067890';
         acc.Mobile_Country_Code_Update__pc = '+91';
         insert acc;
         
         User u = [Select id from User WHERE IsActive = true LIMIT 1];
         Test.startTest();
         Case cs1 = new Case();
         cs1.RecordTypeId = custProfileUpdateRecordTypeId;
         cs1.AccountId = acc.Id;
         cs1.Type = 'Personal Info Update';
         cs1.Sub_Type__c = 'Mobile update';
         cs1.Case_Model__c = 'ila';
         cs1.Case_Nature__c = 'Personal info update';
         cs1.Origin = 'Email';
         insert cs1;
        
         cs1.cc_Maker__c = 'Send to Checker';
         update cs1;
         System.runAs(u) {
         	cs1.cc_Checker_Result__c = 'Approve';
         	update cs1;
         }
         final MyCalloutMock mock = new MyCalloutMock();
         mock.testBody = '{"meta": {"code": "CUST-1008", "message": "Customer Details have been updated successfully."}}';
         Test.setMock(HttpCalloutMock.class, mock);
		 Test.stopTest();
	}
    
    @isTest
    static void unitTest2(){
         Id custRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
         Id custProfileUpdateRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Profile Update').getRecordTypeId();

         Account acc = new Account();
         acc.RecordTypeId = custRecordTypeId;
         acc.FirstName='John';
         acc.LastName = 'Cena';
         acc.PersonEmail = 'undertaker@gmail.com';
         acc.Email_Update__pc = 'johncena@gmail.com';
         insert acc;
         
         User u = [Select id from User WHERE IsActive = true LIMIT 1];
         Test.startTest();
         Case cs1 = new Case();
         cs1.RecordTypeId = custProfileUpdateRecordTypeId;
         cs1.AccountId = acc.Id;
         cs1.Type = 'Personal Info Update';
         cs1.Sub_Type__c = 'Email update';
         cs1.Case_Model__c = 'ila';
         cs1.Case_Nature__c = 'Personal info update';
         cs1.Origin = 'Email';
         insert cs1;
        
         cs1.cc_Maker__c = 'Send to Checker';
         update cs1;
         System.runAs(u) {
         	cs1.cc_Checker_Result__c = 'Approve';
         	update cs1;
         }
         final MyCalloutMock mock = new MyCalloutMock();
         mock.testBody = '{"meta": {"code": "CUST-1008", "message": "Customer Details have been updated successfully."}}';
         Test.setMock(HttpCalloutMock.class, mock);
		 Test.stopTest();
	}
    
     @isTest
    static void unitTest3(){
         Id custRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
         Id custProfileUpdateRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Profile Update').getRecordTypeId();

         Account acc = new Account();
         acc.RecordTypeId = custRecordTypeId;
         acc.FirstName='John';
         acc.LastName = 'Cena';
         acc.PersonEmail = 'undertaker@gmail.com';
         acc.Email_Update__pc = 'johncena@gmail.com';
         acc.ID_Type__pc = 'Bahraini ID';
         acc.ID_Type_Update__pc = 'Passport';
         acc.ID_Expiry_Date__pc = System.today();
         acc.ID_Expiry_Date_Update__pc = System.today() + 360;
         insert acc;
         
         User u = [Select id from User WHERE IsActive = true LIMIT 1];
         Test.startTest();
         Case cs1 = new Case();
         cs1.RecordTypeId = custProfileUpdateRecordTypeId;
         cs1.AccountId = acc.Id;
         cs1.Type = 'Personal Info Update';
         cs1.Sub_Type__c = 'Expired ID Update';
         cs1.Case_Model__c = 'ila';
         cs1.Case_Nature__c = 'Personal info update';
         cs1.Origin = 'Email';
         insert cs1;
        
         cs1.cc_Maker__c = 'Send to Checker';
         update cs1;
         System.runAs(u) {
         	cs1.cc_Checker_Result__c = 'Approve';
         	update cs1;
         }
         final MyCalloutMock mock = new MyCalloutMock();
         mock.testBody = '{"meta": {"code": "CUST-1008", "message": "Customer Details have been updated successfully."}}';
         Test.setMock(HttpCalloutMock.class, mock);
		 Test.stopTest();
	}
 @isTest
    static void unitTest4(){
         Id custRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
         Id custProfileUpdateRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Profile Update').getRecordTypeId();

         Account acc = new Account();
         acc.RecordTypeId = custRecordTypeId;
         acc.FirstName='John';
         acc.MiddleName='T';
         acc.LastName = 'Cena';
         acc.FirstName_Update__pc = 'Christaino';
         acc.MiddleName_Update__pc = 'M';
         acc.LastName_Update__pc = 'Ronaldo';
         acc.PersonEmail = 'undertaker@gmail.com';
         acc.Email_Update__pc = 'johncena@gmail.com';
         acc.ID_Type__pc = 'Bahraini ID';
         acc.ID_Type_Update__pc = 'Passport';
         acc.ID_Expiry_Date__pc = System.today();
         acc.ID_Expiry_Date_Update__pc = System.today() + 360;
         acc.Bypass_Validations__pc  = true;
         insert acc;
         
         User u = [Select id from User WHERE IsActive = true LIMIT 1];
         Test.startTest();
         Case cs1 = new Case();
         cs1.RecordTypeId = custProfileUpdateRecordTypeId;
         cs1.AccountId = acc.Id;
         cs1.Type = 'Personal Info Update';
         cs1.Sub_Type__c = 'Name Fix / Update';
         cs1.Case_Model__c = 'ila';
         cs1.Case_Nature__c = 'Personal info update';
         cs1.Origin = 'Email';
         insert cs1;
        
         cs1.cc_Maker__c = 'Send to Checker';
         update cs1;
         System.runAs(u) {
         	cs1.cc_Checker_Result__c = 'Approve';
         	update cs1;
         }
         final MyCalloutMock mock = new MyCalloutMock();
         mock.testBody = '{"meta": {"code": "CUST-1008", "message": "Customer Details have been updated successfully."}}';
         Test.setMock(HttpCalloutMock.class, mock);
		 Test.stopTest();
	}

    @isTest
    static void unitTest5(){
         Id custRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
         Id custProfileUpdateRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Profile Update').getRecordTypeId();

         Account acc = new Account();
         acc.RecordTypeId = custRecordTypeId;
         acc.FirstName='John';
         acc.MiddleName='T';
         acc.LastName = 'Cena';
         acc.PersonEmail = 'undertaker@gmail.com';
         acc.Email_Update__pc = 'johncena@gmail.com';
         acc.Proof_of_Address_Id__pc = 'Bahraini Drivers Licence';
         acc.Proof_of_Address_ID_Type__pc = 'Bahraini Drivers Licence';
         acc.Address_ID_Expiry_Date__pc = System.today();
         acc.PersonMailingStreet = 'Bank ABC Tower Building 152';
         acc.PersonMailingCity = 'Manama';
         acc.PersonMailingPostalCode = '67548';
         acc.PersonMailingCountry = 'Baharain';
         acc.Proof_of_Address_Id_Update__pc = 'Passport Details';
         acc.Proof_of_Address_ID_Type_Update__pc = 'Passport';
		 acc.Address_ID_Expiry_Date_Update__pc = System.today() + 365;
		 acc.Mailing_Street_Update__pc = 'Abu Owaina Street';
		 acc.Mailing_City_Update__pc = 'Qatar';
		 acc.Postcode_Block_Update__pc = '5464';
         acc.Mailing_Country_Update__pc = 'Qatar';
         acc.Bypass_Validations__pc  = true;
         insert acc;
         
         User u = [Select id from User WHERE IsActive = true LIMIT 1];
         Test.startTest();
         Case cs1 = new Case();
         cs1.RecordTypeId = custProfileUpdateRecordTypeId;
         cs1.AccountId = acc.Id;
         cs1.Type = 'Personal Info Update';
         cs1.Sub_Type__c = 'Address update';
         cs1.Case_Model__c = 'ila';
         cs1.Case_Nature__c = 'Personal info update';
         cs1.Origin = 'Email';
         insert cs1;
        
         cs1.cc_Maker__c = 'Send to Checker';
         update cs1;
         System.runAs(u) {
         	cs1.cc_Checker_Result__c = 'Approve';
         	update cs1;
         }
         final MyCalloutMock mock = new MyCalloutMock();
         mock.testBody = '{"meta": {"code": "CUST-1008", "message": "Customer Details have been updated successfully."}}';
         Test.setMock(HttpCalloutMock.class, mock);
		 Test.stopTest();
	}
     @isTest
    static void unitTest6(){
         Id custRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
         Id custProfileUpdateRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Profile Update').getRecordTypeId();

         Account acc = new Account();
         acc.RecordTypeId = custRecordTypeId;
         acc.FirstName='John';
         acc.LastName = 'Cena';
         acc.PersonEmail = 'undertaker@gmail.com';
         acc.Minor__pc = false;
         acc.Guardian_CIF__pc = '';
         acc.Minor_Update__pc = true;
         acc.Guardian_CIF_Update__pc = '5678908';
         insert acc;
         
         User u = [Select id from User WHERE IsActive = true LIMIT 1];
         Test.startTest();
         Case cs1 = new Case();
         cs1.RecordTypeId = custProfileUpdateRecordTypeId;
         cs1.AccountId = acc.Id;
         cs1.Type = 'Personal Info Update';
         cs1.Sub_Type__c = 'Guardian Info';
         cs1.Case_Model__c = 'ila';
         cs1.Case_Nature__c = 'Personal info update';
         cs1.Origin = 'Email';
         insert cs1;
        
         cs1.cc_Maker__c = 'Send to Checker';
         update cs1;
         System.runAs(u) {
         	cs1.cc_Checker_Result__c = 'Approve';
         	update cs1;
         }
         final MyCalloutMock mock = new MyCalloutMock();
         mock.testBody = '{"meta": {"code": "CUST-1008", "message": "Customer Details have been updated successfully."}}';
         Test.setMock(HttpCalloutMock.class, mock);
		 Test.stopTest();
	}
     @isTest
    static void unitTest7(){
         Id custRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
         Id custProfileUpdateRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Profile Update').getRecordTypeId();

         Account acc = new Account();
         acc.RecordTypeId = custRecordTypeId;
         acc.FirstName='John';
         acc.LastName = 'Cena';
         acc.PersonEmail = 'undertaker@gmail.com';
         acc.Residency_Permit_Number__pc = 'BHR564847';
         acc.Residency_Permit_Expiry__pc = System.today();
         acc.Employment_Status__pc = 'Employed';
         acc.Employer_Name__pc = 'Bank ABC';
         acc.Employer_Country__pc = 'BH';
         acc.Business_Name__pc = 'Marketing';
         acc.Business_Industry__pc = 'Central Bank';
         acc.Residency_Permit_Number_Update__pc = 'BHR564891';
         acc.Residency_Permit_Expiry_Update__pc = System.today() + 365;
         acc.Employment_Status_Update__pc = 'Self Employed';
         acc.Employer_Name_Update__pc = 'Ila Bank';
         acc.Employer_Country_Update__pc = 'IN';
         acc.Business_Name_Update__pc = 'Advertising';
         acc.Business_Industry_Update__pc = 'Advertising';
		 insert acc;
         
         User u = [Select id from User WHERE IsActive = true LIMIT 1];
         Test.startTest();
         Case cs1 = new Case();
         cs1.RecordTypeId = custProfileUpdateRecordTypeId;
         cs1.AccountId = acc.Id;
         cs1.Type = 'Personal Info Update';
         cs1.Sub_Type__c = 'Additional Information';
         cs1.Case_Model__c = 'ila';
         cs1.Case_Nature__c = 'Personal info update';
         cs1.Origin = 'Email';
         insert cs1;
        
         cs1.cc_Maker__c = 'Send to Checker';
         update cs1;
         System.runAs(u) {
         	cs1.cc_Checker_Result__c = 'Approve';
         	update cs1;
         }
         final MyCalloutMock mock = new MyCalloutMock();
         mock.testBody = '{"meta": {"code": "CUST-1008", "message": "Customer Details have been updated successfully."}}';
         Test.setMock(HttpCalloutMock.class, mock);
		 Test.stopTest();
	}
     @isTest
    static void unitTest8(){
         Id custRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
         Id custProfileUpdateRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Profile Update').getRecordTypeId();

         Account acc = new Account();
         acc.RecordTypeId = custRecordTypeId;
         acc.FirstName='John';
         acc.LastName = 'Cena';
         acc.PersonEmail = 'undertaker@gmail.com';
         acc.Email_Update__pc = 'johncena@gmail.com';
         insert acc;
         
         User u = [Select id from User WHERE IsActive = true LIMIT 1];
         Test.startTest();
         Case cs1 = new Case();
         cs1.RecordTypeId = custProfileUpdateRecordTypeId;
         cs1.AccountId = acc.Id;
         cs1.Type = 'Personal Info Update';
         cs1.Sub_Type__c = 'Email update';
         cs1.Case_Model__c = 'ila';
         cs1.Case_Nature__c = 'Personal info update';
         cs1.Origin = 'Email';
         insert cs1;
        
         cs1.cc_Maker__c = 'Send to Checker';
         update cs1;
         System.runAs(u) {
         	cs1.cc_Checker_Result__c = 'Approve';
         	update cs1;
         }
         final MyCalloutMockFailure mock = new MyCalloutMockFailure();
         mock.testBody = '{"meta":{"code":"CUST-0080","message":"Unable to update the customer data because the requirements are not met."}}';
         Test.setMock(HttpCalloutMock.class, mock);
		 Test.stopTest();
	}

	@isTest
    static void unitTest9(){
         Test.startTest();
         profileUpdateHandler.generateRandomString(2);
		 Test.stopTest();
	}
}
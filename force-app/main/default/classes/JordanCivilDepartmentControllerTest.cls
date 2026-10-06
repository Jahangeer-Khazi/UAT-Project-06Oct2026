/**
 *  Test methods for JordanCivilDepartmentController
 *  @author: YZ
 *  @createdDate: 2022-06-28
 *
 */
@isTest(isParallel=true)
public class JordanCivilDepartmentControllerTest {
    @isTest
    static void testGetCaseDetails () {
        Account accountRecord = createAccount();
        Case caseRecord = createeKycCase(accountRecord, 'eKYC', 'No Returned Data From Civil Service', 'No Returned Data due to No Record / API Error / Invalid Response / Can\'t log in to service');
        Test.startTest();
        Case returnedCase = JordanCivilDepartmentController.getCaseDetails(caseRecord.Id);
        Test.stopTest();
        returnedCase = [Select Region_Flag__c from Case where id=:returnedCase.Id];
        System.assertEquals('Jordan', returnedCase.Region_Flag__c);
    } 

    @isTest
    static void testeKycRetry () {
        Account accountRecord = createAccount();
        Case caseRecord = createeKycCase(accountRecord, 'eKYC', 'No Returned Data From Civil Service', 'No Returned Data due to No Record / API Error / Invalid Response / Can\'t log in to service');
        Test.setMock(HttpCalloutMock.class, new CalloutMock());
        Test.startTest();
        Boolean responseSuccess = JordanCivilDepartmentController.eKycRetry(caseRecord.Id);
        Test.stopTest();
        System.assertEquals(true, responseSuccess);
    } 

    @isTest
    static void testeKycConvert () {
        Account accountRecord = createAccount();
        Case caseRecord = createeKycCase(accountRecord, 'eKYC', 'No Returned Data From Civil Service', 'No Returned Data due to No Record / API Error / Invalid Response / Can\'t log in to service');
        Test.setMock(HttpCalloutMock.class, new CalloutMock());
        Test.startTest();
        Boolean responseSuccess = JordanCivilDepartmentController.eKycConvert(caseRecord.Id);
        Test.stopTest();
        System.assertEquals(true, responseSuccess);
    } 

    @isTest
    static void testCivilDepartmentInvocableLogicApproved () {
        Account accountRecord = createAccount();
        Case caseRecord = createeKycCase(accountRecord, 'eKYC', 'No Returned Data From Civil Service', 'No Returned Data due to No Record / API Error / Invalid Response / Can\'t log in to service');
        Test.setMock(HttpCalloutMock.class, new CalloutMock());
        Test.startTest();
        caseRecord.Status = 'Approved';
        update caseRecord;
        Test.stopTest();
        caseRecord = [Select Status from Case where id=:caseRecord.Id];
        System.assertEquals('Approved', caseRecord.Status);
    }

    @isTest
    static void testCivilDepartmentInvocableLogicRejected () {
        Account accountRecord = createAccount();
        Case caseRecord = createeKycCase(accountRecord, 'eKYC', 'No Returned Data From Civil Service', 'No Returned Data due to No Record / API Error / Invalid Response / Can\'t log in to service');
        Test.setMock(HttpCalloutMock.class, new CalloutMock());
        Test.startTest();
        caseRecord.Status = 'Rejected';
        update caseRecord;
        Test.stopTest();
        caseRecord = [Select Status from Case where id=:caseRecord.Id];
        System.assertEquals('Rejected', caseRecord.Status);
    }
    
    @isTest
    static void testCivilDepartmentInvocableLogicIdentificationRejected () {
        Account accountRecord = createAccount();
        Case caseRecord = createeKycCase(accountRecord, 'Identification', 'No Returned Data From Civil Service', 'Identification Rejected');
        Test.setMock(HttpCalloutMock.class, new CalloutMock());
        Test.startTest();
        caseRecord.Status = 'Rejected';
        update caseRecord;
        Test.stopTest();
        caseRecord = [Select Status from Case where id=:caseRecord.Id];
        System.assertEquals('Rejected', caseRecord.Status);
    }    

    public static Account createAccount(){
        Account acc = new Account();
        //acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        acc.LastName = 'Smith';
        acc.PersonEmail= 'test.smith@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        acc.CIF__pc = '10001268';
        acc.Region_Flag__pc = 'Jordan';
        acc.Region_Flag__c = 'Jordan';
        insert acc;
        return acc;
    }

    public static Case createeKycCase(Account acc, String typ, String subj, String descr){
        Case objCase = new Case();
        objCase.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('On-Boarding').getRecordTypeId();
        objCase.Subject = subj; // 'No Returned Data From Civil Service';
        objCase.Description = descr; //'No Returned Data due to No Record / API Error / Invalid Response / Can\'t log in to service';
        objCase.Type = typ; // 'eKYC';
        objCase.Status = 'New';
        objCase.Reason = 'PROCEDURAL';
        objCase.Origin = 'Civil';
        objCase.ContactId = acc.PersonContactId;
        objCase.AccountId = acc.id;
        objCase.Region_Flag__c = 'Jordan';
        // objCase.Case_Model__c = 'ila';
        insert objCase;
        return objCase;
        
       // JordanCivilDepartmentController.identificationCall(objCase.id,'Rejected');
    }
    
    @isTest
    public static void createeKycCase02(){
    
         Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        insert acc;
        
        Case objCase = new Case();
        objCase.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('On-Boarding').getRecordTypeId();
        objCase.Subject = 'CIVIL Test'; // 'No Returned Data From Civil Service';
        objCase.Description = 'This iis a test'; //'No Returned Data due to No Record / API Error / Invalid Response / Can\'t log in to service';
        objCase.Type = 'Civil Department'; // 'eKYC';
        objCase.Status = 'New';
        objCase.Reason = 'PROCEDURAL';
        objCase.Origin = 'Civil';
        objCase.ContactId = acc.PersonContactId;
        objCase.AccountId = acc.id;
        objCase.Region_Flag__c = 'Jordan';
        // objCase.Case_Model__c = 'ila';
        insert objCase;
       // return objCase;
       
        final CalloutMock mock = new CalloutMock();
        mock.testBody = '{"crmSync": "true","promoteGovernmentDataToCustomerProfile":"false","uidValue":"123456"}';
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        JordanCivilDepartmentController.identificationCall(objCase.id,'Rejected');
        // JordanCivilDEpartmentController.eKYCCase(caseRecord.Id);
        test.stopTest();
    }

    @isTest
    public static void test_eKYCCase(){
        Account accountRecord = createAccount();
        Case caseRecord = createeKycCase(accountRecord, 'Civil Department', 'Incomplete Civil Dept Data', 'The customer is found, but certain fields returned as empty (Field A OR B OR C OR D is missing)');
        final CalloutMock mock = new CalloutMock();
        mock.testBody = '{"crmSync": "true","promoteGovernmentDataToCustomerProfile":"false","uidValue":"123456"}';
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        JordanCivilDEpartmentController.eKYCCase(caseRecord.Id);
        test.stopTest();
        caseRecord = [Select Status from Case where id=:caseRecord.Id];
        System.assertEquals('In Progress', caseRecord.Status);
    }   
    
    
    private class CalloutMock implements HttpCalloutMock{
        public String testBody;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            return res;
        }
    }
}
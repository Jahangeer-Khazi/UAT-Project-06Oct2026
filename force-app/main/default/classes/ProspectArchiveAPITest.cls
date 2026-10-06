/**
 * @author Imane Tsioucha
 * @date Création 10/11/2023
 * @date Modification
 * @description : Test class of ProspectArchiveAPI.
 * 
 */
@isTest
public with sharing class ProspectArchiveAPITest {
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
    static Case objCase;
    static Account acc1;
    static {
        Id ManualCustomerRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Manual_Customer_Archival').getRecordTypeId();
         acc1 = new Account(
        FirstName = 'Test',
        LastName = 'Test',
        PersonEmail = 'test@gmail.com'
        );
        insert acc1; 
        objCase = new Case(
        RecordTypeId = ManualCustomerRecordId,
        Subject = 'test case',
        Description = 'test',
        Case_Model__c='ila',
        Origin = 'CRM',
        ContactId = acc1.PersonContactId,
        AccountId = acc1.id
        );
        insert objCase;
    }

    @isTest
    static void ProspectArchiveTest () {
        List<Id> accountList = new List<Id>();
        accountList.add(acc1.Id);
        
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{    "meta": {        "code": " ",        "message": " Response."    },    "data": {   "id": "5376802"}}';

        Test.setMock(HttpCalloutMock.class, mock);
         List<String> result = ProspectArchiveAPI.ProspectArchiveFromFlow(accountList);

    }

}
/**
 * @author Imane Tsioucha
 * @date Création 10/11/2023
 * @date Modification
 * @description : Test class of AutomateArchivalProspectCustomer.
 * 
 */
@isTest
public with sharing class AutomateArchivalProspectCustomerTest {
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
        List<Id> CaseList = new List<Id>();
        CaseList.add(objCase.Id);
        
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{    "meta": {        "code": " ",        "message": " Response."    },    "data": {   "id": "5376802"}}';

        Test.setMock(HttpCalloutMock.class, mock);
         List<String> result = AutomateArchivalProspectCustomer.ProspectArchiveFromFlow(CaseList);

    }

    @isTest
    static void createSystemActionTest () {
           List <System_Action__c> act = AutomateArchivalProspectCustomer.createSystemAction('reqBody','resBody','path','DELETE',objCase.Id,'acc1.Id',acc1.Id,200,'action','Success');
            System.assert(act != null);
    }
}
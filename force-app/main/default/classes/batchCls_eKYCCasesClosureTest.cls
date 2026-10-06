/**
 * * Version History :
 *      #ch01  Added by Amina BENABDELKRIM 20-06-2022 *** to add new field (case model)
 *
 */
@isTest(isParallel = true)
public class batchCls_eKYCCasesClosureTest
{
    private class MyCalloutMock implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 200;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');    
            res.setHeader('Content-Type', 'application/json');
            //res.setBody
            res.setStatusCode(testStatusCode);
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
    }
    
    private class MyCalloutMock1 implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 401;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('NOT OK');    
            res.setHeader('Content-Type', 'application/json');
            //res.setBody
            res.setStatusCode(testStatusCode);
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
    }
    
    private class RestMock implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    private class RestMock1 implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(401);
            return res;
        }
    }
    
    @isTest
    static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        
        System.assertEquals(200, res.getStatusCode());
    }
    
    
    @isTest
    static void testCallout1() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock1());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        
        System.assertEquals(401, res.getStatusCode());
    }
    
    @isTest
    static void eKYCCasesClosureTest1(){
        Set<Id> setIdAcc = new Set<Id>();
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc1.LastName = 'LastName new';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        setIdAcc.add(acc1.id);
        
        List<Case> lstCreateCase=new List<Case>();
        Set<Id> setId = new Set<Id>();
        Case objCase = new Case();
        objCase.Subject = 'Technical failure to start Orchestration Layer';
        objCase.Description = 'A technical issue has occurred at an API level.';
        objCase.Type = 'eKYC';
        // CH01 Added by Amina BENABDELKRIM 20-06-2022 *** to add new field (case model) -->
        objCase.Case_Model__c='ila';
        // CH01 END-->
        objCase.Status = 'In Progress';
        objCase.Priority = 'High';
        objCase.Origin = 'EKYC-UPLOAD';
        objCase.ContactId = acc1.PersonContactId;
        objCase.AccountId = acc1.id;
        lstCreateCase.add(objCase);
        insert lstCreateCase;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"email": "'+objCase.Account.PersonEmail + 
                          '", "phone": "'+objCase.Account.Mobile_Country_Code__pc+objCase.Account.PersonMobilePhone+'"}';

        Test.startTest();
            batchCls_eKYCCasesClosure obj = new batchCls_eKYCCasesClosure();
            DataBase.executeBatch(obj);                    
        Test.stopTest();
    }
    
    @isTest
    static void eKYCCasesClosureTest2() {
        Set<Id> setIdAcc = new Set<Id>();
        List<Case> lstCreateCase=new List<Case>();
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId() ;
        acc1.LastName = 'LastName new';
        acc1.PersonEmail= 'testAcc11@gmail.test';
        acc1.Mobile_Country_Code__pc = '973';
        acc1.PersonMobilePhone = '645383334000';
        insert acc1;
        setIdAcc.add(acc1.id);
        
        Case objCase1 = new Case();
        objCase1.Subject = 'Technical failure to start Orchestration Layer';
        objCase1.Description = 'A technical issue has occurred at an API level.';
        objCase1.Type = 'eKYC';
        // CH01 Added by Amina BENABDELKRIM 20-06-2022 *** to add new field (case model) -->
        objCase1.Case_Model__c='ila';
        // CH01 END-->
        objCase1.Status = 'In Progress';
        objCase1.Priority = 'High';
        objCase1.Origin = 'EKYC-FETCH';
        objCase1.ContactId = acc1.PersonContactId;
        objCase1.AccountId = acc1.id;
        lstCreateCase.add(objCase1);
        
        Case objCase2 = new Case();
        objCase2.Subject = 'Technical failure to start Orchestration Layer';
        objCase2.Description = 'A technical issue has occurred at an API level.';
        objCase2.Type = 'eKYC';
        // CH01 Added by Amina BENABDELKRIM 20-06-2022 *** to add new field (case model) -->
        objCase2.Case_Model__c='ila';
        // CH01 END-->
        objCase2.Status = 'In Progress';
        objCase2.Priority = 'High';
        objCase2.Origin = 'EKYC-SIGNOFF';
        objCase2.ContactId = acc1.PersonContactId;
        objCase2.AccountId = acc1.id;
        lstCreateCase.add(objCase2);        
        insert lstCreateCase;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        final MyCalloutMock mock = new MyCalloutMock();
        // mock.testBody = '{"email": "'+objCase.Account.PersonEmail + 
        //                 '", "phone": "'+objCase.Account.Mobile_Country_Code__pc+objCase.Account.PersonMobilePhone+'"}';

        Test.startTest();
            batchCls_eKYCCasesClosure obj = new batchCls_eKYCCasesClosure();
            DataBase.executeBatch(obj);                    
        Test.stopTest();
    }   
}
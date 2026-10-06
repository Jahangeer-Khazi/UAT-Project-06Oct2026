/**
* @author Jayanth Manickam
* @date Création 28/12/2024
* @date Modification
* @description :ALL the Test Methods used in AppRestrictionCustomerController
* @history Modifications :   
*  
*/

@isTest
public class AppRestrictionCustomerControllerTest {

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
    
     private class MyCalloutFailureMock implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 400;
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
    
     private static ApiConnection con = new ApiConnection();
      @testSetup static void setupMethod() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',region_flag__pc='Bahrain'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Name_and_Risk_Screening_Manual_Override').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',Type ='Name and Risk Screening – Manual Override'), 'TestFactoryDefaults.CaseDefaults',true);//CH01
    }
    
    @isTest
    Public static void UpdateAppRestrictionCustomerStatusTest(){
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutFailureMock());
        List<String>cseId = New List<String>{String.valueOf([SELECT Id FROM case LIMIT 1].Id)};
        AppRestrictionCustomerController.UpdateAppRestrictionCustomerStatus(cseId);
         AppRestrictionCustomerController.UpdateAppRestrictionIDV(cseId,TRUE,'BLACKLISTED');
        Test.StopTest();
    }
     @isTest
    Public static void UpdateAppRestrictionCustomerStatusFailureTest(){
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock());
        List<String>cseId = New List<String>{String.valueOf([SELECT Id FROM case LIMIT 1].Id)};
        AppRestrictionCustomerController.UpdateAppRestrictionCustomerStatus(cseId);
        Test.StopTest();
    }

}
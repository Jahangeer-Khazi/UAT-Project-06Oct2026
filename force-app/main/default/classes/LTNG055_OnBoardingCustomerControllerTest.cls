@isTest
public class LTNG055_OnBoardingCustomerControllerTest {

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

    @testSetup static void setupMethode() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Id onBoardRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('On_Boarding').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = onBoardRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Reason = 'Service'), 'TestFactoryDefaults.CaseDefaults',true);
        CrsOnboarding__c crs = new CrsOnboarding__c(Case__c = caseObj.Id,CRS_Checker_Result__c = 'Approved');
        insert crs;
    }

    
    @isTest
    public static void getCrsRecordIdTest(){   
        Test.startTest();
            Id caseId = [SELECT Id FROM Case LIMIT 1].id; 
            Id crsId = LTNG055_OnBoardingCustomerController.getCrsRecordId(caseId);
            System.assert(crsId != null);
        Test.stopTest();
    }

    @isTest
    public static void crsContinueOnboardingApiTest(){  
        Id caseId = [SELECT Id FROM Case LIMIT 1].id; 
        
        Test.startTest();
        try {
            MyCalloutMock mock = new MyCalloutMock();
            Test.setMock(HttpCalloutMock.class, mock);
            LTNG055_OnBoardingCustomerController.crsContinueOnboardingApiFromFlow(new List<Id>{caseId});
        } catch (Exception exp) {
            //System.assert(true);
        }
        Test.stopTest();
    }  

}
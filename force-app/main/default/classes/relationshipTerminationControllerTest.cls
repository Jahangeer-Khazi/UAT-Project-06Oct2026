@isTest
public class relationshipTerminationControllerTest {
  
    private class MyCalloutMock implements HttpCalloutMock{
        public Integer testStatusCode = 400;
        public string testBody;

        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(testStatusCode);
            if(testBody == NULL){
                res.setBody('Get Callout');
            }else{
                system.debug('not null->'+testBody);
                res.setBody(testBody);
            }
            return res;
        }
    }
    
     private class MyCalloutMock1 implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 200;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            //res.setBody
            res.setStatusCode(testStatusCode);
           // if (null != testBody) {
                res.setBody('{ "meta":{"code":"PROD-10000","message":"The validation has been performed successfully."},"data":{"relationshipTerminationEligible":true,"eligibilityChecksStatus":[{"productCheck":"HASSALA","eligibilityStatus":true,"description":"Has hold on 0 Hassala"},{"productCheck":"KANZ","eligibilityStatus":true,"description":"Has no hold on KANZ"},{"productCheck":"ACCOUNTS_HOLD","eligibilityStatus":true,"description":"Has no hold on accounts"},{"productCheck":"ACCOUNTS_FUNDING","eligibilityStatus":false,"description":"Non-Zero balance on accounts: BH58ABCO12939789101001, BH74ABCO12939789101101"},{"productCheck":"INTERNATIONAL_TRANSFERS","eligibilityStatus":false,"description":"Non-Zero balance on accounts: BH58ABCO12939789101001, BH74ABCO12939789101101"},{"productCheck":"JAMEYA","eligibilityStatus":false,"description":"Non-Zero balance on accounts: BH58ABCO12939789101001, BH74ABCO12939789101101"},{"productCheck":"TERM_DEPOSIT","eligibilityStatus":false,"description":"Non-Zero balance on accounts: BH58ABCO12939789101001, BH74ABCO12939789101101"},{"productCheck":"CREDIT_CARD","eligibilityStatus":false,"description":"Non-Zero balance on accounts: BH58ABCO12939789101001, BH74ABCO12939789101101"}]}}');
            //} 
            return res;
        }
    }


    static Account accObj;
    static{
        accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
    }
    
     @isTest
    public static void getrelationshipTerminationApiTest(){  
    Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Update Customer Profile').getRecordTypeId();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'Relationship Termination';
        cs1.Description = 'Relationship Termination Test for Test Class';
        cs1.Type = 'Relationship Termination';    
        cs1.Origin = 'Phone';
        cs1.AccountId = accObj.Id;  
        insert cs1;       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock()); //Status 400
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        system.debug('STATUS CODE'+res.getStatusCode());
        relationshipTerminationController.republishedData(null,cs1.Id);
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody ='{ "meta":{"code":"PROD-10000","message":"The validation has been performed successfully."},"data":{"relationshipTerminationEligible":true,"eligibilityChecksStatus":[{"productCheck":"HASSALA","eligibilityStatus":true,"description":"Has hold on 0 Hassala"},{"productCheck":"KANZ","eligibilityStatus":true,"description":"Has no hold on KANZ"},{"productCheck":"ACCOUNTS_HOLD","eligibilityStatus":true,"description":"Has no hold on accounts"},{"productCheck":"ACCOUNTS_FUNDING","eligibilityStatus":false,"description":"Non-Zero balance on accounts: BH58ABCO12939789101001, BH74ABCO12939789101101"},{"productCheck":"INTERNATIONAL_TRANSFERS","eligibilityStatus":false,"description":"Non-Zero balance on accounts: BH58ABCO12939789101001, BH74ABCO12939789101101"},{"productCheck":"JAMEYA","eligibilityStatus":false,"description":"Non-Zero balance on accounts: BH58ABCO12939789101001, BH74ABCO12939789101101"},{"productCheck":"TERM_DEPOSIT","eligibilityStatus":false,"description":"Non-Zero balance on accounts: BH58ABCO12939789101001, BH74ABCO12939789101101"},{"productCheck":"CREDIT_CARD","eligibilityStatus":false,"description":"Non-Zero balance on accounts: BH58ABCO12939789101001, BH74ABCO12939789101101"}]}}';
        test.stopTest();
    }
    
    @isTest
    public static void getrelationshipTerminationApiTest1(){  
    Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('New Update Customer Profile').getRecordTypeId();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = 'Relationship Termination';
        cs1.Description = 'Relationship Termination Test for Test Class';
        cs1.Type = 'Relationship Termination';    
        cs1.Origin = 'Phone';
        cs1.AccountId = accObj.Id;  
        insert cs1;       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MyCalloutMock1()); //Status 200
        HttpResponse res = CalloutClass.getInfoFromExternalService();
        system.debug('STATUS CODE'+res.getStatusCode());
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody ='{ "meta":{"code":"PROD-10000","message":"The validation has been performed successfully."},"data":{"relationshipTerminationEligible":true,"eligibilityChecksStatus":[{"productCheck":"HASSALA","eligibilityStatus":true,"description":"Has hold on 0 Hassala"},{"productCheck":"KANZ","eligibilityStatus":true,"description":"Has no hold on KANZ"},{"productCheck":"ACCOUNTS_HOLD","eligibilityStatus":true,"description":"Has no hold on accounts"},{"productCheck":"ACCOUNTS_FUNDING","eligibilityStatus":false,"description":"Non-Zero balance on accounts: BH58ABCO12939789101001, BH74ABCO12939789101101"},{"productCheck":"INTERNATIONAL_TRANSFERS","eligibilityStatus":false,"description":"Non-Zero balance on accounts: BH58ABCO12939789101001, BH74ABCO12939789101101"},{"productCheck":"JAMEYA","eligibilityStatus":false,"description":"Non-Zero balance on accounts: BH58ABCO12939789101001, BH74ABCO12939789101101"},{"productCheck":"TERM_DEPOSIT","eligibilityStatus":false,"description":"Non-Zero balance on accounts: BH58ABCO12939789101001, BH74ABCO12939789101101"},{"productCheck":"CREDIT_CARD","eligibilityStatus":false,"description":"Non-Zero balance on accounts: BH58ABCO12939789101001, BH74ABCO12939789101101"}]}}';
        relationshipTerminationController.republishedData(null,cs1.Id);
        test.stopTest(); 
    }
   
}
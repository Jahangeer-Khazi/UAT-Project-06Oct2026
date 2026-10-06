@isTest
public class CreditCardServiceReqControllerTest {
    @testSetup
    static void setupData() {
        Account acc = new Account();
        acc.FirstName = 'TestIla';
        acc.LastName = 'TestIla';
        //acc.Created_from_Lead__c =true;
        acc.PersonEmail = 'testclass@ilatest123.com';
        //CH03: Start
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        //CH03: END
        insert acc;
    }
    
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
    
    private class RestMock3 implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{ "meta": {"code": "CCRD-1000", "message": "Success"},"data": {"eppList": [{"planNumber": "46001","sequenceNumber": "1","transactionAmount": 1200}]}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void testGetAccRequestCaseRecordType() {
        Test.startTest();
        Id recordTypeId = LTNG043_CreditCardServiceReqController.getAccRequestCaseRecordType();
        Test.stopTest();
    }
    
    @isTest
    static void testLoadEPPList() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        List<String> result = LTNG043_CreditCardServiceReqController.loadEPPList(acc.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testLoadEPPList_Plan() {
        // Arrange
        Account testAccount = [SELECT Id, CIF__pc FROM Account LIMIT 1];
        String testPciNumber = '987654321';

        // Mock callout response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        final MyCalloutMock mock3 = new MyCalloutMock();
        List<String> result = LTNG043_CreditCardServiceReqController.loadEPPList_Plan(testAccount.Id, testPciNumber);
        Test.stopTest();
    }
}
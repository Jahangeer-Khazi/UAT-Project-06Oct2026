/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 21/12/2022
*       Change History: 
*/
@isTest
public class walkinCustomerRegistrationControllerTest {
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
    public static String bodyString(Case objCase){
          String sms = 'sms';
            String walkinCreation = 'WALKIN_CREATION';
            String tokenCounterNumber = '2';
            String num = '9701232456';
            String body = 
               '{"phoneNumber": "'+num + 
                '","type": "'+sms +
                '","subject": "'+null +
                '","templateCode": "'+walkinCreation +
                '","placeholderReplacements": [ '+
                    ' 	{ '+
                    '	  "fieldName":"tokenCounter", '+
                    '	  "fieldText":"'+tokenCounterNumber+'" '+
                    ' 	} '+
                    ' ] '+
                ' }';
        return body;
    }
    @isTest
    static void unitTest1(){
        Test.startTest();
        PageReference pageRef = Page.walkinCustomerRegistrationVFPage;
        Test.setCurrentPage(pageRef);
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.Mobile_Country_Code__pc = '+973';
        acc.PersonMobilePhone = '6754645';
        insert acc;
        
        Case cs1 = new Case();
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Walkin Customers').getRecordTypeId();
        cs1.RecordTypeId = recordTypeId;
        cs1.Type = 'Walkin Customer';
		cs1.SuppliedEmail = 'test2@ilatest.com';
        cs1.SuppliedPhone = '764547487';
        cs1.Sub_Type__c = 'IBAN Related';
        insert cs1;
        pageRef.getParameters().put('id',cs1.id);
        ApexPages.StandardController sc = new ApexPages.standardController(cs1);
        walkinCustomerRegistrationController walkinController = new walkinCustomerRegistrationController();
        walkinCustomerRegistrationController walkinControllerWithParamter = new walkinCustomerRegistrationController(sc);
		walkinControllerWithParamter.saveRequest();
        
        Customer_TokenCounter__c custTknCounter = new Customer_TokenCounter__c();
        custTknCounter.Counter__c = 1 ;
        insert custTknCounter;
        walkinControllerWithParamter.getItems();
        walkinControllerWithParamter.generateToken();
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = bodyString(cs1);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.stopTest();
    }

}
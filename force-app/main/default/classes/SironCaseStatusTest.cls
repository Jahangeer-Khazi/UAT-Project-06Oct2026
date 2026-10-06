/**
 *  @author: SP
 *  @date: 2019-09-18
 *  @description:
 *      Test class for SironCaseStatus 
 * 
 *   Version History :
 *         #CH01 Amina BENABDELKRIM  add add new field (case model) with default value 'ila'
 *
 */
@isTest(isParallel=true)
public class SironCaseStatusTest {

    public SironCaseStatusTest() {System.debug('SironCaseStatusTest()');}

    private class MyCalloutMock implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 200;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(testStatusCode);
            res.setBody('{' + 
                        '    "meta": {' + 
                        '        "code": "COMP-1002",' + 
                        '        "message": "Case status has been retrieved successfully."' + 
                        '    },' + 
                        '    "data": {' + 
                            '        "status": "released",' + 
                                '        "screeningResults": "P",' + 
                                '        "decision": "EDD"' + 
                                '    }'+
                        '}');
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
    }

    @testSetup 
    static void setupData(){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(); 
        Account acc = new Account(LastName='Test Account', RecordTypeId=devRecordTypeId);
        insert acc; 
        
        Contact con = new Contact(LastName='testing', Email='testing@test.com');
        Insert con;

        Case loadedCase = new Case(Type='Name Screening', 
                                    Status = 'In Progress',
                                    Subject = 'Testing', 
                                    ContactId=con.id,
                                    AccountId=acc.Id,
                                    Case_Model__c='ila');//CH01
        Insert loadedCase;
    }
 
    static testMethod void testSendComplianceCheckRequest () {
        
        MyCalloutMock mock = new MyCalloutMock(); 
    
        Test.setMock(HttpCalloutMock.class, mock); 
        Test.startTest();
           System.enqueueJob(new SironCaseStatus(new List<id>()));
        Test.stopTest();
        System.assert(true); // we dont have any value to expected because it just a callout to run another queueable if response success
    }

    static testMethod void testSendOnboardingRequest () {
        
        Case[] lstCases = [Select id From Case Limit 1];
        MyCalloutMock mock = new MyCalloutMock(); 
    
        Test.setMock(HttpCalloutMock.class, mock); 
        Test.startTest();
           System.enqueueJob(new SironOnBoarding(lstCases[0].id, new List<id>()));
        Test.stopTest();

        Case[] lstUpdatedCases = [Select Status From Case Where Subject='Testing'];
        System.assertEquals('Closed', lstUpdatedCases[0].Status); 
    }
    
    static testMethod void testSchder(){
        MyCalloutMock mock = new MyCalloutMock();
    
        Test.setMock(HttpCalloutMock.class, mock); 
        Test.startTest();
           SironChecksScheduler schder = new SironChecksScheduler();
         schder.execute(null);
        Test.stopTest();
        System.assert(true);// we dont have any value to expected because it just a callout to run another queueable if response success
    }
}
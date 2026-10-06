/*      Organization : ABC Bank
 *      Created By: Ranjith Raja
 *      Created Date: 10/09/2024
 *      Change History: 
 *			   #CH01# #Ranjith Raja# #23-10-2024# Added Test Classes and Test Methods for the Class 'DailyHandleCheckerSched'.
 */

@isTest
public class DailyHandleCheckerSchedTest {
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"message": "success"}'; // Your mock JSON response

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void testExecuteMethod() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila', Type = 'Account', Sub_Type__c = 'Segment', cc_Request_Type__c = 'Staff Joiner',cc_Checker_Result__c = 'Approve'), 'TestFactoryDefaults.CaseDefaults',true);
        DailyHandleCheckerSched DailyHandCheckSched = new DailyHandleCheckerSched(); 
		String DHCS ='0 0 0 * * ?'; 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Test.startTest();
		System.schedule('Scheduled Daily to perform action based on checker result', DHCS, DailyHandCheckSched);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateAccountDetails() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila', Type = 'Account', Sub_Type__c = 'Segment', cc_Request_Type__c = 'Staff Joiner',cc_Checker_Result__c = 'Approve'), 'TestFactoryDefaults.CaseDefaults',true);
        
        Test.startTest();
        String finalDate = String.valueOf(Date.today());
		SegmentAPIHandler.updateAccountDetails(acc1.Id, '123', finalDate, 'ranjith.mathiyalagan@bank-abc.com', caseObj.Id,'');
        Test.stopTest();
    }
}
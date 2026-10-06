@isTest
public class Loan_CrossSellingServiceTest {
    // ---------- Mock Class ----------
    private class LoanCrossSellingHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            // Build a fake response depending on endpoint
            if(req.getMethod() == 'GET') {
                res.setBody('{"data":{"cardOptions":[{"productMappingCode":"VISA","cardProductConfigurationId":12345}]}}');
            } else if(req.getMethod() == 'PUT') {
                res.setBody('{"message":"Request updated successfully"}');
            }
            res.setHeader('Content-Type','application/json');
            return res;
        }
    }
     // ---------- Test Setup ----------
    @testSetup
    static void setupData() {
       // Create an Account used by Cases
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
       
        acc.Region_Flag__c = 'Bahrain';
        acc.Region_Flag__pc = 'Bahrain';
        
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        insert acc;
    }
    // ---------- Test 1: CrossSellingServiceFromFlow creates new case ----------
    @isTest
    static void testCrossSellingServiceFromFlowUnitTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Loan Application').getRecordTypeId();
        Case baseCase = new Case(
            RecordTypeId = recordTypeId,
            Subject = 'Loan Case',
            Type = 'New Loan / Finance Application',
            Sub_Type__c = 'New Loan / Finance Application Request',
            AccountId = acc.Id,
            AIR_HaveCreditCard__c = true,
            cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01',
            cc_Requested_Credit_Limit__c = 5000,
            cc_Name_on_the_Card__c = 'Test User');
        
        insert baseCase;
		Test.setMock(HttpCalloutMock.class, new LoanCrossSellingHttpMock());
        // Call method
        List<String> resultIds;
        Test.startTest();
        resultIds = Loan_CrossSellingService.crossSellingServiceFromFlow(new List<Id>{ baseCase.Id });
        Test.stopTest();
}


}
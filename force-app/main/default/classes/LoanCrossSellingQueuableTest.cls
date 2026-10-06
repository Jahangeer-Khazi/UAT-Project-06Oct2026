@isTest
public class LoanCrossSellingQueuableTest {
    // Mock class for HTTP callout
    private class LoanCrossSellingMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"message": "Success"}');
            return res;
        }
    }
     @isTest
    static void testLoanCrossSellingQueueableExpired() {
        // 1. Create test Account (if needed)
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
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Loan Application').getRecordTypeId();

        // 2. Create Test Case
        Case testCase = new Case(
            RecordTypeId = recordTypeId,
            Type = 'New Loan / Finance Application',
            Sub_Type__c = 'New Loan / Finance Application Request',
            AccountId = acc.Id,
            Region_Flag__c = 'Bahrain',
            PrimaryCardProductConfigurationId__c = '10',
            cc_Name_on_the_Card__c = 'Test User',
            cc_Requested_Credit_Limit__c = 5000
        );
        insert testCase;

        // 3. Prepare Set<Id> with Case Id
        Set<Id> caseIds = new Set<Id>{ testCase.Id };

        // 4. Set Mock Callout
        Test.setMock(HttpCalloutMock.class, new LoanCrossSellingMock());

        // 5. Instantiate Queueable
        LoanCrossSellingQueuable job = new LoanCrossSellingQueuable(caseIds, 'EXPIRED');

        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();

       
    }

}
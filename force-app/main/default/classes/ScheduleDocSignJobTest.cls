@isTest
public class ScheduleDocSignJobTest {

    @testSetup
    static void setup() {
        Case testCase = createTestCase();

    }

    private static Case createTestCase() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456', CustomerStatus__c=null, Archived__pc=false), 'TestFactoryDefaults.AccountDefaults', true);    
        Case testCase = (Case)TestDataFactory.createSObject(new Case(
            RecordTypeId = acRecordTypeId,
            ContactId = testAccount.PersonContactId,
            AccountId = testAccount.id,
             Status = 'New',
             Origin = 'Web'

        ), 'TestFactoryDefaults.CaseDefaults', true);

        System.debug('testCase>>' + testCase);
        return testCase;
    }

    @isTest
    static void testScheduleDocSignJobExecution() {

        Case testCase = [SELECT Id FROM Case LIMIT 1];

        Map<String, String> testDetails = new Map<String, String>{
            'envelopeId' => 'test-envelope-123',
            'status' => 'sent'
        };

        Test.startTest();

        ScheduleDocSignJob job = new ScheduleDocSignJob(testCase.Id, testDetails);
        String cronExp = '0 0 0 * * ?'; 
        String jobId = System.schedule('Test DocuSign Job', cronExp, job);

        CronTrigger ct = [SELECT Id, CronJobDetail.Name, State, NextFireTime 
                          FROM CronTrigger 
                          WHERE Id = :jobId];
        System.assertEquals('Test DocuSign Job', ct.CronJobDetail.Name, 'Job name should match');
        System.assertEquals('WAITING', ct.State, 'Job should be in WAITING state');

        Test.stopTest();

        List<CronTrigger> remainingJobs = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(0, remainingJobs.size(), 'Job should be deleted after execution');
    }
 
}
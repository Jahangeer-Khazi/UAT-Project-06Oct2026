/**
 *	@author: Andrey Gavrikov (westbrook)
 *	@date: 2019-03-21 12:56:11
 *	@description:
 *	    Test methods for OnboardingCaseController
 *
 *	Version History :
 *	2019-03-21 - CRM-121 - AG
 *	CRM-121- Identification Approve or Reject
 *
 */
@isTest(isParallel=true)
public class OnboardingCaseControllerTest  {
    private static final String BAHRAIN_REGION = 'Bahrain';
    private static final String JORDAN_REGION = 'Jordan';
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
    @testSetup static void setup() {
 Id FatcaRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('On_Boarding').getRecordTypeId();
       Account  acc1 = new Account(
        FirstName = 'Test',
        LastName = 'Test',
        PersonEmail = 'test@gmail.com'
        );
        insert acc1; 
       Case objCase = new Case(
        RecordTypeId = FatcaRecordId,
        Subject = 'test case',
        Description = 'test',
        Case_Model__c='ila',
        Origin = 'CRM',
        ContactId = acc1.PersonContactId,
        AccountId = acc1.id,
        Type='FATCA'
        );
        insert objCase;      
    }
    final static String CASE_KEY_PREFIX = Schema.SObjectType.Case.getKeyPrefix();
    final static String CASE_ID_1 = CASE_KEY_PREFIX + '000000000001';
    final static String ACCOUNT_KEY_PREFIX = Schema.SObjectType.Account.getKeyPrefix();
    final static String ACCOUNT_ID_1 = ACCOUNT_KEY_PREFIX + '000000000001';



    @isTest
    static void testSendOnboardingContinueRequest () {
        final MyCalloutMock mock = new MyCalloutMock();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);

        final ApiConnection.Response response = OnboardingCaseController.sendOnboardingContinueRequest(CASE_ID_1, 'testCustomerId', 'Identification', '{}', '{}',BAHRAIN_REGION);
        Test.stopTest();
        System.assertEquals(true, response.isSuccess);
    }

    @isTest
    static void testSendComplianceCheckRequest () {
        final MyCalloutMock mock = new MyCalloutMock();
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        final ApiConnection.Response response = OnboardingCaseController.sendComplianceCheckRequest(CASE_ID_1, 'testCustomerId', 'Name Screening', '{}', BAHRAIN_REGION);
         Test.stopTest();
        System.assertEquals(true, response.isSuccess);
    }

    class MyDao extends OnboardingCaseController {
        public Case loadedCase = new Case();
        public SObject updatedRecord;
        protected override Case loadCaseDml(final Id caseId) {
            try {super.loadCaseDml(caseId);} catch (Exception eIgnore){System.debug('The following exception has occurred: ' + eIgnore.getMessage());}
            return loadedCase;
        }
        protected override List<String> updateRecords(final List<SObject> recs) {
            super.updateRecords(recs);
            updatedRecord = recs[0];
            return new List<String>();

        }
    }
    @isTest
    static void testLoadCase () {
        final MyDao DAO = new MyDao();
        OnboardingCaseController.DAO = DAO;
        final ApiConnection.Response response = OnboardingCaseController.loadCase(Case_ID_1);
        System.assertEquals(true, response.isSuccess);
    }

    @isTest
    static void testUpdateCaseStatus () {
        final MyDao DAO = new MyDao();
        OnboardingCaseController.DAO = DAO;
        Case objCase=[Select Id from case LIMIT 1];
        final ApiConnection.Response response = OnboardingCaseController.updateCaseStatus(objCase.Id, 'Approved', null,  null, null,null);
        System.assertEquals(true, response.isSuccess);
        final Case updatedCase = (Case)DAO.updatedRecord;
        System.assertEquals('Approved', updatedCase.status);
    }

    @isTest
    static void testSetNameScreeningResult () {
        final MyDao DAO = new MyDao();
        OnboardingCaseController.DAO = DAO;
        final ApiConnection.Response response = OnboardingCaseController.setNameScreeningResult(Account_ID_1, 'testResult');
        System.assertEquals(true, response.isSuccess);
        final Account updatedAccount = (Account)DAO.updatedRecord;
        System.assertEquals('testResult', updatedAccount.Name_Screening_Result__pc);
    }
}
/**
 *	@author: Andrey Gavrikov (westbrook)
 *	@date: 2019-02-25 16:53:07 
 *	@description:
 *	    Test methods for SystemActionLoggerWithCase
 *	
 *	Version History :   
 *		
 */
@isTest(isParallel=true)
public class SystemActionLoggerWithCaseTest  {
    private class MyDao extends SystemActionLoggerWithCase {
        public Case testCase;
        
        protected override Case loadCase(final Id caseId) {
            try { super.loadCase(caseId); } catch (Exception eIgnore){
                System.debug('The following exception has occurred: ' + eIgnore.getMessage());
            	System.assert(true, 'The following exception has occurred: ' + eIgnore.getMessage());
            }
            return testCase;
        }
    }
    final static String ACCOUNT_KEY_PREFIX = Schema.SObjectType.Account.getKeyPrefix();
    final static String ACCOUNT_ID_1 = ACCOUNT_KEY_PREFIX + '000000000001';
    final static String CASE_KEY_PREFIX = Schema.SObjectType.Case.getKeyPrefix();
    final static String CASE_ID_1 = CASE_KEY_PREFIX + '000000000001';

    
    @isTest
    static void testInitiateLogRequest () {
        final MyDao DAO = new MyDao();
        SystemActionLoggerWithCase.DAO = DAO;
        DAO.testCase = new Case(Id = CASE_ID_1, AccountId = ACCOUNT_ID_1);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://test.com');
        req.setBody('test-body');
        final System_Action__c rec = SystemActionLoggerWithCase.initiateLogRequest(CASE_ID_1, req, 'test-action');
        System.assertEquals('test-body', rec.Request_Body__c, 'Incorrect Request Body');

    }
    @isTest
    static void testInitiateLogRequestFailure () {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://test.com');
        req.setBody('test-body');
        final System_Action__c rec = SystemActionLoggerWithCase.initiateLogRequest(CASE_ID_1, req, 'test-action');
        System.assertNotEquals('test-body', rec.Request_Body__c, 'Expected request body with an error in it');

    }
}
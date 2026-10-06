/**
 *	@author: Andrey Gavrikov (westbrook)
 *	@date: 2019-02-25 16:50:47 
 *	@description:
 *      Action Logger for actions related to Case record
 *	
 *	Version History :   
 *	2019-02-25 - CRM-178 - AG
 *	- initial version was developed for "block a card"
     
 *		
 */
public without sharing virtual class SystemActionLoggerWithCase {
    
    @TestVisible private static SystemActionLoggerWithCase DAO = new SystemActionLoggerWithCase();
    /**
     * @param: caseId - Id of Case involved in the current call out
     * @param: req - usual HttpRequest instance
     * @param: action - type of action being sent to API, e.g. "Close an Account"
     */
    public static System_Action__c initiateLogRequest(final Id caseId, final HttpRequest req, final String action) {
        System.assertNotEquals(null, caseId, 'caseId parameter is required');
        System.assertEquals(Case.sObjectType, caseId.getSobjectType(), 'parameter caseId must contain a valid Case Id');
        
        final System_Action__c actionRec = new System_Action__c();
        // topup  action based on request data
        actionRec.Origin__c = 'CRM';
        actionRec.Target__c = 'Orchestration Layer';
        actionRec.Endpoint__c = req.getEndpoint();
        actionRec.Request_Body__c = req.getBody();

        try {
            final Case caseRec = DAO.loadCase(caseId);
            actionRec.Case__c = caseRec.Id;
            actionRec.Account__c = caseRec.AccountId;
            actionRec.Account_Number__c = caseRec.Account.CIF__pc;
            actionRec.Type__c = caseRec.RecordType.Name;
        } catch (Exception e) {
            actionRec.Request_Body__c  = 'failed to load case by Id: ' + caseId + ' => ' + actionRec.Request_Body__c;
        }
        
        //actionRec.Card_Number__c = cardId;
        actionRec.Action__c = action;
        
        return actionRec;
    }
    
    protected virtual Case loadCase(final Id caseId) {
        return [select Id, AccountId, Account.CIF__pc, RecordType.Name from Case where Id = :caseId limit 1];
    }
}
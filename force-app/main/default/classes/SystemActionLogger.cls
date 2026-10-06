/**
 *	@author: Andrey Gavrikov (westbrook)
 *	@date: 2019-02-20
 *	@description:
 *	   CRM-237 Creation of System Action as part of specific Callouts 
 *
 *	   This class is expected to be used as follows
 *	   1. in request part of the call out, call appropriate initiateLogRequest() method
 *	   System_Action__c action = logger.initiateLogRequest(...);
 *	   2. pass resulting Acton to ApiConnection.makeCallout(req, action);
 *
 *	
 *	Version History :   
 *		
 */
public without sharing virtual class SystemActionLogger {
    @TestVisible private static SystemActionLogger DAO = new SystemActionLogger();

    /**
     * use this method when action is related to HTTP Callout and we have HTTPResponse
     */
    public static void logResponse(final HTTPResponse res, final System_Action__c action) {
        if (null != action) {
            action.Response_Body__c = res.getBody();
            action.HTTP_Response_Code__c = res.getStatusCode();
            logGenericFuture(JSON.serialize(action));
        }
    }
    /**
     * use this method when action is not related to HTTP Callout
     */
    public static void logAction(final System_Action__c action) {
        if (null != action) {
            logGenericFuture(JSON.serialize(action));
        }
    }
    
    @future
    private static void logGenericFuture(final String actionJson) {
        System.debug('agX actionJson=' + actionJson);
        final System_Action__c action = (System_Action__c)JSON.deserializeStrict(actionJson, System_Action__c.class);
        final List<String> errors = DAO.insertRecords(new List<SObject>{action});
        System.debug('agX errors: ' + errors);
        return;
    }

    protected virtual List<String> insertRecords(final List<SObject> recs) {
        final List<String> errors = new List<String>();
        for(Database.SaveResult res : Database.insert(recs, /*all_or_none=*/false)) {
            if (!res.isSuccess()) {
                errors.add(res.getErrors()[0].getMessage());
            }
        }
        return errors;
    }

}
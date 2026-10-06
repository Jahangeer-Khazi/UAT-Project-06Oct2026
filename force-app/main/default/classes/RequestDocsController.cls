/**
 *	Update Case in CRM to ask the customer to visit a branch to provide further information
 *	@author: SP
 *	@date: 04/30/2019
 *	@description:
 *	    controller for aura components RequestDocs
 *
 */
public with sharing class RequestDocsController {

	private static final String EMAIL = 'email';
	private static final String EMAIL_VERIFICATION = 'EMAIL_VERIFICATION';

    @AuraEnabled(cacheable=false)
    public static boolean isValidCase(string caseId) {
        return [select Id from Case where Id = :caseId and Type='Name Screening'].size()>0;
    }
    /**
    * Request data from API and update case stauts
    * authored:	SP
    * date: 	04/30/2019
    * param:	caseId, Id of case that user want to request to api
    * return:	result of response
    */
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response sendRequestDocs(string caseId, String regionName) {
    	List<Case> cases = [select Id, ContactEmail, Type, Contact.Account.CIF__pc from Case where Id = :caseId and Type='Name Screening'];
	    if(!cases.isEmpty()){
	    	try{
	    		//get configuration from custom setting
	    		Request_Docs_Config__c requestSetting = Request_Docs_Config__c.getValues('Request Docs');
	    		if(requestSetting != null){
    				//prepare data for callout
			    	String path = String.isBlank(requestSetting.Path__c) ? '': requestSetting.Path__c;
			    	Map<String, String> mBody = new Map<String, String>();
			    	mBody.put('type', EMAIL);
			    	mBody.put('email', cases.get(0).ContactEmail);
			    	mBody.put('templateCode', EMAIL_VERIFICATION);
			    	ApiConnection con = new ApiConnection();

			    	String customerId = cases.get(0).Contact.Account.CIF__pc == null ? '' : cases.get(0).Contact.Account.CIF__pc;
			        HttpRequest req = con.createRequest('POST', path, customerId, regionName);
			        req.setBody(JSON.serialize(mBody));
			        final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, 'Notify request to visit Service Center');

			        //callout and response
			        final ApiConnection.Response response = con.makeCallout(req, action);
			        if (response.isSuccess && response.responseData != null) {
			        	cases.get(0).Status = Label.Visit_to_Service_Center;
			            update cases;
			        }

			        return response;
	    		}
	    		//in case use didn't add configuration data to custom setting
	    		throw new AuraHandledException(Label.No_Configuration);
	    	}catch(exception e){
	    		//other error
	    		throw new AuraHandledException(e.getMessage());
	    	}
    	}
    	//Case not found
    	throw new AuraHandledException(Label.Invalid_Case);
    }
}
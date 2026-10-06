/**
 * Class to handle request for Jamiyah Account API
 * @createdDate 23-10-2020
 * @author Sopha Pum
 *  				#CH01# #Jahangeer Mohammed #08-05-2024# Added logic for Audit History Enhancements(NBA-9027)
 *
 */
public with sharing class JamiyahAccountController {

    @TestVisible // overwrite instance to provide custom connection in test class
    private static ApiConnection con = new ApiConnection();

    @TestVisible
    private static JamiyahAccountController DAO = new JamiyahAccountController();

    @AuraEnabled
    public static string recordTypeServiceRequest(){
        List<RecordType> lstRecordTyps = [Select Id From RecordType Where SobjectType='Case' and developerName ='Jamiyah'];
        return lstRecordTyps[0].id;
    }

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadJamiyahAccountList(String customerId, String regionName) {
        System.debug('>>>>>>do loadJamiyahAccountList' + customerId);
          //#CH08 : start

        final String path = '/api/v1/jameya/group';
        final HttpRequest req = con.createRequest('GET', path, customerId, regionName);
        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
        if(accs!= null && accs.size()>0){
        System.debug('x-canary added :'+accs.get(0).x_canary__pc);
         if(accs.get(0).x_canary__pc != null){
             req.setHeader('x-canary', accs.get(0).x_canary__pc);
         }
        }
        final ApiConnection.Response response = con.makeCallout(req);
        System.debug('>>>>>>reponse loadJamiyahAccountList:' + JSON.serializePretty(response));
        return response;
    }

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadJamiyahAccountDetails(final String customerId, final String jameyaId, String regionName) {
        final String path = '/api/v1/jameya/group/' + jameyaId;///jameya/group/{jameyaId}
        final HttpRequest req = con.createRequest('GET', path, customerId, regionName);
        req.setHeader('jameyaId', jameyaId);
       List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
        if(accs!= null && accs.size()>0){
        System.debug('x-canary added :'+accs.get(0).x_canary__pc);
         if(accs.get(0).x_canary__pc != null){
             req.setHeader('x-canary', accs.get(0).x_canary__pc);
         }
        }
        final ApiConnection.Response response = con.makeCallout(req);
        System.debug('>>>>>>reponse loadJamiyahAccountDetails:' + JSON.serializePretty(response));
        return response;
    }

    @AuraEnabled
    public static ApiConnection.Response apexStopJamiyah(String customerId,
                                                         Boolean isAdmin,
                                                         Id newCaseId, String regionName){
        System.debug('>>>>>>newCase ' + newCaseId);
        List<RecordType> lstRecordTyps = [Select Id From RecordType Where SobjectType='Case' and developerName ='Jamiyah' LIMIT 1];
        List<Account> lstAcc = [Select Id,PersonContactId from Account Where CIF__pc =: customerId];

        Case nCase = [SELECT Id,Customer_CIF__c,Jamiyah_Id__c,Requested_by_Admin_new__c,Subject,Closure_Reason__c,
                      Origin,Is_Organizer__c,AccountId,Description,ContactId
                      FROM Case WHERE Id =:newCaseId];

        nCase.Subject = 'Stop Jamiyah Account';
        nCase.Description = 'Non admin customer has requested to stop the Jamiyah Account';
        nCase.Type= 'Stop Jamiyah';
        nCase.AccountId = lstAcc[0].Id;
        nCase.ContactId = lstAcc[0].PersonContactId;
        nCase.RecordTypeId = lstRecordTyps[0].id;

        if(nCase.Requested_by_Admin_new__c){
            nCase.Description = 'Customer/Admin has requested to stop the Jamiyah Account';
            return requestStopJamiyah(nCase,  regionName);
        }
        //if it isn't requested by admin, we just create Case, not callout
        else{
            update nCase;
        }

        System.debug('>>>>>>nCase' + nCase);
        ApiConnection.Response responseSuccess = new ApiConnection.Response();
        responseSuccess.isSuccess = true;
        return responseSuccess;
    }

   // @future(callout=true)
    public static ApiConnection.Response requestStopJamiyah(Case nCase, String regionName){

        List<Account> lstAcc = [Select CIF__pc from Account Where id =: nCase.AccountId];
        System.debug('>>>>>new case' + nCase);
        //trigger API will trigger “Update Jameya Group Status API” with status DELETE
        final String path = '/api/v1/jameya/group/' + nCase.Jamiyah_Id__c + '/status';
        //final HttpRequest req = con.createRequest('PATCH', path, lstAcc[0].CIF__pc, regionName);
        final HttpRequest req = con.createRequest('PUT', path, lstAcc[0].CIF__pc, regionName);
        req.setHeader('jameyaId', String.ValueOf(nCase.Jamiyah_Id__c));
        req.setHeader('status', 'DELETE');
       List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:nCase.Customer_CIF__c];
        if(accs!= null && accs.size()>0){
        System.debug('x-canary added :'+accs.get(0).x_canary__pc);
         if(accs.get(0).x_canary__pc != null){
             req.setHeader('x-canary', accs.get(0).x_canary__pc);
         }
        }
        req.setBody('{"status": "DELETE"}');
        System.debug('>>>>>>request requestStopJamiyah:' + JSON.serializePretty(req.getBody()));

        ApiConnection.Response response = con.makeCallout(req);
        System.debug('>>>>>>reponse requestStopJamiyah:' + JSON.serializePretty(response));

        //create case after callout to avoid error
        //You have uncommitted work pending. Please commit or rollback before calling out
        System.debug('>>>>>>nCase:' + nCase);
        if(nCase.id != null){
            update nCase;
        }
        System.debug('>>>>>>nCase2:' + nCase);
        //If callout successed, change the case status to “Closed”
        if(response.isSuccess){
            System.debug('response stop jamiyah >>>>' + JSON.serialize(response));
            nCase.Status = 'Closed';
            update nCase;
        }else{
            List<System_Action__c> sysActionLst = new List<System_Action__c>();
            //sysActionLst = initiateManualOnboarding.createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/jameya/group/' + nCase.Jamiyah_Id__c + '/status?language=en&unit=neo','PATCH',nCase.id,nCase.Customer_CIF__c,nCase.accountId,response.getStatusCode());
        	//insert sysActionLst;
        }

        return response;
    }
    //CH01: Start
     @AuraEnabled
    public static String createAuditRecordForJamiyahDetails(String accCIF, String jameyaId){
        
        System.debug('Account CIF:'+accCIF);
        System.debug('Jamiyah Id:'+jameyaId);
        
        Customer_Pages_Audit_Trail__c cusAudit = new Customer_Pages_Audit_Trail__c();
        cusAudit.Customer_CIF__c = accCIF;
        cusAudit.User_Action__c = 'Viewed';
        cusAudit.User__c = userInfo.getUserId();
        cusAudit.Page_Name__c = 'Jamiyah Detail';
        cusAudit.Jamiyah_ID__c = jameyaId;
        insert cusAudit;
        
        return cusAudit.id;
    }
    //CH01: END

}
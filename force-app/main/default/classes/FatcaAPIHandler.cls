/**
 * author : Aitogram omar
 * @date: 2026-03-14
 * @description: Invocable method to trigger onboarding continue request from Flow.
 *               Sync execution to provide response back to Flow.
 */
public without sharing class FatcaAPIHandler {
    
    @InvocableMethod(label='Send Onboarding Continue Request' description='Sends a POST request to /api/v1/onboarding/continue' callout=true)
    public static List<String> sendRequest(List<Request> requests) {
        System.debug('>>>>>>>>> FatcaAPIHandler.sendRequest - Input Requests: ' + JSON.serialize(requests));
   
        List<Id> caseIds = new List<Id>();
        Map<Id, Boolean> caseWithFatcaMap = new Map<Id, Boolean>();
        
        for (Request req : requests) {
            caseIds.add(req.caseId);
            caseWithFatcaMap.put(req.caseId, req.withFatca);
        }

        if (!caseIds.isEmpty()) {
            executeCalloutFuture(caseIds, caseWithFatcaMap);
        }



           List<String> strLst = new List<String>();
        for(Request qst : requests){
            strLst.add(qst.caseId);
        }
        return strLst;
    }

    private static ApiConnection con = new ApiConnection();

    @future(callout=true)
    public static void executeCalloutFuture(List<Id> caseIds, Map<Id, Boolean> caseWithFatcaMap) {
        for (Id caseId : caseIds) {
            Boolean withFatca = caseWithFatcaMap.containsKey(caseId) ? caseWithFatcaMap.get(caseId) : false;
            executeCallout(caseId, withFatca);
        }
    }

    private static Response executeCallout(Id caseId, Boolean withFatca) {
        Response res = new Response();
        Case caseToUpdate = new Case(Id = caseId);
        Account accountToUpdate;
        try {
            
            Case c = [SELECT Id, Status, Type, AccountId, Account.CIF__pc, Account.PersonEmail, Account.FATCA_Declaration_Form_Type__pc, Region_Flag__c, cc_Maker__c, cc_Checker_Result__c
                      FROM Case WHERE Id = :caseId LIMIT 1];
            
            String customerId = c.Account.CIF__pc;
            String email = c.Account.PersonEmail != null ? c.Account.PersonEmail : '';
            String regionName = c.Region_Flag__c;
            String caseType = c.Type;
            String caseStatus = withFatca ? 'Approved' : 'Rejected';
            String documentType = c.Account.FATCA_Declaration_Form_Type__pc;
            // Construct Request Body
            Map<String, String> bodyMap = new Map<String, String>{
                'caseStatus' => caseStatus,
                'email' => email,
                'caseType' => caseType
            };
            String requestBody = JSON.serialize(bodyMap);

            // System.debug('>>>>>>>>> FatcaAPIHandler.executeCallout - Case Info: Status=' + caseStatus + ', CIF=' + customerId + ', Region=' + regionName);
            // System.debug('>>>>>>>>> FatcaAPIHandler.executeCallout - Request Body: ' + requestBody);

            String actionName =  'FATCA Onboarding';

            // Direct API callout implementation
            final String path = '/api/v1/onboarding/continue?';
            final HttpRequest req = con.createRequest('POST', path, customerId, email, regionName);
            req.setBody(requestBody);

            // System.debug('>>>>>>>>> FatcaAPIHandler.executeCallout - Request Header (userId/email): ' + req.getHeader('userId'));
            
        
            ApiConnection.Response apiResponse = con.makeCallout(req, null);

            // System.debug('>>>>>>>>> FatcaAPIHandler.executeCallout - API Response: ' + JSON.serializePretty(apiResponse) + ' .... '+apiResponse.isSuccess );

            if (apiResponse.isSuccess) {
                if (withFatca == true) {
                    caseToUpdate.Status = 'Approved';
                    if(documentType == 'W-8 BEN'){
                         accountToUpdate = new Account(Id = c.AccountId, FATCA_Customer__pc = false);
                    }
                    else {
                        accountToUpdate = new Account(Id = c.AccountId, FATCA_Customer__pc = true, US_Indicia__pc = false);
                    }
                   
                } else {
                    caseToUpdate.Status = 'Rejected';
                    accountToUpdate = new Account(Id = c.AccountId, FATCA_Customer__pc = false);
                }

                
                insert SM001_ApiCalls.setSystemAction(
                    requestBody,
                    (apiResponse.responseData != null) ? JSON.serialize(apiResponse.responseData) : 'API Success',
                    path,
                    'POST',
                    caseId,
                    customerId,
                    c.AccountId,
                    null,
                    actionName + ' - API Success',
                    'Onboarding'
                );
                
            } else {
                if (withFatca == true) {
                    caseToUpdate.cc_Checker_Result__c = '';
                    //  if(documentType == 'W-8 BEN'){
                    //      accountToUpdate = new Account(Id = c.AccountId, FATCA_Customer__pc = false);
                    // }
                    // else {
                    //     accountToUpdate = new Account(Id = c.AccountId, FATCA_Customer__pc = true, US_Indicia__pc = false);
                    // }
                } else {
                     
                    caseToUpdate.cc_Maker__c = '';
                }
                
                insert SM001_ApiCalls.setSystemAction( 
                    requestBody, 
                    (apiResponse.errorData != null) ? JSON.serialize(apiResponse.errorData) : 'API Failure',
                    path, 
                    'POST',
                    caseId, 
                    customerId, 
                    c.AccountId, 
                    null, 
                    actionName + ' - API Failure', 
                    'Onboarding'
                );
            }

            update caseToUpdate;
            if (accountToUpdate != null) {
                update accountToUpdate;
            }
            
            // Notify UI to refresh
            EventBus.publish(new Refresh_Custom_Components__e());
            
        } catch (Exception e) {
            res.isSuccess = false;
            res.message = e.getMessage() + ' | Stack: ' + e.getStackTraceString();
            System.debug('>>>>>>>>> FatcaAPIHandler exception: ' + res.message);
            
            // Add Logging for Exception
            try {
                Case cQuery = [SELECT AccountId, Account.CIF__pc FROM Case WHERE Id = :caseId LIMIT 1];
                insert SM001_ApiCalls.setSystemAction( 
                    e.getMessage(), 
                    e.getStackTraceString(),
                    null, 
                    null,
                    caseId, 
                    cQuery.Account.CIF__pc, 
                    cQuery.AccountId, 
                    null, 
                    'FATCA Onboarding - Exception: ' + e.getMessage(), 
                    'Onboarding'
                );
            } catch (Exception logEx) {
                System.debug('Failed to log System Action: ' + logEx.getMessage());
            }
        }
        return res;
    }

    public class Request {
        @InvocableVariable(label='Case ID' required=true)
        public Id caseId;
        @InvocableVariable(label='withFatca' required=false)
        public Boolean withFatca;

       
    }

    public class Response {
        @InvocableVariable(label='Is Success')
        public Boolean isSuccess;

        @InvocableVariable(label='Message')
        public String message;

        @InvocableVariable(label='Error Data')
        public String errorData;

        @InvocableVariable(label='Response Data (JSON)')
        public String responseData;
    }
}
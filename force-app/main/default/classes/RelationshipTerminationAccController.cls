/*    Organization : ABC Bank
 *      Created By: Maksud Ali
 *      Created Date: 07-05-2026
 *      Change History: 
 *            Relationship Termination Account Closure Controller (NBA-16921)
*/

public class RelationshipTerminationAccController {

    @AuraEnabled
    public static List<Case> getCaseDetails(String recordId){
        return [Select Id,Unit_Termination__c,Status,Account.CustomerStatus__c 
                FROM Case 
                WHERE Id =: recordId];
    }
    
    @AuraEnabled
    public static ApiConnection.Response relationshipTerminationAccount(String recordId,String unitTermination){
        
        ApiConnection.Response response;
            
        try {
            Case caseDetails = [Select Id,Customer_CIF__c FROM Case WHERE Id =:recordId LIMIT 1];
            ApiConnection con = new ApiConnection();
            final String path = '/api/v1/customer-products/relationship-termination';
            System.debug('recordId ' + recordId);
            System.debug('unitTermination ' + unitTermination);
            System.debug('caseDetails.Customer_CIF__c ' + caseDetails.Customer_CIF__c);
            String customerId = caseDetails.Customer_CIF__c;
            
            List<Account> accs = [SELECT Id,x_canary__pc,Region_Flag__pc FROM Account WHERE CIF__pc =:customerId];
            
            String region = accs.get(0).Region_Flag__pc;
            
            if(unitTermination.equalsIgnoreCase('alburaq')){
               region = region + '_alburaq'; 
            }
            
            
            System.debug('accs ' + accs);
            HttpRequest req = con.createRequest('POST', path, customerId, region);
            
            if(accs.get(0).x_canary__pc != null){
                req.setHeader('x-canary', accs.get(0).x_canary__pc);
            }
            
            
            System.debug('req relation-termination - ' + req);
            System.debug('customer header - ' + req.getHeader('customerId'));
            req.setBody('{"terminationUnit": "' + unitTermination + '","crmCaseId":"'+recordId+'"}');
            
            response = con.makeCallout(req);
            System.debug('rt api response ' + response);
            
            if (response.isSuccess && response.responseData != null) {
            	Map<String, Object> responseData = (Map<String, Object>)response.responseData;
	            System.debug('responseData ' + JSON.serializePretty(responseData));	
                
                String status = (String)responseData.get('status');
                if(status == 'AWATING_HASSALA_COB_CLOSURE'){
                    caseDetails.Status = 'Pending';
                    caseDetails.Sub_Status__c  = 'Pending - Hassala Closure';
                    caseDetails.OwnerId=system.label.ac_TempQueue;
                    update caseDetails;
                }
                if(status == 'SUCCESS'){
                    //Update Account Status to Accounts Closed Successfully
                    //caseDetails.Status = 'Closed';
                    caseDetails.OwnerId=system.label.backOffice_Queue_Id;
                    caseDetails.Sub_Status__c  = 'Accounts Closed Successfully';
                    update caseDetails;
                }	
            }
            
            return response;    
        }
        catch(Exception ex){
            System.debug('ex ' + ex);
            response = new ApiConnection.Response();
            response.isSuccess = false;
            response.errorData = ex.getMessage();
            return response;
        }
    }
}
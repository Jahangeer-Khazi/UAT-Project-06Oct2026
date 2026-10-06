/*     Organization : ABC Bank
*      Created By: Jahangeer Mohammed
*      Created Date: 01-03-2026
*      Description : Handling API'S for Credit Card, Debit Card and Customer Cache
*      Change History: 
*/
public class CreditCardCacheQueuableAPI implements Queueable, Database.AllowsCallouts {
    private static ApiConnection con = new ApiConnection();
    set<Id> cseId;
    public CreditCardCacheQueuableAPI(set<Id> setcseIds){
        this.cseId = setcseIds;
    }
    public void execute(QueueableContext context){
        List<System_Action__c> allSystemActions = new List<System_Action__c>();
        List<Case> lstCase = [Select id, AccountId, Account.x_canary__pc, Region_Flag__c,Account.PersonEmail, Account.CIF__pc from Case Where Id in: cseId];
        for(Case cse : lstCase){
            try{
                Http http = new Http();
                callCreditCardCache(http, cse, allSystemActions);
                callDebitCardCache(http, cse, allSystemActions);
                callCustomerCache(http, cse, allSystemActions);
                
            }catch(Exception ex){
                System.debug('API Exception for Case ' + cse.Id + ' : ' + ex.getMessage());
			}
            
        }//for loop Ends
        if(!allSystemActions.isEmpty()){
            System.debug('System Action Size:'+allSystemActions.size());
            System.debug('System Action List:'+allSystemActions);
            insert allSystemActions;
        }
    }
    
    public static void callCreditCardCache(Http http, Case cse, List<System_Action__c> errorList){
        HttpRequest request = new HttpRequest();
        request = con.createRequest('DELETE', '/api/v1/credit-cards/customer/cache', cse.Region_Flag__c);
        request.setHeader('userId', cse.Account.PersonEmail);
        request.setHeader('customerId', cse.Account.CIF__pc);
        if(cse.Account.x_canary__pc != null){
                request.setHeader('x-canary', cse.Account.x_canary__pc); 
        }
        HttpResponse response = http.send(request);
        validateResponse(request,response, cse, 'Credit Cards Cache API',errorList);
    }
    public static void callDebitCardCache(Http http, Case cse, List<System_Action__c> errorList){
        HttpRequest request = new HttpRequest();
        request = con.createRequest('DELETE', '/api/v1/cards/customer/cache', cse.Region_Flag__c);
        request.setHeader('userId', cse.Account.PersonEmail);
        request.setHeader('customerId', cse.Account.CIF__pc);
        if(cse.Account.x_canary__pc != null){
                request.setHeader('x-canary', cse.Account.x_canary__pc); 
        }
        HttpResponse response = http.send(request);
        validateResponse(request,response, cse, 'Debit Cards Cache API',errorList);
    }
    public static void callCustomerCache(Http http, Case cse, List<System_Action__c> errorList){
        HttpRequest request = new HttpRequest();
        request = con.createRequest('DELETE', '/api/v1/customers/cache', cse.Region_Flag__c);
        request.setHeader('userId', cse.Account.PersonEmail);
        request.setHeader('customerId', cse.Account.CIF__pc);
        if(cse.Account.x_canary__pc != null){
                request.setHeader('x-canary', cse.Account.x_canary__pc); 
        }
        HttpResponse response = http.send(request);
        validateResponse(request,response, cse, 'Cache API',errorList);
    }
    
    public static void validateResponse(HttpRequest request,HttpResponse response, Case cse, String actionType,List<System_Action__c> errorList){
        List<System_Action__c> lstSA = new List<System_Action__c>();
        if(response.getStatusCode() != 200){
			errorList.addAll(createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),cse.Account.CIF__pc,cse.Account.Id,response.getStatusCode(),'DELETE',actionType,cse.Id));
		}else{
        	System.debug('Success Response: ' + response.getBody());
            errorList.addAll(createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),cse.Account.CIF__pc,cse.Account.Id,response.getStatusCode(),'DELETE',actionType,cse.Id));

    	}
        
    }
    public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, final String custId, final Id AccId, final Integer statCode, final String method, final String strAction, final Id cseId) {
        List<System_Action__c> lstSA = new List<System_Action__c>();
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = custId;
        action.Account__c = AccId;
        action.Endpoint__c = path;
        action.Method__c = method;
        action.HTTP_Response_Code__c = statCode;
        action.Origin__c = 'CRM';
        action.Request_Body__c = reqBody;
        action.Response_Body__c = resBody;
        action.Target__c = 'Orchestration Layer';
        action.Action__c = strAction;
        action.Case__c = cseId;
        lstSA.add(action);
        
        return lstSA;
        
    }

}//Queuable End
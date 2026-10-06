/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:20-06-2022
 * 		Change History: 
 *			  
*/
public class CustomerCacheQueuableAPI implements Queueable, Database.AllowsCallouts {
    private static ApiConnection con = new ApiConnection();
    set<Id> accId;
    public CustomerCacheQueuableAPI(set<Id> setAccIdSet){
        this.accId = setAccIdSet;
    }
    public void execute(QueueableContext context){
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Account> lstAcc = [Select id, PersonContactId, CIF__pc, PersonEmail, Mobile_Country_Code__pc, PersonMobilePhone, Mobile_Country_Code_Update__pc, Phone,Region_Flag__c,Region_Flag__pc,x_canary__pc  from Account where id in: accId];
        for(Account acc : lstAcc){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('DELETE', '/api/v1/customers/cache', acc.Region_Flag__pc);
            request.setHeader('userId', acc.PersonEmail);
            request.setHeader('customerId', acc.CIF__pc);
            if(acc.x_canary__pc != null){
               request.setHeader('x-canary', acc.x_canary__pc);
             }
            //request.setTimeout(120000);
          
            HttpResponse response = http.send(request);
            if(response.getStatusCode()!= 200){
                System.debug('Error Response in Customer Cache API:'+response.getBody());
                /*String Endpoint;
                if(acc.Region_Flag__pc == 'Bahrain'){
                    Endpoint = 'callout:NeoBank_Endpoint/api/v1/customers/cache?language=en&unit=neo';
                }
                else if(acc.Region_Flag__pc == 'Jordan'){
                    Endpoint = 'callout:Jordan_Endpoint/api/v1/customers/cache?language=en&unit=jor';
                }*/
                lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),acc.CIF__pc,acc.id,response.getStatusCode(),'DELETE','Cache API');
                
            }
            else{
                System.debug('Success Response in Customer Cache API:'+response.getBody());
            }
            
        }
         if(lstSA.size()>0){
            insert lstSA;
        }
    }
     public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, final String custId, final Id AccId, final Integer statCode, final String method, final String strAction) {
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
        lstSA.add(action);
        
        return lstSA;
        
    }
}
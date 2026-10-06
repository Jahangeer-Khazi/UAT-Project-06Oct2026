/**
 *  @author: Imane Tsioucha
 *  @date: 17-05-2024  
 *  @description:      
 */
public with sharing class MoEngageDeleteCustomer implements Queueable,Database.AllowsCallouts {
    set<Id> accId;
    public MoEngageDeleteCustomer( set<Id> setAccIdSet)   {
        this.accId=setAccIdSet;
        System.debug('accId -->'+this.accId);
    }
    public void execute(QueueableContext context){
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Account> lstAcc = [Select Id,CIF__pc,Region_Flag__pc from Account where id in : accId]; 
     	System.debug('lstAcc -->'+lstAcc);
        for(Account acc : lstAcc){ //for loop start
            System.debug('*************MoEngageDeleteAPI process**************');
            // List<System_Action__c> lstSA = new List<System_Action__c>();
            String regionName=acc.Region_Flag__pc;
            ApiConnection con = new ApiConnection();
            HttpRequest request = con.createRequest('DELETE','/api/v1/moengage/user',regionName); 
            System.debug('my Request==> '+request);
            HttpResponse response = SM001_ApiCalls.MoEngageDeleteAPI(request,acc);
            /*HttpResponse response = new HttpResponse();
            String body = '{ { "meta": { "code": "MOEN-1000", "displayMessage": "Your request has been accepted and will be processed soon."}}';
            response.setStatus('OK');
            response.setStatusCode(200);
            response.setBody(body);
            response.setHeader('Content-Type', 'application/json');*/
            if(response.getStatusCode()==200){
                System.debug('*************MoEngageDeleteAPI response is success**************');
            }
            else{
                System.debug('*************MoEngageDeleteAPI response is failed**************');
                lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),acc.CIF__pc,acc.id,response.getStatusCode(),'DELETE','MoEngageDeleteCustomer');

            }
            if(lstSA!=null && lstSA.size()>0){
                insert lstSA;
            }
          
        }
               
    } // for loop Ends

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
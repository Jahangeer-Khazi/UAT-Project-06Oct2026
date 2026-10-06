/*     Organization   : ABC Bank
 *     Created By     : Jayanth Manickam
 *     Created Date   : 14/02/2022
 *     Description    : This Apex class is used to update customer client status
 *     Change History : 
 *         
 */
public class updateCustomerCoreStatusHandler {
    private static ApiConnection con = new ApiConnection();
    
    public static void handlerBeforeCaseCreation(List<Case> lstCase){
        for(Case cs : lstCase){
            if(cs.Type == 'Update Core Client Status'){
                cs.OwnerId=System.Label.Fraud_Make_Queue;
                cs.Status='In-Progress';
                cs.Sub_Status__c='In-Progress';           
            }
        }
        
    }
    public static void callOutToUpdateCustomerCoreStatus(List<Case>newCases) {
        Set<Id> lstUpdateCaseIds = new Set<Id>();
        List<Case> lstmakerUpdateRouteCase = New List<Case>();
        for (Case newCase : newCases) {
            System.debug('Cases >> ' +newCase);
            if (newCase.Checker_Fraud_Checker_Result__c == 'Update Status' && newCase.Type == 'Update Core Client Status' && newCase.Sub_Status__c=='In-Progress') {
                lstUpdateCaseIds.add(newCase.Id);
                 newCase.Checker_Fraud_Checker_Result_Date_Time__c=System.now();
            }else if(newCase.Checker_Fraud_Checker_Result__c == 'Return to Maker' && newCase.Type == 'Update Core Client Status' && newCase.Sub_Status__c=='In-Progress' && newCase.OwnerId==System.Label.Fraud_Checker_Queue){
               		newCase.OwnerId=System.Label.Fraud_Make_Queue;
                	newCase.Checker_Fraud_Checker_Result_Date_Time__c=System.now();
                	newCase.Maker_Fraud_Maker_Result__c ='';
               // lstmakerUpdateRouteCase.add(newCase);
            }else if(newCase.Maker_Fraud_Maker_Result__c == 'Send to Checker' && newCase.Type == 'Update Core Client Status' && newCase.Sub_Status__c=='In-Progress' && newCase.OwnerId==System.Label.Fraud_Make_Queue){
                newCase.OwnerId=System.Label.Fraud_Checker_Queue;
                newCase.Maker_Fraud_Maker_Result_Date_Time__c=System.now();
                newCase.Checker_Fraud_Checker_Result__c ='';
            }else if((newCase.Maker_Fraud_Maker_Result__c == 'Decline' || newCase.Checker_Fraud_Checker_Result__c=='Decline') && newCase.Sub_Status__c=='In-Progress'){
                newCase.Status='Closed';
            }
        }
        if(lstUpdateCaseIds.size()>0){
        	callOut(lstUpdateCaseIds);            
        }
            
    }
    @future(callout=true)
    public static void callOut(Set<Id> lstUpdateCaseIds) {
        List<System_Action__c> lstSA = new List<System_Action__c>();
        System.debug('CASE LIST:' + lstUpdateCaseIds);
        Set<Id> lstCaseId = New Set<Id>();
        List<Case>lstupdatecase = New List<Case>();
        List<Account>lstupdateAcc = New List<Account>();
        for (Id caseId : lstUpdateCaseIds) {
            /*  Http http = new Http();
              HttpRequest request = new HttpRequest();
              request = con.createRequest('POST', '/api/v1/distribution/customer/' + caseId, 'Bahrain'); //only jordan region require cliq callout

            // con.makeCallout(request, action);
            // /customers/case/{crmCaseId}
       //     system.debug('---> Request --> ' + request.getBody());
              HttpResponse response = http.send(request);
        //    system.debug('---> Responce New --> ' + response.getBody());
             if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, request, 'POST');
                action.HTTP_Response_Code__c = response.getStatusCode();
                insert action;
            } else {*/
                lstCaseId.add(caseId);
            //}
        }
        If(!lstCaseId.isEmpty()){
            for(Case ccase:[Select Id,AccountId,Update_Core_Client_Status__c from Case Where Id IN:lstCaseId]){
                ccase.sub_status__c='Approved';
                ccase.status='Closed';
                lstupdatecase.add(ccase);
                Account acc= New Account();
                acc.Id=ccase.accountId;
                acc.Core_Client_Status__pc=ccase.Update_Core_Client_Status__c;
                lstupdateAcc.add(acc);
            }
        }
        if(!lstupdatecase.isEmpty()){
            update lstupdatecase;
        }
        if(!lstupdateAcc.isEmpty()){
            update lstupdateAcc;
        }
    }
    public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Final Integer statCode, Final String strAction, Final String strType) {
        List<System_Action__c> lstSA = new List<System_Action__c>();
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = custId;
        action.Action__c = strAction;
        //  action.Card_Number__c = objCase.cc_Requested_Card_Type__c;
        action.Case__c = CaseId;
        action.Account__c = AccId;
        action.Endpoint__c = path;
        action.Method__c = method;
        action.HTTP_Response_Code__c = statCode;
        action.Origin__c = 'CRM';
        action.Request_Body__c = reqBody;
        action.Response_Body__c = resBody;
        action.Target__c = 'Orchestration Layer';
        action.Type__c = strType;
        lstSA.add(action);
        return lstSA;
    }
}
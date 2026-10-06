/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date:04-08-2022
*       Change History: 
*						CH01: Added by #Jahangeer Mohammed# #24-09-2023# Enable/Disable Overdue Stages for Periodic Review
*             
*/
public class UnBlockPeriodicReviewProductsQueuableAPI implements Queueable, Database.AllowsCallouts {
    private static ApiConnection con = new ApiConnection();
    set<Id> accId;
    public UnBlockPeriodicReviewProductsQueuableAPI(set<Id> setAccIdSet){
        this.accId = setAccIdSet;
    }
    public void execute(QueueableContext context){
       List<System_Action__c> lstSA = new List<System_Action__c>();
       List<Account> lstAcc = [Select Id,CIF__pc,pr_Block_ATM_Withdrawals__c,pr_Block_Debit_Cards__c,pr_Block_Credit_Cards__c,pr_Block_All_Accounts__c,pr_Block_App_Access__c,
                                        Due_Diligence_Category__pc,pr_NextReviewDate__c,pr_NextReviewReason__c,Region_Flag__pc,PersonEmail from Account where id in : accId]; 
       List<Account> accToUpdate = new List<Account>(); 
        if(lstAcc.size()>0){
            //CH01: Start
            if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('false')){
                for(Account acc : lstAcc){ //for loop start
                    acc.pr_NextReviewReason__c='Periodic Review Scheduled';
                    if(acc.Due_Diligence_Category__pc == 'Standard Due Diligence'){
                        acc.pr_NextReviewDate__c = date.today().addDays(1095);
                        
                    }else if(acc.Due_Diligence_Category__pc == 'Enhanced Due Diligence'){
                        acc.pr_NextReviewDate__c = date.today().addDays(365);
                    }
                    accToUpdate.add(acc);
                }// for loop Ends 
            }
            else if(System.Label.ENABLE_OVERDUE_STAGE.equalsIgnoreCase('true')){
                for(Account acc : lstAcc){ //for loop start
                    ApiConnection con = new ApiConnection();
                    HttpRequest request = con.createRequest('DELETE','/api/v1/customer-products/periodic-review/productBlocks',acc.Region_Flag__pc);
                    HttpResponse response = SM001_ApiCalls.PeriodicReviewUnblockProductsApi(request,acc);
                    
                    if (response.getStatusCode() != 200 ){
                        lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),acc.CIF__pc,response.getStatusCode(),'DELETE','Periodic Review Unblock Products API','Periodic Review');
                        
                    }
                    else{
                        System.debug('Response from API for Unblock Products:'+response.getBody());
                        acc.pr_Block_ATM_Withdrawals__c = false;
                        acc.pr_Block_Debit_Cards__c = false;
                        acc.pr_Block_Credit_Cards__c = false;
                        acc.pr_Block_All_Accounts__c = false;
                        acc.pr_Block_App_Access__c = false;
                        acc.pr_Items_Unblocked__c = true; 
                        acc.pr_NextReviewReason__c='Periodic Review Scheduled';
                       
                        if(acc.Due_Diligence_Category__pc == 'Standard Due Diligence'){
                            acc.pr_NextReviewDate__c =date.today().addDays(1095);
                            
                        }else if(acc.Due_Diligence_Category__pc == 'Enhanced Due Diligence'){
                            acc.pr_NextReviewDate__c =date.today().addDays(365);
                        }
                        accToUpdate.add(acc);
                    }
                    
                } // for loop Ends
            }
            //CH01: END
        }
       if(accToUpdate.size()>0){
            update accToUpdate;
       }
    }
    public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, final String custId, final Integer statCode, final String method, final String strAction, final String strType) {
        List<System_Action__c> lstSA = new List<System_Action__c>();
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = custId;
        //action.Account__c = AccId;
        action.Endpoint__c = path;
        action.Method__c = method;
        action.HTTP_Response_Code__c = statCode;
        action.Origin__c = 'CRM';
        action.Request_Body__c = reqBody;
        action.Response_Body__c = resBody;
        action.Target__c = 'Orchestration Layer';
        action.Action__c = strAction;
        action.Type__c = strType;
        lstSA.add(action);
        return lstSA;
   }
}
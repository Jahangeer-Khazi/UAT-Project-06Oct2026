public class LoanCrossSellingQueuable implements Queueable,Database.AllowsCallouts {
     private static ApiConnection con = new ApiConnection();
     set<Id> cseIds;
     String CROSSELLINGSTATUS;
     public LoanCrossSellingQueuable(set<Id> caseCrossSellingIds, string status){
        this.cseIds = caseCrossSellingIds;
        this.CROSSELLINGSTATUS = status;
    }
    public void execute(QueueableContext qc) {
        List<case> cseList = [Select Id,Type,AccountId,Customer_CIF__c,Region_Flag__c, PrimaryCardProductConfigurationId__c, cc_Name_on_the_Card__c, cc_Requested_Credit_Limit__c from Case Where id in : cseIds];
        List<System_Action__c> lstSA = new List<System_Action__c>();
        for(Case cse : cseList){
            Http http = new Http();
            HttpRequest request = con.createRequest('POST', '/api/v1/credit-cards/cross?',cse.Region_Flag__c);
            HttpResponse response;
            if(CROSSELLINGSTATUS == 'EXPIRED'){
                response = Loan_CrossSellingCcFinalApproval.updateCrossSellingCaseStatusApi(request,cse,CROSSELLINGSTATUS);
            }
            else if(CROSSELLINGSTATUS == 'DECLINED'){
                response = Loan_CrossSellingCcFinalApproval.updateCrossSellingCaseStatusApi(request,cse,CROSSELLINGSTATUS);
            }
            else if(CROSSELLINGSTATUS == 'CANCELLED'){
                response = Loan_CrossSellingCcFinalApproval.updateCrossSellingCaseStatusApi(request,cse,CROSSELLINGSTATUS);
            }
        	
        	if(response != null && response.getStatusCode() != null){
                lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                         request.getEndpoint(),request.getMethod(),
                                                         cse.id,cse.Customer_CIF__c,cse.accountId,response.getStatusCode(), 
                                                         cse.Type+' Request cross selling Status API (called from LoanCrossSellingQueuable class )', cse.Type
                                                        ));
                
            }
        }//for loop ends
        if(lstSA.size()>0){
            insert lstSA;
        }
        
    }

}
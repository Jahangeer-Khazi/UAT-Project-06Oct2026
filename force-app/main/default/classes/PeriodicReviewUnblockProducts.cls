public class PeriodicReviewUnblockProducts {


    @InvocableMethod(label='Periodic Review Unblock Api Calls' description='The purpose of this service is to call the api to either unblock atmWithdrawls,unblock debitCards,unblock creditCards,unblock accounts' )
    public static  List<String>  PeriodicReviewUnblockApiFromFlow(List<Id> accountIds)
    {
        System.debug('PeriodicReviewUnblockApi*****************************');
        //PeriodicReviewUnblockApiFuturMethd(new Set<Id>(accountIds));
       UnBlockPeriodicReviewProductsQueuableAPI unblockAPI = new UnBlockPeriodicReviewProductsQueuableAPI(new Set<Id>(accountIds));
       System.enqueueJob(unblockAPI);
       return null; 
    }

  /*  @future(callout=true)
    public static  void PeriodicReviewUnblockApiFuturMethd(Set<Id> accountIds)
    {
        System.debug('PeriodicReviewUnblockApi*****************************');
        List<Account> accounts = [SELECT Id ,pr_Block_ATM_Withdrawals__c,pr_Block_Debit_Cards__c,pr_Block_Credit_Cards__c,pr_Block_All_Accounts__c,pr_Block_App_Access__c,
                                        Due_Diligence_Category__pc,pr_NextReviewDate__c,pr_NextReviewReason__c,
                                        (SELECT Id FROM Cases WHERE RecordType.DeveloperName = 'Customer_Periodic_Review'AND Status != 'Closed' ) 
                                  FROM Account WHERE Id IN :accountIds];
        List<Case> casesList = new List<Case>();
        List<System_Action__c> lst = new List<System_Action__c>();
        
        for(Account accObj : accounts){
            
            //toDo : use api uncomment this part
            ApiConnection con = new ApiConnection();
            HttpRequest request = con.createRequest('DELETE','/api/v1/customer-products/periodic-review/productBlocks',null);
            HttpResponse response = SM001_ApiCalls.PeriodicReviewUnblockProductsApi(request,accObj);

          HttpResponse response = new HttpResponse();
            // Create Manually json response For Test Class
            String body = '{  	   "meta":{  		  "code":10003,		  "displayMessage":"The validation for {CIF} has been processed successfully."	   }	}';
            response.setStatus('OK');
            response.setStatusCode(200);
            response.setBody(body);
            response.setHeader('Content-Type', 'application/json');

            if (response.getStatusCode() != 200 ) {
                System.debug(' != 200');

               System_Action__c actionRecord = SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                    request.getEndpoint() ,request.getMethod(),
                                                    null,null,accObj.Id,response.getStatusCode(), 
                                                    'Periodic Review Unblock Products API', 'Periodic Review Unblock Products API'
                                                );
                lst.add(actionRecord);
            }
            
            else{
                System.debug(' == 200');
                accObj.pr_Block_ATM_Withdrawals__c = false;
                  System.debug('accObj.pr_Block_ATM_Withdrawals__c=============='+accObj.pr_Block_ATM_Withdrawals__c);
                accObj.pr_Block_Debit_Cards__c = false;
                accObj.pr_Block_Credit_Cards__c = false;
                accObj.pr_Block_All_Accounts__c = false;
                accObj.pr_Block_App_Access__c = false;
                accObj.pr_Items_Unblocked__c = true; 
                accObj.pr_NextReviewReason__c='Periodic Review Due';
                if( accObj.Due_Diligence_Category__pc == 'Standard Due Diligence'){
                    accObj.pr_NextReviewDate__c =date.today().addDays(1095);
                    
                }else if( accObj.Due_Diligence_Category__pc == 'Enhanced Due Diligence'){
                    accObj.pr_NextReviewDate__c =date.today().addDays(365);
                }
                
                if(accObj.Cases != null && accObj.Cases.size()>0){
                    for(Case caseObj : accObj.Cases){
                        caseObj.Status = 'Closed';
                        casesList.add(caseObj);
                    }
                }
                
            }  
        }
         
        if(casesList != null && casesList.size()>0){
            update casesList;
        }
        if(accounts != null && accounts.size()>0){
            update accounts;
        }
        if(lst != null && lst.size()>0){
            insert lst;
        }    
    }

 }*/
}
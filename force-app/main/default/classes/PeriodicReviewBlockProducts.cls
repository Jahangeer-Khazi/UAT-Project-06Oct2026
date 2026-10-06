public  without sharing class PeriodicReviewBlockProducts {
    
    private static String CLASS_NAME = PeriodicReviewBlockProducts.class.getName();
    
    @InvocableMethod(label='Periodic Review Block Api Calls' description='The purpose of this service is to call the api to either block atmWithdrawls,block debitCards,block creditCards,block accounts' callout=true )
    public static  List<Id>  PeriodicReviewBlockApiFromFlow(List<Id> caseIds)
    { 
        
        //call future method  
        System.debug('PeriodicReviewBlockApi0000*****************************');
        System.debug(caseIds);
        PeriodicReviewBlockApi(new Set<Id>(caseIds));
        System.debug(caseIds);
        List<Id> test = new List<Id>(caseIds);
        return test;
    }
    
    @future(callout=true)
    public static void PeriodicReviewBlockApi(Set<Id> caseIds){
        System.debug('PeriodicReviewBlockApi*****************************');
        System.debug(caseIds);
        List<Case> cases = DM002_Case.getListByIds(caseIds);
        List<Account> accList = new List<Account> ();
        List<System_Action__c> lst = new List<System_Action__c>();
        Map<Case,String> mapEmailFlowPerCase = new Map<Case,String>();
        
        for(Case caseObj : cases){
            
            Account accObj = new Account(Id=caseObj.AccountId);
            
            //toDo : use api uncomment this part
            //Create Manually json response For Test Class
            /* 
ApiConnection con = new ApiConnection();
HttpRequest request = con.createRequest('POST','/api/v1/customer-products/periodic-review/productBlocks',null);
HttpResponse response = new HttpResponse();
String body = '{  	   "meta":{  		  "code":10003,		  "displayMessage":"The validation for {CIF} has been processed successfully."	   }	}';
response.setStatus('OK');
response.setStatusCode(200);
response.setBody(body);
response.setHeader('Content-Type', 'application/json'); 
*/
            String regionName=caseObj.Region_Flag__c;
            if(caseObj.Case_Model__c != null && caseObj.Case_Model__c == 'alburaq'){
                regionName += '_alburaq';
            }
            System.debug( 'Region name ===> '+ regionName);
            
            ApiConnection con = new ApiConnection();
            HttpRequest request = con.createRequest('POST','/api/v1/customer-products/periodic-review/productBlocks',regionName); 
            HttpResponse response = SM001_ApiCalls.PeriodicReviewBlockProductsApi(request,accObj,caseObj);
            
            if (response.getStatusCode() != 200 ) {
                System.debug('Status code != 200');
                
                System_Action__c actionRecord = SM001_ApiCalls.setSystemAction((String)request.getBody(),response.getBody(),
                                                                               request.getEndpoint(),request.getMethod(),
                                                                               caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                                               'Periodic Review Block Products API', 'Periodic Review Block Products API'
                                                                              );
                lst.add(actionRecord);
            }
            else{
                System.debug('Status code == 200');
                if(caseObj.Sub_Status__c == 'Overdue Stage 2')
                {
                    System.debug('Sub_Status__c*****************************'+caseObj.Sub_Status__c);
                    
                    mapEmailFlowPerCase.put(caseObj,'PERIODIC_REVIEW_OVERDUE_STAGE_1_1');
                    
                    caseObj.Periodic_review_Notification_Status__c = 'Overdue Stage 2 - Notification 1';
                    
                    accObj.pr_ReviewStatus__c = 'Overdue Stage 2';
                    accObj.pr_Block_ATM_Withdrawals__c = true;
                    accList.add(accObj);
                } 
                else if(caseObj.Sub_Status__c == 'Overdue Stage 3')
                { 
                    System.debug('Sub_Status__c*****************************'+caseObj.Sub_Status__c);
                    mapEmailFlowPerCase.put(caseObj,'PR_OVERDUE_STAGE_3_1');
                    
                    caseObj.Periodic_review_Notification_Status__c = 'Overdue Stage 3 - Notification 1';
                    accObj.pr_ReviewStatus__c = 'Overdue Stage 3';
                    accObj.pr_Block_Debit_Cards__c = true;
                    accList.add(accObj);
                    
                }
                else if(caseObj.Sub_Status__c == 'Overdue Stage 4')
                {
                    System.debug('Sub_Status__c*****************************'+caseObj.Sub_Status__c);
                    mapEmailFlowPerCase.put(caseObj,'PR_OVERDUE_STAGE_4_1');
                    
                    caseObj.Periodic_review_Notification_Status__c = 'Overdue Stage 4 - Notification 1';
                    
                    accObj.pr_ReviewStatus__c = 'Overdue Stage 4';
                    accObj.pr_Block_Credit_Cards__c = true;
                    accObj.pr_Block_All_Accounts__c = true;
                    accList.add(accObj);
                    
                }  
                
            }
            
            if(caseObj.Sub_Status__c == 'Overdue Stage 5'){
                System.debug('Sub_Status__c*****************************'+caseObj.Sub_Status__c);
                mapEmailFlowPerCase.put(caseObj,'PR_OVERDUE_STAGE_5_1');
                
                caseObj.Periodic_review_Notification_Status__c = 'Overdue Stage 5 - Notification 1';
                System.debug('caseObj.Overdue_Stage_Date_Time__c======='+caseObj.Overdue_Stage_Date_Time__c);
                accObj.pr_ReviewStatus__c = 'Overdue Stage 5';
                accObj.pr_Block_App_Access__c = true;
                
                accList.add(accObj);
            }
        }
        System.debug('test1*****************************'); 
        if(cases != null && cases.size()>0){
            update cases;
        }
        System.debug('TEST2*****************************');
        if(accList != null && accList.size()>0){
            update accList;
        }
        System.debug('TEST3*****************************');
        if(lst != null && lst.size()>0){
            insert lst;
        }
        
        //send emails
        for(Case cs : mapEmailFlowPerCase.keySet()){
            sendEmailAlert(cs , mapEmailFlowPerCase.get(cs) );
        }
    }    
    
    public static void sendEmailAlert(Case objCase,String emailAlertName){
        Map<String, Object> Params = new Map<String, Object>();
        Params.put('recordId',objCase.Id);
        Params.put('emailAlertName',emailAlertName);
        Params.put('caseModel',objCase.Case_Model__c);
        Params.put('caseRecordTyeName',objCase.RecordType_DeveloperName__c);
        //create instance of Interview
        System.debug('Params'+Params);
        Flow.Interview.Send_Emails_Alert_Flow stage = new Flow.Interview.Send_Emails_Alert_Flow(Params);
        //Invoke start method
        stage.start(); 
    } 
    
}
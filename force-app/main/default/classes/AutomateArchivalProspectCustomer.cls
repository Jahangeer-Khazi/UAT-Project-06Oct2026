/**
 * Created By: Jayanth Manickam
 * Created Date 01/11/2023
 * Description  : To call Archive API and Automatically Delete the archived Customer
 * Change History:
 *  #CH1# - Fix for PI-3641
 */

public class AutomateArchivalProspectCustomer {
    
    private static ApiConnection con = new ApiConnection();
    @InvocableMethod(label='Delete Prospect' description='The purpose of this service is to delete the prospect and close the case' callout=true )
    public static List<String> ProspectArchiveFromFlow(List<Id> caseIds){
        
        //call future method
        ProspectArchive(new Set<Id>(caseIds));
        
        return caseIds;
    } 
    @future(callout=true)
    public static void ProspectArchive(Set<Id> arcCaseIds){
        List<System_Action__c> lst = new List<System_Action__c>();
        Map<Id,List<Case>> archivalcases=new Map<Id,List<Case>>();
        List<Case> casesToUpdateList=new List<Case>();
        Set<Id>accountIds = New Set<Id>();
        String Regionflag;
        for(Case cs:[SELECT Id,status,Closure_Type__c,RecordType_DeveloperName__c,Region_Flag__c,account.CIF__pc,accountId FROM Case WHERE id in: arcCaseIds]){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            Regionflag=cs.Region_Flag__c;
            request = con.createRequest('POST', '/api/v1/prospects/archive', cs.Region_Flag__c);
           // request =con.createRequest('DELETE', '/api/v1/distribution/customer/archive', cs.Region_Flag__c);
             request.setBody('{"customerId":"'+cs.account.CIF__pc+'","marketCode":"'+Regionflag.toUpperCase()+'"}');
            request.setHeader('customerId', cs.account.CIF__pc);
            request.setTimeout(30000);
            //Regionflag=cs.Region_Flag__c;
            System.debug('request --->'+request);
            HttpResponse response = http.send(request);
            System.debug('###repsonse'+response.getBody()); 
            if(response.getStatusCode()== 200){
                //CH1 - START
                accountIds.add(cs.accountId);
                 //CH1 - END
                cs.Last_Api_Call_Status__c='Success';
                cs.cc_Checker_Result_Date_Time__c=System.Now();
                Map<String,Object> errorCode;
                Map<String,Object>result=(Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                System.debug('0result###'+result);
                errorCode=(Map<String,Object>)result.get('meta');
                System.debug('0code###'+(String)errorcode.get('code'));
                If((String)errorcode.get('code')=='DDST-0052'){
                    lst = createSystemAction((String)request.getBody(),response.getBody(),
                                                                               request.getEndpoint(),request.getMethod(),
                                                                               cs.Id,cs.account.CIF__pc,cs.accountId,response.getStatusCode(), 
                                                                               'Delete Customer API', 'Delete Customer API'
                                                                              );
                }

            }else{
                  
                 lst = createSystemAction((String)request.getBody(),response.getBody(),
                                                                               request.getEndpoint(),request.getMethod(),
                                                                               cs.Id,cs.account.CIF__pc,cs.accountId,response.getStatusCode(), 
                                                                               'Delete Customer API', 'Delete Customer API'
                                                                              );
                cs.Last_Api_Call_Status__c='Failed';
              //  lst.add(actionRecord);

                System.debug('Error :'+response.getBody());
                
            }
            casesToUpdateList.add(cs);
        }
        if(!accountIds.isEmpty()){
             MoEngageDeleteCustomer MoEngageDeleteApi=new  MoEngageDeleteCustomer(accountIds);
             System.enqueueJob(MoEngageDeleteApi);
        }
        
        if(!casesToUpdateList.isEmpty()){
			update casesToUpdateList;
        }
        if(!lst.isEmpty()){
                    insert lst;
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
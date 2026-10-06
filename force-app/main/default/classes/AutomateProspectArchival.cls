/**
 * Created By: Jayanth Manickam
 * Created Date 01/11/2023
 * Description  : To call Archive API and Automatically Delete the archived Customer
 * Change History:
 *  CH-01 : PI-3641 Fix
 */

public class AutomateProspectArchival {
    
    private static ApiConnection con = new ApiConnection();
    @InvocableMethod(label='Delete Prospect' description='The purpose of this service is to delete the prospect and close the case' callout=true )
    public static List<String> ProspectArchiveFromFlow(List<Id> caseIds){
        
        //call future method
        ProspectArchive(new Set<Id>(caseIds));
        
        return caseIds;
    } 
    @future(callout=true)
    public static void ProspectArchive(Set<Id> arcCaseIds){
        // CH01 - START
        List<System_Action__c> lst = new List<System_Action__c>();
        Map<Id,List<Case>> archivalcases=new Map<Id,List<Case>>();
        List<Case> casesToUpdateList=new List<Case>();
        for(Case cs:[SELECT Id,status,Closure_Type__c,RecordType_DeveloperName__c,Region_Flag__c,account.CIF__pc,accountId FROM Case WHERE id in: arcCaseIds]){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('POST', '/api/v1/prospects/archive', cs.Region_Flag__c);
           // request =con.createRequest('DELETE', '/api/v1/distribution/customer/archive', cs.Region_Flag__c);
            request.setHeader('customerId', cs.account.CIF__pc);
            request.setTimeout(40000);
            request.setBody('{"customerId":"'+cs.account.CIF__pc+'","marketCode":"'+cs.Region_Flag__c+'"}');
            HttpResponse response = http.send(request);
            if(response.getStatusCode()== 200){
                cs.Last_Api_Call_Status__c='Success';
                System.debug('Success :'+response.getBody());
                if(!archivalcases.containsKey(cs.accountId)){
                    archivalcases.put(cs.accountId,New List<Case>{cs});
                }else{
                    archivalcases.get(cs.accountId).add(cs);
                }
                //  if( caseToUpdate!=null && caseToUpdate.size()>0 ){
                System.debug('casesToUpdateList==> '+archivalcases);
            }else{
                String errorCode;
                Map<String,Object>result=(Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                errorCode=(String)result.get('code');
                If(errorcode=='DDST-0052'){
                   cs.Last_Api_Call_Status__c='Success';
                   if(!archivalcases.containsKey(cs.accountId)){
                    archivalcases.put(cs.accountId,New List<Case>{cs});
                    }else{
                    archivalcases.get(cs.accountId).add(cs);
                   }
                }
                 System.debug('Response'+result);
                System_Action__c actionRecord = SM001_ApiCalls.setSystemAction((String)request.getBody(),response.getBody(),
                                                                               request.getEndpoint(),request.getMethod(),
                                                                               cs.Id,cs.account.CIF__pc,cs.accountId,response.getStatusCode(), 
                                                                               'Delete Customer API', 'Delete Customer API'
                                                                              );
                lst.add(actionRecord);
                if(lst.size()>=0){
                    insert lst;
                }
                System.debug('Error :'+response.getBody());
                
            }
            //CH1 - End
        }
        if(!archivalcases.isEmpty()){
            for(Case csopen:[Select ID,status,Closure_Type__c,RecordType_DeveloperName__c,Region_Flag__c,account.CIF__pc,accountId FROM Case WHERE accountId in:archivalcases.KeySet() AND Status!='Closed']){
                csopen.status='Closed';
                if(csopen.RecordType_DeveloperName__c=='Manual_Customer_Archival'){
                                csopen.Closure_Type__c='Closed Approved'; 
                  }
                    casesToUpdateList.add(csopen);           
            }
            if(!casesToUpdateList.isEmpty()){
                //update casesToUpdateList;
                Database.SaveResult[] srList=Database.update(casesToUpdateList,true);
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully updated CaseId: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }
        
    }
    
}
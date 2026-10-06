/**
 * Created By: Imane TSIOUCHA
 * Created Date 13/10/2023
 * Description  : To call Archive API and Automatically Delete the archived Customer
 * Change History:
 *  
 */
public with sharing class ProspectArchiveAPI {
    private static ApiConnection con = new ApiConnection();


    @InvocableMethod(label='Delete Prospect' description='The purpose of this service is to delete the prospect and close the case' callout=true )
    public static List<String> ProspectArchiveFromFlow(List<Id> customerIds){

        //call future method
        ProspectArchive(new Set<Id>(customerIds));

        return null;
    } 


    @future(callout=true)
    public static void ProspectArchive(Set<Id> setAccId){
        List<System_Action__c> lst = new List<System_Action__c>();
        List<Case> casesToUpdateList=new List<Case>();
        List<Account> lstAcc = [Select id, CIF__pc,Region_Flag__c  from Account where id in: setAccId];
        List<Case> caseToUpdate=[SELECT Id,status,Closure_Type__c,RecordType_DeveloperName__c FROM Case WHERE AccountId IN: setAccId ];
        for(Account acc : lstAcc){
            Http http = new Http();
           HttpRequest request = new HttpRequest();
           request = con.createRequest('POST', '/api/v1/prospects/archive', acc.Region_Flag__c);
           //request = con.createRequest('DELETE', '/api/v1/distribution/customer/archive', acc.Region_Flag__c);
           request.setHeader('customerId', acc.CIF__pc);
           request.setTimeout(40000);
            request.setBody('{"customerId":"'+acc.CIF__pc+'","marketCode":"'+acc.Region_Flag__c+'"}');
            
            // HttpResponse response = new HttpResponse();
            // String body = '{    "meta": {        "code": " ",        "message": " Response."    },    "data": {   "id": "5376802"}';
            // response.setStatus('OK');    
            // response.setStatusCode(200);
            // response.setBody(body);
            // response.setHeader('Content-Type', 'application/json'); 
             HttpResponse response = http.send(request);

            if(response.getStatusCode()== 200){
                 System.debug('Success :'+response.getBody());
                 System.debug('list of cases ==> '+caseToUpdate);
                if( caseToUpdate!=null && caseToUpdate.size()>0 ){
                    for(Case cs:caseToUpdate){
                           cs.status='Closed'; 
                           cs.Customer_Email_Suppression_on_Closure__c=true;
                            if(cs.RecordType_DeveloperName__c=='Manual_Customer_Archival'){
                                cs.Closure_Type__c='Closed Approved'; 
                            
                            }
                            casesToUpdateList.add(cs);
                }
                    
                }
                System.debug('casesToUpdateList==> '+casesToUpdateList);
                if(casesToUpdateList.size()>0){
                    update casesToUpdateList;
                }
             }
            else {
                System_Action__c actionRecord = SM001_ApiCalls.setSystemAction((String)request.getBody(),response.getBody(),
                                                   request.getEndpoint(),request.getMethod(),
                                                   caseToUpdate[0].Id,acc.CIF__pc,acc.Id,response.getStatusCode(), 
                                                   'Delete Customer API', 'Delete Customer API'
                                               );
                lst.add(actionRecord);
                if(lst.size()>=0){
                    insert lst;
                }
                System.debug('Error :'+response.getBody());
                
            }
            
        }
    }
    
 
}
/**
* @author Anis
* @date Création 27/08/2024
* @date Modification
* @description : LTNG053_DeletePingUserAccTermination
* @history Modifications :   
*  				#CH01# #Maksud Ali #23-08-2026 #Added logic for relationship termination based on subscription model
*/


public without sharing class LTNG053_DeletePingUserAccTermination {

    private static String CLASS_NAME = LTNG053_DeletePingUserAccTermination.class.getName();
    private static List<System_Action__c> lstSA = new List<System_Action__c>();
    private static ApiConnection con = new ApiConnection();

    @InvocableMethod(label='call PingOne Platform API - Delete Ping User on Account Termination' description='call PingOne Platform API - Delete Ping User on Account Termination' callout=true )
    public static List<String> deletePingUserApiFromFlow(List<Id> caseIds)
    {
        deletePingUserApiFuture(new Set<Id>(caseIds));

        return caseIds;
    }
    @future(callout=true)
    public static void deletePingUserApiFuture (Set<Id> caseIds)
    {
        List<Case> cases = new List<Case>();
        List<Case> parentCases = new List<Case>();
        List<Account> customersUpdate = new List<Account>();
        if (caseIds != null && caseIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            
            //CH01 - Added a new field in query Account.Subscription_Model__pc- 
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Parent.Status,Account.X_Canary__pc,Account.Subscription_Model__pc FROM Case WHERE Id IN :caseIds';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }

        for(Case caseObj : cases){
            try {

                String regionName = caseObj.Region_Flag__c;
                if (caseObj.Unit_Termination__c == 'alburaq') {
                    regionName += '_alburaq';
                }
                
                Http http = new Http();
                HttpRequest request = con.createRequest('DELETE', '/api/v1/customers?',regionName);
                
                //request.setHeader('userId', caseObj.Account.PersonEmail);
                request.setHeader('customerId', caseObj.Account.CIF__pc);
                 if(caseObj.Account.X_Canary__pc != null){
                    request.setHeader('x-canary', caseObj.Account.X_Canary__pc);
                  }
                request.setTimeout(60000);
                HttpResponse response;
                if ( test.isRunningTest() ) {
                    //fake response 
                    response = new HttpResponse();
                    String body1 = '{"meta":{"code":"CCRD-1500","message":"Credit card request status has been updated successfully."}}';
                    response.setStatus('OK');    
                    response.setStatusCode(200);
                    response.setBody(body1);
                    response.setHeader('Content-Type', 'application/json');
                }else{
                    response = http.send(request);
                }

                //store response as system action !
                lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                        request.getEndpoint(),request.getMethod(),
                        caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                        'call PingOne Platform API - Delete Ping User on Account Termination', caseObj.Type
                        ));
                
                
                if (response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    caseObj.Last_Api_Call_Status__c = 'Failed';
                    caseObj.Back_Office_Result__c = null;
                }
                else
                {
                    Case parentCs;
                    caseObj.Awaiting_Customer_Feedback__c = false;
                    caseObj.Back_Office_Result_Date_Time__c = System.now();
                    caseObj.Status = 'Closed';
                    caseObj.Sub_Status__c = 'Completed';
                    
                    if(caseObj.ParentId != null){
                        parentCs = new Case(Id = caseObj.ParentId);
                        parentCs.Number_of_Open_Child_Cases__c = 0;
                    }

                    //Child Closed & Completed by Bank
                    if(caseObj.Sub_Type__c == 'Relationship Termination - By Bank' && caseObj.Final_Black_Listed__c == true){
                        //check reason
                        Account acc = new Account(Id=caseObj.AccountId);
                        //CH01 - START
                        if(caseObj.Account.Subscription_Model__pc == 'both' && caseObj.unit_termination__C !='both' ){
                            acc.Subscription_Model__pc = caseObj.unit_termination__C == 'alburaq' ? 'ila' : 'alburaq';
                        }
                        else {
                            acc.Closure_Reason__c = caseObj.Final_Closure_Reason__c;
                        	acc.CustomerStatus__c = 'Closed';
                        }
                        //CH01 END
                        
                        if( caseObj.Closure_Reason__c == 'Death Confirmed' ){
                            acc.Death_Confirmed__c = true;
                            acc.PLA_Eligibility__pc = 'No';
                            acc.PLA_Ineligibility_Reason__pc = 'Deceased';

                            //update parent fields
                            if(parentCs != null){
                                parentCs.Status = 'Closed';
                                parentCs.Sub_Status__c = 'Completed';
                            }
                        }else{
                            acc.Blacklisted__c = true;
                        }
                        customersUpdate.add(acc);
                    }
                    //"Flagged Termination Case Created by Contact Center" OR "Child Closed & Completed by Customer"
                    else if( (caseObj.Created_by_Contact_Center_Flag__c == true && caseObj.Final_Black_Listed__c == false) || 
                             (caseObj.Created_by_Contact_Center_Flag__c == false && caseObj.Sub_Type__c == 'Relationship Termination - By Customer') 
                    ){
                        Account acc = new Account(Id=caseObj.AccountId);
                        
                        //CH01 - START
                        if(caseObj.Account.Subscription_Model__pc == 'both' && caseObj.unit_termination__C !='both'){
                            acc.Subscription_Model__pc = caseObj.unit_termination__C == 'alburaq' ? 'ila' : 'alburaq'; 
                        }
                        else {
                            acc.Closure_Reason__c = caseObj.Final_Closure_Reason__c;
                        	acc.CustomerStatus__c = 'Closed';
                        }
                        //CH01 - END
                        customersUpdate.add(acc);
                    }

                    if(parentCs != null){
                        parentCases.add(parentCs);
                    }
                }
                
                
            } catch (Exception e) {
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                lstSA.add(SM001_ApiCalls.setSystemAction( null,'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),
                                                         null,null,
                                                         caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                         caseObj.Type+' deleteDeviceApi (unhandled error)', caseObj.Type
                                                        ));
                caseObj.Last_Api_Call_Status__c = 'Failed';
                caseObj.Back_Office_Result__c = null;
            }

        }

        if(cases != null && cases.size()>0){
            //update cases;
        }

        if(parentCases != null && parentCases.size()>0){
            update parentCases;
        }

        if(customersUpdate != null && customersUpdate.size()>0){
            update customersUpdate;
        }

        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }
    }

}
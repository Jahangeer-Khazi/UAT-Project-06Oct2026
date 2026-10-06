global with sharing class batchCls_eKYCCasesClosure implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    private static ApiConnection con = new ApiConnection();
    
    //where Id = \'5001l000005W6BFAA0\'
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select id, Type, Sub_Type__c, eKYC_Retry_Counter__c,Origin, Account.PersonEmail, Account.CIF__pc, Region_Flag__c from Case where Type = \'eKYC\' AND eKYC_Retry_Counter__c < '+ Integer.valueOf(system.Label.eKYCCounterLimitSet) +' AND status != \'Closed\'';
        system.debug('---> Query --> '+query);
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<Case> lstCase = (List<Case>)scope;
        List<Case> newLst = new List<Case>();
        for(Case objCase:lstCase)
        {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('POST', '/api/v1/onboarding/continue?', objCase.Region_Flag__c);
            
            if(objCase.Origin == 'EKYC-UPLOAD'){
                String body = '{"caseId": "'+objCase.Id + 
                          '","email": "'+objCase.Account.PersonEmail + 
                          '","caseType": "'+objCase.Type + 
                          '","caseStatus": "ContinueUpload"}';
           
                system.debug('---> BODY --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
            
                system.debug('---> Request --> '+request.getBody());
                HttpResponse response = http.send(request);
            
                if (response.getStatusCode() != 200) 
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                } 
                else 
                {
                    System.debug(response.getBody());
                    if(objCase.eKYC_Retry_Counter__c<Integer.valueOf(system.Label.eKYCCounterLimitSet))
                        objCase.eKYC_Retry_Counter__c = objCase.eKYC_Retry_Counter__c+1;
                    if(objCase.eKYC_Retry_Counter__c == Integer.valueOf(system.Label.eKYC_CCQueueLimit))
                        objCase.OwnerId = System.Label.Contact_Centre_Queue;
                    newLst.add(objCase);
                }
            }
            else if(objCase.Origin == 'EKYC-FETCH'){
                String body = '{"caseId": "'+objCase.Id + 
                          '","email": "'+objCase.Account.PersonEmail + 
                          '","caseType": "'+objCase.Type + 
                          '","caseStatus": "ContinueFetch"}';
           
                system.debug('---> BODY --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
            
                system.debug('---> Request --> '+request.getBody());
                HttpResponse response = http.send(request);
            
                if (response.getStatusCode() != 200) 
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                } 
                else 
                {
                    System.debug(response.getBody());
                    if(objCase.eKYC_Retry_Counter__c<Integer.valueOf(system.Label.eKYCCounterLimitSet))
                        objCase.eKYC_Retry_Counter__c = objCase.eKYC_Retry_Counter__c+1;
                    if(objCase.eKYC_Retry_Counter__c == Integer.valueOf(system.Label.eKYC_CCQueueLimit))
                        objCase.OwnerId = System.Label.Contact_Centre_Queue;
                    newLst.add(objCase);
                }
            }
            else if(objCase.Origin == 'EKYC-SIGNOFF'){
                String body = '{"caseId": "'+objCase.Id + 
                          '","email": "'+objCase.Account.PersonEmail + 
                          '","caseType": "'+objCase.Type + 
                          '","caseStatus": "ContinueSignOff"}';
           
                system.debug('---> BODY --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
            
                system.debug('---> Request --> '+request.getBody());
                HttpResponse response = http.send(request);
            
                if (response.getStatusCode() != 200) 
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                } 
                else 
                {
                    System.debug(response.getBody());
                    if(objCase.eKYC_Retry_Counter__c<Integer.valueOf(system.Label.eKYCCounterLimitSet))
                        objCase.eKYC_Retry_Counter__c = objCase.eKYC_Retry_Counter__c+1;
                    if(objCase.eKYC_Retry_Counter__c == Integer.valueOf(system.Label.eKYC_CCQueueLimit))
                        objCase.OwnerId = System.Label.Contact_Centre_Queue;
                    newLst.add(objCase);
                }
            }
        }
        if(newLst.size()>0){
            update newLst;
        }
    }
    public void finish(Database.BatchableContext BC) {
        /// this is a devOps demo for Code changes
    }
}
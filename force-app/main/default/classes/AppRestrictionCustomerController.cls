/**
* @author Jayanth Manickam
* @date Création 28/12/2024
* @date Modification
* @description :ALL the functions used in AppRestrictionCustomerController
* @history Modifications :   
*  
*/


public class AppRestrictionCustomerController {
    
    
    // Get available balance from the account
    @InvocableMethod(label='update App Restriction Status' description='The purpose of this service is to update ID&v verification status' callout=true )
    public static List<String> UpdateAppRestrictionCustomerStatus(List<String> caseId){
        List<String> Blacklisted= New List<String>(); 
        List<String> Whitelisted= New List<String>();
        List<String> Terminated = New List<String>();  
        if(!caseId.isEmpty()){
            for(Case caseObj: [SELECT Id,account.CIF__pc,Case_Model__c,Region_Flag__c,accountId,Account.x_canary__pc,OwnerId,Fraud_Results__c,cc_Contact_Centre_Result__c,cc_Blacklisted__c,type,sub_type__c,recordtype.Name,Back_office_result__c FROM Case WHERE Id IN:caseId]){
                if(caseObj.recordtype.Name=='Name and Risk Screening – Manual Override' && caseObj.cc_Blacklisted__c==True){
                    Blacklisted.add(caseObj.Id);
                }else if(caseObj.recordtype.Name=='Name and Risk Screening – Manual Override' &&  caseObj.cc_Blacklisted__c==False){
                    Whitelisted.add(caseObj.Id);
                }else if (caseObj.Type=='Relationship Termination' && caseObj.Back_office_result__c=='Termination Completed'){
                    Terminated.add(caseObj.Id);
                }
            }
            if(!Blacklisted.isEmpty()){
                UpdateAppRestriction(Blacklisted,True,'BLACKLISTED');
            }
            if(!Whitelisted.isEmpty()){
                UpdateAppRestriction(Whitelisted,False,'N/A');
            }
            if(!Terminated.isEmpty()){
                UpdateAppRestriction(Terminated,True,'CLOSED');
            }
            
        }
        return null;
    }
    
    //To update IDV status
    @future(callout=true)
    public static void UpdateAppRestriction(List<String> caseId,Boolean Restrict, String Reason) {
     //   Account acc;
     //   Map<String, Object> fieldsToValue = acc.getPopulatedFieldsAsMap();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> casesToUpdateList=new List<Case>();
        List<Case> cases = new List<Case>();
        List<System_Action__c> lst = new List<System_Action__c>();
        Map<String, object> mapReq = new Map<String, object>();
        map<String, String> conInfo = new map<String, String>();
        cases= [SELECT Id,account.CIF__pc,Case_Model__c,Region_Flag__c,accountId,Account.x_canary__pc,Account.Region_Flag__pc,Customer_CIF__c,cc_Contact_Centre_Result__c,cc_Contact_Centre_Date_Time__c,Account.PersonEmail FROM Case WHERE Id IN:caseId];
        for(Case caseObj : cases){
            conInfo.put('email', caseObj.Account.PersonEmail);
            mapReq.put('contactInformation', conInfo);
            mapReq.put('appRestricted', Restrict);
            mapReq.put('appRestrictedReason', Reason);
            String regionName = caseObj.Account.Region_Flag__pc;
            if(caseObj.case_Model__c == 'alburaq'){
                regionName += '_alburaq';
            }
            //toDo : use api uncomment this part
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            ApiConnection con = new ApiConnection();
            request = con.createRequest('PUT','/api/v1/customers?source=crm',caseObj.Account.PersonEmail,regionName);
            System.debug('Request'+request);
           if(caseObj!= null){
                        System.debug('x-canary added :'+caseObj.Account.x_canary__pc);
                        if(caseObj.Account.x_canary__pc != null){
                            request.setHeader('x-canary', caseObj.Account.x_canary__pc);
                        }
                    }
            request.setHeader('customerId', caseObj.Customer_CIF__c);
            request.setTimeout(20000);
            request.setBody(JSON.serialize(mapReq));
            System.debug(request.getBody());         
            HttpResponse response = http.send(request); 
            if (response.getStatusCode() != 200) 
            {
              System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
               System_Action__c actionRecord = SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                                                       request.getEndpoint() ,request.getMethod(),
                                                                                       caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                                                       'App Restriction', 'App Restriction'
                                                                                      );
                        lst.add(actionRecord);
            }else{
                caseObj.status='Closed';
                casesToUpdateList.add(caseObj);
            }
        }
         if(casesToUpdateList != null && casesToUpdateList.size()>0){
                update casesToUpdateList;
                
            }
         if(lst != null && lst.size()>0){
                insert lst;
            }  
    }
    //To update IDV status

    public static void UpdateAppRestrictionIDV(List<String> caseId,Boolean Restrict, String Reason) {
     //   Account acc;
     //   Map<String, Object> fieldsToValue = acc.getPopulatedFieldsAsMap();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> casesToUpdateList=new List<Case>();
        List<Case> cases = new List<Case>();
        List<System_Action__c> lst = new List<System_Action__c>();
        Map<String, object> mapReq = new Map<String, object>();
        map<String, String> conInfo = new map<String, String>();
        cases= [SELECT Id,account.CIF__pc,Case_Model__c,Region_Flag__c,accountId,Account.x_canary__pc,Account.Region_Flag__pc,Customer_CIF__c,cc_Contact_Centre_Result__c,cc_Contact_Centre_Date_Time__c,Account.PersonEmail FROM Case WHERE Id IN:caseId];
        for(Case caseObj : cases){
            conInfo.put('email', caseObj.Account.PersonEmail);
            mapReq.put('contactInformation', conInfo);
            mapReq.put('appRestricted', Restrict);
            mapReq.put('appRestrictedReason', Reason);
            String regionName = caseObj.Account.Region_Flag__pc;
            if(caseObj.case_Model__c == 'alburaq'){
                regionName += '_alburaq';
            }
            //toDo : use api uncomment this part
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            ApiConnection con = new ApiConnection();
            request = con.createRequest('PUT','/api/v1/customers?source=crm',caseObj.Account.PersonEmail,regionName);
            System.debug('Request'+request);
            if(caseObj!= null){
                        System.debug('x-canary added :'+caseObj.Account.x_canary__pc);
                        if(caseObj.Account.x_canary__pc != null){
                            request.setHeader('x-canary', caseObj.Account.x_canary__pc);
                        }
                    }
            request.setHeader('customerId', caseObj.Customer_CIF__c);
            request.setTimeout(120000);
            request.setBody(JSON.serialize(mapReq));
            System.debug(request.getBody());         
            HttpResponse response = http.send(request); 
            if (response.getStatusCode() != 200) 
            {
              System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
               System_Action__c actionRecord = SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                                                       request.getEndpoint() ,request.getMethod(),
                                                                                       caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                                                       'App Restriction', 'App Restriction'
                                                                                      );
                        lst.add(actionRecord);
            }else{
                caseObj.status='Closed';
                casesToUpdateList.add(caseObj);
            }
        }
         if(casesToUpdateList != null && casesToUpdateList.size()>0){
                update casesToUpdateList;
                
            }
         if(lst != null && lst.size()>0){
                insert lst;
            }  
    }

}
/**
*  Changes History :
*                #CH01# #Hamza Chaoui# #04-07-2022# -- implement alburaq unit changes.
                 #CH02 : #Imane Tsioucha# #22-02-2024# add x-canary header
				 #CH03# #Jahangeer Mohammed# 24-11-2025# Added Logic for Queues Re-structuring at Credit Pre-Screener (NBA-15993)
				#CH04# #Jahangeer Mohammed# 29-12-2025# Added Logic for Convert Credit Card Application (NBA-13871)

*/
public class CreditCardCasesExpired {
    @InvocableMethod(label='expireCreditCardCases' description='API Call for Expire Cases' callout=true )
     public static void caseExpire(List<Id> caseIds){
        caseExpireAfter30Days(new Set<Id>(caseIds));
    }
    
    @future(callout=true)
    public static void caseExpireAfter30Days(Set<Id> caseIds){
        ApiConnection con = new ApiConnection();
        String body = '';
        List<Case> lstUpdateCase = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        //#CH01: add Case_Model__c to soql query
        //CH03: Added cc_Customer_Response__c in the SOQL Query
        //CH04: Added Type in the SOQL Query
        for(Case objCase : [SELECT Id,Type,Status,cc_CRM_Stage__c,Sub_Status__c,Account.CIF__pc,Customer_CIF__c,cc_Email_Address__c,Account.PersonEmail,Account.x_canary__pc,Region_Flag__c,accountId,Case_Model__c,cc_Customer_Response__c FROM Case WHERE Id In:caseIds]){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //#CH01: Start
            String regionName = objCase.Region_Flag__c;
            if(objCase.Case_Model__c == 'alburaq'){
                regionName += '_alburaq';
            }
            request = con.createRequest('PUT','/api/v1/credit-cards/request?',regionName);
            //#CH01: End
            body = '{"crmCaseId": "'+objCase.Id +
                '","status":"EXPIRED"}';
            system.debug('---> BODY IN EXPIRE--> '+body);               
            request.setBody(body);
            request.setHeader('userId', objCase.Account.PersonEmail);
            request.setHeader('customerId', objCase.Account.CIF__pc);
            if(objCase.Account.x_canary__pc != null){
                request.setHeader('x-canary', objCase.Account.x_canary__pc); //CH02
            }
            
            system.debug('---> request IN EXPIRE--> '+request.getBody());
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() != 200) 
            {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                //CH04: Start
                if(objCase.Type == 'Credit Card Application'){
                   lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndPoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card');
				}
                else if(objCase.Type == 'Convert Credit Card Nature Application'){
                   lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndPoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application');
 
                }
                //CH04: END
            	System.debug('System Action Size:'+lstSA.size());
                System.debug('System Action Detail:'+lstSA);
            } 
            else 
            {
                System.debug(response.getBody());
                //CH04: Start
                if(objCase.Type == 'Credit Card Application'){
                   lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndPoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card');
				}
                else if(objCase.Type == 'Convert Credit Card Nature Application'){
                   lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndPoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application');
 
                }
                //CH04: END
				objCase.Status = 'Closed';
                objCase.Sub_Status__c = 'Expired';
                objCase.cc_CRM_Stage__c = 'EXPIRED';
                //CH03: Start
                objCase.cc_Customer_Response__c = '';
                //CH03: END
                lstUpdateCase.add(objCase);
                
            }
        }
        if(lstUpdateCase.size()>0)
            update lstUpdateCase;
         if(lstSA.size()>0)
            insert lstSA;
    }
    public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Final Integer statCode, Final String strAction, Final String strType) {
        List<System_Action__c> lstSA = new List<System_Action__c>();
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = custId;
        action.Action__c = strAction;
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
/*     Organization : ABC Bank
*      Created By: Jahangeer Mohammed
*      Created Date: 28-03-2022
*      Description : Handling API'S for Debit Card Project
*      Change History: 
* 			#CH01 : D&A Team add Islamic banking needed changes
* 
*/
global class DebitCardHandlerAPI {
    private static ApiConnection con = new ApiConnection();
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
    @future(callout=true)
    public static void debitCardCaseUpdate(Set<Id> setCaseId){
        List<Case> lstUpdateCase = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> lstCase = [Select id,accountId,status, Sub_Status__c, Type, Sub_Type__c,Customer_Segment__c,Customer_CIF__c, cc_Name_on_the_Card__c, Origin, Account.PersonEmail, Account.CIF__pc,
                              Region_Flag__c,Hold_ID__c,ccol_Hold_Reference_Number__c,ac_Iban__c,RHA_HoldTransactionsReferenceNo__c,cc_Maker__c,cc_Checker_Result__c,Case_Model__c  from Case where id in: setCaseId];
        
        for(Case objCase : lstCase){
            String body = '';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //#CH01 : Start 
            String regionName = objCase.Region_Flag__c; 
            if(objCase.Case_Model__c == 'alburaq'){ 
                regionName += '_alburaq';   
            }   
            request = con.createRequest('POST','/api/v1/transactions/release',regionName);  
            //#CH01 : End
            
            //request = con.createRequest('POST','/api/v1/transactions/release',objCase.Region_Flag__c);
            
            if(objCase.Type == 'Release Hold Amount' && (objCase.Sub_Type__c == 'Release International Transfer' || objCase.Sub_Type__c == 'Release Fawri Transfer') &&
               objCase.cc_Maker__c == 'Release Hold'){
                   body = '{"holdReference": "'+objCase.Hold_ID__c + 
                       '","accountId":"'+objCase.ac_Iban__c +'"}';
                system.debug('---> BODY IN DEBIT CARD HANDLER MAKER --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> Request body in Debit Card Handler Maker--> '+request.getBody());
                HttpResponse response = http.send(request);
                if (response.getStatusCode() != 200) 
                {
                    //objCase.dc_Release_Hold_Completed__c = true;
                    lstUpdateCase.add(objCase);
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/transactions/release','POST',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Release Hold Amount', 'Release International Transfer/Release Fawri Transfer');
                } 
                else 
                {
                    System.debug(response.getBody());
                    objCase.Status = 'Closed';
                    objCase.Sub_Status__c = 'Approved';
                    objCase.cc_Maker_Result_Date_Time__c = System.now();
                    objCase.dc_Release_Hold_Completed__c = true;
                    lstUpdateCase.add(objCase);
                }
            }
            else if(objCase.Type == 'Release Hold Amount' && objCase.Sub_Type__c == 'Release Debit Card Transaction' &&
               objCase.cc_Checker_Result__c == 'Release Hold'){
                   body = '{"holdReference": "'+objCase.Hold_ID__c + 
                       '","accountId":"'+objCase.ac_Iban__c +'"}';
                system.debug('---> BODY IN DEBIT CARD HANDLER CHECKER --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> Request body in Debit Card Handler Checker--> '+request.getBody());
                HttpResponse response = http.send(request);
                if (response.getStatusCode() != 200) 
                {
                    //objCase.dc_Release_Hold_Completed__c = true;
                    lstUpdateCase.add(objCase);
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/transactions/release','POST',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Release Hold Amount', 'Release International Transfer/Release Fawri Transfer');
                } 
                else 
                {
                    System.debug(response.getBody());
                    objCase.Status = 'Closed';
                    objCase.Sub_Status__c = 'Approved';
                    objCase.cc_Checker_Result_Date_Time__c = System.now();
                    objCase.dc_Release_Hold_Completed__c = true;
                    lstUpdateCase.add(objCase);
                }
            }     
            
        }
        if(lstUpdateCase.size() > 0 ){
            update lstUpdateCase;
        }
         if(lstSA.size()>0)
            insert lstSA;
        
    }
    
}
/* Change History: 
 *             #CH01# #Swapna # Reset Recovery Code email - CRM22-27
 *             #CH02# #ASHISH # SMS to be sent on clicking 'Generate Reecovery Code'
 
 */
public class RequestAppUnlockController {
     private static ApiConnection con = new ApiConnection();

    //CH01 - START
    @AuraEnabled
     public static string loadCardDetails(final String csId) {
         List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> updateCase= new List<Case>();
         system.debug(csId);
         Case caseObj = [SELECT Id,Case_Model__c,Status,accountId,account.CIF__pc,Customer_CIF__c,account.PersonEmail,Region_Flag__c,account.Region_Flag__c FROM Case WHERE Id=:csId];
        system.debug(csId);
          //CH14 -Start:
          System.debug('Firstmethod###'+caseObj.account.Region_Flag__c);
            String regionName = caseObj.account.Region_Flag__c;
            if(caseObj.Case_Model__c == 'alburaq'){
                regionName += '_alburaq';
            }
         Http http = new Http();
         system.debug(http);
        HttpRequest request = new HttpRequest();
        request = con.createRequest('POST','/api/v1/customer-products/user/unblock',caseObj.Account.CIF__pc, regionName);
        string responsevalue;
         String body = '{"sendRecoveryCode": "false","email":null,"dialingCode":null,"phoneNumber":null,"nationalId":null,"type":"email","iban":null,'+
                     '"caseId":'+'"'+caseObj.Id+'"'+'}';
           
            system.debug('---> BODY --> '+body);               
            request.setBody(body);
             
        //request.setBody('{"sendRecoveryCode": true}');
        request.setHeader('customerId', caseObj.Account.CIF__pc);
        request.setHeader('regionName', caseObj.Region_Flag__c);
         request.setHeader('userId',caseObj.Account.PersonEmail);
         system.debug('---> Request --> '+request);  
        HttpResponse res = http.send(request);
        System.debug(res);
        if (res.getStatusCode() != 200) 
                {
                    System.debug('The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus());
                     lstSA = createSystemAction(request.getBody(),res.getBody(),'callout:NeoBank_Endpoint/api/v1/product/user/unblock?language=en&unit=neo','GET',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,res.getStatusCode(), 'Reset Recovery codes', 'Recovery Codes');

                }
         else{
             system.debug('res.getBody()==>'+res.getBody());
             if (String.isNotBlank(res.getBody())) {
                 final Response response = new Response();
                 system.debug('JSON.deserializeUntyped(res.getBody())==>'+JSON.deserializeUntyped(res.getBody()));
                 final Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    response.responseData = resMap.containsKey('meta')? resMap.get('meta') : resMap;
                    Map<String, Object> m = (Map<String, Object>)response.responseData;
                Object code=m.get('code');

                 if(code!='PROD-1015')
                 {
                    caseObj.status='Closed';
                 updateCase.add(caseObj);
                 }
             }
         }
         system.debug('updateCase-->'+updateCase);
         
         try{
         if(updateCase.size()>0)
         {
          Database.update(updateCase,false);
         }
             return responsevalue;
         }
         catch (DMLException e) {
            System.debug('Exception :: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
            //responsevalue=Json.deserialize(e.getMessage());
         }
        
    }
    //CH01 - END
    
    //CH02 - START
    @future(callout=true)
    public static void resettingRecoveryCodeSMS(Set<Id> setCaseId)
    {   
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> updateCase = new List<Case>();
        List<Case> lstCase = [SELECT Id,Status,accountId,account.CIF__pc,Customer_CIF__c,account.PersonEmail,Region_Flag__c,account.Region_Flag__c,Case_Model__c FROM Case WHERE Id=:setCaseId];
        for(Case objCase : lstCase)
        {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //CH14 -Start:
             System.debug('Secondmethod###'+objCase.account.Region_Flag__c);
            String regionName = objCase.account.Region_Flag__c;
            if(objCase.Case_Model__c == 'alburaq'){
                regionName += '_alburaq';
            }
            
            request = con.createRequest('POST','/api/v1/customer-products/user/unblock',objCase.Account.CIF__pc, regionName);
            string responsevalue;
            String body = '{"sendRecoveryCode": "true","email":null,"dialingCode":null,"phoneNumber":null,"nationalId":null,"type":"email","iban":null,'+
                     '"caseId":'+'"'+objCase.Id+'"'+'}';
           
            system.debug('---> BODY --> '+body);               
            request.setBody(body);
             
            //request.setBody('{"sendRecoveryCode": true}');
            request.setHeader('customerId', objCase.Account.CIF__pc);
            request.setHeader('regionName', objCase.Region_Flag__c);
            request.setHeader('userId',objCase.Account.PersonEmail);
            system.debug('---> Request --> '+request);  
            
            HttpResponse res = http.send(request);
            System.debug('Response---> '+res);
            if (res.getStatusCode() != 200) 
            {
                System.debug('The status code returned was not expected: ' + res.getStatusCode() + ' ' + res.getStatus());
                 lstSA = createSystemAction(request.getBody(),res.getBody(),'callout:NeoBank_Endpoint/api/v1/product/user/unblock?language=en&unit=neo','POST',objCase.id,objCase.Customer_CIF__c,objCase.accountId,res.getStatusCode(), 'Reset Recovery codes', 'Recovery Codes');
            }
            else{
                    objCase.status='Closed';
                    updateCase.add(objCase);
                }
        }
         system.debug('updateCase-->'+updateCase);
         
        try{
            if(updateCase.size()>0)
            {
                Database.update(updateCase,false);
            }    
            if(lstSA.size()>0)
                insert lstSA;
        }
        catch (DMLException e) {
            System.debug('Exception :: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
         }
    }
    //CH02 - END
    
    public class Response {
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public Object responseData;
        @AuraEnabled
        public Object errorData;
        @AuraEnabled
        public Integer recordLength;
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
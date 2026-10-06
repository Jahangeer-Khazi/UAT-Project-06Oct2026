/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 28-11-2023
*       Change History: 
*                   
*/
public class JordanPeriodicReviewRetreiveID {
    private static ApiConnection con = new ApiConnection();
    @AuraEnabled(cacheable=false)
    public static String retreiveIDExpiryDate(final String caseId) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //HttpResponse response = new HttpResponse();
        HttpResponse response;
        String body = '';
        String res = '';
        Case objCase = [Select id,cc_ID_Number__c,Region_Flag__c,Account.PersonEmail, Account.CIF__pc from Case where id =: caseId];
        
        if(System.Label.JO_PERIODIC_REVIEW_ISACTUAL_RESPONSE.equalsIgnoreCase('true')){
            request = con.createRequest('PUT', '/api/v1/government-data/jo-civil-service/person?',objCase.Region_Flag__c);
            
            body = '{"uidValue": "'+objCase.cc_ID_Number__c +
                '","crmSync": "true","promoteGovernmentDataToCustomerProfile":"false"}';
            
            request.setBody(body); 
            request.setHeader('userId', objCase.Account.PersonEmail);
            request.setHeader('customerId', objCase.Account.CIF__pc);
            request.setTimeout(70000);
            system.debug('---> Jordan Request Sending in Aura Method --> '+request.getBody());
            response = http.send(request);
            res = response.getBody();
            System.debug('Response Body in Aura Method:'+res);
            
        }
        if(System.Label.JO_PERIODIC_REVIEW_ISDUMMY_RESPONSE.equalsIgnoreCase('true')){
            body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"customerCivilDetailResponse":{"jordanianId":"54637635","cexpDt":""}}}';
            response.setStatus('OK');
            response.setStatusCode(200);
            response.setBody(body);
            response.setHeader('Content-Type', 'application/json');
            res = response.getBody();
            System.debug(' Dummy Response Body in Aura Method:'+res); 
        }
       
        return res;
    }
    
    @AuraEnabled(cacheable=false)
    public static String updateIdExpiry(String caseId, String joIDExpiryDate){
        
        String responseMessage;
        
        System.debug('caseId in update Expiry:'+caseId);
        System.debug('Date in update Expiry:'+joIDExpiryDate);
        
        Date retreiveIdExpiryDate = Date.valueOf(joIDExpiryDate);
        
        Case cs = [SELECT Id,Status,Sub_Status__c,ccjo_ID_Expiry_Date__c,Jopr_Awaiting_Customer_Notification__c, Region_Flag__c FROM Case WHERE Id =:caseId];
        
        if(retreiveIdExpiryDate != null){
            
            cs.ccjo_ID_Expiry_Date__c = retreiveIdExpiryDate;
            
        	try{
                update cs;
                responseMessage ='New Id Expiry date has been fetched Successfully from API !!!';
            }
            catch(exception e){
                responseMessage ='Fail: '+e.getMessage();
            } 
        }
        
        return responseMessage;

    }
    
    @AuraEnabled(cacheable=false)
    public static String updateButtonCounter(String caseId){
        
        String responseMessage;
        
        System.debug('caseId in update Expiry:'+caseId);
        Case cs = [SELECT Id,Status,Sub_Status__c,CivilDepart_Api_Retry_Counter__c, Region_Flag__c FROM Case WHERE Id =:caseId];
        
        if(cs.CivilDepart_Api_Retry_Counter__c == 0){
            cs.CivilDepart_Api_Retry_Counter__c++;
        }
        else{
            cs.CivilDepart_Api_Retry_Counter__c++;
        }
        try{
            update cs;
            responseMessage ='Counter Updated Successfully !!!';
        }
        catch(exception e){
            responseMessage ='Fail: '+e.getMessage();
        }
        return responseMessage;

    }
}
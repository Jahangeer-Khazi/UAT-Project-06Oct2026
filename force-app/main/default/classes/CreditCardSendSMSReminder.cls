/**
 * @author D&A team
 * @date Création 10/05/2023
 * @date Modification
 * @description : to hundel send sms Reminder by calling Api for the Credit Card Requirements (credit card application Regular/Staff ; limit increase regular/staff) 
 *                  Used inside "Jordan - Credit Cards Reminders SubFlow"
 * 				#CH01# #Jahangeer Mohammed# Added Product Type for Ila World and Ila World Elite(UATNB-185968)
 */
public without sharing class CreditCardSendSMSReminder {

    private static String CLASS_NAME = CreditCardSendSMSReminder.class.getName();
    private static ApiConnection con = new ApiConnection();
    private static List<System_Action__c> lstSA = new List<System_Action__c>();


    @InvocableMethod(label='Send SMS Reminder via Api (Credit Cards)' description='Send SMS Reminder via Api (Credit Cards)' callout=true )
    public static List<String> cc_SendSMSReminderFromFlow(List<Id> caseIds){

        cc_SendSMSReminderApiFutureMeth( new Set<Id>(caseIds) );
        
        return caseIds;
    } 

    @future(callout=true)
    public static void cc_SendSMSReminderApiFutureMeth(Set<Id> caseIds){
        
        List<Case> cases = new List<Case>();
        if (caseIds != null && caseIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc FROM Case WHERE Id IN :caseIds';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }
        
        for(Case caseObj : cases){
            try {

                String regionName = caseObj.Region_Flag__c;
                if (caseObj.Case_Model__c == 'alburaq') {
                    regionName += '_alburaq';
                }

                HttpRequest request = con.createRequest('POST','/api/v1/notifications?',regionName);
                HttpResponse response = cc_SendSMSReminderApi(request,caseObj);

                if(response.getStatusCode() != 200){
                    System.debug('Invalid /api/v1/notifications? Api call');
                    caseObj.Last_Api_Call_Status__c = 'Failed';
                    lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                    request.getEndpoint(),request.getMethod(),
                                                    caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                    caseObj.Type+' Send Reminder API', caseObj.Type
                                                ));
                }else{
                    System.debug('Send Reminder API Getting Success Status Code from API');
                    lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                    request.getEndpoint(),request.getMethod(),
                                                    caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                    caseObj.Type+' Send Reminder API', caseObj.Type
                                                ));
                    caseObj.Last_Api_Call_Status__c = 'Success';
                }
                
            } catch (Exception e) {
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                lstSA.add(SM001_ApiCalls.setSystemAction( null,'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),
                                                null,null,
                                                caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                caseObj.Type+' cc_SendSMSReminderApiFutureMeth (unhandled error)', caseObj.Type
                                            ));
                caseObj.Last_Api_Call_Status__c = 'Failed';             
            }
        }
        
        if(cases != null && cases.size()>0){
            system.debug('Debug Update Case:');
            update cases;
        }
        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }
    }

    public static HttpResponse cc_SendSMSReminderApi(HttpRequest request,Case objCase){
        PAD.debugLogBegin(CLASS_NAME, 'cc_SendSMSReminderApi','Parameters : [objCase] : '+ objCase);
        String templateCode;
        if(objCase.Type == 'Credit Card Application'){
            if(objCase.cc_SMS_Sent_Flag__c == true){
                templateCode = 'CC_REMIND_DOCS';
            }
            else if(objCase.cc_signature_sms_sent_flag__c == true){
                templateCode = 'CC_PENDING_SIGNATURE';
            }
        }
        else if(objCase.Type == 'Credit Limit Increase Application') {
            if(objCase.cc_SMS_Sent_Flag__c == true){
                templateCode = 'CC_LI_REMIND_DOCS';
            }
            else if(objCase.cc_signature_sms_sent_flag__c == true){
                templateCode = 'CC_LI_PENDING_SIGNATURE';
            }
        }
        
        String productType = '';
        if(objCase.cc_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01'){
           productType = 'ila Switch';  
        }
        if(objCase.cc_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01'){
           productType = 'ila Blue';
        }
        //CH01: Start
        if(objCase.cc_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01'){
            productType = 'ila World'; 
        }
        if(objCase.cc_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
            productType = 'ila World Elite'; 
        }
		//CH01: END
        request.setHeader('customerId', objCase.Customer_CIF__c);
        request.setHeader('userId', objCase.Account.PersonEmail);

        String bodyTxt = 
               '{"phoneNumber": "'+objCase.cc_Mobile_Number__c + 
                '","type": "'+'sms' +
                '","subject": "'+null +
                '","templateCode": "'+templateCode +
                '","placeholderReplacements": [ '+
                    '   { '+
                    '    "fieldName":"creditCardProduct", '+
                    '    "fieldText":"'+productType+'" '+
                    '   } '+
                    ' ] '+
                ' }';        
        
        request.setBody(bodyTxt);

        HttpResponse response;
        if( test.isRunningTest() ){
            //fake response 
            response = new HttpResponse();
            //toDo : .. change body
            String body = '{}';
            response.setStatus('OK');    
            response.setStatusCode(200);
            response.setBody(body);
            response.setHeader('Content-Type', 'application/json'); 
        }
        else{
            response = new Http().send(request);
        }

        PAD.debugLogEnd(CLASS_NAME, 'cc_SendSMSReminderApi', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        return response;
    }

}
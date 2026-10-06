/**
 * 
 * @history Modifications : 
 *          #CH01 : #Hamza Chaoui #04-07-2022# Added alburaq logic.
 * 			#CH02 : #Jahangeer Mohammed #07-07-2026# Added Logic for Ila White, Ila Black and Ila Black Metal Cards (NBA-16947)
 */
public class SendingSMSReminder {
    @InvocableMethod(label='sendSMSReminder' description='API Call for SMS Reminders' callout=true )
    public static void sendSMSReminderCreditCard (List<Id> caseIds){
        sendSMSReminderViaApi(new Set<Id>(caseIds));
    }

    @future(callout=true)
    public static void sendSMSReminderViaApi(Set<Id> caseIds){
        ApiConnection con = new ApiConnection();
        List<Case> caseToUpdate = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
         //CH01 : add Case_Model__c to soql query
        for(Case caseObj : [SELECT Id,Type,Status,cc_Requested_Card_Type__c,Sub_Status__c,Account.CIF__pc,Customer_CIF__c,cc_Email_Address__c,Account.PersonEmail,cc_Mobile_Number__c,cc_signature_sms_sent_flag__c,cc_Email_Sent_Flag__c,Case_Model__c FROM Case WHERE Id In:caseIds]){
            Http http = new Http();
            HttpRequest request1 = new HttpRequest(); 

            //CH01 : Start
            String regionName = 'Bahrain';  
            if(caseObj.Case_Model__c == 'alburaq'){
                regionName += '_alburaq';
            }
            request1 =con.createRequest('POST','/api/v1/notifications?',regionName);
            //CH01 : End
            
            String sms = 'sms';
            String remindDocs = 'CC_REMIND_DOCS';
            String convRemindDocs = 'CC_CONVERT_REMIND_DOCS';
            String productType = '';
            if(caseObj.cc_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01'){
                productType = 'ila Switch';  
            }
            else if(caseObj.cc_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01'){
                productType = 'ila Blue';
            }
            else if(caseObj.cc_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01'){
                //CH02: Start
                //productType = 'ila World';
                productType = 'ila White';
                //CH02: END
            }
            else if(caseObj.cc_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
                //CH02: Start
                //productType = 'ila World Elite';
                productType = 'ila Black';
                //CH02: END
            }
            else if(caseObj.cc_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_02'){
                //CH02: Start
                //productType = 'ila World Elite - Metal';
                productType = 'ila Black Metal';
                //CH02: END
            }
            System.debug('Product Type :'+productType);
            String body = '';
            if(caseObj.Type == 'Credit Card Application'){
                body = 
               '{"phoneNumber": "'+caseObj.cc_Mobile_Number__c + 
                '","type": "'+sms +
                '","subject": "'+null +
                '","templateCode": "'+remindDocs +
                '","placeholderReplacements": [ '+
                    '   { '+
                    '    "fieldName":"creditCardProduct", '+
                    '    "fieldText":"'+productType+'" '+
                    '   } '+
                    ' ] '+
                ' }'; 
            }
            else if(caseObj.Type == 'Convert Credit Card Nature Application'){
                body = 
               '{"phoneNumber": "'+caseObj.cc_Mobile_Number__c + 
                '","type": "'+sms +
                '","subject": "'+null +
                '","templateCode": "'+convRemindDocs +
                '","placeholderReplacements": [ '+
                    '   { '+
                    '    "fieldName":"creditCardProduct", '+
                    '    "fieldText":"'+productType+'" '+
                    '   } '+
                    ' ] '+
                ' }';
                
            }
            system.debug('---> BODY --> '+body);          
            request1.setBody(body);
            request1.setHeader('userId', caseObj.Account.PersonEmail);
            request1.setHeader('customerId', caseObj.Account.CIF__pc);
            System.debug('Get Header User Information:'+request1.getHeader('userId'));
            System.debug('Get Header CIF Information:'+request1.getHeader('customerId'));
            system.debug('---> request1 --> '+request1.getBody());
            HttpResponse response1 = http.send(request1);
            if(response1.getStatusCode() != 200){
                System.debug('Invalid Status Code from API');
                lstSA = createSystemAction(request1.getBody(),response1.getBody(),request1.getEndPoint(),'POST',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 'Credit Card Application', 'SMS Reminder');

            }
            else{
                System.debug('Getting Success Status Code from API:'+response1.getBody());
                lstSA = createSystemAction(request1.getBody(),response1.getBody(),request1.getEndPoint(),'POST',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 'Credit Card Application', 'SMS Reminder');

      		}
        }
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
/**
 * 
 * @history Modifications : 
 *          #CH01 : #Hamza Chaoui #04-07-2022# Added alburaq logic.
 */
public without sharing class SendSmsReminder {

    private static String CLASS_NAME = SendSmsReminder.class.getName();

    @InvocableMethod(label='sendSMSReminder' description='API Call for SMS Reminders' callout=true )
    public static void sendSMSReminderCreditCard (List<Id> caseIds){
        sendSMSReminderViaApi(new Set<Id>(caseIds));
    }

    @future(callout=true)
    public static void sendSMSReminderViaApi(Set<Id> caseIds){
        List<Case> cases = DM002_Case.getListByIds(caseIds);
        ApiConnection con = new ApiConnection();
        List<Case> caseToUpdate = new List<Case>();
        for(Case caseObj : cases){
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
            String body = 
                '{"phoneNumber": "'+caseObj.Account.Mobile_Phone_Check__pc + 
                    '","type": "'+sms +
                    '","subject": "'+null +
                    '","templateCode": "CC_LI_REMIND_DOCS"}';
           
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
            }
            else{
                System.debug('Getting Success Status Code from API');
                if(caseObj.First_Reminder_Sent__c == false){
                    caseObj.First_Reminder_Sent__c = true;
                }else{
                    if(caseObj.Second_Reminder_Sent__c == false){
                        caseObj.Second_Reminder_Sent__c = true;
                    }
                }
                caseToUpdate.add(caseObj);
            }
        }

        if(caseToUpdate.size()>0){
            update caseToUpdate;
        }
    }
}
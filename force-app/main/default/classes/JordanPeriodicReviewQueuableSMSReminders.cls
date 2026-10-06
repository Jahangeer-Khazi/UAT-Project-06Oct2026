/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 07-12-2023
*       Change History: 
*                   
*/
public class JordanPeriodicReviewQueuableSMSReminders /*implements Queueable, Database.AllowsCallouts*/{
    /*private static ApiConnection con = new ApiConnection();
    set<Id> caseId;
    
    public JordanPeriodicReviewQueuableSMSReminders(set<Id> setCaseIdsSet){
        this.caseId = setCaseIdsSet;
    }
    
    //////////////////////////////////////////////////// Start: Logic for First Reminder, Second Reminder, Third Reminder & Customer Block ////////////////////////////////////////////////////////////////////////////////////////////
    
    public void execute(QueueableContext context){
        List<System_Action__c> lstSA = new List<System_Action__c>();
        
        for(Case caseObj : [SELECT Id,Status,Region_Flag__c,Jopr_No_of_Day_bet_ID_Exp_Case_Creation__c,Jopr_No_of_Days_bet_ID_Expiry_First_Rem__c,
                            Sub_Status__c,Account.CIF__pc,Customer_CIF__c,cc_Email_Address__c,Account.PersonEmail,cc_Mobile_Number__c,
                            Case_Model__c,First_Reminder_Sent__c,Second_Reminder_Sent__c,Third_Reminder_Sent__c,Jopr_Jordan_Account_Service_Result__c FROM Case WHERE Id In:caseId]){
            
            Http http = new Http();
            HttpRequest request1 = new HttpRequest(); 
            request1 =con.createRequest('POST','/api/v1/notifications?',caseObj.Region_Flag__c);
            
            String sms = 'sms';
            String tempCodeIDNotExpiredRem1 = 'AUTOMATIC_CASE_REMINDER1_NOT_EXPIRED';
            String tempCodeIDExpiredRem1 = 'AUTOMATIC_CASE_REMINDER1_EXPIRED';
            String tempCodeIDExpiredRem2 = 'AUTOMATIC_CASE_REMINDER2';
            String tempCodeIDExpiredRem3 = 'AUTOMATIC_CASE_REMINDER3';
            String tempCodeBlocked = 'CUSTOMER_BLOCK_SUCCESS';
            String body = '';
                                
            ////////////////////////////////////////////////// Start: First Reminder Sent //////////////////////////////////////////////////////////////////                    
            
            if(caseObj.First_Reminder_Sent__c == true && caseObj.Second_Reminder_Sent__c == false && caseObj.Third_Reminder_Sent__c == false){
                if(caseObj.Jopr_No_of_Days_bet_ID_Expiry_First_Rem__c > 0){
                    Integer noOfDays = Integer.valueOf(caseObj.Jopr_No_of_Days_bet_ID_Expiry_First_Rem__c);
                    body = 
                        '{"phoneNumber": "'+caseObj.cc_Mobile_Number__c + 
                        '","type": "'+sms +
                        '","subject": "'+null +
                        '","templateCode": "'+tempCodeIDNotExpiredRem1 +
                        '","placeholderReplacements": [ '+
                        '   { '+
                        '    "fieldName":"NumberofDays", '+
                        '    "fieldText":"'+noOfDays+'" '+
                        '   } '+
                        ' ] '+
                        ' }';
                }
                else if(caseObj.Jopr_No_of_Days_bet_ID_Expiry_First_Rem__c <= 0){
                    body = 
                        '{"phoneNumber": "'+caseObj.cc_Mobile_Number__c + 
                        '","type": "'+sms +
                        '","subject": "'+null +
                        '","templateCode": "'+tempCodeIDExpiredRem1 +'"}';
                }
            }
                                
            ////////////////////////////////////////////////// END: First Reminder Sent //////////////////////////////////////////////////////////////////                    

            ////////////////////////////////////////////////// Start: Second Reminder Sent //////////////////////////////////////////////////////////////////                    

            else if(caseObj.First_Reminder_Sent__c == true && caseObj.Second_Reminder_Sent__c == true && caseObj.Third_Reminder_Sent__c == false){
                   body = 
                        '{"phoneNumber": "'+caseObj.cc_Mobile_Number__c + 
                        '","type": "'+sms +
                        '","subject": "'+null +
                        '","templateCode": "'+tempCodeIDExpiredRem2 +'"}';                 
            } 
                                
            ////////////////////////////////////////////////// END: Second Reminder Sent //////////////////////////////////////////////////////////////////                    

           ////////////////////////////////////////////////// Start: Third Reminder Sent //////////////////////////////////////////////////////////////////                    

           else if(caseObj.First_Reminder_Sent__c == true && caseObj.Second_Reminder_Sent__c == true && caseObj.Third_Reminder_Sent__c == true){
                  body = 
                        '{"phoneNumber": "'+caseObj.cc_Mobile_Number__c + 
                        '","type": "'+sms +
                        '","subject": "'+null +
                        '","templateCode": "'+tempCodeIDExpiredRem3 +'"}';                    
            }
                                
          ////////////////////////////////////////////////// END: Third Reminder Sent //////////////////////////////////////////////////////////////////                    

          ////////////////////////////////////////////////// Start: Customer Blocked by Jordan Account Service Team //////////////////////////////////////////////////////////////////                    
          else if(caseObj.Jopr_Jordan_Account_Service_Result__c == 'Blocked'){
                 body = 
                        '{"phoneNumber": "'+caseObj.cc_Mobile_Number__c + 
                        '","type": "'+sms +
                        '","subject": "'+null +
                        '","templateCode": "'+tempCodeBlocked +'"}';                    
           }
          ////////////////////////////////////////////////// END: Customer Blocked by Jordan Account Service Team //////////////////////////////////////////////////////////////////                    

            request1.setBody(body);
            request1.setHeader('userId', caseObj.Account.PersonEmail);
            request1.setHeader('customerId', caseObj.Account.CIF__pc);
            System.debug('---> Jordan SMS Request Body --> '+request1.getBody());  
            HttpResponse response1 = http.send(request1);
            if(response1.getStatusCode() != 200){
                System.debug('Invalid Status Code from API');
                lstSA = createSystemAction(request1.getBody(),response1.getBody(),'callout:Jordan_Endpoint/api/v1/notifications?language=en&unit=jor','POST',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 'Jordan SMS API', 'Jordan Periodic Review');
                
            }
            else{
                System.debug('Getting Success Status Code from API:'+response1.getBody());
            }
        }
        if(lstSA.size()>0)
            insert lstSA;
        
    }
    //////////////////////////////////////////////////// END: Logic for First Reminder, Second Reminder, Third Reminder & Customer Block ////////////////////////////////////////////////////////////////////////////////////////////

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

    }*/
}
/**
 * @author Elmustapha ELGARNI
 * @date Création 15/10/2024
 * @date Modification
 * @description : to hundel send notifications by calling Api for the loans Requirements  
 *                  Used inside "Loans Notifications Flow"
 */

public without sharing class Loans_sendNotificationsAPI {

    private static String CLASS_NAME = Loans_sendNotificationsAPI.class.getName();
    private static ApiConnection con = new ApiConnection();
    private static List<System_Action__c> lstSA = new List<System_Action__c>();


    @InvocableMethod(label='Send Reminder via Api (Loans)' description='Send notifications via Api (Loans)' callout=true )
    public static List<String> triggerNotificationFromFlow(List<NotificationWrapper> notificationsList){

        NotificationWrapper LoanNotification = notificationsList.get(0);
        Map<String,String> details = new Map<String,String>();
        details.put('isNew',LoanNotification.isNew);
        details.put('templateCode',LoanNotification.templateCode);
        details.put('notifiCationType',LoanNotification.notifiCationType);

        
        Id jobId = System.enqueueJob(new NotificationQueueable(new Set<Id>{LoanNotification.caseId}, details));
        
        List<String> strLst = new List<String>();
        for(NotificationWrapper qst : notificationsList){
            strLst.add(qst.caseId);
        }
        return strLst;
    } 

    
    public static void Loans_triggerNotificationApi(Set<Id> caseIds,  Map<String,String> details){

        //#CH02 : start add tracking notifications
        List<NotificationsTracking__c> lstSA2 = new List<NotificationsTracking__c>();
        String product = 'Loans';
        DateTime nowDate = System.now();
        String channel = 'Push notif';
        String functionApex ='"Loans Notifications Flow" > Loans_sendNotificationsAPI.Loans_triggerNotificationApi()';
        String notifType='Reminder';
        //#CH02 : End
        
        List<Case> cases = new List<Case>();
        if (caseIds != null && caseIds.size() > 0) {

            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,CaseAnnex__r.cx_ln_Reminder_1_Datetime__c,CaseAnnex__r.cx_ln_Reminder_2_Datetime__c,CaseAnnex__r.cx_ln_Reminder_3_Datetime__c FROM Case WHERE Id IN :caseIds';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }
        
        for(Case caseObj : cases){
            try {

                String regionName = caseObj.Region_Flag__c;
                if (caseObj.Case_Model__c == 'alburaq') {
                    regionName += '_alburaq';
                }

                HttpRequest request = con.createRequest('POST','/api/v1/notifications?',regionName);

                HttpResponse response = Loans_triggerNotificationAPI(request,caseObj, details.get('templateCode'), details.get('notifiCationType'));

                String description;
                if (caseObj.CaseAnnex__r.cx_ln_Reminder_1_Datetime__c != null) {
                    Long diffMs = nowDate.getTime() - caseObj.CaseAnnex__r.cx_ln_Reminder_1_Datetime__c.getTime();
                    if (diffMs >= 0 && diffMs <= 160000) {
                        description = 'Reminder 1 - '+channel+' - Sent -- '+ nowDate + ' GMT';
                    }
                }
                if (caseObj.CaseAnnex__r.cx_ln_Reminder_2_Datetime__c != null && description==null) {
                    Long diffMs = nowDate.getTime() - caseObj.CaseAnnex__r.cx_ln_Reminder_2_Datetime__c.getTime();
                    if (diffMs >= 0 && diffMs <= 160000) {
                        description = 'Reminder 2 - '+channel+' - Sent -- '+ nowDate + ' GMT';
                    }
                }
                if (caseObj.CaseAnnex__r.cx_ln_Reminder_3_Datetime__c != null && description==null) {
                    Long diffMs = nowDate.getTime() - caseObj.CaseAnnex__r.cx_ln_Reminder_3_Datetime__c.getTime();
                    if (diffMs >= 0 && diffMs <= 160000) {
                        description = 'Reminder 3 - '+channel+' - Sent -- '+ nowDate + ' GMT';
                    }
                }
                if(description == null){
                    description = channel+' Sent -- '+ nowDate + ' GMT';
                    notifType = 'Immediate';
                }

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
                    // lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                    //                                 request.getEndpoint(),request.getMethod(),
                    //                                 caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                    //                                 caseObj.Type+' Send Reminder API', caseObj.Type
                    //                             ));
                    caseObj.Last_Api_Call_Status__c = 'Success';
                }
                
                //#CH02 : start add tracking notifications
                lstSA2.add(NotificationTrackingService.setNotifTracking( functionApex,caseObj.Id,channel,description,request.getEndpoint(),null,response.getStatusCode(),request.getMethod(),
                                             notifType,product,request.getBody(),response.getBody(),nowDate,caseObj.Status,caseObj.Sub_Status__c,details.get('templateCode')
                ));
                //#CH02 : End
            } catch (Exception e) {
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                lstSA.add(SM001_ApiCalls.setSystemAction( null,'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),
                                                null,null,caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                caseObj.Type+' Loans_triggerNotificationApiFutureMeth (unhandled error)', caseObj.Type));
                caseObj.Last_Api_Call_Status__c = 'Failed';        

                //#CH02 : start add tracking notifications
                lstSA2.add(NotificationTrackingService.setNotifTracking( functionApex,caseObj.Id,channel,'Exception '+e.getMessage(),null,'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),null,null,
                                             notifType,product,null,null,nowDate,caseObj.Status,caseObj.Sub_Status__c,details.get('templateCode')
                ));
                //#CH02 : End     
            }
        }
        
        if(cases != null && cases.size()>0){
            system.debug('Debug Update Case:');
            update cases;
        }
        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }
        //#CH02 : start add tracking notifications
        if(lstSA2 != null && lstSA2.size()>0){
            insert lstSA2;
        }
        //#CH02 : End

    }

    
    public static HttpResponse Loans_triggerNotificationAPI(HttpRequest request,Case objCase, String templateCode, String notifiCationType){
        PAD.debugLogBegin(CLASS_NAME, 'Loans_triggerNotificationAPI','Parameters : [objCase] : '+ objCase);
        request.setHeader('customerId', objCase.Customer_CIF__c);
        request.setHeader('userId', objCase.Account.PersonEmail);

        List<Map<String, String>> placeholderReplacements = new List<Map<String, String>>();

        if(objCase.Status == 'Closed' && objCase.Sub_Status__c == 'Closed' && notifiCationType == 'sms'){
            placeholderReplacements.add(new Map<String, String>{
                'fieldName' => 'Loan Amount',
                'fieldText' => String.valueOf(345) //objCase.Loans_Requested_Loan_Finance_Amount__c)
            });
            placeholderReplacements.add(new Map<String, String>{
                'fieldName' => 'Last 4 Digits',
                'fieldText' => '7654'
            });
        }

        // if(objCase.Status == 'Pending' && objCase.Sub_Status__c == 'Pending'){
           
        //     templateCode = 'PL_REQUEST_UPLOADDOCS';
        // }
        // else if(objCase.Status == 'Pending Documents' && objCase.Sub_Status__c == 'Discrepancies Re-Upload') {

        //     templateCode = 'PL_DISCREPANCIES_DOCS';
        // }
        // else if(objCase.Status == 'Pending Documents' && objCase.Sub_Status__c == 'Discrepancy in documents') {
            
        //     templateCode = 'PL_DISCREPANCIES_DOCS';
        // }
        

        String bodyTxt = 
               '{' +
                    '"email": null,'+
                    '"phoneNumber": null,'+
                    '"nationalId": null,'+
                    '"type": "'+ notifiCationType +'",'+
                    '"templateCode": "'+ templateCode +'",'+
                    '"subject": null,'+
                    '"placeholderReplacements": '+JSON.serialize(placeholderReplacements) +
                    '}';  
        system.debug('Request Body :'+bodyTxt);      
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
        System.debug('Response: '+response);
        PAD.debugLogEnd(CLASS_NAME, 'Loans_triggerNotificationAPI', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        return response;
    }

    public class NotificationQueueable implements Queueable, Database.AllowsCallouts {
        private Set<Id> caseIds;
        private Map<String,String> details;
        
        // Constructor to accept parameters
        public NotificationQueueable(Set<Id> caseIds, Map<String,String> details) {
            this.caseIds = caseIds;
            this.details = details;
        }
        
        public void execute(QueueableContext context) {
            // Call your original method
            Loans_triggerNotificationApi(caseIds, details);
        }
    }

    public class NotificationWrapper {
        @InvocableVariable(label='Case Id' description='the Id of the Case' required=true)
        public String caseId;
        
        @InvocableVariable(label='isNew' description='used after insert (yes or no)')
        public String isNew;
        
        @InvocableVariable(label='templateCode' description='templateCode to sent in request')
        public String templateCode;

        @InvocableVariable(label='notifiCationType' description='notifiCationType:  can be inform_push, event, sms or email')
        public String notifiCationType;
    }

}
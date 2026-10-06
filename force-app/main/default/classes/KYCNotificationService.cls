public class KYCNotificationService { 

    // Get available balance from the account
    @InvocableMethod(label='SendNotification' description='The purpose of this service is to Send Kyc Notificaion' callout=true )
    public static List<String> KycNotificationSetting(List<KycNotificationData> kycCase){
        List<Kyc_verification__c> Ky = New List<Kyc_verification__c>();
        System.debug('#Notification_Days__c###'+kycCase[0].noofdays);
        System.debug('#Notification_Days__c###'+kycCase[0].Kyccase.Overdue_Stage__c);
        System.debug('#Notification_Days__c###'+kycCase[0].Kyccase.Overdue_Handling__c);
        System.debug('#Notification_Days__c###'+kycCase[0].Kyccase.CRM_Stage__c);
        
        System.debug('#KYC API Status###'+kycCase[0].Kyccase.API_Status__c);
        System.debug('#KYC Type###'+kycCase[0].Kyccase.Type__c);
     /*   Ky = [Select Id,case_Model__c,Account_Name__c,Contact_Name__c,CIF__c,Type__c,Sub_Type__c,Overdue_Handling__c,Overdue_Stage__c,API_Status__c,Account_Name__r.Region_Flag__pc,Account_Name__r.PersonEmail,Account_Name__r.CIF__pc,
                                          Sub_Status__c,Status__c,CRM_Stage__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Review_Personal_Information_Required__c,Block_Debit_Cards__c,Block_Credit_Cards__c,Block_App_Access__c,Block_Account_Debits__c, 
                                          Document_Passport__c,Document_Proof_of_Address__c,Document_Residence_Permit__c,Document_FATCA_Declaration__c,eKYC_Required__c, eKYC_Status__c, ID_V_Required__c, Customer_Segment__c, VVIP__c,Documents_Status__c,Upload_Documents_Required__c,
                                          Account_Name__r.Subscription_Model__pc,Account_Name__r.x_canary__pc,Account_Name__r.Mobile_Phone_Check__pc,No_of_days__c,Next_Notification_Date__c,Document_List__c
                                          from KYC_Verification__c where Id =:kycCase[0].Kyccase.Id];*/
        
        /*String CRM_Stage = '%'+kycCase[0].Kyccase.CRM_Stage__c+'%';
        System.debug('CRM Stage After Like Wise Opeartor:'+CRM_Stage);
        
        List<KYC_Notification_Service__mdt> settings = [
            SELECT DeveloperName, Email_Template_Code__c, Notification_Days__c, Overdue_Handling__c, Overdue_Stage__c,Push_Template_Code__c,SMS_Notification__c,Sms_Template_Code__c
            FROM KYC_Notification_Service__mdt WHERE CRM_Stage__c like:CRM_Stage AND Notification_Days__c=:kycCase[0].noofdays And Overdue_Stage__c =:kycCase[0].Kyccase.Overdue_Stage__c AND Overdue_Handling__c=:kycCase[0].Kyccase.Overdue_Handling__c LIMIT 1];
        System.debug('#Fetching Notification Meta-Data Record#'+settings);*/
        List<KYC_Notification_Service__mdt> settings;
        
        if(kycCase[0].Kyccase.Type__c == 'KYC_PERIODIC_REVIEW'){
            if(kycCase[0].Kyccase.Document_Resend__c){
               settings = [SELECT DeveloperName, Email_Template_Code__c, Notification_Days__c, Overdue_Handling__c, Overdue_Stage__c,Push_Template_Code__c,SMS_Notification__c,Sms_Template_Code__c
            FROM KYC_Notification_Service__mdt WHERE DeveloperName='PR_RETURNED' LIMIT 1]; 
            }else{
           System.debug('Periodic Review Notification');
            String CRM_Stage='%'+kycCase[0].Kyccase.CRM_Stage__c+'%';
            System.debug('CRM Stage After Like Wise Operator:'+CRM_Stage);
			settings = [SELECT DeveloperName, Email_Template_Code__c, Notification_Days__c, Overdue_Handling__c, Overdue_Stage__c,Push_Template_Code__c,SMS_Notification__c,Sms_Template_Code__c
            FROM KYC_Notification_Service__mdt WHERE CRM_Stage__c like:CRM_Stage AND Notification_Days__c=:kycCase[0].noofdays And Overdue_Stage__c =:kycCase[0].Kyccase.Overdue_Stage__c AND Overdue_Handling__c=:kycCase[0].Kyccase.Overdue_Handling__c LIMIT 1];
            }
           
        }
        else if(kycCase[0].Kyccase.Type__c == 'KYC_SUSPECTED_IDENTITY_FRAUD'){
            System.debug('Fraud Notification');
            settings = [SELECT DeveloperName, Email_Template_Code__c, Notification_Days__c, Overdue_Handling__c, Overdue_Stage__c,Push_Template_Code__c,SMS_Notification__c,Sms_Template_Code__c
            FROM KYC_Notification_Service__mdt WHERE CRM_Stage__c=:kycCase[0].Kyccase.API_Status__c AND Notification_Days__c=:kycCase[0].noofdays And Overdue_Stage__c =:kycCase[0].Kyccase.Overdue_Stage__c AND Overdue_Handling__c=:kycCase[0].Kyccase.Overdue_Handling__c LIMIT 1];
        }
        System.debug('#Fetching Notification Meta-data Record#'+settings);
        
        Ky.add(kycCase[0].Kyccase);
        if(!settings.isEmpty()){
            SendEmailNotification(ky,settings[0],'email');
        }
      /*  if(!Ky.isEmpty() && ky[0].Type__c=='KYC_PERIODIC_REVIEW' && ky[0].Document_Resend__c==True){
          //   try{
                        Kyc_Verification__c ku = New Kyc_Verification__c();
                            ku.id= ky[0].id;
                            ku.Document_Resend__c=false;
                        update ku;
                 //        } catch(Exception ex) {
                    //         System.debug('exMessge'+ex.getMessage());
                         //   lstSA.add(KYCVerificationService.buildExceptionAction(ex, kycNewObj));
                    //    }
        }*/
        
        return null;
    }
    
  public static void SendEmailNotification(List<Kyc_verification__c> kycCase,KYC_Notification_Service__mdt NotificationTemplate, String Type) {
        List<KYC_System_Action__c> lstSA = new List<KYC_System_Action__c>();
        List<KYC_Notifications_History__c> KycNOH=new List<KYC_Notifications_History__c>();
        List<Kyc_verification__c> cases = new List<Kyc_verification__c>();
        Map<String, object> mapReq = new Map<String, object>();
      List<Kyc_verification__c> Kyres = New List<Kyc_verification__c>();
       Kyres = [Select Id,case_Model__c,Account_Name__c,Contact_Name__c,CIF__c,Type__c,Sub_Type__c,Overdue_Handling__c,Overdue_Stage__c,API_Status__c,Account_Name__r.Region_Flag__pc,Account_Name__r.PersonEmail,Account_Name__r.CIF__pc,
                                          Sub_Status__c,Status__c,CRM_Stage__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Review_Personal_Information_Required__c,Block_Debit_Cards__c,Block_Credit_Cards__c,Block_App_Access__c,Block_Account_Debits__c, 
                                          Document_Passport__c,Document_Proof_of_Address__c,Document_Residence_Permit__c,Document_FATCA_Declaration__c,eKYC_Required__c, eKYC_Status__c, ID_V_Required__c, Customer_Segment__c, VVIP__c,Documents_Status__c,Upload_Documents_Required__c,
                                          Account_Name__r.Subscription_Model__pc,Account_Name__r.x_canary__pc,Account_Name__r.Mobile_Phone_Check__pc,No_of_days__c,Next_Notification_Date__c,Document_List__c
                                          from KYC_Verification__c where Id =:kycCase[0].Id];
        for(Kyc_verification__c kv : Kyres){
            mapReq.put('type', Type);
            mapReq.put('templateCode', NotificationTemplate.Email_Template_Code__c);
            String regionName = kv.Account_Name__r.Region_Flag__pc;
            if(kv.Account_Name__r.Subscription_Model__pc == 'alburaq'){
                regionName += '_alburaq';
            }
            //toDo : use api uncomment this part
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            ApiConnection con = new ApiConnection();
            request = con.createRequest('POST','/api/v1/notifications?',regionName); 
            System.debug('Request'+request);
            if(kv != null){
                        System.debug('x-canary added :'+kv.Account_Name__r.x_canary__pc);
                        if(kv.Account_Name__r.x_canary__pc != null){
                            request.setHeader('x-canary', kv.Account_Name__r.x_canary__pc);
                        }
                    }
            request.setHeader('userId', kv.Account_Name__r.PersonEmail);
            request.setHeader('customerId', kv.Account_Name__r.CIF__pc);
            request.setTimeout(20000);
            request.setBody(JSON.serialize(mapReq));
            System.debug('Request Body in Send Email Notification:'+request.getBody());         
            HttpResponse response = http.send(request); 
            if (response.getStatusCode() != 200) 
            {
                lstSA.add(KYCVerificationService.buildSystemAction(request.getBody(), response.getBody(), request.getEndpoint(),'POST', kv.CIF__c, kv.Id, response.getStatusCode()));
            }else{
                SendPushNotification(kycCase,NotificationTemplate,'inform_push');
                KYC_Notifications_History__c NH = New KYC_Notifications_History__c();
                NH.KYC_Verification__c = Kv.ID;
                NH.Message_Type__c = Type;
                NH.Template_Code__c = NotificationTemplate.Email_Template_Code__c;
                NH.Sent_On__c = DateTime.now();
                KycNOH.add(NH);
                lstSA.add(KYCVerificationService.buildSystemAction(request.getBody(), response.getBody(), request.getEndpoint(),'POST', kv.CIF__c, kv.Id, response.getStatusCode()));
            }
        }
      if(KycNOH != null && KycNOH.size()>0){
          insert KycNOH;
          
      }
      if(lstSA != null && lstSA.size()>0){
          insert lstSA;
      }  
  }
 
    public static void SendPushNotification(List<Kyc_verification__c> kycCase,KYC_Notification_Service__mdt NotificationTemplate, String Type) {
        List<KYC_System_Action__c> lstSA = new List<KYC_System_Action__c>();
        List<KYC_Notifications_History__c> KycNOH=new List<KYC_Notifications_History__c>();
        List<Kyc_verification__c> cases = new List<Kyc_verification__c>();
        Map<String, object> mapReq = new Map<String, object>();
         List<Kyc_verification__c> Kyres = New List<Kyc_verification__c>();
       Kyres = [Select Id,case_Model__c,Account_Name__c,Contact_Name__c,CIF__c,Type__c,Sub_Type__c,Overdue_Handling__c,Overdue_Stage__c,API_Status__c,Account_Name__r.Region_Flag__pc,Account_Name__r.PersonEmail,Account_Name__r.CIF__pc,
                                          Sub_Status__c,Status__c,CRM_Stage__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Review_Personal_Information_Required__c,Block_Debit_Cards__c,Block_Credit_Cards__c,Block_App_Access__c,Block_Account_Debits__c, 
                                          Document_Passport__c,Document_Proof_of_Address__c,Document_Residence_Permit__c,Document_FATCA_Declaration__c,eKYC_Required__c, eKYC_Status__c, ID_V_Required__c, Customer_Segment__c, VVIP__c,Documents_Status__c,Upload_Documents_Required__c,
                                          Account_Name__r.Subscription_Model__pc,Account_Name__r.x_canary__pc,Account_Name__r.Mobile_Phone_Check__pc,No_of_days__c,Next_Notification_Date__c,Document_List__c
                                          from KYC_Verification__c where Id =:kycCase[0].Id];
        for(Kyc_verification__c kv : Kyres){
            mapReq.put('type', Type);
            mapReq.put('templateCode', NotificationTemplate.Push_Template_Code__c);
            String regionName = kv.Account_Name__r.Region_Flag__pc;
            if(kv.Account_Name__r.Subscription_Model__pc == 'alburaq'){
                regionName += '_alburaq';
            }
            //toDo : use api uncomment this part
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            ApiConnection con = new ApiConnection();
            request = con.createRequest('POST','/api/v1/notifications?',regionName); 
            System.debug('Request'+request);
            if(kv!= null){
                System.debug('x-canary added :'+kv.Account_Name__r.x_canary__pc);
                if(kv.Account_Name__r.x_canary__pc != null){
                    request.setHeader('x-canary', kv.Account_Name__r.x_canary__pc);
                }
            }
            request.setHeader('userId', kv.Account_Name__r.PersonEmail);
            request.setHeader('customerId', kv.Account_Name__r.CIF__pc);
            request.setTimeout(20000);
            request.setBody(JSON.serialize(mapReq));
            System.debug('Request Body in Push Notification:'+request.getBody());            
            HttpResponse response = http.send(request); 
            if (response.getStatusCode() != 200) 
            {
                lstSA.add(KYCVerificationService.buildSystemAction(request.getBody(), response.getBody(), request.getEndpoint(),'POST', kv.CIF__c, kv.Id, response.getStatusCode()));
            }else{
                if(NotificationTemplate.SMS_Notification__c){
                    SendSMSNotification(kycCase,NotificationTemplate,'sms');
                }
                lstSA.add(KYCVerificationService.buildSystemAction(request.getBody(), response.getBody(), request.getEndpoint(),'POST', kv.CIF__c, kv.Id, response.getStatusCode()));
                
                KYC_Notifications_History__c NH = New KYC_Notifications_History__c();
                NH.KYC_Verification__c = Kv.ID;
                NH.Message_Type__c = Type;
                NH.Template_Code__c = NotificationTemplate.Push_Template_Code__c;
                NH.Sent_On__c = DateTime.now();
                KycNOH.add(NH);
            }
        }
        if(KycNOH != null && KycNOH.size()>0){
            insert KycNOH;
            
        }
        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }  
    }
    
     public static void SendSMSNotification(List<Kyc_verification__c> kycCase,KYC_Notification_Service__mdt NotificationTemplate, String Type) {
            List<KYC_System_Action__c> lstSA = new List<KYC_System_Action__c>();
        List<KYC_Notifications_History__c> KycNOH=new List<KYC_Notifications_History__c>();
        List<Kyc_verification__c> cases = new List<Kyc_verification__c>();
        Map<String, object> mapReq = new Map<String, object>();
           List<Kyc_verification__c> Kyres = New List<Kyc_verification__c>();
       Kyres = [Select Id,case_Model__c,Account_Name__c,Contact_Name__c,CIF__c,Type__c,Sub_Type__c,Overdue_Handling__c,Overdue_Stage__c,API_Status__c,Account_Name__r.Region_Flag__pc,Account_Name__r.PersonEmail,Account_Name__r.CIF__pc,
                                          Sub_Status__c,Status__c,CRM_Stage__c,ID_V_Status__c,KYC_Form_Status__c,KYC_Form_Tax_Status__c,KYC_Upload_Document_Status__c,Review_Personal_Information_Required__c,Block_Debit_Cards__c,Block_Credit_Cards__c,Block_App_Access__c,Block_Account_Debits__c, 
                                          Document_Passport__c,Document_Proof_of_Address__c,Document_Residence_Permit__c,Document_FATCA_Declaration__c,eKYC_Required__c, eKYC_Status__c, ID_V_Required__c, Customer_Segment__c, VVIP__c,Documents_Status__c,Upload_Documents_Required__c,
                                          Account_Name__r.Subscription_Model__pc,Account_Name__r.x_canary__pc,Account_Name__r.Mobile_Phone_Check__pc,No_of_days__c,Next_Notification_Date__c,Document_List__c
                                          from KYC_Verification__c where Id =:kycCase[0].Id];
        for(Kyc_verification__c kv : Kyres){
            mapReq.put('phoneNumber',kv.Account_Name__r.Mobile_Phone_Check__pc);
            mapReq.put('type', Type);
            mapReq.put('templateCode', NotificationTemplate.Sms_Template_Code__c);
            String regionName = kv.Account_Name__r.Region_Flag__pc;
            if(kv.Account_Name__r.Subscription_Model__pc == 'alburaq'){
                regionName += '_alburaq';
            }
            //toDo : use api uncomment this part
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            ApiConnection con = new ApiConnection();
            request = con.createRequest('POST','/api/v1/notifications?',regionName); 
            System.debug('Request'+request);
            if(kv!= null){
                        System.debug('x-canary added :'+kv.Account_Name__r.x_canary__pc);
                        if(kv.Account_Name__r.x_canary__pc != null){
                            request.setHeader('x-canary', kv.Account_Name__r.x_canary__pc);
                        }
                    }
            request.setHeader('userId', kv.Account_Name__r.PersonEmail);
            request.setHeader('customerId', kv.Account_Name__r.CIF__pc);
            request.setTimeout(20000);
            request.setBody(JSON.serialize(mapReq));
            System.debug(request.getBody());         
            HttpResponse response = http.send(request); 
            if (response.getStatusCode() != 200) 
            {
              lstSA.add(KYCVerificationService.buildSystemAction(request.getBody(), response.getBody(), request.getEndpoint(),'POST', kv.CIF__c, kv.Id, response.getStatusCode()));
            }else{
                KYC_Notifications_History__c NH = New KYC_Notifications_History__c();
                NH.KYC_Verification__c = Kv.ID;
                NH.Message_Type__c = Type;
                //UATNB-210254: Start
                //NH.Template_Code__c=NotificationTemplate.Push_Template_Code__c; //Commented due to sending Push template code instead of sms template code
                NH.Template_Code__c=NotificationTemplate.Sms_Template_Code__c;
                //UATNB-210254: END
                NH.Sent_On__c = DateTime.now();
                KycNOH.add(NH);
                lstSA.add(KYCVerificationService.buildSystemAction(request.getBody(), response.getBody(), request.getEndpoint(),'POST', kv.CIF__c, kv.Id, response.getStatusCode()));
            }
        }
         if(KycNOH != null && KycNOH.size()>0){
                insert KycNOH;
                
            }
         if(lstSA != null && lstSA.size()>0){
                insert lstSA;
            }  
    }
    // Inner class to represent a key-value pair
    public class KycNotificationData {
        @InvocableVariable(label='Kyccase')
        public KYC_Verification__c Kyccase;

        @InvocableVariable(label='Noofdays')
        public String noofdays; // or any other supported type
    }
}
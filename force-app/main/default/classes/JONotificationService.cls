public class JONotificationService {
    
        // Get available balance from the account
    @InvocableMethod(label='SendNotification' description='The purpose of this service is to Send  Notificaion' callout=true )
    public static List<String> SendNotification(List<JONotificationData> SendNotification){
        JONotificationService.SendEmailNotification(SendNotification[0].templateCode,SendNotification[0].Type,SendNotification[0].email,SendNotification[0].CIF,SendNotification[0].regionName,SendNotification[0].subscriptionModel, SendNotification[0].customerId);
         return null;
    }
    
     public static void SendEmailNotification(String templateCode, String Type, String email, String CIF, String regionName, String subscriptionModel, String customerId) {
        List<System_Action__c> lstSA = new List<System_Action__c>();
         Map<String, object> mapReq = new Map<String, object>();  
         mapReq.put('type', Type);
            mapReq.put('templateCode', templateCode);
           // String regionName = regionName;
            if(subscriptionModel == 'alburaq'){
                regionName += '_alburaq';
            }
            //toDo : use api uncomment this part
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            ApiConnection con = new ApiConnection();
            request = con.createRequest('POST','/api/v1/notifications?',regionName); 
            System.debug('Request'+request);
            request.setHeader('userId', email);
            request.setHeader('customerId', CIF);
            request.setTimeout(20000);
            request.setBody(JSON.serialize(mapReq));
            System.debug('Request Body in Send Email Notification:'+request.getBody());         
            HttpResponse response = http.send(request); 
           if (response.getStatusCode() != 200) 
            {
              //  lstSA.add(KYCVerificationService.buildSystemAction(request.getBody(), response.getBody(), request.getEndpoint(),'POST', kv.CIF__c, kv.Id, response.getStatusCode()));
            }else{
              Account ac = New Account();
                ac.id=customerId;
                ac.Use_Preferential_FD_Rate__pc=True;
                update ac;
            }
        }
  /*    if(lstSA != null && lstSA.size()>0){
          insert lstSA;
      }  */
      public class JONotificationData {
        @InvocableVariable(label='templateCode')
        public String templateCode;

        @InvocableVariable(label='type')
        public String type; // or any other supported type
        
        @InvocableVariable(label='email')
        public String email; // or any other supported type
        
        @InvocableVariable(label='CIF')
        public String CIF;
        
        @InvocableVariable(label='regionName')
        public String regionName; 
        
        @InvocableVariable(label='subscriptionModel')
        public String subscriptionModel; 
        @InvocableVariable(label='customerId')
        public String customerId; 
    }

  }
      // Inner class to represent a key-value pair
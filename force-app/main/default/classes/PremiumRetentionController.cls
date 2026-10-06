/*      
 *      Change History: 
 *          #CH01 : hamza chaoui 22/07/2022 -- add alburaq notification logic
 * 			#CH02# #Jahangeer Mohammed# #01-09-2025# Added Status Mapping for PENDING CUSTOMER (UATNB-190666) Under (NBA-15626)
 *            
*/
public class PremiumRetentionController {
    private static ApiConnection con = new ApiConnection();

    @AuraEnabled
    public static Id getPremiumRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Premium_Retention').getRecordTypeId();
    }
    
    
    @AuraEnabled
    public static Id getCollectionLetterCaseQueue() {
        Id queueId= [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Credit Collection Maker'].Id;
        return queueId;
    }
    
    @AuraEnabled
    public static String getCustomerName(Id accId) {
        Account accreocrd= [SELECT Id,name,FirstName,LastName FROM Account WHERE Id=:accId];
        return accreocrd.FirstName +' '+accreocrd.LastName;
    }
    @future(callout=true)
    public static void updateDiscountRequest(final Id caseId,string substatus,string queueId,Datetime ContactResultDateTime,DateTime RMTResultDateTime,DateTime BusinessDateTime,String cStatus, string caseType) {
        Map<String,string> statusMapping= new Map<string,string>();
        statusMapping.put('Pending Exit Interview','PENDING');
        statusMapping.put('Pending Discount From Bank','PENDING');
        //CH02: Start
        statusMapping.put('Pending Customer','PENDING_CUSTOMER');
        //CH02: END
        statusMapping.put('Retained Without Discount','RETAINED_NO_DISCOUNT');
        statusMapping.put('Retained With Discount','RETAINED_WITH_DISCOUNT');
        statusMapping.put('Downgraded','DOWNGRADED');
        statusMapping.put('Declined by Customer','DECLINED_BY_CUSTOMER');
        statusMapping.put('Expired','EXPIRED');
        statusMapping.put('Rolled Back by Bank','ROLLED_BACK');
        statusMapping.put('Cancelled','CANCELLED');
        statusMapping.put('Accepted by Customer','ACCEPTED_BY_CUSTOMER');
        statusMapping.put('','DISCOUNT_CLAIMED');
        system.debug('substatus'+substatus);
        system.debug('caseId==>'+caseId);
        List<case> updatecase= new List<case>();
        Case cs=[Select Id,Expiry_Days__c,Customer_CIF__c,Account.CIF__pc,Account.x_canary__pc,Account.Region_Flag__c,accountId,RMT_Results_Date_Time__c,Discount_Amount__c,ac_RequestedBy__c,Premium_Substatus_Changed__c,Status,Sub_Status__c,cc_Contact_Centre_Date_Time__c,ownerId,Waiting_for_customer_feedback__c,LastModifiedByID from Case where Id=:caseId];
        system.debug('Sub_Status__c==>'+cs.Sub_Status__c);
        //string caseStatus=statusMapping.get(cs.Sub_Status__c);
  
        string caseStatus;
        if(substatus!=null)
        {
            caseStatus=statusMapping.get(substatus);
        }
        else{
            caseStatus=statusMapping.get(cs.Sub_Status__c);
        }
        if(!String.ValueOf(cs.LastModifiedByID).contains((system.Label.AWS_Integration_User_ID)))
        {
            system.debug('caseStatus==>'+caseStatus);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
          //  if(substatus=='Pending Customer' && caseType=='INVITATION'){
            //     request = con.createRequest('POST','/api/v1/membership/discount/request',cs.Account.Region_Flag__c);
            //}else{
                request = con.createRequest('PUT','/api/v1/membership/discount/request',cs.Account.Region_Flag__c); 
            //}
           
           if(cs.Account.x_canary__pc != null){
                request.setHeader('x-canary', cs.Account.x_canary__pc);//CH22
            }
            string body;
            //string body = '{"caseType": "RETENTION","expiryDays":'+cs.Expiry_Days__c+',"crmCaseId":'+cs.Id+',"status":'+caseStatus+',"discountAmount":'+cs.Discount_Amount__c+',"requestedBy":'+cs.ac_RequestedBy__c+'}';
            If(caseType=='RETENTION')
            {
                if(cs.ac_RequestedBy__c=='Customer')
                {
                    body = '{"caseType": "RETENTION","expiryDays":"'+cs.Expiry_Days__c+'","crmCaseId":"'+cs.Id+'","status":"'+caseStatus+'","discountAmount":'+cs.Discount_Amount__c+',"requestedBy":"CUSTOMER"}';
                }
                else{
                    body = '{"caseType": "RETENTION","expiryDays":"'+cs.Expiry_Days__c+'","crmCaseId":"'+cs.Id+'","status":"'+caseStatus+'","discountAmount":'+cs.Discount_Amount__c+',"requestedBy":"BANK"}';
                }
            }
            If(caseType=='INVITATION')
            {
                if(cs.ac_RequestedBy__c=='Customer')
                {
                    body = '{"caseType": "INVITATION","expiryDays":"'+cs.Expiry_Days__c+'","crmCaseId":"'+cs.Id+'","status":"'+caseStatus+'","discountAmount":'+cs.Discount_Amount__c+',"requestedBy":"CUSTOMER"}';
                }
                else{
                    body = '{"caseType": "INVITATION","expiryDays":"'+cs.Expiry_Days__c+'","crmCaseId":"'+cs.Id+'","status":"'+caseStatus+'","discountAmount":'+cs.Discount_Amount__c+',"requestedBy":"BANK"}';
                }
            }
            
            
            system.debug('---> BODY --> '+body);               
            request.setBody(body);
            request.setHeader('customerId', cs.Account.CIF__pc);
            request.setHeader('regionName', cs.Account.Region_Flag__c);
            //aurora Change -adhoc revert
           // request.setHeader('x-canary', 'aurora');
            
            system.debug('---> request--> '+request.getBody());
            
            HttpResponse response = http.send(request);
            
            System.debug(response);
            //return response;
            if (response.getStatusCode() != 200) 
            {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                insert createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/membership/discount/request?language=en&unit=neo','PUT',cs.Id,cs.Account.CIF__pc,cs.accountId,response.getStatusCode(), 'Premium Retention/Invitation Application', 'premium Application');
            }
            else{ 
                if(cStatus!=null){
                    cs.Status=cStatus;//'Closed'; 
                }
                
                if(substatus!=null){
                    cs.Sub_Status__c=substatus;
                }
                if(substatus=='Pending Customer'){
                    cs.Waiting_for_customer_feedback__c=true;
                    cs.Premium_Substatus_Changed__c=system.today().addDays(Integer.valueOf(cs.Expiry_Days__c));
                }else{
                    cs.Waiting_for_customer_feedback__c=false;
                }
                if(queueId!=null){
                    cs.OwnerId=queueId;
                }
                if(ContactResultDateTime!=null){
                    cs.cc_Contact_Centre_Date_Time__c=ContactResultDateTime;
                }
                if(RMTResultDateTime!=null){
                    cs.RMT_Results_Date_Time__c=RMTResultDateTime;
                }
                
                
                updatecase.add(cs);
            }
    }
    else{
        cs.status = 'Closed';
        updatecase.add(cs);
    }
       Database.update(updatecase);
    }
    

    @AuraEnabled
    public static void updateDiscountRequestApiOnCaseCreation(Id caseId){
        updateDiscountRequest(caseId,'Pending Customer',system.Label.temp_Queue,null,null,system.now(),null,'RETENTION');
    }

    @future(callout=true)
    public static void createDiscountRequest(Id caseId,string substatus) {

        List<Case> updatecases= new List<Case>();
        Case cs=[Select Id,Account.CIF__pc,Expiry_Days__c,Premium_Substatus_Changed__c,Waiting_for_customer_feedback__c,Account.Region_Flag__c,accountId,Status,Sub_Status__c from Case where Id=:caseId];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request = con.createRequest('PUT','/api/v1/membership/discount/request',cs.Account.Region_Flag__c);
        string body = '{"caseType": "RETENTION"}';
        request.setBody(body);
        request.setHeader('customerId', cs.Account.CIF__pc);
        request.setHeader('regionName', cs.Account.Region_Flag__c);
        
        system.debug('---> request IN_PROGRESS FOR createDiscountRequest Api--> '+request.getBody());
        HttpResponse response = http.send(request);
        
        System.debug(response);
        system.debug('response.getStatusCode()==>'+response.getStatusCode());
        if (response.getStatusCode() != 200) 
        {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getBody());
           insert  createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/membership/discount/request?language=en&unit=neo','PUT',cs.Id,cs.Account.CIF__pc,cs.accountId,response.getStatusCode(), 'Premium Retention/Invitation Application', 'premium Application');
        }
        else{ 
            System.debug('createDiscountRequest Response --> '+response.getBody() );
            /* if(substatus=='Pending Customer'){
                cs.Waiting_for_customer_feedback__c=true;
                cs.Premium_Substatus_Changed__c=system.today().addDays(Integer.valueOf(cs.Expiry_Days__c));
            }else{
                cs.Waiting_for_customer_feedback__c=false;
            }
            updatecases.add(cs); */
        }
        //Database.update(updatecases);
        
    }

    public static void sendEmail(Id CaseId){

        //#CH01 : add Case_Model__c
        Case cs = [SELECT Id,Status,AccountId,Letter_Type__c,ContactEmail,Sub_Status__c,cc_Contact_Centre_Result__c,cc_Contact_Centre_Date_Time__c,cc_Business_Approval_Result__c,cc_Business_Approval_Result_Date_Time__c ,Case_Model__c  FROM Case Where ID =:caseId];
        contact cd = [SELECT Id,Name,Email FROM contact WHERE AccountId =:cs.AccountId];

        //EmailTemplate et = [SELECT Id,Name FROM EmailTemplate WHERE DeveloperName ='Premium_Retention_Pending_Customer_Reminder'];

         //#CH01 --Start
         EmailTemplate et;
         if(cs.Case_Model__c == 'alburaq'){
             et = [SELECT Id,Name FROM EmailTemplate WHERE DeveloperName ='Premium_Retention_Pending_Customer_Reminder_Alburaq'];
         }else{
             et = [SELECT Id,Name FROM EmailTemplate WHERE DeveloperName ='Premium_Retention_Pending_Customer_Reminder'];
         } 
         //#CH01 --End


        OrgWideEmailAddress owe = [select Id from OrgWideEmailAddress where Address = 'support@ilabank.com'];
        system.debug('et--->'+et);
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setWhatId(cs.Id);
        email.setTemplateId(et.Id);
        email.setTargetObjectId(cd.Id);
        email.setOrgWideEmailAddressId(owe.Id);
        email.setToAddresses( new List<String>{cd.Email} );
        
        try{
            Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            System.debug('result'+result);
            if(result[0].isSuccess()){
                System.debug('result Success');
            }else{
                System.debug('Email Not sent successfully');
            }
            
        }
        catch(System.Exception e){
            System.debug('Error:'+e.getMessage());
        }
    }
    
    /**
* @param: method - POST | PUT
* Description : To create a system Action record in case of Failed response
*/
    
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
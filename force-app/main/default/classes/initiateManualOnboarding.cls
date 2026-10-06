/*      Organization : ABC Bank
*      Created By: 
*      Created Date:
*      Change History: 
*             #CH01# #Jahangeer Mohammed# Added #24-06-2021# Calling API According to the Additional Requirements of Credit Cards.
*             #CH02# #Shashank# Added #27-06-2021# Calling API For Adobe e-Signature Automation.
*             #CH03# #Jahangeer Mohammed #31-10-2021# Commented Pre-screening Result != Accept for Credit Limit Update.
*                    #Jahangeer Mohammed #01-11-2021# Added Type and Sub type condition in the Signature Verifier phase
*                    #Jahangeer Mohammed #01-11-2021# Added Signature verifier Logic for Limit Update.
*                    #Jahangeer Mohammed #01-11-2021# Commented the Limit Update code from Buyout and Signature Verifier(Application Process)
*             #CH04# #Jahangeer Mohammed #06-11-2021# Added Code for Reminder Functionality.
*                    #Jahangeer Mohammed #10-11-2021# Added API Call for SMS Reminders.
*              #CH05# #Mbarki Aniss #15-11-2021# add the field 'cc_Activate_Reminders_for_Pending_Cases__c" in the select soql query
*              #CH06# #Mbarki Aniss #23-12-2021# code optimization 
*              #CH07# #Mbarki Aniss #17-01-2022# set ScreeningResult as "PASS" if nameScreening == false  
*                     #Jahangeer Mohammed #17-01-2022# Passing Approved Name on the card for Credit Card Supplementary card.
*              #CH08# #Jahangeer Mohammed #31-01-2022# Added Logic for Credit Card Staff Application(NBA-4713)
*              #CH09# #Jahangeer Mohammed #10-02-2022# Added Logic for Credit Card Staff Application(NBA-4807)
*              #CH10# #Jahangeer Mohammed #10-03-2022# Customer Responded condition commented for (NBA-4947/4948)
*              #CH11# #Jahangeer Mohammed #14-07-2022# Added Logic to Populate CPR Number & CPR Expiry(NBA-5692 & NBA-5693) 
*              #CH12# #Jahangeer Mohammed #24-07-2022# Added Logic to Store CardProductConfigurationId
*              #CH13# Added by Amina BENABDELKRIM 20-06-2022 *** to add new field (case model) with the value of subscription model -->   
*              #CH14# #Hamza Chaoui# #04-07-2022# -- implement alburaq unit changes.
*              #CH15# #Jahangeer Mohammed# #15-08-2022# Added campaignID in request parameter as per ticket(NBA-5719)
*              #CH16# #Jahangeer Mohammed# #15-09-2022# Added code fix for PI-1727 Customer receiving email even after case is closed for Credit Limit Increase Application
*              #CH17# #Aniss Mbarki# #23-10-2022# Add code fix for Enhanced Supplementary Card Application Process
*              #CH18# #Jahangeer Mohammed# 24-11-2022# Added Logic for Application Queue Improvements NBA-6361
*              #CH19# #Jahangeer Mohammed# 22-05-2023# Added Custom Labels to Store Credit Card End-Point Urls to avoid hardcoding
*              #CH20# : Elmustapha ELGARNI add UpdateCustomerDetailsForDNDupdate function and add logic to handle Marketing Prefences to add/Remove customer to/from DND list . Date 18/10/2023
*              #CH21# #Jayanth Manickam# Temporary Limit Increase
*              #CH22# ##Imane Tsioucha# #15-01-2024# add x-canary header
*              #CH23# #Jahangeer Mohammed# #16-01-2024# Added Logic for Permanent Limit Increase Process Change (NBA-9499)
*              #CH24# #Jahangeer Mohammed# #16-04-2024# Added Logic for Decline reason Email (NBA-10204)
*              #CH25# #Jahangeer Mohammed# #20-05-2024# Added Decline & Cancelled by Customer in Signature Verifier Phase(NBA-11053)
*              #CH26# #Jahangeer Mohammed# #21-07-2024# Added Campaign Name Segregation for Null and Not Null
*              #CH27# #Jahangeer Mohammed# #04-08-2024# Added Logic to add Alias Name as API/Manual based on the Last Modified User
*              #CH28# #Jahangeer Mohammed# #17-12-2024# Added Logic to add Co-Branded Cards(NBA-12524)
*              #CH29# #Jahangeer Mohammed# #02-02-2025# Added Logic for API Failures(NBA-13083)
*			   #CH30# #Jahangeer Mohammed# #04-02-2025# Added Membership Parameter in Case Creation(UATNB-153526)
*			   #CH31# #Jahangeer Mohammed# #09-02-2025# Added Logic for Re-applying Control Feature(NBA-13039)
*			   #CH32# #Jahangeer Mohammed# #25-02-2025# Added Logic for iGA Passport Number (UATNB-156349)
*			   #CH33# #Jahangeer Mohammed# #09-02-2025# Added Logic for Premium Retention for Co-branded Cards for Premium Customers (NBA-13210)
*			   #CH34# #Jahangeer Mohammed# #06-08-2025# Added Logic for Ila World Elite Premium Invitation and Retention (NBA-15626)
*              #CH35# #Jahangeer Mohammed# #06-08-2025# Added Logic for Credit Card Spouse(NBA-15728)
*			   #CH36# #Jahangeer Mohammed# #05-11-2025# Added Logic for World Entitlement Project(NBA-15929)
			   #CH37# #Jahangeer Mohammed# 24-11-2025# Added Logic for Queues Re-structuring at Credit Pre-Screener (NBA-15993)
			   #CH38# #Jahangeer Mohammed# 29-12-2025# Added Logic for Reapplying Restriction Period Unsecured Limit Increase and Secured Application(NBA-16360)
               #CH39# #Aniss Mbarki# 23-12-2025# Added Logic for Credit Card - In-App DocuSign Documents Signing  (NBA-13727)
               #CH40# #Aniss Mbarki# 05-04-2026# Added Logic for Credit Card - In-App DocuSign attah Documents Signing to an email 
               #CH42 #AITOGRAM Omar# 20/04/2026  Added null pointer for x_canary__pc field 
 			   #CH43# #Jahangeer Mohammed# 23/07/2026 Commented the code CCCaseActivateReminders methods as it is not required for reminder notifications and related fields - Automatic Creation of Upgrade Cases from Limit Increase Application (NBA-17560)
*/            
global class initiateManualOnboarding
{
    private static String caseModelValue;
    private static ApiConnection con = new ApiConnection();
    private static final String  CONTACT_CENTRE_QUEUE = 'Contact Centre';
    private static final String  IT_QUEUE = 'IT';
    private static final String  CREDIT_CARD_REGULAR_BUYOUT_QUEUE = 'Credit Card Regular Buyout';
    
    @future(callout=true)
    public static void ManualOnboarding(Set<Id> setAccId)
    {   
        List<Case> lstCreateCase = new List<Case>();
        //CH13 added new field (case model) with the value of subscription model -->
        
        List<Account> lstAcc = [Select id, PersonContactId, CIF__pc, PersonEmail, Mobile_Country_Code__pc, PersonMobilePhone, Mobile_Country_Code_Update__pc, Phone, Region_Flag__c,Subscription_Model__pc,x_canary__pc  from Account where id in: setAccId];
        
        //Get the queue label for the assignment depending on the region flag
        List<Queue_IDs__mdt> queueIds = [SELECT Id, DeveloperName, Label, Queue_ID__c, MasterLabel, Queue_Name__c, Region__c FROM Queue_IDs__mdt];
        Map<Id, String> accountToRegion = Util.getAccountQueuesCustomMetadata(lstAcc);
        
        for(Account acc : lstAcc)
        {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('POST', '/api/v1/onboarding/manual/start?', acc.Region_Flag__c);
            
            String body = '{"email": "'+acc.PersonEmail + 
                '","customerId": "'+acc.CIF__pc + 
                '", "phone": "'+acc.Mobile_Country_Code__pc+acc.PersonMobilePhone+'"}';
            
            system.debug('---> BODY --> '+body);               
            request.setBody(body);
            request.setHeader('userId', acc.PersonEmail);
            request.setHeader('customerId', acc.CIF__pc);
            //CH42 start 
            if(acc.x_canary__pc != null){
                request.setHeader('x-canary', acc.x_canary__pc);
            }
            //CH42
            
            
            system.debug('---> Request --> '+request.getBody());
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() != 200) 
            {
                //CH13 START   
                if(acc.Subscription_Model__pc=='alburaq'){  
                    caseModelValue='alburaq';   
                }   
                else{   
                    caseModelValue='ila';   
                }   
                System.debug('CaseModelValue==>  '+caseModelValue); 
                //CH13 END
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                System.debug('Response: '+response.getBody());
                Case objCase = new Case();
                objCase.Subject = 'Technical failure to start Orchestration Layer';
                objCase.Description = 'A technical issue has occurred at an API level.';
                objCase.Type = 'Technical';
                objCase.Status = 'In Progress';
                objCase.Priority = 'High';
                Util.setOwnerQueueFromAccount(queueIds, accountToRegion, objCase, acc, IT_QUEUE);
                //objCase.OwnerId = system.label.IT_Queue;
                objCase.Origin = 'OL';
                objCase.ContactId = acc.PersonContactId;
                objCase.Case_Model__c=caseModelValue;//CH13 
                lstCreateCase.add(objCase);
            }
            else
            {
                System.debug(response.getBody());
            }
        }
        if(lstCreateCase.size()>0)
            insert lstCreateCase;
        
    }
    
    @future(callout=true)
    public static void continueManualOnboarding(Set<Id> setCaseId)
    {
        List<Case> lstAcc = [Select id, status, Type, Account.PersonEmail, Account.CIF__pc, Region_Flag__c from Case where id in: setCaseId];
        for(Case caseObj : lstAcc)
        {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('POST', '/api/v1/onboarding/manual/continue?', caseObj.Region_Flag__c);
            
            String body = '{"caseId": "'+caseObj.Id +
                '","email": "'+caseObj.Account.PersonEmail +
                '","caseStatus": "'+caseObj.Status+'"}';
            
            system.debug('---> BODY --> '+body);
            request.setBody(body);
            request.setHeader('userId', caseObj.Account.PersonEmail);
            request.setHeader('customerId', caseObj.Account.CIF__pc);
            
            system.debug('---> Request --> '+request.getBody());
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() != 200)
            {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            }
            else
            {
                System.debug(response.getBody());
            }
        }
        
    }
    
    @future(callout=true)
    public static void reTriggerManualOnboarding(Set<Id> setCaseId)
    {
        List<Case> lstCreateCase = new List<Case>();
        // CH13 START  -->  
        List<Case> lstCase = [Select id, status, Type, Account.PersonContactId, Account.PersonEmail, Account.CIF__pc, Account.Mobile_Country_Code__pc, Account.PersonMobilePhone, Region_Flag__c,Case_Model__c from Case where id in: setCaseId];
        
        //Get the queue label for the assignment depending on the region flag
        List<Queue_IDs__mdt> queueIds = [SELECT Id, DeveloperName, Label, Queue_ID__c, MasterLabel, Queue_Name__c, Region__c FROM Queue_IDs__mdt];
        Map<Id, String> caseToRegion = Util.getQueuesCustomMetadata(lstCase);
        
        for(Case caseObj : lstCase)
        {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('POST', '/api/v1/onboarding/manual/start?', caseObj.Region_Flag__c);
            
            String body = '{"email": "'+caseObj.Account.PersonEmail +
                '","customerId": "'+caseObj.Account.CIF__pc +
                '", "phone": "'+caseObj.Account.Mobile_Country_Code__pc+caseObj.Account.PersonMobilePhone+'"}';
            
            system.debug('---> BODY --> '+body);
            request.setBody(body);
            request.setHeader('userId', caseObj.Account.PersonEmail);
            request.setHeader('customerId', caseObj.Account.CIF__pc);
            
            system.debug('---> Request --> '+request.getBody());
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() != 200)
            {
                if(caseObj.Case_Model__c=='alburaq'){  
                    caseModelValue='alburaq';   
                }   
                else{   
                    caseModelValue='ila';   
                }   
                System.debug('CaseModelValue==>  '+caseModelValue);
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                Case objCase = new Case();
                objCase.Subject = 'Technical failure to start Orchestration Layer';
                objCase.Description = 'A technical issue has occurred at an API level.';
                objCase.Type = 'Technical';
                objCase.Status = 'In Progress';
                objCase.Priority = 'High';
                //objCase.OwnerId = system.label.IT_Queue;
                Util.setOwnerQueueFromCase(queueIds, caseToRegion, objCase, caseObj, IT_QUEUE);
                objCase.Origin = 'OL';
                objCase.ContactId = caseObj.Account.PersonContactId;
                objCase.Case_Model__c=caseModelValue;//CH13
                lstCreateCase.add(objCase);
            }
            else
            {
                System.debug(response.getBody());
            }
        }
        if(lstCreateCase.size()>0)
            insert lstCreateCase;
        // CH13 END -->
        
    }
    
    /////////////////////////// Manual Closure of EKYC Cases /////////////////////////////////////////
    
    @future(callout=true)
    public static void EKYCManualClosure(Set<Id> setCaseId)
    {
        List<Case> lstUpdateCase = new List<Case>();
        List<Case> lstCase = [Select id, status, Type, Sub_Type__c, Origin, Account.PersonEmail, Account.CIF__pc, Region_Flag__c from Case where id in: setCaseId];
        for(Case objCase : lstCase)
        {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('POST', '/api/v1/onboarding/continue?', objCase.Region_Flag__c);
            //request = createRequest('POST','/api/v1/onboarding/manual/start?');
            
            if(objCase.Origin == 'EKYC-UPLOAD'){
                String body = '{"caseId": "'+objCase.Id +
                    '","email": "'+objCase.Account.PersonEmail +
                    '","caseType": "'+objCase.Type +
                    '","caseStatus": "ApprovedUpload"}';
                
                system.debug('---> BODY --> '+body);
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> Request --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                }
                else
                {
                    System.debug(response.getBody());
                }
            }
            else if(objCase.Origin == 'EKYC-FETCH'){
                String body = '{"caseId": "'+objCase.Id +
                    '","email": "'+objCase.Account.PersonEmail +
                    '","caseType": "'+objCase.Type +
                    '","caseStatus": "ApprovedFetch"}';
                
                system.debug('---> BODY --> '+body);
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> Request --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                }
                else
                {
                    System.debug(response.getBody());
                }
            }
            else if(objCase.Origin == 'EKYC-SIGNOFF'){
                String body = '{"caseId": "'+objCase.Id +
                    '","email": "'+objCase.Account.PersonEmail +
                    '","caseType": "'+objCase.Type +
                    '","caseStatus": "ApprovedSignOff"}';
                
                system.debug('---> BODY --> '+body);
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> Request --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                }
                else
                {
                    System.debug(response.getBody());
                }
            }
        }
    }
    
    /////////////////////////////////// eKYC Phase 1.5 //////////////////////////////////////////////
    
    @future(callout=true)
    public static void EKYCManualRetry_IDCase(Set<Id> setCaseId)
    {
        List<Case> lstUpdateCase = new List<Case>();
        List<Case> lstCase = [Select id, status, Type, eKYC_Decision__c, Sub_Type__c, Origin, Account.PersonEmail, Account.CIF__pc, Region_Flag__c from Case where id in: setCaseId];
        for(Case objCase : lstCase)
        {
            Http http = new Http();
            String body = '';
            HttpRequest request = new HttpRequest();
            request = con.createRequest('POST', '/api/v1/onboarding/continue?', objCase.Region_Flag__c);
            //request = createRequest('POST','/api/v1/onboarding/manual/start?');
            
            if(objCase.Origin == 'EKYC-UPLOAD')
            {
                if(objCase.eKYC_Decision__c == 'Manual Retry')
                {
                    body = '{"caseId": "'+objCase.Id +
                        '","email": "'+objCase.Account.PersonEmail +
                        '","caseType": "'+objCase.Type +
                        '","caseStatus": "ContinueUpload"}';
                }
                else if(objCase.eKYC_Decision__c == 'Convert to Identification Case')
                {
                    body = '{"caseId": "'+objCase.Id +
                        '","email": "'+objCase.Account.PersonEmail +
                        '","caseType": "'+objCase.Type +
                        '","caseStatus": "FailedUpload"}';
                }
                system.debug('---> BODY --> '+body);
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> Request --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                }
                else
                {
                    System.debug(response.getBody());
                }
            }
            else if(objCase.Origin == 'EKYC-FETCH')
            {
                if(objCase.eKYC_Decision__c == 'Manual Retry')
                {
                    body = '{"caseId": "'+objCase.Id +
                        '","email": "'+objCase.Account.PersonEmail +
                        '","caseType": "'+objCase.Type +
                        '","caseStatus": "ContinueFetch"}';
                }
                else if(objCase.eKYC_Decision__c == 'Convert to Identification Case')
                {
                    body = '{"caseId": "'+objCase.Id +
                        '","email": "'+objCase.Account.PersonEmail +
                        '","caseType": "'+objCase.Type +
                        '","caseStatus": "FailedFetch"}';
                }
                system.debug('---> BODY --> '+body);
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> Request --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                }
                else
                {
                    System.debug(response.getBody());
                }
            }
            else if(objCase.Origin == 'EKYC-SIGNOFF'){
                body = '{"caseId": "'+objCase.Id +
                    '","email": "'+objCase.Account.PersonEmail +
                    '","caseType": "'+objCase.Type +
                    '","caseStatus": "ContinueSignOff"}';
                
                system.debug('---> BODY --> '+body);
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> Request --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                }
                else
                {
                    System.debug(response.getBody());
                }
            }
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    /////////////////////////// Credit Card Request - Cases API ////////////////////////////////////
    @future(callout=true)
    public static void CCCaseCreation(Set<Id> setCaseId)
    {
        System.debug('Case ID :'+setCaseId);
        List<Case> lstUpdateCase = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        //CH36: Start
        List<World_Elite_Entitlement__c> lstWorldEntitCase = new List<World_Elite_Entitlement__c>();
        //CH36: END
        Integer cardProductConfigurationIdString;
        String cardDisplayNameString = '';
        Map<String, Object> resultsForWorklog = new Map<String, Object>();
        //CH05 : add the field "cc_Activate_Reminders_for_Pending_Cases__c" on the soql query
        //CH11 : Added AccountId,Account.ID_Type__pc,Account.ID_Number__pc,Account.ID_Expiry_Date__pc,cc_CPR_Number__c,cc_CPR_Expiry_Date__c in SOQL Query
        //CH14 : ADD Case_Model__c to soql query
        //CH28 : Added Has_Co_Brand_Membership_Number__c,Is_Balance_Transfer__c in SOQL Query
        //CH32 : Added Account.iGA_Passport_Number__pc,cc_Passport_Number__c in SOQL Query
        //CH35 : Added Issuing_card_for_a_spouse__c,Spouse_CIF__c  in SOQL Query
        //CH43 : Commented cc_Activate_Reminders_for_Pending_Cases__c  in SOQL Query
        List<Case> lstCase = [Select id, AccountId,Account.ID_Type__pc,Account.x_canary__pc,Account.ID_Number__pc,Account.ID_Expiry_Date__pc,Account.iGA_Passport_Number__pc,cc_Passport_Number__c,cc_CPR_Number__c,cc_CPR_Expiry_Date__c, status, Sub_Status__c, Type, Sub_Type__c, 
                              cc_Requested_Card_Type__c, Customer_Segment__c,Customer_CIF__c, cc_Name_on_the_Card__c, Origin, Account.PersonEmail, Account.CIF__pc,cc_Credit_Card_PCI_Number__c,cc_CC_Application_Source__c,/*cc_Activate_Reminders_for_Pending_Cases__c,*/ 
                              PrimaryCardProductConfigurationId__c, PrimaryCard__c, sc_Card_Holder_Mobile_No__c, sc_Card_Holder_Email_Address__c, sc_Relationship__c, Region_Flag__c,Case_Model__c,cc_Request_Type__c,cc_Temporary_Limit_Increase_Duration__c,
                              cc_Temporary_Limit_Increase_Expiry_Date__c,cc_Reminder_Triggered__c,Has_Co_Brand_Membership_Number__c,Is_Balance_Transfer__c,cc_Approved_Embossing_line_4__c,Issuing_card_for_a_spouse__c,Spouse_CIF__c,
                              Send_OTP_Notifications_To__c, Send_Transaction_Notifications_To__c from Case where id in: setCaseId];
        System.debug('CASE LIST:'+lstCase);
        for(Case objCase : lstCase)
        {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //CH14 -Start:  
            String regionName = objCase.Region_Flag__c;    
            if(objCase.Case_Model__c == 'alburaq'){    
                regionName += '_alburaq';  
            }
            //CH19: Start
            //request = con.createRequest('GET', '/api/v1/credit-cards?', regionName ); 
            request = con.createRequest('GET', System.Label.CC_EndPointGetCreditCards, regionName ); 
            //CH19: END
            //CH14 -End:
            //request = con.createRequest('GET', '/api/v1/credit-cards?', objCase.Region_Flag__c);
            System.debug('Person Email :'+objCase.Account.PersonEmail);
            System.debug('Customer ID :'+objCase.Account.CIF__pc);
            //System.debug('Case ID :'+setCaseId);
            
            request.setHeader('userId', objCase.Account.PersonEmail);
            request.setHeader('customerId', objCase.Account.CIF__pc);
            if(objCase.Account.x_canary__pc != null){
                request.setHeader('x-canary', objCase.Account.x_canary__pc);//CH22
            }
            request.setTimeOut(120000);
            system.debug('---> Request --> '+request.getBody());
            HttpResponse response = http.send(request);
            system.debug('---> Responce New --> '+response.getBody());
            
            if (response.getStatusCode() != 200)
            {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                //CH29: Added isAPIFailed parameter in the method
                lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo','GET',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                
            }
            else
            {
                System.debug(response.getBody());
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                System.debug('---> MAP m --> '+m);  // meta, data
                System.debug('---> MAP m VALUES --> '+m.Values());
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                System.debug('---> MAP m1 --> '+m1);  // currentCards,pendingCards,cardOptions
                List<Object> m2 = (List<Object>)m1.get('cardOptions');
                System.debug('---> LIST m2 --> '+m2);
                
                List<Map<String, Object>> a = new List<Map<String, Object>> ();
                
                for(Object obj : m2)
                {
                    a.add((Map<String, Object>)obj);
                    {
                        system.debug('---->> OBJ Iterations --> '+obj);
                    }
                }
                system.debug('---->> FINALL aaaa --> '+a);
                
                for(Map<String, Object> map1 : a)
                {
                    if(map1.get('productMappingCode')== objCase.cc_Requested_Card_Type__c)
                    {
                        system.debug('---> FINALL 1111 --> '+(Integer)map1.get('cardProductConfigurationId'));
                        cardProductConfigurationIdString = (Integer)map1.get('cardProductConfigurationId');
                        system.debug('---> FINALL cardProductConfigurationId --> '+cardProductConfigurationIdString);
                    }
                }
            }
            String body ='';
            Http http1 = new Http();
            HttpRequest request1 = new HttpRequest();
            //CH14 : replace param "objCase.Region_Flag__c" with "regionName"
            //CH19: Start
            //request1 = con.createRequest('PUT', '/api/v1/credit-cards/request?', regionName);
            request1 = con.createRequest('PUT', System.Label.CC_EndPointCreditCardRequest, regionName);
            if(objCase.Account.x_canary__pc != null){
                request1.setHeader('x-canary', objCase.Account.x_canary__pc);//CH22
            }


            //CH19: END
            if(objCase.Sub_Status__c == 'In-Progress'){
                system.debug('--> Check inside In Progress --> ');
                //CH28: Start
                if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card' && objCase.cc_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                    if(objCase.cc_Name_on_the_Card__c !=null){
                        body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","status":"IN_PROGRESS"}';
                    }
                    else{
                        body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            ',"status":"IN_PROGRESS"}';
                    }
                }
                //CH30: Start
                if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card' && objCase.cc_Name_on_the_Card__c !=null && objCase.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                    //CH35: Start
                    if(objCase.cc_Approved_Embossing_line_4__c != null){
                        body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                            '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +
                            '","issuedForSpouse": "'+objCase.Issuing_card_for_a_spouse__c +
                            '","spouseCIF": "'+objCase.Spouse_CIF__c +
                            '","status":"IN_PROGRESS"}';
                    }
                    else if(objCase.cc_Approved_Embossing_line_4__c == null){
                        body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                            '","issuedForSpouse": "'+objCase.Issuing_card_for_a_spouse__c +
                            '","spouseCIF": "'+objCase.Spouse_CIF__c +
                            '","membershipNumber": null,"status":"IN_PROGRESS"}';
                    }
                    //CH35: END
                }
                if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card' && objCase.cc_Name_on_the_Card__c ==null && objCase.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                    //CH35: Start
                    if(objCase.cc_Approved_Embossing_line_4__c != null){
                         body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                            '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +
                            '","issuedForSpouse": "'+objCase.Issuing_card_for_a_spouse__c +
                            '","spouseCIF": "'+objCase.Spouse_CIF__c +
                            '","status":"IN_PROGRESS"}';
                    }
                    else if(objCase.cc_Approved_Embossing_line_4__c == null){
                        body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                            '","issuedForSpouse": "'+objCase.Issuing_card_for_a_spouse__c +
                            '","spouseCIF": "'+objCase.Spouse_CIF__c +
                            '","membershipNumber": null,"status":"IN_PROGRESS"}';
                    }
                    //CH35: END
                }
                //CH30: END
                //CH28: END
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_CC_Application_Source__c == 'Manual' && objCase.cc_Request_Type__c=='permanent'){
                    if(objCase.cc_Name_on_the_Card__c !=null){
                        body = '{"pciNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS"}';
                    }
                    else{
                        body = '{"pciNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS"}';
                    }
                }
                /*#CH21# Start*/
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_CC_Application_Source__c == 'Manual' && objCase.cc_Request_Type__c=='temporary'){
                    if(objCase.cc_Name_on_the_Card__c !=null){
                        body = '{"pciNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                    }
                    else{
                        body = '{"pciNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                    }
                }
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase'  && objCase.cc_CC_Application_Source__c == 'API' && objCase.cc_Request_Type__c=='permanent'){
                    if(objCase.cc_Name_on_the_Card__c !=null){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS"}';
                    }
                    else{
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS"}';
                    }
                }
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase'  && objCase.cc_CC_Application_Source__c == 'API' && objCase.cc_Request_Type__c=='temporary'){
                    if(objCase.cc_Name_on_the_Card__c !=null){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                    }
                    else{
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                    }
                }
                /*#CH21# End*/
                
                if(objCase.Type == 'Credit Card Supplementary Application' && objCase.Sub_Type__c == 'New Supplementary Card'){
                    if(objCase.cc_Name_on_the_Card__c !=null){
                        body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","targetType": "SUPPLEMENTARY_CARD","status":"IN_PROGRESS"}';
                    }
                    else{
                        body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","targetType": "SUPPLEMENTARY_CARD","status":"IN_PROGRESS"}';
                    }
                }
                system.debug('---> BODY --> '+body);               
                request1.setBody(body);
                request1.setHeader('userId', objCase.Account.PersonEmail);
                request1.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> Request --> '+request1.getBody());
                HttpResponse response1 = http1.send(request1);
                system.debug('---> Responce New --> '+response1.getBody());
                
                if (response1.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response1.getStatusCode() + ' ' + response1.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request1.getBody(),response1.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                }
                else
                {
                    System.debug(response1.getBody());
                    //Start : NBA-8386
                    if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_CC_Application_Source__c == 'Manual'){
                        Decimal currentCreditLimit;
                        Map<String, Object> parsedResponse = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                        Map<String, Object> data11 = (Map<String, Object>)parsedResponse.get('data');
                        currentCreditLimit = (Decimal) data11.get('currentCreditLimit');
                        if(currentCreditLimit != null){objCase.cc_Current_Credit_Limit__c = currentCreditLimit;}                        
                    }
                    //End : NBA-8386
                    
                    //CH36: Start
                    if(System.Label.ILA_WORLD_ENTITLEMENT_ENABLE.equalsIgnoreCase('true') && objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card' && (objCase.cc_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01' || objCase.cc_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_02')){
                          World_Elite_Entitlement__c wtlToInsert = CreateWorldEliteEntitCase.createWorldEntitlementCase(objCase.Account, objCase);
                    	  lstWorldEntitCase.add(wtlToInsert);
                    }
                    //CH36: END
                }
            }
            else if(objCase.Sub_Status__c == 'Pending'){
                system.debug('--> Check Inside pending --> ');
                //CH28: Start
                if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card' && objCase.cc_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                    if(objCase.cc_Name_on_the_Card__c !=null){
                        body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","status":"PENDING"}';
                    }
                    else{
                        body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            ',"status":"PENDING"}';
                    }  
                }
                //CH30: Start
                if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card' && objCase.cc_Name_on_the_Card__c !=null && objCase.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                    //CH35: Start
                    if(objCase.cc_Approved_Embossing_line_4__c != null){
                        body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                             '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                            '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +
                            '","issuedForSpouse": "'+objCase.Issuing_card_for_a_spouse__c +
                            '","spouseCIF": "'+objCase.Spouse_CIF__c +
                            '","status":"PENDING"}';
                    }
                    else if(objCase.cc_Approved_Embossing_line_4__c == null){
                        body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                             '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                             '","issuedForSpouse": "'+objCase.Issuing_card_for_a_spouse__c +
                             '","spouseCIF": "'+objCase.Spouse_CIF__c +
                             '","membershipNumber": null,"status":"PENDING"}';
                    } 
                    //CH35: END 
                }
                if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card' && objCase.cc_Name_on_the_Card__c == null && objCase.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                    //CH35: Start
                    if(objCase.cc_Approved_Embossing_line_4__c != null){
                         body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                            '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +
                            '","issuedForSpouse": "'+objCase.Issuing_card_for_a_spouse__c +
                            '","spouseCIF": "'+objCase.Spouse_CIF__c +
                            '","status":"PENDING"}';
                    }
                    else if(objCase.cc_Approved_Embossing_line_4__c == null){
                        body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                            '","issuedForSpouse": "'+objCase.Issuing_card_for_a_spouse__c +
                            '","spouseCIF": "'+objCase.Spouse_CIF__c +
                            '","membershipNumber": null,"status":"PENDING"}';
                    }
                    //CH35: END
                }
                //CH30: END
                //CH28: END
                /*#CH21# Start*/
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_CC_Application_Source__c == 'Manual' && objCase.cc_Request_Type__c=='permanent'){
                    if(objCase.cc_Name_on_the_Card__c !=null){
                        body = '{"pciNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","targetType": "LIMIT_INCREASE","status":"PENDING"}';
                    }
                    else{
                        body = '{"pciNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","targetType": "LIMIT_INCREASE","status":"PENDING"}';
                    } 
                }
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_CC_Application_Source__c == 'Manual' && objCase.cc_Request_Type__c=='temporary'){
                    if(objCase.cc_Name_on_the_Card__c !=null){
                        body = '{"pciNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","targetType": "LIMIT_INCREASE","status":"PENDING","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                    }
                    else{
                        body = '{"pciNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","targetType": "LIMIT_INCREASE","status":"PENDING","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                    } 
                }
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_CC_Application_Source__c == 'API' && objCase.cc_Request_Type__c=='permanent'){
                    if(objCase.cc_Name_on_the_Card__c !=null){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","targetType": "LIMIT_INCREASE","status":"PENDING"}';
                    }
                    else{
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","targetType": "LIMIT_INCREASE","status":"PENDING"}';
                    } 
                }
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_CC_Application_Source__c == 'API' && objCase.cc_Request_Type__c=='temporary'){
                    if(objCase.cc_Name_on_the_Card__c !=null){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","targetType": "LIMIT_INCREASE","status":"PENDING","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                    }
                    else{
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","targetType": "LIMIT_INCREASE","status":"PENDING","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                    } 
                }
                
                
                
                /*#CH21# End*/
                if(objCase.Type == 'Credit Card Supplementary Application' && objCase.Sub_Type__c == 'New Supplementary Card'){
                    //CH06 : use stringApiFormat function
    body = '{"crmCaseId":"' + objCase.Id +
        '","cardProductConfigurationId":' + SM001_ApiCalls.stringApiFormat(objCase.PrimaryCardProductConfigurationId__c) +
        ',"pciNumber":' + SM001_ApiCalls.stringApiFormat(objCase.PrimaryCard__c) +
        ',"embossName":' + SM001_ApiCalls.stringApiFormat(objCase.cc_Name_on_the_Card__c) +
        ',"supplementaryCard":{' +
        '"mobile":"' + objCase.sc_Card_Holder_Mobile_No__c +
        '","email":"' + objCase.sc_Card_Holder_Email_Address__c +
        '","relationship":"' + objCase.sc_Relationship__c +
        '","enableSpendingLimit":false';
    
    // Add ONLY for Bahrain
    if (objCase.Region_Flag__c == 'Bahrain') {
        body +=
            ',"sendOTPNotificationsTo":' + SM001_ApiCalls.stringApiFormat(objCase.Send_OTP_Notifications_To__c) +
            ',"sendTransactionsNotificationsTo":' + SM001_ApiCalls.stringApiFormat(objCase.Send_Transaction_Notifications_To__c) +
            ',"cardHolderMobileNumber":' + SM001_ApiCalls.stringApiFormat(objCase.sc_Card_Holder_Mobile_No__c) +
            ',"cardHolderEmail":' + SM001_ApiCalls.stringApiFormat(objCase.sc_Card_Holder_Email_Address__c);
    }
    
    body += '},' +
        '"creditLimit": 0' +
        ',"targetType": "SUPPLEMENTARY_CARD","status":"PENDING"}';
                }
                system.debug('---> BODY --> '+body);               
                request1.setBody(body);
                request1.setHeader('userId', objCase.Account.PersonEmail);
                request1.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request1 --> '+request1.getBody());
                HttpResponse response1 = http1.send(request1);
                
                if (response1.getStatusCode() != 200) 
                {
                    System.debug('The status code returned was not expected: ' + response1.getStatusCode() + ' ' + response1.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request1.getBody(),response1.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                }
                else
                {
                    
                    System.debug(response1.getBody());
                    //Start : NBA-8386
                    if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_CC_Application_Source__c == 'Manual'){
                        Decimal currentCreditLimit;
                        Map<String, Object> parsedResponse = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                        Map<String, Object> data11 = (Map<String, Object>)parsedResponse.get('data');
                        currentCreditLimit = (Decimal) data11.get('currentCreditLimit');
                        if(currentCreditLimit != null){objCase.cc_Current_Credit_Limit__c = currentCreditLimit;}                        
                    }
                    //End : NBA-8386

                    //CH36: Start
                    if(System.Label.ILA_WORLD_ENTITLEMENT_ENABLE.equalsIgnoreCase('true') && objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card' && (objCase.cc_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01' || objCase.cc_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_02')){
                          World_Elite_Entitlement__c wtlToInsert = CreateWorldEliteEntitCase.createWorldEntitlementCase(objCase.Account, objCase);
                    	  lstWorldEntitCase.add(wtlToInsert);
                    }
                    //CH36: END
                }
            }
            //CH11: Start
            System.debug('Case Type App or Quick Action:'+objCase.Type);
            if(objCase.Type == 'Credit Card Application' || objCase.Type == 'Credit Limit Increase Application'){
                System.debug('Account Id Type:'+objCase.Account.ID_Type__pc);
                if(objCase.Account.ID_Type__pc == 'Bahraini ID'){
                    objCase.cc_CPR_Number__c = objCase.Account.ID_Number__pc;
                    objCase.cc_CPR_Expiry_Date__c = objCase.Account.ID_Expiry_Date__pc;
                    //CH12: Start
                    objCase.PrimaryCardProductConfigurationId__c = String.valueOf(cardProductConfigurationIdString);
                    //CH12: END
                    //CH32: Start
                    objCase.cc_Passport_Number__c = objCase.Account.iGA_Passport_Number__pc;
                    //CH32: END
                    lstUpdateCase.add(objCase);
                }
                //CH12: Start
                else{
                    objCase.PrimaryCardProductConfigurationId__c = String.valueOf(cardProductConfigurationIdString);
                    //CH32: Start
                    objCase.cc_Passport_Number__c = objCase.Account.iGA_Passport_Number__pc;
                    //CH32: END
                    lstUpdateCase.add(objCase);
                }
                //CH12: END
            }
            //CH11: END
        }
        if(lstUpdateCase.size()>0){
            System.debug('List Upsert:'+lstUpdateCase);
            upsert lstUpdateCase;
        }
        if(lstSA.size()>0)
            insert lstSA;
        if(lstWorldEntitCase.size()>0){
            insert lstWorldEntitCase;
        }
    }
    
    @future(callout=true)
    public static void CCCaseUpdate(Set<Id> setCaseId)
    {
        system.debug('setCaseId SIZE:'+setCaseId.size());
        List<Case> lstUpdateCase = new List<Case>();
        //CH28: Start
        List<Case> lstPremiumInvitationCaseToInsert = new List<Case>();
        //CH28: END
        //CH43: Start
        Set<Id> setUpgradeCaseToInsert = new Set<Id>();
        //CH43: END
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Supplementary_Card__c> lstSuppCard = new List<Supplementary_Card__c>();
        // String cardProductConfigurationIdString = '';
        Integer ApprovedCardProductConfigurationId;
        String cardDisplayNameString = '';
        //CH08: Start
        Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
        //CH08: END
        //CH01: Start #Jahangeer Mohammed# Added Approved Balance Transfer Amount, Approved Request Card Type, Operations Result,Signature Verifier Result, Approved Transfer Type,Service Center Result in SOQL
        //CH08: Start #Jahangeer Mohammed# Added RecordTypeId field in SOQL.
        //CH14: Start #Hamza chaoui# Added Case_Model__c field in SOQL.
        //CH15: Added Campaign Name, Approved Campaign Name in SOQL by #Jahangeer Mohammed# #15-08-2022#
        //CH16: Added Customer Response in the SOQL by #Jahangeer Mohammed# #15-09-2022#
        //CH23: Added Fraud Result in the SOQL
        //CH27: Added LastModifiedBy.Name in the SOQL
        //CH28: Added Is_Balance_Transfer__c,Has_Co_Brand_Membership_Number__c,Account.FirstName, Account.LastName in the SOQL
        //CH31: Added Reapplying_Restriction_Period__c in the SOQL
        //CH35: Added Issuing_card_for_a_spouse__c,Spouse_CIF__cin the SOQL
        //CH39: Added ContactId,bs_Instrument_ID__c,Resend_DocuSign__c in the SOQL
        //CH40: added ,account.PersonContactId
        //CH43: Added Is_Initiated_from_Upgrade_Case__c,Target_Upgrade_Credit_Card_Type__c in the SOQL
        List<Case> lstCase = [Select id,Account.x_canary__pc,cc_Credit_Card_PCI_Number__c, status, Sub_Status__c,RecordTypeId, Type, Sub_Type__c, cc_Requested_Card_Type__c, Customer_Segment__c, Customer_CIF__c, cc_Name_on_the_Card__c, cc_Approved_Credit_Limit__c,Origin, Account.PersonEmail, Account.CIF__pc, cc_Credit_Approval_Result__c, cc_Credit_Evaluation_Result__c, cc_Credit_Verification_Result__c, cc_Business_Approval_Result__c, cc_Credit_Approval_Result_Date_Time__c, cc_Application_Stages__c, 
                              cc_Approved_Balance_Transfer_Amount__c,Is_Doc_Dicrepancy__c,cc_Approved_Requested_Card_Type__c,cc_Approved_Transfer_Type__c,cc_Approved_Name_on_the_card__c,cc_Approved_Embossing_line_4__c,cc_Signature_Verifier_Result__c,cc_Service_Centre_Result__c,cc_Operations_Result__c,cc_HR_Result__c, cc_HR_Result_Date_Time__c, cc_Business_Approval_Result_Date_Time__c, cc_Credit_Evaluation_Result_Date_Time__c, cc_Credit_Verification_Result_Date_Time__c, cc_Credit_Pre_Screening_Result__c, cc_Credit_Pre_Screening_Result_Date_Time__c,Account.Segment__pc, cc_Maker__c,
                              Account.Nationality__pc,cc_CEO_Result__c,sc_Spending_Limit_Amount__c,sc_Relationship__c, sc_Card_Holder_First_Name__c, sc_Card_Holder_Last_Name__c, sc_Card_Holder_Date_of_Birth__c, sc_Card_Holder_Email_Address__c,cc_Balance_Transfer_Reference_Number__c,cc_isDocumentReceived__c,Fraud_Results__c,
                              Campaign_Name__c,Approved_Campaign_Name__c,sc_Card_Holder_Mobile_No__c, sc_Card_Holder_Gender__c, sc_Card_Holder_ID_Number__c, cc_ID_Expiry_Date__c, sc_Card_Holder_Nationality__c, cc_Embossing_Line_4__c, cc_Is_Doc_Uploaded__c, cc_Is_Doc_Uploaded_For_Dicrepancy__c,PrimaryCardProductConfigurationId__c, PrimaryCard__c, CaseNumber,sc_Card_Holder_ID_Expiry_Date__c,cc_PCI_Id__c, Region_Flag__c,cc_Customer_Response__c,Case_Model__c ,cc_Request_Type__c,cc_Temporary_Limit_Increase_Duration__c,cc_Temporary_Limit_Increase_Expiry_Date__c,cc_Reminder_Triggered__c,
                              cc_Requested_Credit_Limit__c,LastModifiedBy.Name,Is_Balance_Transfer__c,Has_Co_Brand_Membership_Number__c,Account.FirstName, Account.LastName,Reapplying_Restriction_Period__c,Issuing_card_for_a_spouse__c,Spouse_CIF__c,ContactId,bs_Instrument_ID__c,Resend_DocuSign__c,account.PersonContactId,Is_Initiated_from_Upgrade_Case__c,Target_Upgrade_Credit_Card_Type__c FROM Case where Id In: setCaseId];
        
        //CH01: END
        //Get the queue label for the assignment depending on the region flag
        List<Queue_IDs__mdt> queueIds = [SELECT Id, DeveloperName, Label, Queue_ID__c, MasterLabel, Queue_Name__c, Region__c FROM Queue_IDs__mdt];
        Map<Id, String> caseToRegion = Util.getQueuesCustomMetadata(lstCase);
        //CH31: Start
        List<Account> accListToUpdateRestrictCreditCard = new List<Account>();
        //CH31: END
        
        System.debug('Case List:'+lstCase);
        for(Case objCase : lstCase)
        {
            //CH08: Start
            string recordtypeName = rt_Map.get(objCase.RecordTypeId).getName();
            //CH08: END
            String body = '';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //CH14 -Start: 
            String regionName = objCase.Region_Flag__c; 
            if(objCase.Case_Model__c == 'alburaq'){ 
                regionName += '_alburaq';   
            } 
            //CH19: Start
            //request = con.createRequest('PUT', '/api/v1/credit-cards/request?', regionName); 
            request = con.createRequest('PUT', System.Label.CC_EndPointCreditCardRequest, regionName);
            if(objCase.Account.x_canary__pc != null){
                request.setHeader('x-canary', objCase.Account.x_canary__pc); //CH22
            }
            
            system.debug(' New Test Payload --->' +request);
            //CH19: END
            //CH14 -End:
            //  request = con.createRequest('PUT', '/api/v1/credit-cards/request?', objCase.Region_Flag__c);
            System.debug('Pre screening result value in Future Methods:'+objCase.cc_Credit_Pre_Screening_Result__c);
            System.debug('HR Approve Result:'+objCase.cc_HR_Result__c);
            //CH23: Added a condition Fraud Result != Decline and Fraud Result != Cancelled by Customer in if condition
            //CH25: Added a condition Signature Verifier Result != Decline and Signature Verifier Result != Cancelled by Customer in if condition
            if(objCase.Sub_Status__c == 'Pending' && objCase.cc_Credit_Approval_Result__c != 'Approve' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Expired' && objCase.cc_Business_Approval_Result__c != 'Approve' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_Credit_Evaluation_Result__c != 'Rejected' && objCase.cc_Credit_Verification_Result__c != 'Decline' 
               && objCase.cc_CEO_Result__c != 'Decline' && objCase.cc_Maker__c !='Decline' && objCase.cc_CEO_Result__c!= 'Accept' && objCase.cc_Credit_Pre_Screening_Result__c !='Cancelled by Customer' && objCase.cc_Credit_Evaluation_Result__c !='Cancelled by Customer' && objCase.cc_Credit_Verification_Result__c !='Cancelled by Customer' && objCase.cc_Credit_Approval_Result__c  !='Cancelled by Customer' && objCase.cc_HR_Result__c !='Cancelled by Customer' 
               && objCase.cc_Maker__c !='Cancelled by Customer' && objCase.Fraud_Results__c != 'Decline' && objCase.Fraud_Results__c != 'Cancelled by Customer' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer'){
                
                if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){
                    if(objCase.cc_Name_on_the_Card__c !=null){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","status":"PENDING"}';
                    }
                    else{
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            ',"status":"PENDING"}';
                    }
                }
                /*#CH21# Start*/
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='permanent'){
                    if(objCase.cc_Name_on_the_Card__c !=null){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","targetType": "LIMIT_INCREASE","status":"PENDING" }';
                    }
                    else{
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","targetType": "LIMIT_INCREASE","status":"PENDING"}';
                    }
                }
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='temporary'){
                    if(objCase.cc_Name_on_the_Card__c !=null){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","targetType": "LIMIT_INCREASE","status":"PENDING","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                    }
                    else{
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","targetType": "LIMIT_INCREASE","status":"PENDING","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                    }
                }
                /*#CH21# End*/
                if(objCase.Type == 'Credit Card Supplementary Application' && objCase.Sub_Type__c == 'New Supplementary Card'){
                    //CH07: Start
                    if(objCase.cc_Name_on_the_Card__c !=null){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                            '","targetType": "SUPPLEMENTARY_CARD","status":"PENDING" }';
                    }
                    //CH07: END
                    else{
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","targetType": "SUPPLEMENTARY_CARD","status":"PENDING"}';
                    }
                }
                system.debug('---> BODY --> '+body);
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                }
                else
                {
                    System.debug(response.getBody());
                }
            }
            //CH03 : Commented the Pre-screening Result Condition by Jahangeer Mohammed.
            //CH23: Added a condition Fraud Result != Decline and Fraud Result != Cancelled by Customer in if condition
            //CH25: Added a condition Signature Verifier Result != Decline and Signature Verifier Result != Cancelled by Customer in if condition
            else if(((objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card') || (objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase')) && objCase.Sub_Status__c == 'In-Progress' && objCase.cc_Credit_Approval_Result__c != 'Approve' && objCase.cc_Credit_Approval_Result__c != 'Decline' /*&& objCase.cc_Credit_Pre_Screening_Result__c != 'Accept'*/ && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Expired' && 
                    objCase.cc_HR_Result__c != 'Approved' && objCase.cc_HR_Result__c != 'Decline' /*&& objCase.cc_Business_Approval_Result__c != 'Approve'*/ && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_Credit_Evaluation_Result__c != 'Rejected' && objCase.cc_Credit_Evaluation_Result__c != 'Decline' && objCase.cc_Credit_Verification_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Accept' && objCase.cc_Credit_Pre_Screening_Result__c !='Cancelled by Customer' && 
                    objCase.cc_Credit_Evaluation_Result__c !='Cancelled by Customer' && objCase.cc_Credit_Verification_Result__c !='Cancelled by Customer' && objCase.cc_Credit_Approval_Result__c  !='Cancelled by Customer' && objCase.cc_HR_Result__c !='Cancelled by Customer' && objCase.Fraud_Results__c != 'Decline' && objCase.Fraud_Results__c != 'Cancelled by Customer' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer'){
                if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){
                    //CH15: Start
                    if(objCase.cc_Credit_Pre_Screening_Result__c == 'Accept' && objCase.cc_Credit_Evaluation_Result__c != 'Accept' && objCase.cc_Credit_Verification_Result__c != 'Approve'){
                        //CH12: Start
                        //CH26: Start
                        if(objCase.Campaign_Name__c != null){
                            body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","campaignId": "'+objCase.Campaign_Name__c +
                            '","status":"IN_PROGRESS"}';
                        }
                        else if(objCase.Campaign_Name__c == null){
                            System.debug('Campaign Name is Blank');
                            body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","campaignId": null,"status":"IN_PROGRESS"}';
                        }
                        //CH26: END
                        //CH12: END
                        system.debug('---> BODY IN_PROGRESS WHEN PRE_SCREENER ACCEPTS IN CREDIT CARD APPLICATION --> '+body);               
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request IN_PROGRESS WHEN PRE_SCREENER ACCEPTS IN CREDIT CARD APPLICATION --> '+request.getBody());
                        HttpResponse response = http.send(request);
                        if (response.getStatusCode() != 200)
                        {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH29: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                        }
                        else
                        {
                            System.debug(response.getBody());
                            Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                            Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                            //CH26: Start
                            if(dataMap.containsKey('campaign')){
                                Map<String, Object> dataMapCampaign = (Map<String, Object>)dataMap.get('campaign');
                                System.debug('Data Map Inside Campaign array:'+dataMapCampaign);
                                String campaignName = String.valueOf(dataMapCampaign.get('id'));
                                String campaignValidity = String.valueOf(dataMapCampaign.get('validity'));
                                System.debug('Campaign Name from API:'+campaignName);
                                System.debug('Campaign Validity from API:'+campaignValidity);
                                objCase.Campaign_Name__c = campaignName;
                                objCase.Campaign_Validity__c = campaignValidity; 
                            }
                            //CH26: END
                            lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',false);

                            lstUpdateCase.add(objCase);
                        }
                    }
                    else if(objCase.cc_Credit_Pre_Screening_Result__c == 'Accept' && objCase.cc_Credit_Evaluation_Result__c == 'Accept' && objCase.cc_Credit_Verification_Result__c != 'Approve'){
                        //CH12: Start
                        //CH26:Start
                        if(objCase.Approved_Campaign_Name__c != null){
                            body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","campaignId": "'+objCase.Approved_Campaign_Name__c +
                            '","status":"IN_PROGRESS"}';
                        }
                        else if(objCase.Approved_Campaign_Name__c == null){
                             body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","campaignId": null,"status":"IN_PROGRESS"}';
                        }
                       //CH26: END
                        //CH12: END
                        system.debug('---> BODY IN_PROGRESS WHEN EVALUATOR ACCEPTS IN CREDIT CARD APPLICATION --> '+body);               
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request IN_PROGRESS WHEN EVALUATOR ACCEPTS IN CREDIT CARD APPLICATION --> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if (response.getStatusCode() != 200)
                        {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH29: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                        }
                        else
                        {
                            System.debug(response.getBody());
                        }
                    }
                    else if(objCase.cc_Credit_Pre_Screening_Result__c == 'Accept' && objCase.cc_Credit_Evaluation_Result__c == 'Accept' && objCase.cc_Credit_Verification_Result__c == 'Approve'){
                        //CH12: Start
                        //CH26: Start
                        if(objCase.Approved_Campaign_Name__c != null){
                            body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","campaignId": "'+objCase.Approved_Campaign_Name__c +
                            '","status":"IN_PROGRESS"}';
                        }
                        else if(objCase.Approved_Campaign_Name__c == null){
                            body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","campaignId": null,"status":"IN_PROGRESS"}';
                        }
                       //CH26: END
                        //CH12: END
                        system.debug('---> BODY IN_PROGRESS WHEN VERIFIER ACCEPTS IN CREDIT CARD APPLICATION --> '+body);               
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request IN_PROGRESS WHEN VERIFIER ACCEPTS IN CREDIT CARD APPLICATION --> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if (response.getStatusCode() != 200)
                        {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH29: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                        }
                        else
                        {
                            System.debug(response.getBody());
                        }
                    }
                    //CH15: END
                }
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase'){
                    
                    //CH12: Start
                    /*#CH21# Start*/
                    if(objCase.cc_Request_Type__c=='permanent'){
                        body = '{"crmCaseId": "'+objCase.Id + 
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS"}';
                    }else{
                        body = '{"crmCaseId": "'+objCase.Id +
                                '","creditLimit": "'+objCase.cc_Requested_Credit_Limit__c +
                                '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                '","targetType": "LIMIT_INCREASE","status":"APPROVED","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'","limitExpiryDate":"'+String.valueOf(System.today())+'"}';
                        
                    }
                    //CH12: END
                    /*#CH21# End*/
                    system.debug('---> BODY IN_PROGRESS --> '+body);               
                    request.setBody(body);
                    request.setHeader('userId', objCase.Account.PersonEmail);
                    request.setHeader('customerId', objCase.Account.CIF__pc);
                    
                    system.debug('---> request IN_PROGRESS--> '+request.getBody());
                    HttpResponse response = http.send(request);
                    
                    if (response.getStatusCode() != 200)
                    {
                        System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                        //CH29: Added isAPIFailed parameter in the method
                        lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                    }
                    else
                    {
                        If(objCase.cc_Request_Type__c=='temporary'){
                             System.debug('finalapproval##'+response.getBody());
                                Map<String,Object> results = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                                Map<String,Object> finalresult =(Map<String, Object>)results.get('data');
                                objCase.Status = 'Closed';
                                objCase.Sub_Status__c = 'Approved';
                                objCase.cc_Application_Stages__c = 'Completed';
                                objCase.cc_CRM_Stage__c = 'APPROVED';
                              //  objCase.OwnerId=System.Label.cc_prescreener;
                                objCase.cc_Temporary_Limit_Increase_Expiry_Date__c=objCase.cc_Request_Type__c=='temporary'?Date.ValueOf(String.valueOf(finalresult.get('limitExpiryDate'))):null;
                        lstUpdateCase.add(objCase);
                        }
                   
                        System.debug(response.getBody());
                    }
                } 
                
               
                system.debug('---> BODY IN_PROGRESS --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request IN_PROGRESS--> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                }
                else
                {
                    System.debug(response.getBody());
                }
            }
            //CH18: Start
            //CH25: Added a condition Signature Verifier Result != Decline and Signature Verifier Result != Cancelled by Customer in if condition
            else if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card' && objCase.Sub_Status__c == 'Follow Up' && objCase.cc_Credit_Approval_Result__c != 'Approve' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Expired' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Business_Approval_Result__c != 'Approve' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_Credit_Verification_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Accept' && 
                    objCase.cc_Credit_Pre_Screening_Result__c !='Cancelled by Customer' && objCase.cc_Credit_Evaluation_Result__c !='Cancelled by Customer' && objCase.cc_Credit_Verification_Result__c !='Cancelled by Customer' &&  objCase.cc_Credit_Approval_Result__c  !='Cancelled by Customer' && objCase.cc_HR_Result__c !='Cancelled by Customer' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer'){
                body = '{"crmCaseId": "'+objCase.Id +
                    '","status":"FOLLOW_UP"}';
                system.debug('---> BODY IN FOLLOW UP Condition --> '+body);
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                }
                else
                {
                    System.debug(response.getBody());
                }
            }
            //CH18: END
            
            //System.debug('Pre screening result value in Future Methods:'+objCase.cc_Credit_Pre_Screening_Result__c);
            //CH23: Added a condition Fraud Result != Decline and Fraud Result != Cancelled by Customer in if condition
            //CH25: Added a condition Signature Verifier Result != Decline and Signature Verifier Result != Cancelled by Customer in if condition
            else if(objCase.Sub_Status__c == 'Documents Received' && objCase.cc_Credit_Approval_Result__c != 'Approve' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Expired' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Business_Approval_Result__c != 'Approve' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_Credit_Evaluation_Result__c != 'Rejected' 
                    && objCase.cc_Credit_Verification_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Decline' &&  objCase.cc_Maker__c !='Decline' && objCase.cc_CEO_Result__c != 'Accept' && objCase.cc_Credit_Pre_Screening_Result__c !='Cancelled by Customer' && objCase.cc_Credit_Evaluation_Result__c !='Cancelled by Customer' && objCase.cc_Credit_Verification_Result__c !='Cancelled by Customer' && objCase.cc_Credit_Approval_Result__c  !='Cancelled by Customer' 
                    && objCase.cc_HR_Result__c !='Cancelled by Customer' && objCase.cc_Maker__c !='Cancelled by Customer' && objCase.Fraud_Results__c != 'Decline' && objCase.Fraud_Results__c != 'Cancelled by Customer' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer'){
                
                if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","status":"IN_PROGRESS"}';
                }
                //#CH21# START
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='permanent'){
                    body = '{"crmCaseId": "'+objCase.Id +                             
                        '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS"}';
                    //CH16: Start
                    if(objCase.cc_Customer_Response__c == 'Customer Not Responded'){
                        objCase.cc_Customer_Response__c = 'Customer Responded';
                        lstUpdateCase.add(objCase);
                    }
                    //CH16: END
                }
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='temporary'){
                    body = '{"pciNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +'","crmCaseId": "'+objCase.Id +                             
                        '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                    //CH16: Start
                    if(objCase.cc_Customer_Response__c == 'Customer Not Responded'){
                        objCase.cc_Customer_Response__c = 'Customer Responded';
                        lstUpdateCase.add(objCase);
                    }
                }
                //#CH21# END
                if(objCase.Type == 'Credit Card Supplementary Application' && objCase.Sub_Type__c == 'New Supplementary Card'){
                    body = '{"crmCaseId": "'+objCase.Id + 
                        '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                        '","targetType": "SUPPLEMENTARY_CARD","status":"IN_PROGRESS"}';
                }
                system.debug('---> BODY IN DOCS RECEIVED --> '+body);
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                }
                else
                {
                    System.debug(response.getBody());
                }
            }
            //CH23: Added a condition Fraud Result != Decline and Fraud Result != Cancelled by Customer in if condition
            //CH25: Added a condition Signature Verifier Result != Decline and Signature Verifier Result != Cancelled by Customer in if condition
            else if((objCase.Sub_Status__c == 'Referred by Evaluator' || objCase.Sub_Status__c == 'Referred by Approver' || objCase.Sub_Status__c == 'Referred  by Pre-Screener' || objCase.Sub_Status__c == 'Referred by Verifier' || objCase.Sub_Status__c == 'Referred by Maker' ) && objCase.cc_Credit_Approval_Result__c != 'Approve' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Evaluation_Result__c != 'Expired' /*&& objCase.cc_Business_Approval_Result__c != 'Approve'*/ && objCase.cc_Business_Approval_Result__c != 'Decline' 
                    && objCase.cc_Credit_Evaluation_Result__c != 'Rejected' && objCase.cc_Credit_Verification_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Expired' && objCase.cc_CEO_Result__c != 'Decline' && objCase.cc_Maker__c !='Decline' && objCase.cc_CEO_Result__c != 'Accept' && objCase.cc_Credit_Pre_Screening_Result__c !='Cancelled by Customer' && objCase.cc_Credit_Evaluation_Result__c !='Cancelled by Customer' && objCase.cc_Credit_Verification_Result__c !='Cancelled by Customer' && objCase.cc_Credit_Approval_Result__c  !='Cancelled by Customer' 
                    && objCase.cc_HR_Result__c !='Cancelled by Customer' && objCase.cc_Maker__c !='Send to Pre-Screener' && objCase.Fraud_Results__c != 'Decline' && objCase.Fraud_Results__c != 'Cancelled by Customer' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer'){
                if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){
                    if(objCase.Sub_Status__c == 'Referred by Evaluator' ){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","status":"REFERRED_BY_EVALUATOR"}';
                    }
                    else if(objCase.Sub_Status__c == 'Referred by Approver'){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","status":"REFERRED_BY_APPROVER"}';
                    }
                    else if(objCase.Sub_Status__c == 'Referred  by Pre-Screener'){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","status":"REFERRED_BY_PRESCREENER"}';
                    }
                    else if(objCase.Sub_Status__c == 'Referred by Verifier'){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","status":"REFERRED_BY_VERIFIER"}';
                    }
                }
                //#CH21#:START
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='permanent'){
                    if(objCase.Sub_Status__c == 'Referred by Evaluator' ){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "LIMIT_INCREASE","status":"REFERRED_BY_EVALUATOR"}';
                    }
                    else if(objCase.Sub_Status__c == 'Referred by Approver'){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "LIMIT_INCREASE","status":"REFERRED_BY_APPROVER"}';
                    }
                    else if(objCase.Sub_Status__c == 'Referred  by Pre-Screener'){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "LIMIT_INCREASE","status":"REFERRED_BY_PRESCREENER"}';
                    }
                    else if(objCase.Sub_Status__c == 'Referred by Verifier'){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "LIMIT_INCREASE","status":"REFERRED_BY_VERIFIER"}';
                    }
                }
                
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='temporary'){
                    if(objCase.Sub_Status__c == 'Referred by Evaluator' ){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "LIMIT_INCREASE","status":"REFERRED_BY_EVALUATOR","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                    }
                    else if(objCase.Sub_Status__c == 'Referred by Approver'){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "LIMIT_INCREASE","status":"REFERRED_BY_APPROVER","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                    }
                    else if(objCase.Sub_Status__c == 'Referred  by Pre-Screener'){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "LIMIT_INCREASE","status":"REFERRED_BY_PRESCREENER","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                    }
                    else if(objCase.Sub_Status__c == 'Referred by Verifier'){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "LIMIT_INCREASE","status":"REFERRED_BY_VERIFIER","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                    }
                }
                //#CH21#:END
                if(objCase.Type == 'Credit Card Supplementary Application' && objCase.Sub_Type__c == 'New Supplementary Card'){
                    if(objCase.Sub_Status__c == 'Referred by Maker' ){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "SUPPLEMENTARY_CARD","status":"REFERRED_BY_MAKER"}';
                    }
                }
                system.debug('---> BODY in REFER CONDITION --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                }
                else
                {
                    System.debug(response.getBody());
                }
            }
            ///////////////////////////////////////// SUPPLEMEMTARY MAKER/ PRE SCREENER - PENDING RELATIONSHIP //////////////////////////////////////////////////////////////////////
            
            else if((objCase.Type == 'Credit Card Supplementary Application' && objCase.Sub_Type__c == 'New Supplementary Card') && objCase.Sub_Status__c == 'Pending Relationship' && objCase.cc_Maker__c == 'Pending Relationship Establishment' && objCase.cc_Credit_Pre_Screening_Result__c != 'Accept' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Expired' && objCase.cc_Credit_Pre_Screening_Result__c !='Cancelled by Customer'){
                
                body = '{"crmCaseId": "'+objCase.Id +
                    '","targetType": "SUPPLEMENTARY_CARD","status":"PENDING_RELATIONSHIP"}';
                
                system.debug('---> SUPPLEMENTARY - MAKER PEnding Relationship --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200) 
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Supplementary Application', 'Credit Card',true);
                } 
                else 
                {
                    System.debug(response.getBody());
                }
            }
            
            else if((objCase.Type == 'Credit Card Supplementary Application' && objCase.Sub_Type__c == 'New Supplementary Card') && objCase.Sub_Status__c == 'In-Progress' && objCase.cc_Maker__c == 'Send to Pre-Screener' && objCase.cc_Credit_Pre_Screening_Result__c != 'Accept' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Expired' && objCase.cc_Credit_Pre_Screening_Result__c !='Cancelled by Customer'){
                //CH06 : use stringApiFormat function
                body = '{"crmCaseId": "'+objCase.Id +
                    '","cardProductConfigurationId":'+SM001_ApiCalls.stringApiFormat(objCase.PrimaryCardProductConfigurationId__c)+
                    ',"targetType": "SUPPLEMENTARY_CARD","status":"IN_PROGRESS"}';
                
                system.debug('---> SUPPLEMENTARY - MAKER Send to PRESCREENER --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200) 
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Supplementary Application', 'Credit Card',true);
                } 
                else 
                {
                    System.debug(response.getBody());
                }
            }
            
            else if((objCase.Type == 'Credit Card Supplementary Application' && objCase.Sub_Type__c == 'New Supplementary Card') && objCase.Sub_Status__c == 'Pending Relationship' && objCase.cc_Credit_Pre_Screening_Result__c == 'Pending Relationship Establishment' && objCase.cc_Credit_Pre_Screening_Result__c != 'Accept' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Expired' && objCase.cc_Credit_Pre_Screening_Result__c !='Cancelled by Customer' && objCase.cc_Maker__c != 'Refer to Service Center' && objCase.cc_Maker__c != 'Decline' && objCase.cc_Maker__c != 'Cancelled by Customer'  && objCase.cc_Maker__c != 'Pending Relationship Establishment' && objCase.cc_Maker__c !='Decline'){
                
                body = '{"crmCaseId": "'+objCase.Id +
                    '","targetType": "SUPPLEMENTARY_CARD","status":"PENDING_RELATIONSHIP"}';
                
                system.debug('---> SUPPLEMENTARY - PRESCREENER Pending Relationship --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200) 
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Supplementary Application', 'Credit Card',true);
                } 
                else 
                {
                    System.debug(response.getBody());
                }
            }
            
            else if((objCase.Type == 'Credit Card Supplementary Application' && objCase.Sub_Type__c == 'New Supplementary Card') && objCase.Sub_Status__c == 'Referred  by Pre-Screener' && objCase.cc_Credit_Pre_Screening_Result__c == 'Refer to Service Center' && objCase.cc_Credit_Pre_Screening_Result__c != 'Accept' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Expired' && objCase.cc_Credit_Pre_Screening_Result__c !='Cancelled by Customer' && objCase.cc_Maker__c != 'Refer to Service Center' && objCase.cc_Maker__c != 'Decline' && objCase.cc_Maker__c != 'Cancelled by Customer'  && objCase.cc_Maker__c != 'Pending Relationship Establishment'){
                
                body = '{"crmCaseId": "'+objCase.Id +
                    '","targetType": "SUPPLEMENTARY_CARD","status":"REFERRED_BY_PRESCREENER"}';
                
                system.debug('---> SUPPLEMENTARY - PRESCREENER REFER TO SC --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200) 
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Supplementary Application', 'Credit Card',true);
                } 
                else 
                {
                    System.debug(response.getBody());
                }
            }
            //#CH17 : add " || objCase.cc_Maker__c == 'Accept' "
            else if((objCase.Type == 'Credit Card Supplementary Application' && objCase.Sub_Type__c == 'New Supplementary Card')  && (objCase.cc_Credit_Pre_Screening_Result__c == 'Accept' || objCase.cc_Maker__c == 'Accept') && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Expired' && objCase.cc_Credit_Pre_Screening_Result__c !='Cancelled by Customer'  && objCase.cc_Maker__c != 'Decline' && objCase.cc_Maker__c != 'Cancelled by Customer'  && objCase.cc_Maker__c != 'Pending Relationship Establishment' && objCase.cc_Maker__c != 'Refer to Service Center'){
                
                objCase.Sub_Status__c = 'In-Progress';
                //CH07 : Added Approved Name on the Card by #Jahangeer Mohammed# #17-01-2022#
                Supplementary_Card__c objSuppCard = new Supplementary_Card__c(
                    Status__c = 'In Progress',
                    Primary_Customer__c = objCase.AccountId,
                    Related_Case__c = objCase.Id,
                    Relationship__c = objCase.sc_Relationship__c,
                    Card_Holder_First_Name__c = objCase.sc_Card_Holder_First_Name__c,
                    Card_Holder_Last_Name__c = objCase.sc_Card_Holder_Last_Name__c,
                    Card_Holder_Date_of_Birth__c = objCase.sc_Card_Holder_Date_of_Birth__c,
                    Card_Holder_Email__c = objCase.sc_Card_Holder_Email_Address__c,
                    Card_Holder_Mobile__c = objCase.sc_Card_Holder_Mobile_No__c,
                    Card_Holder_Gender__c = objCase.sc_Card_Holder_Gender__c,
                    Card_Holder_ID_Number__c = objCase.sc_Card_Holder_ID_Number__c,
                    Card_Holder_ID_Expiry_Date__c = objCase.sc_Card_Holder_ID_Expiry_Date__c,
                    Card_Holder_Nationality__c = objCase.sc_Card_Holder_Nationality__c,
                    Embossing_Name__c = objCase.cc_Embossing_Line_4__c,
                    Card_Holder_Name_on_the_Card__c = objCase.cc_Approved_Name_on_the_card__c,
                    Supplementary_Card_PCI_Number__c = objCase.PrimaryCard__c,
                    Supplementary_Card_ID__c = objCase.CaseNumber
                );
                
                //CH14 : replace null param with regionName    
                HttpRequest request1 = con.createRequest('POST','/api/v1/compliances/direct', regionName);
                request1.setTimeout(60000);
                HttpResponse nameScrenResp = SM001_ApiCalls.callNameScreeningApi( request1, objCase );
                if(nameScrenResp.getStatusCode() != 200){
                    System.debug('The status code returned when calling name screening api was not expected: ' + nameScrenResp.getStatusCode() + ' ' + nameScrenResp.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction( request1.getBody(),nameScrenResp.getBody(),
                                               'callout:NeoBank_Endpoint/api/v1/compliances/direct?language=en&unit=neo','POST',
                                               objCase.id,objCase.Customer_CIF__c,objCase.accountId,nameScrenResp.getStatusCode(), 
                                               'Credit Card Supplemntary Application Calling Name Screening Api', 'Credit Card',true
                                              );
                }else{
                    System.debug('Name Screening Api running succefully! ');
                    //check the value of "nameScreening"
                    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(nameScrenResp.getBody());// meta, data
                    Map<String, Object> dataMap = (Map<String, Object>)m.get('data');
                    System.debug(dataMap);
                    Boolean nameScreening = (Boolean) dataMap.get('nameScreening');
                    String screeningResult = String.valueOf(dataMap.get('screeningResult'));
                    
                    objCase.sc_NameScreening__c = nameScreening;
                    objCase.sc_ScreeningResult__c = screeningResult;
                    
                    objSuppCard.sc_NameScreening__c = nameScreening;
                    objSuppCard.sc_ScreeningResult__c = screeningResult;
                    
                    if(nameScreening){
                        System.debug('Name Screening Api equal true ! ');
                        objCase.Sub_Status__c = 'Screening';
                        objCase.Awaiting_Customer_Feedback__c = false;
                        objCase.OwnerId = System.Label.Credit_Card_Temp;
                    }else{
                        System.debug('Name Screening Api equal false ! ');
                        objCase.Awaiting_Customer_Feedback__c = false;
                        
                        //trigger api to create supplementary card in V+ 
                        //CH14 : replace null param with regionName     
                        HttpRequest request2 = con.createRequest('PUT','/api/v1/credit-cards/request', regionName);
                        if(objCase.Account.x_canary__pc != null){
                            request2.setHeader('x-canary', objCase.Account.x_canary__pc); //CH22
                        }
                        HttpResponse suppCardResp = SM001_ApiCalls.callApiToCreateSupplementaryCardInVPlus( request2, objCase );
                        
                        if (suppCardResp.getStatusCode() != 200) 
                        {
                            System.debug('The status code returned was not expected: ' + suppCardResp.getStatusCode() + ' ' + suppCardResp.getStatus());
                            //CH29: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request2.getBody(),suppCardResp.getBody(),
                                                       'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',
                                                       objCase.id,objCase.Customer_CIF__c,objCase.accountId,suppCardResp.getStatusCode(),
                                                       'Credit Card Supplemntary Application -- call api to create supplementary card in V+ ', 'Credit Card',true);
                            //#Jahangeer Mohammed# added the Logic Approved Supplementary Card Using API
                            //CH17: Start
                            objCase.Approve_Card_Using_API__c = true;
                            objCase.OwnerId = System.Label.Supplimentary_Maker_Queue;
                            objCase.Sub_Status__c = 'In-Progress';
                            //CH17: END
                        } 
                        else 
                        {
                            System.debug('Response in SUPP - Prescreener Accepts - : '+suppCardResp.getBody());
                            objCase.Status = 'Closed';
                            objCase.Sub_Status__c = 'Approved';
                            objCase.cc_Credit_Pre_Screening_Result_Date_Time__c = system.now();
                            objCase.cc_CRM_Stage__c = 'APPROVED';
                            objCase.cc_Application_Stages__c = 'Completed';
                            objSuppCard.Status__c = 'Active';
                            
                            //#CH07 -Begin
                            objSuppCard.sc_ScreeningResult__c = 'PASS';
                            objCase.sc_ScreeningResult__c = 'PASS';
                            //#CH07 -END
                        }
                    }
                    
                    lstUpdateCase.add(objCase);
                    lstSuppCard.add(objSuppCard);
                }
            }
            
            ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //CH01: Start
            /***************************************** SERVICE CENTER RESULT IS RELEASE LETTER RECEIVED START *******************************************************/
            //CH28: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            else if((objCase.Sub_Status__c == 'Release Letter Received' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Evaluation_Result__c != 'Decline' &&
                     objCase.cc_Operations_Result__c == 'Balance Transfer Processed' && objCase.cc_Approved_Transfer_Type__c == 'Buy Out' && (objCase.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || objCase.Is_Balance_Transfer__c == true) && objCase.cc_HR_Result__c != 'Accept Release Letter' && objCase.cc_Credit_Evaluation_Result__c != 'Accept Release Letter')
                    || (objCase.Sub_Status__c == 'Release Letter Received' && objCase.cc_HR_Result__c != 'Decline' && objCase.cc_HR_Result__c != 'Accept Release Letter' && objCase.cc_Credit_Evaluation_Result__c != 'Accept Release Letter' &&
                        objCase.cc_Operations_Result__c == 'Balance Transfer Processed' && objCase.cc_Approved_Transfer_Type__c == 'Buy Out' && (objCase.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || objCase.Is_Balance_Transfer__c == true))){
                            if(objCase.Sub_Status__c == 'Release Letter Received'){
                                if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){
                                    body = '{"crmCaseId": "'+objCase.Id +
                                        '","status":"APPROVED_PENDING_BT_LETTER_RECEIVED"}';
                                }
                                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase'){
                                    body = '{"crmCaseId": "'+objCase.Id +
                                        '","targetType": "LIMIT_INCREASE","status":"APPROVED_PENDING_BT_LETTER_RECEIVED"}';
                                }
                            }
                            /*if(objCase.Sub_Status__c == 'Release Letter Accepted'){
body = '{"crmCaseId": "'+objCase.Id +
'","status":"APPROVED_PENDING_BT_LETTER_ACCEPTED"}';
}*/
                            system.debug('---> BODY WHEN SERVICE CENTER RESULT IS RELEASE LETTER RECEIVED  --> '+body);
                            request.setBody(body);
                            request.setHeader('userId', objCase.Account.PersonEmail);
                            request.setHeader('customerId', objCase.Account.CIF__pc);
                            
                            system.debug('---> request SERVICE CENTER RESULT IS RELEASE LETTER RECEIVED --> '+request.getBody());
                            HttpResponse response = http.send(request);
                            
                            if (response.getStatusCode() != 200)
                            {
                                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                                //CH29: Added isAPIFailed parameter in the method
                                lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                            }
                            else
                            {
                                System.debug(response.getBody());
                            }
                            
                        }
            /***************************************** SERVICE CENTER RESULT IS RELEASE LETTER RECEIVED END *******************************************************/
            
            /****************************************** SERVICE CENTER RESULT IS RETURN TO SIGNATURE VERIFIER START ******************************************/
            //CH25: Added a condition Signature Verifier Result != Decline and Signature Verifier Result != Cancelled by Customer in if condition
            //#CH39 : add && objCase.cc_Signature_Verifier_Result__c != 'Re-Send In-App'
            else if(objCase.cc_Service_Centre_Result__c == 'Return to Signature Verifier' && objCase.cc_Signature_Verifier_Result__c != 'Accept' && objCase.cc_Signature_Verifier_Result__c != 'Re-Send' && objCase.cc_Signature_Verifier_Result__c != 'Re-Send In-App' && objCase.cc_Credit_Approval_Result__c == 'Approve' && objCase.cc_Credit_Approval_Result__c != 'Decline' &&
                    objCase.cc_Credit_Evaluation_Result__c != 'Expired' && objCase.cc_Business_Approval_Result__c != 'Decline' &&
                    objCase.cc_Credit_Verification_Result__c != 'Decline' && objCase.cc_CEO_Result__c!= 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer')
                {
                        //#CH39 : start
                        Map<String, String> bodyObject = new Map<String, String>{
                            'crmCaseId' => objCase.Id
                        };

                        //#CH21:START
                        if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='permanent'){
                            /*body = '{"crmCaseId": "'+objCase.Id +
                                '","targetType": "LIMIT_INCREASE","status":"APPROVED_PENDING_SIGNATURE"}';*/
                            bodyObject.put('targetType','LIMIT_INCREASE');
                            bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                        }
                        if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='temporary'){
                            bodyObject.put('targetType','LIMIT_INCREASE');
                            bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                            bodyObject.put('requestType','temporary');
                            bodyObject.put('duration',String.valueOf(objCase.cc_Temporary_Limit_Increase_Duration__c));
                            /*body = '{"crmCaseId": "'+objCase.Id +
                                '","targetType": "LIMIT_INCREASE","status":"APPROVED_PENDING_SIGNATURE","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';*/
                        }
                        //#CH21:END

                        if(objCase.Type == 'Credit Limit Increase Application' && objCase.bs_Instrument_ID__c != null){
                            system.debug('---> envelopeId  --> '+objCase.bs_Instrument_ID__c);
                            if(objCase.Resend_DocuSign__c == 'In-App'){
                                bodyObject.put('signingType','IN_APP');
                                bodyObject.put('envelopeId',objCase.bs_Instrument_ID__c);
                                bodyObject.put('crmContactId',objCase.ContactId);
                            }
                            else if(objCase.Resend_DocuSign__c == 'Email'){
                                bodyObject.put('signingType','EMAIL');
                                bodyObject.put('envelopeId',null);
                                bodyObject.put('crmContactId',null);
                            }
                        }
                        body = JSON.serialize(bodyObject); 
                        //#CH39 : end
                        system.debug('---> BODY WHEN SERVICE CENTER RESULT IS RETURN TO SIGNATURE VERIFIER  --> '+body);
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request SERVICE CENTER RESULT IS RETURN TO SIGNATURE VERIFIER --> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if (response.getStatusCode() != 200)
                        {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH29: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                        }
                        else
                        {
                            System.debug(response.getBody());
                        }
                        
                }
            /****************************************** SERVICE CENTER RESULT IS RETURN TO SIGNATURE VERIFIER END ******************************************/
            
            /******************************************* CREDIT PRE SCREENING RESULT START ************************************************/
            
            else if(objCase.Sub_Status__c == 'Discrepancies' /*&& objCase.Is_Doc_Dicrepancy__c == true*/ && objCase.cc_Credit_Pre_Screening_Result__c == 'Discrepancy in Documents'){
                if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","status":"DISCREPANCIES"}';
                }
                //#CH21#:START
                      if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='permanent'){
                    body = '{"crmCaseId": "'+objCase.Id +
                                    '","targetType": "LIMIT_INCREASE","status":"DISCREPANCIES"}';
                }
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='temporary'){
                    body = '{"crmCaseId": "'+objCase.Id +
                                    '","targetType": "LIMIT_INCREASE","status":"DISCREPANCIES","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                }
                //#CH21#:END
                system.debug('---> BODY IN DISCREPANCY --> '+body);
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request in DISCREPANACY--> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200)
                {
                    
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                }
                else
                {
                    System.debug('Response in DISCREPANACY: '+response.getBody());
                    System.debug(' CREDIT TEMP QUEUE');
                    
                }
                
            }
            /******************************************* CREDIT PRE SCREENING RESULT END ************************************************/
            
            /****************************************** START : CREDIT APPROVER RESULT IS APPROVE//HR RESULT *************************************************/
            //CH08 #Jahangeer Mohammed# #31-01-2022# #Added a condition for HR Result = Approved
            //CH23: Added a condition Fraud Result != Decline in if condition
            //CH25: Added a condition Signature Verifier Result != Decline && Signature Verifier Result != Cancelled by Customer in if condition
            //#CH39 : add && objCase.cc_Signature_Verifier_Result__c != 'Re-Send In-App'
            else if((objCase.cc_Credit_Approval_Result__c == 'Approve' && objCase.Sub_Status__c == 'Pending Signature Verification' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Evaluation_Result__c != 'Decline' &&
                     objCase.cc_Credit_Verification_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_CEO_Result__c!= 'Decline' && objCase.Fraud_Results__c != 'Decline' &&
                     objCase.cc_Signature_Verifier_Result__c != 'Accept' && objCase.cc_Signature_Verifier_Result__c != 'Re-Send' && objCase.cc_Signature_Verifier_Result__c != 'Re-Send In-App' && objCase.cc_Signature_Verifier_Result__c != 'Refer to Service Center' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer') ||
                    objCase.cc_HR_Result__c == 'Approved' && objCase.Sub_Status__c == 'Pending Signature Verification' &&  objCase.cc_Signature_Verifier_Result__c != 'Accept' && objCase.cc_Signature_Verifier_Result__c != 'Re-Send' && objCase.cc_Signature_Verifier_Result__c != 'Re-Send In-App' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer'){
                        //#CH39 : start
                        Map<String, String> bodyObject = new Map<String, String>{
                            'crmCaseId' => objCase.Id
                        };

                        if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){
                            //CH12: Start
                            //CH15: Start
                            //CH26: Start
                            //CH28: Start
                            if(objCase.Approved_Campaign_Name__c != null && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                               /*body = '{"crmCaseId": "'+objCase.Id +
                                '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                '","campaignId": "'+objCase.Approved_Campaign_Name__c +
                                '","status":"APPROVED_PENDING_SIGNATURE"}'; */
                                bodyObject.put('cardProductConfigurationId',String.valueOf(objCase.PrimaryCardProductConfigurationId__c));
                                bodyObject.put('creditLimit',String.valueOf(objCase.cc_Approved_Credit_Limit__c));
                                bodyObject.put('campaignId',String.valueOf(objCase.Approved_Campaign_Name__c));
                                bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                            }
                            else if(objCase.Approved_Campaign_Name__c == null && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                                /*body = '{"crmCaseId": "'+objCase.Id +
                                '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                '","campaignId": null,"status":"APPROVED_PENDING_SIGNATURE"}';*/
                                bodyObject.put('cardProductConfigurationId',String.valueOf(objCase.PrimaryCardProductConfigurationId__c));
                                bodyObject.put('creditLimit',String.valueOf(objCase.cc_Approved_Credit_Limit__c));
                                bodyObject.put('campaignId',null);
                                bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                            }
                            else if(objCase.Approved_Campaign_Name__c == null && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                                if(objCase.cc_Approved_Embossing_line_4__c == '' || objCase.cc_Approved_Embossing_line_4__c == null){
                                    /* body = '{"crmCaseId": "'+objCase.Id +
                                    '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                    '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                    '","campaignId": null,"membershipNumber": null,"status":"APPROVED_PENDING_SIGNATURE"}';*/
                                    bodyObject.put('cardProductConfigurationId',String.valueOf(objCase.PrimaryCardProductConfigurationId__c));
                                    bodyObject.put('creditLimit',String.valueOf(objCase.cc_Approved_Credit_Limit__c));
                                    bodyObject.put('campaignId',null);
                                    bodyObject.put('membershipNumber',null);
                                    bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                                }
                                else if(objCase.cc_Approved_Embossing_line_4__c != null){
                                    /* body = '{"crmCaseId": "'+objCase.Id +
                                    '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                    '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                    '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +    
                                    '","campaignId": null,"status":"APPROVED_PENDING_SIGNATURE"}';*/
                                    bodyObject.put('cardProductConfigurationId',String.valueOf(objCase.PrimaryCardProductConfigurationId__c));
                                    bodyObject.put('creditLimit',String.valueOf(objCase.cc_Approved_Credit_Limit__c));
                                    bodyObject.put('membershipNumber',String.valueOf(objCase.cc_Approved_Embossing_line_4__c));
                                    bodyObject.put('campaignId',null);
                                    bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                                }
                                
                            }
                            //CH28: END
                            //CH26: END
                            //CH12: END
                        }
                        //CH15: END
                        //#CH21: START
                        if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='temporary'){
                            //CH12: Start
                            /*body = '{"crmCaseId": "'+objCase.Id +
                                '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                '","targetType": "LIMIT_INCREASE","status":"APPROVED_PENDING_SIGNATURE","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';*/
                            //CH12: END
                            bodyObject.put('cardProductConfigurationId',String.valueOf(objCase.PrimaryCardProductConfigurationId__c));
                            bodyObject.put('creditLimit',String.valueOf(objCase.cc_Approved_Credit_Limit__c));
                            bodyObject.put('targetType','LIMIT_INCREASE');
                            bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                            bodyObject.put('requestType','temporary');
                            bodyObject.put('duration',String.valueOf(objCase.cc_Temporary_Limit_Increase_Duration__c));
                        }
                        
                        if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='permanent' ){
                            //CH12: Start
                            /*body = '{"crmCaseId": "'+objCase.Id +
                                '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                '","targetType": "LIMIT_INCREASE","status":"APPROVED_PENDING_SIGNATURE"}';*/
                            //CH12: END
                            bodyObject.put('cardProductConfigurationId',String.valueOf(objCase.PrimaryCardProductConfigurationId__c));
                            bodyObject.put('creditLimit',String.valueOf(objCase.cc_Approved_Credit_Limit__c));
                            bodyObject.put('targetType','LIMIT_INCREASE');
                            bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                        }
                        //#CH21: END
                        if((objCase.Type == 'Credit Card Application' || objCase.Type == 'Credit Limit Increase Application') && objCase.bs_Instrument_ID__c != null){
                            system.debug('---> envelopeId  --> '+objCase.bs_Instrument_ID__c);
                            if(objCase.Resend_DocuSign__c == 'In-App'){
                                bodyObject.put('signingType','IN_APP');
                                bodyObject.put('envelopeId',objCase.bs_Instrument_ID__c);
                                bodyObject.put('crmContactId',objCase.ContactId);
                            }
                            else if(objCase.Resend_DocuSign__c == 'Email'){
                                bodyObject.put('signingType','EMAIL');
                                bodyObject.put('envelopeId',null);
                                bodyObject.put('crmContactId',null);
                            }
                        }
                        body = JSON.serialize(bodyObject);
                        //#CH39 : End

                        system.debug('---> BODY IN Approved Pending Signature --> '+body);
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        request.setTimeout(120000);//CH40
                        
                        system.debug('---> request in CREDIT APPROVAL RESULT--> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if (response.getStatusCode() != 200)
                        {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH29: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                        }
                        else
                        {
                            System.debug('Response in Referer: '+response.getBody());
                            System.debug(' CREDIT CARD APPROVAL RESULT');
                        }
                    }
            /********************************************* END : CREDIT APPROVER RESULT IS APPROVE/HR RESULT *************************************************/
            
            /**************************************** START : SIGNATURE VERIFIER CLOSE CASE FOR ILA BLUE/BLACK ****************************************/
            //CH03 : Added Type and Sub type in the condition #01-11-2021#
            //CH08 #Jahangeer Mohammed# #31-01-2022# #Added a condition for HR Result != Decline
            //CH25: Added a condition Signature Verifier Result != Decline in if condition
            //CH28: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            else if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card' && objCase.cc_Signature_Verifier_Result__c == 'Accept' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Evaluation_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Decline' &&
                    objCase.cc_Credit_Verification_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_HR_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline' &&
                    ((objCase.cc_Approved_Requested_Card_Type__c != 'PLATINUM_BALANCE_TRANSFER_01' && objCase.Is_Balance_Transfer__c == false) && objCase.cc_Approved_Requested_Card_Type__c != '')){
                        Http http1 = new Http();
                        HttpRequest request1 = new HttpRequest();
                        //CH14 : replace objCase.Region_Flag__c param with regionName 
                        //CH19: Start  
                        //request1 = con.createRequest('GET', '/api/v1/credit-cards?includeOtherProducts=true', regionName);
                        request1 = con.createRequest('GET', System.Label.CC_EndPointGetCreditCardsIncludingOtherProducts, regionName);
                        //CH19: END
                        
                        request1.setHeader('userId', objCase.Account.PersonEmail);
                        request1.setHeader('customerId', objCase.Account.CIF__pc);
                        // request1.setHeader('includeOtherProducts', 'true');
                        
                        system.debug('---> request1 --> '+request1.getBody());
                        HttpResponse response1 = http1.send(request1);
                        system.debug('---> Response New 111 --> '+response1.getBody());
                        
                        if (response1.getStatusCode() != 200)
                        {
                            System.debug('The status code returned was not expected: ' + response1.getStatusCode() + ' ' + response1.getStatus());
                            //CH29: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request1.getBody(),response1.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo','GET',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                            
                        }
                        else
                        {
                            if(!test.isRunningTest()){
                                System.debug(response1.getBody());
                                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                                System.debug('---> MAP m 222 --> '+m);  // meta, data
                                System.debug('---> MAP m VALUES 222 --> '+m.Values());
                                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                                System.debug('---> MAP m1 222--> '+m1);  // currentCards,pendingCards,cardOptions
                                List<Object> m2 = new List<Object>();
                                if(m1.containsKey('cardOptions') != null)
                                    m2=(List<Object>)m1.get('cardOptions');
                                else if(m1.containsKey('pendingCards') != null)
                                    m2=(List<Object>)m1.get('pendingCards');
                                //List<Object> m2 = (List<Object>)m1.get('cardOptions');
                                
                                System.debug('---> LIST m2 222--> '+m2);
                                
                                List<Map<String, Object>> a = new List<Map<String, Object>> ();
                                
                                for(Object obj : m2)
                                {
                                    a.add((Map<String, Object>)obj);
                                    {
                                        system.debug('---->> OBJ Iterations 222--> '+obj);
                                    }
                                }
                                system.debug('---->> FINALL aaaa 222--> '+a);
                                
                                for(Map<String, Object> map1 : a)
                                {
                                    if(map1.get('productMappingCode')== objCase.cc_Approved_Requested_Card_Type__c)
                                    {
                                        system.debug('---> FINALL 222 --> '+(Integer)map1.get('cardProductConfigurationId'));
                                        ApprovedCardProductConfigurationId = (Integer)map1.get('cardProductConfigurationId');
                                        system.debug('---> FINALL cardProductConfigurationId 222--> '+ApprovedCardProductConfigurationId);
                                    }
                                }
                            }
                        }
                        if(objCase.cc_Approved_Requested_Card_Type__c != 'PLATINUM_BALANCE_TRANSFER_01'){
                            if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){
                                //CH15: Start
                                //CH26: Start
                                //CH28: Start
                                if(objCase.Approved_Campaign_Name__c != null && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                                    body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                    '","crmCaseId": "'+objCase.Id +
                                    '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                    '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                    '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                    '","campaignId": "'+objCase.Approved_Campaign_Name__c +
                                    '","status":"APPROVED"}';
                                }
                                else if(objCase.Approved_Campaign_Name__c == null && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                                    body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                    '","crmCaseId": "'+objCase.Id +
                                    '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                    '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                    '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                    '","campaignId": null,"status":"APPROVED"}';
                                }
                                else if(objCase.Approved_Campaign_Name__c == null && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                                    //CH35: Start
                                    if(objCase.cc_Approved_Embossing_line_4__c == '' || objCase.cc_Approved_Embossing_line_4__c == null){
                                        body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                            '","crmCaseId": "'+objCase.Id +
                                            '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                            '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                            '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                            '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                                            '","issuedForSpouse": "'+objCase.Issuing_card_for_a_spouse__c +
                                            '","spouseCIF": "'+objCase.Spouse_CIF__c +
                                            '","campaignId": null,"membershipNumber": null,"status":"APPROVED"}';
                                    }
                                    else if(objCase.cc_Approved_Embossing_line_4__c != null){
                                        body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                            '","crmCaseId": "'+objCase.Id +
                                            '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                            '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                                            '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +
                                            '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                            '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                            '","issuedForSpouse": "'+objCase.Issuing_card_for_a_spouse__c +
                                            '","spouseCIF": "'+objCase.Spouse_CIF__c +
                                            '","campaignId": null,"status":"APPROVED"}';
                                    }
                                    //CH35: END
                                }
                                //CH28: END
                                //CH26: END
                                //CH15: END
                            }
                            
                            system.debug('---> BODY --> '+body);               
                            request.setBody(body);
                            request.setHeader('userId', objCase.Account.PersonEmail);
                            request.setHeader('customerId', objCase.Account.CIF__pc);
                            request.setTimeout(120000);
                            
                            system.debug('---> request --> '+request.getBody());
                            HttpResponse response = http.send(request);
                            
                            if(response.getStatusCode() != 200 && !test.isRunningTest()) {
                                
                                if(objCase.cc_Signature_Verifier_Result__c == 'Accept'){
                                    objCase.cc_Signature_Verifier_Result__c = '';
                                    objCase.cc_Signature_Verification_Date_Time__c = System.now();
                                }
                                lstUpdateCase.add(objCase);
                                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                                //CH29: Added isAPIFailed parameter in the method
                                lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                            }
                            else
                            {
                                System.debug(response.getBody());
                                //CH34: Start
                                List<String> CREDIT_CARD_TYPE = System.Label.CREDIT_CARD_TYPE.split(',');
                                //CH34: END
                               //CH28: Start
                                if(objCase.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01' && objCase.cc_Approved_Requested_Card_Type__c != null && (objCase.cc_Approved_Embossing_line_4__c == '' || objCase.cc_Approved_Embossing_line_4__c == null)){
                                     Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                                     Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                                     System.debug('Success Response Signature Verifier:'+dataMap);
                                     String membershipNumber = String.valueOf(dataMap.get('membershipNumber'));
                                     objCase.cc_Embossing_Line_4__c = membershipNumber;
                                     objCase.cc_Approved_Embossing_line_4__c = membershipNumber;
                                     if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Regular'){
                                        //CH34: Start
                                        Case cseToInsert = CreatePremiumInvitationCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                     	//CH34: END
                                        lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                     }
                                     //CH33: Start
                                     else if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Premium'){
                                        //CH34: Start
                                        Case cseToInsert = CreatePremiumRetentionCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                     	//CH34: END
                                        lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                    }
                                    //CH33: END 
                                }
                                else if(objCase.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01' && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Embossing_line_4__c != null){
                                    if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Regular'){
                                        //CH34: Start
                                        Case cseToInsert = CreatePremiumInvitationCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                     	//CH34: END
                                        lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                    }
                                    //CH33: Start
                                    else if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Premium'){
                                        //CH34: Start
                                        Case cseToInsert = CreatePremiumRetentionCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                     	//CH34: END
                                        lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                    }
                                    //CH33: END
                                }
                                //CH34: Start
                                else if(System.Label.ENABLE_CROSS_SELLING.equalsIgnoreCase('true') && CREDIT_CARD_TYPE.contains(objCase.cc_Approved_Requested_Card_Type__c) && objCase.Customer_Segment__c == 'Regular'){
                                    Case cseToInsert = CreatePremiumInvitationCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                    lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                }
                                else if(System.Label.ENABLE_CROSS_SELLING.equalsIgnoreCase('true') && CREDIT_CARD_TYPE.contains(objCase.cc_Approved_Requested_Card_Type__c) && objCase.Customer_Segment__c == 'Premium'){
                                    Case cseToInsert = CreatePremiumRetentionCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                    lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                }
                                //CH34: END
                                //CH28: END
                                //CH08: Start
                                if(recordtypeName == 'Credit Card'){
                                    objCase.Status = 'Closed';
                                    objCase.Sub_Status__c = 'Approved';
                                    objCase.cc_Application_Stages__c = 'Completed';
                                    objCase.cc_CRM_Stage__c = 'APPROVED';
                                    //objCase.cc_isDocumentReceived__c = true;
                                    objCase.cc_Signature_Verification_Date_Time__c = System.now();
                                    lstUpdateCase.add(objCase);
                                }
                                if(recordtypeName == 'Credit Card - Staff  Application'){
                                    //objCase.Status = 'Closed';
                                    objCase.Sub_Status__c = 'Pending Disable EPP';
                                    objCase.cc_Application_Stages__c = 'Credit Buyout';
                                    objCase.cc_CRM_Stage__c = 'APPROVED';
                                    objCase.OwnerId = System.Label.Credit_Card_Regular_Buyout;
                                    //objCase.cc_isDocumentReceived__c = true;
                                    lstUpdateCase.add(objCase);
                                }
                                //CH08: END

                                //#CH40 : Start
                                if(objCase.Resend_DocuSign__c == 'In-App'){
                                    SendEmailService.CC_sendEmailWithAtachements(objCase,'ILA_CreditCard_Send_SignedDocs',System.Label.CreditCard_DocuSignFilesKeywords.split(';'));
                                }
                                //#CH40: End
                            }
                        }
                        
                    }
            
            /**************************************** END : SIGNATURE VERIFIER CLOSE CASE FOR ILA BLUE/BLACK ****************************************/
            
            //CH03 : Start
            /**************************************** START : SIGNATURE VERIFIER CLOSE CASE FOR LIMIT UPDATE ******************************************/
            //CH23: Added a condition Fraud Result != Decline in if condition
            //CH25: Added a condition Signature Verifier Result != Decline in if condition
            else if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Signature_Verifier_Result__c == 'Accept' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Evaluation_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Decline' &&
                    objCase.cc_Credit_Verification_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.Fraud_Results__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline')
            {
                Http http1 = new Http();
                HttpRequest request1 = new HttpRequest();
                //CH14 : replace objCase.Region_Flag__c param with regionName 
                //CH19: Start  
                //request1 = con.createRequest('GET','/api/v1/credit-cards?includeOtherProducts=true', regionName);
                request1 = con.createRequest('GET',System.Label.CC_EndPointGetCreditCardsIncludingOtherProducts, regionName);
                //CH19: END
                
                request1.setHeader('userId', objCase.Account.PersonEmail);
                request1.setHeader('customerId', objCase.Account.CIF__pc);
                // request1.setHeader('includeOtherProducts', 'true');
                
                system.debug('---> request1 --> '+request1.getBody());
                HttpResponse response1 = http1.send(request1);
                system.debug('---> Response New 111 --> '+response1.getBody());
                
                if (response1.getStatusCode() != 200) 
                {   
                    System.debug('The status code returned was not expected: ' + response1.getStatusCode() + ' ' + response1.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request1.getBody(),response1.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo','GET',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                    
                } 
                else 
                {
                    if(!test.isRunningTest()){
                        System.debug(response1.getBody());      
                        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                        System.debug('---> MAP m 222 --> '+m);  // meta, data
                        System.debug('---> MAP m VALUES 222 --> '+m.Values());
                        Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                        System.debug('---> MAP m1 222--> '+m1);  // currentCards,pendingCards,cardOptions
                        List<Object> m2 = new List<Object>();
                        if(m1.containsKey('cardOptions') != null)
                            m2=(List<Object>)m1.get('cardOptions');
                        else if(m1.containsKey('pendingCards') != null)
                            m2=(List<Object>)m1.get('pendingCards'); 
                        //List<Object> m2 = (List<Object>)m1.get('cardOptions');
                        
                        System.debug('---> LIST m2 222--> '+m2);
                        
                        List<Map<String, Object>> a = new List<Map<String, Object>> ();
                        
                        for(Object obj : m2)
                        {
                            a.add((Map<String, Object>)obj);
                            {
                                system.debug('---->> OBJ Iterations 222--> '+obj);
                            }
                        }
                        system.debug('---->> FINALL aaaa 222--> '+a);
                        
                        for(Map<String, Object> map1 : a)
                        {
                            if(map1.get('productMappingCode')== objCase.cc_Approved_Requested_Card_Type__c)
                            {
                                system.debug('---> FINALL 222 --> '+(Integer)map1.get('cardProductConfigurationId'));
                                ApprovedCardProductConfigurationId = (Integer)map1.get('cardProductConfigurationId');
                                system.debug('---> FINALL cardProductConfigurationId 222--> '+ApprovedCardProductConfigurationId);
                            }
                        }
                    }
                }
                 //#CH21:START
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='permanent'){
                   
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                        '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                        '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                        '","targetType": "LIMIT_INCREASE","status":"APPROVED"}';
                }
               
                  if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='temporary'){
                           
                      body = '{"crmCaseId": "'+objCase.Id +
                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                '","targetType": "LIMIT_INCREASE","status":"APPROVED","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'","limitExpiryDate":"'+String.valueOf(System.today())+'"}';
                        }
                //#CH21:END
                system.debug('---> BODY --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if(response.getStatusCode() != 200 && !test.isRunningTest()) {
                    
                    if(objCase.cc_Signature_Verifier_Result__c == 'Accept'){
                        objCase.cc_Signature_Verifier_Result__c = '';
                        objCase.cc_Signature_Verification_Date_Time__c = System.now();
                    }
                    lstUpdateCase.add(objCase);
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                } 
                else 
                {
                    System.debug('finalapproval##'+response.getBody());
                    Map<String,Object> results = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                    Map<String,Object> finalresult =(Map<String, Object>)results.get('data');
                    objCase.Status = 'Closed';
                    objCase.Sub_Status__c = 'Approved';
                    objCase.cc_Application_Stages__c = 'Completed';
                    objCase.cc_CRM_Stage__c = 'APPROVED';
                    objCase.cc_Temporary_Limit_Increase_Expiry_Date__c=objCase.cc_Request_Type__c=='temporary'?Date.ValueOf(String.valueOf(finalresult.get('limitExpiryDate'))):null;
                    //objCase.cc_isDocumentReceived__c = true;
                    objCase.cc_Signature_Verification_Date_Time__c = System.now();
                    //CH43: Start
                    if(objCase.Is_Initiated_from_Upgrade_Case__c == true){
                       setUpgradeCaseToInsert.add(objCase.Id);
                    }
                    //CH43: END
                    lstUpdateCase.add(objCase);
                    
                    //#CH40 : Start
                    if(objCase.Resend_DocuSign__c == 'In-App'){
                        SendEmailService.CC_sendEmailWithAtachements(objCase,'ILA_CreditCard_Send_SignedDocs',System.Label.CreditCard_DocuSignFilesKeywords.split(';'));
                    }
                    //#CH40: End
                }
                
                
            }
            //CH03: END
            
            /**************************************** END : SIGNATURE VERIFIER CLOSE CASE FOR LIMIT UPDATE ********************************************/
            
            /**************************************** START : SIGNATURE VERIFIER RESULT IS ACCEPT FOR ILA SWITCH-BALANCE TRANSFER AND BUY OUT ****************************************/
            //CH03 : Added Type and Sub type in the condition #01-11-2021#
            //CH08 #Jahangeer Mohammed# #01-02-2022# #Added a condition for HR Result != Decline
            //CH25: Added a condition Signature Verifier Result != Decline in if condition
			//CH28: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
				else if((objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card' && objCase.cc_Signature_Verifier_Result__c == 'Accept' && objCase.cc_Operations_Result__c != 'Balance Transfer Processed' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Evaluation_Result__c != 'Decline' &&
                     objCase.cc_Credit_Verification_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Decline' && objCase.cc_HR_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline') &&
                    (((objCase.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || objCase.Is_Balance_Transfer__c == true) && objCase.cc_Approved_Transfer_Type__c == 'Balance Transfer') ||
                     ((objCase.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || objCase.Is_Balance_Transfer__c == true) && objCase.cc_Approved_Transfer_Type__c == 'Buy Out'))){
                         
                         Http http1 = new Http();
                         HttpRequest request1 = new HttpRequest();
                         //CH14 : replace objCase.Region_Flag__c param with regionName 
                         //CH19: Start  
                         //request1 = con.createRequest('GET', '/api/v1/credit-cards?includeOtherProducts=true', regionName);
                         request1 = con.createRequest('GET', System.Label.CC_EndPointGetCreditCardsIncludingOtherProducts, regionName);
                         //CH19: END
                         
                         request1.setHeader('userId', objCase.Account.PersonEmail);
                         request1.setHeader('customerId', objCase.Account.CIF__pc);
                         // request1.setHeader('includeOtherProducts', 'true');
                         
                         system.debug('---> request1 --> '+request1.getBody());
                         HttpResponse response1 = http1.send(request1);
                         system.debug('---> Response New 111 --> '+response1.getBody());
                         
                         if (response1.getStatusCode() != 200)
                         {
                             System.debug('The status code returned was not expected: ' + response1.getStatusCode() + ' ' + response1.getStatus());
                             //CH29: Added isAPIFailed parameter in the method
                             lstSA = createSystemAction(request1.getBody(),response1.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo','GET',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                             
                         }
                         else
                         {
                             if(!test.isRunningTest()){
                                 System.debug(response1.getBody());
                                 Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                                 System.debug('---> MAP m 222 --> '+m);  // meta, data
                                 System.debug('---> MAP m VALUES 222 --> '+m.Values());
                                 Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                                 System.debug('---> MAP m1 222--> '+m1);  // currentCards,pendingCards,cardOptions
                                 List<Object> m2 = new List<Object>();
                                 if(m1.containsKey('cardOptions') != null)
                                     m2=(List<Object>)m1.get('cardOptions');
                                 else if(m1.containsKey('pendingCards') != null)
                                     m2=(List<Object>)m1.get('pendingCards');
                                 //List<Object> m2 = (List<Object>)m1.get('cardOptions');
                                 
                                 System.debug('---> LIST m2 222--> '+m2);
                                 
                                 List<Map<String, Object>> a = new List<Map<String, Object>> ();
                                 
                                 for(Object obj : m2)
                                 {
                                     a.add((Map<String, Object>)obj);
                                     {
                                         system.debug('---->> OBJ Iterations 222--> '+obj);
                                     }
                                 }
                                 system.debug('---->> FINALL aaaa 222--> '+a);
                                 
                                 for(Map<String, Object> map1 : a)
                                 {
                                     if(map1.get('productMappingCode')== objCase.cc_Approved_Requested_Card_Type__c)
                                     {
                                         system.debug('---> FINALL 222 --> '+(Integer)map1.get('cardProductConfigurationId'));
                                         ApprovedCardProductConfigurationId = (Integer)map1.get('cardProductConfigurationId');
                                         system.debug('---> FINALL cardProductConfigurationId 222--> '+ApprovedCardProductConfigurationId);
                                     }
                                 }
                             }
                             //CH28: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
                             if((objCase.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || objCase.Is_Balance_Transfer__c == true) && objCase.cc_Approved_Transfer_Type__c == 'Balance Transfer'){
                                 if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){
                                     //CH15: Start
                                     //CH26: Start
                                     //CH28: Start
                                     if(objCase.Approved_Campaign_Name__c != null && objCase.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01'){
                                         body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                         '","crmCaseId": "'+objCase.Id +
                                         '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                         '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                         '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                         '","campaignId": "'+objCase.Approved_Campaign_Name__c +
                                         '","status":"APPROVED"}';
                                     }
                                     else if(objCase.Approved_Campaign_Name__c == null && objCase.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01'){
                                         body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                         '","crmCaseId": "'+objCase.Id +
                                         '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                         '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                         '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                         '","campaignId": null,"status":"APPROVED"}';
                                     }
                                     else if(objCase.Approved_Campaign_Name__c == null && objCase.Is_Balance_Transfer__c == true){
                                        //CH35: Start 
                                        if(objCase.cc_Approved_Embossing_line_4__c == '' || objCase.cc_Approved_Embossing_line_4__c == null){ 
                                             body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                                 '","crmCaseId": "'+objCase.Id +
                                                 '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                                 '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                                 '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                                 '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                                                 '","issuedForSpouse": "'+objCase.Issuing_card_for_a_spouse__c +
                                                 '","spouseCIF": "'+objCase.Spouse_CIF__c +
                                                 '","campaignId": null,"membershipNumber": null,"status":"APPROVED"}';
                                         }
                                         else if(objCase.cc_Approved_Embossing_line_4__c != null){
                                             body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                                 '","crmCaseId": "'+objCase.Id +
                                                 '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                                 '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                                                 '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +
                                                 '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                                 '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                                 '","issuedForSpouse": "'+objCase.Issuing_card_for_a_spouse__c +
                                                 '","spouseCIF": "'+objCase.Spouse_CIF__c +
                                                 '","campaignId": null,"status":"APPROVED"}';
                                         }
                                         //CH35: END
                                     }
                                     //CH28: END
                                    //CH26: END
                                     //CH15: END
                                 }
                                
                                 system.debug('---> BODY IN ILA SWITCH-BALANCE TRANSFER --> '+body);               
                                 request.setBody(body);
                                 request.setHeader('userId', objCase.Account.PersonEmail);
                                 request.setHeader('customerId', objCase.Account.CIF__pc);
                                 
                                 system.debug('---> request in ILA SWITCH-BALANCE TRANSFER --> '+request.getBody());
                                 HttpResponse response = http.send(request);
                                 if (response.getStatusCode() != 200)
                                 {
                                     System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                                     //CH29: Added isAPIFailed parameter in the method
                                     lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                                 }
                                 else
                                 {
                                     System.debug('Response in ILA SWITCH-BALANCE TRANSFER : '+response.getBody());
                                     System.debug(' SIGNATURE VERIFICATION ACCEPT FOR ILA SWITCH-BALANCE TRANSFER');
                                     //CH28: Start
                                     if(objCase.Is_Balance_Transfer__c == true && (objCase.cc_Approved_Embossing_line_4__c == '' || objCase.cc_Approved_Embossing_line_4__c == null)){
                                         Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                                         Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                                         System.debug('Success Response at Signature Verifier for Balance Transfer:'+dataMap);
                                         String membershipNumber = String.valueOf(dataMap.get('membershipNumber'));
                                         objCase.cc_Embossing_Line_4__c = membershipNumber;
                                         objCase.cc_Approved_Embossing_line_4__c = membershipNumber;
                                         if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Regular'){
                                             //CH34: Start
                                             Case cseToInsert = CreatePremiumInvitationCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                             //CH34: END
                                             lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                         }
                                        //CH33: Start
                                     	else if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Premium'){
                                        	//CH34: Start
                                            Case cseToInsert = CreatePremiumRetentionCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                     		//CH34: END
                                            lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                    	}
                                    	//CH33: END 
                                         
                                     }
                                     else if(objCase.Is_Balance_Transfer__c == true && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Embossing_line_4__c != null){
                                         if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Regular'){
                                             //CH34: Start
                                             Case cseToInsert = CreatePremiumInvitationCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                             //CH34: END
                                             lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                         }
                                        //CH33: Start
                                     	else if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Premium'){
                                        	//CH34: Start
                                            Case cseToInsert = CreatePremiumRetentionCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                     		//CH34: END
                                            lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                    	}
                                    	//CH33: END 
                                	 }
                                     //CH28: END
                                     Util.setOwnerQueue(queueIds, caseToRegion, objCase, CREDIT_CARD_REGULAR_BUYOUT_QUEUE); //objCase.OwnerId = System.Label.Credit_Card_Regular_Buyout;
                                     objCase.cc_Application_Stages__c = 'Credit Buyout';
                                     objCase.Sub_Status__c = 'Approved BT';
                                     objCase.cc_CRM_Stage__c = 'APPROVED';
                                     //CH08: Start
                                     objCase.cc_Signature_Verification_Date_Time__c = System.now();
                                     //CH08: END
                                    
                                    lstUpdateCase.add(objCase);
                                    
                                    //#CH40 : Start
                                    if(objCase.Resend_DocuSign__c == 'In-App'){
                                        SendEmailService.CC_sendEmailWithAtachements(objCase,'ILA_CreditCard_Send_SignedDocs',System.Label.CreditCard_DocuSignFilesKeywords.split(';'));
                                    }
                                    //#CH40: End
                                 }
                             }
                             //CH28: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
                             else if((objCase.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || objCase.Is_Balance_Transfer__c == true) && objCase.cc_Approved_Transfer_Type__c == 'Buy Out'){
                                 if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){
                                     body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                         '","crmCaseId": "'+objCase.Id +
                                         '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                         '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                         '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                         '","status":"APPROVED_PENDING_BT_PROCESSING"}';
                                 }
                                 
                                 system.debug('---> BODY IN ILA SWITCH-BUY OUT --> '+body);               
                                 request.setBody(body);
                                 request.setHeader('userId', objCase.Account.PersonEmail);
                                 request.setHeader('customerId', objCase.Account.CIF__pc);
                                 
                                 system.debug('---> request in ILA SWITCH-BUY OUT--> '+request.getBody());
                                 HttpResponse response = http.send(request);
                                 if (response.getStatusCode() != 200)
                                 {
                                     System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                                     //CH29: Added isAPIFailed parameter in the method
                                     lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                                 }
                                 else
                                 {
                                     System.debug('Response in ILA SWITCH-BUY OUT : '+response.getBody());
                                     System.debug(' SIGNATURE VERIFICATION ACCEPT FOR ILA SWITCH-BUY OUT');
                                     //CH28: Start
                                     if(objCase.Is_Balance_Transfer__c == true && (objCase.cc_Approved_Embossing_line_4__c == '' || objCase.cc_Approved_Embossing_line_4__c == null)){
                                         Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                                         Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                                         System.debug('Success Response at Signature Verifier for Balance Transfer:'+dataMap);
                                         String membershipNumber = String.valueOf(dataMap.get('membershipNumber'));
                                         objCase.cc_Embossing_Line_4__c = membershipNumber;
                                         objCase.cc_Approved_Embossing_line_4__c = membershipNumber;
                                         if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Regular'){
                                             //CH34: Start
                                             Case cseToInsert = CreatePremiumInvitationCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                             //CH34: END
                                             lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                         }
                                        //CH33: Start
                                     	else if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Premium'){
                                        	//CH34: Start
                                            Case cseToInsert = CreatePremiumRetentionCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                     		//CH34: END
                                            lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                    	}
                                    	//CH33: END 
                                      }
                                      else if(objCase.Is_Balance_Transfer__c == true && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Embossing_line_4__c != null){
                                         if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Regular'){
                                             //CH34: Start
                                             Case cseToInsert = CreatePremiumInvitationCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                             //CH34: END
                                             lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                         }
                                        //CH33: Start
                                     	else if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Premium'){
                                        	//CH34: Start
                                            Case cseToInsert = CreatePremiumRetentionCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                     		//CH34: END
                                            lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                    	}
                                    	//CH33: END 
                                      }
                                      
                                     //CH28: END
                                 }
                                 
                             }
                             //CH28: END
                         }
                     }
            
            
            
            /*************************************** END : SIGNATURE VERIFIER RESULT IS ACCEPT FOR ILA SWITCH-BALANCE TRANSFER AND BUY OUT ****************************************/
            
            /**************************************** START : SIGNATURE VERIFIER RESULT IS RE-SEND ****************************************/
            //CH23: Added a condition Fraud Result != Decline in if condition
            //CH25: Added a condition Signature Verifier Result != Decline in if condition
            //#CH39 : add || objCase.cc_Signature_Verifier_Result__c == 'Re-Send In-App'
            else if( (objCase.cc_Signature_Verifier_Result__c == 'Re-Send' || objCase.cc_Signature_Verifier_Result__c == 'Re-Send In-App') && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Evaluation_Result__c != 'Decline' &&
                    objCase.cc_Credit_Verification_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Decline' && objCase.cc_HR_Result__c != 'Decline' && objCase.Fraud_Results__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline'){
                        
                        //#CH39 : start
                        Map<String, String> bodyObject = new Map<String, String>{
                            'crmCaseId' => objCase.Id
                        };
                        if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){
                            /*body = '{"crmCaseId": "'+objCase.Id +
                                '","status":"APPROVED_PENDING_SIGNATURE"}';*/
                            bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                        }
                        if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase'){
                            /*body = '{"crmCaseId": "'+objCase.Id +
                                '","targetType": "LIMIT_INCREASE","status":"APPROVED_PENDING_SIGNATURE"}';*/
                            bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                            bodyObject.put('targetType','LIMIT_INCREASE');
                        }
                        if((objCase.Type == 'Credit Card Application' || objCase.Type == 'Credit Limit Increase Application') && objCase.bs_Instrument_ID__c != null){
                            system.debug('---> envelopeId  --> '+objCase.bs_Instrument_ID__c);
                            if(objCase.cc_Signature_Verifier_Result__c == 'Re-Send In-App'){
                                bodyObject.put('signingType','IN_APP');
                                bodyObject.put('envelopeId',objCase.bs_Instrument_ID__c);
                                bodyObject.put('crmContactId',objCase.ContactId);
                                objCase.Resend_DocuSign__c = 'In-App';
                                lstUpdateCase.add(objCase);
                            }
                            else if(objCase.cc_Signature_Verifier_Result__c == 'Re-Send'){
                                bodyObject.put('signingType','EMAIL');
                                bodyObject.put('envelopeId',null);
                                bodyObject.put('crmContactId',null);
                                objCase.Resend_DocuSign__c = 'Email';
                                lstUpdateCase.add(objCase);
                            }
                        }
                        body = JSON.serialize(bodyObject);
                        //#CH39 : End

                        system.debug('---> BODY IN RESEND Approved Pending Signature FOR SIGNATURE VERIFICATION --> '+body);
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request in Approved Pending Signature FOR SIGNATURE VERIFICATION --> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if (response.getStatusCode() != 200)
                        {
                            
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH29: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                        }
                        else
                        {
                            System.debug('Response in Approved Pending Signature FOR SIGNATURE VERIFICATION : '+response.getBody());
                            System.debug(' SIGNATURE VERIFICATION RE_SEND');
                        }
                    }
            /**************************************** END : SIGNATURE VERIFIER RESULT IS RE-SEND ****************************************/
            
            /******************************* START : SIGNATURE VERIFIER RESULT IS REFER TO SERVICE CENTER ****************************************/
            //CH23: Added a condition Fraud Result != Decline in if condition
            //CH25: Added a condition Signature Verifier Result != Decline in if condition

            else if(objCase.cc_Signature_Verifier_Result__c == 'Refer to Service Center' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Evaluation_Result__c != 'Decline' &&
                    objCase.cc_Credit_Verification_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Decline' && objCase.Fraud_Results__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline'){
                        if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){
                            body = '{"crmCaseId": "'+objCase.Id +
                                '","status":"REFERRED_BY_SIGNATURE_VERIFIER"}';
                        }
                        //#CH21:START
                        if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='permanent'){
                            body = '{"crmCaseId": "'+objCase.Id +
                                '","targetType": "LIMIT_INCREASE","status":"REFERRED_BY_SIGNATURE_VERIFIER"}';
                        }
                          if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='temporary'){
                            body = '{"crmCaseId": "'+objCase.Id +
                                '","targetType": "LIMIT_INCREASE","status":"REFERRED_BY_SIGNATURE_VERIFIER","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                        }
                        //#CH21:END
                        system.debug('---> BODY IN SIGNATURE VERIFIER IF REFER TO SERVICE CENTER --> '+body);
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request in SIGNATURE VERIFIER IF REFER TO SERVICE CENTER ---> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if (response.getStatusCode() != 200)
                        {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH29: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                        }
                        else
                        {
                            System.debug('Response in SIGNATURE VERIFIER IF REFER TO SERVICE CENTER - : '+response.getBody());
                            System.debug(' SIGNATURE VERIFICATION REFER TO SERVICE CENTER');
                        }
                    }
            /******************************* END : SIGNATURE VERIFIER RESULT IS  REFER TO SERVICE CENTER  ****************************************/
            
           
            /************************** START : BUYOUT OPERATION RESULT IS BALANCE TRANSFER AND TRANSFER TYPE IS BUYOUT *****************************************/
            //CH25: Added a condition Signature Verifier Result != Decline in if condition
            //CH28: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
                else if((objCase.cc_Operations_Result__c == 'Balance Transfer Processed' && objCase.cc_Signature_Verifier_Result__c == 'Accept' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Evaluation_Result__c != 'Decline' &&
                     objCase.cc_Credit_Verification_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Decline' &&
                     (objCase.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || objCase.Is_Balance_Transfer__c == true) && objCase.cc_Approved_Transfer_Type__c == 'Buy Out' && objcase.cc_Credit_Evaluation_Result__c != 'Accept Release Letter' && objCase.cc_HR_Result__c != 'Accept Release Letter' && objCase.cc_Signature_Verifier_Result__c != 'Decline') ||
                    (objCase.cc_Operations_Result__c == 'Balance Transfer Processed' &&  (objCase.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || objCase.Is_Balance_Transfer__c == true) && objCase.cc_Approved_Transfer_Type__c == 'Buy Out' &&
                     objCase.cc_HR_Result__c == 'Approved' && objCase.cc_HR_Result__c != 'Decline' && objCase.cc_HR_Result__c != 'Accept Release Letter' && objcase.cc_Credit_Evaluation_Result__c != 'Accept Release Letter' && objCase.cc_Signature_Verifier_Result__c != 'Decline')){
                         if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){ 
                             body = '{"crmCaseId": "'+objCase.Id +
                                 '","transactionReference": "'+objCase.cc_Balance_Transfer_Reference_Number__c +
                                 '","status":"APPROVED_PENDING_BT_LETTER"}';
                         }
                        
                         system.debug('---> BODY IN BUYOUT OPERATION FOR BUY OUT TYPE --> '+body);               
                         request.setBody(body);
                         request.setHeader('userId', objCase.Account.PersonEmail);
                         request.setHeader('customerId', objCase.Account.CIF__pc);
                         
                         system.debug('---> request in BUYOUT OPERATION  FOR BUY OUT TYPE ---> '+request.getBody());
                         HttpResponse response = http.send(request);
                         
                         if (response.getStatusCode() != 200)
                         {
                             System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                             //CH29: Added isAPIFailed parameter in the method
                             lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                         }
                         else
                         {
                             System.debug('Response in BUYOUT OPERATION  FOR BUY OUT TYPE - : '+response.getBody());
                             System.debug(' BUYOUT OPERATION REFER TO SERVICE CENTER');
                         }
                     }
            
            /************************** END : BUYOUT OPERATION RESULT IS BALANCE TRANSFER AND TRANSFER TYPE IS BUYOUT *****************************************/
            
            /**************************** START : EVALUATION RESULT IS ACCEPT RELEASE LETTER ***************************************************/
            //CH25: Added a condition Signature Verifier Result != Decline in if condition
            //CH28: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            else if(objCase.cc_Credit_Evaluation_Result__c == 'Accept Release Letter' && objCase.cc_Service_Centre_Result__c == 'Release Letter Received' && objCase.cc_Operations_Result__c == 'Balance Transfer Processed' && objCase.cc_Signature_Verifier_Result__c == 'Accept' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Evaluation_Result__c != 'Decline' &&
                    objCase.cc_Credit_Verification_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline' &&
                    (objCase.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || objCase.Is_Balance_Transfer__c == true) && objCase.cc_Approved_Transfer_Type__c == 'Buy Out')
            {
                if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){
                    //CH15: Start
                    //CH26: Start
                    if(objCase.Approved_Campaign_Name__c != null){
                        body = '{"crmCaseId": "'+objCase.Id +
                        '","campaignId": "'+objCase.Approved_Campaign_Name__c +
                        '","status":"APPROVED"}';
                    }
                    else if(objCase.Approved_Campaign_Name__c == null){
                         body = '{"crmCaseId": "'+objCase.Id +
                        '","campaignId": null,"status":"APPROVED"}';
                    }
                   //CH26: END
                    //CH15: END
                }
                
                system.debug('---> BODY IN EVALUATION RESULT ACCEPT RELEASE LETTER --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request in evaluation result accept release letter ---> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                }
                else
                {
                    System.debug('Response in Evaluation result accept release letter - : '+response.getBody());
                    System.debug('Evaluation Result Accept Release Letter');
                    objCase.Status = 'Closed';
                    objCase.Sub_Status__c = 'Approved';
                    if(objCase.cc_Credit_Evaluation_Result__c == 'Accept Release Letter'){
                        objCase.cc_Credit_Evaluation_Result_Date_Time__c = system.now();
                    }
                    objCase.cc_CRM_Stage__c = 'APPROVED';
                    objCase.cc_Application_Stages__c = 'Completed';
                    lstUpdateCase.add(objCase);
                }
            }
            
            /**************************** END : EVALUATION RESULT IS ACCEPT RELEASE LETTER *********************************************************/
            
           
            //CH09: END
            /*********************************** END : HR APPROVAL RESULT IS APPROVE ************************************************************/
            
            /************************************** START : HR APPROVAL RESULT ACCEPT RELEASE LETTER *************************************************************/
            else if(objCase.cc_HR_Result__c == 'Accept Release Letter'){
                if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","status":"APPROVED"}';
                }
               
                system.debug('---> BODY WHEN HR RESULT IS ACCEPT RELEASE LETTER  --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request WHEN HR RESULT IS ACCEPT RELEASE LETTER --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200)
                {
                    if(objCase.cc_HR_Result__c == 'Accept Release Letter'){
                        objCase.cc_HR_Result__c = '';
                    }
                    lstUpdateCase.add(objCase);
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                }
                else
                {
                    System.debug(response.getBody());
                    objCase.Status = 'Closed';
                    objCase.Sub_Status__c = 'Approved';
                    objCase.cc_Application_Stages__c = 'Completed';
                    objCase.cc_CRM_Stage__c = 'APPROVED';
                    lstUpdateCase.add(objCase);
                }
                
            }
            /************************************** END : HR APPROVAL RESULT ACCEPT RELEASE LETTER *************************************************************/
            
            //CH01: END
            //CH23: Added a condition Fraud Result == Decline in if condition
            //CH25: Added a condition Signature Verifier Result == Decline in if condition
            else if(objCase.cc_Credit_Approval_Result__c == 'Decline' || objCase.cc_HR_Result__c == 'Decline' || objCase.cc_Business_Approval_Result__c == 'Decline' || objCase.cc_Credit_Evaluation_Result__c == 'Rejected' || objCase.cc_Credit_Evaluation_Result__c == 'Decline' || objCase.cc_Credit_Verification_Result__c == 'Decline' || objCase.cc_Credit_Pre_Screening_Result__c == 'Decline' || objCase.cc_CEO_Result__c == 'Decline' || objCase.cc_Maker__c == 'Decline' || objCase.Fraud_Results__c == 'Decline' || objCase.cc_Signature_Verifier_Result__c == 'Decline' ){
               //CH24: Start
               String decReason = DeclineReasonMapping.fetchDeclineMappingValue(objCase.id);
               //CH24: END
               if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){
                   //CH24: Start
                   //CH25: Added a condition Signature Verifier Result == Decline in if condition
                    if((objCase.cc_Credit_Approval_Result__c == 'Decline' || objCase.cc_Business_Approval_Result__c == 'Decline' || objCase.cc_Credit_Evaluation_Result__c == 'Decline' || objCase.cc_Credit_Verification_Result__c == 'Decline' || objCase.cc_Credit_Pre_Screening_Result__c == 'Decline' || objCase.cc_CEO_Result__c == 'Decline' || objCase.Fraud_Results__c == 'Decline' || objCase.cc_Signature_Verifier_Result__c == 'Decline') && objCase.cc_HR_Result__c != 'Approved'){
                    //CH12: Start
                    body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","declineReasons": "'+decReason +
                            '","status":"DECLINED"}';
                    //CH12: END
                    }
                    //CH24: Start
                    /////////////////////////////////////////// Start Staff - HR Signature Verifier Decline /////////////////////////////////////////
                    //CH28: Start - Remove "targetType": "LIMIT_INCREASE"
                   else if(objCase.cc_HR_Result__c == 'Approved' && objCase.cc_Signature_Verifier_Result__c == 'Decline'){
                         body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","status":"DECLINED"}';
                    }
                   //CH28: END
                   /////////////////////////////////////////// END Staff - HR Signature Verifier Decline ///////////////////////////////////////////
                   //CH24: END
                   else if(objCase.cc_HR_Result__c == 'Decline'){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","status":"DECLINED"}';
                   }
                    //CH24: END
                }
                //#CH21:START
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='permanent'){
                     //CH24: Start
                     //CH25: Added a condition Signature Verifier Result == Decline in if condition
                     //CH23: Added a condition Fraud Result == Decline in if condition
                    
                    //////////////////////////////////////// Start Non Staff - Decline Conditions ////////////////////////////////////////////
                    if((objCase.cc_Credit_Approval_Result__c == 'Decline' || objCase.cc_Business_Approval_Result__c == 'Decline' || objCase.cc_Credit_Evaluation_Result__c == 'Decline' || objCase.cc_Credit_Verification_Result__c == 'Decline' || objCase.cc_Credit_Pre_Screening_Result__c == 'Decline' || objCase.cc_CEO_Result__c == 'Decline' || objCase.cc_Signature_Verifier_Result__c == 'Decline' || objCase.Fraud_Results__c == 'Decline') && objCase.cc_HR_Result__c != 'Approved'){
                    //CH12: Start
                    body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","declineReasons": "'+decReason +
                            '","targetType": "LIMIT_INCREASE","status":"DECLINED"}';
                    //CH12: END
                    }
                   //////////////////////////////////////// End Non Staff - Decline Conditions ////////////////////////////////////////////

                    //CH24: Start
                    /////////////////////////////////////////// Start Staff - HR Signature Verifier Decline /////////////////////////////////////////
                    else if(objCase.cc_HR_Result__c == 'Approved' && objCase.cc_Signature_Verifier_Result__c == 'Decline'){
                         body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","targetType": "LIMIT_INCREASE","status":"DECLINED"}';
                    }
                   /////////////////////////////////////////// END Staff - HR Signature Verifier Decline ///////////////////////////////////////////
                   //CH24: END
                    
                    else if(objCase.cc_HR_Result__c == 'Decline'){
                         body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","targetType": "LIMIT_INCREASE","status":"DECLINED"}';
                    }
                    //CH24: END
                }
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='temporary'){
                    //CH12: Start
                    body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","targetType": "LIMIT_INCREASE","status":"DECLINED","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                    //CH12: END
                }
                //#CH21:END
                if(objCase.Type == 'Credit Card Supplementary Application' && objCase.Sub_Type__c == 'New Supplementary Card'){
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                        '","targetType": "SUPPLEMENTARY_CARD","status":"DECLINED"}';
                }
                system.debug('---> BODY IN DECLINE --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request in DECLINE --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                }
                else
                {
                    System.debug(response.getBody());
                    objCase.Status = 'Closed';
                    objCase.Sub_Status__c = 'Declined';
                    objCase.cc_CRM_Stage__c = 'DECLINED';
                    objCase.Awaiting_Customer_Feedback__c = false;
                    //CH37: Start
                     objCase.cc_Customer_Response__c  = '';
                    //CH37: END
                    
                    if(objCase.cc_CEO_Result__c == 'Decline'){
                        //CH31: Start
                        //CH38: Start
                        if((objCase.Type == 'Credit Card Application' || objCase.Type == 'Credit Limit Increase Application') /*&& objCase.Reapplying_Restriction_Period__c != null*/){
                            Account acc = restrictAccountToApplyCard(objCase,objCase.AccountId);
                            accListToUpdateRestrictCreditCard.add(acc);
                        }
                        //CH38: END
                        //CH31: END
                        objCase.cc_CEO_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit CEO';
                    }
                    if(objCase.cc_Credit_Approval_Result__c == 'Decline'){
                        //CH31: Start
                        //CH38: Start
                        if((objCase.Type == 'Credit Card Application' || objCase.Type == 'Credit Limit Increase Application') /*&& objCase.Reapplying_Restriction_Period__c != null*/){
                            Account acc = restrictAccountToApplyCard(objCase,objCase.AccountId);
                            accListToUpdateRestrictCreditCard.add(acc);
                        }
                        //CH38: END
                        //CH31: END
                        objCase.cc_Credit_Approval_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Approval';
                    }
                    if(objCase.cc_HR_Result__c == 'Decline')
                        objCase.cc_HR_Result_Date_Time__c = system.now();
                    if(objCase.cc_Business_Approval_Result__c == 'Decline'){
                        //CH31: Start
                        //CH38: Start
                        if((objCase.Type == 'Credit Card Application' || objCase.Type == 'Credit Limit Increase Application') /*&& objCase.Reapplying_Restriction_Period__c != null*/){
                            Account acc = restrictAccountToApplyCard(objCase,objCase.AccountId);
                            accListToUpdateRestrictCreditCard.add(acc);
                        }
                        //CH38: END
                        //CH31: END
                        objCase.cc_Business_Approval_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Business Team';
                    }
                   
                    if(objCase.cc_Credit_Evaluation_Result__c == 'Decline'){
                        //CH31: Start
                        //CH38: Start
                        if((objCase.Type == 'Credit Card Application' || objCase.Type == 'Credit Limit Increase Application') /*&& objCase.Reapplying_Restriction_Period__c != null*/){
                            Account acc = restrictAccountToApplyCard(objCase,objCase.AccountId);
                            accListToUpdateRestrictCreditCard.add(acc);
                        }
                        //CH38: END
                        //CH31: END
                        objCase.cc_Credit_Evaluation_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Evaluation';
                    }
                    if(objCase.cc_Credit_Verification_Result__c == 'Decline'){
                        //CH31: Start
                        //CH38: Start
                        if((objCase.Type == 'Credit Card Application' || objCase.Type == 'Credit Limit Increase Application') /*&& objCase.Reapplying_Restriction_Period__c != null*/){
                            Account acc = restrictAccountToApplyCard(objCase,objCase.AccountId);
                            accListToUpdateRestrictCreditCard.add(acc);
                        }
                        //CH38: END
                        //CH31: END
                        objCase.cc_Credit_Verification_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Verification';
                    }
                    if(objCase.cc_Credit_Pre_Screening_Result__c == 'Decline'){
                        //CH31: Start
                        //CH38: Start
                        if((objCase.Type == 'Credit Card Application' || objCase.Type == 'Credit Limit Increase Application') /*&& objCase.Reapplying_Restriction_Period__c != null*/){
                            Account acc = restrictAccountToApplyCard(objCase,objCase.AccountId);
                            accListToUpdateRestrictCreditCard.add(acc);
                        }
                        //CH38: END
                        //CH31: END
                        objCase.cc_Credit_Pre_Screening_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Pre-Screening';
                    }
                    if(objCase.cc_Maker__c == 'Decline'){
                        objCase.cc_Maker_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Maker';
                    }
                    //CH23:Start
                    if(objCase.Fraud_Results__c == 'Decline'){
                        //CH31: Start
                        //CH38: Start
                        if((objCase.Type == 'Credit Card Application' || objCase.Type == 'Credit Limit Increase Application') /*&& objCase.Reapplying_Restriction_Period__c != null*/){
                            Account acc = restrictAccountToApplyCard(objCase,objCase.AccountId);
                            accListToUpdateRestrictCreditCard.add(acc);
                        }
                        //CH38: END
                        //CH31: END
                        objCase.Fraud_Results_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Fraud Team';
                    }
                    //CH23: END
                    //CH25: Start
                    if(objCase.cc_Signature_Verifier_Result__c == 'Decline'){
                        //CH31: Start
                        //CH38: Start
                        if((objCase.Type == 'Credit Card Application' || objCase.Type == 'Credit Limit Increase Application') /*&& objCase.Reapplying_Restriction_Period__c != null*/){
                            Account acc = restrictAccountToApplyCard(objCase,objCase.AccountId);
                            accListToUpdateRestrictCreditCard.add(acc);
                        }
                        //CH38: END
                        //CH31: END
                        objCase.cc_Signature_Verification_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Signature Verification';
                    }
                    //CH25: END
                    
                    lstUpdateCase.add(objCase);
                }
            }
            //CH23: Added a condition Fraud Result == Cancelled by Customer in if condition
            //CH25: Added a condition Signature Verifier Result == Cancelled by Customer in if condition
            else if(objCase.cc_Credit_Approval_Result__c == 'Cancelled by Customer' || objCase.cc_HR_Result__c == 'Cancelled by Customer' || objCase.cc_Credit_Evaluation_Result__c == 'Cancelled by Customer' || objCase.cc_Credit_Verification_Result__c == 'Cancelled by Customer' || objCase.cc_Credit_Pre_Screening_Result__c == 'Cancelled by Customer' || objCase.cc_Maker__c == 'Cancelled by Customer' || objCase.Fraud_Results__c == 'Cancelled by Customer' || objCase.cc_Signature_Verifier_Result__c == 'Cancelled by Customer'){
                if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){
                    //CH12: Start
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                        '","status":"CANCELLED"}';
                    //CH12: END
                }
                //#CH21:START
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='permanent'){
                    //CH12: Start
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                        '","targetType": "LIMIT_INCREASE","status":"CANCELLED"}';
                    //CH12: END
                }
                 if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase'&& objCase.cc_Request_Type__c=='temporary'){
                    //CH12: Start
                    body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","targetType": "LIMIT_INCREASE","status":"CANCELLED","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                    //CH12: END
                }
                  //#CH21:END
                if(objCase.Type == 'Credit Card Supplementary Application' && objCase.Sub_Type__c == 'New Supplementary Card'){
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                        '","targetType": "SUPPLEMENTARY_CARD","status":"CANCELLED"}';
                }
                system.debug('---> BODY IN CANCELLED --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request in CANCEL --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200)
                {
                    if(objCase.cc_Credit_Approval_Result__c == 'Cancelled by Customer')
                        objCase.cc_Credit_Approval_Result__c = '';
                    if(objCase.cc_HR_Result__c == 'Cancelled by Customer')
                        objCase.cc_HR_Result__c = '';
                    if(objCase.cc_Credit_Evaluation_Result__c == 'Cancelled by Customer')
                        objCase.cc_Credit_Evaluation_Result__c = '';
                    if(objCase.cc_Credit_Verification_Result__c == 'Cancelled by Customer')
                        objCase.cc_Credit_Verification_Result__c = '';
                    if(objCase.cc_Credit_Pre_Screening_Result__c == 'Cancelled by Customer')
                        objCase.cc_Credit_Pre_Screening_Result__c = '';
                    if(objCase.cc_Maker__c == 'Cancelled by Customer')
                        objCase.cc_Maker__c = '';
                    //CH23: Start
                    if(objCase.Fraud_Results__c == 'Cancelled by Customer')
                        objCase.Fraud_Results__c = '';
                    //CH23: END
                    //CH25: Start
                    if(objCase.cc_Signature_Verifier_Result__c == 'Cancelled by Customer'){
                       objCase.cc_Signature_Verifier_Result__c = '';
                    }
                    //CH25: END
                    
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                }
                else
                {
                    System.debug(response.getBody());
                    objCase.Status = 'Closed';
                    objCase.Sub_Status__c = 'Cancelled';
                    objCase.cc_CRM_Stage__c = 'CANCELLED';
                    //CH37: Start
                     objCase.cc_Customer_Response__c  = '';
                    //CH37: END
                    
                    if(objCase.cc_Credit_Approval_Result__c == 'Cancelled by Customer'){
                        objCase.cc_Credit_Approval_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Approval';
                    }
                    if(objCase.cc_HR_Result__c == 'Cancelled by Customer'){
                        objCase.cc_HR_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit HR Team';
                    }
                    if(objCase.cc_Credit_Evaluation_Result__c == 'Cancelled by Customer'){
                        objCase.cc_Credit_Evaluation_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Evaluation';
                    }
                    if(objCase.cc_Credit_Verification_Result__c == 'Cancelled by Customer'){
                        objCase.cc_Credit_Verification_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Verification';
                    }
                    if(objCase.cc_Credit_Pre_Screening_Result__c == 'Cancelled by Customer'){
                        objCase.cc_Credit_Pre_Screening_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Pre-Screening';
                    }
                    if(objCase.cc_Maker__c == 'Cancelled by Customer'){
                        objCase.cc_Maker_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Maker';
                    }
                    //CH23:Start
                    if(objCase.Fraud_Results__c == 'Cancelled by Customer'){
                        objCase.Fraud_Results_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Fraud Team';
                    }
                    //CH23: END
                    //CH25: Start
                    if(objCase.cc_Signature_Verifier_Result__c == 'Cancelled by Customer'){
                        objCase.cc_Signature_Verification_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Signature Verification';
                    }
                    //CH25: END
                    //CH27: Start
                    if(objCase.LastModifiedBy.Name == 'AWS Integration' && objCase.Type != 'Credit Card Supplementary Application'){
                        objCase.Alias_account__c = 'API';
                    }
                    else if(objCase.LastModifiedBy.Name != 'AWS Integration' && objCase.Type != 'Credit Card Supplementary Application'){
                        objCase.Alias_account__c = 'Manual';
                    }
                    //CH27: END
                    lstUpdateCase.add(objCase);
                }
            }
            else if(objCase.cc_Credit_Pre_Screening_Result__c == 'Expired' || objCase.Sub_Status__c == 'Expired'){
                if(objCase.Type == 'Credit Card Application' && objCase.Sub_Type__c == 'New Credit Card'){
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","status":"EXPIRED"}';
                }
                //CH21#:START
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c=='permanent'){
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","targetType": "LIMIT_INCREASE","status":"EXPIRED"}';
                }
                if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase'&& objCase.cc_Request_Type__c=='temporary'){
                    body = '{"crmCaseId": "'+objCase.Id +
                                '","targetType": "LIMIT_INCREASE","status":"EXPIRED","requestType":"temporary","duration":"'+objCase.cc_Temporary_Limit_Increase_Duration__c+'"}';
                }
                //CH21#:END
                if(objCase.Type == 'Credit Card Supplementary Application' && objCase.Sub_Type__c == 'New Supplementary Card'){
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","targetType": "SUPPLEMENTARY_CARD","status":"EXPIRED"}';
                }
                system.debug('---> BODY IN EXPIRE--> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request IN EXPIRE--> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH29: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                }
                else
                {
                    System.debug(response.getBody());
                    objCase.Status = 'Closed';
                    objCase.Sub_Status__c = 'Expired';
                    objCase.cc_CRM_Stage__c = 'EXPIRED';
                    if(objcase.cc_Credit_Pre_Screening_Result__c == 'Expired'){
                        objCase.cc_Credit_Pre_Screening_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Pre-Screening';
                    }
                    lstUpdateCase.add(objCase);
                }
            }
        }
        if(lstUpdateCase.size()>0)
            update lstUpdateCase;
        if(lstSA.size()>0)
            insert lstSA;
        if(lstSuppCard.size()>0)
            insert lstSuppCard;
        //CH28: Start
        if(lstPremiumInvitationCaseToInsert.size()>0){
            insert lstPremiumInvitationCaseToInsert;
        }
        //CH28: END
        //CH31: Start
        if(accListToUpdateRestrictCreditCard.size()>0){
            update accListToUpdateRestrictCreditCard;
        }
        //CH31: END
        //CH43: Start
        if(setUpgradeCaseToInsert.size()>0){
            //insert lstUpgradeCaseToInsert;
            CreateUpgradeCases upgCse = new CreateUpgradeCases(setUpgradeCaseToInsert);
            System.enqueueJob(upgCse);
        }
        //CH43: END
    }
    //CH31: Start
    public static Account restrictAccountToApplyCard(Case objCase, Id accId){
		Account acc = new Account(Id = accId);
		acc.Reapplying_Restriction_Last_Update_Date__pc = system.now();
        if(objCase.Reapplying_Restriction_Period__c != null){
            acc.Reapplying_Restriction_Period__pc = objCase.Reapplying_Restriction_Period__c;
        }else if(objCase.Reapplying_Restriction_Period__c == null){
            acc.Reapplying_Restriction_Period__pc = '1 Month';
        }
    	//acc.Reapplying_Restriction_Period__pc = objCase.Reapplying_Restriction_Period__c;
		return acc;
	}
    //CH31: END
    ////////////////////////////////Activate Credit Card Reminders //////////////////////////////////////////////
    
    //CH43: Start
    /*@future(callout=true)
    public static void CCCaseActivateReminders(Set<Id> setCaseId)
    {
        List<Case> lstUpdateCase = new List<Case>();
        List<Case> lstCase = [Select id, status, Type, Account.PersonEmail, Customer_CIF__c, Activate_CreditCard_Reminders__c from Case where id in: setCaseId];
        for(Case caseObj : lstCase)
        {
            caseObj.Activate_CreditCard_Reminders__c = true;
            lstUpdateCase.add(caseObj);
        }
        if(lstUpdateCase.size()>0)
            update lstUpdateCase;
    }*/
    //CH43: END
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////// Stop Jamiyah Case Closure//////////////////////////////////
    
    @future(callout=true)
    public static void stopJamiyahCase(Set<Id> setCaseId)
    {
        List<Case> lstCaseUpdate = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        //CH14 : add Case_Model__c to soql query
        List<Case> lstCase = [Select id, status, Type, Account.PersonEmail, Account.CIF__pc,Customer_CIF__c, Jamiyah_Id__c, Region_Flag__c, Case_Model__c from Case where id in: setCaseId];
        for(Case caseObj : lstCase)
        {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //CH14 -Start:  
            String regionName = caseObj.Region_Flag__c; 
            if(caseObj.Case_Model__c == 'alburaq'){ 
                regionName += '_alburaq';   
            }   
            request = con.createRequest('PUT', '/api/v1/jameya/group/' + caseObj.Jamiyah_Id__c + '/status', regionName);  
            //CH14 -End:
            
            String body = '{"status": "DELETE"}';
            system.debug('---> BODY --> '+body);
            request.setBody(body);
            request.setHeader('userId', caseObj.Account.PersonEmail);
            request.setHeader('customerId', caseObj.Account.CIF__pc);
            request.setHeader('jameyaId', String.ValueOf(caseObj.Jamiyah_Id__c));
            request.setHeader('status', 'DELETE');
            
            system.debug('---> Request --> '+request.getBody());
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() != 200)
            {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                //CH29: Added isAPIFailed parameter in the method
                lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/jameya/group/' + caseObj.Jamiyah_Id__c + '/status?language=en&unit=neo','PATCH',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 'Jmaiyah Application', 'Jamiyah',false);
            }
            else
            {
                System.debug(response.getBody());
                System.debug('response stop jamiyah >>>>' + response);
                caseObj.Status = 'Closed';
                lstCaseUpdate.add(caseObj);
            }
        }
        if(lstCaseUpdate.size()>0)
            update lstCaseUpdate;
        if(lstSA.size()>0)
            insert lstSA;
        
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////
    
    /**
* Shashank 22/03/2021
* eKYC Signoff Case
*/
    @future(callout=true)
    public static void eKYCSignCaseClosure(Set<Id> accIds){
        
        //eKYC signoffAPI call
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Case').getRecordTypeId();
        List<Case> eKYC_UpdateList = new List<Case>();
        //CH14 : add Case_Model__c field to soql query
        List<Case> cases = [SELECT Id, Status, Account.PersonEmail, Account.CIF__pc, OwnerId, Region_Flag__c, Case_Model__c FROM Case WHERE AccountId In:accIds and Subject ='eKYC Signoff' AND RecordTypeId =:recordTypeId];
        
        //Get the queue label for the assignment depending on the region flag
        List<Queue_IDs__mdt> queueIds = [SELECT Id, DeveloperName, Label, Queue_ID__c, MasterLabel, Queue_Name__c, Region__c FROM Queue_IDs__mdt];
        Map<Id, String> caseToRegion = Util.getQueuesCustomMetadata(cases);
        
        for(Case cItem :cases){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //https://api.dev.ilabank.com/api/v1/government-data/wathiq/person/case?language=en&unit=neo
            //CH14 -Start:  
            String regionName = cItem.Region_Flag__c;   
            if(cItem.Case_Model__c == 'alburaq'){   
                regionName += '_alburaq';   
            }   
            //https://api.dev.ilabank.com/api/v1/government-data/wathiq/person/case?language=en&unit=neo    
            request = con.createRequest('PUT', '/api/v1/government-data/wathiq/person/case?', regionName);  
            //CH14 -End:
            
            String body = '{"mockURL":null}';
            
            system.debug('---> BODY --> '+body);
            request.setBody(body);
            request.setHeader('userId', cItem.Account.PersonEmail);
            request.setHeader('customerId', cItem.Account.CIF__pc);
            request.setTimeout(120000);
            
            system.debug('---> Request --> '+request.getBody());
            HttpResponse response = http.send(request);
            system.debug('Account Activation Response Body'+response.getBody());
            system.debug('Account Activation Response Status Code'+response.getStatusCode());
            
            //if API call response == 200 close the case
            if(response.getStatusCode() == 200){
                cItem.Status ='Closed';
                eKYC_UpdateList.add(cItem);
            }else{
                Util.setOwnerQueue(queueIds, caseToRegion, cItem, CONTACT_CENTRE_QUEUE);
                eKYC_UpdateList.add(cItem);
            }
        }
        if(!eKYC_UpdateList.isEmpty()){
            update eKYC_UpdateList;
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////
    /**
* Shashank 22/03/2021
* second BHD Account
*/
    @future(callout=true)
    public static void secondBHDAccountRequest(Set<Id> caseIdSet){
        List<Case> BHDCaseList = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        //CH14 : add Case_Model__c to soql query
        for(Case cItem :[SELECT Id, Status, Sub_Status__c, Customer_CIF__c, Alias_account__c, Currency__c, AccountId, Interest_Option__c, Region_Flag__c, Case_Model__c FROM Case WHERE Id In:caseIdSet]){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //CH14 -Start: 
            String regionName = cItem.Region_Flag__c;
            String templateId ='CA';
            if(cItem.Case_Model__c == 'alburaq'){
                regionName += '_alburaq';
                templateId ='BU';
            }
            request = con.createRequest('POST', '/api/v1/accounts?', regionName);
            //CH14 -End:
            
            
            
            String body = '{"currency": {"code":"'+cItem.Currency__c+'","decimalPlaces": "3"},"templateId":"'+templateId+'",'+
                '"alias":"'+cItem.Alias_account__c+'",'+
                '"earnInterest":"'+cItem.Interest_Option__c+'"}';
            
            system.debug('---> BODY --> '+body);
            request.setTimeout(50000);
            request.setBody(body);
            request.setHeader('customerId', cItem.Customer_CIF__c);
            request.setHeader('x-canary', 'cbs');
            
            system.debug('---> Request --> '+request.getBody());
            HttpResponse response = http.send(request);
            system.debug('Second Account Creation'+response.getBody());
            system.debug('Second Account Creation'+response.getStatusCode());
            
            //if API call response == 201 is for success?
            if(response.getStatusCode() == 201){
                system.debug('cItem.Status|'+cItem.Status+'||cItem.Sub_Status__c|'+cItem.Sub_Status__c);
                cItem.Status ='Closed';
                cItem.Sub_Status__c='Approved';
                BHDCaseList.add(cItem);
            }else{
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                //CH29: Added isAPIFailed parameter in the method
                lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/accounts?language=en&unit=neo','POST',cItem.id,cItem.Customer_CIF__c,cItem.accountId,response.getStatusCode(), 'SECOND BHD Account', 'BHD Account Creation',false);
            }
        }
        if(!BHDCaseList.isEmpty()){
            update BHDCaseList;
        }
        if(!lstSA.isEmpty()){
            insert lstSA;
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////
    /************************************************* ACTIVATE SMS REMINDERS START ***************************************************/
    //CH04 : Start #Jahangeer Mohammed #10-11-2021# Added API Call for SMS Reminders.
    @future(callout=true) 
    public static void sendSMSReminder(Set<Id> CaseId){
        List<System_Action__c> lstSA = new List<System_Action__c>(); 
        //CH14 : add Case_Model__c field to soql query
        for(Case objCase : [SELECT Id,AccountId,Type,Status,Sub_Status__c,Account.CIF__pc,Customer_CIF__c,cc_Email_Address__c,Account.PersonEmail,cc_Mobile_Number__c,cc_signature_sms_sent_flag__c,cc_Email_Sent_Flag__c,cc_SMS_Sent_Flag__c, Region_Flag__c,Case_Model__c FROM Case WHERE Id In:caseId]){
            Http http = new Http(); 
            HttpRequest request1 = new HttpRequest();    
            //CH14 -Start:  
            String regionName = objCase.Region_Flag__c; 
            if(objCase.Case_Model__c == 'alburaq'){ 
                regionName += '_alburaq';   
            }   
            request1 = con.createRequest('POST', '/api/v1/notifications?', regionName);     
            //CH14 -End:
            String sms = 'sms';
            String body = ''; 
            if(objCase.cc_SMS_Sent_Flag__c == true && objCase.Type == 'Credit Limit Increase Application'){
                body = '{"phoneNumber": "'+objCase.cc_Mobile_Number__c + 
                    '","type": "'+sms +
                    '","subject": "'+null +
                    '","templateCode": "CC_LI_REMIND_DOCS"}';
            }
            if(objCase.cc_signature_sms_sent_flag__c == true && objCase.Type == 'Credit Limit Increase Application'){
                body = '{"phoneNumber": "'+objCase.cc_Mobile_Number__c + 
                    '","type": "'+sms +
                    '","subject": "'+null +
                    '","templateCode": "CC_LI_PENDING_SIGNATURE"}';
            }
            if(objCase.cc_SMS_Sent_Flag__c == true && objCase.Type == 'Credit Card Application'){
                body = '{"phoneNumber": "'+objCase.cc_Mobile_Number__c + 
                    '","type": "'+sms +
                    '","subject": "'+null +
                    '","templateCode": "CC_REMIND_DOCS"}';
            }
            if(objCase.cc_signature_sms_sent_flag__c == true && objCase.Type == 'Credit Card Application'){
                body = '{"phoneNumber": "'+objCase.cc_Mobile_Number__c + 
                    '","type": "'+sms +
                    '","subject": "'+null +
                    '","templateCode": "CC_PENDING_SIGNATURE"}';
            }
            system.debug('---> BODY --> '+body);               
            request1.setBody(body);
            request1.setHeader('userId', objCase.Account.PersonEmail);
            request1.setHeader('customerId', objCase.Account.CIF__pc);
            
            system.debug('---> request1 --> '+request1.getBody());
            HttpResponse response1 = http.send(request1);
            if(response1.getStatusCode() != 200){
                System.debug('Invalid Status Code from API');
                //CH29: Added isAPIFailed parameter in the method
                lstSA = createSystemAction(request1.getBody(),response1.getBody(),'callout:NeoBank_Endpoint/api/v1/notifications?language=en&unit=neo','POST',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Application', 'SMS Reminder',false);
                
            }
            else{
                System.debug('Getting Success Status Code from API');
            }
        }
        
    }
    //CH04: END
    /************************************************* ACTIVATE SMS REMINDERS END *****************************************************/
    
    //CH23: Start
    
    /************************************************** START: VISION PLUS PERMANENT CREDIT LIMIT UPDATE BY FRAUD TEAM *****************************************************************/
    
    @future(callout=true) 
    public static void tempLimitIncreaseVisonPlusAPI(Set<Id> CaseId){
        List<System_Action__c> lstSA = new List<System_Action__c>(); 
        List<Case> lstUpdateCase = new List<Case>();
        for(Case objCase : [SELECT Id,AccountId,Type,Sub_Type__c,Status,Sub_Status__c,Account.CIF__pc,Customer_CIF__c,cc_Email_Address__c,Account.PersonEmail,Region_Flag__c,Case_Model__c,
                            Fraud_Results__c,cc_Approved_Temporary_Limit__c,cc_Approved_Temporary_Limit_Expiry_Date__c,cc_Request_Type__c,cc_Credit_Card_PCI_Number__c FROM Case WHERE Id In:caseId]){
            Http http = new Http(); 
            HttpRequest request1 = new HttpRequest();    
             
            String regionName = objCase.Region_Flag__c; 
            if(objCase.Case_Model__c == 'alburaq'){ 
                regionName += '_alburaq';   
            }   
            request1 = con.createRequest('POST', '/api/v1/credit-cards/limit/temporary?', regionName);     
           
            String body = ''; 
            Integer noOfMonths = 1;
            if(objCase.Type == 'Credit Limit Increase Application' && objCase.Sub_Type__c == 'Credit Limit Increase' && objCase.cc_Request_Type__c == 'permanent'){
                
                body = '{"pciNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                    '","temporaryCreditLimit": "'+objCase.cc_Approved_Temporary_Limit__c +
                    '","numberOfMonths": "'+noOfMonths +'"}';
            }
            
            system.debug('---> BODY --> '+body);               
            request1.setBody(body);
            request1.setHeader('userId', objCase.Account.PersonEmail);
            request1.setHeader('customerId', objCase.Account.CIF__pc);
            
            system.debug('---> request1 --> '+request1.getBody());
            HttpResponse response1 = http.send(request1);
            if(response1.getStatusCode() != 200){
                System.debug('Invalid Status Code from API');
                if(objCase.Fraud_Results__c == 'Accept')
                   objCase.Fraud_Results__c = '';
                lstSA = createSystemAction(request1.getBody(),response1.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/limit/temporary?language=en&unit=neo','POST',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Vision Plus Limit Increase', 'Credit Card Limit Increase',false);
                
            }
            else{
                System.debug('Getting Success Status Code from VISION PULSE LIMIT INCREASE UPDATE API:'+response1.getBody());
                Map<String,Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody()); // meta, data
                Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                System.debug('Map Json Data:'+mapJSONData);
                String idExpiryDate = (string)mapJSONData.get('temporaryCreditLimitExpiry');
                Date dateOfExpiry;
                if(String.isNotBlank(idExpiryDate)){
                    dateOfExpiry = Date.valueOf(idExpiryDate);
                    System.debug('ID Expiry Date:'+dateOfExpiry);
                    objCase.cc_Approved_Temporary_Limit_Expiry_Date__c = dateOfExpiry;
                    objCase.Fraud_Results_Date_Time__c = system.now();
                    objCase.cc_Application_Stages__c = 'Credit Fraud Team';
                    lstUpdateCase.add(objCase);
                }

            }
        } //for loop Ends
        if(!lstUpdateCase.isEmpty()){
            update lstUpdateCase;
        }
        if(!lstSA.isEmpty()){
            insert lstSA;
        }
    }
    
    
    /************************************************** END:VISION PLUS PERMANENT CREDIT LIMIT UPDATE BY FRAUD TEAM *****************************************************************/

    //CH23: END
    /**
* @param: method - POST | PUT
* Description : To create a system Action record in case of Failed response
*/
    //CH29: Added isAPIFailed parameter in the method
    public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Final Integer statCode, Final String strAction, Final String strType,Boolean isAPIFailed) {
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
        action.Is_API_Failed__c = isAPIFailed;
        lstSA.add(action);
        
        return lstSA;
        
    }
    
    public static Map<String, Object> getFCRresponse(httpRequest req, Boolean isClosed, Id caseId,String customerID, String actionType){
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Map<String, Object> responseResult = new Map<String, Object>();
        Http http = new Http();
        req.setHeader('customerId', customerID);
        system.debug('--->Customer ID ---> '+customerID);
        HttpResponse response = http.send(req);
        if (response.getStatusCode() != 200) {
            Case caseObj = [SELECT Id,Customer_CIF__c,AccountId FROM Case WHERE Id =:caseId];
            String URLpath;
            if(actionType =='Unfreeze Card' || actionType =='Freeze Card'){
                URLpath='/api/v1/credit-cards/status?';
            }else{
                URLpath=' /api/v1/credit-cards/block/internal?';
            }
            //CH29: Added isAPIFailed parameter in the method
            lstSA = createSystemAction(req.getBody(),response.getBody(),'callout:NeoBank_Endpoint'+URLpath+'language=en&unit=neo','POST',caseId,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 'Credit Card Application', 'FCR',true);
            insert lstSA;
        }
        else{
            if(response.getStatusCode() == 200){
                
                if(isClosed && caseId != NULL){
                    Case cs = new Case(Id=caseId);
                    cs.Status = 'Closed';
                    update cs;
                }
                
                
            }
        }
        
        return responseResult;
    }
    
    // CH20 - Start
    
    /**
* @author Elmustapha
* @description :  future method to update customer Details when he/she has been added/remove to/from DND list and handle the logic to close the case upon success response from API
* @param setCaseId set of case Ids 
* @return void 
*/
    @future(callout=true)
    public static void UpdateCustomerDetailsForDNDupdate(Set<Id> setCaseId){
        
        //ApiConnection con = new ApiConnection();
        List<System_Action__c> lst = new List<System_Action__c>();
        List<Case> casesToUpdate = new List<Case>();
        
        
        List<Case> caseObjList = [SELECT Id,Status , Region_Flag__c, Case_Model__c, Customer_CIF__c,accountId, account.DND__pc, Account.CIF__pc, Account.Personemail, Sub_Type__c,RecordType_DeveloperName__c FROM Case WHERE Id IN : setCaseId ];
        
        for(Case caseObj: caseObjList){
            try{
                String regionName=caseObj.Region_Flag__c;
                if(caseObj.Case_Model__c != null && caseObj.Case_Model__c == 'alburaq'){
                    regionName += '_alburaq';
                }
                System.debug( 'UpdateCustomerDetailsForDNDupdate region name'+ regionName);
                HttpRequest request = con.createRequest('PUT','/api/v1/customers',regionName);
                
                request.setHeader('customerId', caseObj.Account.CIF__pc);
                request.setHeader('userId', caseObj.Account.Personemail);
                
                
                String body = '{"subscription": {'+
                                                '"doNotDisturb":' + caseObj.account.DND__pc+
                                                '},'+
                                '"contactInformation": {'+
                                                    '"email": "'+ caseObj.Account.Personemail + '"'+
                                                '}'+
                                '}';
                
                System.debug( 'UpdateCustomerDetailsForDNDupdate Body: '+body);
                
                //call future method
                request.setTimeout(60000);
                HttpResponse response = SM001_ApiCalls.updateCustomerDetailsAPI(request, Body);
                
                //Call the mock response
                // MCK001_ApiCalls mck = new MCK001_ApiCalls();
                // HttpResponse response = mck.updateCustomerDetailsAPI(request, 200);
                
                system.debug('UpdateCustomerDetailsForDNDupdate status code => ' + response.getStatusCode());
                system.debug('UpdateCustomerDetailsForDNDupdate response => ' + response.getBody());
                
                if (response.getStatusCode() != 200  ) {
                    
                    System.debug(' != 200');
                    System_Action__c actionRecord = SM001_ApiCalls.setSystemAction((String)request.getBody(),response.getBody(),
                                                                                   request.getEndpoint(),request.getMethod(),
                                                                                   caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                                                   'DND LIST - Customer Details API Update', 'DND List add/remove - Customer Details API UpdateI'
                                                                                  );
                    lst.add(actionRecord);
                    
                }else {
                    caseObj.status = 'closed';
                    casesToUpdate.add(caseObj);
                    String emailAlertName = caseObj.Sub_Type__c == 'Add to DND List' ? 'DND_ADD': (caseObj.Sub_Type__c == 'Remove from DND List' ?'DND_REMOVE' :'');
                        
                        // Send email alert to customer
                    Map<String, Object> Params = new Map<String, Object>();
                    Params.put('recordId',caseObj.Id);
                    Params.put('emailAlertName',emailAlertName);
                    Params.put('caseModel',caseObj.Case_Model__c);
                    Params.put('caseRecordTyeName',caseObj.RecordType_DeveloperName__c);
                    //create instance of Interview
                    if(emailAlertName != ''){
                        Flow.Interview.Send_Emails_Alert_Flow stage = new Flow.Interview.Send_Emails_Alert_Flow(Params);
                        //Invoke start method
                        stage.start(); 
                    }
                    
                }
                
            }catch(Exception e){
                caseObj.Last_Api_Call_Status__c = 'Failed';
                casesToUpdate.Add(caseObj);
                //store unexpected errors from system !!
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                System_Action__c actionRecord = SM001_ApiCalls.setSystemAction( e.getMessage(),String.valueOf(e.getStackTraceString()),
                                                                               null,null,
                                                                               caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                                               'please check : InitiateManualOnboarding.UpdateCustomerDetailsForDNDupdate()', 'Add/Remove to/from DND List'
                                                                              );
                lst.add(actionRecord);
            }
        }
        
        if(lst != null && lst.size()>0){
            insert lst;
        }
        if(casesToUpdate != null && casesToUpdate.size()>0){
            update casesToUpdate;
        }
    }
    
    // CH20 - End
}
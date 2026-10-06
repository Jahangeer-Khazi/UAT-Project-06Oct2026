/**
* Handler for Segment API
* @createdDate: 17-07-2020
* @author SP
* Change History :
*  #CH01 : 23-04-2023 requirement Islamic Banking - Premium Segment - CRM Requirements
*  #CH02# #Imane Tsioucha# #17-01-2024# add x-canary header
*  #CH03# #Imane Tsioucha# #14-05-2024# add new logic for staff segment
* 
*/
public virtual class SegmentAPIHandler {
    
    public static String SEGMENT_EP = '/api/v1/segment';
    
    @TestVisible // overwrite instance to provide custom connection in test class
    private static ApiConnection con = new ApiConnection();
    
    @TestVisible // overwrite instance to provide custom DAO in test class
    private static SegmentAPIHandler DAO = new SegmentAPIHandler();
    
    /**
* to load Segment Option /segment/options/crm?language=en&unit=neo
* @author SP
*/
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadSegmentOptionsCRM(String customerId, String caseId, String regionName){
        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
        final HttpRequest req = con.createRequest('GET', SEGMENT_EP + '/options/crm', customerId, regionName);
        if(accs!= null && accs.size()>0){
            System.debug('x-canary added :'+accs.get(0).x_canary__pc);
            if(accs.get(0).x_canary__pc != null){
                req.setHeader('x-canary', accs.get(0).x_canary__pc);
            }
        }
        
        //#CH01 Start
        if(regionName != null && regionName.contains('alburaq')){
            req.setTimeout(60000);
        }
        //#CH01 End
        
        final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, 'Load Segment Options CRM');
        ApiConnection.Response response = con.makeCallout(req, action);
        System.debug(JSON.serializePretty(response));
        if (response.isSuccess && response.responseData != null) {
            Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            
            responseData.put('isUserAuthorizedForDiscount', isUserInLifetimePremiumDiscountQueue());
            
            if (responseData.containsKey('currentSegment')) {
                Map<String, Object> currentSegment = (Map<String, Object>)responseData.get('currentSegment');
                if (currentSegment.containsKey('segmentName')) {
                    String segmentName = (String)currentSegment.get('segmentName');
                    responseData.put('isPremiumSegment', 'PREMIUM'.equalsIgnoreCase(segmentName));
                }
            }
        }
        
        return response;
    }
    
    public static Boolean isUserInLifetimePremiumDiscountQueue() {
        try {
            List<GroupMember> groupMembers = [SELECT Id, UserOrGroupId 
                                              FROM GroupMember 
                                              WHERE Group.DeveloperName = 'Lifetime_Premium_Discount_Queue'
                                              AND UserOrGroupId = :UserInfo.getUserId()];
            return !groupMembers.isEmpty();
        } catch (Exception e) {
            System.debug('Error checking queue membership: ' + e.getMessage());
            return false;
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response upDowngradeSegment(String customerId, String availableCard,
                                                            String discount, String embossName,
                                                            String caseId, String regionName){
                                                                
                                                                Map<String, String> requestObject = new Map<String, String>{
                                                                    'customerId' => customerId,
                                                                        'cardOperation' => 'ISSUE'
                                                                        };
                                                                            
                                                                            if(embossName != null && embossName != ''){
                                                                                requestObject.put('embossName', embossName);
                                                                            }
                                                                
                                                                if(discount != null && discount != '' && discount != 'None'&& discount != 'No Discount'&& discount != 'NO_DISCOUNT'){
                                                                    requestObject.put('discountName', discount);
                                                                }else{
                                                                   requestObject.put('discountName', 'None'); 
                                                                }
                                                                
                                                                if(availableCard != null && availableCard != ''){
                                                                    requestObject.put('newCardProductType', availableCard);
                                                                }
                                                                
                                                                final String requestText = JSON.serialize(requestObject);
                                                                final HttpRequest req = con.createRequest('POST', SEGMENT_EP + '/transition', customerId, regionName);
                                                                
                                                                //#CH02 : start
                                                                List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
                                                                if(accs!= null && accs.size()>0){
                                                                    System.debug('x-canary added :'+accs.get(0).x_canary__pc);
                                                                    if(accs.get(0).x_canary__pc != null){
                                                                        req.setHeader('x-canary', accs.get(0).x_canary__pc);
                                                                    }
                                                                }
                                                                //#CH02 : End
                                                                req.setTimeOut(120000);
                                                                req.setBody(requestText);
                                                                
                                                                final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, 'Upgrade Downgrade Segment');
                                                                ApiConnection.Response response = con.makeCallout(req, action);
                                                                
                                                                return response;
                                                            }
    
    @AuraEnabled
    public static Account updateAccount(Id accountId, String staffId, String staffCorporateEmail){
        Account acc = new Account(Id = accountId, Staff_ID__pc = staffId, Staff_Corporate_Email__pc = staffCorporateEmail, Employment_Type__pc='Staff',Staff_Consent_Direct_Debit__pc=true,Consent_DirectDebit_Timestamp__pc=DateTime.now());
        update acc;
        return acc;
    }
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response updateSegment(String customerId, String newSegmentCRMId, String caseId, String regionName){
        Map<String, String> requestObject = new Map<String, String>();
      if(newSegmentCRMId=='Premium'){
             requestObject = new Map<String, String>{
            'customerId' => customerId,
                'newSegmentCrmId' => newSegmentCRMId,
                'newCardProductType'=>'World'
                };
        }else{
             requestObject = new Map<String, String>{
            'customerId' => customerId,
                'newSegmentCrmId' => newSegmentCRMId
                };
        }
        
                    
                    final String requestText = JSON.serialize(requestObject);
        system.debug('requestText##'+requestText);
        final HttpRequest req = con.createRequest('POST', SEGMENT_EP + '/transition', customerId, regionName);
        
        //#CH02 : start
        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
        if(accs!= null && accs.size()>0){
            System.debug('x-canary added :'+accs.get(0).x_canary__pc);
            if(accs.get(0).x_canary__pc != null){
                req.setHeader('x-canary', accs.get(0).x_canary__pc);
            }
        }
        //#CH02 : End
        
        req.setBody(requestText);
        
        final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, 'Update Segment');
        ApiConnection.Response response = con.makeCallout(req, action);
        
        return response;
    }
    
    //#CH01 Start
    @AuraEnabled(cacheable=false)
    public static void sendToSegmentChangeMaker(String caseId,String currentSegment,String newSegment,String discountName){
        Case objCase = new Case();
        objCase.Id= caseId;
        objCase.asc_Current_Segment__c = currentSegment;
        objCase.asc_New_Segment_Options__c = newSegment;
        objCase.asc_Membership_Discount__c = discountName;
        objCase.isSubmitted__c = true;
        objCase.OwnerId= system.Label.Segment_Change_Maker_Queue;
        update objCase;
    }
    
    @InvocableMethod(label='call Segment Transition API' description='The purpose of this service is to call Segment Transition API after checker result equal to Approve' callout=true )
    public static  List<String> callSegmentTransitionAPIFromFlow(List<Id> caseIds)
        
    {   
        //call future method  
        callSegmentTransitionAPI(new Set<Id>(caseIds));
        return caseIds;
    }
    
    @future(callout=true)
    public static void callSegmentTransitionAPI(Set<Id> caseIds){
        System.debug('call Segment Transition API *****************************');
        System.debug(caseIds);
        List<Case> cases = [SELECT Id,Account.Subscription_Model__pc,Account.CIF__pc,asc_New_Segment_Options__c,Region_Flag__c,Case_Model__c,Customer_CIF__c,accountId,asc_Membership_Discount__c FROM Case WHERE Id IN :caseIds];
        List<System_Action__c> lstSA = new List<System_Action__c>();
        
        for(Case caseObj : cases){
            
            String customerId = caseObj.Account.CIF__pc;
            String regionName = caseObj.Region_Flag__c;
            if(caseObj.Case_Model__c != null && caseObj.Case_Model__c == 'alburaq'){
                regionName+='_alburaq';      
            }
            
            Map<String, String> requestObject = new Map<String, String>{
                'customerId' => customerId,
                    'newSegmentCrmId' => caseObj.asc_New_Segment_Options__c,
                    'discountName' => caseObj.asc_Membership_Discount__c
                    };
                        String requestText = JSON.serialize(requestObject);
            
            
            HttpRequest request = con.createRequest('POST', SEGMENT_EP + '/transition', customerId, regionName);
            
            //#CH02 : start
            List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
            if(accs!= null && accs.size()>0){
                System.debug('x-canary added :'+accs.get(0).x_canary__pc);
                if(accs.get(0).x_canary__pc != null){
                    request.setHeader('x-canary', accs.get(0).x_canary__pc);
                }
            }
            //#CH02 : End
            request.setBody(requestText);
            
            HttpResponse response;
            if (test.isRunningTest()) {
                //fake response 
                response = new HttpResponse();
                response.setStatus('OK');    
                response.setStatusCode(200);
                response.setBody('');
                response.setHeader('Content-Type', 'application/json');
            }else{
                response = new Http().send(request);
            }
            
            lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                     request.getEndpoint(),request.getMethod(),
                                                     caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                     'Calling APi Update Segment for alburaq Customer', 'Update Segment for alburaq Customer'
                                                    ));
            
            if (response.getStatusCode() != 200) {
                caseObj.cc_Checker_Result__c = null;
            } 
            else
            {
                caseObj.Status = 'Closed';
                caseObj.Sub_Status__c = 'Approved';
                caseObj.cc_Checker_Result_Date_Time__c =DateTime.now();
            }
        }  
        
        
        if(cases != null && cases.size()>0){
            update cases;
        } 
        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        } 
    }
    //#CH01 End
    
    @AuraEnabled
    public static ResponseWrapper updateAccountDetails(Id accountId, String staffId, String exitDate, String staffCorporateEmail, Id caseId, String currentSegment) {
        ResponseWrapper response = new ResponseWrapper();
        
        try {
            Id queueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Segment_Change_Checker' LIMIT 1].Id;
            Account accToUpdate;
            
            // Update Account if accountId is provided
            if (accountId != null) {
                accToUpdate = [SELECT Id, Employment_Type__pc, Staff_Consent_Direct_Debit__pc, Consent_DirectDebit_Timestamp__pc
                               FROM Account WHERE Id = :accountId LIMIT 1];
                
                // Update account fields
                accToUpdate.Employment_Type__pc = 'Staff';
                accToUpdate.Staff_Consent_Direct_Debit__pc = true;
                accToUpdate.Consent_DirectDebit_Timestamp__pc = DateTime.now();
                
                update accToUpdate;
            } else {
                System.debug('No accountId provided, skipping account update');
            }
            
            // Update Case if caseId is provided
            if (caseId != null) {
                Case caseToUpdate = [SELECT Id, cc_Staff_Number__c, Updated_Email__c, cc_Maker__c, cc_Maker_Result_Date_Time__c, 
                                     asc_Current_Segment__c, Status, Sub_Status__c, Type, Sub_Type__c, cc_Request_Type__c, 
                                     From_Date__c, Awaiting_Customer_Feedback__c, Reason, BUA_Reason__c 
                                     FROM Case WHERE Id = :caseId LIMIT 1];
                
                caseToUpdate.cc_Maker__c = 'Send to Checker';
                caseToUpdate.Status = 'In Progress';
                caseToUpdate.Sub_Status__c = 'In-Progress';
                caseToUpdate.cc_Maker_Result_Date_Time__c = System.now();
                caseToUpdate.ownerId = queueId;
                caseToUpdate.asc_Current_Segment__c = currentSegment;
                
                // Update staff number if provided
                if (String.isNotBlank(staffId)) {
                    caseToUpdate.cc_Staff_Number__c = staffId;
                } else {
                    System.debug('No staff ID provided, skipping staff number update');
                }
                
                // Update email if provided
                if (String.isNotBlank(staffCorporateEmail)) {
                    caseToUpdate.Updated_Email__c = staffCorporateEmail;
                } else {
                    System.debug('No staff corporate email provided, skipping email update');
                }
                
                if (exitDate != null && exitDate != '') {
                    caseToUpdate.From_Date__c = Date.valueOf(exitDate);
                } else {
                    System.debug('No valid exitDate provided, skipping From_Date__c update');
                }
                
                if (caseToUpdate.Type == 'Account' && caseToUpdate.Sub_Type__c == 'Segment' && 
                    caseToUpdate.cc_Request_Type__c == 'Staff Leaver' && caseToUpdate.From_Date__c != null && 
                    caseToUpdate.From_Date__c > System.today()) {
                        
                        caseToUpdate.Awaiting_Customer_Feedback__c = true;
                        caseToUpdate.BUA_Reason__c = 'Pending on customer response';
                    } else {
                        System.debug('Conditions not met for Awaiting Customer Feedback');
                    }
                
                // Update the case
                try {
                    update caseToUpdate;
                } catch (Exception e) {
                    throw e; // Re-throw to be caught by outer catch block
                }
            } else {
                System.debug('No caseId provided, skipping case update');
            }
            
            // Set success response
            response.isSuccess = true;
            response.message = 'Account and Case updated successfully';
            response.updatedAccount = accToUpdate;
            
        } catch (Exception e) {
            response.isSuccess = false;
            response.message = 'Error: ' + e.getMessage();
        }
        
        return response;
    }
    //#CH03 End 
    
    public class ResponseWrapper {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String message;
        @AuraEnabled public Account updatedAccount;
    }
}
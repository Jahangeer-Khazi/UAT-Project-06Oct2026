/*      
 *      Created By: AITOGRAM Omar
 *      Created Date: 22/04/2026
 *     
 */


public class CaseFawriTransferController {

    private static ApiConnection con = new ApiConnection();

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response getFawriTransferList(final String customerId, String regionName){
        // if (String.isBlank(regionName)) {
        //     regionName = 'Bahrain';
        // }
        
        System.debug('>>>> getFawriTransferList START <<<<');
        System.debug('>>>> customerId: ' + customerId);
        System.debug('>>>> regionName: ' + regionName);

        ApiConnection.Response response = new ApiConnection.Response();
        try {
            String canaryValue;
            List<Account> accounts = [
                SELECT x_canary__pc
                FROM Account
                WHERE CIF__pc = :customerId
                LIMIT 1
            ];
            if (!accounts.isEmpty() && String.isNotBlank(accounts[0].x_canary__pc)) {
                canaryValue = accounts[0].x_canary__pc;
            }

            final String path = '/api/v1/tmsxcontrol/transactions';
            final HttpRequest req = con.createRequest('GET', path, customerId, regionName);
            if (String.isNotBlank(canaryValue)) {
                req.setHeader('x-canary', canaryValue);
            }
            
           
            
            System.debug('>>>> Request Endpoint: ' + req.getEndpoint());
            System.debug('>>>> Request customerId Header: ' + req.getHeader('customerId'));
            //System.debug('>>>> Request x-canary Header: ' + req.getHeader('x-canary'));
            
            response = con.makeCallout(req);
            
            System.debug('>>>> Response isSuccess: ' + response.isSuccess);
            System.debug('>>>> Response Data: ' + response.responseData);
            System.debug('>>>> Response Error Data: ' + response.errorData);

        } catch (Exception e) {
            System.debug('>>>> ERROR in getFawriTransferList: ' + e.getMessage());
            System.debug('>>>> Stack Trace: ' + e.getStackTraceString());
            
            response.isSuccess = false;
            response.errorData = e.getMessage();
        }
        
        System.debug('>>>> getFawriTransferList END <<<<');
        return response;
    }

    
    @AuraEnabled(cacheable=true)
    public static Boolean isUserInCheckerQueue() {
         System.debug('>>>> isUserInCheckerQueue Start  <<<<');
        List<GroupMember> members = [Select Id FROM GroupMember 
                                     WHERE Group.DeveloperName = 'Checker_Fawri_Cancellation' 
                                     AND UserOrGroupId =:UserInfo.getUserId()];
        
        if(members.isEmpty()){
        	return false;    
        }
        
        return true;
    }
    
    @AuraEnabled
    public static Case getCaseDetails(Id recordId) {
        Case caseRecord = [SELECT RecordTypeId, CaseNumber,Closure_Reason__c,
                           Closure_Type__c,Type,Sub_Type__c, cc_Request_Type__c
                           FROM Case WHERE Id = :recordId LIMIT 1];
        return caseRecord;
    }
    
    @AuraEnabled(cacheable=true)
    public static CaseAnnex__c getFawriApiCount(Id recordId){
        return [Select Id,Fawri_Cancel_Api_Count__c 
                FROM CaseAnnex__c where case__c =: recordId];
    }
    
    @AuraEnabled
    public static ApiConnection.Response cancelFawriTransaction(final Id recordId) {
        System.debug('>>>> cancelFawriTransaction START <<<<');
        System.debug('>>>> recordId: ' + recordId);

        ApiConnection.Response response = new ApiConnection.Response();
        
        try {
            // 1. Query Case and related Account to get context and data
            Case caseObj = [SELECT Id, CaseNumber, AccountId, Account.Customer_CIF__c, Account.Region_Flag__c, 
                                   New_Mobile_Number__c, cc_Transaction_Reference_Number__c, Transaction_Date__c,
                                   ccol_Hold_Account_IBAN__c
                           FROM Case WHERE Id = :recordId LIMIT 1];
            
            String customerId = caseObj.Account.Customer_CIF__c;
            String regionName = caseObj.Account.Region_Flag__c;
            
            System.debug('>>>> customerId: ' + customerId);
            System.debug('>>>> regionName: ' + regionName);
            System.debug('>>>> transactions : ' +  caseObj.cc_Transaction_Reference_Number__c);
            System.debug('>>>> batchId: ' + caseObj.New_Mobile_Number__c);
            System.debug('>>>> crmCaseId: ' + caseObj.Id);
            System.debug('>>>> valueDate: ' + caseObj.Transaction_Date__c);
             System.debug('>>>> senderAgentBic: ' + caseObj.ccol_Hold_Account_IBAN__c);

             if (String.isBlank(caseObj.New_Mobile_Number__c)) {
                response.isSuccess = false;
                response.errorData = 'Batch ID is missing from the Case record. The transaction cannot be cancelled.';
                return response;
            }

     
            Map<String, Object> bodyMap = new Map<String, Object>{
                'transactionId' => caseObj.cc_Transaction_Reference_Number__c,
                'batchId' => caseObj.New_Mobile_Number__c,
                'crmCaseId' => caseObj.Id,
                'reasonCode' => 'CANC',
                'reasonDescription' => 'Cancellation Request',
                'valueDate' => String.valueOf(caseObj.Transaction_Date__c),
                'senderAgentBic' => caseObj.ccol_Hold_Account_IBAN__c
            };
            String body = JSON.serialize(bodyMap);

            final String path = '/api/v1/tmsxcontrol/transaction/cancel';
            final HttpRequest req = con.createRequest('PUT', path, customerId, regionName);
            req.setTimeout(60000);
            req.setBody(body);
            
            System.debug('>>>> Request Endpoint: ' + req.getEndpoint());
            System.debug('>>>> Request Body: ' + body);
            
            HttpResponse res = new Http().send(req);
            
            if (res.getStatusCode() == 200) {
                response.isSuccess = true;
                if (String.isNotBlank(res.getBody())) {
                    final Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    response.responseData = resMap.get('data');
                }
            } else {
                response.isSuccess = false;
                try {
                    final Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    response.errorData = resMap.containsKey('meta')? resMap.get('meta') : resMap;
                } catch (Exception ex) {
                    response.errorData = res.getBody();
                }
            }
            
            System.debug('>>>> Response isSuccess: ' + response.isSuccess);
            System.debug('>>>> Response Data: ' + response.responseData);
            System.debug('>>>> Response Error Data: ' + response.errorData);

            // Log System Action
            System_Action__c action = SM001_ApiCalls.setSystemAction(
                req.getBody(), res.getBody(), req.getEndpoint(), 'PUT',
                recordId, customerId, caseObj.AccountId, res.getStatusCode(),
                'Cancel Fawri Transaction', 'Fawri'
            );
            insert action;

            // Update Case status
            caseObj.Last_Api_Call_Status__c = response.isSuccess ? 'Success' : 'Failed';
            update caseObj;

            CaseAnnex__c caseAnnex = [SELECT Id, Fawri_Cancel_Api_Count__c FROM CaseAnnex__c WHERE Case__c = :recordId LIMIT 1];
            if (caseAnnex.Fawri_Cancel_Api_Count__c == null) {
                caseAnnex.Fawri_Cancel_Api_Count__c = 0;
            }
            caseAnnex.Fawri_Cancel_Api_Count__c += 1;
            update caseAnnex;

        } catch (Exception e) {
            System.debug('>>>> ERROR in cancelFawriTransaction: ' + e.getMessage());
            System.debug('>>>> Stack Trace: ' + e.getStackTraceString());
            
            response.isSuccess = false;
            response.errorData = e.getMessage();
        }

        System.debug('>>>> cancelFawriTransaction END <<<<');
        return response;
    }
    
    // @AuraEnabled
    // public static void sendFawriCancellationEmail(Id recordId) {
    //     try {
    //         Case caseRecord = [SELECT Id, AccountId, Account.Contact_ID__pc, Account.PersonEmail, Case_Model__c FROM Case WHERE Id = :recordId LIMIT 1];
    //         if (caseRecord.AccountId != null && caseRecord.Account.PersonEmail != null) {
               
    //             OrgWideEmailAddress owe = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'support@ilabank.com' LIMIT 1];
         
    //             List<EmailTemplate> etList = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Fawri_Cancellation_Pending_Transfer' OR Name = 'Fawri Cancellation Pending Transfer' LIMIT 1];
                
    //             if(!etList.isEmpty()){
    //                 Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    //                 email.setTemplateId(etList[0].Id);
    //                 email.setTargetObjectId(caseRecord.Account.Contact_ID__pc);
    //                 email.setWhatId(caseRecord.Id);
    //                 if (owe != null) {
    //                     email.setOrgWideEmailAddressId(owe.Id);
    //                 }
    //                 Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    //             }
    //         }
    //     } catch (Exception e) {
    //         System.debug('Error sending Fawri cancellation email: ' + e.getMessage());
    //         throw new AuraHandledException('Error sending email: ' + e.getMessage());
    //     }
    // }
    @AuraEnabled
    public static void sendFawriCancellationEmail(Id recordId) {
    try {
        Case caseRecord = [SELECT Id, AccountId, Account.Contact_ID__pc, Account.PersonEmail, Case_Model__c FROM Case WHERE Id = :recordId LIMIT 1];
        if (caseRecord.AccountId != null && caseRecord.Account.PersonEmail != null) {

            OrgWideEmailAddress owe = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'support@ilabank.com' LIMIT 1];

            String developerName;
            String templateName;

            if (caseRecord.Case_Model__c == 'ila') {
                developerName = 'Fawri_Cancellation_Pending_Transfer';
                templateName = 'Fawri Cancellation Pending Transfer';
            } else {
                developerName = 'Fawri_Cancellation_Pending_Transfer_Alburaq';
                templateName = 'Fawri Cancellation Pending Transfer Alburaq';
            }

            List<EmailTemplate> etList = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :developerName OR Name = :templateName LIMIT 1];

            if (!etList.isEmpty()) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(etList[0].Id);
                email.setTargetObjectId(caseRecord.Account.Contact_ID__pc);
                email.setWhatId(caseRecord.Id);
                if (owe != null) {
                    email.setOrgWideEmailAddressId(owe.Id);
                }
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
        }
    } catch (Exception e) {
        System.debug('Error sending Fawri cancellation email: ' + e.getMessage());
        throw new AuraHandledException('Error sending email: ' + e.getMessage());
    }
}
}
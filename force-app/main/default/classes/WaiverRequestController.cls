/********************************************************************************************
* @name                 WaiverRequestController
* @description          This controller is responsible to generate the public link for uploaded file, when Waiver record created.
*						Code coverage of this class is done under WaiverApprovalTriggerHandlerTest
* @date                 23/12/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           23/12/2025     Initial Version
*********************************************************************************************
*/


public class WaiverRequestController {

    @AuraEnabled(cacheable=true)
    public static List<CustomApprovalResponse> getWaiverApprovalHistory(String recordId){
        
        New_Wavier_Approval__c waiverObj = [Select Id,Approved_By__c, Email_Approver_User__c,Email_Approver_User__r.Name FROM New_Wavier_Approval__c WHERE Id = :recordId];
        
        List<ProcessInstanceStep> steps = [SELECT Id,Comments,StepStatus,OriginalActor.Name,ProcessInstance.Status,
                                           ProcessInstance.CreatedDate,ProcessInstance.LastModifiedDate,ActorId,Actor.Name
                                           FROM ProcessInstanceStep
                                           WHERE ProcessInstance.TargetObjectId =: recordId ORDER BY CreatedDate DESC];
        
        List<CustomApprovalResponse> response = new List<CustomApprovalResponse>();
        
        for(ProcessInstanceStep step : steps){
            CustomApprovalResponse res = new CustomApprovalResponse();
            
            res.comments = step.Comments;
            res.originalApprover = step.OriginalActor.Name;
            res.status = step.StepStatus;
            res.dtTime = step.ProcessInstance.LastModifiedDate;
            res.currentApprover = step.Actor.Name;
            if(step.StepStatus == 'Approved' || step.StepStatus == 'Rejected'){
                //checking if record is approved through email service.
                if(!String.isEmpty(waiverObj.Approved_By__c)){
                    res.currentApprover = waiverObj.Approved_By__c;
                }
            }
            
            response.add(res);
        }
        return response;
    }
    
    @AuraEnabled(cacheable=false)
    public static string createWaiverRequest(String jsonFieldData,List<String> documentIds){
        Map<String,Object> fieldMap = (Map<String,Object>)JSON.deserializeUnTyped(jsonFieldData);
        String recordId = '';
        try {
        	New_Wavier_Approval__c waiver = new New_Wavier_Approval__c();
            waiver.Customer__c = (String)fieldMap.get('accountId');
            waiver.Subject__c = (String)fieldMap.get('subject');
            waiver.Description__c = (String)fieldMap.get('description');
            waiver.Case_Model__c = (String)fieldMap.get('caseModel');
            waiver.Type__c = (String)fieldMap.get('type');
            waiver.Sub_Type__c = (String)fieldMap.get('subType');
            waiver.Request_Type__c = (String)fieldMap.get('requestType');
            waiver.Case_Origin__c = (String)fieldMap.get('caseOrigin');
            String amount = (String)fieldMap.get('claimAmount');
            waiver.ContentDocumentId__c = (String)fieldMap.get('contentDocumentId');
            waiver.Claim_Amount__c = Decimal.valueOf(amount);
            waiver.Transaction_Reference_Number__c = (String) fieldMap.get('transactionRefNumber');
            
            insert waiver;
            recordId = waiver.Id;
            
            //If there is a file selected while creating waiver the below code executed.
            if(!String.isEmpty(waiver.ContentDocumentId__c)){
                
                
            	List<ContentDocumentLink> cdLinksToDelete = new List<ContentDocumentLink>();
                for(ContentDocumentLink cdl : [Select Id,ShareType FROM ContentDocumentLink WHERE 
                                               contentDocumentId IN : documentIds AND LinkedEntityId =:waiver.Customer__c]){
                    if(cdl.ShareType == 'V'){
                        cdLinksToDelete.add(cdl);
                    }
                }
                
                if(!cdLinksToDelete.isEmpty()){
                   //Delete the contentlink record for account, when file was uploaded it associated with account record 
                   //as aura file component directly upload file prior of waiver record creating, so we gave account id reference
                   //now that reference would be deleted and actual record would be linked to uploaded file.
                   delete cdLinksToDelete; 
                }
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = waiver.contentDocumentId__c;
                cdl.LinkedEntityId = waiver.Id;
                cdl.ShareType = 'V';
                insert cdl;    
            }
            
        }
        catch(Exception ex){
            System.debug('Ex ' + ex);
            System.debug('Ex message ' + ex.getMessage());
            throw ex;
        }
    	return '{\"status\":\"success\",\"recordId\":\"' + recordId + '\"}';
    }
    
    /*
    @AuraEnabled(cacheable=false)
    public static string sendReminderEmail(String recordId){
        
        Set<Id> waiverDocumentIds = new Set<Id>();
        
        List<New_Wavier_Approval__c> waiverList = [Select Id FROM New_Wavier_Approval__c 
                                                   WHERE Id =: recordId AND 
                                                   Wavier_Level__c  like 'Waiver Level%'];
        
        if(!waiverList.isEmpty()){
            //checking if file is also uploaded.
            if(!String.isBlank(waiverList[0].ContentDocumentId__c)){
                waiverDocumentIds.add(waiverList[0].ContentDocumentId__c);
            }
        }
        
        return '';
    }*/
    
    @AuraEnabled(cacheable=false)
    public static String validateFileSize(String contentDoumentId){
        List<ContentDocument> docs = [SELECT Id,ContentSize 
                                     FROM ContentDocument WHERE Id =: contentDoumentId limit 1];
        Long maxFileSize = 15728640;//default size is 15MB
        if(!docs.isEmpty()){
            if (!String.isBlank(Label.Waiver_File_Size_Limit)) {
                maxFileSize = Long.valueOf(Label.Waiver_File_Size_Limit);
            }
            
            if(docs[0].ContentSize > maxFileSize){
                try {
                	delete docs;
                    Long sizee = maxFileSize / (1024*1024);
                    return 'File size cannot be more than ' + sizee + 'MB';
            	}
                catch(Exception ex){
                    return ex.getMessage();
                }
            }
        }
        return 'success';
    }
    
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadAccountList(String customerId,Boolean isAlburaq) {
        
        ApiConnection con = new ApiConnection();
        List<Account> accountList = [SELECT Id,CIF__pc,x_canary__pc,Region_Flag__c,Subscription_Model__pc 
                                     FROM Account 
                                     WHERE Id =:customerId];
        
        
        String path = '/api/v1/accounts?returnedAccounts=default,HY';// '/api/v1/accounts?returnedAccounts=ALL';
        
        
        ApiConnection.Response response;
        
        if(!accountList.isEmpty()){
            
        
            String regionName = accountList[0].Region_Flag__c;
            
            if(isAlburaq){
                regionName += '_alburaq';
            }
            
            HttpRequest req = con.createRequest('GET', path, accountList[0].CIF__pc, regionName);
            
            if(accountList[0].x_canary__pc != null){
                req.setHeader('x-canary', accountList[0].x_canary__pc);
            }
            
            response = con.makeCallout(req);
            
            List<String> sensitiveFieldsAccountList = new List<String>{
                'account.availableBalance',
                'account.ledgerBalance'
            };
                
            if (response.isSuccess && null != response.responseData) {
                final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
                final Object[] accounts = (Object[])responseData.get('accounts');
                if (SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)) {
                    SensitiveDataCleaner.removeSensitiveData(accounts, sensitiveFieldsAccountList);
                }
            }
            System.debug('loadAccountList##'+response);
            return response;
        }
        else {
			return response;            
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadAccountTransactions(final String customerId,final String caseModel,final String searchParametersJson) {
     
         List<String> sensitiveFieldsAccountList = new List<String>{
             'account.availableBalance',
             'account.ledgerBalance',
             'account.ledgerBalance'
         };
             
             
         ApiConnection con = new ApiConnection();
         ApiConnection.Response response;
         
         
         List<Account> accountList = [SELECT Id,x_canary__pc,Region_Flag__c,Subscription_Model__pc FROM Account WHERE CIF__pc =:customerId];
         String regionName = '';
         if(!accountList.isEmpty()){
             
             regionName = accountList[0].Region_Flag__c;
             
             if(caseModel == 'alburaq'){
                regionName += '_alburaq';
            }
             
             String path = '/api/v1/transactions?';
             HttpRequest req = con.createRequest('POST', path, customerId, regionName);
             req.setTimeout(120000);
             req.setBody(searchParametersJson);
             if(accountList.get(0).x_canary__pc != null){
                  req.setHeader('x-canary', accountList.get(0).x_canary__pc);
             }
             
             response = con.makeCallout(req);
             if (response.isSuccess && null != response.responseData) {
                Map<String, Object> responseData = (Map<String, Object>)response.responseData;
                if (SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)) {
                    SensitiveDataCleaner.removeSensitiveData(responseData, sensitiveFieldsAccountList);
                }
              }
         }

         return response;
     }
    
    public class CustomApprovalResponse {
        @AuraEnabled 
        public DateTime dtTime;
        
        @AuraEnabled 
        public String status;
        
        @AuraEnabled 
        public String originalApprover;
        
        @AuraEnabled 
        public String currentApprover;
        
        @AuraEnabled 
        public String comments;
    }
}
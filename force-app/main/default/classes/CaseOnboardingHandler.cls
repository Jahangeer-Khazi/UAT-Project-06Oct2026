/*      Organization : ABC Bank
 *      Created By: Ranjith Raja 
 *      Created Date: 28/10/2025
 *      Change History: 
 *              #CH01# #Ranjith Raja# #28-10-2025# Added Logic for Checker Result Actions
 */

public virtual class CaseOnboardingHandler {
    @TestVisible
    private static ApiConnection con = new ApiConnection();
    public static Map<Id,Account> accountMap;
    public static Map<Id,Id> caseAccountIdMap;
    
    public class CaseRequest {
        public String caseStatus;
        public String email;
        public String caseType;
    }
    
    @InvocableMethod
    public static void handleAfterUpdate(List<Case> newCases) {
        Set<Id> AccountIds = new Set<Id>();
        accountMap = new Map<Id,Account>();
        caseAccountIdMap = new Map<Id,Id>();
        
        for (Case newCase : newCases) {
            if (newCase.RecordType_DeveloperName__c == 'On_Boarding') {
                caseAccountIdMap.put(newCase.Id,newCase.AccountId);
                AccountIds.add(newCase.AccountId);
            }
        }
        
        if (newCases.isEmpty()) {
            System.debug('No cases to process in after update');
            return;
        }
        
        List<Account> accountList = [SELECT Id, Name, Onboarding_Stage__pc, PersonEmail, CIF__pc FROM Account WHERE Id IN: AccountIds];
        
        for(Account acc: accountList) {
            accountMap.put(acc.Id,acc);
        }
        
        for (Case caseToProcess : newCases) {
            processCheckerResult(caseToProcess);
        }
    }
    
    private static void processCheckerResult(Case caseRec) {
        switch on caseRec.cc_Checker_Result__c {
            when 'Wrong Declaration' {
                Account relatedAccount = accountMap.get(caseRec.AccountId);
                
                String requestBody = JSON.serialize(new Map<String, Object>{
                    'caseStatus' => 'Approved',
                    'email' => relatedAccount.PersonEmail,
                    'caseType' => 'EDD'
                });
                
                sendOnboardingContinueRequest(
                    caseRec.Id, relatedAccount.CIF__pc, 'EDD', 
                    requestBody, relatedAccount.PersonEmail, caseRec.Region_Flag__c, 'Approved', caseAccountIdMap
                );
            }
            when 'Closed Rejected' {
                Account relatedAccount = accountMap.get(caseRec.AccountId);
                
                String requestBody = JSON.serialize(new Map<String, Object>{
                    'caseStatus' => 'Rejected',
                    'email' => relatedAccount.PersonEmail,
                    'caseType' => 'EDD'
                });
                
                sendOnboardingContinueRequest(
                    caseRec.Id, relatedAccount.CIF__pc, 'EDD', 
                    requestBody, relatedAccount.PersonEmail, caseRec.Region_Flag__c, 'Rejected', caseAccountIdMap
                );
            }
        }
    }
    
    @future(callout=true)
    public static void sendOnboardingContinueRequest(Id caseId, String customerId, String actionName, String requestBody, String email, String regionName, String status, Map<Id,Id> caseAccIdMap) {
        String path = '/api/v1/onboarding/continue?';     
        
        HttpRequest req = con.createRequest('POST', path, customerId, email, regionName);
        req.setBody(requestBody);
        
        System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, actionName);
        action.Type__c = 'Onboarding';
        
        ApiConnection.Response responseValue = makeCalloutSync(req, action);
        
        if (responseValue.isSuccess) {
            if (status == 'Approved') {
                updateCaseStatus(caseId, 'Approved', '', '', caseAccIdMap);
            } else if (status == 'Rejected') {
                updateCaseStatus(caseId, 'Rejected', 'Closed Rejected', 'Failed to provide Documents on time', caseAccIdMap);
            }
        } else {
            System.debug('API call failed for case: ' + caseId + ' - ' + responseValue.errorData);
        }
    }
    
    public static ApiConnection.Response makeCalloutSync(HttpRequest req, System_Action__c action) {
        try {
            Http http = new Http();
            HttpResponse response = http.send(req);
            
            ApiConnection.Response apiResponse = new ApiConnection.Response();
            apiResponse.isSuccess = (response.getStatusCode() >= 200 && response.getStatusCode() < 300);
            
            action.HTTP_Response_Code__c = response.getStatusCode();
            action.Response_Body__c = response.getBody();
            insert action;
            
            return apiResponse;
            
        } catch (Exception e) {
            ApiConnection.Response apiResponse = new ApiConnection.Response();
            apiResponse.isSuccess = false;
            apiResponse.errorData = e.getMessage();
            return apiResponse;
        }
    }
    
    public static ApiConnection.Response updateCaseStatus(Id caseId, String status, String closureType, String rejectReason, Map<Id,Id> caseAccIdMap) {
        Case caseRec = new Case(Id = caseId, Status = status);
        List<SObject> recordsToUpdate = new List<SObject>();
        recordsToUpdate.add(caseRec);
        
        if (status == 'Rejected') {
            caseRec.Closure_Type__c = closureType;
            caseRec.Case_Reject_Reason__c = rejectReason;
        } else if (status == 'Approved') {
            if (caseAccIdMap != null && caseAccIdMap.containsKey(caseId)) {
                Id accountId = caseAccIdMap.get(caseId);
                Account accRec = new Account(Id = accountId, PEP_Self_Declaration__pc = false);
                recordsToUpdate.add(accRec);
            }
        }
        
        List<String> errors = updateRecords(recordsToUpdate);
        ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = errors.isEmpty();
        response.errorData = JSON.serialize(errors);
        
        if (!errors.isEmpty()) {
            System.debug('Record update failed: ' + caseId + ' - ' + errors);
        } else {
            System.debug('Record update successful: ' + caseId);
        }
        
        return response;
    }
    
    public static List<String> updateRecords(List<SObject> recs) {
        List<String> errors = new List<String>();
        
        for (Database.SaveResult res : Database.update(recs, false)) {
            if (!res.isSuccess()) {
                errors.add(res.getErrors()[0].getMessage());
            }
        }
        
        return errors;
    }
}
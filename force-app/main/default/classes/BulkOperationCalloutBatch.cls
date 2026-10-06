public class BulkOperationCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    private Set<Id> bulkOperationIds;
    private String operationType;
    private Boolean isUnblockOperation;
    private Set<String> allowedProfiles = new Set<String>{'ila Risk', 'RMT', 'Contact Centre', 'System Administrator'};
    private Id internalCaseRecordTypeId;
    public String profName;
    
    public BulkOperationCalloutBatch(Set<Id> bulkOperationIds, String operationType) {
        this.bulkOperationIds = bulkOperationIds;
        this.operationType = operationType;
        this.isUnblockOperation = operationType == 'Unblock Account';
        this.internalCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Case').getRecordTypeId();
        System.debug('Constructor called with operationType: ' + operationType + ', isUnblockOperation: ' + isUnblockOperation + ', bulkOperationIds: ' + bulkOperationIds);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Start method called');
        return Database.getQueryLocator([
            SELECT Id, Customer__r.Region_Flag__pc, Model__c, CIF__c, Customer__c, Status__c, 
            Customer__r.PersonContactId, Customer__r.PersonEmail, IBAN__c, Sub_Type__c, All_Accounts__c 
            FROM Bulk_Operation_Detail__c 
            WHERE Bulk_Operation__c IN :bulkOperationIds
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Bulk_Operation_Detail__c> details) {
        System.debug('Execute method called with records: ' + details.size());
        
        User currentUser = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        profName = currentUser.Profile.Name;
        System.debug('Current user profile: ' + currentUser.Profile.Name);
        
        List<Bulk_Operation_Detail__c> toUpdate = new List<Bulk_Operation_Detail__c>();
        List<Case> casesToCreate = new List<Case>();
        List<System_Action__c> systemActions = new List<System_Action__c>();
        
        for (Bulk_Operation_Detail__c detail : details) {
            System.debug('Processing detail record Id: ' + detail.Id);
            
            if (isUnblockOperation && !allowedProfiles.contains(currentUser.Profile.Name)) {
                System.debug('Unauthorized unblock attempt for detail Id: ' + detail.Id);
                // systemActions.add(SM001_ApiCalls.setSystemActionWithBOD('Bulk Block/Unblock Accounts','Bulk Block/Unblock Accounts',
                //                                                         'Unauthorized to unblock Account Only the Account blocker are allowed to unblock Account',
                //                                                         'Unauthorized to unblock Account Only the Account blocker are allowed to unblock Account',
                //                                                         detail.id, detail.CIF__c, detail.Customer__c, 400, 
                //                                                         'Bulk Block/Unblock Accounts API', operationType));
                continue;
            }
            
            if (String.isBlank(detail.IBAN__c) && detail.All_Accounts__c == false) {
                System.debug('Skipping record with empty IBAN: ' + detail.Id);
                continue;
            }
            
            try {
                HttpResponse response = makeApiCall(detail);
                System.debug('API Response for detail Id ' + detail.Id + ': ' + response.getBody());
                processResponse(response, detail, toUpdate, casesToCreate);
            } catch(Exception ex) {
                System.debug('Exception during API call for detail Id ' + detail.Id + ': ' + ex.getMessage());
            }
        }
        
        executeDmlOperations(systemActions, toUpdate, casesToCreate);
    }
    
    @TestVisible
    private HttpResponse makeApiCall(Bulk_Operation_Detail__c detail) {
        System.debug('Making API call for detail Id: ' + detail.Id);
        
        String regionName = detail.Customer__r.Region_Flag__pc + (detail.Model__c == 'alburaq' ? '_alburaq' : '');
        String type = getBlockType(detail.Sub_Type__c);
        
        ApiConnection con = new ApiConnection();
        HttpRequest request = con.createRequest('PUT', '/api/v1/accounts/block-unblock', regionName);
        request.setHeader('x-canary', 'cbs');
        request.setHeader('customerId', detail.CIF__c);
        System.debug('request  --->'+request);
        List<String> listIbanObj = createIbanList(detail.IBAN__c);
        String allAccountsValue = detail.All_Accounts__c ? 'true' : 'false';
        
        String body =  '{  "action":'+stringApiFormat(operationType == 'Block Account' ? 'BLOCK' : 'UNBLOCK')+
            ',"type": '+stringApiFormat(type)+
            ',"allAccounts": ' + allAccountsValue +
            ',"accounts": [ '+String.join(listIbanObj,',')+' ]'+
            '}';
        System.debug('body --->'+JSON.serialize(body));
        request.setBody(body);
        
        System.debug('Request Body: ' + body);
        return EM001_ApiCalls.blockUnblockAccountApi(request, 200);
    }
    
    @TestVisible
    private void processResponse(HttpResponse response, Bulk_Operation_Detail__c detail, List<Bulk_Operation_Detail__c> toUpdate, List<Case> casesToCreate) {
        try {
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            Map<String, Object> meta = (Map<String, Object>)responseMap.get('meta');
            System.debug('Parsed API meta response: ' + meta + 'status code:' +response.getStatusCode());
            
            if (response.getStatusCode() == 200 && meta.get('code') == 'ACCO-1011') {
                detail.Status__c = 'Success';
                casesToCreate.add(createCase(detail, 'Account Block/Unblock Activity',profName,'Bulk Block Activity/Customer account blocked, please refer to ila fraud team for any inquiries.'));
                System.debug('Operation Success for detail Id: ' + detail.Id);
            } else {
                detail.Status__c = 'Failed';
                detail.Failure_Reason__c = String.valueOf(meta.get('message'));
                System.debug('Operation Failed for detail Id: ' + detail.Id + ', Reason: ' + detail.Failure_Reason__c);
            }
            toUpdate.add(detail);
        } catch(Exception e) {
            detail.Status__c = 'Failed';
            detail.Failure_Reason__c = 'Error processing API response: ' + e.getMessage();
            toUpdate.add(detail);
            System.debug('Error processing response for detail Id ' + detail.Id + ': ' + e.getMessage());
        }
    }
    
    @TestVisible
    private void executeDmlOperations(List<System_Action__c> systemActions, List<Bulk_Operation_Detail__c> toUpdate, List<Case> casesToCreate) {
        System.debug('Executing DML operations');
        
        try {
            if (!systemActions.isEmpty()) {
                insert systemActions;
                System.debug('Inserted systemActions: ' + systemActions.size());
            }
        } catch(DmlException e) {
            System.debug('Error inserting system actions: ' + e.getMessage());
        }
        
        try {
            if (!toUpdate.isEmpty()) {
                update toUpdate;
                System.debug('Updated Bulk_Operation_Detail__c: ' + toUpdate.size());
            }
        } catch(DmlException e) {
            System.debug('Error updating bulk operation details: ' + e.getMessage());
        }
        
        try {
            if (!casesToCreate.isEmpty()) {
                insert casesToCreate;
                System.debug('Inserted cases: ' + casesToCreate.size());
            }
        } catch(DmlException e) {
            System.debug('Error inserting cases: ' + e.getMessage());
        }
    }
    
    @TestVisible
    private List<String> createIbanList(String ibans) {
        List<String> ibanList = new List<String>();
        if (String.isNotBlank(ibans)) {
            for (String iban : ibans.split(';')) {
                ibanList.add('{ "iban" : '+stringApiFormat(iban)+' }');
            }
        }
        System.debug('IBAN list created: ' + ibanList);
        return ibanList;
    }
    
    @TestVisible
    private String getBlockType(String subType) {
        String type = '';
        if (subType != null) {
            if(subType == 'Block for debit' || subType == 'Unblock for debit'){
                type = 'DEBIT';
            }else if(subType == 'Block for credit' || subType == 'Unblock for credit'){
                type = 'CREDIT';
            }else if(subType == 'Block for both' || subType == 'Unblock for both'){
                type = 'BOTH';
            }
        }
        System.debug('Determined block type: ' + type);
        return type;
    }
    
    @TestVisible
    private Case createCase(Bulk_Operation_Detail__c detail, String subject, String profileName, String description) {
        Case c = new Case(
            Subject = subject,
            Description = description,
            Comments = 'Based on the Bulk Block Account Activity',
            Type = 'Technical',
            Case_Model__c = 'ila',
            Case_Nature__c = 'Bulk Block',
            Status = 'Closed',
            Sub_status__c = 'Completed',
            Priority = 'High',
            Origin = 'CRM',
            ContactId = detail.Customer__r.PersonContactId,
            AccountId = detail.Customer__c,
            Bulk_Operation_Detail__c = detail.Id,
            RecordTypeId = internalCaseRecordTypeId,
            cbb_BlockStatusB__c = profileName,
            BUA_AccountsInformation__c = detail.IBAN__c
        );
        System.debug('Case created for detail Id: ' + detail.Id);
        return c;
    }
    
    @TestVisible
    public void finish(Database.BatchableContext bc) {
        System.debug('Finish method called');
        
        if (!bulkOperationIds.isEmpty()) {
            List<Bulk_Operation__c> operationsToUpdate = new List<Bulk_Operation__c>();
            for (Id opId : bulkOperationIds) {
                operationsToUpdate.add(new Bulk_Operation__c(
                    Id = opId, 
                    Status__c = 'Closed', 
                    Sub_Status__c = 'Completed',
                    End_Time__c = System.now()
                ));
            }
            
            try {
                update operationsToUpdate;
                System.debug('Bulk operations updated: ' + operationsToUpdate.size());
            } catch(DmlException e) {
                System.debug('Error updating bulk operations: ' + e.getMessage());
            }
        }
    }
    
    @TestVisible
    public static String stringApiFormat(String input){
        if(input != null){
            return '"'+ input +'"';
        }else{
            return 'null';
        }
    }
}
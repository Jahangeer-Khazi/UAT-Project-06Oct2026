/*      Organization : ABC Bank
*      Created By: Ranjith Raja
*      Created Date: 11/08/2024
*      Change History: 
*			   #CH01# #Ranjith Raja# #11-08-2024# Added Logic for Case Assignment Rule
*			   #CH02# #Ranjith Raja# #01-10-2024# Moved the Logic for Assigning Entitlement Ids from CaseHandler to CaseProcessingHandler
*			   #CH03# #Ranjith Raja# #28-10-2024# Added Logic for Clearing Makers and Checkers Comments
*/

public class CaseProcessingHandler {
    // Static variable to control first-time execution
    private static Boolean isFirstExecution = true;
    private static Boolean hasRun = false;
    
    // CH01: Start
    @InvocableMethod
    public static void assignCasesUsingActiveAssignmentRule(List<Id> caseIds) {
        assignCasesUsingCustomAssignmentRule(caseIds);
    }
    
    @future
    public static void assignCasesUsingCustomAssignmentRule(List<Id> caseIds) {
        if (isFirstExecution) {
            isFirstExecution = false; // Set the flag to false to prevent re-entry
            
            AssignmentRule activeAssignmentRule;
            if(!Test.isRunningTest()) {
                activeAssignmentRule = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1];
            }
            
            List<Case> caseListForUpdate = new List<Case>();
            
            // Query the Case records based on the provided caseIds
            List<Case> cases = [SELECT Id FROM Case WHERE Id IN :caseIds];
            
            for (Case currCase : cases) {
                caseListForUpdate.add(new Case(Id = currCase.Id)); // Prepare cases for update
            }
            
            // Set DML options to use the active assignment rule
            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            if(!Test.isRunningTest()) {
                dmlOptions.assignmentRuleHeader.assignmentRuleId = activeAssignmentRule.Id;
            }
            dmlOptions.emailHeader.triggerAutoResponseEmail = true;
            dmlOptions.emailHeader.triggerOtherEmail = true;
            dmlOptions.emailHeader.triggerUserEmail = true;
            
            // Update cases using the assignment rule
            Database.saveResult[] result = Database.update(caseListForUpdate, dmlOptions);
        }
    }
    // CH01: End
    
    // CH02: Start
    public static void assignEntitlement(list<Case> caseNewList , Map<Id,Case> caseOldMap){
        
        List<String> entitlementNames =  new List<String>{'IssueCase_Entitlement', 'MastercardSLA'};
            List<Entitlement> entitlements = [SELECT Id,Name FROM Entitlement WHERE Name IN :entitlementNames];
        
        Map<String, Id> entitlementsMap = new Map<String, Id>();
        
        for(Entitlement entitlement: entitlements){
            entitlementsMap.put(entitlement.Name, entitlement.Id);
        }
        //assign entitlement
        Set<Id> caseIds = new Set<Id>();
        for(Case cs: caseNewList){
            Case oldCase = caseOldMap.get(cs.Id);
            if(cs.ac_Pending_Date__c != null && cs.ac_Pending_Date__c != oldCase.ac_Pending_Date__c){
                if(cs.Sub_Type__c == 'Customer Transaction & Payment Disputes- Mastercard' || (cs.RecordType_DeveloperName__c == 'Case_Disputes_and_Frauds' && cs.Type == 'MasterCard')){
                    caseIds.add(cs.Id);
                    cs.EntitlementId = entitlementsMap.get('MastercardSLA');
                } else if(cs.Sub_Type__c == 'Customer Transaction & Payment Disputes- Benfit' || (cs.RecordType_DeveloperName__c == 'Case_Disputes_and_Frauds' && cs.Type == 'Benefit')){
                    caseIds.add(cs.Id);
                    cs.EntitlementId = entitlementsMap.get('IssueCase_Entitlement');
                }
            }
        }
        //get caseMileStones
        List<CaseMilestone> CaseMilestones = [SELECT Id,StartDate FROM CaseMilestone WHERE CaseId IN :caseIds AND IsCompleted=false];
        DateTime CurrentDate=system.now();
        for(CaseMilestone ml :CaseMilestones){
            ml.StartDate=CurrentDate;
        }
        update caseMileStones;
    }
    // CH02: End
    
    @AuraEnabled
    public static Case getCaseDetails(Id recordId) {
        Case caseRecord = [SELECT RecordTypeId, CaseNumber, Closure_Type__c, ac_Pending_Date__c FROM Case WHERE Id = :recordId LIMIT 1];
        return caseRecord;
    }
    
    // CH03: Start
    public static void clearMakerCheckerComments(Set<Id> caseIds) {
        List<Case> casesToUpdate = new List<Case>();
        
        // Query the cases based on the case IDs
        for (Case caseObj : [SELECT Id, cc_Maker_Comments__c, cc_Checker_Comments__c FROM Case WHERE Id IN :caseIds]) {
            caseObj.cc_Maker_Comments__c = '';  // Clear Maker Comment
            caseObj.cc_Checker_Comments__c = '';  // Clear Checker Comment
            casesToUpdate.add(caseObj);
        }
        
        // Update cases with blank Maker and Checker Comments
        if (!casesToUpdate.isEmpty()) {
            try {
                update casesToUpdate;
            } catch (Exception e) {
                System.debug('Error while updating Maker and Checker Comments: ' + e.getMessage());
            }
        }
    }
    // CH03: End
    
    @TestVisible
    public static void assignEntitlements(List<Case> newList, Map<Id, Case> oldMap) {
        if (hasRun || newList.isEmpty()) return;
        hasRun = true;
        
        // Query all mappings
        List<Case_Entitlement_Mapping__mdt> mappings = [
            SELECT Type__c, Sub_Type__c, Request_Type__c, Segment__c, Entitlement_Name__c, SLA__c 
            FROM Case_Entitlement_Mapping__mdt
        ];
        
        // Get all entitlement names (from static and mappings)
        Set<String> entitlementNames = new Set<String>{'IssueCase_Entitlement', 'MastercardSLA'};
            for (Case_Entitlement_Mapping__mdt m : mappings) {
                entitlementNames.add(m.Entitlement_Name__c);
            }
        
        // Query Entitlements once
        Map<String, Id> entitlementMap = new Map<String, Id>();
        for (Entitlement e : [SELECT Id, Name FROM Entitlement WHERE Name IN :entitlementNames AND Name NOT IN ('001Pw00000MUaG0IALEntitlement3')]) {
            entitlementMap.put(e.Name, e.Id);
        }
        
        // Get Accounts in bulk
        Set<Id> accountIds = new Set<Id>();
        for (Case cs : newList) {
            if (cs.AccountId != null) {
                accountIds.add(cs.AccountId);
            }
        }
        
        Map<Id, Account> accMap = new Map<Id, Account>(
            [SELECT Id, VVIP__pc, Segment__pc FROM Account WHERE Id IN :accountIds]
        );
        
        // Assign entitlement
        for (Case cs : newList) {
            if (cs.EntitlementId != null) continue;
            
            Account acc = accMap.get(cs.AccountId);
            String segment = (acc != null && acc.VVIP__pc) ? 'Premium' : acc?.Segment__pc;
            
            // Match metadata conditions
            List<Case_Entitlement_Mapping__mdt> matched = new List<Case_Entitlement_Mapping__mdt>();
            for (Case_Entitlement_Mapping__mdt m : mappings) {
                if (m.Type__c == cs.Type &&
                    m.Sub_Type__c == cs.Sub_Type__c &&
                    normalize(m.Request_Type__c) == normalize(cs.cc_Request_Type__c)) {
                        matched.add(m);
                    }
            }
            
            // Find best match based on Segment
            Case_Entitlement_Mapping__mdt selected;
            for (Case_Entitlement_Mapping__mdt m : matched) {
                if (m.Segment__c == segment) {
                    selected = m;
                    break;
                }
            }
            
            // Fallback to 'Regular' if not VVIP
            if (selected == null && (acc == null || !acc.VVIP__pc)) {
                for (Case_Entitlement_Mapping__mdt m : matched) {
                    if (m.Segment__c == 'Regular') {
                        selected = m;
                        break;
                    }
                }
            }
            
            // Set entitlement and pass SLA in a temporary custom field
            if (selected != null && entitlementMap.containsKey(selected.Entitlement_Name__c)) {
                System.debug('Entitlement Name- - -- >'+selected.Entitlement_Name__c);
                System.debug('Entitlement Id- - -- >'+entitlementMap.get(selected.Entitlement_Name__c));
                cs.EntitlementId = entitlementMap.get(selected.Entitlement_Name__c);
                cs.SLA__c = selected.SLA__c;
            }
        }
    }
    
    public static void processPostUpdate(List<Case> newList, Map<Id, Case> oldMap) {
        if (newList.isEmpty()) return;
        
        Set<Id> milestoneCaseIds = new Set<Id>();
        Map<Id, Decimal> caseIdToSLA = new Map<Id, Decimal>();
        
        for (Case cs : newList) {
            Case oldCs = oldMap.get(cs.Id);
            Boolean isNewEntitlement = cs.EntitlementId != null && oldCs.EntitlementId == null;
            
            if (isNewEntitlement) {
                milestoneCaseIds.add(cs.Id);
            }
        }
        
        if (!milestoneCaseIds.isEmpty()) {
            if (!Test.isRunningTest()) {
                DynamicCaseReportController.updateRelatedRecordsAsync(milestoneCaseIds, caseIdToSLA);
            }
        }
    }
    
    @TestVisible
    // Normalize to avoid Unicode/whitespace mismatches
    private static String normalize(String input) {
        return input != null
            ? input.trim().replaceAll('[\\u2018\\u2019\\u201C\\u201D]', '\'').replaceAll('[^\\x20-\\x7E]', '')
            : '';
    }
    
    public static void beforeServiceRequestUpdate(List<Case> newList, Map<Id, Case> oldMap) {
        // Get Service Request RecordTypeId once
        Id serviceRequestRecordTypeId = Schema.SObjectType.Case
            .getRecordTypeInfosByDeveloperName()
            .get('Service_Request')
            .getRecordTypeId();
        
        // Get Segment Change - Checker queue once
        Group makerQueue = [
            SELECT Id 
            FROM Group 
            WHERE Type = 'Queue' 
            AND Name = 'Segment Change - Maker' 
            LIMIT 1
        ];
        
        for (Case newCase : newList) {
            Case oldCase = oldMap.get(newCase.Id);
            
            // Only process if Service_Request record type
            if (newCase.RecordTypeId == serviceRequestRecordTypeId) {
                
                // ✅ Approve case → Close
                if (oldCase.cc_Checker_Result__c != 'Approve' 
                    && newCase.cc_Checker_Result__c == 'Approve') {
                        newCase.Status = 'Closed';
                        newCase.Sub_Status__c = 'Closed';
                    }
                
                // ✅ Return to Maker with specific criteria → Reassign owner
                if (oldCase.cc_Checker_Result__c != 'Return to Maker' && newCase.cc_Checker_Result__c == 'Return to Maker'
                    && newCase.Type == 'Account'
                    && newCase.Sub_Type__c == 'Segment'
                    && (newCase.cc_Request_Type__c == 'Staff Joiner' 
                        || newCase.cc_Request_Type__c == 'Staff Leaver')) {
                            newCase.OwnerId = makerQueue.Id;
                            newCase.cc_Maker__c = '';
                        }
            }
        }
    }
    
    
    public static System_Action__c setSystemAction(
        final String reqBody,
        final String resBody,
        final String path,
        final String method,
        final Id caseId,
        final String custId,
        final Id accId,
        final Integer statCode,
        final String strAction,
        final String strType) {

    System_Action__c action = new System_Action__c();
    action.Account_Number__c   = custId;
    action.Action__c           = strAction;
    action.Case__c             = caseId;
    action.Account__c          = accId;
    action.Endpoint__c         = path;
    action.Method__c           = method;
    action.HTTP_Response_Code__c = statCode;
    action.Origin__c           = 'CRM';
    action.Request_Body__c     = reqBody;
    action.Response_Body__c    = resBody;
    action.Target__c           = 'Orchestration Layer';
    action.Type__c             = strType;

    if (strType == 'Prepaid Credit Card') {
        action.Is_API_Failed__c = true;
    }
    return action;
}
    
}
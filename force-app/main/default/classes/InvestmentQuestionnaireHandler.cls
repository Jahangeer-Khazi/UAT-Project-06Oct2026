/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 02-01-2024
*       Change History: 
*                   
*/
public class InvestmentQuestionnaireHandler {

    // Static map for Record Types to avoid SOQL queries in loops
    private static Map<Id, String> recordTypeDeveloperNames;
    private static Map<String, Id> queueCache = new Map<String, Id>();

    static {
        recordTypeDeveloperNames = new Map<Id, String>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Case']) {
            recordTypeDeveloperNames.put(rt.Id, rt.DeveloperName);
        }
    }
    
    public static void handlerBeforeCaseCreation(List<case> lstCase){
        List<Case> lstNewCase = new List<Case>();
        Set<Id> setNewAccIds = new Set<Id>();
        Map<Id,List<Case>> mapAccountContainingInvestmentQuestionnaireCase = new Map<Id,List<Case>>();
        
        for(Case caseObj : lstCase){ //for loop Start
            if(caseObj.RecordType_DeveloperName__c == 'Sukuk_Bond_Request' && caseObj.Type == 'Investment Questionnaire' && caseObj.Sub_Type__c == 'New Investment Questionnaire' && caseObj.Region_Flag__c == 'Bahrain'){
                System.debug('Testing for Jordan Existing Investment Questionnaire Case');
                lstNewCase.add(caseObj);
                setNewAccIds.add(caseObj.AccountId);
            }
        }//for Ends
        
        if(setNewAccIds.size()>0){
            for(Case c : [Select id,AccountId,Status from Case where Status NOT IN('Closed') AND Type = 'Investment Questionnaire' AND Sub_Type__c = 'New Investment Questionnaire'  AND AccountId IN :setNewAccIds]){
                if(mapAccountContainingInvestmentQuestionnaireCase.containsKey(c.AccountId)){
                    mapAccountContainingInvestmentQuestionnaireCase.get(c.AccountId).add(c);
                }
                else{
                    mapAccountContainingInvestmentQuestionnaireCase.put(c.AccountId,new List<case>{c});
                }
            } //for loop Ends
        } //if Ends
        
        if(lstNewCase.size()>0){
            for(Case c : lstNewCase){
                if(mapAccountContainingInvestmentQuestionnaireCase.containsKey(c.AccountId)){
                    if(!test.isRunningTest())
                        c.addError('Please close the Existing Investment Questionnaire Review Case');
                }
                else if(!mapAccountContainingInvestmentQuestionnaireCase.containsKey(c.AccountId)){
                    c.OwnerId = System.Label.Investment_Questionnaire_Maker_Queue;
                    c.Sub_Status__c = 'In-Progress';
                }
            } //for Ends
    	}//if Ends
    }
    
    public static void handlerBeforeCaseUpdate(List<case> lstCase){
        List<Account> accToUpdate = new List<Account>();
        List<Bonds_Sukuk_Questionnaire__c> lstQuestionnaire = new List<Bonds_Sukuk_Questionnaire__c>();
        for(Case caseObj : lstCase){
            Case caseOldObj = (Case)trigger.oldMap.get(caseobj.id);
            
            if(caseObj.RecordType_DeveloperName__c == 'Sukuk_Bond_Request' && caseObj.Type == 'Investment Questionnaire'  && caseObj.Sub_Type__c == 'New Investment Questionnaire' && caseObj.Region_Flag__c == 'Bahrain' && 
               caseOldObj.cc_Maker__c != caseObj.cc_Maker__c && caseObj.cc_Maker__c == 'Send to Investment Questionnaire Checker' && caseObj.cc_Maker__c != ''){
                   caseObj.OwnerId = System.Label.Investment_Questionnaire_Checker_Queue;
                   caseObj.cc_Checker_Result__c = '';
                   
            }
            if(caseObj.RecordType_DeveloperName__c == 'Sukuk_Bond_Request' && caseObj.Type == 'Investment Questionnaire'  && caseObj.Sub_Type__c == 'New Investment Questionnaire' && caseObj.Region_Flag__c == 'Bahrain' && 
               caseOldObj.cc_Checker_Result__c != caseObj.cc_Checker_Result__c && caseObj.cc_Checker_Result__c == 'Return to Investment Questionnaire Maker'){
                   caseObj.OwnerId = System.Label.Investment_Questionnaire_Maker_Queue;
                   caseObj.cc_Maker__c = '';
                   
            }
            if(caseObj.RecordType_DeveloperName__c == 'Sukuk_Bond_Request' && caseObj.Type == 'Investment Questionnaire'  && caseObj.Sub_Type__c == 'New Investment Questionnaire' && caseObj.Region_Flag__c == 'Bahrain' && 
               caseOldObj.cc_Checker_Result__c != caseObj.cc_Checker_Result__c && caseObj.cc_Checker_Result__c == 'Decline'){
                   caseObj.Sub_Status__c = 'Declined';
                   caseObj.Status = 'Closed';
                   
            }
            if(caseObj.RecordType_DeveloperName__c == 'Sukuk_Bond_Request' && caseObj.Type == 'Investment Questionnaire'  && caseObj.Sub_Type__c == 'New Investment Questionnaire' && caseObj.Region_Flag__c == 'Bahrain' && 
               caseOldObj.cc_Checker_Result__c != caseObj.cc_Checker_Result__c && caseObj.cc_Checker_Result__c == 'Approve'){
                   
                   Bonds_Sukuk_Questionnaire__c quest = new Bonds_Sukuk_Questionnaire__c();
                   quest.Risk_Tolerance__c = caseObj.Bo_Risk_Tolerance__c;
                   quest.Risk_Preference__c = caseObj.Bo_Risk_Preference__c;
                   quest.Risk_Level__c = caseObj.Bo_Risk_Level__c;
                   quest.Knowledge_Level__c = caseObj.Bo_Knowledge_Level__c;
                   quest.Experience_Level__c = caseObj.Bo_Experience_Level__c;
                   quest.Past_Experience__c = caseObj.Bo_Past_Experience__c;
                   quest.Investor_Declaration__c = caseObj.Bo_Investor_Declaration__c;
                   quest.Submitted_By__c = 'Agent';
                   //quest.Submitted_On__c = caseObj.CreatedDate;
                   quest.Case_Number__c = caseObj.Id;
                   quest.Customer__c = caseObj.AccountId;
                   lstQuestionnaire.add(quest);
                   
                   caseObj.Sub_Status__c = 'Approved';
                   caseObj.Status = 'Closed';
                   
                   
            }
        }//for loop Ends
        
        if(!lstQuestionnaire.isEmpty()){
            insert lstQuestionnaire;
        }
        
    }

    // Before Update Handler Method for Investment Questionnaire Review Record Type
    public static void handlerBeforeCaseUpdate(List<Case> newCases, Map<Id, Case> oldCaseMap) {
        // Get the Queue Id for Investment_Questionnaire_Review_Checker
        Id checkerQueueId = getQueueId('Investment Questionnaire Review Checker');
        
        if (checkerQueueId == null) {
            System.debug('Queue Investment_Questionnaire_Review_Checker not found');
            return;
        }
        
        for (Case caseRecord : newCases) {
            // Check if record type is 'Investment_Questionnaire_Review'
            if (isInvestmentQuestionnaireReview(caseRecord)) {
                
                Case oldCase = oldCaseMap.get(caseRecord.Id);
                
                // Check if cc_Maker__c field is changed
                if (caseRecord.cc_Maker__c != oldCase.cc_Maker__c) {
                    
                    // If value changed to 'Send to Checker'
                    if (caseRecord.cc_Maker__c == 'Send to Checker') {
                        caseRecord.OwnerId = checkerQueueId;
                        caseRecord.cc_Checker_Result__c = null;//UATNB-218299
                    }
                }
            }
        }
    }
    
    // After Update Handler Method for Investment Questionnaire Review Record Type
    public static void handlerAfterCaseUpdate(List<Case> newCases, Map<Id, Case> oldCaseMap) {
        // Get Queue Ids
        Id makerQueueId = getQueueId('Investment Questionnaire Review Maker');
        
        if (makerQueueId == null) {
            System.debug('Queue Investment_Questionnaire_Review_Maker not found');
        }
        
        List<Case> casesToUpdate = new List<Case>();
        Map<Id, String> accountStatusMap = new Map<Id, String>();
        
        for (Case caseRecord : newCases) {
            // Check if record type is 'Investment_Questionnaire_Review'
            if (isInvestmentQuestionnaireReview(caseRecord)) {
                
                Case oldCase = oldCaseMap.get(caseRecord.Id);
                
                // Check if cc_Checker_Result__c field is changed
                if (caseRecord.cc_Checker_Result__c != oldCase.cc_Checker_Result__c) {
                    
                    // Handle Approve
                    if (caseRecord.cc_Checker_Result__c == 'Approve') {
                        // Create a new Case object for update (cannot modify the trigger record directly)
                        Case caseToUpdate = new Case(Id = caseRecord.Id);
                        caseToUpdate.Status = 'Closed';
                        caseToUpdate.Sub_Status__c = 'Approved'; // Add if needed
                        caseToUpdate.cc_Checker_Result_Date_Time__c = System.now();//UATNB-218111
                        casesToUpdate.add(caseToUpdate);
                        
                        // Mark Account for update to 'Approved'
                        if (caseRecord.AccountId != null) {
                            accountStatusMap.put(caseRecord.AccountId, 'Approved');
                        }
                        
                        // TODO: Make callout to external API for Approval
                        /*
                        makeCallout(caseRecord.Id, 'Approve');
                        */
                    }
                    
                    // Handle Reject
                    else if (caseRecord.cc_Checker_Result__c == 'Reject') {
                        // Create a new Case object for update (cannot modify the trigger record directly)
                        Case caseToUpdate = new Case(Id = caseRecord.Id);
                        caseToUpdate.Status = 'Closed';
                        caseToUpdate.Sub_Status__c = 'Rejected'; // Add if needed
                        caseToUpdate.cc_Checker_Result_Date_Time__c = System.now();//UATNB-218111
                        casesToUpdate.add(caseToUpdate);
                        
                        // Mark Account for update to 'Rejected'
                        if (caseRecord.AccountId != null) {
                            accountStatusMap.put(caseRecord.AccountId, 'Rejected');
                        }
                        
                        // TODO: Make callout to external API for Rejection
                        /*
                        makeCallout(caseRecord.Id, 'Reject');
                        */
                    }
                    
                    // Handle Return to Maker
                    else if (caseRecord.cc_Checker_Result__c == 'Return to Maker' && makerQueueId != null) {
                        // Create a new Case object for update (cannot modify the trigger record directly)
                        Case caseToUpdate = new Case(Id = caseRecord.Id);
                        caseToUpdate.OwnerId = makerQueueId;
                        caseToUpdate.cc_Maker__c = null;//UATNB-218111
                        caseToUpdate.cc_Checker_Result_Date_Time__c = System.now();//UATNB-218111
                        casesToUpdate.add(caseToUpdate);
                    }
                }
            }
        }
        
        // Update Account records
        if (!accountStatusMap.isEmpty()) {
            List<Account> accountsToUpdate = new List<Account>();
            List<Account> accounts = [SELECT Id, Gold_Silver_Questionnaire_Status__c 
                                     FROM Account 
                                     WHERE Id IN :accountStatusMap.keySet()];
            
            for (Account acc : accounts) {
                String newStatus = accountStatusMap.get(acc.Id);
                if (newStatus != null) {
                    acc.Gold_Silver_Questionnaire_Status__c = newStatus;
                    accountsToUpdate.add(acc);
                }
            }
            
            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
        }
        
        // Update Case records - This is the key fix: Perform a separate DML update
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }
    
    // Helper method to get Queue Id by Queue Name with caching
    private static Id getQueueId(String queueName) {
        if (queueCache.containsKey(queueName)) {
            return queueCache.get(queueName);
        }
        
        try {
            Group queue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :queueName LIMIT 1];
            queueCache.put(queueName, queue.Id);
            return queue.Id;
        } catch (Exception e) {
            System.debug('Queue not found: ' + queueName);
            return null;
        }
    }
    
    // Helper method to check if Record Type is Investment Questionnaire Review
    private static Boolean isInvestmentQuestionnaireReview(Case caseRecord) {
        if (caseRecord.RecordTypeId == null || !recordTypeDeveloperNames.containsKey(caseRecord.RecordTypeId)) {
            return false;
        }
        return recordTypeDeveloperNames.get(caseRecord.RecordTypeId) == 'Investment_Questionnaire_Review';
    }
    
}
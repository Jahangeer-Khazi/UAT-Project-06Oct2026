/**
* @File Name : CaseAgingCalculationBatch.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : June 1, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | June 1, 2025 |   | Initial Version
**/

public class CaseAgingCalculationBatch implements Database.Batchable<SObject>, Database.Stateful {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id FROM Case 
            WHERE RecordType.DeveloperName IN 
            ('Case_Disputes_and_Frauds','Complaint','Case_Faults_and_Incidents','Request','Sukuk_Bond_Request')
            AND Status != 'Closed'
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Case> scope) {
        Set<Id> caseIds = new Set<Id>();
        for (Case c : scope) {
            caseIds.add(c.Id);
        }
        processCases(caseIds);
    }
    
    public void finish(Database.BatchableContext bc) {
        String status = 'Calculation Completed';
        Case_Export_Progress__e event = new Case_Export_Progress__e(
            JobId__c = null,
            Status__c = status,
            Progress__c = 100,
            ErrorMessage__c = null,
            Operation_Type__c = 'CALCULATION'
        );
        try {
            Database.SaveResult result = EventBus.publish(event);
            if (!result.isSuccess()) {
                for (Database.Error err : result.getErrors()) {
                    System.debug('Event publish error: ' + err.getMessage());
                }
            }
        } catch (Exception e) {
            System.debug('Error publishing progress event: ' + e.getMessage());
        }
    }
    
    // Core processing logic
    public static void processCases(Set<Id> caseIds) {
        if (caseIds == null || caseIds.isEmpty()) return;
        
        // Get Case Aging records for these cases
        Map<Id, Id> caseToAgingMap = new Map<Id, Id>();
        for (Case_Aging__c aging : [
            SELECT Id, Case__c FROM Case_Aging__c 
            WHERE Case__c IN :caseIds
        ]) {
            caseToAgingMap.put(aging.Case__c, aging.Id);
        }
        
        if (caseToAgingMap.isEmpty()) return;
        
        // Get the latest line item for each Case Aging record
        Map<Id, Case_Aging_Line_Item__c> latestLineItems = new Map<Id, Case_Aging_Line_Item__c>();
        for (Case_Aging_Line_Item__c item : [
            SELECT Id, Case_Aging__c, Time__c, Total_Time__c, CreatedDate
            FROM Case_Aging_Line_Item__c 
            WHERE Case_Aging__c IN :caseToAgingMap.values()
            ORDER BY Case_Aging__c, CreatedDate DESC
        ]) {
            if (!latestLineItems.containsKey(item.Case_Aging__c)) {
                latestLineItems.put(item.Case_Aging__c, item);
            }
        }
        
        // Calculate new Total_Time__c values
        List<Case_Aging_Line_Item__c> itemsToUpdate = new List<Case_Aging_Line_Item__c>();
        DateTime currentTime = System.now();
        
        for (Id agingId : latestLineItems.keySet()) {
            Case_Aging_Line_Item__c item = latestLineItems.get(agingId);
            if (item.Time__c != null) {
                Decimal totalMinutes = (currentTime.getTime() - item.Time__c.getTime()) / (1000 * 60);
                Decimal totalHours = totalMinutes / 60;
                if (item.Total_Time__c != totalHours) {
                    itemsToUpdate.add(new Case_Aging_Line_Item__c(
                        Id = item.Id,
                        Total_Time__c = totalHours
                    ));
                }
            }
        }
        
        // Perform the update if needed
        if (!itemsToUpdate.isEmpty()) {
            update itemsToUpdate;
        }
    }
}
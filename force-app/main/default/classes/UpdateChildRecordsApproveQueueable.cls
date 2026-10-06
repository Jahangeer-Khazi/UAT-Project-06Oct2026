public class UpdateChildRecordsApproveQueueable implements Queueable, Database.AllowsCallouts {

    private Set<Id> parentIds;
    
    public UpdateChildRecordsApproveQueueable(Set<Id> parentIds) {
        this.parentIds = parentIds;
    }
    
    public void execute(QueueableContext context) {
        Set<Id> childIdsToProcess = new Set<Id>();
        List<Returned_Cards__c> childRecordsToUpdate = new List<Returned_Cards__c>();
        
        // First, query the child records that need to be updated
        for (Returned_Cards__c childRecord : [
            SELECT Id, Status__c, Sub_Status__c, Returned_Card_Bulk_Operation__c,
            CIF__c, Customer__c, Region_Flag__c, Case_Model__c,
            Customer__r.PersonEmail, Customer__r.PersonMobilePhone
            FROM Returned_Cards__c 
            WHERE Returned_Card_Bulk_Operation__c IN :parentIds
            AND Is_Checker_Approved__c != true
            LIMIT 50000
        ]) {
            childIdsToProcess.add(childRecord.Id);
            childRecord.Is_Checker_Approved__c = true;
            childRecordsToUpdate.add(childRecord);
        }
        
        // Process callouts FIRST (before any DML)
        if (!childIdsToProcess.isEmpty()) {
            ReturnedCardsHandler.processCalloutsForRecords(childIdsToProcess);
        }
        
        // Then update the records AFTER callouts are complete
        if (!childRecordsToUpdate.isEmpty()) {
            update childRecordsToUpdate;
        }
    }
}
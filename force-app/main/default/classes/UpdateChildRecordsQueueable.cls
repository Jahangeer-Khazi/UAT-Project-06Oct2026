public class UpdateChildRecordsQueueable implements Queueable {
    
    private Set<Id> parentIds;
    
    public UpdateChildRecordsQueueable(Set<Id> parentIds) {
        this.parentIds = parentIds;
    }
    
    public void execute(QueueableContext context) {
        List<Returned_Cards__c> childRecordsToUpdate = new List<Returned_Cards__c>();
        
        for (Returned_Cards__c childRecord : [
            SELECT Id, Status__c, Sub_Status__c, Returned_Card_Bulk_Operation__c
            FROM Returned_Cards__c 
            WHERE Returned_Card_Bulk_Operation__c IN :parentIds
            AND (Status__c != 'Closed' OR Sub_Status__c != 'Destroyed')
            LIMIT 50000
        ]) {
            childRecord.Status__c = 'Closed';
            childRecord.Sub_Status__c = 'Destroyed';
            childRecordsToUpdate.add(childRecord);
        }
        
        if (!childRecordsToUpdate.isEmpty()) {
            update childRecordsToUpdate;
        }
    }
}
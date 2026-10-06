public class ProcessCalloutsQueueable implements Queueable, Database.AllowsCallouts {
    
    private Set<Id> recordIds;
    
    public ProcessCalloutsQueueable(Set<Id> recordIds) {
        this.recordIds = recordIds;
    }
    
    public void execute(QueueableContext context) {
        ReturnedCardsHandler.processCalloutsForRecords(recordIds);
    }
}
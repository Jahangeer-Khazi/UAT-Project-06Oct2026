public class ReturnedCardsCalloutQueueable implements Queueable, Database.AllowsCallouts {

    private Set<Id> returnedCardIds;

    public ReturnedCardsCalloutQueueable(Set<Id> returnedCardIds) {
        this.returnedCardIds = returnedCardIds;
    }

    public void execute(QueueableContext context) {
        ReturnedCardsHandler.processCalloutsForRecords(returnedCardIds); 
    }
}
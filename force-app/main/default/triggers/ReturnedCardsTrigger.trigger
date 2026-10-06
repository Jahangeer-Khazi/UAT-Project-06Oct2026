trigger ReturnedCardsTrigger on Returned_Cards__c (before insert, before update, after insert, after update, after delete, after undelete) {
    
    if (Trigger.isBefore && Trigger.isInsert) {
        ReturnedCardsHandler.calculateAcceptedWarnings(Trigger.new);
        ReturnedCardsHandler.populateSubject(Trigger.new);
    }
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        ReturnedCardsHandler.calculateAcceptedWarnings(Trigger.new);
        ReturnedCardsHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        ReturnedCardsHandler.populateSubject(Trigger.new);
    }
    
    if (Trigger.isAfter && Trigger.isInsert) {
        ReturnedCardsHandler.updateAcceptedWarningsAfterTrigger(Trigger.newMap.keySet());
        
        // Queue callouts asynchronously
        if (!ReturnedCardsHandler.recordsForCallout.isEmpty()) {
            System.enqueueJob(new ProcessCalloutsQueueable(new Set<Id>(ReturnedCardsHandler.recordsForCallout)));
            ReturnedCardsHandler.recordsForCallout.clear();
        }
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        Set<Id> recordsWithChangedCIF = new Set<Id>();
        for (Returned_Cards__c rc : Trigger.new) {
            Returned_Cards__c oldRc = Trigger.oldMap.get(rc.Id);
            if (rc.CIF__c != oldRc.CIF__c) {
                recordsWithChangedCIF.add(rc.Id);
            }
        }
        
        if (!recordsWithChangedCIF.isEmpty()) {
            ReturnedCardsHandler.updateAcceptedWarningsAfterTrigger(recordsWithChangedCIF);
        }
        
        // Queue callouts asynchronously for manual updates
        if (!ReturnedCardsHandler.recordsForCallout.isEmpty()) {
            System.enqueueJob(new ProcessCalloutsQueueable(new Set<Id>(ReturnedCardsHandler.recordsForCallout)));
            ReturnedCardsHandler.recordsForCallout.clear();
        }
    }
    
    if (Trigger.isAfter && Trigger.isDelete) {
        ReturnedCardsHandler.handleAfterDelete(Trigger.old);
    }
    
    if (Trigger.isAfter && Trigger.isUndelete) {
        ReturnedCardsHandler.updateAcceptedWarningsAfterTrigger(Trigger.newMap.keySet());
    }
}
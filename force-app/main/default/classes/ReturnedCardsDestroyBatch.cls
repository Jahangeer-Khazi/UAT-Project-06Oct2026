global class ReturnedCardsDestroyBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(
            'SELECT Id, Status__c, SLA_Remaining_Time__c, Sub_Status__c ' +
            'FROM Returned_Cards__c ' +
            'WHERE Status__c = \'Open\' ' +
            'AND SLA_Remaining_Time__c = TODAY'
        );
    }

    global void execute(Database.BatchableContext bc, List<Returned_Cards__c> scope) {

        for (Returned_Cards__c rc : scope) {
            rc.Sub_Status__c = 'DESTROYED';
        }

        if (!scope.isEmpty()) {
            update scope;
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Optional: logging, email notification, etc.
    }
}
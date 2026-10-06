trigger BulkOperationTrigger on Bulk_Operation__c (after update) {
    Set<Id> approvedRecordIds = new Set<Id>();
    Set<Id> rejectedRecordIds = new Set<Id>();
    String operationType;
    List<Bulk_Operation__c> recordsToUpdate = new List<Bulk_Operation__c>();

    for (Bulk_Operation__c record : Trigger.new) {
        Bulk_Operation__c oldRecord = Trigger.oldMap.get(record.Id);
        if (oldRecord.Status__c != 'Checker Approved' && record.Status__c == 'Checker Approved') {
            approvedRecordIds.add(record.Id);
            operationType = record.Type__c;
            // Set status to 'Processing'
            Bulk_Operation__c updateRecord = new Bulk_Operation__c(Id = record.Id, Status__c = 'Processing', Start_Time__c = System.now());
            recordsToUpdate.add(updateRecord);
        }
        
        // Checker Result Rejected Logic
        if (oldRecord.Checker_Result__c != 'Reject' && record.Checker_Result__c == 'Reject') {
            rejectedRecordIds.add(record.Id);
        }
    }

    if (!recordsToUpdate.isEmpty()) {
        update recordsToUpdate;
    }

    if (!approvedRecordIds.isEmpty()) {
        Database.executeBatch(new BulkOperationCalloutBatch(approvedRecordIds,operationType), 1); 
        //System.enqueueJob(new BulkOperationCalloutBatch(approvedRecordIds));
        BulkOperationHandler.updateAccountsFromChildDetails(approvedRecordIds);
    }
    
    if (!rejectedRecordIds.isEmpty()) {
        BulkOperationHandler.rejectChildDetails(rejectedRecordIds);
    }
}
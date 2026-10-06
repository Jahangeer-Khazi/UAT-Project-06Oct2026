trigger ReturnedCardBulkOperationTrigger on Returned_Card_Bulk_Operation__c (before update, after update) {
    
    Set<Id> parentIdsToProcess = new Set<Id>();
    Set<Id> parIdsToProcess = new Set<Id>();
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        for (Returned_Card_Bulk_Operation__c record : Trigger.new) {
            Returned_Card_Bulk_Operation__c oldRecord = Trigger.oldMap.get(record.Id);
            
            // Check if Checker_Result__c field value has changed
            if (record.Checker_Result__c != oldRecord.Checker_Result__c) {
                
                // Update Status__c based on Checker_Result__c value
                if (record.Checker_Result__c == 'Approve') {
                    record.Status__c = 'Approved';
                } 
                else if (record.Checker_Result__c == 'Reject') {
                    record.Status__c = 'Rejected';
                }
                
                // Update Checker_Result_Date_Time__c with current date/time
                record.Checker_Result_Date_Time__c = DateTime.now();
            }
            
            // Check if either rollup summary field has changed
            if (record.Total_Number_of_Cases__c != oldRecord.Total_Number_of_Cases__c || 
                record.Total_Closed_Cases__c != oldRecord.Total_Closed_Cases__c) {
                    
                // Update status to 'Completed' when both fields are equal
                if (record.Total_Number_of_Cases__c == record.Total_Closed_Cases__c) {
                    record.Status__c = 'Completed';
                }
            }
            
            // When Checker_Result__c is 'Reject' and has changed, mark for child update
            if (record.Checker_Result__c == 'Reject' && record.Checker_Result__c != oldRecord.Checker_Result__c) {
                parentIdsToProcess.add(record.Id);
            }
        }
        
        // Queue the child update in a separate transaction
        if (!parentIdsToProcess.isEmpty()) {
            System.enqueueJob(new UpdateChildRecordsQueueable(parentIdsToProcess));
        }
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        for (Returned_Card_Bulk_Operation__c record : Trigger.new) {
            Returned_Card_Bulk_Operation__c oldRecord = Trigger.oldMap.get(record.Id);
            
            // When Checker_Result__c is 'Approve' and has changed, mark for child update
            if (record.Checker_Result__c == 'Approve' && record.Checker_Result__c != oldRecord.Checker_Result__c) {
                parIdsToProcess.add(record.Id);
            }
        }
        
        // Queue the child update in a separate transaction
        if (!parIdsToProcess.isEmpty()) {
            System.enqueueJob(new UpdateChildRecordsApproveQueueable(parIdsToProcess));
        }
    }
}
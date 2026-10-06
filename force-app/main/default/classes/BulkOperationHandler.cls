public class BulkOperationHandler {
    public static void updateAccountsFromChildDetails(Set<Id> bulkOperationIds) {
        if (bulkOperationIds.isEmpty()) return;

        // Step 1: Fetch child records
        List<Bulk_Operation_Detail__c> childRecords = [
            SELECT Id, Block_App_Access__c, Blacklist__c, Is_Fraud__c,
                   Customer__c
            FROM Bulk_Operation_Detail__c
            WHERE Bulk_Operation__c IN :bulkOperationIds
                  AND Customer__c != null
        ];

        // Step 2: Map to hold updates to Account
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();

        for (Bulk_Operation_Detail__c detail : childRecords) {
            if (detail.Customer__c == null) continue;

            Account acc = accountsToUpdate.containsKey(detail.Customer__c)
                ? accountsToUpdate.get(detail.Customer__c)
                : new Account(Id = detail.Customer__c);

            // Update checkbox fields if true
            if (detail.Block_App_Access__c) {
                acc.pr_Block_App_Access__c = true;
            }
            if (detail.Blacklist__c) {
                acc.Blacklisted__c = true;
            }
            if (detail.Is_Fraud__c) {
                acc.Is_Fraud__c = true;
            }

            accountsToUpdate.put(acc.Id, acc);
        }

        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate.values();
        }
    }
    
    // ✅ New method to update child record statuses to 'Rejected'
    public static void rejectChildDetails(Set<Id> bulkOperationIds) {
        if (bulkOperationIds.isEmpty()) return;

        List<Bulk_Operation_Detail__c> childRecordsToUpdate = [
            SELECT Id, Status__c
            FROM Bulk_Operation_Detail__c
            WHERE Bulk_Operation__c IN :bulkOperationIds
        ];

        for (Bulk_Operation_Detail__c detail : childRecordsToUpdate) {
            detail.Status__c = 'Rejected';
        }

        if (!childRecordsToUpdate.isEmpty()) {
            update childRecordsToUpdate;
        }
    }
}
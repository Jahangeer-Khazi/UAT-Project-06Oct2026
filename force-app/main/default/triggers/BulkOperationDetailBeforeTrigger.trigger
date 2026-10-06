trigger BulkOperationDetailBeforeTrigger on Bulk_Operation_Detail__c (before insert, before update) {
    // Collect all CIF values from the records being inserted
    Set<String> cifSet = new Set<String>();
    for (Bulk_Operation_Detail__c bod : Trigger.new) {
        if (bod.CIF__c != null) {
            cifSet.add(bod.CIF__c);
        }
    }

    // Query Account records where CIF__pc matches the given CIFs
    Map<String, Id> accountMap = new Map<String, Id>();
    if (!cifSet.isEmpty()) {
        for (Account acc : [SELECT Id, CIF__pc FROM Account WHERE CIF__pc IN :cifSet]) {
            accountMap.put(acc.CIF__pc, acc.Id);
        }
    }

    // Assign the related Account Id to Bulk_Operation_Detail__c records
    for (Bulk_Operation_Detail__c bod : Trigger.new) {
        if (bod.CIF__c != null && accountMap.containsKey(bod.CIF__c)) {
            bod.Customer__c = accountMap.get(bod.CIF__c);
        }
    }
}
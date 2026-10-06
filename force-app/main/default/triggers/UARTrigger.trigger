trigger UARTrigger on UAR__c (after update) {
    Set<Id> customerIds = new Set<Id>();

    // Collect Customer IDs where Compliance Result changed to 'Approved'
    for (UAR__c uar : Trigger.new) {
        UAR__c oldRecord = Trigger.oldMap.get(uar.Id);
        if (uar.Compliance_Result__c == 'Approved' && oldRecord.Compliance_Result__c != 'Approved') {
            if (uar.Account__c != null) {
                customerIds.add(uar.Account__c);
            }
        }
    }

    if (!customerIds.isEmpty()) {
        List<Account> customersToUpdate = new List<Account>();

        // Fetch Customers whose STR__c is false
        Map<Id, Account> customerMap = new Map<Id, Account>(
            [SELECT Id, RFI__c, STR__c FROM Account WHERE Id IN :customerIds]
        );

        for (Account cust : customerMap.values()) {
            cust.STR__c = true; // Tick RFI checkbox
            customersToUpdate.add(cust);
        }

        // Perform bulk update
        if (!customersToUpdate.isEmpty()) {
            update customersToUpdate;
        }
    }
}
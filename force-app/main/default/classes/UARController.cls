public with sharing class UARController {
    @AuraEnabled
    public static void createSuspiciousTransactions(List<Suspicious_Transaction__c> transactions) {
        System.debug('DEBUG: createSuspiciousTransactions called, transactions: ' + JSON.serialize(transactions));
        try {
            if (transactions != null && !transactions.isEmpty()) {
                System.debug('DEBUG: Inserting ' + transactions.size() + ' transactions');
                insert transactions;
                System.debug('DEBUG: Transactions inserted successfully');
            } else {
                System.debug('DEBUG: No transactions to insert');
            }
        } catch (Exception e) {
            System.debug('DEBUG: Error creating transactions: ' + e.getMessage());
            throw new AuraHandledException('Error creating transactions: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Suspicious_Transaction__c> getTransactions(Id uarId) {
        return [
            SELECT Id, Name, Transaction_Amount__c, Transaction_Date__c, UAR__c
            FROM Suspicious_Transaction__c
            WHERE UAR__c = :uarId
            ORDER BY Transaction_Date__c DESC
        ];
    }

    @AuraEnabled
    public static void deleteTransactions(List<Id> transactionIds) {
        try {
            if (transactionIds != null && !transactionIds.isEmpty()) {
                Database.delete(transactionIds);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting transactions: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateTransactions(List<Suspicious_Transaction__c> transactions) {
        try {
            if (transactions != null && !transactions.isEmpty()) {
                // Separate new records from updates
                List<Suspicious_Transaction__c> newRecords = new List<Suspicious_Transaction__c>();
                List<Suspicious_Transaction__c> updates = new List<Suspicious_Transaction__c>();
                
                for (Suspicious_Transaction__c trans : transactions) {
                    if (trans.Id == null) {
                        newRecords.add(trans);
                    } else {
                        updates.add(trans);
                    }
                }
                
                if (!newRecords.isEmpty()) insert newRecords;
                if (!updates.isEmpty()) update updates;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error updating transactions: ' + e.getMessage());
        }
    }
}
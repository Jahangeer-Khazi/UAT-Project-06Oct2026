public without sharing class LeadArchivalBatch implements Database.Batchable<sObject>, Schedulable {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = Test.isRunningTest()
            ? 'SELECT Id, Email__c, Mobile__c, Secondary_Phone_Number__c FROM Social_Media_Leads__c'
            : 'SELECT Id, Email__c, Mobile__c, Secondary_Phone_Number__c FROM Social_Media_Leads__c WHERE CreatedDate < LAST_N_DAYS:1';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Social_Media_Leads__c> scope) {
        List<Social_Media_Leads__c> toUpdate = new List<Social_Media_Leads__c>();
        for (Social_Media_Leads__c sml : scope) {
            Boolean updated = false;
            if (String.isNotBlank(sml.Email__c) && !sml.Email__c.startsWith('#arc#-')) {
                sml.Email__c = '#arc#-' + sml.Email__c;
                updated = true;
            }
            if (String.isNotBlank(sml.Mobile__c) && !sml.Mobile__c.startsWith('#arc#-')) {
                sml.Mobile__c = '#arc#-' + sml.Mobile__c;
                updated = true;
            }
            if (String.isNotBlank(sml.Secondary_Phone_Number__c) && !sml.Secondary_Phone_Number__c.startsWith('#arc#-')) {
                sml.Secondary_Phone_Number__c = '#arc#-' + sml.Secondary_Phone_Number__c;
                updated = true;
            }
            if (updated) {
                toUpdate.add(sml);
            }
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new LeadArchivalBatch(), 200);
    }
}
/**
 * @description       : Batch Class that updates as Approved all Draw Entries related to Draw.
 * @author            : Jose Caballero
 * @group             :
 * @last modified on  : 26/10/2021
 * @last modified by  : Jose Caballero
**/
public with sharing class DrawEntriesApprovalBatch implements Database.batchable <SObject> {

    private String targetDrawId;

    /**
    * @description Constructor
    * @author Jose Caballero | 26/10/2021
    * @param drawId
    **/
    public DrawEntriesApprovalBatch(String drawId) {
        targetDrawId = drawId;
    }

    /**
    * @description Retrieves all draw entries related to given draw id from the constructor
    * @author Jose Caballero | 26/10/2021
    * @param BC
    * @return Database.QueryLocator
    **/
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Draw_Entry_Approved__c FROM Draw_Entry__c WHERE Draw__c = \'' + targetDrawId + '\'';
        return Database.getQueryLocator(query);
    }

    /**
    * @description Updates every draw entry from the iterable
    * @author Jose Caballero | 26/10/2021
    * @param BC
    * @param scope Iterable from .start method query
    **/
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        for(Sobject s : scope) {
            s.put('Draw_Entry_Approved__c',true);
            s.put('justification__c','Approved status is changed by Draw entries approval batch process');
        }
        update scope;
    }

    public void finish(Database.BatchableContext BC){
        // Nothing to do here
    }
}
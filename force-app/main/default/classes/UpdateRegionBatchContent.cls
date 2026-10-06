/**
 * Created by Himanshu on 02/02/2022.
 * //Update the region for Account and contacts
 */
global with sharing class UpdateRegionBatchContent implements Schedulable, Database.Batchable<SObject> {

     public static String contentQuery = 'SELECT Id, Region_flag__c FROM content__c WHERE Region_flag__c=\'\' ORDER BY CreatedDate DESC';
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Content scope query locator ' +contentQuery);
        return Database.getQueryLocator(contentQuery);

    }
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new UpdateRegionBatchContent(),  Integer.valueOf(Label.Region_Flag_Update_Batch_Size));
    }
    global void execute(Database.BatchableContext info, List<content__c> scope) {
        System.debug('Total content records ' +scope.size());
        List<content__c> contentUpdate =  new List<content__c>();
        for(content__c cont : scope){
            if(String.isEmpty(cont.Region_Flag__c) ) {
                cont.Region_Flag__c = 'Bahrain';
                contentUpdate.add(cont);
            }

        }

        System.debug('Total content records updated ' +contentUpdate.size());
        update contentUpdate;
    }
    global void finish(Database.BatchableContext info) {

    }

}
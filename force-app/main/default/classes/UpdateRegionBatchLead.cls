/**
 * Created by Himanshu on 02/02/2022.
 * //Update the region for Account and contacts
 */
global with sharing class UpdateRegionBatchLead implements Schedulable, Database.Batchable<SObject> {

   // private static String dateTo = System.now().addDays(Integer.valueOf('01/01/2015')).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
   // private static String dateFrom = System.now().addDays(Integer.valueOf('25/02/2022')).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); //values should be minus

    //public static String contactQuery = 'SELECT Id, Region_flag__c, region_flag__pc   FROM account WHERE  CreatedDate >= '+dateFrom+' AND CreatedDate <= '+dateTo+' ORDER BY CreatedDate DESC';
    public static String leadQuery = 'SELECT Id, Region_flag__c   FROM Lead where Region_flag__c=\'\' ORDER BY CreatedDate DESC';
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Lead scope query locator ' +leadQuery);
        return Database.getQueryLocator(leadQuery);

    }
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new UpdateRegionBatchLead(),  Integer.valueOf(Label.Region_Flag_Update_Batch_Size));
    }
    global void execute(Database.BatchableContext info, List<Lead> scope) {
        System.debug('Total lead records ' +scope.size());
        List<Lead> leadUpdate =  new List<Lead>();
        for(Lead ld : scope){
            if(String.isEmpty(ld.Region_Flag__c) ) {
                ld.Region_Flag__c = 'Bahrain';

                leadUpdate.add(ld);
            }

        }

        System.debug('Total lead records updated ' +leadUpdate.size());
        update leadUpdate;
    }
    global void finish(Database.BatchableContext info) {

    }

}
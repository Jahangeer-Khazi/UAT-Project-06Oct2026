/**
 * Created by Himanshu on 02/02/2022.
 * //Update the region for Account and contacts
 */
global with sharing class UpdateRegionBatchCase implements Schedulable, Database.Batchable<SObject> {

   // private static String dateTo = System.now().addDays(Integer.valueOf('01/01/2015')).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
   // private static String dateFrom = System.now().addDays(Integer.valueOf('25/02/2022')).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); //values should be minus

    //public static String contactQuery = 'SELECT Id, Region_flag__c, region_flag__pc   FROM account WHERE  CreatedDate >= '+dateFrom+' AND CreatedDate <= '+dateTo+' ORDER BY CreatedDate DESC';
    public static String caseQuery = 'SELECT Id, Region_flag__c FROM case WHERE Region_flag__c=\'\' ORDER BY CreatedDate DESC';
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('case scope locator ' +caseQuery);
        return Database.getQueryLocator(caseQuery);

    }
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new UpdateRegionBatchCase(),  Integer.valueOf(Label.Region_Flag_Update_Batch_Size));
    }
    global void execute(Database.BatchableContext info, List<case> scope) {
        System.debug('Total case records ' +scope.size());
        List<case> caseUpdate =  new List<case>();
        for(case cs : scope){
            if(String.isEmpty(cs.Region_Flag__c) ) {
                cs.Region_Flag__c = 'Bahrain';
                caseUpdate.add(cs);
            }

        }

        System.debug('Total case records updated ' +caseUpdate.size());
        update caseUpdate;
    }
    global void finish(Database.BatchableContext info) {

    }

}
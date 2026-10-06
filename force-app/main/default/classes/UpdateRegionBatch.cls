/**
 * Created by Himanshu on 02/02/2022.
 * //Update the region for Account and contacts
 */
global with sharing class UpdateRegionBatch implements Schedulable, Database.Batchable<SObject> {

   // private static String dateTo = System.now().addDays(Integer.valueOf('01/01/2015')).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
   // private static String dateFrom = System.now().addDays(Integer.valueOf('25/02/2022')).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); //values should be minus

    //public static String contactQuery = 'SELECT Id, Region_flag__c, region_flag__pc, Mobile_Phone_Check__pc FROM account WHERE  CreatedDate >= '+dateFrom+' AND CreatedDate <= '+dateTo+' ORDER BY CreatedDate DESC';
    public static String contactQuery = 'SELECT Id, Region_flag__c, region_flag__pc, Mobile_Phone_Check__pc, Segment__pc, PLA_Eligibility__pc FROM account where region_flag__c=\'\' or region_flag__pc=\'\' ORDER BY CreatedDate DESC limit '+Label.Region_Flag_Batch_Query_Size;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('BatchDocShare_ContentVersion_Scope locator ' +contactQuery);
        return Database.getQueryLocator(contactQuery);

    }
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new UpdateRegionBatch(),  Integer.valueOf(Label.Region_Flag_Update_Batch_Size));
    }
    global void execute(Database.BatchableContext info, List<Account> scope) {
        System.debug('Total records ' +scope.size());
        List<Account> accUpdate =  new List<Account>();
        Boolean toBeUpdated = false;
        for(Account acc : scope){
            if(String.isEmpty(acc.Region_Flag__c) || String.isEmpty(acc.Region_Flag__pc)) {
                acc.Region_Flag__c = !String.isEmpty(acc.Region_Flag__c) ? acc.Region_Flag__c : 'Bahrain';
                acc.Region_Flag__pc = !String.isEmpty(acc.Region_Flag__c) ? acc.Region_Flag__c : 'Bahrain';
                toBeUpdated = true;
            }
            System.debug('@@@ String.IsNotEmpty(acc.Mobile_Phone_Check__pc) '+String.IsNotEmpty(acc.Mobile_Phone_Check__pc));
            if (String.IsNotEmpty(acc.Mobile_Phone_Check__pc) && !acc.Mobile_Phone_Check__pc.contains('-'+acc.Region_Flag__pc) && String.IsNotEmpty(acc.Region_Flag__pc)) {
                acc.Mobile_Phone_Check__pc += '-'+acc.Region_Flag__pc;
                toBeUpdated = true;
            }
            if (String.IsEmpty(acc.PLA_Eligibility__pc) && acc.Segment__pc!='Staff') {
                acc.PLA_Eligibility__pc = 'Yes';
                toBeUpdated = true;
            }
            if (toBeUpdated) {
                accUpdate.add(acc);
                toBeUpdated = false;
            }
        }

        System.debug('Total records updated ' +accUpdate.size());
        update accUpdate;
    }
    global void finish(Database.BatchableContext info) {

    }

}
/**
 * Created by Himanshu on 02/02/2022.
 * //Update the region for Account and contacts
 * YZ - 24/02/2022 - class used to update field Mobile_Phone_Check__pc and Mobile_Phone_Check_Region__pc on all records where Mobile_Phone_Check_Region__pc is empty and Region Flag & Phone Number are not empty
 */
global with sharing class UpdateRegionBatchAccount2 implements Schedulable, Database.Batchable<SObject> {

    public static String contactQuery = 'SELECT Id, Region_flag__c, region_flag__pc, archived__pc, Mobile_Phone_Check__pc, Mobile_Country_Code__pc, PersonMobilePhone, Mobile_Phone_Check_Region__pc, Segment__pc, PLA_Eligibility__pc FROM account where Mobile_Phone_Check_Region__pc=\'\' or archived__pc=true ORDER BY CreatedDate DESC limit '+Label.Region_Flag_Batch_Query_Size;
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
            /*if(String.isEmpty(acc.Region_Flag__c) || String.isEmpty(acc.Region_Flag__pc)) {
                acc.Region_Flag__c = !String.isEmpty(acc.Region_Flag__c) ? acc.Region_Flag__c : 'Bahrain';
                acc.Region_Flag__pc = !String.isEmpty(acc.Region_Flag__c) ? acc.Region_Flag__c : 'Bahrain';
                toBeUpdated = true;
            }*/
            System.debug('@@@ String.IsNotEmpty(acc.Mobile_Phone_Check__pc) '+String.IsNotEmpty(acc.Mobile_Phone_Check__pc));
            if (String.IsNotEmpty(acc.Region_Flag__pc)) {
                if (String.IsNotEmpty(acc.Mobile_Country_Code__pc) && String.IsNotEmpty(acc.PersonMobilePhone)) {
                    if (!acc.archived__pc) {
                        acc.Mobile_Phone_Check__pc = acc.Mobile_Country_Code__pc + acc.PersonMobilePhone;
                        acc.Mobile_Phone_Check_Region__pc = acc.Mobile_Country_Code__pc + acc.PersonMobilePhone + '-' + acc.Region_Flag__pc;
                    }
                    else {
                        acc.Mobile_Phone_Check__pc = '';
                        acc.Mobile_Phone_Check_Region__pc = '';
                    }
                    toBeUpdated = true;
                }
            }
            /*if (String.IsEmpty(acc.PLA_Eligibility__pc) && acc.Segment__pc!='Staff') {
                acc.PLA_Eligibility__pc = 'Yes';
                toBeUpdated = true;
            }*/
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
/**
 * @description       : This is the batch class responsable of checking customers conditions and open periodic review case based on them  
 *                     
 * @author            : Wissal Benqezza
 * @creation date     : 03-06-2022
 * to run the batch use : Id batchJobId = Database.executeBatch(new PR002_OpenPeriodicReviewCase(), 200);
**/
global with sharing class PR002_OpenPeriodicReviewCase implements Database.Batchable<sObject>,Database.AllowsCallouts {
    global Id periodicReviewId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Periodic_Review').getRecordTypeId();
    global Database.QueryLocator start(Database.BatchableContext bc) {       
        String query = 'Select id, '+
                            '(SELECT Id FROM cases WHERE RecordTypeId = :periodicReviewId AND Status != \'Closed\' ) '+
                        'FROM Account WHERE pr_NextReviewDate__c = TODAY '+
                                    'OR ( '+
                                        'On_boarding_type__pc != \'IGA\' AND ('+
                                                                            'ID_Expiry_Date__pc = NEXT_N_DAYS:45 '+
                                                                            'OR ( Nationality__pc != \'BH\' '+
                                                                                'AND (Passport_Expiry_Date__pc= NEXT_N_DAYS:45 OR Residency_Permit_Expiry__pc = NEXT_N_DAYS:45) '+
                                                                            ')'+
                                                                        ')'+
                                    ')';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> batch) {
        List<Case> lstCase = new List<Case>();
        String isBatchRunnable = System.Label.pr_Initiate_Periodic_Review_Batch;

        if(batch != null && isBatchRunnable.equalsIgnoreCase('true') ){
            for (Account a : batch) {
                if(a.cases == null || a.cases.size() == 0 ){
    
                    
                    Case cas =  new Case();
                    cas.AccountId = a.Id;
                    cas.Type = 'Periodic Review';
                    cas.RecordTypeId=periodicReviewId;
                    cas.Sub_Type__c='Periodic Review - Scheduled Review Date';
                    cas.pr_TriggerType__c='Automatically';
                    cas.Origin='App';
                    cas.Case_Nature__c='Account Maintenance';
                                
                    
    
                    //toDo : mapping
                    /* cas.AccountId = a.Id;
                    cas.AccountId = a.Id;
                    cas.AccountId = a.Id; */
                    lstCase.add(cas);
                }
            }
            if(lstCase != null && lstCase.size()>0){
                insert lstCase;
                System.debug('Cases to be inserted !! ');
                for(Case cc : lstCase){
                    System.debug(cc);
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('PR002_OpenPeriodicReviewCase finished !');
    }
}
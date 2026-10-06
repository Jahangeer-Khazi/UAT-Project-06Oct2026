/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 05-12-2023
*       Change History: 
*                   
*/
global class JordanPeriodicReviewBatch implements Database.Batchable<sObject>, Database.Stateful{
    Set<String> acctIds = new Set<String>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        Id joperiodicReviewId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('JO_Customer_Periodic_Review').getRecordTypeId();
		List<String> joPeriodicReviewAccountIds = System.Label.JO_PERIODIC_REVIEW_ACCOUNT_IDS.split(',');

        String query = '';
        //CONFIG_1 = 10 Days
        Date currentDatePlus10Days = Date.today().addDays(Integer.valueOf(System.Label.CONFIG_1));
        
        /////////////////////////////////////////////////// Start: This Query will be run only for the first time //////////////////////////////////////////////////////////////////////////////////////////////
        
        if(System.Label.JO_PERIODIC_REVIEW_1_IMPLEMENTATION.equalsIgnoreCase('true')){
            query = 'Select id, '+
                '(SELECT Id,Status FROM cases WHERE RecordTypeId =: joperiodicReviewId AND Status != \'Closed\') '+ 
                'Name,Onboarding_Stage__pc,Segment__pc,VVIP__pc,ID_Type__pc,ID_Expiry_Date__pc,Passport_Expiry_Date__pc,On_boarding_type__pc, '+
                'Region_Flag__pc  from Account where Onboarding_Stage__pc = \'ACCOUNT_ACTIVATED\' AND Region_Flag__pc = \'Jordan\' AND (Segment__pc = \'Regular\' OR Segment__pc = \'Premium\')  AND '+
                '(((ID_Type__pc = \'Jordanian ID\' OR ID_Type__pc = \'Military ID\' OR ID_Type__pc = \'Gaza ID\' OR ID_Type__pc = \'ID for son’s of Jordanian\') AND (ID_Expiry_Date__pc <=: currentDatePlus10Days)) OR (ID_Type__pc = \'Passport\' AND Passport_Expiry_Date__pc <=: currentDatePlus10Days)) LIMIT 1';
        }
        
        /////////////////////////////////////////////////// END: This Query will be run only for the first time //////////////////////////////////////////////////////////////////////////////////////////////

        /////////////////////////////////////////////////// Start: This Query will be run daily from the second time ///////////////////////////////////////////////////////////////////////////////////////////////////
        
        if(System.Label.JO_PERIODIC_REVIEW_SOQL_ENABLE_DAILY_JOB.equalsIgnoreCase('true')){
            query = 'Select id, '+
                '(SELECT Id,Status FROM cases WHERE RecordTypeId =: joperiodicReviewId AND Status != \'Closed\') '+ 
                'Name,Onboarding_Stage__pc,Segment__pc,VVIP__pc,ID_Type__pc,ID_Expiry_Date__pc,Passport_Expiry_Date__pc,On_boarding_type__pc, '+
                'Region_Flag__pc  from Account where Onboarding_Stage__pc = \'ACCOUNT_ACTIVATED\' AND Region_Flag__pc = \'Jordan\' AND (Segment__pc = \'Regular\' OR Segment__pc = \'Premium\')  AND '+
                '(((ID_Type__pc = \'Jordanian ID\' OR ID_Type__pc = \'Military ID\' OR ID_Type__pc = \'Gaza ID\' OR ID_Type__pc = \'ID for son’s of Jordanian\') AND (ID_Expiry_Date__pc =: currentDatePlus10Days)) OR (ID_Type__pc = \'Passport\' AND Passport_Expiry_Date__pc =: currentDatePlus10Days)) LIMIT 1';
        
        }
        
       /////////////////////////////////////////////////// END: This Query will be run daily from the second time ///////////////////////////////////////////////////////////////////////////////////////////////////

       /////////////////////////////////////////////////// Start: This Query will be run for unit testing ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
        
        if(System.Label.JO_PERIODIC_REVIEW_UNIT_TESTING.equalsIgnoreCase('true')){
             query = 'Select id, '+
                '(SELECT Id,Status FROM cases WHERE RecordTypeId =: joperiodicReviewId AND Status != \'Closed\') '+ 
                'Name,Onboarding_Stage__pc,Segment__pc,VVIP__pc,ID_Type__pc,ID_Expiry_Date__pc,Passport_Expiry_Date__pc,On_boarding_type__pc, '+
                'Region_Flag__pc  from Account where Onboarding_Stage__pc = \'ACCOUNT_ACTIVATED\' AND Region_Flag__pc = \'Jordan\' AND (Segment__pc = \'Regular\' OR Segment__pc = \'Premium\')  AND '+
                '(((ID_Type__pc = \'Jordanian ID\' OR ID_Type__pc = \'Military ID\' OR ID_Type__pc = \'Gaza ID\' OR ID_Type__pc = \'ID for son’s of Jordanian\') AND (ID_Expiry_Date__pc <=: currentDatePlus10Days)) OR (ID_Type__pc = \'Passport\' AND Passport_Expiry_Date__pc <=: currentDatePlus10Days)) AND Id IN : joPeriodicReviewAccountIds';
        
        }
        
       /////////////////////////////////////////////////// END: This Query will be run for unit testing ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

        System.debug('Query String:'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Account> accList) {
        
        Id periodicReviewId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('JO_Customer_Periodic_Review').getRecordTypeId();
        Map<String,Case> mapAccountRelatedNewPeriodicReviewCase = new Map<String,Case>();
        Set<String> setofAccountHavingExistingPeriodicReviewCases = new Set<String>();
        Set<String> setofsuccessFullCaseIds = new Set<String>();
        Set<String> setOfErrormessage = new Set<string>();
        
        try{
            System.debug('Jordanian Account Size:'+accList.size());
            String isBatchRunnable = System.Label.JO_PERIODIC_REVIEW_INITIATE;
            if(accList.size() > 0 && isBatchRunnable.equalsIgnoreCase('true')){
                for(Account acc : accList){
                    if(acc.cases.size() == 0){
                        System.debug('New Periodic Review cases is ready to be created against a customer');
                        System.debug('Account Ids:'+acc.Id);
                        Case cs = new Case();
                        cs.AccountId = acc.Id;
                        cs.RecordTypeId = periodicReviewId;
                        cs.Type = 'Periodic Review';
                        cs.Sub_Type__c ='Periodic Review - Scheduled Review Date';
                        cs.pr_TriggerType__c = 'Automatically';
                        cs.Origin = 'CRM';
                        cs.Case_Nature__c = 'Account Maintenance';
                        cs.Subject = 'Periodic Review';
                        cs.Description = 'New Periodic Review/ Expired ID';
                        mapAccountRelatedNewPeriodicReviewCase.put(acc.id,cs);
                        acctIds.add(acc.id);
                    }
                    else if(acc.cases.size() > 0){
                       System.debug('Existing Periodic Review cases are already existing against a customer:'+acc.Id);
					   setofAccountHavingExistingPeriodicReviewCases.add(acc.Id);
                    }
                }//for loop Ends
            }//If Ends
            
            if(!mapAccountRelatedNewPeriodicReviewCase.isEmpty()){
                Database.SaveResult[] saveResultInsert = Database.insert(mapAccountRelatedNewPeriodicReviewCase.values(),false);
				for(Database.SaveResult sr : saveResultInsert){
                    if(sr.isSuccess()) {
                        setofsuccessFullCaseIds.add(sr.getId());
                        System.debug('Set of success case Ids:'+setofsuccessFullCaseIds);
                    }
                    else{
                        for(Database.Error err : sr.getErrors()) {
                            setOfErrormessage.add(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Set of Error Message:'+setOfErrormessage);
                        }	
                    }
                } //for loop Ends
            } //If Ends
            
        }catch(Exception Ex){
            String errorMessage = ex.getMessage()  + ex.getStackTraceString();
            System.debug('Error Message to Display in Catch block:'+errorMessage);
        }
    }
    global void finish(Database.BatchableContext bc) {
        //Id joperiodicReviewId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('JO_Customer_Periodic_Review').getRecordTypeId();
 		//CONFIG_1 = 10 Days
        Date currentDatePlus10Days = Date.today().addDays(Integer.valueOf(System.Label.CONFIG_1));
        
        system.debug('Before Delay:'+System.Now());
        
        Long endT = System.Now().getTime()+Integer.valueOf(System.Label.JO_PERIODIC_REVIEW_BATCH_TIME_DELAY); //JO_PERIODIC_REVIEW_BATCH_TIME_DELAY= 9000
        While(System.Now().getTime() < endT){
        }
        
        system.debug('After Delay:'+System.Now());
        List<Account> RerunJOPeriodicReviewBatch = new List<Account>();
        
        /////////////////////////////////////////////////// Start: This Query will be Re-run only for the first time //////////////////////////////////////////////////////////////////////////////////////////////

        if(System.Label.JO_PERIODIC_REVIEW_1_IMPLEMENTATION.equalsIgnoreCase('true')){
            RerunJOPeriodicReviewBatch = [Select Id,Name,Onboarding_Stage__pc,Segment__pc,VVIP__pc,ID_Type__pc,ID_Expiry_Date__pc,Passport_Expiry_Date__pc,On_boarding_type__pc,
                                          Region_Flag__pc from Account where Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED' AND Region_Flag__pc = 'Jordan' AND (Segment__pc = 'Regular' OR Segment__pc = 'Premium') AND
                                          (((ID_Type__pc = 'Jordanian ID' OR ID_Type__pc = 'Military ID' OR ID_Type__pc = 'Gaza ID' OR ID_Type__pc = 'ID for son’s of Jordanian') AND (ID_Expiry_Date__pc <=: currentDatePlus10Days)) OR (ID_Type__pc = 'Passport' AND Passport_Expiry_Date__pc <=: currentDatePlus10Days)) AND Id NOT IN : (acctIds)];
            
            if(!RerunJOPeriodicReviewBatch.isEmpty() && System.Label.JO_PERIODIC_REVIEW_MANUAL_STOP.equalsIgnoreCase('false')){
                JordanPeriodicReviewBatch JPRB = new JordanPeriodicReviewBatch();
                database.executeBatch(JPRB,1);
            }
        }//If Ends
        
        /////////////////////////////////////////////////// END: This Query will be Re-run only for the first time //////////////////////////////////////////////////////////////////////////////////////////////

        /////////////////////////////////////////////////// Start: This Query will be Re-run only from the Second time onwards //////////////////////////////////////////////////////////////////////////////////////////////

        if(System.Label.JO_PERIODIC_REVIEW_SOQL_ENABLE_DAILY_JOB.equalsIgnoreCase('true')){
            RerunJOPeriodicReviewBatch = [Select Id,Name,Onboarding_Stage__pc,Segment__pc,VVIP__pc,ID_Type__pc,ID_Expiry_Date__pc,Passport_Expiry_Date__pc,On_boarding_type__pc,
                                          Region_Flag__pc from Account where Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED' AND Region_Flag__pc = 'Jordan' AND (Segment__pc = 'Regular' OR Segment__pc = 'Premium') AND
                                          (((ID_Type__pc = 'Jordanian ID' OR ID_Type__pc = 'Military ID' OR ID_Type__pc = 'Gaza ID' OR ID_Type__pc = 'ID for son’s of Jordanian') AND (ID_Expiry_Date__pc =: currentDatePlus10Days)) OR (ID_Type__pc = 'Passport' AND Passport_Expiry_Date__pc =: currentDatePlus10Days)) AND Id NOT IN : (acctIds)];
            
            if(!RerunJOPeriodicReviewBatch.isEmpty() && System.Label.JO_PERIODIC_REVIEW_MANUAL_STOP.equalsIgnoreCase('false')){
                JordanPeriodicReviewBatch JPRB = new JordanPeriodicReviewBatch();
                database.executeBatch(JPRB,1);
            }
        	
    	} //If Ends
        System.debug('!!!!!!!!!!!!!!! Jordan Periodic Review Batch finished !!!!!!!!!!!!!!!!!');
    
    /////////////////////////////////////////////////// END: This Query will be Re-run only from the Second time onwards //////////////////////////////////////////////////////////////////////////////////////////////

  }
}
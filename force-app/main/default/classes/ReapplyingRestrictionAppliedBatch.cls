/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 09-09-2026
* 		Change History: 
*	     
*/
global class ReapplyingRestrictionAppliedBatch implements Database.Batchable<sObject>,Schedulable {
    global void execute(SchedulableContext SC) {
		Database.executeBatch(new ReapplyingRestrictionAppliedBatch(),Integer.valueOf(System.Label.REAPPLYING_RESTRICTION_COUNT));
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = '';
        query = System.label.ACCOUNT_REAPPLY_RESTRICTION_SOQL;
        System.debug('********* Account Reapply Restriction SOQL Query ********' +query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> accList){
        List<Account> accToUpdate = new List<Account>();
        System.debug('Account List Size:'+accList.size());
        if(accList.size()>0){
            for(Account acc : accList){
            	acc.CC_Reapplying_Restriction_Applied__pc = false;
                acc.Reapplying_Restriction_Period__pc = '';
                acc.Reapplying_Restriction_Last_Update_Date__pc = null;
                acc.CC_Reapply_Restriction_Period_Validity__pc = null;
        		accToUpdate.add(acc);
        	}//for loop Ends
            try{
                if(!accToUpdate.isEmpty()){
                    update accToUpdate;
                }
            }catch(Exception e){
                System.debug('Exception in Batch execute method:'+e.getMessage());
            } 
            
        }//If Ends
    }
    global void finish(Database.BatchableContext BC) {
    }
    /*
    String cronExpression = '0 0 9 * * ?';
    System.schedule('Daily Reapplying Restriction Check',cronExpression,new ReapplyingRestrictionAppliedBatch());
    */

}
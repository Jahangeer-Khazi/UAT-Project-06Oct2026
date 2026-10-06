/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 07-12-2023
*       Change History: 
*                   
*/
public class JordanPeriodicReviewSMSSchedulable implements Schedulable {
    set<Id> caseId;
    
    public JordanPeriodicReviewSMSSchedulable(set<Id> setCaseIdsSet){
        this.caseId = setCaseIdsSet;
    }
    
    ///////////////////////////////////////// Start: Scheduler Which Runs After 5 minutes if we found more then one Queuable job in a single Transaction //////////////////////////////////////////////////////
	
    public void execute(SchedulableContext sc){
         JordanPeriodicReviewQueuableSMSAutomatic sendSMS = new JordanPeriodicReviewQueuableSMSAutomatic(caseId);
		 System.enqueueJob(sendSMS);
         CronTrigger ct = [SELECT Id,CronJobDetail.Name,TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :sc.getTriggerId()];
         System.debug('Cron Trigger Details:'+ct);
         System.debug('Cron Trigger Id or Schedule Job Id:'+ct.Id);
         System.abortJob(ct.Id);
    }
    
    ///////////////////////////////////////// END: Scheduler Which Runs After 2 minutes if we found more then one Queuable job in a single Transaction //////////////////////////////////////////////////////

}
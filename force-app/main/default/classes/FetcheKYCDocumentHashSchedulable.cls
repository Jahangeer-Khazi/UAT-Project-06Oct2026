/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 28-11-2022
* 		Change History: 
*	     
*/
public class FetcheKYCDocumentHashSchedulable implements Schedulable {
    set<Id> caseId;
    public FetcheKYCDocumentHashSchedulable(set<Id> setCaseIdsSet){
        this.caseId = setCaseIdsSet;
    }
	public void execute(SchedulableContext sc){
         FetcheKYCDocumentHashQueuableAPI fetchDocumentHash = new FetcheKYCDocumentHashQueuableAPI(caseId);
		 System.enqueueJob(fetchDocumentHash);
         CronTrigger ct = [SELECT Id,CronJobDetail.Name,TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :sc.getTriggerId()];
         System.debug('Cron Trigger Details:'+ct);
         System.debug('Cron Trigger Id or Schedule Job Id:'+ct.Id);
         System.abortJob(ct.Id);
    }
}
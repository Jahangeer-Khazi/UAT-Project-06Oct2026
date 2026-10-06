public class FetchBcrbSchedulable implements Schedulable {
	set<Id> caseId;
    public FetchBcrbSchedulable(set<Id> setCaseIdsSet){
        this.caseId = setCaseIdsSet;
    }
    public void execute(SchedulableContext sc){
         FetchSTPFromBcrbAPI fetchBCRB = new FetchSTPFromBcrbAPI(caseId);
		 System.enqueueJob(fetchBCRB);
         CronTrigger ct = [SELECT Id,CronJobDetail.Name,TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :sc.getTriggerId()];
         System.debug('Cron Trigger BCRB Details:'+ct);
         System.debug('Cron Trigger BCRB Id or Schedule Job Id:'+ct.Id);
         System.abortJob(ct.Id);
    }
}
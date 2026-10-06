public class CustomerCacheSchedulable implements Schedulable{
	set<Id> caseId;
    public CustomerCacheSchedulable(set<Id> setCaseIdsSet){
        this.caseId = setCaseIdsSet;
    }
    public void execute(SchedulableContext sc){
         CustomerCacheQueuableAPI custCache = new CustomerCacheQueuableAPI(caseId);
         System.enqueueJob(custCache);
         CronTrigger ct = [SELECT Id,CronJobDetail.Name,TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :sc.getTriggerId()];
         System.debug('Cron Trigger Customer Cache Details:'+ct);
         System.debug('Cron Trigger Customer Cache Schedule Job Id:'+ct.Id);
         System.abortJob(ct.Id);
    }
}
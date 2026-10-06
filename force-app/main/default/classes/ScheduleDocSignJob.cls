public without sharing class ScheduleDocSignJob implements Schedulable{
    private Id caseId;
    private Map<String,String> details;
    public ScheduleDocSignJob(Id caseId, Map<String,String> details) {
        this.caseId = caseId;
        this.details = details;
    }
    public void execute(SchedulableContext sc) {
        CronTrigger ct = [SELECT Id,CronJobDetail.Name,TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :sc.getTriggerId()];
        System.debug('Cron Trigger Schedule Docusign Job Details:'+ct);
        DocuSignGetEnvelopeId.docuSignGetEnvelopeFuture(caseId,details);
        System.abortJob(ct.Id);
        System.debug('Job completed and unscheduled successfully.'); 
    }

}
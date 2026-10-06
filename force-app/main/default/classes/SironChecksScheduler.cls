/**
* Schedule to run SironCaseStatus
* @author: SP
* @createdDate: 2019-09-19
**/
global class SironChecksScheduler implements Schedulable{
    public SironChecksScheduler(){System.debug('SironChecksScheduler()');}
    
    global void execute(SchedulableContext sc){ 
        
        //If we're hitting limitation, we dont need to run it
        //We also dont need to re-run it because this schedule will run every hour
        if(Limits.getLimitQueueableJobs() - Limits.getQueueableJobs() > 0){
            System.enqueueJob(new SironCaseStatus(new List<ID>()));
        }
    }

}
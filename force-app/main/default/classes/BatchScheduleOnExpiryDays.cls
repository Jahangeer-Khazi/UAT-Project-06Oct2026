global class BatchScheduleOnExpiryDays implements Schedulable  {
    global void execute(SchedulableContext sc) 
    {
        PremiumRetentionExpDaysBatch bObj = new PremiumRetentionExpDaysBatch(); 
        database.executebatch(bObj);
    }
}
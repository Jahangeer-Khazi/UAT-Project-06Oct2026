global class Schedule_Batch_PR002_OPenPeriodicReview implements schedulable {
    global void execute(SchedulableContext sc){
       PR002_OpenPeriodicReviewCase  myBatch = new PR002_OpenPeriodicReviewCase ();
        Database.executeBatch(myBatch,20);
    }

}
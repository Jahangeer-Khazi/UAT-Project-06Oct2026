global class ReturnedCardsDestroyScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        ReturnedCardsDestroyBatch batch = new ReturnedCardsDestroyBatch();
        Database.executeBatch(batch, 200);
    }
}
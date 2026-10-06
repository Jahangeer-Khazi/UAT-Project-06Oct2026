// Schedulable class to run CaseExportBatch with parameter '180'
public class CaseExportBatchScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        // Instantiate the batch class with parameter
        CaseExportBatch batch = new CaseExportBatch('180');
        Database.executeBatch(batch);
    }
}
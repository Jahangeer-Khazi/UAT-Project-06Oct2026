@isTest
public class CaseExportBatchSchedulerTest {
	@isTest
    static void testSchedulerExecutesBatch() {
        // Start test context
        Test.startTest();

        // Create instance of scheduler and call execute manually
        CaseExportBatchScheduler scheduler = new CaseExportBatchScheduler();
        scheduler.execute(null); 

        Test.stopTest();
    }
}
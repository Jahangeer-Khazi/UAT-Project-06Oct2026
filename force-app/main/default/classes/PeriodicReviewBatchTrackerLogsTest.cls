/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 28-12-2022
* 		Change History: 
*	     
*/
@isTest
public class PeriodicReviewBatchTrackerLogsTest {
    @isTest
    static void unitTest1(){
        PeriodicReviewBatchTrackerLogs.successlog('Test Class','Apex Class','Success records','Account');
        PeriodicReviewBatchTrackerLogs.errorlog('Test Class','Apex Class','Failure records','Bad Code','Case');
        PeriodicReviewBatchTrackerLogs.existingPeriodicReviewCaseExist('Test Class', 'Apex Class', 'Success Records', 'Case', 'Having Existing Periodic Review Case');
        PeriodicReviewBatchTrackerLogs.successCaselog('Test Class', 'Apex Class', 'Success Records', 'Case');
        PeriodicReviewBatchTrackerLogs.errorCaselog('Test Class', 'Apex Class', 'Failure records', 'Bad Code', 'Case');
        PeriodicReviewBatchTrackerLogs.successCaselogWithUpdatedDocHash('Test Class', 'Apex Class', 'Success records', 'Case', true);
		PeriodicReviewBatchTrackerLogs.successCaselogWithCategory('Test Class', 'Apex Class', 'Success records', 'Case', 'Having Existing Periodic Review Case');
    }

}
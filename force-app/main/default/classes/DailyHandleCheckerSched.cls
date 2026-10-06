global class DailyHandleCheckerSched implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<Id> ids = new List<Id>();
        Integer caseCount = 0;
        for (Case c : [
            SELECT Id
            FROM Case
            WHERE (cc_Request_Type__c = 'Staff Joiner'
                   OR (cc_Request_Type__c = 'Staff Leaver' AND From_Date__c = :Date.today()))
              AND cc_Checker_Result__c = 'Approve'
        ]) {
            ids.add(c.Id);
            caseCount++;
        }
        if (!ids.isEmpty()) {
            Set<Id> idSet = new Set<Id>(ids);
            System.enqueueJob(new HandleCheckerApprovalQueueable(idSet));
        } else {
            System.debug('DailyHandleCheckerSched.execute() - No qualifying Cases found, skipping job queueing');
        }
    }
}
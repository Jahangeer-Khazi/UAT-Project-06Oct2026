/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 08/07/2024
*       Change History: 
*/
global class DeleteAuditRecordsBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    List<String> audRecIdsToDelete = new List<String>();
    Integer executeCount = 1;
    public DeleteAuditRecordsBatch(List<String> auditIds){
        if(auditIds.size() > 0){
            audRecIdsToDelete.addAll(auditIds);
        }
        System.debug('Audit Record Ids Size:'+audRecIdsToDelete.size());
    }
	global Database.QueryLocator start(Database.BatchableContext BC){
        String query = '';
        query = 'Select id from Customer_Pages_Audit_Trail__c where id IN : audRecIdsToDelete';
        return Database.getQueryLocator(query);
        
	}
    global void execute(Database.BatchableContext BC, List<Customer_Pages_Audit_Trail__c> lstAuditRecs){
        System.debug('Execute Method Count:'+executeCount);
        if(lstAuditRecs.size()>0){
            delete lstAuditRecs;
            database.emptyRecycleBin(lstAuditRecs);
            executeCount++;
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
}
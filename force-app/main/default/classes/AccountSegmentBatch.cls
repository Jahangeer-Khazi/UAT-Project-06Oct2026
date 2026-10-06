/********************************************************************************************
* @name                 AccountSegmentBatch
* @description          This batch would run one time only on production to update Segment_Change_Date__c date field.
* @date                 16/02/2026
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           16/02/2026     Initial Version
*********************************************************************************************
*/

global class AccountSegmentBatch implements Database.Batchable<SObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id,AccountId,CreatedDate,OldValue,NewValue FROM AccountHistory where Field = \'Segment__pc\' ORDER BY CreatedDate desc';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<AccountHistory> accHistoryList) {
    
        Map<Id,Date> accountIdMap = new Map<Id,Date>();
        
        System.debug('accHistoryList ' + accHistoryList);
        
        for(AccountHistory history :accHistoryList){
            System.debug('history ' + history.NewValue);
            if(history.NewValue == 'Premium'){
                accountIdMap.put(history.AccountId,history.CreatedDate.date());
            }
        }
        
        if(!accountIdMap.isEmpty()){
         	List<Account> accountSegmentDateUpdateList = new List<Account>();
            for(Account acct : [Select Id,Segment_Change_Date__c FROM Account WHERE Id IN :accountIdMap.keyset() AND Segment_Change_Date__c = NULL]){
                acct.Segment_Change_Date__c = accountIdMap.get(acct.Id);
                accountSegmentDateUpdateList.add(acct);
                System.debug('acct ' + acct);
            }
            
            try {
                System.debug('acct record getting updated ');
            	update accountSegmentDateUpdateList;
                System.debug('acct record updated ');
            }
            catch(Exception ex){
                System.debug('Error while updating Segment_Change_Date__c - ' +  ex.getMessage());
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}
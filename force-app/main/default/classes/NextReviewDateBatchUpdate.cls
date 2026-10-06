/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 16-09-2025
* 		Change History: 
*	     
*/
global class NextReviewDateBatchUpdate implements Database.Batchable<sObject>, Database.Stateful{
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<String> AcctIds = System.Label.Account_ID_S_NEXT_REVIEW_BATCH.split(',');
        String query = '';
        /*SELECT Id,(Select id from KYC_Verifications__r Order By CreatedDate DESC LIMIT 1 ), Onboarding_Stage__pc,
        Region_Flag__pc,CustomerStatus__c,Bank_Account_Opening_Date__c,pr_Last_Review_Date__c,pr_NextReviewDate__c 
        from Account where Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED' AND Region_Flag__pc = 'Bahrain' AND Blacklisted__c != true 
        AND CustomerStatus__c = 'Active'*/
        if(System.Label.ACCT_RELATED_NEXT_REVIEW_ENABLE_TESTING.equalsIgnoreCase('true')){
            query = System.Label.ACCT_RELATED_KYC_VERIFICATION_SOQL + ' '+ 'AND Id IN : AcctIds';
        }
        if(System.Label.ACCT_RELATED_NEXT_REVIEW_ENABLE_FOR_PROD.equalsIgnoreCase('true')){
            query = System.Label.ACCT_RELATED_KYC_VERIFICATION_SOQL;
        }
        System.debug('********* Account Related KYC Verification SOQL Query ********' +query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> accList){
        List<Account> accToUpdate = new List<Account>();
        List<System_Action__c> lstAction = new List<System_Action__c>();
        if(accList.size()>0){
            for(Account acc: accList){
                try{
                    if(acc.KYC_Verifications__r.size() == 0 && acc.pr_NextReviewDate__c == null){
                        Date openingDate = acc.Bank_Account_Opening_Date__c != null ? acc.Bank_Account_Opening_Date__c.date() : null;
                        acc.pr_NextReviewDate__c = openingDate;
                        accToUpdate.add(acc);
                    }
                }catch(Exception ex){
                    System_Action__c errorAction = new System_Action__c();
                    errorAction.Account__c = acc.Id;
                    errorAction.Account_Number__c = acc.CIF__pc;
                    errorAction.Type__c = 'KYC Verification';
                    errorAction.Action__c = 'Periodic Review';
                    errorAction.Origin__c = 'CRM';
                    errorAction.Response_Body__c = 'Error while updating account ' + acc.Id + ': ' + ex.getMessage();
                    lstAction.add(errorAction);
                }
            }//for loop Ends 
        }//If Ends
        if(accToUpdate.size()>0){
            Database.SaveResult[] accResults = Database.update(accToUpdate, false);
            for(Integer i = 0; i < accResults.size(); i++) {
                if (!accResults[i].isSuccess()) {
                    for (Database.Error err : accResults[i].getErrors()) {
                        System_Action__c errorAction = new System_Action__c();
                        errorAction.Account__c = accToUpdate[i].Id;
                        errorAction.Account_Number__c = accToUpdate[i].CIF__pc;
                        errorAction.Type__c = 'KYC Verification';
                        errorAction.Action__c = 'Periodic Review';
                        errorAction.Origin__c = 'CRM';
                        errorAction.Response_Body__c = 'Error updating Account record: ' + err.getMessage();
                        lstAction.add(errorAction);
                    }
                }
            }
        }
        if(!lstAction.isEmpty()){
            try{
                insert lstAction;
            }catch(Exception ex){
                System.debug('Error inserting System_Action__c logs: ' + ex.getMessage());
            }
            
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
}
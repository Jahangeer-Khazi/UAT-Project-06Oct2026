/**
 * Created by AHSISH on 15/12/2022.
 * //Update the MoEngage fields - RM-1936: https://bank-abc.atlassian.net/browse/RM-1936
 */
global with sharing class BatchCls_UpdatePushNotificationFields implements Database.Batchable<SObject> {
    //where Id = \'a0O1j000002s3cxEAA\'
    global Database.QueryLocator start(Database.BatchableContext bc) {
         String contactQuery = 'SELECT Id, Push_Notifications__pc, Push_Notifications_Marketing__pc, Push_Notifications_Transactional__pc FROM Account where Onboarding_Stage__pc=\'ACCOUNT_ACTIVATED\' AND Archived__pc=FALSE AND Push_Notifications__pc=FALSE';
        System.debug('Query Locator Result --> ' +contactQuery);
        return Database.getQueryLocator(contactQuery);

    }
    
    global void execute(Database.BatchableContext info, List<Account> scope) {
        System.debug('Total records ' +scope.size());
        List<Account> accUpdate = (List<Account>)scope;
        for(Account acc : accUpdate){
            acc.Push_Notifications__pc = TRUE;
            acc.Push_Notifications_Marketing__pc = TRUE;
            acc.Push_Notifications_Transactional__pc = TRUE;
        }
        if(accUpdate.size()>0){
            System.debug('Total records updated ' +accUpdate.size());
            update accUpdate;
        }
    }
    global void finish(Database.BatchableContext info) {

    }

}
/**
 * @description       : This is the batch class (Executed one time) should be executed against all customers to update their status to “Active“
 * @author            : ANISS MBARKI
 * @creation date     : 02-02-2022
 * History Changes :  
**/
global without sharing class APB02_UpdateCustomersToActive implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id,CustomerStatus__c FROM Account WHERE CustomerStatus__c = null AND Archived__pc = false AND Onboarding_Stage__pc = \'ACCOUNT_ACTIVATED\' ');
    }

    global void execute(Database.BatchableContext bc, List<Account> accList) {
        System.debug('execute APB02_UpdateCustomersToActive **********************');
        for(Account objAcc : accList){
            objAcc.CustomerStatus__c = 'Active';
        }

        if(accList != null && accList.size()>0){
            update accList;
        }
    }

    
    global void finish(Database.BatchableContext bc) {
        System.debug('APB02_UpdateCustomersToActive finished !');
    }
}
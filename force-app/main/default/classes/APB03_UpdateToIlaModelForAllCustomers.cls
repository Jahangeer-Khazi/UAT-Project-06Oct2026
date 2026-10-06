/**
 * @description       : This is the batch class (Executed one time) should be executed against all customers to update their Subscription Model to “Ila"
 * @author            : Hamza Chaoui
 * @creation date     : 30-05-2022
 * History Changes :  
**/
global with sharing class APB03_UpdateToIlaModelForAllCustomers implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id,Subscription_Model__pc FROM Account WHERE Subscription_Model__pc = null AND Archived__pc = false ');
    }

    global void execute(Database.BatchableContext bc, List<Account> accList) {
        System.debug('execute APB03_UpdateToIlaModelForAllCustomers **********************');
        for(Account objAcc : accList){
            objAcc.Subscription_Model__pc = 'ila';
        }

        if(accList != null && accList.size()>0){
            update accList;
        }
    }

    
    global void finish(Database.BatchableContext bc) {
        System.debug('APB03_UpdateToIlaModelForAllCustomers finished !');
    }
}
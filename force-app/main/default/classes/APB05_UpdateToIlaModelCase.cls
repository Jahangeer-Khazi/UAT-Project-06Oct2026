/*
* @author Hamza CHAOUI
 * @date Création 20-05-2022

 * @description :  batch class that modify the new field case model to ila 
Version History :

*/
global with sharing class APB05_UpdateToIlaModelCase  implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id,Case_Model__c FROM Case WHERE '+system.Label.isb_batchWhere);
    }

    global void execute(Database.BatchableContext bc, List<Case> CaseList) {
        System.debug('execute APB05_UpdateToIlaModelCase **********************');
        for(Case objCase : CaseList){
            objCase.Case_Model__c = 'ila';
        }

        if(CaseList != null && CaseList.size()>0){
            update  CaseList;
        }
    }

    
    global void finish(Database.BatchableContext bc) {
        System.debug('APB05_UpdateToIlaModelCase finished !');
    }
}
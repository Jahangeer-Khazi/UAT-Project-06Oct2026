/*
* @author Hamza CHAOUI
 * @date Création 30-05-2022

 * @description :  batch class that modify the new field document model to ila 
Version History :

*/
global without sharing  class APB04_UpdateToIlaModelForCustDocument implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('Select id, Document_Model__c from Content__c WHERE Document_Model__c = null  ');//ToDo : Where ... to check with Ashish
    }

    global void execute(Database.BatchableContext bc, List<Content__c> contList) {
      
        System.debug('execute APB04_UpdateToIlaModelForCustDocument **********************');
        for(Content__c objCon : contList )
        {
                objCon.Document_Model__c='ila';   
        }

        if(contList != null && contList.size()>0){
            update contList;
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug('APB04_UpdateToIlaModelForCustDocument finished !');
    }

}
/********************************************************************************************
* @name                 CRMNewsRibbonTrigger
* @description          Trigger for CRM_News_Ribbon__c object
* @date                 15/05/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           15/05/2025     Initial Version
*********************************************************************************************
*/
trigger CRMNewsRibbonTrigger on CRM_News_Ribbon__c (before Insert,before Update) {

    if(Trigger.isBefore){
        CRMNewsRibbonTriggerHandler.beforeUpsert(Trigger.New,Trigger.oldMap);
    }
}
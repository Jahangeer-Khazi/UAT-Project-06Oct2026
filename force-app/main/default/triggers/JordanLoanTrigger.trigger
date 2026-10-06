/********************************************************************************************
* @name                 JordanLoanTrigger
* @description          Jordan trigger would manage to populate customer if the customer record is empty and CIF is populated.
* @date                 23/12/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           16/11/2025     Initial Version
*********************************************************************************************
*/

trigger JordanLoanTrigger on Jordan_Loan__c (after insert,before insert,before update,after update) {

    if(Trigger.isInsert && Trigger.isBefore){
        JordanLoanTriggerHandler.beforeInsert(Trigger.New);
    }
    
    if(Trigger.isInsert && Trigger.isAfter){
        JordanLoanTriggerHandler.afterInsert(Trigger.New);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        if(!CustomEmailComposerController.bypassTrigger){
        	JordanLoanTriggerHandler.beforeUpdate(Trigger.New,Trigger.oldMap);    
        }
    }
    
    if(Trigger.isUpdate && Trigger.isAfter){
    	JordanLoanTriggerHandler.afterUpdate(Trigger.New,Trigger.oldMap);
    }
}
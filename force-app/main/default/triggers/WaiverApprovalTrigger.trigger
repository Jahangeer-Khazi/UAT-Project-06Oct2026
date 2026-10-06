/********************************************************************************************
* @name                 WaiverApprovalTrigger
* @description          Waiver trigger handle the waiver record to submit for approval and approval email.
* @date                 08/01/2026
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           08/01/2026     Initial Version
*********************************************************************************************
*/

trigger WaiverApprovalTrigger on New_Wavier_Approval__c (after insert,after update) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        WaiverApprovalTriggerHandler.afterInsert(Trigger.new);
    }
    
	if(Trigger.isAfter && Trigger.isUpdate){
        WaiverApprovalTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
    }    

}
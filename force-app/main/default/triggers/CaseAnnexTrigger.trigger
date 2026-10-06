trigger CaseAnnexTrigger on CaseAnnex__c (before update,after update) {
	if(Trigger.isUpdate && Trigger.isBefore){
        CaseAnnexHandler.loanApproverApproved(Trigger.newMap, Trigger.oldMap);
    }
}
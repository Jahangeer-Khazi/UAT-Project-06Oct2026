trigger CaseAgingLineItemTrigger on Case_Aging_Line_Item__c (before insert) {
	if (Trigger.isBefore && Trigger.isInsert) {
        CaseSLATriggerHandler.populateOwnerAndGroupQueue(Trigger.new);
    }
}
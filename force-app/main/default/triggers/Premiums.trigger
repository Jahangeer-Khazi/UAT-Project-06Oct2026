trigger Premiums on Premium_Retention_Request__c (After insert) {
    Map<string, Triggers__c> triggerSwitch =Triggers__c.getAll();
    if(triggerSwitch!=null && triggerSwitch.containsKey('Premium_Retention_Request__c') && triggerSwitch.get('Premium_Retention_Request__c').Is_Active__c)
    {
	 if (trigger.isAfter ){
		if( trigger.isInsert ) 
		{
			PremiumHandler.afterinsert(trigger.new);
		}
	}
    }
}
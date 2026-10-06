({
	
	close: function (component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
	approvePrepaidCard: function (component, event, helper) {
        component.set("v.diableButton",true);		
        helper.approvePrepaidCard(component, event, helper);
	}
})
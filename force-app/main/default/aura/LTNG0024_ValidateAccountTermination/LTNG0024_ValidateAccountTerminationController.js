({
	
	close: function (component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
	validateAcc: function (component, event, helper) {
        component.set("v.diableButton",true);		
        helper.validateAcc(component, event, helper);
	}
})
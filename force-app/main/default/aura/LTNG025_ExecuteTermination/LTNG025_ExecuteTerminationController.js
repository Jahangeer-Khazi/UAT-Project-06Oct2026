({
	
	close: function (component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
	terminateAcc: function (component, event, helper) {
        component.set("v.diableButton",true);		
        helper.terminateAcc(component, event, helper);
	}
})
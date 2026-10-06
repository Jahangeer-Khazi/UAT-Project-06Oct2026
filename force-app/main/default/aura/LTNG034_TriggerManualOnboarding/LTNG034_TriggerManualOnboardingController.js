({
	
	close: function (component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
	closeCase: function (component, event, helper) {
        component.set("v.diableButton",true);		
	
        helper.closeCase(component, event, helper);
	}
})
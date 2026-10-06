({
	
	close: function (component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
	callApi: function (component, event, helper) {
        component.set("v.diableButton",true);		
        helper.callDrawApi(component, event, helper);
	}
})
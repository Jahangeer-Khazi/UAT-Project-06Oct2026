({
	
	close: function (component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
	calculateFeesButton: function (component, event, helper) {
        console.log('calculateFeesButton***********');
        component.set("v.diableButton",true);		
        helper.calculateFees(component, event, helper);
	}
})
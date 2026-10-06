({
	doInit: function (component, event, helper) {
		//...
		helper.getCases(component, event, helper);
	},
	close: function (component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	}
})
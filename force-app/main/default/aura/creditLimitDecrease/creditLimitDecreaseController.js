({
	init : function(component, event, helper) {
		
	},
    handleOnSubmit: function(component, event, helper) {
        helper.showSpinner(component, event, helper);
        helper.checkActiveCards(component, event, helper);
    }
})
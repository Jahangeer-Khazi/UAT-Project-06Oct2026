({
    validateAcc: function (component, event, helper) {
		component.set("v.isProcessing", true);
		var action = component.get("c.validateAccClosureViaApi");
		action.setParams({
			caseId: component.get('v.recordId')
		});

		action.setCallback(this, function (response) {
            var state = response.getState();
            component.set("v.isProcessing", false);
			if (state == "SUCCESS") {
                let data = response.getReturnValue();
				$A.get("e.force:closeQuickAction").fire();
				//helper.handleSuccess(data.messageApi);
				$A.get('e.force:refreshView').fire();
			}
			if (state == "ERROR") {
				$A.get("e.force:closeQuickAction").fire();
				//helper.handleErrors(response.getError());
			}
			
		});
		$A.enqueueAction(action);
	},
	handleErrors: function (errors) {
		// Configure error toast
		let toastParams = {
			mode: "sticky",
			title: "Erreur",
			message: errors, // Default error message
			type: "error"
		};
		// Pass the error message if any
		if (errors && Array.isArray(errors) && errors.length > 0) {
			toastParams.message = errors[0].message;
		}
		// Fire error toast
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams(toastParams);
		toastEvent.fire();
	},
	handleSuccess: function (message) {
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": "Success!",
			"type": 'success',
			"message": message
		});
		toastEvent.fire();
	},
})
({
	 /*showSuccessToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Toast Message',
            message: 'This is Success Toast...!!!',
            duration:' 4000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },*/
    handleloadCardDetails : function (component, event, helper, csId) {
        var action = component.get('c.loadCardDetails');
        action.setParams({
            csId : csId
        });
        action.setCallback(this, function (actionResult) {
            var status = actionResult.getState();
            if (status === "SUCCESS") {
                let data = actionResult.getReturnValue();
                debugger;
                if ($A.util.isEmpty(data)) {
                component.find('apexService').showSuccessMessage($A.get("$Label.c.Request_Sent_Successfully"));
            } else {
                helper.handleloadCardDetails(component, event, helper, csId);
            }
            } else if (status === "ERROR") {
                //var errors = response.getError();
                // Process error returned by server
                helper.handleErrors('Only L2 agents can close this case!');
            }
            else {
                console.error("AUTRE ERROR");
                // Handle other reponse states
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
})
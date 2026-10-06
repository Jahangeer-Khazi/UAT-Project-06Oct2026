({
	showSpinner: function (component, event, helper) {
        component.set("v.showSpinner",true);
    },
    hideSpinner: function (component, event, helper) {
        component.set("v.showSpinner",false);
    },
    handleErrors: function (errors, addError) {
        // Configure error toast
        let toastParams = {
            mode: "sticky",
            title: "Erreur",
            message: errors, // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = addError + '' + errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    }, loadInstrument : function (component, event, helper) {
        var action = component.get('c.getInstrumentListViaApi');
        action.setCallback(this, function (actionResult) {
            var status = actionResult.getState();
            if (status === "SUCCESS") {
                let data = actionResult.getReturnValue();
                console.log(JSON.stringify(data));
                if (data) {                    
                    component.set("v.currentInst",null);
                    component.set("v.InstrumentList",data);
                }
            } else if (statut === "ERROR") {
                // Process error returned by server
                helper.handleErrors(actionResult.getError(), '');
            }
            else {
                console.error("AUTRE ERROR");
                // Handle other reponse states
            }
        });
        $A.enqueueAction(action);
    },
})
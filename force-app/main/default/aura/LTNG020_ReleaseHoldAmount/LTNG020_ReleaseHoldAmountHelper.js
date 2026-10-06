({
	getAccDetails: function (component, event, helper, currentAcc) {
       
        var accountId = component.get('v.accountId');
        var action = component.get('c.getAccDetailsViaApi');
        action.setParams(
            {
                iban: currentAcc.iban,
                accountId : accountId,
                caseModel : component.get("v.caseModel")//CH01
            });
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            component.set("v.showCmp", true);
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if (data) {
                    component.set("v.accDetails", {holdReferenceNumber: null,holdAmount:null,holdDate:null,holdExpiryDate:null,HoldType:null} );
                    component.set("v.TransactionsToHoldList", data);
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
    },
})
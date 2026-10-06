/**
Change History :
*         #CH01 : #D&A Team #24-06-2022# Added Case model parameter to add alburaq logic.
*/
({
    getCurrentCards: function (component, event, helper, accId) {
        var action = component.get('c.getCurrentCardsViaApi');
        action.setParams(
            {
                accountId: accId,
                caseModel : component.get("v.caseModel")//CHO1
            });
        action.setCallback(this, function (actionResult) {
            component.set("v.showCmp", true);
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if (data) {
                    component.set("v.currentCards", data);
                    console.log('Current cards --->',component.get("v.currentCards"));
                    let current = component.get("v.valueCurrentCard");  
                    if (current) {
                        console.error('=====>getCurrentCards ' + component.get("v.valueCurrentCard"));
                        component.set("v.valueCurrentCard", "");
                        setTimeout(() => { component.set("v.valueCurrentCard", current); }, 60);
                    }

                }
            } else if (statut === "ERROR") {
                // Process error returned by server
                helper.handleErrors(actionResult.getError(), 'Error in Credit Card Options API : ');
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
({
    enterIdNumberButton : function (component, event, helper) {
        helper.showSpinner(component);
        var fields = event.getParam("fields");

        var action = component.get('c.enterIdNumberButton');
        action.setParams({
            caseId : component.get("v.recordId"),
            cardHolderIdNumber : fields["sc_Card_Holder_Jordan_ID_Number__c"],
            cardHolderIdType : fields["sc_CardHolder_ID_Type__c"]
		});
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if(data){
                    helper.handleErrors(data, '');
                }else{
                    helper.handleSuccess("Case has been updated successfully.");
                }

                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            } else if (statut === "ERROR") {
                // Process error returned by server
                helper.handleErrors(actionResult.getError(), '');
                $A.get("e.force:closeQuickAction").fire();
            }
            else {
                console.error("AUTRE ERROR");
                // Handle other reponse states
            }
        });
        $A.enqueueAction(action);
    },
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
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
    handleSuccess: function (message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Success!",
            "message": message
        });
        toastEvent.fire();
    },
})
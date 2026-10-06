({
    doInit : function (component, event, helper, accId) {
        var action = component.get('c.getKycRecordType');
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if (data) {
                    component.set("v.recordTypeId", data);
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
        $A.enqueueAction(action);},
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
    },
    validateOpencase:function (component, event, helper, accId) {
        var recId = component.get("v.recordId");
        var action = component.get('c.validateCaseCreationRequest');
         action.setParams({'accountId':recId});
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if (data) {
                    component.set("v.isvalidPeriodic", data);
                }else{
                       var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                        component.find('notifyId').showNotice({
                            "variant": "warning",
                            "header": "Open KYC Verification case",
                            "message": "KYC Verification case cannot be created as customer already has an open KYC Verification case.",
                            closeCallback: function(component, event, helper) 
                            {window.setTimeout($A.getCallback(function() {}),100);}});   
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
    getTypeBasedRecordType:function (component, event, helper, Type) {
      //  var type = component.get("v.recordId");
        var action = component.get('c.getTypeBasedRecordType');
         action.setParams({'Type':Type});
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
           if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if (data) {
                    component.set("v.recordTypeId", data);
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
    }
})
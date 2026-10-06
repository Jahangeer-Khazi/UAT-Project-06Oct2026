({
    doInit : function (component, event, helper) {
        var action = component.get('c.getBidAllocationRecordType');
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
    },
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
    loadInstrument : function (component, event, helper) {
        var action = component.get('c.getInstrumentListViaApi');
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if (data) {
                    component.set("v.SelInstrument", null);
                    component.set("v.InstrumentList", data);
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
    GenerateBIDAllocation: function(component,event,helper){
        var action = component.get('c.generateBIDAllocation');
        var InstrumentId = component.find('ISINCODE').get('v.value');
      //  var indcode = component.find('ISINCODE').get('v.value').lastIndexOf('-')+1;
      //  var ISINCode = component.find('ISINCODE').get('v.value').substring(indcode);
      //  var ISINType = component.find('ISINCODE').get('v.value').split('-')[0];
       //alert('##ISINCode2334'+ISINCode);
        action.setParams({'InstrumentID':InstrumentId,'triggerType':'Manual'});
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if (data) {
                    var navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
            "listViewId": '00BPw000001eDuoMAE',
            "listViewName": null,
            "scope": "Bid_Allocation__c"
        });
        navEvent.fire();
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
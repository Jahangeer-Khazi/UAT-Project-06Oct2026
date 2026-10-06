/**
 * Change History :
 *		  #CH01 : Maksud Ali 10/09/2025 CRM Enhancements - Validating Generate case request, for outstanding, cancelling and no due
 */ 
({
    doInit : function (component, event, helper, accId) {
        var action = component.get('c.getCollectionLetterCaseRecordType');
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
    getQueueId : function (component, event, helper, accId) {
        var action = component.get('c.getCollectionLetterCaseQueue');
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if (data) {
                    component.set("v.queueId", data);
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
    getDefaultAccountIdViaApi: function (component, event, helper) {
		console.log('getDefaultAccountIdViaApi --> ');

		var accId = component.get('v.recordId');
		var action = component.get('c.getDefaultAccountIdViaApi');
        action.setParams(
        {
			accountId: accId,
			caseModel: component.get("v.caseModel")
        });
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
        		console.log('Success --> default account.Id');
				console.error(data);
				component.set("v.defaultAccId", data);

            } else if (statut === "ERROR") {
                // Process error returned by server
                helper.handleErrors(actionResult.getError(), 'Error in Accounts List API : ');
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
            title: "Error",
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
    },//CH01 - Start
    fetchAndValidateCreditCard : function(component, event, helper){
        var sub_type = component.get('v.sub_type');
        console.log("subtype ",sub_type);
        helper.showSpinner(component);
        if(sub_type.toLowerCase() == 'outstanding balance letter' || sub_type.toLowerCase() == 'no due letter'){
        	helper.validateCard(component, helper,'D');
        }
        else if(sub_type.toLowerCase() == 'cancellation letter'){
        	helper.validateCard(component, helper,'A');
        }
        else {
            component.find('form').submit();
       	}
    },
    validateCard: function(component,helper,filterOption){
		console.log("filterOption ",filterOption);
		var sub_type = component.get('v.sub_type');
        
        var action = component.get('c.validateCreditCard');
        
        action.setParams(
        {
			accountId: component.get('v.recordId'),
			filerOption: filterOption,
            letterType: sub_type.toLowerCase()
        });
        
        console.log("accountid ",component.get('v.recordId'));
        //console.log("filerOption ",filerOption);
        console.log("sub_type ",sub_type.toLowerCase());
        
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
            	let data = actionResult.getReturnValue();
                console.log('credit card data ',data);
                if(data == 'success'){
                    component.find('form').submit();
                }
                else {
                    helper.hideSpinner(component);
                    helper.handleErrors(data, '');
                }
            }
            else if (statut === "ERROR") {
                // Process error returned by server
                helper.hideSpinner(component);
                helper.handleErrors(actionResult.getError(), 'Error in Credit Card API : ');
            }
            else {
                helper.hideSpinner(component);
                console.error("AUTRE ERROR");
            }
        });
        $A.enqueueAction(action);
    }
    //CH01 - End
})
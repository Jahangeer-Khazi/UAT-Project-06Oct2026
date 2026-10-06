({
	getBankStatementRecordType: function (component, event, helper) {
        var action = component.get('c.getBankStatementRecordType');
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if (data) {
                    component.set("v.bankStatementRecordTypeId", data);
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
	getAccountConfigViaApi: function (component, event, helper) {
		console.log('getAccountConfigViaApi --> ');
        component.set("v.accountOptions",null);
        component.set('v.currentAcc',null);

		var accId = component.get('v.recordId');
		var action = component.get('c.getAccountConfigViaApi');
        action.setParams(
        {
			accountId: accId,
			caseModel: component.get("v.caseModel")
        });
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
        		console.log('Success --> ');
				console.error(data);
                
                var accounts = data;
                var updatedAccounts = [];
                
                accounts.forEach(function(accObj) {
                    // Clone object to avoid reference issues
                    let tempObj = Object.assign({}, accObj);
                    
                    // Check templateId
                    if (tempObj.account && tempObj.account.templateId === 'HY') {
                        tempObj.label = tempObj.id +' - '+ tempObj.account.currency.code + ' - HYSA';
                    } else {
                        tempObj.label = tempObj.id +' - '+ tempObj.account.currency.code; // fallback
                    }
                    
                    updatedAccounts.push(tempObj);
                });
                
                // Set back to attribute
                component.set("v.accountOptions", updatedAccounts);
                
                
                data.findIndex(item => {
                    if(item.account.defaultAccount == true ){
                        component.set('v.defaultAcc',item)
                    }
                });

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
    getCCardOptionsViaApi: function (component, event, helper, subType) {
		console.log('getCCardOptionsViaApi --> ');
        component.set("v.creditOptions",null);
        component.set('v.currentCard',null);

		var accId = component.get('v.recordId');
		var action = component.get('c.getCCardOptionsViaApi');
        action.setParams(
        {
			accountId: accId,
            subType: subType,
			caseModel: component.get("v.caseModel")
        });
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
        		console.log('Success --> ');
				console.error(data);

                component.set("v.showCCSection",true);
				component.set("v.creditOptions", data);
            } else if (statut === "ERROR") {
                // Process error returned by server
                helper.handleErrors(actionResult.getError(), 'Error in Credit Card List API : ');
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
})
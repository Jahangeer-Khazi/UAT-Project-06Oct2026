({
	checkActiveCards: function (component, event, helper) {
        var helper = this;
        let fetchActiveCards = JSON.stringify(component.get('v.activeCards'));
        let fetchCards = JSON.parse(fetchActiveCards);
        console.log('After Parsing:',fetchCards);
        let selectedCardId = component.get('v.cardId');
        console.log('Selected Card Id:',component.get('v.cardId'));
        var cardDetailResult = fetchCards.filter(obj => {
  			return obj.id === selectedCardId; // Checking Selected Card Id with Current Cards
		})
        console.log('Result Using Arrow Function:',cardDetailResult);
        console.log('Type of Result:',typeof cardDetailResult);
        
        var action = component.get("c.decreaseCreditLimit");
        var requestedLimit = component.get('v.requestedCreditLimit');
        console.log('Requested Limit Type:',typeof requestedLimit);
        var convertRequestedLimit = parseInt(requestedLimit);
        console.log('After conversion Requested Limit Type:',typeof convertRequestedLimit);
        if(convertRequestedLimit > 0){
            action.setParams({
                caseId: component.get('v.caseId'),
                requestedLimit: requestedLimit,
                cardDetail: JSON.stringify(cardDetailResult)
            });
            
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('Server State:',state);
                if (state == "SUCCESS") {
                    let data = response.getReturnValue();
                    
                    if(data.successMessageFromApi != null && data.successMessageFromApi != ''){
                        helper.handleSuccess(component,data.successMessageFromApi);
                    }else{
                        helper.handleErrors(component,'Server Error Please Check System Action Or Contact your administrator for more infos ! ');
                    }
                }
                if (state == "ERROR") {
                    helper.handleErrors(response.getError());
                }
                
            });
            $A.enqueueAction(action);
        }
        else{
            helper.handleErrors(component, 'Please fill a valid number for Request Credit Limit');
        }
    },
    
    handleSuccess: function (component,message) {
        var helper = this;
        this.hideSpinner(component);
        let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": "Success!",
			"type": 'success',
			"message": message
		});
		toastEvent.fire();
        component.set("v.enableForm",false);
	},
    
    handleErrors: function (component,errors) {
        var helper = this;
        this.hideSpinner(component);
		// Configure error toast
		let toastParams = {
			mode: "sticky",
			title: "Error",
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
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
})
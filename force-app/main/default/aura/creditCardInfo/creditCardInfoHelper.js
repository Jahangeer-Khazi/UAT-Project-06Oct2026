({
	fetchCurrentCards  : function(component) {
        component.set("v.isLoadingCards",true);
        var action = component.get("c.getCurrentCards");
        action.setParams({
            accID : component.get("v.customerId")
        });

    	action.setCallback(this, function(response) {
            console.log('Credit Card Details:',response.getReturnValue());
            console.log('Response State:',response.getState());
			if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.length > 0){
                    component.set("v.currentCards",result);
                     component.set("v.isLoadingCards",false);
                }
                else{
                  component.set("v.isLoadingCards",false);
                  var customerCIF = component.get("v.cifNumber");
                  component.set("v.message","No Credit Cards Details found for customer : " + customerCIF); 
                }
		    }
            else if (response.getState() === "ERROR") {
                component.set("v.isLoadingCards",false);
                var errors = response.getError();
                var errorMessage = "";
                console.error('Apex Class error: ', JSON.stringify(errors));
                if(errors && errors[0] && errors[0].message) {
                     errorMessage = errors[0].message;
                     console.error('Primary error message: ', errorMessage);
               }
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error",
                        "message": errorMessage
                    });
                toastEvent.fire();
            }
    	});

    	$A.enqueueAction(action);
		
	},
    fetchCurrentLimit  : function(component,cardId) {
        var action = component.get("c.loadCardDetailsToFetchLimit");
        action.setParams({
            accID : component.get("v.customerId"),
            requestedPCINumber: cardId
        });

    	action.setCallback(this, function(response) {
			if(response.getState() === "SUCCESS") {
				var result = response.getReturnValue();
                console.log('Credit Limit:',result.creditLimit);
                component.set('v.currentCreditLimit',result.creditLimit);
                component.set('v.isLoadingLimit',false);
        	}
    	});

    	$A.enqueueAction(action);
		
	},
})
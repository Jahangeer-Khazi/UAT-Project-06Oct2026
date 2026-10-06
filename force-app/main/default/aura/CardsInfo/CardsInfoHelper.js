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
                  var customerCIF = component.get("v.cifNumber");
                  component.set("v.isLoadingCards",false);
                  component.set("v.message","No Credit Cards Details found for customer : " +customerCIF); 
                }
		    }
            else if (response.getState() === "ERROR") {
                component.set("v.isLoadingCards",false);
                var errors = response.getError();
                var errorMessage = "";
                console.error('Apex Class error in Credit Cards: ', JSON.stringify(errors));
                if(errors && errors[0] && errors[0].message) {
                     errorMessage = errors[0].message;
                     console.error('Primary error message Credit Cards: ', errorMessage);
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
    fetchDebitCards  : function(component) {
        console.log('Fetch Debit Cards')
        component.set("v.isLoadingDebitCards",true);
        var action = component.get("c.getCurrentDebitCards");
        action.setParams({
            accID : component.get("v.customerId")
        });

    	action.setCallback(this, function(response) {
            console.log('Debit Card Details:',response.getReturnValue());
            console.log('Response State:',response.getState());
			if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.length > 0){
                    component.set("v.currentDebitCards",result);
                     component.set("v.isLoadingDebitCards",false);
                }
                else{
                  var customerCIF = component.get("v.cifNumber");
                  component.set("v.isLoadingDebitCards",false);
                  component.set("v.messageDebit","No Debit Cards Details found for customer : " +customerCIF); 
                }
		    }
            else if (response.getState() === "ERROR") {
                component.set("v.isLoadingDebitCards",false);
                var errors = response.getError();
                var errorMessage = "";
                console.error('Apex Class error in Debit Cards: ', JSON.stringify(errors));
                if(errors && errors[0] && errors[0].message) {
                     errorMessage = errors[0].message;
                     console.error('Primary error message Debit Cards: ', errorMessage);
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
})
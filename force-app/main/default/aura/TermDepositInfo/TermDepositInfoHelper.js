({
	fetchFixedDeposits : function(component) {
		component.set("v.isLoadingTermDeposits",true);
        var action = component.get("c.getFixedDeposits");

        action.setParams({
			accID :component.get("v.customerId")
		});

        action.setCallback(this,function(response){

            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.length >0 ){
                    component.set("v.fixedDeposits",response.getReturnValue());
                    component.set("v.isLoadingTermDeposits",false);
                }else{
                  var customerCIF = component.get("v.cifNumber");
                  component.set("v.isLoadingTermDeposits",false);
                  component.set("v.message","No Fixed Deposit found for customer : " + customerCIF); 
                }
            }
            else if(response.getState() === "ERROR"){
                console.log(response.getError());
                component.set("v.isLoadingTermDeposits",false);
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
    }
})
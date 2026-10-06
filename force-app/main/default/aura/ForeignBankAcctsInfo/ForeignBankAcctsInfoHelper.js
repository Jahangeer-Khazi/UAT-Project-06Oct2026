({
	fetchActiveForeignAccts : function(component) {
		component.set("v.isLoadingaccts",true);
        var action = component.get("c.getForeignAccounts");

        action.setParams({
			accID :component.get("v.customerId")
		});

        action.setCallback(this,function(response){

            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.length >0 ){
                    component.set("v.bankAccts",response.getReturnValue());
                    component.set("v.isLoadingaccts",false);
                }else{
                  var customerCIF = component.get("v.cifNumber");
                  component.set("v.isLoadingaccts",false);
                  component.set("v.message","No Foreign Accounts found for customer : " + customerCIF); 
                }
            }
            else if(response.getState() === "ERROR"){
                console.log(response.getError());
                component.set("v.isLoadingaccts",false);
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
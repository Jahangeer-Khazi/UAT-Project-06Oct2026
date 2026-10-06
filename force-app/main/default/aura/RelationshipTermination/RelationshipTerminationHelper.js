({
	doInitHelper : function(component, event,helper,sObjectName,recordId) {
		
        component.set('v.showLoadingSpinner',true);
        var action = component.get("c.republishedData");
         console.log("objectName ==> "+sObjectName);
        console.log("recordId ==> "+recordId);
        action.setParams({
            objectName : sObjectName,
            recordId : recordId
        });
        
        action.setCallback(this, function(response){
                var state = response.getState();
                var data = response.getReturnValue();
                
                console.log("state ==> "+state);

            
                if (state === "SUCCESS" && data == null) {
                    component.set('v.showLoadingSpinner',false);
                    helper.handleSuccess('Validation check For Relationship Termination successfully Executed.');
                    $A.get("e.force:closeQuickAction").fire();
                	$A.get('e.force:refreshView').fire();
                }else if(state === "SUCCESS" && data != null){//custom error mesg from apex controller
                    helper.handleErrors(data);
                }
                else if (state == "ERROR") {
                    helper.handleErrors(response.getError());
                }
        });
        $A.enqueueAction(action);
    },
    handleErrors: function (errors) {
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
    handleSuccess: function (message) {
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": "Success!",
			"type": 'success',
			"message": message
		});
		toastEvent.fire();
	},
})
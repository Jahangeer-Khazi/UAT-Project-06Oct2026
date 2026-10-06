({
	onSuccessAction : function(component, event, helper) {
        console.log("Passport Expiry date have been Updated successfully.");
        component.set("v.flag",false); 
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"success",
            "title": "Success!",
            "message": "Passport Expiry Date have been updated successfully."
        });
        toastEvent.fire();
		
	}
})
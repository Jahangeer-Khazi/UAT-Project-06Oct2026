({
	onSuccessAction : function(component, event, helper) {
		console.log("Resident details have been Updated successfully.");
        component.set("v.flag",false); 
        //component.set("v.confirmationMsg",true); 
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"success",
            "title": "Success!",
            "message": "Wathiq details have been updated successfully."
        });
        toastEvent.fire();
	}
})
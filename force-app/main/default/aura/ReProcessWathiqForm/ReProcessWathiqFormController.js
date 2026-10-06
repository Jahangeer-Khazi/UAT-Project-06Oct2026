({
	onSuccessAction : function(component, event, helper) {
        component.set("v.flag",false); 
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"success",
            "title": "Success!",
            "message": "Re-Processing has been done successfully."
        });
        toastEvent.fire();
	}
})
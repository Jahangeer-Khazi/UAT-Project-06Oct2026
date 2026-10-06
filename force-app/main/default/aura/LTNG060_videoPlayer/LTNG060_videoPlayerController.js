({
    doInit : function(component, event, helper) {
        let action = component.get("c.getVideoUrl");
        action.setParams({ recordId: component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.videoUrl", response.getReturnValue());
            } else {
                console.error("Error loading video URL");
            }
        });
        $A.enqueueAction(action);
    }
})
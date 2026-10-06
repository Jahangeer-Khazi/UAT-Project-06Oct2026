({
	doInit : function(component, event, helper) {
        var action = component.get("c.setOwnerAsQueue"); 
        action.setParams({
            recId : component.get("v.recordId")
        });
        action.setCallback(this, function(resp) {
            if (resp.getState() === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    }
})
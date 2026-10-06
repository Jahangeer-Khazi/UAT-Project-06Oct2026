({
	handleClick : function(component, event, helper) {
        console.log('--> In Save Function-->');
        console.log('--> In Rec ID-->'+component.get("v.recordId"));
        console.log('--> In Refer Comment-->'+component.get("v.referComments"));
		var action = component.get("c.setMakerQueueAsOwner");
        action.setParams({ 
            				referCommentsSF  : component.get("v.referComments"),
            				recIDSF : component.get("v.recordId")
        
        				});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               console.log('--> Success-->');
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "INCOMPLETE") {
                console.log('--> Incomplete-->');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	}
})
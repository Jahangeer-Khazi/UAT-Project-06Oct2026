({
    loadCIF: function(component, guardianId) {
        if (!guardianId) {
            component.set("v.selectedGuardianCIF", null);
            return;
        }
        
        // Show loading state
        component.set("v.selectedGuardianCIF", "Loading...");
        
        const action = component.get("c.getAccountCIF");
        action.setParams({
            accountId: guardianId
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.selectedGuardianCIF", response.getReturnValue());
            } else if (state === "ERROR") {
                component.set("v.selectedGuardianCIF", "Error loading CIF");
                const errors = response.getError();
                console.error('Error loading CIF:', errors);
            }
        });
        
        $A.enqueueAction(action);
    }
})
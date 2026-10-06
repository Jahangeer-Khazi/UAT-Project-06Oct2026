({
    handleLoad: function(component, event, helper) {
        var caseType = component.find("caseType").get("v.value");
        component.set("v.caseType", caseType);
        console.log('caseType: ' , caseType );
        var cif = component.find("Customer_CIF").get("v.value");
        console.log("Fetching Customer Details ..");
        // Validate CIF before making the call
        if (!cif) {
            console.warn("CIF is empty, skipping server call.");
            return;
        }

        var action = component.get("c.fetchCustomerDetailsByCIF");
        action.setParams({ cif: cif });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                component.set("v.Customer", res);
                console.log("Customer Details Retrieved:", res);
            } 
            else if (state === "INCOMPLETE") {
                console.warn("Server call was incomplete. Check network connection.");
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error("Error fetching customer data:", errors[0].message);
                } else {
                    console.error("Unknown error occurred while fetching customer data.");
                }
            }
        });

        $A.enqueueAction(action);
    }
});
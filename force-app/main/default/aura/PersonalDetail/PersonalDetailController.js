({
	onFirstNameChanged : function(component, event, helper) {
        var firstName = component.find("firstName");
		var account = component.get("v.account");
        account.FirstName = firstName.get("v.value");
	},
    
    onLastNameChanged : function(component, event, helper) {
        var firstName = component.find("lastName");
		var account = component.get("v.account");
        account.LastName = firstName.get("v.value");
	},
    
    onGuardianChange: function (component, event, helper) {
    try {
        const source = event.getSource();
        const guardianId = source.get("v.value");

        if (guardianId) {
            component.set("v.selectedGuardianCIF", "Loading...");

            const action = component.get("c.getAccountCIF");
            action.setParams({
                accountId: guardianId[0]
            });

            action.setCallback(this, function (response) {
                const state = response.getState();

                if (state === "SUCCESS") {
                    const result = response.getReturnValue();
                    
                    // Set CIF value
                    const cif = result.cif ? result.cif.trim() : '';
                    component.set("v.selectedGuardianCIF", cif);
                    
                    // Set ID Number value (you'll need to add this attribute to your component)
                    const idNumber = result.idNumber ? result.idNumber.trim() : '';
                    component.set("v.selectedGuardianIdNumber", idNumber);

                    console.log('cif --->',cif);
                    console.log('idNumber --->',idNumber);
                    // Fire event with both values
                    const cifEvent = component.getEvent("cifUpdateEvent");
                    cifEvent.setParams({
                        "guardianCIF": cif,
                        "guardianIdNumber": idNumber
                    });
                    cifEvent.fire();
                    
                    component.set("v.errorMessage", "");

                } else if (state === "ERROR") {
                    const errors = response.getError();
                    source.set("v.value", null);
                    component.set("v.selectedGuardianCIF", '');
                    component.set("v.selectedGuardianIdNumber", '');
                    
                    let errorMessage = 'An error occurred while validating the guardian.';
                    
                    if (errors && errors.length > 0 && errors[0].message) {
                        errorMessage = errors[0].message;
                    }
                    
                    component.set("v.errorMessage", errorMessage);
                    
                    const toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Invalid Selection",
                        "message": errorMessage,
                        "type": "error"
                    });
                    toastEvent.fire();
                }
            });

            $A.enqueueAction(action);
        } else {
            component.set("v.selectedGuardianCIF", '');
            component.set("v.selectedGuardianIdNumber", '');
        }

    } catch (ex) {
        console.error('Error in onGuardianChange:', ex.message);
        if (source) {
            source.set("v.value", null);
        }
        component.set("v.selectedGuardianCIF", '');
        component.set("v.selectedGuardianIdNumber", '');
    }
},

    
    // Optional: Also handle when component initializes with existing value
    doInit: function(component, event, helper) {
        const guardianId = component.get("v.account.Guardian__pc");
        if (guardianId) {
            // Trigger the same logic to load CIF
            const source = { get: function() { return guardianId; } };
            helper.loadCIF(component, source);
        }
    }
})
({
    loadDocumentType: function(component) {
        component.set('v.isLoading', true);
        let recordId = component.get("v.recordId");
        
        let action = component.get("c.getDocumentType");
        action.setParams({ caseId: recordId });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state == "SUCCESS") {
                component.set('v.isLoading', false);
                let result = response.getReturnValue();
                component.set("v.selectedValues", result.DocumentType ? result.DocumentType.split(";") : []);
                component.set("v.caseStatus", result.Status);
                if (result.Status === "Closed") {
                    component.set("v.isButtonDisabled", true);
                }
            } else {
                component.set('v.isLoading', false);
                this.showToast("Error", "Error loading Document Type", "error");
            }
        });
        $A.enqueueAction(action);
    },
    
    saveDocumentType: function(component) {
        component.set('v.isLoading', true);
        let recordId = component.get("v.recordId");
        let documentType = component.get("v.selectedValues").join(";");
        
        let action = component.get("c.updateDocumentType");
        action.setParams({ caseId: recordId, documentType: documentType });
        
        // Check if both checkboxes are selected
        let selectedValues = component.get("v.selectedValues");
        let hasApprovalAttached = selectedValues.includes("Approval Attached");
        let hasDeclarationAttached = selectedValues.includes("Temporary Credit Declaration attached");
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                // If both checkboxes are selected, transfer the case to the Operations queue
                if (hasApprovalAttached && hasDeclarationAttached) {
                    let transferAction = component.get("c.transferToOperationsQueue");
                    transferAction.setParams({ caseId: recordId });

                    transferAction.setCallback(this, function(transferResponse) {
                        let transferState = transferResponse.getState();
                        if (transferState === "SUCCESS") {
                            component.set('v.isLoading', false);
                            component.find('apexService').showSuccessMessage("Document Type updated successfully and case transferred to Operations queue!");
                            $A.get('e.force:refreshView').fire();
                        } else {
                            component.set('v.isLoading', false);
                            this.showToast("Error", "Error transferring case to Operations queue.", "error");
                        }
                    });
                    $A.enqueueAction(transferAction);
                } else {
                    // If only one checkbox is selected, just show success message
                    component.set('v.isLoading', false);
                    component.find('apexService').showSuccessMessage("Document Type updated successfully!");
                    $A.get('e.force:refreshView').fire();
                }
            } else {
                component.set('v.isLoading', false);
                component.find('apexService').showSuccessMessage("Error updating Document Type");
                $A.get('e.force:refreshView').fire();
                //this.showToast("Error", "Error updating Document Type", "error");
            }
        });
        
        $A.enqueueAction(action);
    },
    
    showToast: function(title, message, variant) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: variant
        });
        toastEvent.fire();
    },
    
    validateContentRecords: function(component, selectedValues) {
        let recordId = component.get("v.recordId");
        let hasApprovalAttached = selectedValues.includes("Approval Attached");
        let hasDeclarationAttached = selectedValues.includes("Temporary Credit Declaration attached");

        // Validate "Approval Attached"
        if (hasApprovalAttached) {
            let action = component.get("c.hasContentRecords");
            action.setParams({ caseId: recordId, documentType: "Temporary Credit Approval" });
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    let hasRecords = response.getReturnValue();
                    if (!hasRecords) {
                        this.showToast("Error", "No 'Temporary Credit Approval' records found in related Content records.", "error");
                        return; // Exit if validation fails
                    }
                    // Proceed to validate "Temporary Credit Declaration attached"
                    if (hasDeclarationAttached) {
                        this.validateDeclarationRecords(component, recordId);
                    } else {
                        this.saveDocumentType(component); // Save if no declaration is selected
                    }
                } else {
                    this.showToast("Error", "Error validating Content records.", "error");
                }
            });
            $A.enqueueAction(action);
        } else if (hasDeclarationAttached) {
            // Validate "Temporary Credit Declaration attached"
            this.validateDeclarationRecords(component, recordId);
        } else {
            // Save if no additional validations are needed
            this.saveDocumentType(component);
        }
    },

    validateDeclarationRecords: function(component, recordId) {
        let action = component.get("c.hasContentRecords");
        action.setParams({ caseId: recordId, documentType: "Temporary Credit Declaration" });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let hasRecords = response.getReturnValue();
                if (!hasRecords) {
                    this.showToast("Error", "No 'Temporary Credit Declaration' records found in related Content records.", "error");
                    return; // Exit if validation fails
                }
                this.saveDocumentType(component); // Save if validation passes
            } else {
                this.showToast("Error", "Error validating Content records.", "error");
            }
        });
        $A.enqueueAction(action);
    }
});
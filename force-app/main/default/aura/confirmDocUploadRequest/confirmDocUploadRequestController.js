({
    doInit: function(component, event, helper) {
        component.set("v.documentTypeOptions", [
            { label: "Approval Attached", value: "Approval Attached" },
            { label: "Temporary Credit Declaration attached", value: "Temporary Credit Declaration attached" }
        ]);
        helper.loadDocumentType(component);
    },
    
    handleChange: function(component, event, helper) {
        component.set("v.selectedValues", event.getParam("value"));
    },
    
    handleSave: function(component, event, helper) {
        let selectedValues = component.get("v.selectedValues");
        if (!selectedValues || selectedValues.length === 0) {
            // Show error message if no checkbox is selected
            helper.showToast("Error", "Please select at least one document type before saving.", "error");
            return; // Exit the function early
        }
        // Perform additional validations based on selected checkboxes
        helper.validateContentRecords(component, selectedValues);
    }
});
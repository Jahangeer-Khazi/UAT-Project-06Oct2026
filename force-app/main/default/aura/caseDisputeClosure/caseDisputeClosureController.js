({
    init: function (component, event, helper) {
        helper.loadCase(component, component.get('v.recordId'));
    },
    
    onSubmitClick: function (component, event, helper) {
        component.set('v.isLoading', true);
        event.preventDefault();
        var fields = event.getParam('fields');
        fields.Status = 'Closed';
        fields.Sub_Status__c = 'Closed';
        fields.Token_Counter__c = 0;
        //fields.ac_Pending_Date__c = null;
        var closureType = fields.Closure_Type__c || component.get("v.ClosureType");
        var comments = fields.Comments;

        if ($A.util.isEmpty(closureType)) {
            component.find('apexService').showWarningMessage("Closure Type is required");
            component.set('v.isLoading', false);
            return;
        }

        if (closureType === 'Others' && $A.util.isEmpty(comments)) {
            component.find('apexService').showErrorMessage("Internal Comments are required if you select 'Others' as the closure type.");
            component.set('v.isLoading', false);
            return;
        }

        component.find("caseDispute").submit(fields);
    },
    
    handleSuccess: function (component, event, helper) {
        component.set('v.isLoading', false);
        var caseNumber = component.get("v.caseNumber");
        component.find('apexService').showSuccessMessage("Case " + caseNumber + " was saved.");
        $A.get('e.force:refreshView').fire();
    },
    
    handleError: function (component, event, helper) {
        component.set('v.isLoading', false);
        var errorMessage = event.getParam("message");
        component.find('apexService').showErrorMessage("Error occurred while saving the case: " + errorMessage);
    }
})
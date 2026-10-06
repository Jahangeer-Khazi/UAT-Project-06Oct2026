({
    init: function (component, event, helper) {
        helper.loadCase(component, component.get('v.recordId'));
    },

    onSubmitClick: function (component, event, helper) {
        event.preventDefault();
        var closureType = component.get('v.selectedCaseClosure');
        console.log('closureType >> '+ closureType + ' ... ' + component.get('v.isCheckerQueueMember'))
        if ((closureType === 'Approved' || closureType === 'Rejected')
            && !component.get('v.isCheckerQueueMember')) {
            component.find('apexService').showErrorMessage(
                'Access Denied: Only members of the "Checker - Fawri Cancellation Queue" are allowed to select "' + closureType + '" and close this case.'
            );
            return;  
        }

        component.set('v.isLoading', true);
        var fields = event.getParam('fields');
        fields.Closure_Reason__c = closureType;

        if (closureType === 'Approved' || closureType === 'Rejected' || closureType === 'Failed') {
            fields.Status = 'Closed';
            fields.Sub_Status__c = 'Closed';
        }

        console.log('case fields ', JSON.stringify(fields));
        component.find("caseFawri").submit(fields);
    },

    handleSuccess: function (component, event, helper) {
        component.set('v.isLoading', false);


        var closureType = component.get('v.selectedCaseClosure');
        if (closureType === 'Approved') {
            var action = component.get("c.sendFawriCancellationEmail");
            action.setParams({ recordId: component.get('v.recordId') });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("Email sent successfully");
                    component.find('apexService').showSuccessMessage("Fawri Cancellation email was sent successfully.");
                } else {
                    console.error("Failed to send email");
                    component.find('apexService').showErrorMessage("Failed to send Fawri Cancellation email.");
                }
            });
            $A.enqueueAction(action);
        }

        component.find('apexService').showSuccessMessage("Case record was saved.");
        $A.get('e.force:refreshView').fire();
    },

    handleError: function (component, event, helper) {
        component.set('v.isLoading', false);
        var errorMessage = event.getParam("message");
        console.log("errorMessage ", errorMessage);
        console.log("errorMessage event ", event);
        component.find('apexService').showErrorMessage("Error occurred while saving the case: " + errorMessage);
    }
})
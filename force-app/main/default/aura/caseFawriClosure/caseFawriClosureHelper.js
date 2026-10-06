({
    checkCheckerQueue: function (component) {
        console.log('innnn');
        var action = component.get('c.isUserInCheckerQueue');
        console.log('resp1 >> ', action);
        action.setCallback(this, function (response) {
            console.log('resp >> ', response.getState());
            if (response.getState() === 'SUCCESS') {
                component.set('v.isCheckerQueueMember', response.getReturnValue());
            } else {

                component.set('v.isCheckerQueueMember', false);
            }
        });
        $A.enqueueAction(action);
    },

    loadCase: function (component, recId) {
        component.set('v.isLoading', true);
        var action = component.get("c.getCaseDetails");
        action.setParams({ recordId: recId });
        console.log("caseRecord recId ", recId);
        action.setCallback(this, function (response) {
            component.set('v.isLoading', false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var caseRecord = response.getReturnValue();
                console.log("caseRecord caseRecord ", caseRecord);
                component.set("v.recordTypeId", caseRecord.RecordTypeId);
                component.set("v.selectedCaseClosure", caseRecord.Closure_Reason__c == undefined ? "" : caseRecord.Closure_Reason__c);

                if (caseRecord.Type == "Funds Transfer" && caseRecord.Sub_Type__c == "EFTS"
                    && caseRecord.cc_Request_Type__c == "Cancellation Request") {
                    component.set("v.isFawriCase", true);
                }

                this.checkCheckerQueue(component);

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    console.error("Error: " + errors[0].message);
                }
            }
        });

        $A.enqueueAction(action);
    }
})
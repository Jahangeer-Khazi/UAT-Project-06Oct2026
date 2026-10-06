({
    loadCase: function (component, recId) {
        var action = component.get("c.getCaseDetails");
        action.setParams({ recordId: recId });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var caseRecord = response.getReturnValue();
                component.set("v.recordTypeId", caseRecord.RecordTypeId);
                component.set("v.caseNumber", caseRecord.CaseNumber);
                component.set("v.ClosureType", caseRecord.Closure_Type__c);
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
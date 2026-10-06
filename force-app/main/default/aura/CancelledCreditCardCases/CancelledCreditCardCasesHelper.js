({
	fetchCases : function(component) {
        const action = component.get("c.getCreditCardCancelledCases");
        action.setParams({ caseId: component.get("v.recordId") });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const cases = response.getReturnValue();
                cases.forEach(function(caseRecord) {
                    caseRecord.caseLink = '/lightning/r/Case/' + caseRecord.Id + '/view';
                });
                component.set("v.caseData", cases.slice(0, 5)); 
                component.set("v.recordCount",cases.length);
                component.set("v.allCases", cases);
            } else {
                console.error('Error fetching cases: ' + response.getError());
            }
        });

        $A.enqueueAction(action);
    }
})
({
    configureSection: function(component) {
        const recordTypeDeveloperName = component.get("v.recordTypeDeveloperName");
        const caseStatut = this.normalizeFilter(component.get("v.caseStatut"));
        const caseSubStatus = this.normalizeFilter(component.get("v.caseSubStatus"));
		
        const currentCase = component.get("v.currentCase") || {};
		const currentCaseSubType = currentCase.Sub_Type__c;
		let caseTypeLabel;
		if (recordTypeDeveloperName === "LoanFinanceServiceRequest") {
			caseTypeLabel = currentCaseSubType || "Loan Finance Service Request";
		} else if (recordTypeDeveloperName === "Loan_Application") {
			caseTypeLabel = "Loan Application";
		} else {
			caseTypeLabel = "Case";
		}

        const iconBySubStatus = {
            Declined: "action:close",
            Cancelled: "action:delete",
            Approved: "action:approval",
            Processed: "action:approval"
        };

        let title = "Previous ";

        if (caseSubStatus) {
            title += caseSubStatus + " " + caseTypeLabel + " Cases";
        }

        component.set("v.sectionTitle", title);
        component.set(
            "v.sectionIconName",
            //iconBySubStatus[caseSubStatus] || (caseStatut === "Closed" ? "utility:lock" : "standard:case")
			iconBySubStatus[caseSubStatus]
        );
    },

    fetchCases: function(component) {
        const action = component.get("c.getRelatedCases");
		const caseSubTypeValue = component.get("v.caseSubType");

        action.setParams({
            caseId: component.get("v.recordId"),
            recordTypeDeveloperName: component.get("v.recordTypeDeveloperName"),
            caseStatut: this.normalizeFilter(component.get("v.caseStatut")),
            caseSubStatus: this.normalizeFilter(component.get("v.caseSubStatus")),
			caseSubType: $A.util.isEmpty(caseSubTypeValue)? null : caseSubTypeValue
        });

        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);

            if (response.getState() === "SUCCESS") {
                const cases = response.getReturnValue() || [];

                cases.forEach(function(caseRecord) {
                    caseRecord.caseLink = "/lightning/r/Case/" + caseRecord.Id + "/view";
                });

                component.set("v.caseData", cases);
                component.set("v.recordCount", cases.length);
                this.updateDisplayedCases(component);
                return;
            }

            const errors = response.getError();
            const message = errors && errors[0] && errors[0].message
                ? errors[0].message
                : "An unexpected error occurred while loading cases.";

            component.set("v.errorMessage", message);
            component.set("v.caseData", []);
            component.set("v.displayedCases", []);
            component.set("v.recordCount", 0);
        }.bind(this));

        $A.enqueueAction(action);
    },

    updateDisplayedCases: function(component) {
        const cases = component.get("v.caseData") || [];
        component.set("v.displayedCases", cases.slice(0, 5));
    },

    normalizeFilter: function(value) {
        return !value || value === "None" ? null : value;
    }
});
({
    fetchCases: function(component) {
        var action = component.get("c.getRelatedCases");

        action.setParams({
            caseId: component.get("v.recordId"),
            recordTypeDeveloperName: component.get("v.recordTypeDeveloperName"),
            caseStatut: this.normalizeFilter(component.get("v.caseStatut")),
            caseSubStatus: this.normalizeFilter(component.get("v.caseSubStatus")),
            caseSubType: $A.util.isEmpty(component.get("v.caseSubType"))
                ? null
                : component.get("v.caseSubType")
        });

        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);

            if (response.getState() === "SUCCESS") {
                var cases = response.getReturnValue() || [];

                cases.forEach(function(item, index) {
                    item.serialNumber = index + 1;
                    item.caseLink = "/lightning/r/Case/" + item.Id + "/view";
                    item.CaseNumberInt = parseInt(item.CaseNumber.replace(/^0+/, ""), 10);
                    item.OwnerName = item.Owner ? item.Owner.Name : "";
                });

                component.set("v.allCases", cases);
                component.set("v.recordCount", cases.length);
                return;
            }

            var errors = response.getError();
            var message = errors && errors[0] && errors[0].message
                ? errors[0].message
                : "An unexpected error occurred while loading cases.";

            component.set("v.errorMessage", message);
            component.set("v.allCases", []);
            component.set("v.recordCount", 0);
        });

        $A.enqueueAction(action);
    },

    setTabProperties: function(component) {
        var workspaceAPI = component.find("workspace");
        if (!workspaceAPI) {
            return;
        }

        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            workspaceAPI.setTabLabel({
                tabId: tabId,
                label: component.get("v.sectionTitle") || "Related Cases"
            });
            workspaceAPI.setTabIcon({
                tabId: tabId,
                icon: "utility:list",
                iconAlt: "Related Cases"
            });
        }).catch(function(error) {
            console.log("Error setting tab properties:", error);
        });
    },

    sortData: function(component, fieldName, sortDirection) {
        var data = component.get("v.allCases") || [];
        var reverse = sortDirection !== "asc";
        var actualField = fieldName === "caseLink" ? "CaseNumberInt" : fieldName;

        data.sort(this.sortBy(actualField, reverse));
        component.set("v.allCases", data);
    },

    sortBy: function(field, reverse) {
        var key = function(item) {
            return item[field];
        };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse
                ? ((a > b) ? -1 : ((a < b) ? 1 : 0))
                : ((a < b) ? -1 : ((a > b) ? 1 : 0));
        };
    },

    normalizeFilter: function(value) {
        return !value || value === "None" ? null : value;
    }
});
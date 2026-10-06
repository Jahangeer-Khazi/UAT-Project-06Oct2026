({
    doInit: function(component, event, helper) {
        component.set("v.columns", [
            {
                label: "Sno",
                fieldName: "serialNumber",
                type: "number",
                sortable: false,
                initialWidth: 75,
                cellAttributes: { alignment: "center" }
            },
            {
                label: "Case Number",
                fieldName: "caseLink",
                type: "url",
                sortable: true,
                typeAttributes: {
                    label: { fieldName: "CaseNumber" },
                    target: "_blank"
                }
            },
            { label: "Subject", fieldName: "Subject", type: "text", sortable: true },
            { label: "Type", fieldName: "Type", type: "text", sortable: true },
            { label: "Sub Type", fieldName: "Sub_Type__c", type: "text", sortable: true },
            { label: "Status", fieldName: "Status", type: "text", sortable: true },
            { label: "Sub Status", fieldName: "Sub_Status__c", type: "text", sortable: true },
            {
                label: "Date/Time Opened",
                fieldName: "CreatedDate",
                type: "date",
                sortable: true,
                typeAttributes: {
                    year: "numeric",
                    month: "short",
                    day: "2-digit",
                    hour: "2-digit",
                    minute: "2-digit"
                }
            },
            {
                label: "Date/Time Closed",
                fieldName: "ClosedDate",
                type: "date",
                sortable: true,
                typeAttributes: {
                    year: "numeric",
                    month: "short",
                    day: "2-digit",
                    hour: "2-digit",
                    minute: "2-digit"
                }
            },
            { label: "Owner", fieldName: "OwnerName", type: "text", sortable: true }
        ]);

        var pageReference = component.get("v.pageReference");
        if (pageReference && pageReference.state) {
            if (pageReference.state.c__recordId) {
                component.set("v.recordId", pageReference.state.c__recordId);
            }
            if (pageReference.state.c__recordTypeDeveloperName) {
                component.set("v.recordTypeDeveloperName", pageReference.state.c__recordTypeDeveloperName);
            }
            if (pageReference.state.c__caseStatut) {
                component.set("v.caseStatut", pageReference.state.c__caseStatut);
            }
            if (pageReference.state.c__caseSubStatus) {
                component.set("v.caseSubStatus", pageReference.state.c__caseSubStatus);
            }
            if (pageReference.state.c__caseSubType !== undefined) {
                component.set("v.caseSubType", pageReference.state.c__caseSubType);
            }
            if (pageReference.state.c__sectionTitle) {
                component.set("v.sectionTitle", pageReference.state.c__sectionTitle);
            }
        }

        helper.setTabProperties(component);
        helper.fetchCases(component);
    },

    handleSort: function(component, event, helper) {
        var fieldName = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");

        component.set("v.sortedBy", fieldName);
        component.set("v.sortDirection", sortDirection);

        helper.sortData(component, fieldName, sortDirection);
    }
});
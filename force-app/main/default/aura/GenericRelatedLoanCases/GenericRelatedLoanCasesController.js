({
    doInit: function(component, event, helper) {
        component.set("v.columns", [
            {
                label: "Case Number",
                fieldName: "caseLink",
                type: "url",
                typeAttributes: {
                    label: { fieldName: "CaseNumber" },
                    target: "_blank"
                }
            },
            { label: "Status", fieldName: "Status", type: "text" },
            { label: "Sub Status", fieldName: "Sub_Status__c", type: "text" },
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
            }
        ]);

        helper.configureSection(component);
        helper.fetchCases(component);
    },

    handleRecordUpdated: function(component, event, helper) {
        const changeType = event.getParams().changeType;

        if (changeType === "LOADED") {
            helper.configureSection(component);
        }

        if (changeType === "CHANGED") {
            helper.configureSection(component);
            helper.fetchCases(component);
        }

        if (changeType === "ERROR") {
            console.error(
                "Error loading the current Case Sub Type."
            );
        }
    },
    navigateToRelatedList: function(component, event, helper) {
        event.preventDefault();

        var pageReference = {
            type: "standard__component",
            attributes: {
                componentName: "c__GenericViewAllRelatedList"
            },
            state: {
                c__recordId: component.get("v.recordId"),
                c__recordTypeDeveloperName: component.get("v.recordTypeDeveloperName"),
                c__caseStatut: component.get("v.caseStatut"),
                c__caseSubStatus: component.get("v.caseSubStatus"),
                c__caseSubType: component.get("v.caseSubType") || "",
                c__sectionTitle: component.get("v.sectionTitle") || "Related Cases"
            }
        };

        var navService = component.find("navService");
        if (navService) {
            navService.navigate(pageReference);
        } else {
            var navEvt = $A.get("e.force:navigateToComponent");
            navEvt.setParams({
                componentDef: "c:GenericViewAllRelatedList",
                componentAttributes: {
                    recordId: component.get("v.recordId"),
                    recordTypeDeveloperName: component.get("v.recordTypeDeveloperName"),
                    caseStatut: component.get("v.caseStatut"),
                    caseSubStatus: component.get("v.caseSubStatus"),
                    caseSubType: component.get("v.caseSubType") || "",
                    sectionTitle: component.get("v.sectionTitle") || "Related Cases"
                }
            });
            navEvt.fire();
        }
    }
});
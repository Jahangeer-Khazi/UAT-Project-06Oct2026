/**
 *  #CH02 : Added by AITOGRAM Omar : 20/04/2026 added new logic for dormancy status jordan recordType (NBA-11715)
 */
({
    doInit: function (component, event, helper) {
        // helper.doInit(component, event, helper); #CHO2 logic moved to handleLoad to wait for Region_Flag__pc
    },
    handleOnload: function (component, event, helper) {
        console.log("on load form !");
        // CH02 - Start
        let regionFlag = component.get("v.regionFlag");
        let recordTypeNameField = component.find("CaseRecordTypeName");
        let subStatus = component.find("subStatus");
        if (recordTypeNameField) {
            if (regionFlag == 'Jordan') {
                recordTypeNameField.set("v.value", "Dormancy Status Jordan");
                subStatus.set("v.value", "In-Progress");
            } else {
                recordTypeNameField.set("v.value", "Dormancy Status");
            }
        }
        // CH02 - End
    },
    handleOnSubmit: function (component, event, helper) {
        console.log('handleOnSubmit');
        event.preventDefault();
        console.error(component.get('v.recordTypeId'));
        component.find('form').submit();
        helper.showSpinner(component);
    },
    handleOnSuccess: function (component, event, helper) {
        helper.hideSpinner(component);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Success!",
            "message": "Case has been created successfully."
        });
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.getParam("response").id,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    handleOnError: function (component, event, helper) {
        helper.hideSpinner(component);
    },
    onCancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleLoad: function (component, event, helper) {//CH01
        console.log('handleLoad  cmp---');
        let subscriptionModel = component.find("Subscription_Model").get("v.value");
        if (subscriptionModel != null && subscriptionModel == 'alburaq') {
            component.set('v.caseModel', subscriptionModel);
        } else {
            component.set('v.caseModel', 'ila');
        }

        // CH02 - Start
        let regionFlag = component.find("Region_Flag").get("v.value");
        component.set("v.regionFlag", regionFlag);

        helper.doInit(component, event, helper, regionFlag);
        // CH02 - End
    },
})
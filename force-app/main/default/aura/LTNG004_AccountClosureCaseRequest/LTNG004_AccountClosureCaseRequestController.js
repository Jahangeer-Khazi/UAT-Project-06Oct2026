/**
 * Change History :
 * 		#CH01 - Maksud Ali, 3 May 2026, Popuplated product name and product type value to case fields
 */ 
({
    doInit: function (component, event, helper) {
        helper.doInit(component, event, helper);
    },
    handleOnload: function (component, event, helper) {
        console.log("on load form !");
    },
    handleOnSubmit: function (component, event, helper) {
        console.log('handleOnSubmit');
        event.preventDefault();
        console.error(component.get('v.recordTypeId'));
        
        //CH01 - START
        const currentAcc = component.get('v.currentAcc');
        console.log('currentAcc selected ',currentAcc);
        debugger;
        let fields = event.getParam("fields");
        if(currentAcc && currentAcc.productName && currentAcc.productType && currentAcc.productType == 'HYSA'){
        	fields.Other_Downgrade_Reason__c = currentAcc.productName;     
        }
        
        
        component.find('form').submit(fields);
        //CH01 - END
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
        console.log('handleLoad  cmp---'+component.find("Subscription_Model").get("v.value"));
        let subscriptionModel = component.find("Subscription_Model").get("v.value");
        if( subscriptionModel != null && subscriptionModel == 'alburaq' ){
            component.set('v.caseModel',subscriptionModel);
        }else{
            component.set('v.caseModel','ila');
        }
    },
})
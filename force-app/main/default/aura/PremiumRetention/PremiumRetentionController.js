//#CH01# - Fixed the bug. updateDiscountRequestAPi call will be directly only if the requestby id Bank/CBB
({
    doInit: function (component, event, helper) {
        helper.showSpinner(component);
        helper.doInit(component, event, helper);
    },
    handleOnload: function (component, event, helper) {
        helper.showSpinner(component);
        var accId=component.get('v.recordId');
        helper.handlecustomerName(component, event, helper, accId);
        helper.hideSpinner(component);
    },
    handleOnSuccess: function (component, event, helper) {
        console.error('handleOnSuccess**********');
        helper.hideSpinner(component);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Success!",
            "message": "Case has been created successfully."
        });
        toastEvent.fire();
        
        //#CH01 -Start 29/07/2022
        var RequestedBy = component.get('v.RequestedBy');
        if(RequestedBy=='Bank / CBB'){
            helper.callUpdateDiscountRequestApi(component, event, helper,event.getParam("response").id);
        }
        //#CH01 -End
        
        $A.get("e.force:closeQuickAction").fire();
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.getParam("response").id,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    handleOnSubmit: function (component, event, helper) {
        console.log('handleOnSubmit');
        event.preventDefault();
        console.error(component.get('v.recordTypeId'));
        component.find('form').submit();
        helper.showSpinner(component);
    },
    handleOnError: function (component, event, helper) {
        helper.hideSpinner(component);
    },
    onCancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    caseModelIsChanged : function(component, event, helper) {
        console.error('is changed caseModelIsChanged');
        //#CH01
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
/**
Change History :
*         #CH01 : #D&A Team #24-06-2022# Added Case model parameter to add alburaq logic.
*/
({
    doInit: function (component, event, helper) {
       
        helper.showSpinner(component);
        helper.doInit(component, event, helper);
        //helper.hideSpinner(component);
    },
    handleOnload: function (component, event, helper) {
        helper.showSpinner(component);
        var accId=component.get('v.recordId');
        helper.handlecustomerName(component, event, helper, accId);
        console.log("on load form !");
        helper.hideSpinner(component);
    },
    handleOnSubmit: function (component, event, helper) {
        console.log('handleOnSubmit');
        event.preventDefault();
        console.error(component.get('v.recordTypeId'));
        var fields = event.getParam('fields');
        fields["BUA_Reason__c"] = "Pending on customer response";
        fields["Awaiting_Customer_Feedback__c"]=true;

        if (component.get('v.RequestedBy') === 'Bank / CBB') {
            var discountPercentage = component.find("discountPercentage");
            var premiumSubscriptionDurationYears = component.find("premiumSubscriptionDurationYears");
            if (!discountPercentage.get("v.value") || !premiumSubscriptionDurationYears.get("v.value")) {
                var errorToast = $A.get("e.force:showToast");
                errorToast.setParams({
                    "type": "error",
                    "title": "Error",
                    "message": "Please fill in Discount Percentage and Premium Subscription Duration."
                });
                errorToast.fire();
                return;
            }
        }

        component.find('form').submit(fields);
        helper.showSpinner(component);
    },
    handleOnSuccess: function (component, event, helper) {
        var caseId = event.getParam("response").id;

        if (component.get('v.RequestedBy') === 'Bank / CBB') {
            component.set('v.createdCaseId', caseId);
            var fields = {
                Case__c: caseId,
                Discount_Percentage__c: component.find("discountPercentage").get("v.value"),
                Premium_Subscription_Duration_Years__c: component.find("premiumSubscriptionDurationYears").get("v.value")
            };
            component.find('caseAnnexForm').submit(fields);
            return;
        }

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
            "recordId": caseId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    handleOnSuccessAnnex: function (component, event, helper) {
        helper.hideSpinner(component);
        var resp = event.getParam("response");
        var caseId = component.get('v.createdCaseId')
            || (resp && resp.fields && resp.fields.Case__c ? resp.fields.Case__c.value : null);

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
            "recordId": caseId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    handleOnErrorAnnex: function (component, event, helper) {
        helper.hideSpinner(component);
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
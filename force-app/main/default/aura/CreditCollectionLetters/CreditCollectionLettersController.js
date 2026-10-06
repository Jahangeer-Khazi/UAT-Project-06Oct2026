/**
Change History :
*         #CH01 : #D&A Team #24-06-2022# Added Case model parameter to add alburaq logic.
*		  #CH02 : Maksud Ali 10/09/2025 CRM Enhancements - Validating Generate case request, for outstanding, cancelling and no due
*/
({
    doInit: function (component, event, helper) {
        //debugger;
        helper.showSpinner(component);
        helper.doInit(component, event, helper);
        helper.getQueueId(component,event,helper);
        //helper.hideSpinner(component);
    },
    handleOnload: function (component, event, helper) {
        helper.showSpinner(component);
        var accId=component.get('v.recordId');
        console.log("on load form !");
        helper.hideSpinner(component);
    },
    handleOnSubmit: function (component, event, helper) {
        console.log('handleOnSubmit');
        event.preventDefault();
        let defaultAccId = component.get("v.defaultAccId");
        if (defaultAccId == '' || defaultAccId == null ) {
            helper.handleErrors("please fill the Customer Iban",'');
        }
        else{
            //CH02 - Start
            //component.find('form').submit();
            //helper.showSpinner(component);
            helper.fetchAndValidateCreditCard(component, event, helper);
            //CH02 - End
        }
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
    caseModelIsChanged : function(component, event, helper) {
        console.error('is changed caseModelIsChanged');
        helper.getDefaultAccountIdViaApi(component, event, helper);
    },
    handleLoad: function (component, event, helper) {//CH01
		console.log('handleLoad  cmp---');
        let subscriptionModel = component.find("Subscription_Model").get("v.value");
        let regionFlag = component.find("Region_Flag").get("v.value");
        component.set('v.regionFlag',regionFlag);
        if( subscriptionModel != null && subscriptionModel == 'alburaq' ){
            component.set('v.caseModel',subscriptionModel);
        }else{
            component.set('v.caseModel','ila');
        }
        helper.getDefaultAccountIdViaApi(component, event, helper);
	},
	subTypeChange : function (component, event, helper) {//#CH02
        //console.error('subTypeChange =================>>>>');
		var sub_type = component.get('v.sub_type');
        console.log("subtype ",sub_type);
        if(sub_type.toLowerCase() == 'outstanding balance letter'){
            component.set('v.caseNature','Credit Card');
        }else{
            component.set('v.caseNature','FCR');
        }
	}
})
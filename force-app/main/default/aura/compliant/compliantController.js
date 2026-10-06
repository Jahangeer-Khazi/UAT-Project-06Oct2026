({
	doInit: function (component, event, helper) {
        helper.doInit(component, event, helper);
           // Get the pageReference object provided by the interface
        var pageRef = component.get("v.pageReference");
        var customerCIF;
        var interactionId;
        if (pageRef && pageRef.state) {
            // Read the parameter (Salesforce prefixes parameters with c__)
            customerCIF = pageRef.state.c__cif; 
            interactionId =pageRef.state.c__interactionId; 
            // Set the value to your local Aura attribute
           // alert('interactionId'+interactionId);
            component.set("v.interactionId",interactionId);
            component.set("v.cif", customerCIF);
            helper.getCustomerCIF(component, event, helper,customerCIF);
        }    
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
       handleOnSubmit: function (component, event, helper) {
        console.log('handleOnSubmit');
         //  alert('AccountId'+component.get("v.recordId"));
        try{
            event.preventDefault();
             var fields = event.getParam("fields");
            fields["AccountId"] = component.get("v.recordId"); 
           console.error(component.get('v.recordTypeId'));
            component.find('form').submit(fields);
        } catch (error) {
            console.log('Error '+error);            
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
})
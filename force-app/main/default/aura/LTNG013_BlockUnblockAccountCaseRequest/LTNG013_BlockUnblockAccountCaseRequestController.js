({
	doInit: function (component, event, helper) {
        helper.doInit(component, event, helper);
        
        // Call to check if user is in Fraud Team
        var action = component.get("c.isFraudTeamUser");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.isFraudTeamUser", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    handleOnload: function (component, event, helper) {
        console.log("on load form !");
    },
    
    handleOnSubmit: function (component, event, helper) {
        console.log('handleOnSubmit');
        event.preventDefault();
       // component.find('form').submit();
        helper.showSpinner(component);
        var fields = event.getParam('fields');
        var subtype= component.find('subType').get('v.value');
        //fields["BUA_Reason__c"] = component.get('v.selectedCaseReason');
        fields["Reason"] = component.get('v.selectedCaseReason');
        if(subtype.includes('Unblock')){
         helper.updateUnblocKProfile(component, event, helper,fields); 
        }else{
            console.log('--->',JSON.stringify(fields));
            component.find('form').submit(fields);
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
    
    handleLoad: function (component, event, helper) {//CH01
		console.log('handleLoad  cmp---');
        let subscriptionModel = component.find("Subscription_Model").get("v.value");
        console.log('subscriptionModel##'+subscriptionModel);
        if( subscriptionModel != null && subscriptionModel == 'alburaq' ){
            component.set('v.caseModel',subscriptionModel);
        }else{
            component.set('v.caseModel','ila');
        }
	},
    
    handleCaseReasonChange: function(component, event, helper) {
        let selected = event.getSource().get("v.value");
        component.set("v.selectedCaseReason", selected);
        console.log('isFraudTeamUser:', component.get("v.isFraudTeamUser"));
        console.log('selectedCaseReason:', component.get("v.selectedCaseReason"));
        console.log('Condition should be:', 
                    component.get("v.isFraudTeamUser") && 
                    component.get("v.selectedCaseReason") === 'Fraud Recommendation');
    },
    
    handleReasonChange: function(component, event, helper) {
        let selected = event.getSource().get("v.value");
        component.set("v.selectedReason", selected);
    }
})
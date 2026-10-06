({
	fetchMembershipId: function (component, event, helper) {
        helper.showSpinner(component);
        var caseId = component.get("v.recordId");
        console.log('Case Id:',caseId);
        var accId = component.get("v.caseRecord.AccountId");
        console.log('Account Id:',accId);
        //var memberId = component.get("v.caseRecord.cc_Embossing_Line_4__c");
        var memberId = component.get("v.embossingLine4");
        //var memberId = membershipId;
        console.log('Membership Id in fetch:',memberId);
        if(memberId != null && memberId != ''){
            var action = component.get("c.fetchGulfAirId");
            action.setParams({
                customerId: accId,
                membershipId: memberId
            });
            action.setCallback(this, function (response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    console.log('Getting response Map:',response.getReturnValue());
                    var response = response.getReturnValue();
                    console.log('Code:',response.meta.code);
                    if(response.meta.code === 'GULF-1000'){
                        var fields = event.getParam("fields");
                        fields["cc_Embossing_Line_4__c"] = component.get("v.embossingLine4");
                        fields["cc_Approved_Embossing_line_4__c"] = component.get("v.embossingLine4");
                        helper.handleSuccess("Gulf air Membership Id have been found successfully.");
                        component.set('v.enableButton',false);
                        component.set('v.showEditForm',false);
                        component.find("form").submit(fields);
                        helper.hideSpinner(component);
                    }
                    else if(response.meta.code != 'GULF-1000'){
                        helper.handleErrors("Please Enter a valid Membership Id of a customer");
                        helper.hideSpinner(component);
                        
                    }
                    
                }else if(state === "ERROR") {
                    helper.handleErrors(response.getError());
                    helper.hideSpinner(component);
                }
            });
            	$A.enqueueAction(action);
        }
        else if(memberId == null || memberId == ''){
            console.log('Membership Id is Blank');
            helper.handleErrors("Please Enter a valid Membership Id of a customer and it cannot be empty/blank");
        	helper.hideSpinner(component);
        }
        
    },
    
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    handleSuccess : function(msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
             mode: "sticky",
            "type":"success",
            "title": "Success!",
            "message": msg
        });
        toastEvent.fire();
    },
    handleErrors: function (errors) {
        let toastParams = {
			mode: "sticky",
			title: "Error",
			message: errors, // Default error message
			type: "error"
		};
		if(errors && Array.isArray(errors) && errors.length > 0) {
			toastParams.message = errors[0].message;
		}
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams(toastParams);
		toastEvent.fire();
	},
})
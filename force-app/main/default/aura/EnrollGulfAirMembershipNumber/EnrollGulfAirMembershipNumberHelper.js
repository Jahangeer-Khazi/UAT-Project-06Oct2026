({
	enrollMembership : function(component,event,helper) {
		helper.showSpinner(component);
        var caseId = component.get("v.recordId");
        console.log('Case Id:',caseId);
        var accId = component.get("v.caseRecord.AccountId");
        console.log('Account Id:',accId);
        
        var action = component.get("c.enrollGulfAirMembershipId");
            action.setParams({
                customerId: accId
            });
            action.setCallback(this, function (response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    console.log('Getting response Map:',response.getReturnValue());
                    var response = response.getReturnValue();
                    console.log('Code:',response.meta.code);
                    if(response.meta.code === 'GULF-3000'){
                        var membershipId = response.data.membershipNumber;
                        if(membershipId != ''){
                            console.log('Created Membership Id:',membershipId);
                            // Update the field value using force:recordData
                    		let recordLoader = component.find("recordLoader");
                    		let recordFields = component.get("v.caseRecord");
                    		
                            recordFields["cc_Embossing_Line_4__c"] = membershipId;
                            recordFields["cc_Approved_Embossing_line_4__c"] = membershipId;
                            recordFields["Relationship_Termination_Button_Checks__c"] = true;
                            
                            recordLoader.saveRecord($A.getCallback(function (saveResult) {
                        	if(saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                            	console.log("Membership created and fields updated successfully!");
                        	}else if (saveResult.state === "ERROR") {
                            	console.error("Save error: ", JSON.stringify(saveResult.error));
                            }else {
                            	console.error("Unknown problem, state: " + saveResult.state);
                        	}
                    		}));
                            
                            helper.handleSuccess("Gulf air Membership created successfully.");
                        	//component.set('v.enableButton',false);
                        	helper.hideSpinner(component);
                        }
                        else{
                            console.log('Membership Id is Empty');
                        }
                    }
                    else if(response.meta.code != 'GULF-3000'){
                        helper.handleErrors(response.meta.message);
                        helper.hideSpinner(component);
                    }
                    
                }else if(state === "ERROR") {
                    helper.handleErrors(response.getError());
                    helper.hideSpinner(component);
                }
            });
            $A.enqueueAction(action);
    },
    manageMembership : function(component,event,helper) {
		helper.showSpinner(component);
        var caseId = component.get("v.recordId");
        console.log('Case Id:',caseId);
        var accId = component.get("v.caseRecord.AccountId");
        console.log('Account Id:',accId);
        var membershipId = component.get("v.caseRecord.cc_Approved_Embossing_line_4__c");
        console.log('Membership Id:',membershipId);
        var action = component.get("c.manageGulfAirMembershipId");
            action.setParams({
                customerId: accId,
                membershipId:membershipId
            });
            action.setCallback(this, function (response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    console.log('Getting response Map:',response.getReturnValue());
                    var response = response.getReturnValue();
                    console.log('Code:',response.meta.code);
                    if(response.meta.code === 'GULF-2000'){
                        
                        // Update the field value using force:recordData
                        let recordLoader = component.find("recordLoader");
                        let recordFields = component.get("v.caseRecord");
                        
                        recordFields["Relationship_Termination_Button_Checks__c"] = true;
                        recordLoader.saveRecord($A.getCallback(function (saveResult){
                            
                            if(saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                                console.log("Membership updated successfully!");
                            }else if (saveResult.state === "ERROR") {
                                console.error("Save error: ", JSON.stringify(saveResult.error));
                            }else {
                                console.error("Unknown problem, state: " + saveResult.state);
                            }
                        }));
                        
                        helper.handleSuccess("Gulf air Membership updated successfully.");
                        helper.hideSpinner(component);
                    }
                    else if(response.meta.code != 'GULF-2000'){
                        helper.handleErrors(response.meta.message);
                        helper.hideSpinner(component);
                    }
                    
                }else if(state === "ERROR") {
                    helper.handleErrors(response.getError());
                    helper.hideSpinner(component);
                }
            });
            $A.enqueueAction(action);
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
    updateButtonState: function (component,event,helper) {
        var helper = this;
        const recordFields = component.get("v.caseRecord");
        console.log("Relationship Termination Button Checks:", recordFields.Relationship_Termination_Button_Checks__c);

        if(recordFields.Relationship_Termination_Button_Checks__c) {
            component.set("v.enableButton", false); // Hide the button
        }else{
            component.set("v.enableButton", true); // Show the button
        }
        
    },
    
   
    
})
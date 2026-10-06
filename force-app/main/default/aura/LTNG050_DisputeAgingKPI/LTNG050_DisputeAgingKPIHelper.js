({
    doInit : function(component,event,helper) {

        var subtypeOptions = [
            { label: 'Local Dispute - Benefit', value: 'Customer Transaction & Payment Disputes- Benfit' },
            { label: ' International Dispute - Mastercard', value: 'Customer Transaction & Payment Disputes- Mastercard' }
        ];       
        component.set("v.subtypeOptions",subtypeOptions);
		const action = component.get("c.getRecordDetails");
        action.setParams({ recordId: component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                const result = response.getReturnValue();
                
                if (result.RecordType_DeveloperName__c === 'Case_Disputes_and_Frauds') {
                    const subtype = result.Type === 'MasterCard'
                    ? 'Customer Transaction & Payment Disputes- Mastercard'
                    : result.Type === 'Benefit'
                    ? 'Customer Transaction & Payment Disputes- Benefit'
                    : null;
                    
                    if (subtype) {
                        component.set("v.SubTypeSelected", subtype);
                    }
                }
                
                console.log('result -->', JSON.stringify(result));
            }
        });
        
        $A.enqueueAction(action);
    },
    
    saveRecord : function(component,event,helper) {
        console.log("**********start save recorddd**************");
        helper.showSpinner(component,event.helper);
        var subTypeValue=component.get("v.SubTypeSelected");
        var commentValue=component.get("v.commentValue");
        console.log("subTypeValue==> "+subTypeValue+" commentValue==>  "+commentValue);
        
        if(!commentValue || commentValue.trim() === "") {
            helper.hideSpinner(component,event.helper);
            component.find("comment").setCustomValidity("Comment cannot be empty.");
            component.find("comment").reportValidity();
        } else {
            var action = component.get('c.updateSubTypeAndComment');
            action.setParams({
                'recordId':component.get("v.recordId"),
                'subTypeValue':subTypeValue,
                'commentValue':commentValue, 
            });
            action.setCallback(this, function (actionResult) {
                var statut = actionResult.getState();
                if (statut === "SUCCESS") {
                    //  alert("sucesssss");
                    helper.showToast(component,event,helper,"The case has been updated successfully!","case updated!","success");
                    helper.hideSpinner(component,event.helper);
                    
                } else if (statut === "ERROR") {
                    // Process error returned by server
                    handleErrors(actionResult.getError(), '');
                    helper.hideSpinner(component,event.helper);
                }
                    else {
                        console.error("AUTRE ERROR");
                        // Handle other reponse states
                        helper.hideSpinner(component,event.helper);
                        
                    }
            });
            $A.enqueueAction(action);
        }
    },
    
    showSpinner: function (component, event, helper) {
        component.set("v.showSpinner",true);
    },
    hideSpinner: function (component, event, helper) {
        component.set("v.showSpinner",false);
    },
    handleErrors: function (errors, addError) {
        // Configure error toast
        let toastParams = {
            mode: "sticky",
            title: "Erreur",
            message: errors, // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = addError + '' + errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },
    showToast : function(component, event, helper,message,title,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type":type
        });
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();

    }
})
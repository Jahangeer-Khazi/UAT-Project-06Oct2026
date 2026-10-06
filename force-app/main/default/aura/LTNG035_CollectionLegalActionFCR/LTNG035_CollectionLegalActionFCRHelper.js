({
    doInit : function (component, event, helper, accId) {
        var action = component.get('c.getCollectionLegalCaseRecordType');
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if (data) {
                    component.set("v.recordTypeId", data);
                }
            } else if (statut === "ERROR") {
                // Process error returned by server
                helper.handleErrors(actionResult.getError(), '');
            }
            else {
                console.error("AUTRE ERROR");
                // Handle other reponse states
            }
        });
        $A.enqueueAction(action);
    },

    UpdateCheckboxes:function(component, event, helper,isCollectionChecked,isLegalChecked, isLoanCollectionChecked, isLoanLegalChecked){
        console.log('**************** start UpdateCheckboxes***************');
        helper.showSpinner(component);
            var result;
            var action = component.get("c.updateCheckboxCustomer");
            action.setParams({
                isCollectionChecked: isCollectionChecked,
                isLegalChecked:isLegalChecked,
                isLoanCollectionChecked: isLoanCollectionChecked,
                isLoanLegalChecked:isLoanLegalChecked,
                accountId: component.get('v.recordId')      
            });
            action.setCallback(this, function(response) {
                result = response.getReturnValue();
                console.log('result1==>'+result);
                if(result==false){
                    console.log('testtt1==> ');
                    helper.handleErrors('Flag already updated', 'Flag already updated');
                      
                }else{
                    console.log('testtt2==> ');
                    component.find('form').submit();
                }
                helper.hideSpinner(component);      

              });
              $A.enqueueAction(action);
            

         
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
            title: "Error While creating the case",
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
})
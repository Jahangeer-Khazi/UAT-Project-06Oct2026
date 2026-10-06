({
	doInit : function (component, event, helper, accId) {
        //var acctId = component.get('v.recordId');
      //  console.log('Acc Id:',acctId);
        var action = component.get('c.getAccRequestCaseRecordType');// CH02
        //var action = component.get('c.getRecordTypeIdByregionName');
        /*action.setParams(
           {
               recordId: component.get('v.recordId')
            }); */ 
              action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if (data) {
                    console.log('Record Type Id:',data);
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
    updateUnblocKProfile : function (component, event, helper,fields) {
        var action = component.get('c.UpdateApproverProfile');// CH02
        var recordId=component.get('v.recordId');
        var caseModel=component.get('v.caseModel');
        console.log('caseModel###'+caseModel);
        var unblockAccount = component.get('v.accDetails');
        action.setParams(
            {
                accountId: recordId,
                caseModel: caseModel,
                UnblockAccount:unblockAccount
            });      
             action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                var data = actionResult.getReturnValue();
                if (data) {
                    console.log('blockerProfile##3'+data);
                    fields['cbb_BlockStatusB__c']=data;
                     component.find('form').submit(fields);
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
    }
})
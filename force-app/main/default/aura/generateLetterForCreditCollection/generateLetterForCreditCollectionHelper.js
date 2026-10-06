({
	handleSendEmail : function (component, event, helper, caseId) {
        debugger;
        var action = component.get('c.sendEmailWithPdf');
        action.setParams({
            'caseId':caseId

        });
        action.setCallback(this, function (actionResult) {
            var status = actionResult.getState();
            if (status === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                helper.handleSuccess("Email has been sent successfully.");
                component.set("v.isEmailSubmited",false);
                helper.hideSpinner(component, event, helper);
                let data = actionResult.getReturnValue();
                if (data) {
                    //component.set("v.queueId", data);
                }
            } else if (status === "ERROR") {
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
    handleDownloadPDF: function (component, event, helper, caseId) {
        var action = component.get('c.downloadcasePdf');
        action.setParams({
            'caseId':caseId

        });
        action.setCallback(this, function (actionResult) {
            var status = actionResult.getState();
             var blob = actionResult.getReturnValue();
            if (status === "SUCCESS") {
        		let downloadLink = document.createElement("a");
        		downloadLink.setAttribute("type", "hidden");
        		downloadLink.href = "data:text/html;base64,"+actionResult.getReturnValue();
                downloadLink.download = component.get("v.caseRecord.Sub_Type__c")+'.pdf';//'Statement-'+component.get('v.productName')+'-'+pciNumber.substr(-4)+'-'+statementDate.replace(/-/g, "")+'.pdf';//result.responseData.fileName;
        		document.body.appendChild(downloadLink);
        		downloadLink.click();
        		downloadLink.remove();
                $A.get('e.force:refreshView').fire();
                helper.handleSuccess("File has been downloaded successfully.");
                component.set("v.isDownloadSubmited",false);
                helper.hideSpinner(component, event, helper);
            } else if (status === "ERROR") {
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
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
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
    handleSuccess: function (message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Success!",
            "message": message
        });
        toastEvent.fire();
    },
})
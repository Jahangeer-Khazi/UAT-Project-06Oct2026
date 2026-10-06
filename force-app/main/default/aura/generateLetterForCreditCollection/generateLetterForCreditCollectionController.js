({
        handleClick : function(component, event, helper) {
                component.set("v.isDownloadSubmited",true);
                helper.showSpinner(component, event, helper);
                var caseId=component.get("v.recordId");
                helper.handleDownloadPDF(component, event, helper, caseId);
	},
        handleSendEmail: function(component, event, helper) {
                component.set("v.isEmailSubmited",true);
                helper.showSpinner(component, event, helper);
                var caseId=component.get("v.recordId");
                helper.handleSendEmail(component, event, helper, caseId);
	},
})
({
	handleClick : function(component, event, helper) {
        component.set('v.isSubmited',true);
        var caseId=component.get("v.recordId");
        helper.handleDownloadPDF(component, event, helper, caseId);
	},
    handleSendEmail: function(component, event, helper) {
        console.log('send email ')
        component.set('v.isSubmited',true);
        var caseId=component.get("v.recordId");
        helper.handleSendEmail(component, event, helper, caseId);
	},
})
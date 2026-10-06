({
    init : function(component, event, helper) {
        //helper.loadCase(component, component.get('v.recordId'));
        //helper.loadCase(component, component.get('v.caseId'));
	},
    onAppUnlockClick : function(component, event, helper) {
        if (confirm('Proceed with App Unlock')) {
            var customerId = component.get('v.customerId');
            var caseId = component.get('v.caseId');
            var account = component.get('v.account');
            var requests = [];
            var requestBody = {
                "type": "email",
                "email": account.PersonEmail,
                "recovery": true,
                "caseId": caseId
            };
            requests.push(requestBody);

            helper.sendVerificationRequest(component, caseId, customerId, requests);

        }
	},

})
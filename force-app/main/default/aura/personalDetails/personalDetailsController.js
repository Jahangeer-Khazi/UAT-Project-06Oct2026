({
    init : function(component, event, helper) {
        //helper.loadData(component, component.get('v.recordId'));
	},

    onEditClick : function(component, event, helper) {
        component.set('v.mode', 'edit');
	},
    onCancelClick : function(component, event, helper) {
        component.set('v.mode', 'view');
        component.set('v.newEmail', undefined);
        component.set('v.newMobile', undefined);
	},
    onSaveClick : function(component, event, helper) {
        //component.set('v.mode', 'view');
        var customerId = component.get('v.customerId');
        var caseId = component.get('v.caseId');

        var oldEmail = component.get('v.account.PersonEmail');
        var oldMobile = component.get('v.account.PersonMobilePhone');
        var regionName = component.get('v.account.Region_Flag__c');
        var newEmail = component.get('v.newEmail');
        var newMobile = component.get('v.newMobile');

        var requests = [];

        if (!$A.util.isEmpty(newEmail) && newEmail !== oldEmail) {
            var requestBody = {
                "type": "email",
                "email": newEmail
            };
            requests.push(requestBody);
            //helper.sendEmailVerificationRequest(component, caseId, customerId, newEmail);
        }
        if (!$A.util.isEmpty(newMobile) && newMobile !== oldMobile) {
            var requestBody = {
                "type": "sms",
                "phoneNumber": newMobile
            };
            requests.push(requestBody);
            //helper.sendMobileVerificationRequest(component, caseId, customerId, newMobile);
        }
        var noChanges = requests.length < 1;
        if (true === noChanges) {
            component.find('apexService').showWarningMessage($A.get("$Label.c.No_changes_detected_Please_enter_new_email_and_or_mobile"));
            //helper.resetToViewMode(component);
        } else {
            helper.sendVerificationRequest(component, caseId, customerId, requests, regionName);
        }
	}

})
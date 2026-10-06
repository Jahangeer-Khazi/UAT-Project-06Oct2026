({
    /*
	sendEmailVerificationRequest : function(component, caseId, customerId, newEmail) {
	    var helper = this;
        var requestBody = {
            "type": "email",
            "email": newEmail
        };
        helper.sendVerificationRequest(component, caseId, customerId, requestBody);

	},
	sendMobileVerificationRequest : function(component, caseId, customerId, newMobile) {
	    var helper = this;
        var requestBody = {
            "type": "sms",
            "phoneNumber": newMobile
        };
        helper.sendVerificationRequest(component, caseId, customerId, requestBody);

	},
    */
	sendVerificationRequest : function(component, caseId, customerId, requests, regionName) {
        debugger;
        var requestBody = requests.shift();
	    var helper = this;
		component.find('apexService').request(component.get('c.sendVerificationRequest'), {
		    customerId: customerId,
            requestBody: JSON.stringify( requestBody ),
            caseId: caseId,
            systemActionName: 'Procedural',
            regionName: regionName
        },
		function(response) {
		    var result = response.getReturnValue();

            console.log('result=' + result)
            if ($A.util.isEmpty(requests)) {
                helper.resetToViewMode(component);
                component.find('apexService').showSuccessMessage($A.get("$Label.c.Request_Sent_Successfully"));
            } else {
                helper.sendVerificationRequest(component, caseId, customerId, requests);
            }
		});

	},
    resetToViewMode : function(component) {
        component.set('v.mode', 'view');
        component.set('v.newEmail', undefined);
        component.set('v.newMobile', undefined);
	},
})
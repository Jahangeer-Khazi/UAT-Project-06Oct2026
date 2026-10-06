({
	loadCase : function(component, recordId) {
	    var helper = this;
		component.find('apexService').request(component.get('c.loadCase'), {
		    recordId: recordId
        },
		function(response) {
		    var result = response.getReturnValue();

            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                var caseObj = result.responseData;
                var account = {};
                if (caseObj.hasOwnProperty( 'Account') ) {
                    account = caseObj.Account;
                } else {
                    account = caseObj;
                }
            }
            console.log("loaded account: " + JSON.stringify(account));
			debugger;
            component.set('v.account', account);
            component.set('v.customerId', account.CIF__pc);
            //component.set('v.caseType', caseObj.Type);
            //component.set('v.caseRecordTypeId', caseObj.RecordTypeId);
            /*
            if (confirm('Proceed with App Unlock')) {
                console.log("app Unlock confirmed by user");
            }
            */
		});
	},
	sendVerificationRequest : function(component, caseId, customerId, requests) {
        debugger;
        var requestBody = requests.shift();
        var account = component.get('v.account');
	    var helper = this;
		component.find('apexService').request(component.get('c.sendVerificationRequest'), {
		    customerId: customerId,
            requestBody: JSON.stringify( requestBody ),
            caseId: caseId,
            systemActionName: 'Unlock App Access',
            email: account.PersonEmail,
            regionName:account.Region_Flag__c
        },
		function(response) {
		    var result = response.getReturnValue();
            if ($A.util.isEmpty(requests)) {
                component.find('apexService').showSuccessMessage($A.get("$Label.c.Request_Sent_Successfully"));
            } else {
                helper.sendVerificationRequest(component, caseId, customerId, requests);
            }
		});

	},

})
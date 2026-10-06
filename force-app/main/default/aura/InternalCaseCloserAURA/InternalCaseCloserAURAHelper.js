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
            
            component.set('v.account', account);
            component.set('v.customerId', account.CIF__pc);
            component.set('v.RegionFlag', caseObj.Region_Flag__c); // #CH01#
            component.set('v.caseRecordTypeId', caseObj.RecordTypeId);
            component.set('v.subType',caseObj.Sub_Type__c)
            var isOpenCase = 'Closed' !== caseObj.Status;
            component.set('v.isOpenCase', isOpenCase);
		});
	},
	showSpinner: function (component, event, helper) {
        component.set("v.showSpinner",true);
    },
    hideSpinner: function (component, event, helper) {
        component.set("v.showSpinner",false);
    }
})
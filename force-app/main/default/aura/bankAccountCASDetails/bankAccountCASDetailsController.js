({
	init : function(component, event, helper) {
		console.log('CAS Component Executed');
        var ibanNumber = component.get('v.accountId');
        console.log('IBAN Number in CAS',ibanNumber);
	},
     loadCASDetails: function (component, event, helper) {
       helper.loadCASP(component, component.get('v.customerId'),component.get('v.account'),component.get('v.accountId'));
    },
})
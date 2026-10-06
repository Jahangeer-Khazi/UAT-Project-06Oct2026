({
	 retreiveJordanianId: function(component, event, helper) {
        var caseId=component.get("v.recordId");
        console.log('Fetch Jordanian ID from Civil Integration API');
        helper.showSpinner(component, event, helper);
        helper.fetchIdExpiryDate(component, event, caseId);
	},
})
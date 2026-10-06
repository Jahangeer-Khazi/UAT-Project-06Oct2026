({
	init : function(component, event, helper) {
        console.log('Inside init method of Daily Payment Limit component');
    	console.log('sobjectName==> '+component.get('v.sObjectName'));
        var accIds = component.get("v.caseId");
        console.log('Account Ids:',accIds);
        // Define datatable columns
        component.set("v.columns", [
            {
                label: "Daily Payment Cap",
                fieldName: "dailyPaymentCap",
                type: "number",
                cellAttributes: { alignment: "left" }
            },
            {
                label: "Used Amount",
                fieldName: "usedAmount",
                type: "number",
                cellAttributes: { alignment: "left" }
            },
            {
                label: "Remaining Limit",
                fieldName: "remainingLimit",
                type: "number",
                cellAttributes: { alignment: "left" }
            }
        ]);
        
        // Load mock API response
        
        //helper.showSpinner(component,event,helper);
        //helper.loadMockData(component,event,helper);
        helper.fetchPaymentLimits(component,event,helper);
		
	}
})
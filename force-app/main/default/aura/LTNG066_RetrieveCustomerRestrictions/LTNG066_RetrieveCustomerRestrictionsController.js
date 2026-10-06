({
	init : function(component, event, helper) {
        console.log('LTNG066_RetrieveCustomerRestrictions --> init');
        var recordId = component.get('v.recordId');
        console.log('recordId Id in init:',recordId);
        var pageType = component.get('v.pageType');
        console.log('LTNG066_RetrieveCustomerRestrictions --> pageType in init:',pageType);
        helper.loadRetrieveCustomerRestrictions(component, recordId, pageType);
    },
})
({
    init: function(component, event, helper) {
        var customerId = component.get('v.customerId');
        
        helper.loadCurrencyOptions(component);
        helper.loadAccount(component, customerId);
        //component.set("v.currencyOptions", helper.getCurrencyOptions());	
	},
    open: function(component, event, helper) {
        var accountObj = event.getParams('arguments').arguments.accountObj;
        var actionType = event.getParams('arguments').arguments.actionType;
        component.set('v.accountObj', accountObj);
        component.set('v.actionType', actionType);
        //var requestData = {
        //};
        //component.set('v.requestData', requestData);
        var requestData = component.get('v.requestData');
        helper.openRequestPopup(component, requestData);

    },
    onCancel: function (component, event, helper) {
        helper.resetRequestData(component);
        helper.closeRequestPopup(component);
    },

    onSendRequestClick: function (component, event, helper) {
        var requestData =  component.get('v.requestData');
        if (false === helper.isValidInput(component)) {
            
            component.find('apexService').showErrorMessage($A.get("$Label.c.Please_enter_required_values"));
            return;
        }
        if (!confirm($A.get("$Label.c.Are_you_sure_you_want_to_proceed_with_the_request"))) {
            return;
        }
        var customerId = component.get('v.customerId');
        var caseId = component.get('v.caseId');
        var requestType = "Collection" === component.get('v.actionType')? 'Cash Collection': 'Cash Delivery';

        var accountObj = component.get('v.accountObj');
        requestData.account = accountObj;
        helper.sendRequest(component, customerId, requestData, caseId, requestType);
    },

})
({
    init : function(component, event, helper) {
        helper.loadCardDetails(component, component.get('v.customerId'), component.get('v.cardId'), component.get('v.account'));
	},

    load : function(component, event, helper) {
        helper.loadCardDetails(component, component.get('v.customerId'), component.get('v.cardId'), component.get('v.account'));
	}
})
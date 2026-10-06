({
	init : function(component, event, helper) {
        console.log('Sub Tab Clicked and init invokeddd');
        var accId = component.get('v.accId');
        console.log('Acct Id in init:',accId);
        var subTabName = component.get('v.subTabName');
        console.log('Sub Tab Name in init:',subTabName);
        helper.loadDataInAuditObject(component, component.get('v.accId'), subTabName);
    },
})
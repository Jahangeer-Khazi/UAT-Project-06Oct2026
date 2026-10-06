({
	init : function(component, event, helper) {
        console.log('Details Tab Clicked and init invokeddd');
        var tabName = component.get('v.tabName');
        console.log('Tab Name in init:',tabName);
        if(tabName === 'Customer Details' || tabName === 'Ila Accounts' || tabName === 'Alburaq Accounts' || tabName === 'Case List' || tabName === 'Documents List' || tabName === 'Activity List'){
             helper.loadDataInAuditObject(component, component.get('v.recordId'), tabName);
        }
        else if(tabName === 'Content Detail'){
             helper.loadContentDataInAuditObject(component, component.get('v.recordId'), tabName);
        }
        else if(tabName === 'Case Detail'){
             helper.loadCaseDataInAuditObject(component, component.get('v.recordId'), tabName);
        }
       
    },
})
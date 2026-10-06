({
	init : function(component, event, helper) {
        component.set("v.tbId", Math.random().toString(36).substr(2, 11));
        component.set('v.gridDataColumns', helper.getDataColumns(component));
        component.set('v.gridDataColumnDefs', helper.getColumnDefs(component));
        helper.loadGovernmenSecurities(component,event,helper);
	},
    handleJqDataTableEvent: function(component, event, helper) {
        helper.handleJqDataTableEvent(component, event);
    },
       onSearchClick: function(component, event, helper) {
        if(!$A.util.isEmpty(component.get('v.selectedLookUpRecord'))){
         component.set('v.customerId',component.get('v.selectedLookUpRecord.CIF__pc'));
         helper.customerDetails(component,event,helper);
      }
        helper.loadGovernmenSecurities(component,event,helper);
        
    }
})
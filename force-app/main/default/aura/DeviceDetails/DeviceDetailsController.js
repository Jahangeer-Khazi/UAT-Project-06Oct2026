({
	doInit  : function(component, event, helper) {
        var accId = component.get("v.customerId");
        console.log('Account Id from Flow:',accId);
         // DATATABLE COLUMNS
        component.set("v.columns", [
            {
                label: 'ID',fieldName: 'id',type: 'text'
            },
            {
      			label: 'Status',fieldName: 'status',type: 'text'
            },
            {
                label: 'Manufacturer',fieldName: 'manufacturer',type: 'text'
            },
            {
                label: 'Model',fieldName: 'model',type: 'text'
            },
            {
                label: 'OS',fieldName: 'os',type: 'text'
            },
            {
                label: 'Device Last Login',fieldName: 'deviceLastLogin',type: 'text'
            }
        ]);

        helper.fetchDevices(component);
		
	}
})
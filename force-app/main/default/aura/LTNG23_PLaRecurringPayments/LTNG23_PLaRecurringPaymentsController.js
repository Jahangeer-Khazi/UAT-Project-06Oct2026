({
	init : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Schedule ID', fieldName: 'scheduleId', type: 'text',sortable:true},
            {label: 'Amount', fieldName: 'amount', type: 'text',sortable:true},
            {label: 'Source Account', fieldName: 'sourceAccount', type: 'text',sortable:true},
            {label: 'Frequency', fieldName: 'frequency', type: 'text',sortable:true},
            {label: 'Start Date', fieldName: 'startDate', type: 'text',sortable:true},
            {label: 'Next Payment Date', fieldName: 'nextPaymentDate', type: 'text',sortable:true},
            {label: 'Status', fieldName: 'status', type: 'text',sortable:true},
            {label: 'End of the Month', fieldName: 'endOfTheMonth', type: 'text',sortable:true}
		]);
		
        component.set('v.columnsDataPaymentDetails', [
            {label: 'Schedule ID', fieldName: 'scheduleId', type: 'text',sortable:true},
            {label: 'Transaction Amount', fieldName: 'amount', type: 'text',sortable:true},
            {label: 'Source Account', fieldName: 'sourceAccount', type: 'text',sortable:true},
            {label: 'Transaction Date', fieldName: 'transactionDate', type: 'text',sortable:true},
            {label: 'Transaction Payment Status', fieldName: 'transactionPaymentStatus', type: 'text',sortable:true}
        ]);
	},
	onLoadviewReccPayments: function (component, event, helper) {
        console.log('onLoadviewReccPayments');
        helper.loadData(component,helper);
	},
	handleRowSelection: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        // Display that id of the selected row
        for (var i = 0; i < selectedRows.length; i++){
            var schedulRecPayId = selectedRows[i].id;
            console.log("---------On selection schedulRecPayId--------", schedulRecPayId);
            helper.openSchedulRecPayDetails(component,helper,schedulRecPayId);
            break;
        }
    },  
	
})
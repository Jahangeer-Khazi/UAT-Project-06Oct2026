/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History: 
 *			  
 *
 */
({
    init : function(component, event, helper) {
        var customerId = component.get('v.customerId');
        component.set('v.columns', [
            {label: 'Account Number', fieldName: 'accountNumber', type: 'text', sortable:true},
            {label: 'Product Name', fieldName: 'productName', type: 'text', sortable:true},
            {label: 'Transaction Date', fieldName: 'transactionDate', type: 'date', sortable:true},
            {label: 'Transaction Amount', fieldName: 'amount', type: 'number', sortable:true},
            {label: 'Transaction Currency', fieldName: 'transactionCurrency', type: 'text', sortable:true},
            {label: 'Transaction Type', fieldName: 'transactionType', type: 'text', sortable:true},
            {label: 'Transaction Description', fieldName: 'transactionDescription', type: 'text', sortable:false},
        ]);

        helper.loadData(component, customerId);
	},
})
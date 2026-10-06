/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:23-09-2021
 * 		Change History: 
 *			  
*/
({
    init : function(component, event, helper) {
	console.log('init statement method called');
        var customerId = component.get('v.customerId');
        var account = component.get('v.account');
        var accountId = component.get('v.account.Id');
        var pciNumber = component.get('v.pcICardId');
        var columns = [];
        	columns  = [
            	{label: 'Statement Date', fieldName: 'statementDate', type: 'text',sortable:true },
            	{label: 'Due Date', fieldName: 'dueDate', type: 'text',sortable:true},
            	{label: 'Minimum Due Amount', fieldName: 'minimumDueAmount', type: 'text',sortable:true},
            	{label: 'Past Due Amount', fieldName: 'pastDueAmount', type: 'number',sortable:true},
               // {label: 'Download',fieldName: 'accountId', type: 'text'}
               {
        label: 'Download',
        type: 'button-icon',
        initialWidth: 135,
        typeAttributes: { iconName: 'utility:download', name: 'download_file', title: 'Click to download' }
    }
                
        	];
        	component.set('v.columns', columns);
        /*component.set('v.data', [{
                statementDate: '2019-01-31',
            	statementDescription: 'January, 2019',
            dueDate: '2021-01-01',
            latePaymentGraceDate: '2021-01-01',
            openingBalance: 1000,
            closingBalance: 900,
            minimumDueAmount: 10,
            pastDueAmount: 200,
            overLimitAmount: 50,
            accountId: '455512******4554'

        }]);
           console.log("dummy data is loaded",component.get('v.data'));*/
        helper.loadData(component, customerId,pciNumber,account);
    },
    GenerateStatement : function(component, event, helper) {
        component.set("v.showStatement",true);
        console.log('data===>'+component.get('v.data'));
    },
    handleRowAction: function(component, event,helper) {
        var customerId = component.get('v.customerId');
        var account = component.get('v.account');
        var pciNumber = component.get('v.pcICardId');
        var action = event.getParam( 'action' );
	    var selectedRow = event.getParam( 'row' );
        helper.handleGetStatement(component, customerId, pciNumber,account,selectedRow);
},
    
})
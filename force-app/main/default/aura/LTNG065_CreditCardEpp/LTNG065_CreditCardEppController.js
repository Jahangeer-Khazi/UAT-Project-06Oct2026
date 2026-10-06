/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:23-09-2021
 * 		Change History: 
 *          #CH01 : Hamza Chaoui 20/06/2022 Alburaq Logic
 *			  
*/
({
	init : function(component, event, helper) {
      
        
        var columns = [];
        columns  = [
            	{label: 'Merchant Name', fieldName: 'merchant', type: 'text',sortable:true },
            	{label: 'Plan Number', fieldName: 'planNumber', type: 'text',sortable:true},
            	{label: 'Tenor', fieldName: 'tenor', type: 'text',sortable:true},
            	{label: 'Transaction Amount', fieldName: 'transactionAmount', type: 'number',sortable:true},
            	{label: 'Status', fieldName: 'status', type: 'text',sortable:true}
        	];
        component.set('v.columns', columns);
        helper.loadCaseData(component,event,helper);
       // helper.loadData(component, customerId, pciNumber,account);
    },
    load: function (component, event, helper) {
       
        console.log('Load method called');
        
        var customerId = component.get('v.customerId');
        var pciNumber = component.get('v.pcICardId');
        helper.loadData(component, customerId,pciNumber);
    },
    handleRowAction: function (component, event, helper) {
    },
    
    handleRowSelection: function (component, event, helper) {
        component.find('EPPListTable').set("v.selectedRows", []);
       // component.set('v.selectedEPPRow',[]);
        var selectedRows = event.getParam('selectedRows');
        console.log('--> SELECTED EPP Record-> ',selectedRows);
        var selRow = [];
        for (var i = 0; i < selectedRows.length; i++){
            selRow = selectedRows[i];
            console.log('Selected Row On Selection:',selRow);
            component.set('v.selectedEPPRow',selRow);
            component.set('v.eppTargetData',selRow);
            component.set('v.eppSelected',true);
            component.set('v.SelectedPlan',selectedRows[i].planNumber)
            break;
        }
        //console.log('----> Getting the EPP Data->',component.get('v.eppTargetData'));
        //console.log('Epp Selected in Handle Row Selection',component.get('v.eppSelected'));
   },
    onChangepciCardId : function(component, event, helper) {
        console.error('onChangepciCardId !!');
        var customerId = component.get('v.customerId');
        var account = component.get('v.account');
        var pciNumber = component.get('v.pcICardId');
        component.set('v.data', []); 
        helper.loadData(component, customerId, pciNumber,account);
    },

   
})
/* 		Organization : ABC Bank
 * 		Created By: 
 *		Created Date:
 * 		Change History: 
 *             
 *            #CH03# : #Jahangeer Mohammed# #06-05-2024# Added Logic for Audit History Enhancements(NBA-9027)
			  #CH04# : Maksud Ali 12-10-2025, set potName prop.

*/
({
    init : function(component, event, helper) {
        var rowLevelActions = [
            { label: 'Show transactions', name: 'show_transactions' },
        ];

        if (true === component.get('v.enableActions')) {
            // add action buttons
            rowLevelActions.push( { label: 'Request Cash Collection', name: 'request_cash_collection' });
            rowLevelActions.push( { label: 'Request Cash Delivery', name: 'request_cash_delivery' });
        }

        component.set('v.columns', [
            {label: 'Pot Id', fieldName: 'potId', type: 'text',sortable:true, cellAttributes : {alignment : 'left'}},
            {label: 'Name', fieldName: 'name', type: 'text',sortable:true},
            {label: 'Account Available Balance', fieldName: 'accountAvailableBalance', type: 'number',sortable:true},
            {label: 'Status', fieldName: 'status', type: 'text',sortable:true},
            { type: 'action', typeAttributes: { rowActions: rowLevelActions } }
        ]);
        
        var customerId = component.get('v.customerId');
			 
        if (customerId) {
            helper.loadData(component, customerId);
        }
    },
    load: function (component, event, helper) {
        var customerId = component.get('v.customerId');
												 
        helper.loadData(component, customerId);
    },

    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var customerId = component.get('v.customerId');
        switch (action.name) {
            case 'show_transactions':
                helper.openTransactionList(component, customerId, row.id);
                break;
            case 'freeze':
                break;
        }
    },
    handleRowSelection: function (component, event, helper) {
        var customerId = component.get('v.customerId');
        var selectedRows = event.getParam('selectedRows');
        console.log('Selected ROW saving pot:',selectedRows);
        // Display that id of the selected row
        for (var i = 0; i < selectedRows.length; i++){
            var potId = selectedRows[i].potId;
            //CH04 start
            var potName = selectedRows[i].name;
            component.set("v.potName",potName);
            //CH04 end
            
            console.log("---------On selection id--------", potId);
			console.log("---------On selection name--------", potName);
            
            helper.loadPotDetail(component, customerId, potId);
            //CH03: Start
            var enableAuditComp = $A.get("$Label.c.ENABLE_AUDIT_COMPONENT");
            if(enableAuditComp == 'true'){
                helper.loadDataInAuditObject(component,potId);
            }
            //CH03: END
            break;
        }
    },
    handleAppEvent: function (component, event, helper) {
        console.log("bankAccountList.handleAppEvent=" + JSON.stringify(event));

        var isMyEvent = 'accountList' === event.getParam("target");

        if (!isMyEvent) {
            return;
        }

        var message = event.getParam("message");
        var action = message.action;

        var customerId = component.get('v.customerId');

        if ( "refresh" === action) {
            // reload account list and reset selection
            component.set('v.potId', undefined);
            component.find('lstPots').set("v.selectedRows", []);
            //helper.loadData(component, customerId);
        }
    },
    //CH02:Imane Tsioucha#  Add Saving Pots Filter

    onSavingPotStatusChange : function(component, event, helper){
        var newdata = [];
        var savingPotSelected = component.get('v.selectedSavingPotStatus'); 
        console.log('Selected saving pot: >>>  '+savingPotSelected);
        var accounts = component.get('v.Origindata');
        console.log('bank saving pot Account: ', JSON.stringify(accounts));
        accounts.forEach(account => { 
            console.log('acc >> '+JSON.stringify(account));
            if(
            ((account.status.toLowerCase() == 'active' || account.status.toLowerCase() == 'inactive') && savingPotSelected == 'A')
            || ((account.status.toLowerCase() == 'completed' || account.status.toLowerCase() == 'closed') && savingPotSelected == 'B')
            || (account.status.toLowerCase() == 'archived' && savingPotSelected == 'C')
            || (account.status.toLowerCase() == 'dormant' && savingPotSelected == 'D')
            || (account.status.toLowerCase() == 'blocked for debits' && savingPotSelected == 'E')
            ){
              	newdata.push(account);
        	} 
        })
        console.log('newdata >>>> '+JSON.stringify(newdata));
        component.set('v.data', newdata);
        
    }
    //CH02: END

})
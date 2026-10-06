/* 		
 * 		Change History: 
 *              #CH01# : #Jahangeer Mohammed# #07-08-2023# Added Logic for CAS Status(NBA-7983)
 *              #CH02# : #Tsioucha Imane# #13-09-2023
 */
({
    init : function(component, event, helper) {
      
        var rowLevelActions = [
            { label: 'Show BondDetails', name: 'show_BondDetails' },
        ];
        
        component.set('v.columns', [
            {label: 'Instrument No', fieldName: 'ReferenceNo', type: 'text',sortable:true},
            {label: 'Investment No', fieldName: 'investmentid', type: 'text',sortable:true},
            {label: 'ISIN Code', fieldName: 'ISINCode', type: 'text',sortable:true},
            {label: 'ISIN Name', fieldName: 'ISINName', type: 'text',sortable:true},
            {label: 'Instrument Status', fieldName: 'Status', type: 'text',sortable:true},
            {label: 'Investment Status', fieldName: 'invStatus', type: 'text',sortable:true},
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
        }
    },    
    handleRowSelection: function (component, event, helper) {
        var customerId = component.get('v.customerId');
        var selectedRows = event.getParam('selectedRows');
        // Display that id of the selected row
        for (var i = 0; i < selectedRows.length; i++){
            var instrumentId = selectedRows[i].ReferenceNo;
            var investmentId= selectedRows[i].investmentid;
            //CH02: Start
            var isinCode= selectedRows[i].ISINCode;
            var isinName=selectedRows[i].ISINName;
            //CH02: End
            console.log('==> selectedRows '+JSON.stringify(selectedRows[i]));

            //CH01: Start
         /*   var getAccountIdevent = $A.get("e.c:PassAccountIdEvent");
            if(getAccountIdevent){
                getAccountIdevent.setParams({
                    "globalAccountId": accountId
                    });
                var test = getAccountIdevent.getParam("globalAccountId");
                console.log("global account ID is set in Bank account list to  ", test);
                getAccountIdevent.fire();
            }*/

            //CH01: Added one parameter accountType
            helper.openInstrumentDetails(component, instrumentId,investmentId);
            //CH01: END
           // break;
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
            component.set('v.accountId', undefined);
            component.find('accountListTable').set("v.selectedRows", []);
            //helper.loadData(component, customerId);
        }
    },

})
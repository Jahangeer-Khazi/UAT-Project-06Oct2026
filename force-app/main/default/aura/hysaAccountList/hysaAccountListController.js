/* 		
 * 		Created By: Maksud Ali
 *		Created Date: 08-12-2025 (Below code is cloned from bank account List)
 * 		Change History: 
 *              #CH01# : #Jahangeer Mohammed# #07-08-2023# Added Logic for CAS Status(NBA-7983)
 *              #CH02# : #Tsioucha Imane# #13-09-2023
 *              #CH03# : #Jahangeer Mohammed# #28-04-2024# Added Logic for Audit History Enhancements(NBA-9027)
 */
({
    init : function(component, event, helper) {
        var rowLevelActions = [
            { label: 'Show transactions', name: 'show_transactions' },
        ];
            
            if (true === component.get('v.enableActions')) {
            rowLevelActions.push( { label: 'Request Cash Collection', name: 'request_cash_collection' });
            rowLevelActions.push( { label: 'Request Cash Delivery', name: 'request_cash_delivery' });
            }
            
            component.set('v.columns', [
            {label: 'Product Name', fieldName: 'productName', type: 'text',sortable:true},
            {label: 'Account Number', fieldName: 'accountNumber', type: 'text',sortable:true},
            {label: 'Account Available Balance', fieldName: 'availableBalance', type: 'number',sortable:true},
            {label: 'Account Currency', fieldName: 'accountCurrency', type: 'text',sortable:true},
            {label: 'Account Status', fieldName: 'status', type: 'text',sortable:true},
            { type: 'action', typeAttributes: { rowActions: rowLevelActions } } 
        ]);
        
        var customerId = component.get('v.customerId');
        if (customerId) {
            debugger;
            helper.loadData(component, customerId);
        }
    },
    
    load: function (component, event, helper) {
        var customerId = component.get('v.customerId');
        helper.loadData(component, customerId);
    },
    
    handleRowAction: function (component, event, helper) {
        debugger;
        var action = event.getParam('action');
        var row = event.getParam('row');
        var customerId = component.get('v.customerId');
        switch (action.name) {
            case 'show_transactions':
                helper.openTransactionList(component, customerId, row.id);
                break;
            case 'request_cash_collection':
                helper.requestCashCollection(component, customerId, row);
                break;
            case 'request_cash_delivery':
                helper.requestCashDelivery(component, customerId, row);
                break;
            case 'freeze':
                break;
        }
    },   
    
    handleRowSelection: function (component, event, helper) {
        debugger;
        var customerId = component.get('v.customerId');
        var selectedRows = event.getParam('selectedRows');
        // Display that id of the selected row
        for (var i = 0; i < selectedRows.length; i++){
            var accountId = selectedRows[i].id;
            //CH02: Start
            var curency= selectedRows[i].accountCurrency;
            var accountNumber=selectedRows[i].accountNumber;
            //CH02: End
            console.log('==> selectedRows ', selectedRows[i]);
            console.log('==> selectedRows '+JSON.stringify(selectedRows[i]));
            console.log('==> curency '+curency);
            console.log('==> accountNumber '+accountNumber);

            component.set('v.hysaRate', selectedRows[i].hysaRate);
            component.set('v.debitInterestRate', selectedRows[i].debitInterestHY);
            component.set('v.debitInterestHY', selectedRows[i].debitInterestHY);
            
            
            //CH01: Start
            var accountType = selectedRows[i].productName;
            console.log('Selected Row in bank Account:',accountType);
            //CH01: END
            console.log("---------On selection accountId--------", accountId);
            /*pass the ID to Bank card list controller*/
            var getAccountIdevent = $A.get("e.c:PassAccountIdEvent");
            if(getAccountIdevent){
                getAccountIdevent.setParams({
                    "globalAccountId": accountId
                    });
                var test = getAccountIdevent.getParam("globalAccountId");
                //alert("global account ID is set in Bank account list to  " +test);
                console.log("global account ID is set in Bank account list to  ", test);
                getAccountIdevent.fire();
            }

            //CH01: Added one parameter accountType
            helper.openAccountDetails(component, customerId, accountId,curency,accountNumber,accountType);
            //CH01: END
            //CH03: Start
            var enableAuditComp = $A.get("$Label.c.ENABLE_AUDIT_COMPONENT");
            console.log('Enable Audit Comp:',enableAuditComp);
            if(enableAuditComp == 'true'){
               helper.loadDataInAuditObject(component,accountId); 
            }
            //CH03: END
            break;
        }
    },    
    
    handleAppEvent: function (component, event, helper) {
        var isMyEvent = 'accountList' === event.getParam("target");
        
        if (!isMyEvent) {
            return;
        }
        
        var message = event.getParam("message");
        var action = message.action;
        var customerId = component.get('v.customerId');
        
        if ( "refresh" === action) {
            component.set('v.accountId', undefined);
            component.find('accountListTable').set("v.selectedRows", []);
        }
    },
    
})
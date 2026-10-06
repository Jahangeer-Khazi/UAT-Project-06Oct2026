/* 	
 * 		Change History: 
 *              #CH01# : #Jahangeer Mohammed# #11-10-2023# Added Logic to reset SelectedCardId for Debit Cards
 *              #CH02# : #Jahangeer Mohammed# #06-05-2024# Added Logic for Audit History Enhancements(NBA-9027)

 */
({
    init : function(component, event, helper) {
        /*
           var totalCnt = component.get("c.getTotalCount");
           totalCnt.setCallback(this, function(a) {
           component.set("v.totalNumberOfRows", a.getReturnValue());
           });
           $A.enqueueAction(totalCnt);
         */
        console.log('Debit Card Constructor Loads');
        var fetchOption = component.get('v.option');
        console.log('Fetch Option value:',fetchOption);
        var columns  = [
            {label: 'Card Classification', fieldName: 'productType', type: 'text',sortable:true },
            //{label: 'Card Type', fieldName: 'cardType', type: 'text',sortable:true},
            {label: 'Card Status', fieldName: 'status', type: 'text',sortable:true},
            {label: 'Card Number', fieldName: 'maskedCardNumber', type: 'text',sortable:true}
        ];
        /*
        if (true === component.get('v.enableActions')) {
            // add action buttons
            var rowLevelActions = [
                { label: 'Activate', name: 'activate' },
               { label: 'Block', name: 'block' },

            ];
            columns.push({type: 'action', typeAttributes: { rowActions: rowLevelActions } });
        }
        */
        component.set('v.columns', columns);
        var customerId = component.get('v.customerId');
        helper.loadData(component, customerId);
    },

    LoadAccountId : function(component, event, helper) {
        //alert("Load account is fired and global variable set" +event.getParam("globalAccountId"));
        var accountId = event.getParam("globalAccountId");
        component.set("v.accountId", accountId);  //set the accountID passed through bank account list component
        //alert("AccountId in BankCardListController" +accountId);
     },

    load: function (component, event, helper) {
        var customerId = component.get('v.customerId');
        helper.loadData(component, customerId);
    },

    handleRowAction: function (component, event, helper) {
        console.log("bankCardsList.cmp - handleRowAction");
        var action = event.getParam('action');
        var row = event.getParam('row');
        var customerId = component.get('v.customerId');
        switch (action.name) {
            case 'activate':
                helper.activateCard(component, customerId, row.id);
            break;
            case 'block':
                var blockCardData = {
                    cardId: row.id,
                    maskedCardNumber: row.maskedCardNumber
                };
                helper.openBlockCardPopup(component, customerId, blockCardData);
            break;
        }
    },
    handleRowSelection: function (component, event, helper) {
        var fetchOption = component.get('v.option');
        console.log('Fetch Option value on Row Selection:',fetchOption);
        if(fetchOption != 'P'){
            var customerId = component.get('v.customerId');
            var selectedRows = event.getParam('selectedRows');
            console.log('Seelcted ROW in Debit Card',selectedRows);
            // Display that id of the selected row
            for (var i = 0; i < selectedRows.length; i++){
                var cardId = selectedRows[i].id;
                //CH02: Start
                var maskNumber = selectedRows[i].maskedCardNumber;
                var cardClassification = selectedRows[i].productType;
                var cardStatus = selectedRows[i].status;
                //CH02: END
                console.log('Debit Card Id in Non Purge Cards:',cardId);
                component.set('v.selectedCardId', cardId);
                helper.openCardDetails(component, customerId, cardId, component.get('v.accountId'));
                //CH02: Start
                var enableAuditComp = $A.get("$Label.c.ENABLE_AUDIT_COMPONENT");
                if(enableAuditComp == 'true'){
                    helper.loadDataInAuditObject(component,maskNumber,cardClassification,cardStatus);
                }
                //CH02: END
				break;
            }
        }
        else if(fetchOption == 'P'){
           console.log('Purge Option Selected');
           var customerId = component.get('v.customerId');
           var selectedRows = event.getParam('selectedRows');
            console.log('Selected Rows Length:',selectedRows.length);
           var selRow = [];
           for (var i = 0; i < selectedRows.length; i++){
                var cardId = selectedRows[i].id;
                console.log('Debit Card Id in Purge Cards:',cardId);
                selRow = selectedRows[i];
                console.log('Selected Purge Row On Selection:',selRow);
                component.set('v.selectedCardId', cardId);
                component.set('v.purgeData',selRow);
                component.set('v.purgeSelected',true);
                break;
            }
        }
        
        
    },
    handleAppEvent: function (component, event, helper) {
        console.log("bankCardsList.handleAppEvent=" + JSON.stringify(event));

        var isMyEvent = 'cardList' === event.getParam("target");

        if (!isMyEvent) {
            return;
        }

        var message = event.getParam("message");
        var action = message.action;

        var customerId = component.get('v.customerId');

        if ( "refresh" === action) {
            // reload card list and reset selection
            component.set('v.selectedCardId', undefined);
            component.find('cardsListTable').set("v.selectedRows", []);
            helper.loadData(component, customerId);
        }
    },
    //CH01: Start
	onChangeOption : function(component, event, helper) {
        console.log('onChangeSelectedCardId !!');
        component.set('v.selectedCardId', null); 
    },
    //CH01: END
})
/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History:
 *			   #CH03# #MBARKI ANISS# #09-08-2022# Add targetType
 *			   #CH04# #Jahangeer Mohammed# #16-10-2023# Added Card Nature for Ila World & Ila World Elite
 *             #CH05# : #Jahangeer Mohammed# #31-12-2023# Added Logic to reset SelectedCardId for Credit Cards
 *             #CH06# : #Jahangeer Mohammed# #05-05-2024# Added Logic for Audit History Enhancements(NBA-9027)
 *			   #CH07# #Jahangeer Mohammed# #24-10-2024# Added Logic for Credit Card Account Closure(NBA-9192)
 *             #CH08# : Maksud Ali - 2nd Apr 2025, Added a line to set the v.selectedCardType props
 *	 		   #CH09# #Jahangeer Mohammed #09-11-2025# Added Logic for Credit Card Spouse (NBA-15728)		   
 */
({
    init: function (component, event, helper) {
        console.log('Inside Credit Card List Controller init method');
        /*
           var totalCnt = component.get("c.getTotalCount");
           totalCnt.setCallback(this, function(a) {
           component.set("v.totalNumberOfRows", a.getReturnValue());
           });
           $A.enqueueAction(totalCnt);
         */
        var fetchOption = component.get('v.option');
        console.log('Fetch Option Value Inside Init method of CC List Controller:', fetchOption);


        var columns = [
            {
                label: 'Card Classification', fieldName: 'productType', type: 'text', sortable: true,
                cellAttributes: {
                    class: { fieldName: 'colortext' }
                }
            },
            //{label: 'Card Type', fieldName: 'cardType', type: 'text',sortable:true},
            {
                label: 'Card Status', fieldName: 'status', type: 'text', sortable: true,
                cellAttributes: {
                    class: { fieldName: 'colortext' }
                }
            },
            //CH03:Start
            {
                label: 'Card Type', fieldName: 'cardType', type: 'text', sortable: true,
                cellAttributes: {
                    class: { fieldName: 'colortext' }
                }
            },
            //CH03:Start
            {
                label: 'Card Number', fieldName: 'maskedCardNumber', type: 'text', sortable: true,
                cellAttributes: {
                    class: { fieldName: 'colortext' }
                }
            },
            {
                label: 'Is Delinquent', fieldName: '',
                cellAttributes: {
                    class: { fieldName: 'delinquent', fieldName: 'colortext' },
                    iconName: {
                        fieldName: 'displayIconName'
                    }
                }
            }
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
        helper.loadBTColumns(component);
        var customerId = component.get('v.customerId');
        var account = component.get('v.account');
        var accountId = component.get('v.account.Id');
        console.log("---->>> CUSTOMER ID List1--> ", customerId);
        console.log("---->>> account List1--> ", account);
        console.log("---->>> accountId List1--> ", accountId);
        helper.handleuserData(component, event, account);
        helper.loadData(component, customerId);
    },

    LoadAccountId: function (component, event, helper) {
        //alert("Load account is fired and global variable set" +event.getParam("globalAccountId"));
        var accountId = event.getParam("globalAccountId");
        component.set("v.accountId", accountId);  //set the accountID passed through bank account list component
        //alert("AccountId in BankCardListController" +accountId);
    },
    handleComponentEvent: function (cmp, event) {
        //debugger;
        var productName = event.getParam("productName");

        // set the handler attributes based on event data
        cmp.set("v.productName", productName);

    },

    load: function (component, event, helper) {
        console.log('Inside Credit Card List Controller Load method');
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
        var customerId = component.get('v.customerId');
        var accountId = component.get('v.account.Id');
        var allCardDetails = component.get("v.allCardDetails");

        var cardType;
        var selectedRows = event.getParam('selectedRows');
        var cardStatus;

        console.log('--> SELECTED ROW CARD ID first-> ', selectedRows);
        // Display that id of the selected row
        console.log('--> SELECTED ROW Length-> ', selectedRows.length);

        //var gettingFilterData = component.get('v.CaptureDataBasedOnFilter');
        //console.log('Getting Data Based on Filter',gettingFilterData);

        //CH05: Start
        var fetchOption = component.get('v.option');
        console.log('Fetch Option value on Row Selection Credit Card:', fetchOption);

        if (fetchOption != 'P') {
            for (var i = 0; i < selectedRows.length; i++) {
                console.log("selectedRows[i] ", selectedRows[i]);
                var selRow = selectedRows[i];
                component.set("v.selectedCardDetails", allCardDetails[selRow.id]);

                console.log('selected card details --->', component.get("v.selectedCardDetails"));
                //CH08: Start
                component.set("v.selectedCardType", selectedRows[i].cardType);
                //CH08: End
                if (selectedRows[i].productType == 'ila Switch') {
                    cardType = 'PLATINUM_BALANCE_TRANSFER_01';
                }
                else if (selectedRows[i].productType == 'ila Blue') {
                    cardType = 'PLATINUM_CASHBACK_AND_REWARD_01';
                }
                else if (selectedRows[i].productType == 'ila Black Metal') {
                    cardType = 'WORLD_ELITE_CASHBACK_AND_REWARDS_01';
                }
                else if (selectedRows[i].productType == 'ila Gulf Air') {
                    cardType = 'GULF_AIR_AIRLINE_MILES';
                }
                var cardId = selectedRows[i].id;
                component.set("v.maskedNumber", selectedRows[i].maskedCardNumber);
                cardStatus = selectedRows[i].status;
                //CH06: Start
                var maskNumber = selectedRows[i].maskedCardNumber;
                var cardClassification = selectedRows[i].productType;
                //CH06: END
                //#CH03 : Start
                component.set("v.targetType", selectedRows[i].targetType);
                console.error('v.targetType>>>>>>>>>>>>>>>>>>>>>' + selectedRows[i].targetType);
                //#CH03 : End

                component.set("v.isPrimary", selectedRows[i].targetType == 'SUPPLEMENTARY_CARD' ? false : true);
                //CH04: Start
                var cardNature = selectedRows[i].cardNature;
                console.log('Card Nature of Selected Card:', cardNature);
                component.set('v.cardNature', cardNature);
                //CH07: Start
                var caseIdRelatedToCard = selectedRows[i].crmCaseId;
                component.set('v.caseIdRelatedToCard', caseIdRelatedToCard);
                //CH07: END
                //CH09: Start
                var isSpouse = selectedRows[i].isSpouse;
                console.log('Spouse value:', isSpouse);
                component.set('v.isSpouse', isSpouse);
                //CH09: END
                var caseType = component.get('v.caseType');
                component.set('v.typeOfCase', caseType);
                ///////////////////////////// Cash Collateral Cards ///////////////////////////////////
                if (cardNature == 'secured') {
                    var holdAcc = selectedRows[i].holdAccount;
                    var holdAmt = selectedRows[i].holdAmount;
                    var holdRef = selectedRows[i].holdReference;
                    component.set('v.holdAccount', holdAcc);
                    component.set('v.holdAmount', holdAmt);
                    component.set('v.holdReference', holdRef);
                }
                ///////////////////////////// Cash Collateral Cards ///////////////////////////////////
                //CH04: END

                console.log('--> This is Account ID -> ', component.get('v.account.Id'));
                console.log('--> SELECTED ROW CARD ID -> ', cardId);

                //#CH10 :Start
                console.log("selectedRows[i].isRenewed -->" + selectedRows[i].isRenewed);
                if (selectedRows[i].isRenewed == true) {
                    component.set('v.showIsRenewedError', true);
                    break;
                }
                //#CH10 :End

                helper.openCardDetails(component, customerId, cardId, component.get('v.account.Id'), cardType, cardStatus);
                //CH06: Start
                var enableAuditComp = $A.get("$Label.c.ENABLE_AUDIT_COMPONENT");
                if (enableAuditComp == 'true') {
                    helper.loadDataInAuditObject(component, maskNumber, cardClassification, cardStatus);
                }
                //CH06: END
                break;
            } //for loop Ends
        } //If Ends
        else if (fetchOption == 'P') {
            console.log('Purge Option Selected for Credit Cards');
            var customerId = component.get('v.customerId');
            var selectedRows = event.getParam('selectedRows');
            console.log('Selected Rows Length Credit Card:', selectedRows.length);
            var selRow = [];
            for (var i = 0; i < selectedRows.length; i++) {
                var cardId = selectedRows[i].id;
                console.log('Credit Card Id in Purge Cards:', cardId);
                selRow = selectedRows[i];
                console.log('Selected Credit Card Purge Row On Selection:', selRow);
                component.set('v.selectedCardId', cardId);
                component.set('v.purgeData', selRow);
                component.set('v.purgeSelected', true);
                break;
            } //for Ends
        } //else if Ends
        //CH05: END

        // ==================== NEW LOGIC - ONLY FOR isSecondary = true ====================
        if (component.get("v.isSecondary") && fetchOption != 'P' && selectedRows && selectedRows.length > 0) {
            console.log('Reached');
            component.set("v.btPlans", []);
            component.set("v.selectedBTPlanId", "");
            component.set("v.btSubmitted", false);

            var selectedCard = selectedRows[0];
            component.set("v.selectedCardId", selectedCard.id);

            helper.loadBTPlans(component, selectedCard);
        }
        // ==================== END NEW LOGIC ====================
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

        if ("refresh" === action) {
            // reload card list and reset selection
            component.set('v.selectedCardId', undefined);
            component.find('cardsListTable').set("v.selectedRows", []);
            helper.loadData(component, customerId);
        }
    },
    //CH05: Start
    onChangeOption: function (component, event, helper) {
        console.log('onChangeSelectedCardId !!');
        component.set('v.selectedCardId', null);
    },
    //CH05: END

    handleBTPlanSelection: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        if (selectedRows && selectedRows.length > 0) {
            var selectedPlan = selectedRows[0];
            component.set("v.selectedBTPlan", selectedPlan);
            // Enable submit buttons since a row is selected
            component.set("v.btSubmitted", false);
        } else {
            component.set("v.selectedBTPlan", null);
            // Disable submit buttons when no row is selected
            component.set("v.btSubmitted", true);
        }
    },

    handleBTSubmit: function (component, event, helper) {
        // Check if at least one row is selected
        var selectedPlan = component.get("v.selectedBTPlan");
        if (!selectedPlan) {
            helper.showToast("Error", "Please select a BT plan to submit", "error");
            return;
        }

        // Get the current case record
        var caseId = component.get("v.caseId") || (event.getParam("arguments") && event.getParam("arguments").recordId);;
        console.log('recordId --->',caseId);
        if (!caseId) {
            helper.showToast("Error", "Case record not found", "error");
            return;
        }

        // Disable the buttons and table
        component.set("v.btSubmitted", true);

        // Store the selected BT plan details in case fields or attribute for reference
        component.set("v.selectedBTPlanNumber", selectedPlan.planNumber);
        component.set("v.selectedBTSequenceNumber", selectedPlan.sequenceNumber);
        component.set("v.selectedBTPlanBalance", selectedPlan.remainingBalance);

        console.log('PlanNumber --->',selectedPlan.planNumber);
        console.log('SequenceNumber --->',selectedPlan.sequenceNumber);
        console.log('PlanBalance --->',selectedPlan.remainingBalance);
        console.log('selectedPlan --->',JSON.stringify(selectedPlan));
        console.log('pciNumber --->',component.get('v.pciNumber'));

        var updateCase = {
            Id: caseId,
            cc_Maker__c: 'Send to Checker',
            cc_PCI_Id__c: component.get('v.pciNumber'),
            cc_Balance_Transfer_Card_Number__c: selectedPlan.planNumber,
            cc_Balance_Transfer_Reference_Number__c: selectedPlan.sequenceNumber
        };

        helper.updateCaseRecord(component, updateCase, function (result) {
            if (result.success) {
                helper.showToast("Success", "Case sent to Checker queue for review", "success");
                // Optionally navigate back or refresh
                setTimeout(function () {
                    $A.get('e.force:refreshView').fire();
                }, 2000);
            } else {
                helper.showToast("Error", result.message || "Failed to update case", "error");
                component.set("v.btSubmitted", false);
            }
        });
    },

    handleCancelledByCustomer: function (component, event, helper) {
        // Check if at least one row is selected
        var selectedPlan = component.get("v.selectedBTPlan");
        if (!selectedPlan) {
            helper.showToast("Error", "Please select a BT plan to cancel", "error");
            return;
        }

        var caseId = component.get("v.caseId");
        if (!caseId) {
            helper.showToast("Error", "Case record not found", "error");
            return;
        }

        // Disable the buttons
        component.set("v.btSubmitted", true);

        // Set Maker result to 'Cancelled by Customer'
        var updateCase = {
            Id: caseId,
            cc_Maker__c: 'Cancelled by Customer'
        };

        helper.updateCaseRecord(component, updateCase, function (result) {
            if (result.success) {
                helper.showToast("Success", "Case has been cancelled as requested by customer", "success");
                setTimeout(function () {
                    $A.get('e.force:refreshView').fire();
                }, 2000);
            } else {
                helper.showToast("Error", result.message || "Failed to update case", "error");
                component.set("v.btSubmitted", false);
            }
        });
    }
})
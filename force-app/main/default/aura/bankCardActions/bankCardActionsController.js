({
    init : function(component, event, helper) {
        console.log('Selected Card Id ===>', component.get('v.selectedCardId'));
       /* var options = [
        {'label': 'CANCEL (Only for upgrades by mistake)', 'value': 'Cancel', 'helpText':'This action will cancel your card'},
        {'label': 'Report Lost Card', 'value': 'Lost', 'helpText':'This action will block the card and issue a new card'},
        {'label': 'Report Stolen Card', 'value': 'Stolen', 'helpText':'This action will block the card and issue a new card'},
        {'label': 'Report Damaged Card', 'value': 'Damaged', 'helpText':'This action will issue a new card'},
        {'label': 'Issue New Card', 'value': 'New Card', 'helpText':'This action will issue a new card'},
        // {'label': 'Upgrade Card', 'value': 'Upgrade', 'helpText':'This will provide the customer with the upgraded card after they have paid the upgrade fee'},
        // {'label': 'Downgrade Card', 'value': 'Downgrade', 'helpText':'Inform customer this will take place when the 12 month subscription runs out'},
        {'label': 'Freeze Card', 'value': 'Freeze', 'helpText':''},
        {'label': 'Unfreeze Card', 'value': 'Unfreeze', 'helpText':''},
        {'label': 'Link Card to Bank Account', 'value': 'Link Account', 'helpText':''},
        {'label': 'Delink Card from Bank Account', 'value': 'Delink Account', 'helpText':''},
        {'label': 'Upgrade / Downgrade Card', 'value': 'Segment Upgrade Downgrade', 'helpText':''},
        ]; */

        //#CH02 : by Aniss : Debit+Card+Enhancement+P2
        component.find('apexService').request(component.get('c.visibilityOptionsCheck'), {
            caseId: component.get('v.caseId'),
        },
        function(response) {
            var result = response.getReturnValue();
            var caseStatus = result.Status; 
            var profileName = result.Profile;
            component.set("v.caseStatus",caseStatus);
            component.set("v.profileName",profileName);
            component.set("v.personEmail",result.PersonEmail);
            component.set("v.regionName",result.Region);

            if(caseStatus != 'Closed'){
                var options = [
                    {'label': 'CANCEL (Only for upgrades by mistake)', 'value': 'CARD_CANCELLED', 'helpText':'This action will cancel your card'},
                    {'label': 'Report Lost Card (With Replacement Fee)', 'value': 'LOST_WITH_CARD_REPLACEMENT_WithFee', 'helpText':'This action will block the card and issue a new card'},
                    {'label': 'Report Stolen Card (With Replacement Fee)', 'value': 'STOLEN_WITH_CARD_REPLACEMENT_WithFee', 'helpText':'This action will block the card and issue a new card'},
                    {'label': 'Report Damaged Card (With Replacement Fee)', 'value': 'DAMAGED_WITH_CARD_REPLACEMENT_WithFee', 'helpText':'This action will issue a new card'},
                    {'label': 'User Freeze Card', 'value': 'Freeze', 'helpText':''},
                    {'label': 'User Unfreeze Card', 'value': 'Unfreeze', 'helpText':''},
                    {'label': 'Link Card to Bank Account', 'value': 'Link Account', 'helpText':''},
                    {'label': 'Delink Card from Bank Account', 'value': 'Delink Account', 'helpText':''},
                    {'label': 'Upgrade / Downgrade Card', 'value': 'Segment Upgrade Downgrade', 'helpText':''}
                ];

                if( profileName != null && ( profileName.includes('Admin') || profileName == 'RMT' || profileName == 'ila Risk') ){
                    var options2 = [
                        {'label': 'Bank Block (Report Fraud Card)', 'value': 'TEMPORARY_BLOCKED', 'helpText':''},
                        {'label': 'Bank Unblock', 'value': 'UNBLOCK', 'helpText':''},
                        {'label': 'Report Lost Card (Without Replacement Fee)', 'value': 'LOST_WITH_CARD_REPLACEMENT', 'helpText':''},
                        {'label': 'Report Stolen Card (Without Replacement Fee)', 'value': 'STOLEN_WITH_CARD_REPLACEMENT', 'helpText':''},
                        {'label': 'Report Damaged Card (Without Replacement Fee)', 'value': 'DAMAGED_WITH_CARD_REPLACEMENT', 'helpText':''}
                    ];
                    options  = options.concat(options2);
                }

                component.set('v.cardActionTypeOptions', options);
            }
        });
        
        //#CH02 - End 


        //helper.loadCardDetails(component, component.get('v.customerId'), component.get('v.cardId'));
        var customerId = component.get('v.customerId');
        if (customerId) {
            helper.loadAccountList(component, customerId);
        }
	},
    onSubmitClick : function(component, event, helper) {
        //customerId, cardId, caseId, reason
        //CH03 Added by Aniss Mbarki 16-03-2023
        console.log("onSubmitClick clicked");
        component.set('v.isSubmited',true);
        //CH03 End
        var selectedCardActionType = component.get('v.selectedCardActionType');
        if ($A.util.isEmpty(selectedCardActionType)) {
            component.find('apexService').showErrorMessage("Action is required");
            return;
        }
        var customerId = component.get('v.customerId');
        var account = component.get('v.account');
        var cardDetails = component.get('v.cardDetails');
        var reason =  component.get('v.reason');
        var caseId = component.get('v.caseId');
        var regionName = component.get('v.regionName');
        component.set('v.productType', cardDetails.productType);
        
        var blockCardData = {};
        blockCardData["cardId"] = cardDetails.id;
        blockCardData["reason"] = $A.util.isEmpty(reason) ? selectedCardActionType : reason;
        blockCardData["actionType"] = 'Block ' + selectedCardActionType;
        blockCardData["maskedCardNumber"] = cardDetails.maskedCardNumber;

        if (['LOST_WITH_CARD_REPLACEMENT_WithFee', 'LOST_WITH_CARD_REPLACEMENT',
             'STOLEN_WITH_CARD_REPLACEMENT_WithFee', 'STOLEN_WITH_CARD_REPLACEMENT',
             'Upgrade', 'Downgrade'].indexOf(selectedCardActionType) >=0 ) {
            console.log("selectedCardActionType", selectedCardActionType);

            var deliveryType = component.get('v.deliveryType');
            if ($A.util.isEmpty(deliveryType)) {
                component.find('apexService').showErrorMessage("Delivery Type is required");
                return;
            }
            if ('LOST_WITH_CARD_REPLACEMENT_WithFee' === selectedCardActionType ) {
                blockCardData["reason"] = 'LOST_WITH_CARD_REPLACEMENT';
                blockCardData["collectFee"] = true;
                helper.processLostCard(component, customerId, blockCardData, caseId, account);
                return;
            }else if('LOST_WITH_CARD_REPLACEMENT' === selectedCardActionType){
                blockCardData["collectFee"] = false;
                helper.processLostCard(component, customerId, blockCardData, caseId, account);
                return;
            } else if ('STOLEN_WITH_CARD_REPLACEMENT_WithFee' === selectedCardActionType) {
                blockCardData["reason"] = 'STOLEN_WITH_CARD_REPLACEMENT';
                blockCardData["collectFee"] = true;
                helper.processStolenCard(component, customerId, blockCardData, caseId, account);
                return;
            } else if ('STOLEN_WITH_CARD_REPLACEMENT' === selectedCardActionType) {
                blockCardData["collectFee"] = false;
                helper.processStolenCard(component, customerId, blockCardData, caseId, account);
                return;
            } else if ('Upgrade' === selectedCardActionType) {
                var productType = component.get('v.productType');
                if ($A.util.isEmpty(productType)) {
                    component.find('apexService').showErrorMessage("Product Type is required");
                    return;
                }
                helper.processCardUpgrade(component, customerId, blockCardData, caseId, account);
                return;

            } else if ('Downgrade' === selectedCardActionType) {
                var productType = component.get('v.productType');
                if ($A.util.isEmpty(productType)) {
                    component.find('apexService').showErrorMessage("Product Type is required");
                    return;
                }
                helper.processCardDowngrade(component, customerId, blockCardData, caseId, account);
                return;

            }

        } else if ('CARD_CANCELLED' === selectedCardActionType) {
            blockCardData["reason"] = 'Cancelled';
            helper.cancelCard(component, customerId, blockCardData, caseId, account);
            return;
        } else if ('DAMAGED_WITH_CARD_REPLACEMENT_WithFee' === selectedCardActionType) {
                blockCardData["reason"] = 'DAMAGED_WITH_CARD_REPLACEMENT';
                blockCardData["collectFee"] = true;
                helper.processDamagedCard(component, customerId, blockCardData, caseId, account);
                return;
		} else if ('DAMAGED_WITH_CARD_REPLACEMENT' === selectedCardActionType) {
                blockCardData["collectFee"] = false;
                helper.processDamagedCard(component, customerId, blockCardData, caseId, account);
                return;
		} else if ('New Card' === selectedCardActionType) {
                helper.processIssueNewCard(component, customerId, caseId, account);
                return;
        } else if ('Freeze' === selectedCardActionType ) {
            blockCardData["actionType"] = 'Freeze Card';
            blockCardData["cardStatus"] = 'Freeze';
            blockCardData["isCaseClosureRequired"] = true;
            blockCardData["caseType"] = (regionName=='Bahrain')?'Cards':'Card Service';
            blockCardData["caseSubType"] = (regionName=='Bahrain')?'Card Control':'Freeze/Unfreeze Card';
            helper.changeCardStatus(component, customerId, blockCardData, caseId, account);
            return;
        } else if ( 'Unfreeze' === selectedCardActionType ) {
            blockCardData["actionType"] = 'Unfreeze Card';
            blockCardData["cardStatus"] = 'Unfreeze';
            blockCardData["isCaseClosureRequired"] = true;
            blockCardData["caseType"] = (regionName=='Bahrain')?'Cards':'Card Service';
            blockCardData["caseSubType"] = (regionName=='Bahrain')?'Card Control':'Freeze/Unfreeze Card';
            helper.changeCardStatus(component, customerId, blockCardData, caseId, account);
            return;
        } else if ( 'Link Account' === selectedCardActionType ) {
            var selectedAccountId = component.get('v.selectedAccountId');
            if ($A.util.isEmpty(selectedAccountId)) {
                component.find('apexService').showErrorMessage("Account is required");
                return;
            }
            blockCardData["actionType"] = 'Link Card'; //for System_Action__c
            blockCardData["action"] = 'Link'; //for API call
            blockCardData["accountId"] = selectedAccountId;
            blockCardData["isCaseClosureRequired"] = true;
            blockCardData["caseType"] = 'Card Service';
            blockCardData["caseSubType"] = 'Link/ Delink Card';
            helper.changeCardAccountAssociation(component, customerId, blockCardData, caseId, account);
            return;
        } else if ( 'Delink Account' === selectedCardActionType ) {
            var selectedAccountId = component.get('v.selectedAccountId');
            if ($A.util.isEmpty(selectedAccountId)) {
                component.find('apexService').showErrorMessage("Account is required");
                return;
            }
            blockCardData["actionType"] = 'Delink Card'; //for System_Action__c
            blockCardData["action"] = 'Unlink'; //for API call
            blockCardData["accountId"] = selectedAccountId;
            blockCardData["isCaseClosureRequired"] = true;
            blockCardData["caseType"] = 'Card Service';
            blockCardData["caseSubType"] = 'Link/ Delink Card';
            helper.changeCardAccountAssociation(component, customerId, blockCardData, caseId, account);
            return;
        } else if("Segment Upgrade Downgrade" === selectedCardActionType){
            console.log('>>>>>>>>>>>>>', component.get("v.curSegSelected"));
            console.log('>>>>>>>>>>>>>', component.get("v.disSegSelected"));
            console.log('>>>>>>>>>>>>>', component.get("v.segmentEmbossName"));
            
            var isUpgrading = helper.isUpgradingSegment(component);
            var selectedDiscount = component.get("v.disSegSelected");
            var isUserAuthorized = component.get("v.isUserAuthorizedForDiscount");
            
            console.log('isUpgrading>>>>>>>>>>>>>', isUpgrading);
            console.log('selectedDiscount>>>>>>>>>>>>>', selectedDiscount);
            console.log('isUserAuthorized>>>>>>>>>>>>>', isUserAuthorized);
            
            console.log('skipped>>>>>>>>>>>>>');
            
            helper.updateSegment(component, customerId);
            return;
        } else if(['TEMPORARY_BLOCKED', 'UNBLOCK'].indexOf(selectedCardActionType) >=0 ){
            var isSuccess = function() {
                helper.refreshScreen(component, helper);
            }
            helper.blockCard(component, customerId, blockCardData, caseId, isSuccess, account);
            return;
        }
        component.find('apexService').showWarningMessage("Support for this action is Not implemented");
    },
    onActionSelectionChange : function(component, event, helper) {
        var options = component.get('v.cardActionTypeOptions');
        var selectedCardActionType = component.get('v.selectedCardActionType');
        var selectedOption = options.find(function(option) {
            return option.value === selectedCardActionType;
        })
        if (selectedOption && !$A.util.isEmpty(selectedOption.helpText)) {
            component.set('v.selectedActionHelpText', selectedOption.helpText);

        } else {
            component.set('v.selectedActionHelpText', undefined);
        }

        var showDeliveryTypeSelector = false;
        var showProductTypeSelector = false;
        var showLinkedAccountsSelector = false;
        var showAccountsToLinkToSelector = false;
        var showUpgradeDowngrade = false;

        //#CH02 by Aniss 

        if (['LOST_WITH_CARD_REPLACEMENT', 'STOLEN_WITH_CARD_REPLACEMENT', 'DAMAGED_WITH_CARD_REPLACEMENT',
             'LOST_WITH_CARD_REPLACEMENT_WithFee', 'STOLEN_WITH_CARD_REPLACEMENT_WithFee', 'DAMAGED_WITH_CARD_REPLACEMENT_WithFee',
              'New Card'].indexOf(selectedCardActionType) >=0 ) {
            showDeliveryTypeSelector = true;
            console.log('Selected Card Id not on init ===>', component.get('v.selectedCardId'));
            var customerId = component.get('v.customerId');
            var personEmail = component.get('v.personEmail');
            var regionName = component.get('v.regionName');
            
            if (customerId && personEmail && regionName) {
                helper.loadCardList(component, customerId, personEmail, regionName);
            }
        }
        if (['Downgrade', 'DAMAGED_WITH_CARD_REPLACEMENT', 'DAMAGED_WITH_CARD_REPLACEMENT_WithFee', 'New Card'].indexOf(selectedCardActionType) >=0 ) {
            showProductTypeSelector = true;
            component.set('v.productType', 'CLASSIC');
        }
        if ('Upgrade' == selectedCardActionType) {
            showProductTypeSelector = true;
            component.set('v.productType', 'PREMIUM');
        }
        if ('Link Account' == selectedCardActionType) {
            component.set('v.accountsToLinkOptions', helper.getAccountOptionsToLinkTo(component));
            showAccountsToLinkToSelector = true;
        }
        if ('Delink Account' == selectedCardActionType) {
            component.set('v.linkedAccountOptions', helper.getLinkedAccountOptions(component));
            showLinkedAccountsSelector = true;
        }
        if ('Segment Upgrade Downgrade' == selectedCardActionType) {
            helper.getSegmentOptionsCRM(component);
            showUpgradeDowngrade = true;
        }


        component.set('v.showDeliveryTypeSelector', showDeliveryTypeSelector);
        component.set('v.showProductTypeSelector', showProductTypeSelector);
        component.set('v.showLinkedAccountsSelector', showLinkedAccountsSelector);
        component.set('v.showAccountsToLinkToSelector', showAccountsToLinkToSelector);
        component.set('v.showUpgradeDowngrade', showUpgradeDowngrade);
    },


})
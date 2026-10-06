/* 		
 * 		Change History:
 *			   #CH01# #MBARKI ANISS# #09-08-2022# Add targetType param  & "Reactivate Dormant Card" Logic
 *			   #CH02# #Jahangeer Mohammed #19-08-2024# setting isClosed attribute onSubmit Click to disable the button(PI-3506)
 			   #CH03# #Jahangeer Mohammed# #19-08-2025# Added Masked Card Number(NBA-15639)
 */
({
    init : function(component, event, helper) {
        console.log('Card Action Component Loaded');
        
        helper.getCaseDetails(component, event, helper);

        var customerId = component.get('v.customerId');
        if (customerId) {
            helper.loadAccountList(component, customerId);
        }
        
	},
    //CH03: Start
    handleCardDetailsChange : function(component, event, helper) {
        var cardDetails = component.get('v.cardDetails');
        // Check if cardDetails is not null and has actual data
        if(cardDetails && cardDetails !== null && Object.keys(cardDetails).length > 0){
            console.log("Card PCI Number in change handler", JSON.stringify(cardDetails));
            // Check if PCI number exists in the card details
            if(cardDetails.pciNumber && cardDetails.cmsAccountId){
                console.log("PCI Number:", cardDetails.pciNumber);
                console.log("Mask Card Number:", cardDetails.cmsAccountId);
                var caseId = component.get('v.caseId');
                var pciNumber = cardDetails.pciNumber;
                var mskCardNumber = cardDetails.cmsAccountId;
                helper.updatePCIAndMaskCardNoCase(component,caseId,pciNumber,mskCardNumber);
            }
         }
         else{
            console.log("Card details is empty or null in change handler");
         }
        
    },
    //CH03: END
    onSubmitClick : function(component, event, helper) {
        //customerId, cardId, caseId, reason
        console.log('card Action type:'+component.get('v.selectedCardActionType'));
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

        //#CH01 :Start
        var targetType = component.get('v.targetType');
        console.error('onSubmit TargetType <<<<<<<< '+targetType);
        //#CH01 :End

      //  component.set('v.productType', cardDetails.productType);
      
        var blockCardData = {};
        blockCardData["cardId"] = cardDetails.pciNumber;
        blockCardData["reason"] = $A.util.isEmpty(reason) ? selectedCardActionType : reason;
       // blockCardData["actionType"] = 'Block ' + selectedCardActionType;
        blockCardData["maskedCardNumber"] = cardDetails.maskedCardNumber;

		if (selectedCardActionType === 'Cancel') {
            blockCardData["reason"] = 'Cancelled';
            helper.creditCardFCR(component, customerId, blockCardData, caseId, account);

            return;
        }
		else if (selectedCardActionType === 'Freeze') {
            blockCardData["actionType"] = 'Freeze Card';
            blockCardData["cardStatus"] = 'Freeze';
            blockCardData["isCaseClosureRequired"] = true;
            blockCardData["caseType"] = 'Credit Card FCR';
            blockCardData["caseSubType"] = 'Freeze / Unfreeze Card';
            helper.creditCardFCR(component, customerId, blockCardData, caseId, account);
            //CH02:Start
            component.set("v.isClosed",true);
            //CH02: END
            helper.successmessageHelper(component);
            return;
        } else if ( selectedCardActionType === 'Unfreeze') {
            blockCardData["actionType"] = 'Unfreeze Card';
            blockCardData["cardStatus"] = 'Unfreeze';
            blockCardData["isCaseClosureRequired"] = true;
            blockCardData["caseType"] = 'Credit Card FCR';
            blockCardData["caseSubType"] = 'Freeze / Unfreeze Card';
            helper.creditCardFCR(component, customerId, blockCardData, caseId, account);
            //CH02:Start
            component.set("v.isClosed",true);
            //CH02: END
            helper.successmessageHelper(component);
            return;
        } else if( selectedCardActionType === 'temporaryBlock'){
            console.log('selectedCardActionType: '+selectedCardActionType);
            blockCardData["actionType"] = 'temporaryBlock';
            blockCardData["cardStatus"] = 'Active';
            blockCardData["isCaseClosureRequired"] = true;
            blockCardData["caseType"] = 'Credit Card FCR';
            blockCardData["reason"] = component.get("v.selectedReason");
            blockCardData["caseSubType"] = 'Block/ Unblock Card';
            //#CH01 :Start
            blockCardData["targetType"] = targetType;
            //#CH01 :End
            helper.creditCardFCR(component, customerId, blockCardData, caseId, account);
            //CH02:Start
            component.set("v.isClosed",true);
            //CH02: END
            helper.successmessageHelper(component);
            return;
        } else if( selectedCardActionType === 'Unblock'){
            console.log('selectedCardActionType: '+selectedCardActionType);
            blockCardData["actionType"] = 'Unblock';
            blockCardData["cardStatus"] = 'Unblock';
            blockCardData["isCaseClosureRequired"] = true;
            blockCardData["caseType"] = 'Credit Card FCR';
            blockCardData["caseSubType"] = 'Block/ Unblock Card';
            //#CH01 :Start
            blockCardData["targetType"] = targetType;
            //#CH01 :End
            helper.creditCardFCR(component, customerId, blockCardData, caseId, account);
            //CH02:Start
            component.set("v.isClosed",true);
            //CH02: END
            helper.successmessageHelper(component);
            return;
        }
        else if( selectedCardActionType === 'ReplaceCard'){
            console.log('selectedCardActionType: '+selectedCardActionType);
            blockCardData["actionType"] = 'Replace Card';
            blockCardData["cardStatus"] = 'replace';
            blockCardData["isCaseClosureRequired"] = true;
            blockCardData["caseType"] = 'Credit Card FCR';
            blockCardData["reason"] = component.get("v.selectedReason");
            blockCardData["caseSubType"] = 'Replace Card';
            //#CH01 :Start
            blockCardData["targetType"] = targetType;
             
            //#CH01 :End
            helper.creditCardFCR(component, customerId, blockCardData, caseId, account);
           //CH02:Start
            component.set("v.isClosed",true);
            //CH02: END
            helper.successmessageHelper(component);
            return;
        }
        //#CH01 :Start
        else if( selectedCardActionType === 'ReactivateDormantCard'){
            console.log('selectedCardActionType: '+selectedCardActionType);
            blockCardData["actionType"] = 'ReactivateDormantCard';
            blockCardData["cardStatus"] = 'ACTIVATE_DORMANT';
            blockCardData["isCaseClosureRequired"] = true;
            blockCardData["caseType"] = 'Credit Card FCR';
            blockCardData["caseSubType"] = 'Reactivate Dormant Card';
            helper.creditCardFCR(component, customerId, blockCardData, caseId, account);
            //CH02:Start
            component.set("v.isClosed",true);
            //CH02: END
            helper.successmessageHelper(component);
            return;
        }
        //#CH01 :End


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

    },


})
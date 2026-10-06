/* 		
 * 		Change History: 	
 *              #CH01# : added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product	
 */
({

   // loadAccountList : function(component, customerId, cardId) {
    loadAccountList : function(component, customerId) {
        var account = component.get('v.account');
        //CH01 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product	
        var regionName = account.Region_Flag__c;	
        if(component.get('v.isAlburaqProduct') == true){	
            regionName += '_alburaq';	
        }	
        //CH01 -End
		component.find('apexService').request(component.get('c.loadAccountList'), {
		    customerId: customerId,
		    regionName: regionName
        },
		function(response) {
		    var result = response.getReturnValue();
            var data = [];
            var accounts = [];
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData.accounts)) {
                accounts = result.responseData.accounts;
            }

            for (var i = 0; i < accounts.length; i++) {
                var accountObj = accounts[i];
                var obj = {
                    'id': accountObj.id,
                    'iban': accountObj.account.iban,
                    'alias': accountObj.alias,
                    'number': accountObj.account.number
                };
                data.push(obj);
            }
            component.set('v.allCustomerAcounts', data);
		});
	},
    getAccountOptionsToLinkTo: function(component) {
        var allCustomerAcounts = component.get('v.allCustomerAcounts');
        var options = [];

        for (var i = 0; i < allCustomerAcounts.length; i++) {
            var account = allCustomerAcounts[i];
            options.push({'value': account.iban, 'label': account.alias + ' (' + account.number + ')'});
        }
        return options;
    },

    getLinkedAccountIds: function(component) {
        var cardDetails = component.get('v.cardDetails');
        if (cardDetails && !$A.util.isEmpty(cardDetails.linkedAccounts)) {
            var linkedAccounts = cardDetails.linkedAccounts;

            if (1 == cardDetails.linkedAccounts.length) {
                // fix linkedAccounts value
                // (Mock API returns it in the wrong format: array with a single string: ["12345, 67890"]
                //instead of array of strings: ["12345", "67890"]
                linkedAccounts = cardDetails.linkedAccounts[0].split(",");
            }
            return linkedAccounts;
        }
        return [];
    },
    getAccountDataById: function(component, accountNumber) {
        var allCustomerAcounts = component.get('v.allCustomerAcounts');
        var account = allCustomerAcounts.find(function(obj) { return obj.number == accountNumber});
        return account;
    },

    getLinkedAccountOptions: function(component) {
        var helper = this;

        var linkedAccounts = helper.getLinkedAccountIds(component);

        var options = [];

        for (var i = 0; i < linkedAccounts.length; i++) {
            var num = linkedAccounts[i];
            var label = num;
            var account = helper.getAccountDataById(component, num);
            if (account) {
                label = account.alias + ' (' + account.number + ')';
                num = account.iban;
            }
            options.push({'value': num, 'label': label});
        }
        return options;
    },

    getSegmentOptionsCRM: function(cmp){
    var customerId = cmp.get('v.customerId');
    var caseId = cmp.get("v.caseId");
    
    //CH01 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product
    var account = cmp.get('v.account');
    var regionName = account.Region_Flag__c;
    if(cmp.get('v.isAlburaqProduct') == true){
        regionName += '_alburaq';
    }
    //CH01 -End

    cmp.find('apexService').request(cmp.get('c.loadSegmentOptionsCRM'), {
        customerId: customerId,
        caseId: caseId,
        regionName : regionName
    },
    function(response) {
        var result = response.getReturnValue();
        console.log("result", result);

        if (result.isSuccess === true && !$A.util.isEmpty(result.responseData)) {
            // Store user authorization and segment info
            cmp.set("v.isUserAuthorizedForDiscount", result.responseData.isUserAuthorizedForDiscount || false);
            cmp.set("v.isPremiumSegment", result.responseData.isPremiumSegment || false);

            // Generate segment options
            var lstSegOpts = result.responseData.segmentOptions ? result.responseData.segmentOptions : [];
            var segOpts = [];
            lstSegOpts.forEach(segOpt => {
                segOpts.push({label: segOpt.segmentName, value: segOpt.segmentCrmId});
            });

            // Generate card options
            var lstCardOpts = result.responseData.cardOptions ? result.responseData.cardOptions : [];
            var cardOpts = [];
            lstCardOpts.forEach(cardOpt => {
                cardOpts.push({label: cardOpt.cardDisplayName, value: cardOpt.productType})
            });

            // NEW: Determine if this is an upgrade scenario
            var currentSegment = result.responseData.currentSegment ? result.responseData.currentSegment.segmentName : '';
            var isUpgradeScenario = currentSegment.toUpperCase() === 'REGULAR';
            
            // NEW: Filter discount options based on user authorization AND scenario
            var lstDisOpts = result.responseData.discountOptions ? result.responseData.discountOptions : [];
            var disOpts = [];
            
            if (isUpgradeScenario) {
                if (result.responseData.isUserAuthorizedForDiscount) {
                    // Authorized users see all discounts during upgrades
                    lstDisOpts.forEach(disOpt => {
                        disOpts.push({label: disOpt.displayName, value: disOpt.value})
                    });
                } else {
                    // Unauthorized users only see "No discount" option during upgrades
                    var noDiscountOption = lstDisOpts.find(function(disOpt) {
                        return disOpt.name === 'NO_DISCOUNT' || disOpt.value === 'None' || 
                               disOpt.displayName === 'No Discount' || disOpt.label === 'No Discount';
                    });
                    
                    if (noDiscountOption) {
                        disOpts.push({label: noDiscountOption.displayName || noDiscountOption.label, 
                                     value: null});
                    } else if (lstDisOpts.length > 0) {
                        // Fallback: use first option as "No discount"
                        disOpts.push({label: 'No Discount', value: 'None'});
                    } else {
                        // If no discount options available at all, add "No Discount"
                        disOpts.push({label: 'No Discount', value: 'None'});
                    }
                }
            }
            // During downgrades, disOpts will be empty (no discounts shown)

            // NEW: Set flag to control UI visibility
            cmp.set("v.showDiscountDropdown", isUpgradeScenario && disOpts.length > 0);

            cmp.set("v.segmentCardOpts", cardOpts);
            cmp.set("v.segmentCurCards", result.responseData.currentCards ? result.responseData.currentCards : []);
            cmp.set("v.segmentCurrent", result.responseData.currentSegment ? result.responseData.currentSegment : {});
            cmp.set("v.segmentDisOpts", disOpts);
            cmp.set("v.segmentOpts", segOpts);
            cmp.set("v.segmenttransitionInProgress", result.responseData.transitionInProgress ? result.responseData.transitionInProgress : false);

        }
    });
},

    cancelCard : function(component, customerId, blockCardData, caseId, account) {
        var helper = this;

        var isSuccess = function() {
            helper.refreshScreen(component, helper);
        }
        helper.blockCard(component, customerId, blockCardData, caseId, isSuccess, account);
    },

    processLostCard : function(component, customerId, blockCardData, caseId, account) {
        var helper = this;

        var issueNewCardFun = function() {
            //CH02 START : comment this function 
            /* var extraParameters = {
                isCaseClosureRequired: true,
                systemActionType: 'Lost Card',
                caseType: 'Card Service',
                caseSubType: 'Lost/Stolen Card'
            }
            */
            //helper.requestNewCard(component, customerId, /*cardId=*/undefined, caseId, extraParameters, account);
            //CH02 :END
        }
        var isSuccess = function() {
            helper.refreshScreen(component, helper);
        }
        
        helper.blockCard(component, customerId, blockCardData, caseId, /* issueNewCardFun */isSuccess, account);
    },

    processStolenCard : function(component, customerId, blockCardData, caseId, account) {
        var helper = this;

        var issueNewCardFun = function() {
            //CH02 START : comment this function 
            /* var extraParameters = {
                isCaseClosureRequired: true,
                systemActionType: 'Stolen Card',
                caseType: 'Card Service',
                caseSubType: 'Lost/Stolen Card'
            } */
            //helper.requestNewCard(component, customerId, /*cardId=*/undefined, caseId, extraParameters, account);
            //CH02 :END
        }
        var isSuccess = function() {
            helper.refreshScreen(component, helper);
        }
        helper.blockCard(component, customerId, blockCardData, caseId, /* issueNewCardFun */isSuccess, account);
    },
    processDamagedCard : function(component, customerId, blockCardData, caseId, account) {
        //CH02 : Start
        //old code
        //commented code by SP: For Damage Care, we will call to request new card only one
        //Date 07/10/19
        var helper = this;
        var issueNewCardFun = function() {
            //CH02 START : comment this function 
            /* var cardId = blockCardData.cardId;
            var extraParameters = {
                isCaseClosureRequired: true,
                systemActionType: 'Damaged Card',
                caseType: 'Card Service',
                caseSubType: 'Damaged Card'
            }
            helper.requestNewCard(component, customerId, cardId, caseId, extraParameters, account); */
            //CH02 :END
        }
        var isSuccess = function() {
            helper.refreshScreen(component, helper);
        }
        helper.blockCard(component, customerId, blockCardData, caseId, /* issueNewCardFun */isSuccess, account);
        //CH02 END

        //add by sp
        //Date 07/10/19
        /* var cardId = blockCardData.cardId;
        var extraParameters = {
            isCaseClosureRequired: true,
            systemActionType: 'Damaged Card',
            caseType: 'Card Service',
            caseSubType: 'Damaged Card'
        }
        console.log("processDamagedCard.......");
        this.requestNewCard(component, customerId, cardId, caseId, extraParameters, account); */
    },

    processIssueNewCard : function(component, customerId, caseId, account) {

        var extraParameters = {
            isCaseClosureRequired: true,
            systemActionType: 'Issue New Card',
        }
        console.log("processIssueNewCard.......");
        this.requestNewCard(component, customerId, undefined, caseId, extraParameters, account);
    },

    processCardUpgrade : function(component, customerId, blockCardData, caseId, account) {
        var helper = this;

        var cardId = undefined;//blockCardData.cardId;
        var extraParameters = {
            isCaseClosureRequired: true,
            systemActionType: 'Upgrade Card',
            caseType: 'Card Service',
            caseSubType: 'Upgrade/Downgrade Card'
        }
        helper.requestNewCard(component, customerId, cardId, caseId, extraParameters, account);
    },
    processCardDowngrade : function(component, customerId, blockCardData, caseId, account) {
        var helper = this;

        var cardId = undefined;//blockCardData.cardId;
        var extraParameters = {
            isCaseClosureRequired: true,
            systemActionType: 'Downgrade Card',
            caseType: 'Card Service',
            caseSubType: 'Upgrade/Downgrade Card'
        }
        helper.requestNewCard(component, customerId, cardId, caseId, extraParameters, account);
    },

    blockCard : function(component, customerId, blockCardData, caseId, onSuccessCallback, account) {
        var helper = this;
        	
        //CH01 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product	
        var regionName = account.Region_Flag__c;	
        if(component.get('v.isAlburaqProduct') == true){	
            regionName += '_alburaq';	
        }	
        //CH01 -End

        component.find('apexService').request(component.get('c.blockCard'), {
            customerId: customerId,
            blockCardData: JSON.stringify(blockCardData),
            caseId: caseId,
            personEmail: account.PersonEmail,
            regionName: regionName
        },
        function(response) {
            var result = response.getReturnValue();
            var data = [];
            if (true === result.isSuccess ) {
                component.set('v.reason', undefined);
                // refresh cards list
                //helper.requestCardListRefresh(component);

                if (!$A.util.isEmpty(onSuccessCallback)) {
                    onSuccessCallback();
                }
            }
        });
	},

    requestNewCard : function(component, customerId, cardId, caseId, extraParameters, account) {
        var helper = this;
        var existingCardDetails = component.get('v.cardDetails');
        var deliveryType = component.get('v.deliveryType');
        var productType = component.get('v.productType');
        var accountId = component.get('v.accountId');
        if ($A.util.isEmpty(accountId)) {
            //if accountId is not fetched (account is not selected in another tab) than default accountID is sent to issuance API
            accountId = existingCardDetails.defaultAccount;
        }

        if ($A.util.isEmpty(productType)) {
            // if product type is not selected then use existing card product type
            productType = existingCardDetails.productType;
        }

        var requestData = {
            accountId: existingCardDetails.defaultAccount,
            //accountId :  accountId,
            productType: productType,
            cardType:  existingCardDetails.cardType,
            deliveryType: deliveryType,
            status: "Inactive",
        }
        if (!$A.util.isEmpty(cardId)) {
            requestData["cardId"] = cardId;
        }
        //CH01 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product	
        var regionName = account.Region_Flag__c;	
        if(component.get('v.isAlburaqProduct') == true){	
            regionName += '_alburaq';	
        }	
        //CH01 -End
        component.find('apexService').request(component.get('c.requestNewCard'), {
            customerId: customerId,
            requestTextJson: JSON.stringify(requestData),
            maskedCardNumber: existingCardDetails.maskedCardNumber,
            caseId: caseId,
            extraParameters: JSON.stringify(extraParameters),
            personEmail: account.PersonEmail,
            regionName: regionName
        },
        function(response) {
            var result = response.getReturnValue();
            console.log("result.......", result);
            var data = [];
            if (true === result.isSuccess ) {
                helper.refreshScreen(component, helper);
            }
        });
	},
    requestCardListRefresh: function(component) {
            var appEvent = $A.get("e.c:appEvent");
            var message = {
                "action": 'refresh',
            };
            appEvent.setParams(
                {
                    "source": "cardActions",
                    "target": "cardList",
                    "message": message
                }
            );
            appEvent.fire();

    },

    changeCardStatus : function(component, customerId, parameterData, caseId, account) {
        var helper = this;
		 //CH01 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product	
        var regionName = account.Region_Flag__c;	
        if(component.get('v.isAlburaqProduct') == true){	
            regionName += '_alburaq';	
        }	
        //CH01 -End
        component.find('apexService').request(component.get('c.changeCardStatus'), {
            customerId: customerId,
            parameterData: JSON.stringify(parameterData),
            caseId: caseId,
            personEmail: account.PersonEmail,
            regionName: regionName
        },
        function(response) {
            var result = response.getReturnValue();
            var data = [];
            if (true === result.isSuccess ) {
                helper.refreshScreen(component, helper);
            }
        });
	},

    changeCardAccountAssociation : function(component, customerId, parameterData, caseId, account) {
        var helper = this;
		 //CH01 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product	
        var regionName = account.Region_Flag__c;	
        if(component.get('v.isAlburaqProduct') == true){	
            regionName += '_alburaq';	
        }	
        //CH01 -End
        component.find('apexService').request(component.get('c.changeCardAccountAssociation'), {
            customerId: customerId,
            parameterData: JSON.stringify(parameterData),
            caseId: caseId,
            personEmail: account.PersonEmail,
            regionName: regionName
        },
        function(response) {
            var result = response.getReturnValue();
            var data = [];
            if (true === result.isSuccess ) {
                helper.refreshScreen(component, helper);
            }
        });
	},

    updateSegment: function(cmp, customerId){
        var helper = this;
        var caseId = cmp.get("v.caseId");
        
        // NEW: Enhanced validation
        var selectedDiscount = cmp.get("v.disSegSelected");
        var isUserAuthorized = cmp.get("v.isUserAuthorizedForDiscount");
        var currentSegment = cmp.get("v.segmentCurrent.segmentName") || '';
        var selectedCard = cmp.get("v.curSegSelected");
        
        // Determine if this is an upgrade (REGULAR → PREMIUM/WORLD)
        var isUpgrading = currentSegment.toUpperCase() === 'REGULAR' && selectedCard.toUpperCase() === 'WORLD';
        
        //CH01 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product
        var account = cmp.get('v.account');
        var regionName = account.Region_Flag__c;
        if(cmp.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        //CH01 -End

        cmp.find('apexService').request(cmp.get('c.upDowngradeSegment'), {
            customerId: customerId,
            availableCard: cmp.get("v.curSegSelected"),
            discount: cmp.get("v.disSegSelected"),
            embossName: cmp.get("v.segmentEmbossName"),
            caseId: caseId,
            regionName: regionName
        },
        function(response) {
            var result = response.getReturnValue();
            console.log("res", response);
            if (true === result.isSuccess ) {
                helper.refreshScreen(cmp, helper);
            }
            // CH03: Reset submission flag on error too
            cmp.set('v.isSubmited', false);
        });
    },
        
        isUpgradingSegment: function(component) {
            var currentSegment = component.get("v.segmentCurrent.segmentName") || '';
            var selectedCard = component.get("v.curSegSelected");
            
            console.log('currentSegment>>>>>>>>>>>>>', currentSegment);
            console.log('selectedCard>>>>>>>>>>>>>', selectedCard);
            console.log('final>>>>>>>>>>>>>', (currentSegment.toUpperCase() === 'REGULAR' && selectedCard.toUpperCase() === 'WORLD'));
            
            // If current segment is REGULAR and selected card is PREMIUM/WORLD, it's an upgrade
            return currentSegment.toUpperCase() === 'REGULAR' && selectedCard.toUpperCase() === 'WORLD';
        },
        
    refreshScreen : function(component, helper){
        component.set('v.selectedCardActionType', undefined);
        component.set('v.selectedAccountId', undefined);
        component.set('v.deliveryType', undefined);
        component.set('v.productType', undefined);
        component.set('v.reason', undefined);

        // give user an indication that the action was a success
        component.find('apexService').showSuccessMessage("Request successful");
        // refresh cards list
        helper.requestCardListRefresh(component);
        // refresh the standard page view
        $A.get('e.force:refreshView').fire();
    },
        
        loadCardList: function(component, customerId, personEmail, regionName) {
            component.set('v.isLoading', true);
            var action = component.get("c.loadCardList");
            
            var regName = regionName;
            if(component.get('v.isAlburaqProduct') == true){
                regName += '_alburaq';
            }
            
            action.setParams({
                customerId: customerId,
                personEmail: personEmail,
                regionName: regName
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (true === result.isSuccess) {
                        console.log('result --->',JSON.stringify(result));
                        console.log('responseData --->',JSON.stringify(result.responseData));
                        console.log('cards --->',JSON.stringify(result.responseData.cards));
                        var cards = result.responseData.cards;
                        var selectedCardId = component.get('v.selectedCardId');
                        console.log('selectedCardId -->',selectedCardId);
                        console.log('cards -->',JSON.stringify(cards));
                        var selectedCard = cards.filter(item => item.id == selectedCardId);
                        console.log('selectedCard -->',selectedCard);
                        var isCardRenewed = selectedCard[0].canReplace;
                        console.log('isCardRenewed -->',isCardRenewed);
                        //var isCardRenewed = true;
                        component.set('v.cardCanReplaced', !isCardRenewed);
                        component.set('v.isLoading', false);
                    }
                    console.log('Card list loaded successfully:', JSON.stringify(result));
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.error('Error loading card list:', errors);
                    component.set('v.isLoading', false);
                }
            });
            
            $A.enqueueAction(action);
        }
})
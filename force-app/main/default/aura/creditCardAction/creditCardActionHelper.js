/* 		
 * 		Change History:
 *			   #CH01# #MBARKI ANISS# #09-08-2022# Add "Reactivate Dormant Card" Logic
 			   #CH02# #Jahangeer Mohammed# #19-08-2025# Added Masked Card Number(NBA-15639)
 */
 ({

    loadAccountList : function(component, customerId, cardId) {
         var account = component.get('v.account');
		component.find('apexService').request(component.get('c.loadAccountList'), {
		    customerId: customerId,
		    regionName: account.Region_Flag__c
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
        var account = cmp.get('v.account');
        cmp.find('apexService').request(cmp.get('c.loadSegmentOptionsCRM'), {
            customerId: customerId,
            caseId: caseId,
            regionName:account.Region_Flag__c
        },
		function(response) {
		    var result = response.getReturnValue();
            console.log("result", result);

            if (result.isSuccess === true && !$A.util.isEmpty(result.responseData)) {

                //generate card options
                var lstSegOpts = result.responseData.segmentOptions ? result.responseData.segmentOptions : [];
                var segOpts = [];
                lstSegOpts.forEach(segOpt => {
                    segOpts.push({label: segOpt.segmentName, value: segOpt.segmentCrmId});
                });

                var lstCardOpts = result.responseData.cardOptions ? result.responseData.cardOptions : [];
                var cardOpts = [];
                lstCardOpts.forEach(cardOpt => {
                    cardOpts.push({label: cardOpt.cardDisplayName, value: cardOpt.productType})
                });

                var lstDisOpts = result.responseData.discountOptions ? result.responseData.discountOptions : [];
                var disOpts = [];
                lstDisOpts.forEach(disOpt => {
                    disOpts.push({label: disOpt.displayName, value: disOpt.name})
                });

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
            var extraParameters = {
                isCaseClosureRequired: true,
                systemActionType: 'Lost Card',
                caseType: 'Card Service',
                caseSubType: 'Lost/Stolen Card'
            }
            helper.requestNewCard(component, customerId, /*cardId=*/undefined, caseId, extraParameters, account);
        }
        helper.blockCard(component, customerId, blockCardData, caseId, issueNewCardFun, account);
    },

    processStolenCard : function(component, customerId, blockCardData, caseId, account) {
        var helper = this;

        var issueNewCardFun = function() {
            var extraParameters = {
                isCaseClosureRequired: true,
                systemActionType: 'Stolen Card',
                caseType: 'Card Service',
                caseSubType: 'Lost/Stolen Card'
            }
            helper.requestNewCard(component, customerId, /*cardId=*/undefined, caseId, extraParameters, account);
        }
        helper.blockCard(component, customerId, blockCardData, caseId, issueNewCardFun, account);
    },
    processDamagedCard : function(component, customerId, blockCardData, caseId, account) {
        //old code
        //commented code by SP: For Damage Care, we will call to request new card only one
        //Date 07/10/19
        /*var helper = this;
        var issueNewCardFun = function() {
            var cardId = blockCardData.cardId;
            var extraParameters = {
                isCaseClosureRequired: true,
                systemActionType: 'Damaged Card',
                caseType: 'Card Service',
                caseSubType: 'Damaged Card'
            }
            helper.requestNewCard(component, customerId, cardId, caseId, extraParameters, account);
        }
        helper.blockCard(component, customerId, blockCardData, caseId, issueNewCardFun, account);
        */

        //add by sp
        //Date 07/10/19
        var cardId = blockCardData.cardId;
        var extraParameters = {
            isCaseClosureRequired: true,
            systemActionType: 'Damaged Card',
            caseType: 'Card Service',
            caseSubType: 'Damaged Card'
        }
        console.log("processDamagedCard.......");
        this.requestNewCard(component, customerId, cardId, caseId, extraParameters, account);
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

        component.find('apexService').request(component.get('c.blockCard'), {
            customerId: customerId,
            blockCardData: JSON.stringify(blockCardData),
            caseId: caseId,
            personEmail: account.PersonEmail,
            regionName: account.Region_Flag__c
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
        component.find('apexService').request(component.get('c.requestNewCard'), {
            customerId: customerId,
            requestTextJson: JSON.stringify(requestData),
            maskedCardNumber: existingCardDetails.maskedCardNumber,
            caseId: caseId,
            extraParameters: JSON.stringify(extraParameters),
            personEmail: account.PersonEmail,
            regionName: account.Region_Flag__c
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
		console.log('I am here !!!!!!');
        component.find('apexService').request(component.get('c.changeCardStatus'), {
            customerId: customerId,
            parameterData: JSON.stringify(parameterData),
            caseId: caseId,
            personEmail: account.PersonEmail
        },
        function(response) {
            var result = response.getReturnValue();
            var data = [];
            if (true === result.isSuccess ) {
                helper.refreshScreen(component, helper);
            }
        });
	},

    creditCardFCR : function(component, customerId, parameterData, caseId, account) {
        var helper = this;
        console.error('customerId--> '+customerId);
        component.find('apexService').request(component.get('c.creditCardFCRAPI'), {
            customerId: customerId,
            parameterData: JSON.stringify(parameterData),
            caseId: caseId,
            personEmail: account.PersonEmail,
            regionName: account.Region_Flag__c
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

        component.find('apexService').request(component.get('c.changeCardAccountAssociation'), {
            customerId: customerId,
            parameterData: JSON.stringify(parameterData),
            caseId: caseId,
            personEmail: account.PersonEmail,
            regionName: account.Region_Flag__c
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

        cmp.find('apexService').request(cmp.get('c.upDowngradeSegment'), {
            customerId: customerId,
            availableCard: cmp.get("v.curSegSelected"),
            discount:  cmp.get("v.disSegSelected"),
            embossName: cmp.get("v.segmentEmbossName"),
            caseId: caseId
        },
        function(response) {
            var result = response.getReturnValue();
            console.log("res", response);
            if (true === result.isSuccess ) {
                helper.refreshScreen(cmp, helper);
            }
        });
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

     getCaseDetails : function(component, helper){
        var caseIdJS = component.get("v.caseId");
        console.log('----- case ID JS--> ' +caseIdJS);

        var action = component.get("c.getCaseSubType");
        action.setParams({ caseIdapex : caseIdJS });
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
               var casreturnValue = response.getReturnValue();
                console.log('----- case RETURN VALUE--> ' +JSON.stringify(casreturnValue));
				console.log('----- case SUB TYPE --> ' +casreturnValue.Sub_Type__c);
                console.log('----- case Status --> ' +JSON.stringify(casreturnValue.Status));
                console.log('----- case Type --> ' +JSON.stringify(casreturnValue.Type));
                if(casreturnValue.Sub_Type__c == 'Freeze / Unfreeze Card' || ((casreturnValue.Sub_Type__c == 'Credit card'|| casreturnValue.Sub_Type__c == 'ila prepaid') && casreturnValue.Type =='Fraud' )){
                    if(casreturnValue.Status =='Closed' && (casreturnValue.Type =='Credit Card FCR' ||((casreturnValue.Sub_Type__c == 'Credit card'|| casreturnValue.Sub_Type__c == 'ila prepaid') && casreturnValue.Type =='Fraud'))){
                        component.set("v.isClosed",true);
                    }
                    
                    var optionFreeze = [
                                        {'label': 'Freeze', 'value': 'Freeze', 'helpText':'This action will Freeze the Card. The customer will have option to Unfreeze the Card from the App'},
                                        {'label': 'Unfreeze', 'value': 'Unfreeze', 'helpText':'This action will Unfreeze the Card'}
                            
                                    ];
                    component.set('v.cardActionTypeOptions', optionFreeze);
                }
                else if(casreturnValue.Sub_Type__c == 'Block/ Unblock Card'){
                    if(casreturnValue.Status =='Closed' && casreturnValue.Type =='Credit Card FCR'){
                        component.set("v.isClosed",true);
                    }
                    var optionBlock= [
                                        {'label': 'Temporary Block Card', 'value': 'temporaryBlock', 'helpText':'This action will temporarily block the Card. The Customer will not have the option to Unblock the Card from the App.'},
                                        {'label': 'Unblock Card', 'value': 'Unblock', 'helpText':'This action will Unblock your card'}

                                    ];
                    component.set('v.cardActionTypeOptions', optionBlock);
                }
                else if(casreturnValue.Sub_Type__c == 'Replace Card'){
                    if(casreturnValue.Status =='Closed' && casreturnValue.Type =='Credit Card FCR'){
                        component.set("v.isClosed",true);
                    }
                    var optionReplace= [
                                        {'label': 'Replace Card', 'value': 'ReplaceCard', 'helpText':'This option will block the Card permanently immediately and will issue a new Card with a new number'}
                                       // {'label': 'Damaged Card', 'value': 'damage', 'helpText':'This option will block the Card permanently immediately and will issue a new Card with a new number'},
                            			//{'label': 'Stolen Card', 'value': 'stolen', 'helpText':'This option will block the Card permanently immediately and will issue a new Card with a new number'}
                                    ];
                    component.set('v.cardActionTypeOptions', optionReplace);
                }
                //#CH01 : Start 
                else if(casreturnValue.Sub_Type__c == 'Reactivate Dormant Card'){
                    if(casreturnValue.Status =='Closed' && casreturnValue.Type =='Credit Card FCR'){
                        component.set("v.isClosed",true);
                    }
                    var optionReplace= [
                                        {'label': 'Reactivate Dormant Card', 'value': 'ReactivateDormantCard', 'helpText':'This option will Reactivate Dormant Card'}
                                    ];
                    component.set('v.cardActionTypeOptions', optionReplace);
                } else if (casreturnValue.Type == 'Cards' && casreturnValue.Sub_Type__c == 'Card Control') {
                    var options = [
                        { label: 'Freeze', value: 'Freeze', helpText: 'This action will Freeze the Card. The customer will have option to Unfreeze the Card from the App' },
                        { label: 'Unfreeze', value: 'Unfreeze', helpText: 'This action will Unfreeze the Card' }
                    ];
                    
                    // Add all other options
                    options = options.concat([
                        { label: 'Temporary Block Card', value: 'temporaryBlock', helpText: 'This action will temporarily block the Card. The Customer will not have the option to Unblock the Card from the App.' },
                        { label: 'Unblock Card', value: 'Unblock', helpText: 'This action will Unblock your card' },
                        { label: 'Replace Card', value: 'ReplaceCard', helpText: 'This option will block the Card permanently immediately and will issue a new Card with a new number' },
                        { label: 'Reactivate Dormant Card', value: 'ReactivateDormantCard', helpText: 'This option will Reactivate Dormant Card' }
                    ]);
                    
                    component.set('v.cardActionTypeOptions', options);
                    
                    if (casreturnValue.Status === 'Closed' && casreturnValue.Type === 'Credit Card FCR') {
                        component.set("v.isClosed", true);
                    }
                }
                //#CH01 :End

            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
        successmessageHelper : function(component){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":"success",
                "title": "Success!",
                "message": "Request has been sent successfully."
            });
            toastEvent.fire();
        },
            //CH02: Start
            updatePCIAndMaskCardNoCase :  function(component,caseId,pciNumber,mskCardNumber){
                console.log('Update PCI and Masked Card Number in Helper');
                var action = component.get('c.updatePCIMaskNumberOnCase');
                action.setParams({
                    caseId:caseId,
                    pciNumber:pciNumber,
                    mskCardNumber:mskCardNumber
                });
                
                action.setCallback(this, function(response) {
                    console.log('Response State:',response.getState());
                    var state = response.getState();
                    if(state === "SUCCESS") {
                        var result = response.getReturnValue();
                        console.log('Result Value:',result)
                    }
                    else if(state === "INCOMPLETE"){
                        console.log("Incomplete message");
                    }
                    else if(state === 'Error'){
                         var errors = response.getError();
                         if(errors){
                               console.log("Error message: ",+ errors[0].message);
                          }else{
                                console.log("UNKNOWN error");
                          }
                    }
                });
                $A.enqueueAction(action);
            }
//CH02: END
})
/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History:
 *			   #CH01# Added #20-08-2021# Added Java script code to invoke Credit Card Detail based on Account or Case Record Page
 *				by Jahangeer Mohammed.
 *			   #CH04# #MBARKI ANISS# #09-08-2022# Add targetType  & exclude Supplementary cards from the list (if Type = "Credit Card Services" & RecordType == "Credit_Card_Services")
 *			   #CH05# Added #Jahangeer Mohammed# #15-01-2023# Includes Only Credit Cards & Cash Collateral Cards which are active for credit limit decrease application(NBA-6757)
 *			   #CH06# Added #Jahangeer Mohammed# #15-10-2023# Added Active Credit Cards and Cash Collateral Cards to update to Ila World & Ila World Elite(NBA-9090)
               #CH07# Added #Imane Tsioucha# #01-11-2023# Added recordId for LoadCardList
               #CH08# Added #Imane Tsioucha# #18-12-2023# Added CaseId on loadCardList & loadCardDetails to update fields from API
               #CH09# : #Jahangeer Mohammed# #05-05-2024# Added Logic for Audit History Enhancements(NBA-9027)
               #CH10# : #Aniss# #30-07-2024# Added Logic for Credit Card - Renewal - CRM not to call any API when credit card is renewed (NBA-11756)
               #CH11# : #Jahangeer Mohammed# #11-02-2025# Added Logic to the status Dormancy for prepaid cards(NBA-13205)
               #CH12# #Jahangeer Mohammed# #07-05-2025# Added Logic for Credit Card Cancellation Process(NBA-13500)
               #CH13# #Jahangeer Mohammed #09-11-2025# Added Logic for Credit Card Spouse (NBA-15728)
               #CH14#  #Aitogram omar# #01-04-2026 Added logic for Dormancy Visibility Restrictions (NBA-11705) 
               #CH15# #Jahangeer Mohammed# #20-09-2026# Add Logic for Credit Card Payment Restriction (NBA-16942)
 */
({
    loadData: function (component, customerId) {

        //console.log('Email:', account.PersonEmail);
        //console.log('CustomerId:', customerId);
        var helper = this;

        //Customer Id is required for make request
        if (!customerId) {
            return;
        }
        var account = component.get('v.account');

        // CH14 start 
        component.find('apexService').request(component.get('c.getJordanVisibility'), {
            customerId: customerId
        }, function (response) {
            var hideJordanFinancialDetails = response.getReturnValue();
            component.set('v.hideJordanFinancialDetails', hideJordanFinancialDetails);
            // CH14 end 

            var regionName = account.Region_Flag__c;

            if (
                account.Subscription_Model__pc == 'both' ||
                account.Subscription_Model__pc == 'alburaq'
            ) {
                regionName += '_alburaq';
            }

            component.find('apexService').request(component.get('c.loadCardList'), {
                customerId: customerId,
                personEmail: account.PersonEmail,
                regionName: account.Region_Flag__c,
                //caseId : component.get("v.caseId"), //CH08
                //#CH07 :START 
                recordId: null
                //#CH07 :END
            },
                function (response) {
                    var result = response.getReturnValue();
                    console.log('ResulTT--> ', result);
                    console.log('ResulTT 2 Param--> ', result.responseData.currentCards);

                    component.set("v.currentCards", result.responseData.currentCards);
                    // array of card data
                    var data = [];

                    //#CH04 :START 
                    var caseRecordType = component.get('v.caseRecordType');

                    console.log('caseRecordType -->', caseRecordType);

                    var caseType = component.get('v.caseType');
                    //#CH04 :END 
                    //CH05: Start
                    var caseSubType = component.get('v.caseSubType');
                    var caseStatus = component.get('v.caseStatus');
                    console.log('Sub Type Value :', caseSubType);
                    console.log('Case Status:', component.get('v.caseStatus'));
                    var activeCardsList = [];
                    //CH05: END

                    //var cardListData = [];
                    if (true === result.isSuccess && !$A.util.isEmpty(result.responseData.currentCards)) {

                        var cards = result.responseData.currentCards;
                        console.log('ResulTT inside IF Cards--> ', cards);
                        for (var i = 0; i < cards.length; i++) {
                            var cardObj = cards[i];
                            console.log('--- CARD OBJ --> ', cardObj);

                            //#CH04 :START
                            if (caseType == 'Credit Card Services' && caseRecordType == 'Credit_Card_Services' && (cardObj.isPrimary == false)) {
                                /*
                                    display only currentCards that meet the following conditions :
                                    isPrimary = true
                                */
                                continue;
                            }
                            //#CH04 :END

                            //CH05: Start
                            else if (caseRecordType == 'Credit_Card_FCR' && caseType == 'Credit Card FCR' && caseSubType == 'Credit Limit Decrease' && (cardObj.isPrimary == false || cardObj.status != 'ACTIVE')) {
                                continue;
                            }
                            //CH05: END 

                            //CH06:Start
                            else if (caseRecordType == 'Credit_Card_Services' && caseType == 'Credit Card Upgrade' && (cardObj.isPrimary == false || cardObj.status != 'ACTIVE')) {
                                continue;
                            }
                            //CH06: END

                            let cardDetails = {};

                            console.log('sendOTPNotificationsTo -->', cardObj.sendOTPNotificationsTo);
                            console.log('sendTransactionsNotificationsTo -->', cardObj.sendTransactionsNotificationsTo);
                            console.log('cardHolderMobileNumber -->', cardObj.cardHolderMobileNumber);
                            console.log('cardHolderEmail -->', cardObj.cardHolderEmail);

                            if (cardObj.sendOTPNotificationsTo) {
                                cardDetails.sendOTPNotificationsTo = cardObj.sendOTPNotificationsTo;
                            }
                            if (cardObj.sendTransactionsNotificationsTo) {
                                cardDetails.sendTransactionsNotificationsTo = cardObj.sendTransactionsNotificationsTo;
                            }
                            if (cardObj.cardHolderMobileNumber) {
                                cardDetails.cardHolderMobileNumber = cardObj.cardHolderMobileNumber;
                            }
                            if (cardObj.cardHolderEmail) {
                                cardDetails.cardHolderEmail = cardObj.cardHolderEmail;
                            }

                            console.log('cardDetails for card ' + cardObj.id + ' --->', cardDetails);

                            // Store cardDetails in a map with card id as key
                            let allCardDetails = component.get("v.allCardDetails") || {};
                            allCardDetails[cardObj.id] = cardDetails;
                            component.set("v.allCardDetails", allCardDetails);

                            data.push(helper.formatData(component, cardObj));
                            //CH05: Start
                            activeCardsList.push(helper.formatDataOfActiveCards(component, cardObj));
                            //CH05: END
                        }
                    }
                    console.log("CardList data is loaded", data);
                    component.set('v.data', data);
                    //CH05: Start
                    console.log("Active Card List", activeCardsList);
                    component.set('v.activeCardList', activeCardsList);
                    console.log("Active Card List Data", component.get('v.activeCardList'));
                    //CH05: END 
                    //console.log("Card List Data with new Parameter",cardListData);
                    //component.set('v.copyData',cardListData);
                    //CH15: Start
                    /*
 						* Notify parent whether Credit Cards exist
 					*/
					var creditCardEvent = component.getEvent('creditCardListEvent');
					creditCardEvent.setParams({
    					hasCreditCards: data.length > 0
					});
					creditCardEvent.fire();
                    //CH15: END
                });
            // added by Shashank

            component.find('apexService').request(component.get('c.caseType'), {
                caseId: component.get("v.caseId")
            },
                function (response) {
                    var result = response.getReturnValue();
                    //CH06: Start #Added Case Type in if condition
                    var cseType = component.get('v.caseType');
                    var caseSubType = component.get('v.caseSubType');
                    console.log('Case Sub Type:', caseSubType);
                    /*if (result == 'Credit Card Services' && cseType != 'Credit Card Upgrade' && cseType == 'Credit Card Services') { 
                        if(caseSubType == 'EPP Early Closure' || caseSubType == 'EPP Techical Error'){
                            component.set("v.isCreditCardService",true); //It display Handoff Component on Case Detail
                            component.set("v.isCreditCardServiceEPP",true);//It display EPP Component on Case Detail 
                              component.set("v.isCreditCardUpgrade",false); //It Hides Upgrade Component on Case Detail
                        }
                        else if(caseSubType != 'EPP Early Closure' && caseSubType == 'EPP Techical Error'){
                            component.set("v.isCreditCardService",true); //It display Handoff Component on Case Detail
                            component.set("v.isCreditCardServiceEPP",false);//It Hides EPP Component on Case Detail 
                              component.set("v.isCreditCardUpgrade",false); //It Hides Upgrade Component on Case Detail
                        }
                        
                    }*/
                    if (result == 'Credit Card Services' && cseType != 'Credit Card Upgrade') {
                        component.set("v.isCreditCardService", true);
                        component.set("v.isCreditCardUpgrade", false);
                    }
                    else if (result == 'Credit Card Services' && cseType == 'Credit Card Upgrade') { //It Display Upgrade Component
                        component.set("v.isCreditCardUpgrade", true);
                        component.set("v.isCreditCardService", false);

                    }
                    else {
                        component.set("v.isCreditCardService", false);
                        component.set("v.isCreditCardUpgrade", false);

                    }
                    //CH06: END
                });
        });
    },
    formatData: function (component, cardObj) {
        var rec = {};
        //CH04: Start
        if (cardObj.isPrimary == false) {
            rec.cardType = 'Supplementary Card';
            rec.targetType = 'SUPPLEMENTARY_CARD';
        } else if (cardObj.cardNature == 'prepaid') {
            rec.targetType = 'PREPAID_CARD';
            rec.cardType = 'Prepaid Card';

        } else {
            rec.targetType = 'CREDIT_CARD';
            if (cardObj.isPrimary == true && cardObj.cardNature == 'secured') {
                rec.cardType = 'Cash Collateral';
            }
            else if (cardObj.isPrimary == true && cardObj.cardNature == 'unsecured') {
                rec.cardType = 'Credit Card';
            }
        }
        //CH04: End

        var isCustomerDelinquent = cardObj.isDelinquent;
        if (isCustomerDelinquent == true) {
            rec.id = cardObj.id;
            rec.productType = cardObj.cardDisplayName;
            //CH11: Start
            if (cardObj.cardNature == 'prepaid' && cardObj.status == 'DORMANT') {
                rec.status = 'INACTIVE_6_MONTHS';
            }
            else if (cardObj.cardNature == 'prepaid' && cardObj.status != 'DORMANT') {
                rec.status = cardObj.status;
            }
            else if (cardObj.cardNature != 'prepaid') {
                rec.status = cardObj.status;
            }
            //rec.status = cardObj.status;
            //CH11: END
            rec.maskedCardNumber = cardObj.maskedCardNumber;
            rec.blockDate = cardObj.blockDate;
            rec.parentStatus = cardObj.parentStatus;
            //CH06: Start
            rec.cardNature = cardObj.cardNature;
            if (cardObj.cardNature == 'secured') {
                rec.holdAccount = cardObj.holdAccount;
                rec.holdAmount = cardObj.holdAmount;
                rec.holdReference = cardObj.holdReference;
            }
            //CH06: END
            //CH02: Start
            if (cardObj.isPrimary == true) {
                rec.isPrimary = false;
            }
            else {
                rec.isPrimary = true;
            }
            //CH02: END
            rec.delinquent = cardObj.isDelinquent;
            rec.displayIconName = 'utility:success';
            //rec.colortext = 'slds-text-color_error';
            rec.colortext = 'CSSROWCOLOR';
        }
        if (isCustomerDelinquent == false) {
            rec.id = cardObj.id;
            rec.productType = cardObj.cardDisplayName;
            //CH11: Start
            if (cardObj.cardNature == 'prepaid' && cardObj.status == 'DORMANT') {
                rec.status = 'INACTIVE_6_MONTHS';
            }
            else if (cardObj.cardNature == 'prepaid' && cardObj.status != 'DORMANT') {
                rec.status = cardObj.status;
            }
            else if (cardObj.cardNature != 'prepaid') {
                rec.status = cardObj.status;
            }
            //rec.status = cardObj.status;
            //CH11: END
            rec.maskedCardNumber = cardObj.maskedCardNumber;
            rec.blockDate = cardObj.blockDate;
            rec.parentStatus = cardObj.parentStatus;
            //CH06: Start
            rec.cardNature = cardObj.cardNature;
            if (cardObj.cardNature == 'secured') {
                rec.holdAccount = cardObj.holdAccount;
                rec.holdAmount = cardObj.holdAmount;
                rec.holdReference = cardObj.holdReference;
            }
            //CH06: END
            //CH02: Start
            if (cardObj.isPrimary == true) {
                rec.isPrimary = false;
            }
            else {
                rec.isPrimary = true;
            }
            //CH02: END
            rec.delinquent = cardObj.isDelinquent;
            rec.displayIconName = 'utility:close';

        }

        rec.isRenewed = cardObj.isRenewed;//#CH10:
        rec.crmCaseId = cardObj.crmCaseId;
        //CH13: Start
        rec.isSpouse = cardObj.issueForSpouse;
        //CH13: END
        return rec;

    },
    formatData2: function (component, cardObj) {
        var rec = {};
        rec.id = cardObj.id;
        rec.productType = cardObj.cardDisplayName;
        rec.blockDate = cardObj.blockDate;
        rec.parentStatus = cardObj.parentStatus;
        rec.status = cardObj.status;
        return rec;
    },

    //CH05: Start
    formatDataOfActiveCards: function (component, cardObj) {
        var rec = {};
        rec.id = cardObj.id;
        rec.embossName = cardObj.embossName;
        rec.cardProductionConfigurationId = cardObj.cardProductionConfigurationId;
        rec.cardNature = cardObj.cardNature;
        return rec;

    },
    //CH05: END
    activateCard: function (component, customerId, cardId) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "This is a demo!",
            "message": "This action will activate selected card."
        });
        toastEvent.fire();
    },
    //accountId is added as it is required by API
    //CH01: Start Added by Jahangeer Mohammed 29-08-2021
    openCardDetails: function (component, customerId, cardId, accountId, cardType, cardStatus) {
        var checkCardService = component.get('v.isCreditCardService');
        //CH06: Start
        var checkCardUpgrade = component.get('v.isCreditCardUpgrade');
        //CH06: END
        //CH06: Start #Added checkCardUpgrade condition in if block
        if (checkCardService == false && checkCardUpgrade == false) {
            component.set('v.selectedCardId', cardId);
            component.set('v.cardStatusValue', cardStatus);
            component.set('v.accountId', accountId);

            console.log("AccountId is received at Account Level", accountId);
            console.log("CardId is received at Account Level  --> ", component.get('v.selectedCardId'));
        }
        //CH06: END
        //CH06: Start
        else if (checkCardService == false && checkCardUpgrade == true) {
            component.set('v.selectedCardId', cardId);
            component.set('v.accountId', accountId);
            console.log("AccountId is received at Upgrade Request", accountId);
            console.log("CardId is received in Upgrade Request  --> ", component.get('v.selectedCardId'));
        }
        //CH06: END
        //CH06: Start #Added checkCardUpgrade condition in else block
        else if (checkCardService == true && checkCardUpgrade == false) {
            var account = component.get('v.account');
            this.openCardDetailsForCreditCardService(component, customerId, cardId, account);
        }
        //CH06: END
    },
    openCardDetailsForCreditCardService: function (component, customerId, cardId, account) {
        console.log('=====Account information', account);
        console.log('=====Customer information', customerId);
        console.log('=====Card information', cardId);
        component.set('v.selectedCardId', cardId);
        //alert('inside');
        var helper = this;
        component.find('apexService').request(component.get('c.loadCardDetails'), {
            customerId: customerId,
            cardId: cardId,
            personEmail: account.PersonEmail,
            regionName: account.Region_Flag__c
            //caseId : component.get("v.caseId"), //CH08
        },
            function (response) {
                var result = response.getReturnValue();
                // single card data
                var data = {};
                if (true === result.isSuccess && !$A.util.isEmpty(result.responseData))//responseData.currentCards))
                {
                    data = result.responseData;//result.responseData.currentCards;
                }

                //component.set('v.cardData', data);
                //CH12: Start
                console.log("Card Details data Response---->", data);
                var creditLmt = data.creditLimit;
                var creditOutStandBal = data.outstandingBalance;
                var pciNumber = data.pciNumber;

                console.log("Credit Limit---->", creditLmt);
                console.log("Credit Outstanding Balance---->", creditOutStandBal);
                component.set('v.currentCreditLmt', creditLmt);
                component.set('v.currentOutStandingBalance', creditOutStandBal);
                component.set('v.pciNumber', pciNumber);

                var myValues = [];
                myValues = component.get("v.activeCardList");
                console.log('Active List on Selection:', myValues)
                myValues.findIndex(item => {
                    if (item.id === cardId) {
                        console.log('Card Product Id:', item.cardProductionConfigurationId);
                        var configId = (item.cardProductionConfigurationId).toString();
                        component.set('v.cardProductId', configId);
                    }
                });
                //CH12: END
                //console.log("Card Details data on Card Services---->",JSON.stringify(data));
                //var fetchALLCardData = component.get('v.copyData');

                var fetchALLCardData = component.get('v.CaptureDataBasedOnFilter');
                var fetchCardData = JSON.parse(JSON.stringify(fetchALLCardData));
                console.log('-----Fetching Credit Card Data :', fetchCardData);
                console.log('-----Fetching Credit Card Data Length:', fetchCardData.length);
                var CardIdSelected = component.get('v.selectedCardId');
                console.log('---->Selected Card Id is:', CardIdSelected);

                var today = new Date(
                    new Date().getFullYear(),
                    new Date().getMonth() + 1,
                    new Date().getDate()
                );
                var dd = today.getDate();
                var mm = today.getMonth();
                var yyyy = today.getFullYear();

                if (dd < 10) {
                    dd = '0' + dd;
                }

                if (mm < 10) {
                    mm = '0' + mm;
                }
                var CurrentDate = yyyy + '-' + mm + '-' + dd;
                var noOfDays = $A.get("$Label.c.NO_OF_DAYS");
                console.log('Number of days:', noOfDays);
                for (var i = 0; i < fetchCardData.length; i++) {
                    var cardIds = fetchCardData[i].id;
                    if (CardIdSelected == cardIds) {
                        console.log('Cards Ids are:', cardIds);
                        if (fetchCardData[i].parentStatus == 'ACCOUNT_BLOCKED' && fetchCardData[i].status == 'ACCOUNT_CANCELLED_BY_CUSTOMER' &&
                            fetchCardData[i].blockDate != null && fetchCardData[i].blockDate != undefined) {
                            var ccBlockDate = fetchCardData[i].blockDate;
                            const oneDay = 24 * 60 * 60 * 1000;
                            CurrentDate = CurrentDate.split('-');
                            ccBlockDate = ccBlockDate.split('-');
                            const currDate = new Date(CurrentDate);
                            const blockDate = new Date(ccBlockDate);
                            console.log('Current Date---->', currDate);
                            console.log('Block Date of Card---->', blockDate);
                            //const diffDays = Math.round(Math.abs((currDate - blockDate) / oneDay));
                            //console.log('Difference Between Block date and current date>>>>>',diffDays);
                            const diffDays = Math.round(Math.abs((blockDate - currDate) / oneDay));
                            console.log('Current Date after split Date 3>>>>>', diffDays);
                            if (diffDays < noOfDays) {
                                component.set('v.displaySendForBusinessApprovalButton', true);
                                component.set('v.displayGenerateCertificateButton', false);
                                component.set('v.displayRejectButton', false);
                            }
                            else if (diffDays >= noOfDays) {
                                component.set('v.displayGenerateCertificateButton', true);
                                component.set('v.displaySendForBusinessApprovalButton', false);
                                component.set('v.displayRejectButton', false);
                            }
                        }
                        else if (fetchCardData[i].parentStatus == 'ACTIVE') {
                            console.log('Parent Status are:', fetchCardData[i].parentStatus);
                            component.set('v.displayRejectButton', true);
                            component.set('v.displaySendForBusinessApprovalButton', false);
                            component.set('v.displayGenerateCertificateButton', false);
                        }
                        else if (fetchCardData[i].parentStatus == 'ACCOUNT_BLOCKED' && fetchCardData[i].status == 'ACCOUNT_CANCELLED_BY_CUSTOMER' &&
                            (fetchCardData[i].blockDate == null || fetchCardData[i].blockDate == undefined)) {
                            console.log('Block Dates are Missing');
                            component.set('v.displayRejectButton', false);
                            component.set('v.displaySendForBusinessApprovalButton', false);
                            component.set('v.displayGenerateCertificateButton', false);
                        }
                    }
                }
            });
    },
    handleuserData: function (component, event, account) {
        component.find('apexService').request(component.get('c.checkVisibilityStatement'), {
            accountId: account.Id,
        },
            function (response) {
                var result = response.getReturnValue();
                if (result == true) {
                    component.set("v.showCreditCardStatement", true);
                } else {
                    component.set("v.showCreditCardStatement", false);
                }

            });
    },
    //CH01: END
    //CH09: Start
    loadDataInAuditObject: function (component, maskNumber, cardClassification, cardStatus) {
        var action = component.get("c.createAuditRecordForCreditCardDetails");
        console.log('Mask Number in helper:', maskNumber);
        console.log('Card Classification in helper:', cardClassification);
        console.log('Card Status in helper:', cardStatus);
        var account = component.get('v.account');
        var accCIF = account.CIF__pc;
        console.log('Acc CIF in helper:', accCIF);
        action.setParams({
            accCIF: accCIF,
            maskNumber: maskNumber,
            cardClassification: cardClassification,
            cardStatus: cardStatus
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('Fetched Audit Id:', result);
            }

        });
        $A.enqueueAction(action);
    },
    //CH09: END

    // NEW: Load columns for Balance Transfer Plans table
    loadBTColumns: function (component) {
        var btColumns = [
            {
                label: 'Plan Number',
                fieldName: 'planNumber',
                type: 'text'
            },
            {
                label: 'Sequence Number',
                fieldName: 'sequenceNumber',
                type: 'text'
            },
            {
                label: 'Transaction Amount',
                fieldName: 'transactionAmount',
                type: 'number'
            },
            {
                label: 'Merchant',
                fieldName: 'merchant',
                type: 'text'
            },
            {
                label: 'Booking Date',
                fieldName: 'installmentBookingDate',
                type: 'date'
            },
            {
                label: 'Remaining Balance',
                fieldName: 'remainingBalance',
                type: 'number'
            },
            {
                label: 'Status',
                fieldName: 'status',
                type: 'text'
            }
        ];
        component.set("v.btColumns", btColumns);
    },

    // NEW: Load Active BT Plans (Mock for now)
    loadBTPlans: function (component, selectedCard) {
        console.log('Loading BT Plans for card (Mock):', selectedCard);
        var allCardDetails = component.get("v.currentCards");

        var finalCard = allCardDetails.filter(x => x.id == selectedCard.id)[0];
        console.log('Final filtered value -->', JSON.stringify(finalCard));

        var mockBTPlans = [
            { id: 'bt-001', planNumber: 'BT-987654', sequenceNumber: '001', planBalance: 3250.75 },
            { id: 'bt-002', planNumber: 'BT-123456', sequenceNumber: '002', planBalance: 1480.00 },
            { id: 'bt-003', planNumber: 'BT-555888', sequenceNumber: '003', planBalance: 8750.50 }
        ];

        //component.set("v.btPlans", mockBTPlans);
        console.log('selectedCard --->', JSON.stringify(selectedCard));
        component.find('apexService').request(component.get('c.getActiveBTPlans'), {
            accID: component.get('v.account.Id'),
            caseModel: 'ila',
            requestedPCINumber: finalCard.primaryCardPciNumber
        }, function (response) {
            console.log('result --->', JSON.stringify(response));
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result 2 --->', JSON.stringify(result));
                console.log('eppList --->', JSON.stringify(result.eppList));
                console.log('eppList length --->', result.eppList ? result.eppList.length : 0);

                component.set("v.btPlans", result.eppList || []);

                console.log(
                    'btPlans after set --->',
                    JSON.stringify(component.get("v.btPlans"))
                );
            } else {
                console.error('Apex Error --->', response.getError());
            }
        });

    },

    showToast: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                title: title,
                message: message,
                type: type
            });
            toastEvent.fire();
        } else {
            alert(message);
        }
    },

    updateCaseRecord: function (component, caseFields, callback) {
        var action = component.get("c.updateCaseRecord");
        action.setParams({
            "caseRecord": caseFields
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (callback) callback({ success: true, result: response.getReturnValue() });
            } else if (state === "ERROR") {
                var errors = response.getError();
                var message = errors && errors[0] && errors[0].message ? errors[0].message : "Unknown error";
                if (callback) callback({ success: false, message: message });
            }
        });

        $A.enqueueAction(action);
    }
})
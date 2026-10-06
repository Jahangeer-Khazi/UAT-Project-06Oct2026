({
    loadData: function(component, recordId) {
        var helper = this;
        component.find('apexService').request(component.get('c.loadRecord'), {
            recordId: recordId
        },
        function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            var account = {};
            
            if (state === "SUCCESS") {
                if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                    var data = result.responseData;
                    if (data.hasOwnProperty('Account')) {
                        account = data.Account;
                        component.set('v.caseRecordType', data.RecordType.DeveloperName);
                        component.set('v.caseType', data.Type);
                        component.set('v.caseSubType', data.Sub_Type__c);
                        component.set('v.caseStatus', data.Status);
                    } else {
                        account = data;
                    }
                }
            }

            component.set('v.account', account);
            component.set('v.customerId', account.CIF__pc);
            helper.loadTabsConfig(component);
        });
    },
    
    loadTabsConfig: function(component) {
        var helper = this;
        component.find('apexService').request(component.get('c.loadTabsConfig'), {},
        function(response) {
            var result = response.getReturnValue();

            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                var tabsConfig = result.responseData;
                component.set('v.tabsConfig', tabsConfig);
                if (true === tabsConfig.Bank_Accounts__c) {
                    return;
                }
                if (true === tabsConfig.Bank_Cards__c) {
                    return;
                }
            }
        });
    },
    
    reloadComponentById: function(component, componentId) {
        var cmp = component.find(componentId);
        if (cmp) {
            cmp.reload();
        }
    },
    
    cardStatusCall: function(component, recordId) {
        var helper = this;
        component.find('apexService').request(component.get('c.cardStatusFilter'), {
            recordId: recordId,
            option: component.get("v.selectedStatus")
        },
        function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            
            if (state === "SUCCESS") {
                if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                    var data = result.responseData;
                    var creditCardData = result.responseData.currentCards;
                    var creditCardDataFilterData = [];
                    var caseRecordType = component.get('v.caseRecordType');
                    var caseType = component.get('v.caseType');
                    
                    for (var i = 0; i < creditCardData.length; i++) {
                        var cardObj = creditCardData[i];
                        if (caseType == 'Credit Card Services' && caseRecordType == 'Credit_Card_Services' && (cardObj.cardNature == 'prepaid' || cardObj.isPrimary == false)) {
                            continue;
                        }
                        creditCardDataFilterData.push(helper.formatData(component, cardObj));
                    }
                    
                    component.set('v.dataInformation', creditCardDataFilterData);
                    component.set('v.dataInformationBasedOnFilter', creditCardDataFilterData);
                    
                    var account = {};
                    if (data.hasOwnProperty('Account')) {
                        account = data.Account;
                        component.set('v.caseRecordType', data.RecordType.DeveloperName);
                        component.set('v.caseType', data.Type);
                    } else {
                        account = data;
                    }
                }
            }
        });
    },
    
    formatData: function(component, cardObj) {
        var rec = {};

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
            } else if (cardObj.isPrimary == true && cardObj.cardNature == 'unsecured') {
                rec.cardType = 'Credit Card';
            }
        }
        
        var isCustomerDelinquent = cardObj.isDelinquent;
        if (isCustomerDelinquent == true) {
            rec.id = cardObj.id;
            rec.productType = cardObj.cardDisplayName;
            rec.status = cardObj.status;
            rec.maskedCardNumber = cardObj.maskedCardNumber;
            rec.blockDate = cardObj.blockDate;
            rec.parentStatus = cardObj.parentStatus;
            if (cardObj.isPrimary == true) {
                rec.isPrimary = false;
            } else {
                rec.isPrimary = true;
            }
            rec.delinquent = cardObj.isDelinquent;
            rec.displayIconName = 'utility:success';
            rec.colortext = 'CSSROWCOLOR';
        }
        if (isCustomerDelinquent == false) {
            rec.id = cardObj.id;
            rec.productType = cardObj.cardDisplayName;
            rec.status = cardObj.status;
            rec.maskedCardNumber = cardObj.maskedCardNumber;
            rec.blockDate = cardObj.blockDate;
            rec.parentStatus = cardObj.parentStatus;
            if (cardObj.isPrimary == true) {
                rec.isPrimary = false;
            } else {
                rec.isPrimary = true;
            }
            rec.delinquent = cardObj.isDelinquent;
            rec.displayIconName = 'utility:close';
        }
        return rec;
    },
    
    loadDebitCardsBasedOnSelectedOption: function(component, recordId) {
        var helper = this;
        var selectedDebitCardOption = component.get("v.selectedDebitCardStatus");
        
        if (selectedDebitCardOption === 'A' || selectedDebitCardOption === 'B') {
            component.find('apexService').request(component.get('c.loadDebitCardList'), {
                recordId: recordId,
                option: component.get("v.selectedDebitCardStatus")
            },
            function(response) {
                var result = response.getReturnValue();
                var data = [];
                
                if (true === result.isSuccess && !$A.util.isEmpty(result.responseData.cards)) {
                    var cards = result.responseData.cards;
                    for (var i = 0; i < cards.length; i++) {
                        var cardObj = cards[i];
                        if (selectedDebitCardOption === 'B' && (cardObj.status === 'Active' || cardObj.status === 'Inactive')) {
                            data.push(helper.formatActiveDebitData(component, cardObj));
                        } else if (selectedDebitCardOption === 'A' && (cardObj.status === 'Blocked' || cardObj.status === 'Cancelled')) {
                            data.push(helper.formatActiveDebitData(component, cardObj));
                        }
                    }
                    component.set('v.selectedDebitCardData', data);
                    component.set('v.filterOptionValue', selectedDebitCardOption);
                } else {
                    component.set('v.selectedDebitCardData', []);
                    component.set('v.filterOptionValue', selectedDebitCardOption);
                }
            });
        } else if (selectedDebitCardOption === 'P') {
            component.find('apexService').request(component.get('c.loadDebitCardPurgeList'), {
                recordId: recordId,
                option: component.get("v.selectedDebitCardStatus")
            },
            function(response) {
                var result = response.getReturnValue();
                var data = [];
                
                if (true === result.isSuccess && !$A.util.isEmpty(result.responseData.cards)) {
                    var cards = result.responseData.cards;
                    for (var i = 0; i < cards.length; i++) {
                        var cardObj = cards[i];
                        data.push(helper.formatPurgeDebitData(component, cardObj));
                    }
                    component.set('v.selectedDebitCardData', data);
                    component.set('v.filterOptionValue', selectedDebitCardOption);
                } else {
                    component.set('v.selectedDebitCardData', []);
                    component.set('v.filterOptionValue', selectedDebitCardOption);
                }
            });
        }
    },
    
    formatActiveDebitData: function(component, cardObj) {
        var rec = {};
        rec.id = cardObj.id;
        rec.productType = cardObj.productType;
        rec.status = cardObj.status;
        rec.maskedCardNumber = cardObj.maskedCardNumber;
        return rec;
    },
    
    formatPurgeDebitData: function(component, cardObj) {
        var rec = {};
        rec.id = cardObj.id;
        rec.productType = cardObj.cardClassification;
        rec.status = cardObj.status;
        rec.maskedCardNumber = cardObj.id;
        rec.activationDate = cardObj.activationDate;
        rec.issueDate = cardObj.issueDate;
        rec.embossName = cardObj.embossName;
        rec.cardType = cardObj.cardType;
        rec.primaryAccountIdentifier = cardObj.primaryAccountIdentifier;
        return rec;
    }
})
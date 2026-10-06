/* 		
 *			   #CH02# Added #ANISS MBARKI# 22/02/2023 display cardType and isDelinquent after filtring the table.
 *			   #CH03# Added #Jahangeer Mohammed# #29-05-2023# Logic to fetch debit Card list based on the selected option
 *			   #CH04# Added #Jahangeer Mohammed# #26-12-2023# Logic to fetch credit Card list based on the selected option
               #CH05# Added #Jahangeer Mohammed# #10-04-2025# Added Logic to the status Dormancy for prepaid cards(NBA-13205)

*/
 ({
	loadData : function(component, recordId) {
	    var helper = this;
		component.find('apexService').request(component.get('c.loadRecord'), {
		    recordId: recordId
        },
		function(response) {
		    var result = response.getReturnValue();
		    var state  = response.getState();
            // this can be either Account directly or Case(Account = )
            if(state === "SUCCESS"){
                if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {

                    var data = result.responseData;
                    //Alert the user with value
                    //returned from the user
                    console.info('Response Data in Dafault Load', result.responseData); //responseData is a object
                    var account = {};
                    if (data.hasOwnProperty( 'Account') ) {
                        account = data.Account;
                        
                        component.set('v.caseRecordType', data.RecordType.DeveloperName);
                        component.set('v.caseType',data.Type);
                        //console.log('dataType'+data.Type);
                        console.log('Bank Info Default load if');
                    } else {
                        console.log('Bank Info Default load else');
                        account = data;
                    }
                }
            }else if(state === "INCOMPLETE"){
                console.log("Incomplete message");
            }else if(state === "ERROR"){
                var errors = response.getError();
                if(errors){
                    console.log("Error message: ",+ errors[0].message);
                }else{
                     console.log("UNKNOWN error");
                }

            }

            console.log("loaded account: " + JSON.stringify(account));
            component.set('v.account', account);
            component.set('v.customerId', account.CIF__pc);

            /*
            var bankAccountsListComponent = component.find('bankAccountsList');
            if (bankAccountsListComponent) {
                bankAccountsListComponent.reload();
            }
            */
            helper.loadTabsConfig(component);
		});

	},
    
	loadTabsConfig : function(component) {
        //debugger;
	    var helper = this;
		component.find('apexService').request(component.get('c.loadTabsConfig'), { },
		function(response) {
		    var result = response.getReturnValue();

            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                var tabsConfig = result.responseData;
                component.set('v.tabsConfig', tabsConfig);
                console.log('Term Deposit Value',tabsConfig.Term_Deposits__c);
                // load data in the first visible tab
                if (true === tabsConfig.Bank_Accounts__c) {
                    helper.reloadComponentById(component, 'bankAccountsList');
                    return;
                }
                if (true === tabsConfig.Bank_Cards__c) {
                    helper.reloadComponentById(component, 'bankCardsList');
                    return;
                }
                //Start : Added by #Jahangeer Mohammed# #27-10-2021# for Term Deposit Functionality
               // console.log('Term Deposit Value',tabsConfig.Term_Deposits__c);
                if (true === tabsConfig.Term_Deposits__c) {
                    helper.reloadComponentById(component, 'termDepositList');
                    return;
                }
                //END
            }
		});
	},
    reloadComponentById: function(component, componentId) {
        console.log('Finding Component',componentId);
        var cmp = component.find(componentId);
        if (cmp) {
            cmp.reload();
        }

    },
    cardStatusCall : function(component, recordId){
        var helper = this;
        //alert('call Option API to get the relevent list for '+component.get("v.selectedStatus"));
        //CH04: Start
        var selectedCreditCardOption = component.get("v.selectedStatus");
        console.log('Selected Credit Card in helper:',selectedCreditCardOption);
        console.log("selected card id ",recordId);
        if(selectedCreditCardOption != 'P'){	
        component.find('apexService').request(component.get('c.cardStatusFilter'), { 
                recordId:recordId,
                option:component.get("v.selectedStatus")
            },
		function(response) {
		    var result = response.getReturnValue();
			var state  = response.getState();
            if(state === "SUCCESS"){
                if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                    
                    var data = result.responseData;
                    //CH01 Start Added by Jahangeer Mohammed for No Due Functionality
                    var creditCardData = result.responseData.currentCards;
                    var creditCardDataFilterData = [];
                    for (var i = 0; i < creditCardData.length; i++) {
                    	var cardObj = creditCardData[i];
                    	//console.log('--- CARD OBJ --> ',cardObj);
                    	creditCardDataFilterData.push(helper.formatData(component, cardObj));
                    }
                    //Alert the user with value
                    //returned from the user
                    console.log('Response Data in Changing Option', result.responseData); //responseData is a object
                    component.set('v.dataInformation',creditCardDataFilterData);
                    //CH04: Start
                    component.set('v.filterOptionCreditValue',selectedCreditCardOption);
                    //CH04: END
                    //CH01 END
                    var account = {};
                    if (data.hasOwnProperty( 'Account') ) {
                        account = data.Account;
                        component.set('v.caseRecordType', data.RecordType.DeveloperName);
                        component.set('v.caseType',data.Type);
                        console.log('Inside If statement');
                        //console.log('dataType'+data.Type);
                    } else {
                       // console.log('Inside else statement');
                        account = data;
                    }
                    //console.log('Data in new Array:',component.get('v.dataInformation'));
                }
            }else if(state === "INCOMPLETE"){
                console.log("Incomplete message");
            }else if(state === "ERROR"){
                var errors = response.getError();
                if(errors){
                    console.log("Error message: ",+ errors[0].message);
                }else{
                     console.log("UNKNOWN error");
                }

            }
            
		});
        } //If Ends
        else if(selectedCreditCardOption === 'P'){
            //component.set('v.data', []);
            console.log('We need to call Credit Purge API');
            component.find('apexService').request(component.get('c.loadCreditCardPurgeList'), { 
              recordId:recordId,
              option:component.get("v.selectedStatus")
          },
          function(response){
		    var result = response.getReturnValue();
            console.log('Result Value In Credit Purge:',result);
            // array of card data
            var data = [];
            if(true === result.isSuccess && !$A.util.isEmpty(result.responseData.cards)) {
                var cards = result.responseData.cards;
                for(var i = 0; i < cards.length; i++){
                    var cardObj = cards[i];
                    console.log('Credit Card Purge Data:',cardObj);
                    data.push(helper.formatPurgeCreditData(component, cardObj)); 
                }
                component.set('v.dataInformation',data);
                component.set('v.filterOptionCreditValue',selectedCreditCardOption);
            }
            else{
                  console.log('Empty Data - No Purge Credit Cards Found');
                  component.set('v.dataInformation',[]);
                  component.set('v.filterOptionCreditValue',selectedCreditCardOption);
            }
        });
        } //Else If Ends
        //CH04: END
    },
    //CH01 Start
    formatData: function(component, cardObj) {
        //CH02 Start
        var rec = {};

        if(cardObj.isPrimary == false){
            rec.cardType = 'Supplementary Card';
            rec.targetType = 'SUPPLEMENTARY_CARD';
        }else if( cardObj.cardNature == 'prepaid'){
            rec.targetType = 'PREPAID_CARD';
            rec.cardType = 'Prepaid Card';
        }else{
            rec.targetType = 'CREDIT_CARD';
            if(cardObj.isPrimary == true && cardObj.cardNature == 'secured' ){
                rec.cardType = 'Cash Collateral';
            }
            else if(cardObj.isPrimary == true  && cardObj.cardNature == 'unsecured' ){
                rec.cardType = 'Credit Card';
            }
        }

        var isCustomerDelinquent = cardObj.isDelinquent;
        if(isCustomerDelinquent == true){
            rec.id = cardObj.id;
            rec.productType = cardObj.cardDisplayName;
            //rec.cardType = cardObj.cardType;
            //CH05: Start
            if(cardObj.cardNature == 'prepaid' && cardObj.status == 'DORMANT'){
                 rec.status = 'INACTIVE_6_MONTHS';
            }
            else if(cardObj.cardNature == 'prepaid' && cardObj.status != 'DORMANT'){
                rec.status = cardObj.status;
            }
            else if(cardObj.cardNature != 'prepaid'){
                rec.status = cardObj.status;
            }
            //rec.status = cardObj.status;
            //CH05: END
            rec.maskedCardNumber = cardObj.maskedCardNumber;
            rec.blockDate = cardObj.blockDate;
            rec.parentStatus = cardObj.parentStatus;
            if(cardObj.isPrimary == true){
                rec.isPrimary = false;
            }
            else{
                rec.isPrimary = true;
            }
            rec.delinquent = cardObj.isDelinquent;
            rec.displayIconName = 'utility:success';
            rec.colortext = 'CSSROWCOLOR';
        }
        if(isCustomerDelinquent == false){
            rec.id = cardObj.id;
            rec.productType = cardObj.cardDisplayName;
            //CH05: Start
            if(cardObj.cardNature == 'prepaid' && cardObj.status == 'DORMANT'){
                 rec.status = 'INACTIVE_6_MONTHS';
            }
            else if(cardObj.cardNature == 'prepaid' && cardObj.status != 'DORMANT'){
                rec.status = cardObj.status;
            }
            else if(cardObj.cardNature != 'prepaid'){
                rec.status = cardObj.status;
            }
            //rec.status = cardObj.status;
            //CH05: END
            rec.maskedCardNumber = cardObj.maskedCardNumber;
            rec.blockDate = cardObj.blockDate;
            rec.parentStatus = cardObj.parentStatus;
            if(cardObj.isPrimary == true){
                rec.isPrimary = false;
            }
            else{
                rec.isPrimary = true;
            }
            rec.delinquent = cardObj.isDelinquent;
            rec.displayIconName = 'utility:close';
            
        }
        return rec;
        //CH02 END
    },
    //CH01 END
     //CH03: Start
    loadDebitCardsBasedOnSelectedOption : function(component, recordId){
         var helper = this;
         var selectedDebitCardOption = component.get("v.selectedDebitCardStatus");
         console.log('Selected Debit Card in helper:',selectedDebitCardOption);
         
         //component.set('v.data', []);
         if(selectedDebitCardOption === 'A' || selectedDebitCardOption === 'B'){
           component.find('apexService').request(component.get('c.loadDebitCardList'), { 
              recordId:recordId,
              option:component.get("v.selectedDebitCardStatus")
          },
          function(response) {
		    var result = response.getReturnValue();
            console.log('Result Value In Active/Block:',result);
            // array of card data
            var data = [];
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData.cards)) {
                var cards = result.responseData.cards;
                for (var i = 0; i < cards.length; i++) {
                    var cardObj = cards[i];
                    console.log('Debit Card Status:',cardObj.status);
                    if(selectedDebitCardOption === 'B' && (cardObj.status === 'Active' || cardObj.status === 'Inactive')){
                       console.log('Debit Card Data:',cardObj);
                       data.push(helper.formatActiveDebitData(component, cardObj)); 
                    }
                    else if(selectedDebitCardOption === 'A' && (cardObj.status === 'Blocked' || cardObj.status === 'Cancelled')){
                       console.log('Debit Card Block Status');
                       data.push(helper.formatActiveDebitData(component, cardObj));
                    }
                    
                }
                component.set('v.selectedDebitCardData',data);
                component.set('v.filterOptionValue',selectedDebitCardOption);
            }
            else{
                  console.log('Empty Data - No Cards Found');
                  component.set('v.selectedDebitCardData',[]);
                  component.set('v.filterOptionValue',selectedDebitCardOption);
            }
            
			}); 
        } //If Ends
        else if(selectedDebitCardOption === 'P'){
            //component.set('v.data', []);
            console.log('We need to call Purge API');
            component.find('apexService').request(component.get('c.loadDebitCardPurgeList'), { 
              recordId:recordId,
              option:component.get("v.selectedDebitCardStatus")
          },
          function(response){
		    var result = response.getReturnValue();
            console.log('Result Value In Purge:',result);
            // array of card data
            var data = [];
            if(true === result.isSuccess && !$A.util.isEmpty(result.responseData.cards)) {
                var cards = result.responseData.cards;
                for(var i = 0; i < cards.length; i++){
                    var cardObj = cards[i];
                    console.log('Debit Card Purge Data:',cardObj);
                    data.push(helper.formatPurgeDebitData(component, cardObj)); 
                }
                component.set('v.selectedDebitCardData',data);
                component.set('v.filterOptionValue',selectedDebitCardOption);
            }
            else{
                  console.log('Empty Data - No Purge Cards Found');
                  component.set('v.selectedDebitCardData',[]);
                  component.set('v.filterOptionValue',selectedDebitCardOption);
            }
        }); 
      } //Else if Ends
         
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
        //console.log('Format Purge Data:',rec);
        return rec;

    },
    formatActiveDebitData: function(component, cardObj) {
        var rec = {};
        rec.id = cardObj.id;
        rec.productType = cardObj.productType;
        rec.status = cardObj.status;
        rec.maskedCardNumber = cardObj.maskedCardNumber;
        return rec;

    },
     
    //CH03: END
     //CH04: Start
     formatPurgeCreditData: function(component, cardObj) {
        var rec = {};
        rec.id = cardObj.id;
        rec.productType = cardObj.cardDisplayName;
        if(cardObj.isPrimary == false){
            rec.cardType = 'Supplementary Card';
        }
        else if(cardObj.isPrimary == true){
             rec.cardType = 'Credit Card';
        }
        
        rec.status = cardObj.status;
        rec.maskedCardNumber = cardObj.maskedCardNumber;
        rec.defaultAccount = cardObj.defaultAccount;
        rec.isPrimary = cardObj.isPrimary;
        rec.issueDate = cardObj.issueDate;
        rec.cardCurrency = cardObj.cardCurrency;
        rec.creditLimit = cardObj.creditLimit;
        rec.availableLimit = cardObj.availableLimit;
        rec.billedAmount = cardObj.billedAmount;
        rec.unbilledAmount = cardObj.unbilledAmount;
        rec.holdAmount = cardObj.holdAmount;
        rec.minimumDues = cardObj.minimumDues;
        rec.totalDues = cardObj.totalDues;
        rec.pastDues = cardObj.pastDues;
        rec.paymentDueDate = cardObj.paymentDueDate;
        rec.lastPaymentDate = cardObj.lastPaymentDate;
        rec.lastPaymentAmount = cardObj.lastPaymentAmount;
        rec.product = cardObj.product;
        rec.currentMonthPointsBalance = cardObj.currentMonthPointsBalance;
        rec.cashLimit = cardObj.cashLimit;
        rec.currentMonthCashbackAmount = cardObj.currentMonthCashbackAmount;
        rec.totalEarnedCashbackAmount = cardObj.totalEarnedCashbackAmount;
        rec.accountBlockCode1 = cardObj.accountBlockCode1;
        rec.accountBlockCode2 = cardObj.accountBlockCode2;
        rec.accountBlockDate1 = cardObj.accountBlockDate1;
        rec.accountBlockDate2 = cardObj.accountBlockDate2;
        rec.delinquent = false;
        rec.displayIconName = 'utility:close';
        console.log('Format Purge Data:',rec);
        return rec;
	 },
     //CH04: END
})
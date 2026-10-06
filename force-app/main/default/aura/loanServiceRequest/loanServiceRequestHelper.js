/* 		
 *			   #CH02# Added #ANISS MBARKI# 22/02/2023 display cardType and isDelinquent after filtring the table.
 *			   #CH03# Added #Jahangeer Mohammed# #29-05-2023# Logic to fetch debit Card list based on the selected option
                #CH04# Added #Omar Aitogram 21-o1-2026 fixing hardcoded loans tabset label
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
                        component.set('v.isAlburaqProduct',(data.Case_Model__c=='alburaq'?true:false));
                        //console.log('dataType'+data.Type);
                        console.log('test---->'+data.Case_Model__c );
                        console.log('Bank Info Default load if');
                        //omar start CH04
                        var isAlburaqProduct = component.get("v.isAlburaqProduct");
                        var loanOrFinance = (isAlburaqProduct) ? 'Finances' : 'Loans';
                        console.log('isAlburaqProduct ===> '+ isAlburaqProduct);
                        console.log('loanOrFinance ===> '+ loanOrFinance);
                        component.set('v.loanOrFinance', loanOrFinance);
                        //omar end CH04

                        //start CH05
                        var fixedDepositLabel = (isAlburaqProduct) ? 'Wakala Investment' : 'Fixed Deposits';
                        console.log('fixedDepositLabel ===> '+ fixedDepositLabel);
                        component.set('v.fixedDepositLabel', fixedDepositLabel);
                        //End CH05

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
        debugger;
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
            rec.status = cardObj.status;
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
            rec.status = cardObj.status;
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
         component.find('apexService').request(component.get('c.loadDebitCardList'), { 
              recordId:recordId,
              option:component.get("v.selectedStatus")
          },
          function(response) {
		    var result = response.getReturnValue();
            console.log(result);
            // array of card data
            var data = [];
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData.cards)) {
                var cards = result.responseData.cards;
                for (var i = 0; i < cards.length; i++) {
                    var cardObj = cards[i];
                    console.log(cardObj);
                    data.push(helper.formatDebitData(component, cardObj));
                }
                component.set('v.selectedDebitCardData',data);
            }
            
		});
    },
    formatDebitData: function(component, cardObj) {
        var rec = {};
        rec.id = cardObj.id;
        rec.productType = cardObj.productType;
        rec.status = cardObj.status;
        rec.maskedCardNumber = cardObj.maskedCardNumber;
        return rec;

    }
    //CH03: END
})
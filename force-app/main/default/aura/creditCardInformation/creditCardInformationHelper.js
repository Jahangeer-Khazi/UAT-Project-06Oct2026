/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History:
 *			   #CH02# #MBARKI ANISS# #16-08-2022# Add CardType & exclude PrepaidCard/Supplementary cards from the list (if Type = "Credit Card Services" & RecordType == "Credit_Card_Services")
 *			   #CH03# #Jahangeer Mohammed# #15-01-2023# setting the Sub type value for credit Limit Decrease(NBA-6757)
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
                    console.info('Response Data Default CC INFO', result.responseData); //responseData is a object
                    var account = {};
                    if (data.hasOwnProperty( 'Account') ) {
                        //console.log('data.Account'+JSON.Stringify(data.Account));
                        account = data.Account;
                        //console.log('Account Data:'+JSON.stringify(account));
                        //console.log('Account Region Flag:'+account.Region_Flag__c);
                        component.set('v.caseRecordType', data.RecordType.DeveloperName);
                        component.set('v.caseType',data.Type);
                        //console.log('dataType'+data.Type);
                        //CH03: Start
                        component.set('v.caseSubType',data.Sub_Type__c);
                        component.set('v.caseStatus', data.Status);
                        //CH03: END
                    } else {
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
	    var helper = this;
		component.find('apexService').request(component.get('c.loadTabsConfig'), { },
		function(response) {
		    var result = response.getReturnValue();

            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                var tabsConfig = result.responseData;
                component.set('v.tabsConfig', tabsConfig);
                // load data in the first visible tab
                if (true === tabsConfig.Bank_Accounts__c) {
                    //helper.reloadComponentById(component, 'bankAccountsList');
                    return;
                }
                if (true === tabsConfig.Bank_Cards__c) {
                    //helper.reloadComponentById(component, 'bankCardsList');
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
                    //CH01 Start Added by Jahangeer Mohammed on 29-08-2021 to capture filter option response
                    var creditCardData = result.responseData.currentCards;
                    var creditCardDataFilterData = [];
                    
                    //#CH02 :START 
                    var caseRecordType = component.get('v.caseRecordType');
                    var caseType = component.get('v.caseType');
                    //#CH02 :END 
                    
                    for (var i = 0; i < creditCardData.length; i++) {
                    	var cardObj = creditCardData[i];
                        //console.log('--- CARD OBJ --> ',cardObj);
                        //#CH02 :START
                        if(caseType == 'Credit Card Services' && caseRecordType == 'Credit_Card_Services' && ( cardObj.cardNature == 'prepaid' || cardObj.isPrimary == false ) ){
                            /*
                                display only currentCards that meet the following conditions :
                                isPrimary = true
                                cardNature does not include prepaid 
                            */
                            continue;
                        }
                        //#CH02 :END
                    	creditCardDataFilterData.push(helper.formatData(component, cardObj));
                    }
                    //Alert the user with value
                    //returned from the user
                    //console.log('Response Data in CC INFO', result.responseData); //responseData is a object
                    console.log('Credit Card Filter Data:',creditCardDataFilterData);
                    component.set('v.dataInformation',creditCardDataFilterData);
                    component.set('v.dataInformationBasedOnFilter',creditCardDataFilterData);
                    //CH01 END
                    var account = {};
                    if (data.hasOwnProperty( 'Account') ) {
                        account = data.Account;
                        component.set('v.caseRecordType', data.RecordType.DeveloperName);
                        component.set('v.caseType',data.Type);
                        console.log('CC INFO Inside IF');
                    } else {
                        console.log('CC INFO Inside ELSE');
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
            
		});
        
    },
    //CH01 Start 
     formatData: function(component, cardObj) {
        var rec = {};

        //CH02: Start
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
        //CH02: End

        //CH02: Start
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
        //CH02: END
    },
    //CH01 END
})
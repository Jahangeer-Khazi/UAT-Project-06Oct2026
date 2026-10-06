({
	loadData : function(component, recordId) {

		//to get data details if it's a case or account

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
                    if (data.hasOwnProperty( 'Account') ) { //to Check if the data it's a Case record
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

    }
})
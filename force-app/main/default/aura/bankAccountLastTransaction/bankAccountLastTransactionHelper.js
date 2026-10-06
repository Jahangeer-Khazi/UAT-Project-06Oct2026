/* 	Organization : ABC Bank
 * 		Created By:Jayanth Manickam
 *		Created Date:17/10/2023
 * 		Change History:
 */
(
    {
        getDefaultSearchJson: function(accountId) {
            var searchParametersJson = {
                "id": accountId,
                "offSet": 0,
                "pageSize": 1
    
            };
            return searchParametersJson;
        },


	 loadData : function(component, customerId, accountId) {
        console.log('bankAccountDetails: loadData(customerId=' + customerId + ', accountId=' + accountId + ')');
        var account = component.get('v.account');
        var helper = this;
        
        //CH01 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product
        var regionName = account.Region_Flag__c;
        if(component.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        //CH01 -End
        var defaultSearchParametersJson = helper.getDefaultSearchJson(accountId);

		component.find('apexService').request(component.get('c.loadAccountLastTransaction'), {
		    "customerId": customerId,
		    "searchParametersJson": JSON.stringify(defaultSearchParametersJson),
		    "regionName": regionName
        },
		function(response) {
            /*
            var DEMO_ACCOUNT = {
                "customerId": "989248099",
                "id": "BH09ABCO00929029882",
                "alias": "Wife Account",
                "productType": "Account",
                "productName": "Saving Account",
                "category1": "",
                "category2": "",
                "account": {
                    "number": "100001009280",
                    "branch": "",
                    "currency": {
                        "code": "BHD",
                        "description": "Bahraini Dinar",
                        "decimalPlaces": 3
                    },
                    "iban": "BH09ABCO00929029882",
                    "availableBalance": 100,
                    "ledgerBalance": 100.000,
                    "startDate": "2018-01-09",
                    "endDate": "2018-02-09",
                    "status": "Active",
                    "overdraftLimit": 100000.000,
                    "overdraftExpiryDate": "2020-12-31",
                    "overdraftAvailableLimit": 1000000.000,
                    "paymentsAllowed": true
                }
            } ;
            */
		    var result = response.getReturnValue();
			console.log('Result',result);
            var data = {};
            console.log('Response Data',result.responseData);
            console.log('Boolean Value',!$A.util.isEmpty(result.responseData));
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                data = result.responseData;
                console.log('Data',data);
            }
            console.log('testttttttttttttttttttttt');
            //TODO - remove when API is available
            //data = DEMO_ACCOUNT;
            component.set('v.data', helper.formatData(component, data));
		});

    },
    formatData: function(component, accountObj){
        console.log('accountObjData==< '+JSON.stringify(accountObj));
        var result = {};
        if(accountObj.transactions[0]!=null){
            result.id = accountObj.transactions[0].id;
            result.TransactionDate = accountObj.transactions[0].transactionDate;
            result.TransactionType = accountObj.transactions[0].transactionType;
            result.TransactionStatus = accountObj.transactions[0].status;
            result.TransactionReference = accountObj.transactions[0].reference;
            result.TransactionCurrency = accountObj.transactions[0].transactionCurrency.code;
            result.TransactionAmount = accountObj.transactions[0].amount;
            result.TransactionDescription = (typeof accountObj.transactions[0].transactionDescription1 !='undefined'?accountObj.transactions[0].transactionDescription1:''+''+typeof accountObj.transactions[0].transactionDescription2 !='undefined'?accountObj.transactions[0].transactionDescription2:''+''+typeof accountObj.transactions[0].transactionDescription3 !='undefined'?accountObj.transactions[0].transactionDescription3:''+''+typeof accountObj.transactions[0].transactionDescription4 !='undefined'?accountObj.transactions[0].transactionDescription4:''+''+typeof accountObj.transactions[0].transactionDescription5 !='undefined'?accountObj.transactions[0].transactionDescription5:''+''+typeof accountObj.transactions[0].transactionDescription6 !='undefined'?accountObj.transactions[0].transactionDescription6:'').trim();
        }
       
       
        return result;

    }
})
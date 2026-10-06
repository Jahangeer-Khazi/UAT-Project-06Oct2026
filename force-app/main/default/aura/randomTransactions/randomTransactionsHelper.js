/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History: 
 *			   #CH01# #Jahangeer Mohammed# #23-08-2022# Added a Logic to Display recent 3 months Transactions and Record Limit is 25.
 *			  
 *
 */
({
    //CH01: Start
    BATCH_SIZE: 30,
    RECORD_SIZE:24,
    getDefaultSearchJson: function(component, customerId, accountId,jsonToDate,jsonFromDate) {
        var searchParametersJson = {
            "id": accountId,
            "offSet": 0,
            "pageSize": this.BATCH_SIZE,
            //"filter": "SC", //TODO remove when API allows -
            //"fromAmount": "0", //TODO remove when API allows
            //"toAmount": "10000000000", //TODO remove when API allows
            "fromDate": jsonToDate,
            "toDate": jsonFromDate,
            "debitCreditIndicator": "ALL" //TODO remove when API allows

        };//CH01: END
        return searchParametersJson;
    },
	loadData : function(component, customerId) {
        var helper = this;
        var regionName = component.get('v.regionName');
        console.log('Region Name from Flow:'+regionName);
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

            component.set('v.accounts', accounts);
            //console.log('Account IN Load Data:',JSON.stringify(accounts));
            helper.loadTransactions(component, customerId, accounts, []);
		});

	},
    loadTransactions: function(component, customerId, accounts, previouslyLoadedTransactions) {
        var helper = this;
        //console.log('Array Size for Account List:'+accounts.length);
        //Commented by Jahangeer Mohammed on 22-08-2022
        /*if ($A.util.isEmpty(accounts)) {
            component.set('v.gridDataRows', helper.getRandomTransactions(previouslyLoadedTransactions, helper.BATCH_SIZE));
            return;
        }*/
        var account = accounts.shift();// take top account If from the list
        //console.log('Top Most Account Id:'+account.id);
        //CH01: Start
         var today = new Date(
            new Date().getFullYear(),
            new Date().getMonth() + 1, 
            new Date().getDate() + 1
        );
        var dd = today.getDate();
        var mm;
        var yyyy;
        if(today.getMonth()==0){
        	mm = today.getMonth()+12;
            yyyy = today.getFullYear()-1;
        }
        else{
            mm = today.getMonth();
            yyyy = today.getFullYear();
        }
        
        if(dd<10) 
        {
            dd='0'+dd;
        } 
        
        if(mm<10) 
        {
            mm='0'+mm;
        } 
        var jsonFromDate = yyyy+'-'+mm+'-'+dd;
        console.log('From Date>>>>>'+jsonFromDate);
        
        var threeMonthsDate = new Date(
            new Date().getFullYear(),
            new Date().getMonth() + 1 - 12,
            new Date().getDate()
        );
        var dddd = threeMonthsDate.getDate();
        var mmmm = threeMonthsDate.getMonth();
        var yyyyyy = threeMonthsDate.getFullYear();
        
        if(dddd<10) 
        {
            dddd='0'+dddd;
        } 
        
        if(mmmm<10) 
        {
            mmmm='0'+mmmm;
            if(mmmm == '00'){
                console.log('Month is zero');
                var yyyyyy = threeMonthsDate.getFullYear()-1;
                //var mmmm = threeMonthsDate.getMonth()+3;
                var mmmm = threeMonthsDate.getMonth()+12;
                console.log(yyyyyy);
                console.log(mmmm);
            }
        } 
        var jsonToDate = yyyyyy+'-'+mmmm+'-'+dddd;
        console.log('ToDate>>>>>'+jsonToDate);
        //CH01 END
        var searchParametersJson = helper.getDefaultSearchJson(component, customerId, account.id,jsonToDate,jsonFromDate);
		component.find('apexService').request(component.get('c.loadAccountTransactions'), {
		    "customerId": customerId,
            "searchParametersJson": JSON.stringify(searchParametersJson),
            "regionName": component.get('v.regionName')
        },
		function(response) {

		    var result = response.getReturnValue();
            console.log('Response Data from Bank Account Transactions:',JSON.stringify(result));
            // array of card data
            // continue existing collection or start new one if offset is not specified
            var data = $A.util.isArray(previouslyLoadedTransactions)? previouslyLoadedTransactions : [];
            //var data = isNaN(offset)? [] :component.get('v.gridDataRows') ;
            var transactionsBatch = [];
            //var sortTransactionsData = JSON.stringify(result.responseData);
            //CH01: Start
            var sortTransactionsData = result.responseData;
            //console.log('Sort Transaction Data:'+sortTransactionsData);
            
            var sortresult = sortTransactionsData.sort((a,b)=> new Date(b.transactionDate).getTime() - new Date(a.transactionDate).getTime());

            console.log('After Sorting in Descending:'+sortresult);
            
            if (true === result.isSuccess && !$A.util.isEmpty(sortresult)) {
                var transactionsBatch = result.responseData;
                console.log('Transaction Batch Length:'+transactionsBatch.length);
                for (var i = 0; i < transactionsBatch.length; i++) {
                    if(i <= helper.RECORD_SIZE){
                    	var transactionObj = transactionsBatch[i];
                    	data.push(helper.formatData(component, transactionObj, account));
                    }
                }
            }
            //helper.loadTransactions(component, customerId, accounts, data)
            //console.log('Response Data from Bank Account Transactions:',JSON.stringify(data));
            component.set('v.gridDataRows',data);
            //CH01: END
		});

    },
    formatData: function(component, transaction, account){
        var result = {};
        result.id = transaction.id;
        result.accountNumber = account.account.number;
        result.productName = account.productName;
        var transDate = new Date(transaction.transactionDate);
        result.transactionDate = transDate;
        //result.transactionDate = transaction.transactionDate;
        result.transactionType = transaction.transactionType;
        result.transactionCurrency = transaction.transactionCurrency.code;
        result.transactionDescription = [transaction.transactionDescription1, transaction.transactionDescription2].join(' ');
        result.amount = transaction.amount;

        return result;

    },
    getRandomTransactions: function(transactions, resultSize){
        if (!transactions) {
            return [];
        }
        var helper = this;
        return helper.getRandomSubarray(transactions, resultSize);
    },
    getRandomSubarray: function(arr, size) {
        var shuffled = arr.slice(0), i = arr.length, temp, index;
        while (i--) {
            index = Math.floor((i + 1) * Math.random());
            temp = shuffled[index];
            shuffled[index] = shuffled[i];
            shuffled[i] = temp;
        }
        return shuffled.slice(0, size);
    }

})
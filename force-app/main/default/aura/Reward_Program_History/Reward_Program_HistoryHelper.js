/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History: 
 *			   #CH01# Added #05-04-2021# getSearchJson, loadTransactionSearch, formatCurrency, afterSixMonths, beforeSixMonths   
 			          isUptoSixMonths, isBeforeSixMonths and formatDateToDDMMYY Method/function in the Helper by Jahangeer Mohammed
               #CH02# Added #27-04-2021# Java script code to display current date Transactions and added two extra parameters
               		  jsonToDate and jsonFromDate in getDefaultSearchJson function by Jahangeer Mohammed.
               #CH03# Added #06-06-2021# Added on Default Load display 50 records from current date to 1 year.On search critaria diaplay
               		  1000 records from current date to three months by Jahangeer Mohammed.
               #CH04# Added #28-10-2021# IBJCRM-71 Region name changes by YZ/HP.
               #CH05# Added #06-06-2022# by Hamza Chaoui.
 */
({
    BATCH_SIZE:50,
    //CH01: Start
    BATCH_SIZE_SEARCH:100, 
    RECORD_SIZE:1000,
    //CH01: END
    //CH03: Start
    API_CALL_RECORD_SIZE_LMT:900,
    //CH03: END
    getDefaultSearchJson: function(component, customerId, accountId,jsonToDate,jsonFromDate) {
        var searchParametersJson = {
            "id": accountId,
            "offSet": 0,
            "pageSize": this.BATCH_SIZE, //"50",//'this.BATCH_SIZE',
            "fromDate": jsonToDate,
            "toDate": jsonFromDate,
            "debitCreditIndicator": "ALL" //TODO remove when API allows

        };
        return searchParametersJson;
    },
    //CH01: Start
     getSearchJson: function(component, customerId, accountId) {
        var searchParametersJson = {
            "id": accountId,
            "offSet": 0,
            "pageSize": this.BATCH_SIZE_SEARCH, //"100",//'this.BATCH_SIZE',
            "debitCreditIndicator": "ALL" //TODO remove when API allows

        };
        return searchParametersJson;
    },
    //CH01: END
    /**
     * @param providedSearchParametersJson OPTIONAL, use only from user defined search and to load more
     * @param previouslyLoadedTransactions OPTIONAL, if provided then we are in "load-more" mode
     */
    loadRewardHistory: function(component, customerId, accountId, providedSearchParametersJson, previouslyLoadedTransactions, prevTransactionLength) { 
		console.log('loadTransactions(customerId=' + customerId + ', accountId=' + accountId + ')');
        var account = component.get('v.account');
        var helper = this;
        var defaultSearchParametersJson = helper.getSearchJson(component, customerId, accountId);
        var cardId=component.get('v.cardId');
        var searchParametersJson = undefined === providedSearchParametersJson ? defaultSearchParametersJson : providedSearchParametersJson;
		console.log('prevTransactionLength', prevTransactionLength);
        prevTransactionLength = prevTransactionLength && prevTransactionLength > 0 ? prevTransactionLength : 0;
        
        if(prevTransactionLength && prevTransactionLength > 0){
            searchParametersJson.offset = prevTransactionLength;
        }
        console.log('searchParametersJson', searchParametersJson);

            component.find('apexService').request(component.get('c.loadRewardHistory'), {
                "customerId": customerId,
                "regionName" : account.Region_Flag__c,
                "cardId":cardId
            },
            function(response) {
                var result = response.getReturnValue();
                console.log("result------------->>>", JSON.stringify(result));
                // array of card data
                // continue existing collection or start new one if offset is not specified
                var data = $A.util.isArray(previouslyLoadedTransactions)? previouslyLoadedTransactions : [];
                //var data = isNaN(offset)? [] :component.get('v.gridDataRows') ;
                var transactionsBatch = [];
                var recordLength = 0;
                if(true === result.isSuccess){
                    recordLength = parseInt(result.recordLength);
                }
                console.log('recordLength------->'+recordLength);
                if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                    transactionsBatch = result.responseData;
                    for (var i = 0; i < transactionsBatch.length; i++) {
                        var transactionObj = transactionsBatch[i];
                        data.push(helper.formatData(component, transactionObj));
                    }
                }
                // check if data load is complete
                console.log('>>>>> record helper.BATCH_SIZE:', helper.BATCH_SIZE_SEARCH);
                console.log('>>>>> record length:', recordLength);
                var offsetValue = searchParametersJson.offset;
                var offset = offsetValue;
                if (recordLength != 0) {
                    // may have more records, send another query 
                    //var totalRecordLength = (recordLength + prevTransactionLength);
                    //CH03: Start
                    offset = offset + 1;
                    if(offset < helper.SEARCH_OFFSET_COUNT){
                    	helper.loadTransactionSearch(component, customerId, accountId, searchParametersJson, data, offset);
                    }
                    else{
                        component.set('v.gridDataRows', data);
                    }
                } else {
                    component.set('v.gridDataRows', data);
                } //CH03: END
            });

    },
    //CH01: Start
    loadTransactionSearch: function(component, customerId, accountId, providedSearchParametersJson, previouslyLoadedTransactions, prevTransactionLength) {
        console.log('loadTransactions(customerId=' + customerId + ', accountId=' + accountId + ')');
        var helper = this;
        var defaultSearchParametersJson = helper.getSearchJson(component, customerId, accountId);
		var defaultSearchParametersAsBlank = helper.getDefaultSearchJson(component, customerId, accountId);
        var searchParametersJson = undefined === providedSearchParametersJson ? defaultSearchParametersJson : providedSearchParametersJson;
		console.log('prevTransactionLength', prevTransactionLength);
        prevTransactionLength = prevTransactionLength && prevTransactionLength > 0 ? prevTransactionLength : 0;
        
        if(prevTransactionLength && prevTransactionLength > 0){
            searchParametersJson.offSet = prevTransactionLength;
        }
        var account = component.get('v.account'); // #CH04#

        //CH05 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product
        var regionName = account.Region_Flag__c;
        if(component.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        //CH05 -End
		component.find('apexService').request(component.get('c.loadRewardHistory'), {
                "customerId": customerId,
                "regionName" : regionName // #CH04#
        },
        function(response) {
    
                var result = response.getReturnValue();
                
                console.log("result for transaction serach", result);
                // array of card data
                // continue existing collection or start new one if offset is not specified
               // var data = $A.util.isArray(previouslyLoadedTransactions)? previouslyLoadedTransactions : [];
                 var data =  [];
                //var data = isNaN(offset)? [] :component.get('v.gridDataRows') ;
                var transactionsBatch = [];
                var recordLength = 0;
                if(true === result.isSuccess){
                    recordLength = parseInt(result.recordLength);
                    console.log('Record Length:'+recordLength);
                }
                if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                    transactionsBatch = result.responseData;
                    console.log('Transaction Length:'+transactionsBatch.length);
                    for (var i = 0; i < transactionsBatch.length; i++) {
                        //CH03: Start
                        var transactionObj = transactionsBatch[i]; 
                        data.push(helper.formatData(component, transactionObj));
                        //CH03: END
                    }
                }
                // check if data load is complete
                console.log('>>>>> record helper.BATCH_SIZE_SEARCH:', helper.BATCH_SIZE_SEARCH);
                console.log('>>>>> record length:', recordLength);
            	//CH03: Start
                var totalRecordLength = (recordLength + prevTransactionLength);
            	if (helper.BATCH_SIZE_SEARCH == recordLength) {
                    // may have more records, send another query 
                    //var totalRecordLength = (recordLength + prevTransactionLength);
                    console.log('Total Record Length:' +totalRecordLength);
                    if(totalRecordLength <= helper.API_CALL_RECORD_SIZE_LMT){
                        helper.loadTransactionSearch(component, customerId, accountId, searchParametersJson, data,totalRecordLength);
                    }
                    else{
                        component.set('v.gridDataRows', data);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Information!",
                            "message": $A.get("$Label.c.TOAST_MESSAGE"),
                            "duration": '10000',
                            "type": 'error'
                            
                        });
                    	toastEvent.fire();
                   }
                }else{
                    console.log('Total Record Length in else',totalRecordLength);
                    if(totalRecordLength <= helper.RECORD_SIZE){
                    	component.set('v.gridDataRows', data);
                    }
                }
            //CH03: END
            });

      },
    //CH01: END
    /**
     * set object field if aura attribute is not empty
     * ex: helper.setIfNotEmpty(component.get('v.pageSize'), obj, 'pageSize');
     */
    setIfNotEmpty: function(value, obj, fName) {
        if (!$A.util.isEmpty(value)) {
            obj[fName] = value;
        }
    },
    formatData : function(component,transaction){
      //  alert('inside'+JSON.stringify(transaction));
        //CH01: Start
         var helper = this;
        //CH01: End
       // console.log('transaction', transaction); 
        var result = {};
        result.requestedDate = new Date(transaction.requestedDate).toLocaleString();
        result.preferredPaymentOption = transaction.preferredPaymentOption;
        result.effectiveDate = new Date(transaction.effectiveDate).toLocaleString();
        console.log('result##'+result);
       return result;
    },
    //CH01: END
    getDataColumns: function(component) {
        return [
                {title:'id', data: 'rowSelector', "orderable": false, "visible": false, "searchable": false},
            {title:'Change Request Date', data:'requestedDate'},
                {title:'Chosen Reward Program ', data:'preferredPaymentOption'},
             	{title:'Change Effective Date', data:'effectiveDate'}
            ];
    },
    
    getColumnDefs: function(component) {
        var columnDefs = [
            
            {
                targets: '_all',
                "defaultContent": ""
            }, 
            { targets: 1, width: '20%'},
            { targets: 2, width: '20%'},
            { targets: 3, width: '20%'}
        ];
        return columnDefs;

    },
    
})
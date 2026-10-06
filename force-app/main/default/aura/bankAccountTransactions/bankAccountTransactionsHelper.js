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
               #CH06# Added #Jahangeer Mohammed# #05-06-2022# Added offset parameter in getSearchJson function (PI-4023)
 *             #CH07# Added #11-11-2025# Transaction Excel Generation and added download button by Maksud               
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
    //CH06: Start
     getSearchJson: function(component, customerId, accountId) {
        var searchParametersJson = {
            "id": accountId,
            "offSet": 0,
            "offset": 0,
            "pageSize": this.BATCH_SIZE_SEARCH, //"100",//'this.BATCH_SIZE',
            "debitCreditIndicator": "ALL" //TODO remove when API allows

        };
        return searchParametersJson;
    },
    //CH06: END
    //CH01: END
    /**
     * @param providedSearchParametersJson OPTIONAL, use only from user defined search and to load more
     * @param previouslyLoadedTransactions OPTIONAL, if provided then we are in "load-more" mode
     */
    loadTransactions: function(component, customerId, accountId, providedSearchParametersJson, previouslyLoadedTransactions, prevTransactionLength) {
        console.log('loadTransactions(customerId=' + customerId + ', accountId=' + accountId + ')');
        var helper = this;
        //CH02: Start
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
            //CH03: Start
            new Date().getMonth() + 1 - 12,
            //CH03: END
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
                var mmmm = threeMonthsDate.getMonth()+12;
                console.log(yyyyyy);
                console.log(mmmm);
            }
        } 
        var jsonToDate = yyyyyy+'-'+mmmm+'-'+dddd;
        console.log('ToDate>>>>>'+jsonToDate);
        //CH02: END
        
        //CH02: Start #Added two extra parameters jsonToDate and jsonFromDate
        var defaultSearchParametersJson = helper.getDefaultSearchJson(component, customerId, accountId,jsonToDate,jsonFromDate);
        //CH02: END
        var searchParametersJson = undefined === providedSearchParametersJson ? defaultSearchParametersJson : providedSearchParametersJson;
		console.log('prevTransactionLength', prevTransactionLength);
        
        prevTransactionLength = prevTransactionLength && prevTransactionLength > 0 ? prevTransactionLength : 0;
        
        console.log('prevTransactionLength value',prevTransactionLength);
        
        if(prevTransactionLength && prevTransactionLength > 0){
            searchParametersJson.offset = prevTransactionLength;
               searchParametersJson.offSet = prevTransactionLength;
        }
        
        console.log('offset value',searchParametersJson.offset);
            console.log('searchParametersJson', searchParametersJson);
            var account = component.get('v.account'); // #CH04#

            //CH05 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product
            var regionName = account.Region_Flag__c;
            if(component.get('v.isAlburaqProduct') == true){
                regionName += '_alburaq';
            }
            //CH05 -End

        	const jsn = JSON.stringify(searchParametersJson);
        	console.log("searchParametersJson ",jsn);
        	console.log("searchParametersJson ",encodeURIComponent(jsn));
        
        	component.set("v.searchParametersJson",JSON.stringify(searchParametersJson)); //search param json would use in exporting excel.
        
            component.find('apexService').request(component.get('c.loadAccountTransactions'), {
                "customerId": customerId,
                "searchParametersJson": JSON.stringify(searchParametersJson),
                "regionName" : regionName // #CH04#
            },

            function(response) {
    
                var result = response.getReturnValue();
                console.log("result", result);
                // array of card data
                // continue existing collection or start new one if offset is not specified
                var data = $A.util.isArray(previouslyLoadedTransactions)? previouslyLoadedTransactions : [];
                //var data = isNaN(offset)? [] :component.get('v.gridDataRows') ;
                var transactionsBatch = [];
                var recordLength = 0;
                if(true === result.isSuccess){
                    recordLength = parseInt(result.recordLength);
                    console.log('Record Length from Server:'+recordLength);
                }
                if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                    transactionsBatch = result.responseData;
                    for (var i = 0; i < transactionsBatch.length; i++) {
                        //CH03: Start
                         var transactionObj = transactionsBatch[i]; 
                         data.push(helper.formatData(component, transactionObj));
                        //CH03: END
                    }
                }
                // check if data load is complete
                console.log('>>>>> record helper.BATCH_SIZE:', helper.BATCH_SIZE);
                console.log('>>>>> record length:', recordLength);
                if (helper.BATCH_SIZE == recordLength && prevTransactionLength<0) {
                    // may have more records, send another query 
                    var totalRecordLength = (recordLength + prevTransactionLength);
                    helper.loadTransactions(component, customerId, accountId, searchParametersJson, data, totalRecordLength);
                } else {
                    console.log('Setting data in JQ Table');
                    component.set('v.gridDataRows', data);
                }
            });

            
        // });
        
		

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
            searchParametersJson.offset = prevTransactionLength;
            searchParametersJson.offSet = prevTransactionLength;
        }
        var account = component.get('v.account'); // #CH04#
        //CH05 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product
        var regionName = account.Region_Flag__c;
        if(component.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        //CH05 -End

        component.set("v.searchParametersJson",JSON.stringify(searchParametersJson)); //search param json would use in exporting excel.
        
        console.log('searchParametersJson for transaction', searchParametersJson);
		component.find('apexService').request(component.get('c.loadAccountTransactions'), {
                "customerId": customerId,
                "searchParametersJson": JSON.stringify(searchParametersJson),
                "regionName" : regionName // #CH04#
        },
        function(response) {
    
                var result = response.getReturnValue();
                console.log("result for transaction serach", result);
                // array of card data
                // continue existing collection or start new one if offset is not specified
                var data = $A.util.isArray(previouslyLoadedTransactions)? previouslyLoadedTransactions : [];
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
    formatData: function(component, transaction){
        //CH01: Start
        var helper = this;
        //CH01: End
       // console.log('transaction', transaction); 
        
        var transacDate = new Date(transaction.transactionDate); 
        var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

        var transactionMonth = (transacDate.getMonth() + 1) + "";
        transactionMonth = transactionMonth.length >= 2 ? transactionMonth : "0" + transactionMonth;

        var transactionMn = transacDate.getMinutes() + "";
        transactionMn = transactionMn.length >= 2 ? transactionMn : '0' + transactionMn;

        var transactionH = transacDate.getHours() + "";
        transactionH = transactionH.length >= 2 ? transactionH : '0' + transactionH;
        
        var transactionDate = transacDate.getDate() + "";
        transactionDate = transactionDate.length >= 2 ? transactionDate : "0" + transactionDate; 
        
        //update value Date
        var valueDate = new Date(transaction.valueDate); 
        var valueMonth = (valueDate.getMonth + 1) + "";
        valueMonth = valueMonth.length >= 2 ? valueMonth : '0' + valueMonth; 

        var result = {};
        result.id = transaction.id;
        result.transactionDate = transactionDate + ' ' + months[transacDate.getMonth()] + ' ' + transacDate.getFullYear() + ' ' + transactionH + ':' + transactionMn;
        //result.transactionDate = transaction.transactionDate;
        result.transactionType = transaction.transactionType;
        result.valueDate = valueDate.getDate() + ' ' + valueMonth + ' ' + valueDate.getFullYear();
        result.status = transaction.status;
        if( transaction.transactionCurrency){

           result.transactionCurrency =transaction.transactionCurrency.code;  

        }else{

             result.transactionCurrency =transaction.accountCurrency.code;

        }
        result.transactionDescription = [transaction.transactionDescription1, transaction.transactionDescription2].join(' ');
        result.amount = transaction.amount;
        result.reference = transaction.reference; //RM edit, added
        //CH01: Start
        //result.originalAmount = transaction.originalAmount; //RM edit, added
        var tranAmt = transaction.originalAmount;
        if( transaction.transactionCurrency){
        var formatNum = helper.formatCurrency(tranAmt,transaction.transactionCurrency.decimalPlaces,undefined,undefined);
                }else{

            var formatNum = helper.formatCurrency(tranAmt,transaction.accountCurrency.decimalPlaces,undefined,undefined);

        }
        result.originalAmount = formatNum;
        //CH01: END
        
        result.transactionDescription1 = transaction.transactionDescription1;//RM edit, added
        result.transactionDescription2 = transaction.transactionDescription2;//RM edit, added
        result.transactionDescription3 = transaction.transactionDescription3;//RM edit, added
        result.transactionDescription4 = transaction.transactionDescription4;//RM edit, added
        result.transactionDescription5 = transaction.transactionDescription5;//RM edit, added
        result.transactionDescription6 = transaction.transactionDescription6;//RM edit, added
        transaction.fullDescription = 
            [transaction.transactionDescription1, 
                transaction.transactionDescription2,
                transaction.transactionDescription3,
                transaction.transactionDescription4,
                transaction.transactionDescription5,
                transaction.transactionDescription6,
            ].join(' ');
        result.transactionData = transaction;
             
       return result;

    },
    //CH01: Start          
    formatCurrency : function(number,decPlaces,decSep,thouSep){
       // console.log('Inside Format currency');
        decPlaces = isNaN(decPlaces = Math.abs(decPlaces)) ? 2 : decPlaces;
       
		decSep = typeof decSep === "undefined" ? "." : decSep;
       
		thouSep = typeof thouSep === "undefined" ? "," : thouSep;
        
        var sign = number < 0 ? "-" : "";
		var i = String(parseInt(number = Math.abs(Number(number) || 0).toFixed(decPlaces)));
       // console.log('Number to String:'+i);
       // console.log('Number Length:'+i.length);
		var j = (j = i.length) > 3 ? j % 3 : 0;
        return sign +
		(j ? i.substr(0, j) + thouSep : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thouSep) + (decPlaces ? decSep + Math.abs(number - i).toFixed(decPlaces).slice(2) : "");   
    },
    //CH01: END
    getDataColumns: function(component) {
        return [
                {title: 'id', data: 'rowSelector', "orderable": false, "visible": false, "searchable": false},
                //{title: '', data: null, defaultContent: "", "orderable": false, "searchable": false},
             {title: 'Date', data: 'transactionDate'},
                {title: 'Type', data: 'transactionType'},
             	{title: 'Status', data: 'status'},
                {title: 'Amount', data: 'originalAmount'},//, className: 'dt-body-right' //RM edit, was {title: 'Amount', data: 'amount'} // Ashish -  {title: 'Amount', data: 'originalAmount'}
                {title: 'Currency', data: 'transactionCurrency'},
                {title: 'Description', data: 'transactionDescription'},
                {title: 'Reference', data: 'reference'}, //RM edit
                //{title: 'Previous Balance', data: 'previousBalance'},
                //{title: 'Current Balance', data: 'currentBalance'},
            ];
    },
    
    getColumnDefs: function(component) {
        var columnDefs = [
            
            {
                targets: '_all',
                "defaultContent": ""
            }, 
            { targets: 1, width: '1%', type:'date'},
            { targets: 2, width: '1%'},
            { targets: 3, width: '1%' },
            { targets: 4, width: '1%' },
            { targets: 5, width: '1%' },
            { targets: 6, width: '1%' }
        ];
        return columnDefs;

    },
    validateFilters: function(component) {
        var helper = this;
        // Amounts
        console.log('Inside Validate filter method');
        var amountFrom = component.get('v.amountFrom');
        var amountTo = component.get('v.amountTo');
        if (!$A.util.isEmpty(amountFrom) && isNaN(amountFrom)) {
            helper.displayValidationError(component, $A.get("$Label.c.Amount_From_Value_must_be_numeric"));
            return false;
        }
        if (!$A.util.isEmpty(amountTo) && isNaN(amountTo)) {
            helper.displayValidationError(component, $A.get("$Label.c.Amount_To_Value_must_be_numeric"));
            return false;
        }
        // check if amountFrom is less than amountTo
        if (!$A.util.isEmpty(amountFrom) && !$A.util.isEmpty(amountTo) && Number(amountFrom) > Number(amountTo)) {
            helper.displayValidationError(component, $A.get("$Label.c.Amount_From_must_be_less_than_Amount_To"));
            return false;
        }

        // Dates
        var dateFromStr = component.get('v.dateFrom');
        var dateToStr = component.get('v.dateTo');
        var dateFrom = helper.stringToDate(dateFromStr);
        var dateTo = helper.stringToDate(dateToStr);
        //CH01: Start
        var dateFromStr2 = component.get('v.dateFrom');
        var dateFrom2 = helper.stringToDate(dateFromStr2);
        var dateSixMonths = helper.isUptoSixMonths(dateFrom2);
        //CH01: END
        
        if (!$A.util.isEmpty(dateFromStr) && !helper.isValidDate(dateFrom)) {
            helper.displayValidationError(component, $A.get("$Label.c.Date_From_Value_must_be_of_type_Date"));
            return false;
        }
        if (!$A.util.isEmpty(dateToStr) && !helper.isValidDate(dateTo)) {
            helper.displayValidationError(component, $A.get("$Label.c.Date_To_Value_must_be_of_type_Date"));
            return false;
        }
        // check if dateFrom is less than dateTo
        
        if (!$A.util.isEmpty(dateFrom) && !$A.util.isEmpty(dateTo) && dateFrom > dateTo) {
            helper.displayValidationError(component, $A.get("$Label.c.Date_From_must_be_before_Date_To"));
            return false;
        }
        //CH01: Start
        console.log('Date from after adding 3 months:'+dateFrom2);
        if (!$A.util.isEmpty(dateTo) && dateTo > dateFrom2) {
            helper.displayValidationError(component, $A.get("$Label.c.Date_Date_values_must_be_in_three_months_range"));
            return false;
        }
         if ($A.util.isEmpty(dateTo) && $A.util.isEmpty(dateFrom))  {
            helper.displayValidationError(component, $A.get("$Label.c.Date_Date_From_and_Date_To_fields_cannot_be_left_blank"));
            return false;
        }
        //CH01: END
       
        return true;
            
    },
    displayValidationError: function(component, message){
		component.find('apexService').showErrorMessage(message);
    },
    //CH01: Start
    afterSixMonths : function(component,str) {
        var helper = this;
        var d = helper.stringToDate(str);
        var dateFromStr2 = component.get('v.dateFrom');
        var dateFrom2 = helper.stringToDate(dateFromStr2);
        var dateSixMonths = helper.isUptoSixMonths(dateFrom2);
        var StrDate = dateFrom2.toString();
        var DDMMYY = helper.formatDateToDDMMYY(StrDate);
        component.set('v.dateTo',DDMMYY);
	},
     beforeSixMonths : function(component,str) {
        var helper = this;
        var d = helper.stringToDate(str);
        var dateToStr2 = component.get('v.dateTo');
        var dateTo = helper.stringToDate(dateToStr2);
        var dateBeforeSixMonths = helper.isBeforeSixMonths(dateTo);
        var StrDateTo = dateTo.toString();
        var DDMMYYTo = helper.formatDateToDDMMYY(StrDateTo);
        component.set('v.dateFrom',DDMMYYTo);
	},
    //CH01: END

    /**
     * convert string '2014-12-31' into date 
     */
    stringToDate: function(str) {
        if ($A.util.isEmpty(str)) {
            return undefined;
        }
        var parts =str.split('-');
        // JavaScript counts months from 0:
        // January - 0, February - 1, etc.
        if (3 != parts.length) {
            return undefined;
        }
        return new Date(parts[0], parts[1] - 1, parts[2]); 
    },
    isValidDate: function(date) {
        return date && Object.prototype.toString.call(date) === "[object Date]" && !isNaN(date);
    },
    //CH01: Start
    isUptoSixMonths:function(date){
        console.log('isUptoSix Months:'+date);
        if(date!=undefined){
            var d = new Date();
            d = date;
            var sixMonthdate = new Date();
            //sixMonthdate = d.setMonth(6);
            sixMonthdate = d.setMonth(d.getMonth() + 3);
            return sixMonthdate;
        }else{
            return null;
        }
    },
    
    isBeforeSixMonths:function(date){
        console.log('isBeforeSix Months:'+date);
        if(date!=undefined){
            var d = new Date();
            d = date;
            var sixMonthdate = new Date();
            sixMonthdate = d.setMonth(d.getMonth() - 3);
            return sixMonthdate;
        }else{
            return null;
        }
    },
    
    formatDateToDDMMYY: function(date) {
        var d = new Date(date),
        month = '' + (d.getMonth() + 1),
        day = '' + d.getDate(),
        year = d.getFullYear();
        if (month.length < 2) 
            month = '0' + month;
        if (day.length < 2) 
            day = '0' + day;
        return [year, month, day].join('-');
    },
    //CH01: END
    
    runSearch: function(component, customerId, accountId) {
        var helper = this;
        console.log('Inside run Search method');
        if (!helper.validateFilters(component)) {
            return;
        }
        
        var helper = this;
        //CH01: Start
        var searchParametersJson = helper.getSearchJson(component, customerId, accountId);
        //CH01: END
        console.log('Search Parameter JSON Value:'+searchParametersJson);
        helper.setIfNotEmpty(component.get('v.amountFrom'), searchParametersJson, 'fromAmount');
        helper.setIfNotEmpty(component.get('v.amountTo'), searchParametersJson, 'toAmount');
        helper.setIfNotEmpty(component.get('v.dateFrom'), searchParametersJson, 'fromDate');
        helper.setIfNotEmpty(component.get('v.dateTo'), searchParametersJson, 'toDate');
        helper.setIfNotEmpty(component.get('v.debitCreditIndicator'), searchParametersJson, 'debitCreditIndicator');
        helper.setIfNotEmpty(component.get('v.transactionStatus'), searchParametersJson, 'status');
        //CH01: Start
        helper.loadTransactionSearch(component, customerId, accountId, searchParametersJson);
        //CH01: END
    },
    

    handleJqDataTableEvent: function(component, event) {
        console.log("bankAccountTransaction.handleJqDataTableEvent=" + JSON.stringify(event));
        var message = event.getParam("message");
        var action = message.action;
        var thisHelper = this;
        if ( "getSelectedRowsResponse" === action) {
            
        } else if ( "broadcastSelectedRows" === action) {
            var selectedIds = message.rowIds;
            console.log("selectedIds=" + JSON.stringify(selectedIds));
            var gridDataRows = component.get('v.gridDataRows');
            var selectedRows = [];
            if (!$A.util.isEmpty(gridDataRows)) {
                for (var i = 0; i < selectedIds.length; i++) {
                    var id = selectedIds[i];
                    var foundRow = gridDataRows.find(function(row) {
                        return row.id === id;
                    });
                    if (foundRow) {
                        selectedRows.push(foundRow);
                    }

                }
            }
            thisHelper.onSelectRow(component, selectedRows);
        } else if ( "broadcastDeSelectedRows" === action) {
            var selectedIds = message.rowIds;
            thisHelper.onDeSelectRow(component, selectedIds);
        }

    },
    // notify other components about row selection
    onSelectRow: function(component, selectedRows) {
        console.log('Selected Row is:',selectedRows);
        if ($A.util.isEmpty(selectedRows)) {
            return;
        }
        var thisHelper = this;
        
        var rowsWithChildData = [];
        for (var i = 0; i < selectedRows.length; i++) {
            var row = selectedRows[i];
            console.log('Selected Row Data on selection:',selectedRows[i]);
            console.log('Row Data on selection:',row);
            rowsWithChildData.push({"id": row.id, "childData": thisHelper.formatChildData(row)});
        }
        // request child row data display
        var appEvent = $A.get("e.c:jqDataTableEvent");
        var message = {
            "action": "displayChild",
            "rowsWithChildData": rowsWithChildData,
        };
        appEvent.setParams(
            { 
                "message": message
            }
        );
        appEvent.fire();

        
    },
    onDeSelectRow: function(component, rowIds) {
        if ($A.util.isEmpty(rowIds)) {
            return;
        }
        var appEvent = $A.get("e.c:jqDataTableEvent");
        var message = {
            "action": "hideChild",
            "rowIds": rowIds,
        };
        appEvent.setParams(
            { 
                "message": message
            }
        );
        appEvent.fire();
    
    },
    
    formatChildData: function ( row ) {
        var d = row.transactionData;
        console.log('Row Transaction Data:',d);
        //update value Date
        var valueDate = new Date(d.valueDate); 
        var valueMonth = (valueDate.getMonth() + 1) + "";
        valueMonth = valueMonth.length >= 2 ? valueMonth : '0' + valueMonth; 


        var numberFormatter = new Intl.NumberFormat('en-GB', { style: 'decimal', maximumFractionDigits: d.transactionCurrency.decimalPlaces});
        // `row` is the original data object for the row
        return '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
            '<tr>'+
            '<td>Value Date:</td>'+
            '<td>'+ valueDate.getDate() + '-' + valueMonth + '-' + valueDate.getFullYear()+'</td>'+
            '</tr>'+
            '<tr>'+
            '<td>Transaction Exchange Rate:</td>'+
            '<td>'+d.transactionExchangeRate+'</td>'+
            '</tr>'+
            '<tr>'+
            '<td>Account Currency:</td>'+
            '<td>'+d.accountCurrency.code+'</td>'+
            '</tr>'+
            '<tr>'+
            '<td>Amount (Acc Currency):</td>'+ //RM edit, was "Original Amount"
            '<td>'+numberFormatter.format(d.amount) +'</td>'+ //RM edit, was originalAmount
            '</tr>'+
            '<tr>'+
            '<td>Reference:</td>'+
            '<td>'+d.reference+'</td>'+
            '</tr>'+
            '<tr>'+
            '<td>Previous Balance:</td>'+
            '<td>'+numberFormatter.format(d.previousBalance) +'</td>'+
            '</tr>'+
            '<tr>'+
            '<td>Current Balance:</td>'+
            '<td>'+numberFormatter.format(d.currentBalance) +'</td>'+
            '</tr>'+
            '<tr>'+
            '<td>Transaction Description 1:</td>'+
            '<td>'+d.transactionDescription1+'</td>'+
            '</tr>'+
            '<tr>'+
            '<td>Transaction Description 2:</td>'+
            '<td>'+d.transactionDescription2+'</td>'+
            '</tr>'+
            '<tr>'+
            '<td>Transaction Description 3:</td>'+
            '<td>'+d.transactionDescription3+'</td>'+
            '</tr>'+
            '<tr>'+
            '<td>Transaction Description 4:</td>'+
            '<td>'+d.transactionDescription4+'</td>'+
            '</tr>'+
            '<tr>'+
            '<td>Transaction Description 5:</td>'+
            '<td>'+d.transactionDescription5+'</td>'+
            '</tr>'+
            '<tr>'+
            '<td>Transaction Description 6:</td>'+
            '<td>'+d.transactionDescription6+'</td>'+
            '</tr>'+
            '</table>';
    },
    //CH07 - Start
    downloadExcel: function(component,helper){
        
        var customerId = component.get('v.customerId');
        var account = component.get('v.account');
        var accountNumber = component.get('v.bankAccountNo');
        var productName = component.get('v.bankProductName');
        var regionName = account.Region_Flag__c;
        if(component.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        
        // Encode parameters in base64
            var encodedcustomerId = btoa(customerId);
            var encodedRegName = btoa(regionName);
        
        var encodedProductName = btoa(productName);
        var encodedAccountNumber = btoa(accountNumber);
            
        const dateFrom = component.get('v.dateFrom');
        var datePopulated = 'N';
        if(dateFrom){
        	datePopulated = 'Y';
        }
        var encodedDatePopulated = btoa(datePopulated);
        var vfPageUrl = '/apex/AccountTransactionExcel?cifno=' + encodeURIComponent(encodedcustomerId) +
            				'&region=' + encodeURIComponent(encodedRegName) +
               				'&datePopulated=' + encodeURIComponent(encodedDatePopulated) +
                			'&productName=' + encodeURIComponent(encodedProductName) +
                			'&accountNumber=' + encodeURIComponent(encodedAccountNumber) +
               				'&filter=' + encodeURIComponent(component.get("v.searchParametersJson"));
        window.open(vfPageUrl, '_blank');
    }
    //CH07 - End
})
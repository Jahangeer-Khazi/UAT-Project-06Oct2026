/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History: 
 *			   #CH01# Added #03-05-2021# getSearchJson, loadTransactionSearch, formatCurrency, afterSixMonths, beforeSixMonths   
 			          isUptoSixMonths, isBeforeSixMonths and formatDateToDDMMYY Method/function in the Helper by Jahangeer Mohammed
               #CH02# Added #03-05-2021# Java script code to display current date Transactions and added two extra parameters
               		  jsonToDate and jsonFromDate in getDefaultSearchJson function by Jahangeer Mohammed.

               #CH03 04/09/2023 by Imane TSIOUCHA add Saving Pots process for alburaq 
 */
({
    BATCH_SIZE: 500, //Change BATCH_SIZE from 100 to 500 by Jahangeer Mohammed
    //CH01: Start
    BATCH_SIZE_SEARCH:500, 
    RECORD_SIZE:500,
    //RECORD_COUNT:1,
    //CH01: END
        
    getDefaultSearchJson: function(component, customerId, potId,jsonToDate,jsonFromDate) {
        var searchParametersJson = {
            "potId": potId,
            "offSet": 0,
            "pageSize": this.BATCH_SIZE,
            //"debitCreditIndicator": "ALL", //TODO remove when API allows
            "fromDate": jsonToDate,
            "toDate": jsonFromDate,
            "status" : "completed"
        }; 
        return searchParametersJson;
    },
    //CH01: Start
     getSearchJson: function(component, customerId, potId) {
        var searchParametersJson = {
            "id": potId,
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
    loadTransactions: function(component, customerId, potId, providedSearchParametersJson, previouslyLoadedTransactions, prevTransactionLength) {
        console.log('loadTransactions(customerId=' + customerId + ', potId=' + potId + ')'); 
        console.log('Previously Loaded Transactions:'+previouslyLoadedTransactions);
        console.log('Provided search parameter JSON:'+providedSearchParametersJson);
	    var helper = this;
        //CH02: Start
        var today = new Date(
            new Date().getFullYear(),
            new Date().getMonth() + 1, 
            new Date().getDate() + 1
        );
        var dd = today.getDate();
        //var mm = today.getMonth();
        //var yyyy = today.getFullYear();
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
            new Date().getMonth() + 1 - 3, 
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
        
        var defaultSearchParametersJson = helper.getDefaultSearchJson(component, customerId, potId,jsonToDate,jsonFromDate);
        var searchParametersJson = undefined === providedSearchParametersJson ? defaultSearchParametersJson : providedSearchParametersJson;
        //CH01: Start
        console.log('prevTransactionLength', prevTransactionLength);
        prevTransactionLength = prevTransactionLength && prevTransactionLength > 0 ? prevTransactionLength : 0;
        
        if(prevTransactionLength && prevTransactionLength > 0){
            searchParametersJson.offSet = prevTransactionLength;
        }
        //CH01: END
        /*if ($A.util.isArray(previouslyLoadedTransactions)) {// Commented by Jahangeer Mohammed
            // in 'load-more' mode, set appropriate offset value
            searchParametersJson.offSet = previouslyLoadedTransactions.length;
        }*/ 
        
        console.log("searchParametersJson", searchParametersJson);

        //CH03 -Start added by imane : pass Bahrain_alburaq in case of alburaq Product
        var regionName = component.get('v.account.Region_Flag__c');
        if(component.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        //CH03 -End

        component.set("v.filterParametersJson",JSON.stringify(searchParametersJson));
        component.find('apexService').request(component.get('c.loadPotTransactions'), {
            "customerId": customerId,
            "potId": potId,
            "searchParametersJson": JSON.stringify(searchParametersJson),
            "regionName": regionName
        },
        function(response) {

            var result = response.getReturnValue();
            
            console.log("result", result);
            // array of card data
            // continue existing collection or start new one if offset is not specified
            var data = $A.util.isArray(previouslyLoadedTransactions)? previouslyLoadedTransactions : [];
            //var data = isNaN(offset)? [] :component.get('v.gridDataRows') ;
            var transactionsBatch = [];
            //CH01: Start
            var recordLength = 0;
            if(true === result.isSuccess){
                //recordLength = parseInt(result.responseData.length);
                recordLength = parseInt(result.recordLength);
                console.log('Record Length from Server:'+recordLength);
            }
            //CH01: END
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                transactionsBatch = result.responseData;
                for (var i = 0; i < transactionsBatch.length; i++) {
                    if(i == helper.RECORD_SIZE){
                        	break;
                    }else{
                    	var transactionObj = transactionsBatch[i];  
						data.push(helper.formatData(component, transactionObj));
                    }
                }
            }
            component.set('v.gridDataRows', data);
        });
    },
    //CH01: Start
    loadTransactionSearch: function(component, customerId, potId, providedSearchParametersJson, previouslyLoadedTransactions, prevTransactionLength) {
        console.log('loadTransactions(customerId=' + customerId + ', potId=' + potId + ')'); 
        console.log('ProvidedJSON',providedSearchParametersJson);
        console.log('Previously Loaded Transactions:',previouslyLoadedTransactions);
	    console.log('Previous Transanction Length',prevTransactionLength);
        
        var helper = this;
        var defaultSearchParametersJson = helper.getSearchJson(component, customerId, potId);
        var searchParametersJson = undefined === providedSearchParametersJson ? defaultSearchParametersJson : providedSearchParametersJson;
        console.log('prevTransactionLength', prevTransactionLength);
        prevTransactionLength = prevTransactionLength && prevTransactionLength > 0 ? prevTransactionLength : 0;
        
        if(prevTransactionLength && prevTransactionLength > 0){
            searchParametersJson.offSet = prevTransactionLength;
        }
        /*if ($A.util.isArray(previouslyLoadedTransactions)) {
            // in 'load-more' mode, set appropriate offset value
            searchParametersJson.offSet = previouslyLoadedTransactions.length;
        }*/ 
        
        console.log("searchParametersJson", searchParametersJson);
        //CH03 -Start added by imane : pass Bahrain_alburaq in case of alburaq Product
        var regionName = component.get('v.account.Region_Flag__c');
        if(component.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        //CH03 -End

		component.set("v.filterParametersJson",JSON.stringify(searchParametersJson));
        component.find('apexService').request(component.get('c.loadPotTransactions'), {
            "customerId": customerId,
            "potId": potId,
            "searchParametersJson": JSON.stringify(searchParametersJson),
            "regionName": regionName
        },
        function(response) {

            var result = response.getReturnValue();
            
            console.log("result", result);
            // array of card data
            // continue existing collection or start new one if offset is not specified
            var data = $A.util.isArray(previouslyLoadedTransactions)? previouslyLoadedTransactions : [];
            //var data = isNaN(offset)? [] :component.get('v.gridDataRows') ;
            console.log('Previous Data',data);
            console.log('Previous Data',data.length);
            var transactionsBatch = [];
            var recordLength = 0;
            if(true === result.isSuccess){
                recordLength = parseInt(result.responseData.length);
                console.log('Record Length from Server:'+recordLength);
            }
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                transactionsBatch = result.responseData;
                for (var i = 0; i < transactionsBatch.length; i++) {
                    if(i == helper.RECORD_SIZE){
                        	break;
                    }
                    else{
                    	var transactionObj = transactionsBatch[i];  
						data.push(helper.formatData(component, transactionObj));
                    }
                }
            }
         	 component.set('v.gridDataRows', data);
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
        //console.log('transaction', transaction); 
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
        result.transactionCurrency = transaction.transactionCurrency.code;
        result.transactionDescription = [transaction.transactionDescription1, transaction.transactionDescription2].join(' ');
        result.amount = transaction.amount;
        result.reference = transaction.reference; //RM edit, added
        //CH01: Start
        //result.originalAmount = transaction.originalAmount; //RM edit, added
        var tranAmt = transaction.originalAmount;
        var formatNum = helper.formatCurrency(tranAmt,3,undefined,undefined);
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
             
        /*
        result.childRowColumns = ["valueDate", "transactionExchangeRate", "accountCurrency", "transactionDescription1", 
            "originalAmount" , "reference" , "previousBalance" , "currentBalance" ];
        */
        
        return result;

    },
    //CH01: Start          
    formatCurrency : function(number,decPlaces,decSep,thouSep){
        //console.log('Inside Format currency');
        decPlaces = isNaN(decPlaces = Math.abs(decPlaces)) ? 2 : decPlaces;
       
		decSep = typeof decSep === "undefined" ? "." : decSep;
       
		thouSep = typeof thouSep === "undefined" ? "," : thouSep;
        
        var sign = number < 0 ? "-" : "";
		var i = String(parseInt(number = Math.abs(Number(number) || 0).toFixed(decPlaces)));
        //console.log('Number to String:'+i);
        //console.log('Number Length:'+i.length);
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
                {title: 'Amount', data: 'originalAmount'},//, className: 'dt-body-right' //RM edit, was {title: 'Amount', data: 'amount'}
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

    runSearch: function(component, customerId, potId) {
        var helper = this;
        if (!helper.validateFilters(component)) {
            return;
        }
       
        var helper = this;
        //CH01: Start
        var searchParametersJson = helper.getSearchJson(component, customerId, potId);
        //CH01: END
        helper.setIfNotEmpty(component.get('v.amountFrom'), searchParametersJson, 'fromAmount');
        helper.setIfNotEmpty(component.get('v.amountTo'), searchParametersJson, 'toAmount');
        helper.setIfNotEmpty(component.get('v.dateFrom'), searchParametersJson, 'fromDate');
        helper.setIfNotEmpty(component.get('v.dateTo'), searchParametersJson, 'toDate');
        helper.setIfNotEmpty(component.get('v.debitCreditIndicator'), searchParametersJson, 'debitCreditIndicator');
        helper.setIfNotEmpty(component.get('v.transactionStatus'), searchParametersJson, 'status');
        
        console.log("searchParametersJson in runSearch Method", searchParametersJson);
        //CH01: Start
        helper.loadTransactionSearch(component, customerId, potId, searchParametersJson);
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
        if ($A.util.isEmpty(selectedRows)) {
            return;
        }
        var thisHelper = this;
        
        var rowsWithChildData = [];
        for (var i = 0; i < selectedRows.length; i++) {
            var row = selectedRows[i];
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
    }
})
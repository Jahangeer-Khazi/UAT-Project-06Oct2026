/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History:
 */
({
    BATCH_SIZE:50,
    BATCH_SIZE_SEARCH:100, 
    RECORD_SIZE:1000,
    API_CALL_RECORD_SIZE_LMT:900,
    
    getDefaultSearchJson: function(component, customerId, accountId, cardId) {
        var searchParametersJson = {
            "id": accountId,
            "offSet": 0,
            "pageSize": this.BATCH_SIZE, //"50",//'this.BATCH_SIZE',
            "cardId": cardId
            
        };
        return searchParametersJson;
    },
    
    getSearchJson: function(component, customerId, accountId,cardId,jsonToDate,jsonFromDate,type,status,aircode,flynum,fromAmount,toAmount) {
        var searchParametersJson = {
            "id": accountId,
            "offSet": 0,
            "pageSize": this.BATCH_SIZE_SEARCH, //"100",//'this.BATCH_SIZE',
            "fromDate": jsonFromDate,
            "toDate": jsonToDate,
            "fromAmount":fromAmount,
            "toAmount":toAmount,
            "cardId": cardId,
            "type": type, //TODO remove when API allows
            "status":status,
            "aircode":aircode,
            "flynum":flynum
            
        };
        return searchParametersJson;
    },
    //CH01: END
    /**
     * @param providedSearchParametersJson OPTIONAL, use only from user defined search and to load more
     * @param previouslyLoadedTransactions OPTIONAL, if provided then we are in "load-more" mode
     */
    loadRedemptions: function(component, customerId, accountId,Option,cardId,providedSearchParametersJson, previouslyLoadedTransactions, prevTransactionLength) {
        console.log('loadTransactions(customerId=' + customerId + ', accountId=' + accountId + ')');
        var helper = this;
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
                var mmmm = threeMonthsDate.getMonth()+12;
                console.log(yyyyyy);
                console.log(mmmm);
            }
        } 
        var jsonToDate = yyyyyy+'-'+mmmm+'-'+dddd;
        console.log('ToDate>>>>>'+jsonToDate);
        
        var defaultSearchParametersJson = helper.getDefaultSearchJson(component, customerId, accountId, cardId);
        var searchParametersJson = undefined === providedSearchParametersJson ? defaultSearchParametersJson : providedSearchParametersJson;
        console.log('prevTransactionLength', prevTransactionLength);
        
        prevTransactionLength = prevTransactionLength && prevTransactionLength > 0 ? prevTransactionLength : 0;
        
        console.log('prevTransactionLength value',prevTransactionLength);
        
        if(prevTransactionLength && prevTransactionLength > 0){
            searchParametersJson.offSet = prevTransactionLength;
        }
        
        console.log('offset value',searchParametersJson.offSet);
        console.log('searchParametersJson', searchParametersJson);
        var account = component.get('v.account');
        
        var regionName = account.Region_Flag__c;
        if(component.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        
        
        component.find('apexService').request(component.get('c.loadRedemptionHistory'), {
            "customerId": customerId,
            "searchParametersJson": JSON.stringify(searchParametersJson),
            "regionName" : regionName,
            "option":Option
        },
                                              function(response) {
                                                  
                                                  var result = response.getReturnValue();
                                                  console.log("result",JSON.stringify(result));
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
                                                      console.log('inside bacth'+transactionsBatch);
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
                                                      helper.loadRedemptions(component, customerId, accountId, searchParametersJson, data, totalRecordLength);
                                                  } else {
                                                      console.log('Setting data in JQ Table'+JSON.stringify(data));
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
        var Option = component.get('v.preferredRewardsOption');
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
        
        console.log('searchParametersJson for transaction', searchParametersJson);
        component.find('apexService').request(component.get('c.loadRedemptionHistory'), {
            "customerId": customerId,
            "searchParametersJson": JSON.stringify(searchParametersJson),
            "regionName" : regionName,
            "option":Option// #CH04#
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
        
        var transacDate = new Date(transaction.transactionDateTime); 
        var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        
        var transactionMonth = (transacDate.getMonth() + 1) + "";
        transactionMonth = transactionMonth.length >= 2 ? transactionMonth : "0" + transactionMonth;
        
        var transactionMn = transacDate.getMinutes() + "";
        transactionMn = transactionMn.length >= 2 ? transactionMn : '0' + transactionMn;
        
        var transactionH = transacDate.getHours() + "";
        transactionH = transactionH.length >= 2 ? transactionH : '0' + transactionH;
        
        var transactionDate = transacDate.getDate() + "";
        transactionDate = transactionDate.length >= 2 ? transactionDate : "0" + transactionDate; 
        
        var result = {};
        result.id = transaction.reference;
        //result.transactionDateTime = transactionDate + ' ' + months[transacDate.getMonth()] + ' ' + transacDate.getFullYear() + ' ' + transactionH + ':' + transactionMn;
        result.transactionDateTime = transaction.redemptionDate;
        result.tokenType = transaction.redeemedTokensType;
        result.tokens = transaction.redeemedTokens;
        result.tokensValue = transaction.redeemedTokensType=='MILES'?transaction.redeemedTokensMiles:transaction.redeemedTokensValue;
        result.status = transaction.status;
        result.transactionCurrency = transaction.cardCurrency.code;
        result.transactionId = transaction.redeemedTokensType=='MILES'?transaction.airlineReference:transaction.reference;
        result.airlines=transaction.merchant.name;
        result.flyNumber=transaction.flyNumber;
        
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
        var j = (j = i.length) > 3 ? j % 3 : 0;
        return sign +
            (j ? i.substr(0, j) + thouSep : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thouSep) + (decPlaces ? decSep + Math.abs(number - i).toFixed(decPlaces).slice(2) : "");   
    },
    //CH01: END
    getDataColumns: function(component) {
        var redeemType = component.get('v.preferredRewardsOption')=='ILA_TOKENS'?'Redeemed Tokens Value':component.get('v.preferredRewardsOption')=='CASHBACK'?'Redeemed Cashback':'Redeemed Miles';
        var column=[
            {title: 'id', data: 'rowSelector', "orderable": false, "visible": false, "searchable": false},
            //{title: '', data: null, defaultContent: "", "orderable": false, "searchable": false},
            {title: 'Redemption Date', data: 'transactionDateTime'},
            {title: 'Type', data: 'tokenType'},
            {title: 'Redeemed Tokens', data: 'tokens'},
            {title: redeemType, data: 'tokensValue'},//, className: 'dt-body-right' //RM edit, was {title: 'Amount', data: 'amount'} // Ashish -  {title: 'Amount', data: 'originalAmount'}
            {title: 'Currency', data: 'transactionCurrency'},
            {title: 'Status', data: 'status'},
            {title: 'Reference Number', data: 'transactionId'},
            {title: 'Airline', data: 'airlines'},
            {title: 'Airline Membership Number', data: 'flyNumber'},//RM edit
            //{title: 'Previous Balance', data: 'previousBalance'},
            //{title: 'Current Balance', data: 'currentBalance'},
        ];
            if(redeemType=='Redeemed Miles'){
            column = column.filter(label => label.title !== "Currency");
            column = column.filter(label => label.title !== "Type");
            }
            if(redeemType=='Redeemed Cashback'){
            column = column.filter(label => label.title !== "Type");
            column = column.filter(label => label.title !== "Airline");
            column = column.filter(label => label.title !== "Airline Membership Number");
            }
            return column;
            },
            
            getColumnDefs: function(component) {
            var redeemType = component.get('v.preferredRewardsOption')=='ILA_TOKENS'?'Redeemed Tokens Value':component.get('v.preferredRewardsOption')=='CASHBACK'?'Redeemed Cashback':'Redeemed Miles';
            var columnDefs = [
            
            {
            targets: '_all',
            "defaultContent": ""
            }, 
            { targets: 1, width: '10%', type:'date'},
            { targets: 2, width: '10%'},
            { targets: 3, width: '10%' },
            { targets: 4, width: '10%' },
            { targets: 5, width: '10%' },
            { targets: 6, width: '10%' }
        ];
        if(redeemType=='Redeemed Miles'){
            columnDefs = columnDefs.filter(label => label.targets !== 4);
        }
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
        var StrDate = dateFrom2.toISOString();
        console.log('StrDate###'+StrDate);
        //var DDMMYY = helper.formatDateToDDMMYY(StrDate);
        component.set('v.dateTo',StrDate);
    },
    beforeSixMonths : function(component,str) {
        var helper = this;
        var d = helper.stringToDate(str);
        var dateToStr2 = component.get('v.dateTo');
        var dateTo = helper.stringToDate(dateToStr2);
        var dateBeforeSixMonths = helper.isBeforeSixMonths(dateTo);
        var StrDateTo = dateTo.toISOString();
        console.log('StrDate###'+StrDateTo);
        //var DDMMYYTo = helper.formatDateToDDMMYY(StrDateTo);
        component.set('v.dateFrom',StrDateTo);
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
        helper.setIfNotEmpty(new Date(component.get('v.dateFrom')).toISOString('YYYY-MM-DDTHH:mm:ss').slice(0, -5), searchParametersJson, 'fromDate');
        helper.setIfNotEmpty(component.get('v.cardId'), searchParametersJson, 'cardId');
        helper.setIfNotEmpty(new Date(component.get('v.dateTo')).toISOString('YYYY-MM-DDTHH:mm:ss').slice(0, -5), searchParametersJson, 'toDate');
        helper.setIfNotEmpty(component.get('v.type'), searchParametersJson, 'type');
        helper.setIfNotEmpty(component.get('v.transactionStatus'), searchParametersJson, 'status');
        helper.setIfNotEmpty(component.get('v.airlinecode'), searchParametersJson, 'aircode');
        helper.setIfNotEmpty(component.get('v.flyNumber'), searchParametersJson, 'flynum');
        var data=[];
       // data = component.get('v.data');
        var datalength = data.length;
        //CH01: Start
        helper.loadTransactionSearch(component, customerId, accountId, searchParametersJson,data,datalength);
        //CH01: END
    },
    
})
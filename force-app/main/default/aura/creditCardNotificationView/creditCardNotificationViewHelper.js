/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History: 
 *
 */
({
    BATCH_SIZE:50,
    BATCH_SIZE_SEARCH:100, 
    RECORD_SIZE:1000,
    API_CALL_RECORD_SIZE_LMT:900,
    getDefaultSearchJson: function(component, customerId, jsonToDate, jsonFromDate, category) {
        var searchParametersJson = {
            "offSet": 0,
            "pageSize":this.BATCH_SIZE, //"50",//'this.BATCH_SIZE',
            "fromDate":jsonToDate,
            "toDate": jsonFromDate,
            "category": category
            
        };
        return searchParametersJson;
    },
    
    getSearchJson: function(component, customerId) {
        var searchParametersJson = {
            "offSet": 0,
            "pageSize": this.BATCH_SIZE_SEARCH, //"100",//'this.BATCH_SIZE'
            
        };
        return searchParametersJson;
    },
    
    
    /**
     * @param providedSearchParametersJson OPTIONAL, use only from user defined search and to load more
     * @param previouslyLoadedTransactions OPTIONAL, if provided then we are in "load-more" mode
     */
    loadTransactions: function(component, customerId, providedSearchParametersJson, previouslyLoadedTransactions, prevTransactionLength) {
        console.log('loadTransactions(customerId=' + customerId + ')');
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
        
        var defaultSearchParametersJson = helper.getDefaultSearchJson(component, customerId, jsonToDate,jsonFromDate);
        var searchParametersJson = undefined === providedSearchParametersJson ? defaultSearchParametersJson : providedSearchParametersJson;       
        prevTransactionLength = prevTransactionLength && prevTransactionLength > 0 ? prevTransactionLength : 0;
        
        if(prevTransactionLength && prevTransactionLength > 0){
            searchParametersJson.offSet = prevTransactionLength;
        }
        
        var account = component.get('v.account');
        component.find('apexService').request(component.get('c.loadAccountTransactions'), {
            "customerId": customerId,
            "searchParametersJson": JSON.stringify(searchParametersJson),
            "regionName" : account.Region_Flag__c
        },
                                              function(response) {
                                                  
                                                  var result = response.getReturnValue();
                                                  console.log("result", result);
                                                  var data = $A.util.isArray(previouslyLoadedTransactions)? previouslyLoadedTransactions : [];
                                                  var transactionsBatch = [];
                                                  var recordLength = 0;
                                                  if(true === result.isSuccess){
                                                      recordLength = parseInt(result.recordLength);
                                                      console.log('Record Length from Server:'+recordLength);
                                                  }
                                                  if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                                                      transactionsBatch = result.responseData;
                                                      for (var i = 0; i < transactionsBatch.length; i++) {
                                                          var transactionObj = transactionsBatch[i]; 
                                                          data.push(helper.formatData(component, transactionObj));
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
        
        
        
    },
    
    loadTransactionSearch: function(component, customerId, providedSearchParametersJson, previouslyLoadedTransactions, prevTransactionLength) {
        debugger;
        console.log('loadTransactions(customerId=' + customerId + ')');
        var helper = this;
        var category = component.get("v.category");
        var defaultSearchParametersJson = helper.getSearchJson(component, customerId);
        var defaultSearchParametersAsBlank = helper.getDefaultSearchJson(component, customerId, category);
        var searchParametersJson = undefined === providedSearchParametersJson ? defaultSearchParametersJson : providedSearchParametersJson;
        console.log('prevTransactionLength', prevTransactionLength);
        prevTransactionLength = prevTransactionLength && prevTransactionLength > 0 ? prevTransactionLength : 0;
        
        if(prevTransactionLength && prevTransactionLength > 0){
            searchParametersJson.offSet = prevTransactionLength;
        }
        var account = component.get('v.account');
        component.find('apexService').request(component.get('c.loadAccountTransactions'), {
            "customerId": customerId,
            "searchParametersJson": JSON.stringify(searchParametersJson),
            "regionName" : account.Region_Flag__c 
        },
                                              function(response) {
                                                  
                                                  var result = response.getReturnValue();
                                                  console.log("result for transaction serach", result);
                                                  // array of Notification
                                                  // continue existing collection or start new one if offset is not specified
                                                  var data = $A.util.isArray(previouslyLoadedTransactions)? previouslyLoadedTransactions : [];
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
                                                          var transactionObj = transactionsBatch[i]; 
                                                          data.push(helper.formatData(component, transactionObj));
                                                          component.set('v.gridDataRows', data);
                                                      }
                                                  }
                                                  // check if data load is complete
                                                  console.log('>>>>> record helper.BATCH_SIZE_SEARCH:', helper.BATCH_SIZE_SEARCH);
                                                  console.log('>>>>> record length:', recordLength);
                                                  var totalRecordLength = (recordLength + prevTransactionLength);
                                                  if (helper.BATCH_SIZE_SEARCH == recordLength) {
                                                      console.log('Total Record Length:' +totalRecordLength);
                                                      if(totalRecordLength <= helper.API_CALL_RECORD_SIZE_LMT){
                                                          helper.loadTransactionSearch(component, customerId, searchParametersJson, data, totalRecordLength);
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
                                              });
        
    },
    setIfNotEmpty: function(value, obj, fName) {
        if (!$A.util.isEmpty(value)) {
            obj[fName] = value;
        }
    },
    formatData: function(component, transaction){
        
        var helper = this;
        
        var transacDate = new Date(transaction.notificationDate); 
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
        result.templateCode = transaction.templateCode;
        result.notificationDate = transactionDate + ' ' + months[transacDate.getMonth()] + ' ' + transacDate.getFullYear() + ' ' + transactionH + ':' + transactionMn;
        result.notificationType = transaction.notificationType;
        result.mobileNumber = transaction.mobileNumber;
        result.category = transaction.category;
        return result;
        
    },
    getDataColumns: function(component) {
        return [
            {title: 'id', data: 'rowSelector', "orderable": false, "visible": false, "searchable": false},
            //{title: '', data: null, defaultContent: "", "orderable": false, "searchable": false},
            {title: 'Template Name', data:'templateCode'},
            {title: 'Date', data: 'notificationDate'},
            {title: 'Type', data: 'notificationType'},
            {title: 'Mobile Number', data: 'mobileNumber'},
            {title: 'Category', data: 'category'}
        ];
    },
    
    getColumnDefs: function(component) {
        var columnDefs = [
            
            {
                targets: '_all',
                "defaultContent": ""
            }, 
            { targets: 1, width: '1%'},
            { targets: 2, width: '1%',type:'date'},
            { targets: 3, width: '1%' },
            { targets: 4, width: '1%' },
            { targets: 5, width: '1%' }
        ];
        return columnDefs;
        
    },
    validateFilters: function(component) {
        var helper = this;
        
        // Dates
        var dateFromStr = component.get('v.dateFrom');        
        var dateToStr = component.get('v.dateTo');
        var dateFrom = helper.stringToDate(dateFromStr);
        var dateTo = helper.stringToDate(dateToStr);
        
        var dateFromStr2 = component.get('v.dateFrom');
        var dateFrom2 = helper.stringToDate(dateFromStr2);
        var dateThreeMonths = helper.isUptoThreeMonths(dateFrom2);
        var today=new Date().valueOf();
        
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
        
        if (!$A.util.isEmpty(dateTo) && dateTo > dateFrom2) {
            helper.displayValidationError(component, $A.get("$Label.c.Date_Date_values_must_be_in_three_months_range"));
            return false;
        }
        
        if (!$A.util.isEmpty(dateTo) && dateTo > today) {
            helper.displayValidationError(component, $A.get("$Label.c.Date_Date_values_must_be_in_within_currentdate"));
            return false;
        }
        if ($A.util.isEmpty(dateTo) && $A.util.isEmpty(dateFrom))  {
            helper.displayValidationError(component, $A.get("$Label.c.Date_Date_From_and_Date_To_fields_cannot_be_left_blank"));
            return false;
        }
        
        return true;
        
    },
    displayValidationError: function(component, message){
        component.find('apexService').showErrorMessage(message);
    },
    
    afterThreeMonths : function(component,str) {
        var helper = this;
        var d = helper.stringToDate(str);
        var dateFromStr2 = component.get('v.dateFrom');
        var dateFrom2 = helper.stringToDate(dateFromStr2);
        var dateThreeMonths = helper.isUptoThreeMonths(dateFrom2);
        var StrDate = dateThreeMonths.toString();
        var DDMMYY = helper.formatDateToDDMMYY(StrDate);
        component.set('v.dateTo',DDMMYY);
    },
    beforeThreeMonths : function(component,str) {
        var helper = this;
        var d = helper.stringToDate(str);
        var dateToStr2 = component.get('v.dateTo');
        var dateTo = helper.stringToDate(dateToStr2);
        var dateBeforeThreeMonths = helper.isBeforeThreeMonths(dateTo);
        var StrDateTo = dateTo.toString();
        var DDMMYYTo = helper.formatDateToDDMMYY(StrDateTo);
        component.set('v.dateFrom',DDMMYYTo);
    },
    
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
    isUptoThreeMonths:function(date){
        console.log('isUptoThree Months:'+date);
        if(date!=undefined){
            var d = new Date();
            d = date;
            var sixMonthdate = new Date();
            sixMonthdate = d.setMonth(d.getMonth() + 3);
            console.log(new Date(sixMonthdate).valueOf() > new Date().valueOf());
            if(new Date(sixMonthdate).valueOf() > new Date().valueOf()){
                sixMonthdate=new Date();
            }
            return new Date(sixMonthdate);
        }else{
            return null;
        }
    },
    
    isBeforeThreeMonths:function(date){
        console.log('isBeforeThree Months:'+date);
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
    
    runSearch: function(component, customerId) {
        debugger;
        var helper = this;
        if (!helper.validateFilters(component)) {
            return;
        }
        
        var helper = this;
        var searchParametersJson = helper.getSearchJson(component, customerId);
        console.log('Search Parameter JSON Value:'+searchParametersJson);
        
        helper.setIfNotEmpty(component.get('v.dateFrom'), searchParametersJson, 'fromDate');
        helper.setIfNotEmpty(component.get('v.dateTo'), searchParametersJson, 'toDate');
        helper.setIfNotEmpty(component.get('v.category'), searchParametersJson, 'category');
        
        helper.loadTransactionSearch(component, customerId, searchParametersJson);
    },
    
})
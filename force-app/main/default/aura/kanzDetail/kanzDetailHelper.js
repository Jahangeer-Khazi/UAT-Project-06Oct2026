/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History:
 *					 #CH01# #Jahangeer Mohammed# #02-06-2022# Added ledgerBalance and HoldAmount(NBA-5191)
 *              	 #CH02# : #Jahangeer Mohammed# #07-05-2024# Added Logic for Audit History Enhancements(NBA-9027)
 *              	 #CH04# : #Aniss Mbarki# #08-01-2025# Added Logic for PLA - Double Chances - CRM Requirements (NBA-12870)
 *                   #CH05#: #Aitogram omar# #01-04-2026 Added logic for Dormancy Visibility Restrictions (NBA-11705)
 */
({
     BATCH_SIZE:50,
    
    BATCH_SIZE_SEARCH:100,
    RECORD_SIZE:1000,
    
    API_CALL_RECORD_SIZE_LMT:900,
        
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
     
     getSearchJson: function(component, customerId, accountId) {
        var searchParametersJson = {
            "id": accountId,
            "offSet": 0,
            "pageSize": this.BATCH_SIZE_SEARCH, //"100",//'this.BATCH_SIZE',
            "debitCreditIndicator": "ALL" //TODO remove when API allows

        };
        return searchParametersJson;
    },

	loadData : function(component, customerId, caseId, regionName) {
        if ($A.util.isEmpty(customerId)) {
            console.error('kanzDetailHelper.js: customerId not provided');
            return;
        }
	    var helper = this;
        /*console.log('test demo');
        var DEMO_DATA = {
            "status":"EXISTING",
            "account":{
                "iban":"BH09ABCO00929029883",
                "balance":100000.000,
                "currency":{
                    "code":"BHD",
                    "decimalPlaces":3
                },
                "status":"Active"
            },
            "draws":[
                {
                    "id":"00000000001",
                    "code":"DRAW-F32",
                    "startDate":"2021-08-10T10:00:00",
                    "retentionStart":"2021-08-11T08:00:00",
                    "drawDate":"2021-08-12T12:00:00",
                    "type":"CURRENT",
                    "drawAmount":1000000.000,
                    "customerAmount":90000.000,
                    "currency":{
                        "code":"BHD",
                        "decimalPlaces":3
                    },
                    "noOfChances":4,
                    "timeZone":"UTC+03",
                    "grandPrize":2000.000,
                    "prizes":[
                        {
                            "order":1,
                            "noOfWinner":1,
                            "amount":1000
                        },
                        {
                            "order":2,
                            "noOfWinner":2,
                            "amount":5000
                        },
                        {
                            "order":3,
                            "noOfWinner":3,
                            "amount":500000
                        }
                    ]
                },
                {
                    "id":"00000000002",
                    "code":"DRAW-4GS",
                    "startDate":"2021-07-16T00:00:00",
                    "retentionStart":"2021-07-17T00:00:00",
                    "drawDate":"2021-07-18T00:00:00",
                    "type":"FUTURE",
                    "drawAmount":200000.000,
                    "customerAmount":70000.000,
                    "currency":{
                        "code":"BHD",
                        "decimalPlaces":3
                    },
                    "noOfChances":2,
                    "timeZone":"UTC+03",
                    "grandPrize":20000.000,
                    "prizes":[
                        {
                            "order":1,
                            "noOfWinner":1,
                            "amount":100000
                        },
                        {
                            "order":2,
                            "noOfWinner":2,
                            "amount":500000
                        },
                        {
                            "order":3,
                            "noOfWinner":3,
                            "amount":5000
                        }
                    ]
                },
                {
                    "id":"00000000003",
                    "code":"DRAW-5G4",
                    "startDate":"2021-09-18T11:00:00",
                    "retentionStart":"2021-09-19T12:00:00",
                    "drawDate":"2021-09-20T09:00:00",
                    "type":"FUTURE",
                    "drawAmount":2000000.000,
                    "customerAmount":70000.000,
                    "currency":{
                        "code":"BHD",
                        "decimalPlaces":3
                    },
                    "noOfChances":2,
                    "timeZone":"UTC+03",
                    "grandPrize":2000000.000,
                    "prizes":[
                        {
                            "order":1,
                            "noOfWinner":1,
                            "amount":10
                        },
                        {
                            "order":2,
                            "noOfWinner":2,
                            "amount":5
                        },
                        {
                            "order":3,
                            "noOfWinner":3,
                            "amount":5
                        }
                    ]
                },
                {
                    "id":"00000000004",
                    "code":"DRAW-G4D",
                    "startDate":"2021-11-15T10:00:00",
                    "retentionStart":"2021-11-15T00:00:00",
                    "drawDate":"2021-11-15T00:00:00",
                    "type":"FUTURE",
                    "drawAmount":20.000,
                    "customerAmount":70.000,
                    "currency":{
                        "code":"BHD",
                        "decimalPlaces":3
                    },
                    "noOfChances":2,
                    "timeZone":"UTC+03",
                    "grandPrize":20.000,
                    "prizes":[
                        {
                            "order":1,
                            "noOfWinner":1,
                            "amount":10
                        },
                        {
                            "order":2,
                            "noOfWinner":2,
                            "amount":5
                        },
                        {
                            "order":3,
                            "noOfWinner":3,
                            "amount":5
                        }
                    ]
                },
                {
                    "id":"00000000005",
                    "code":"DRAW-9HF",
                    "startDate":"2021-09-04T00:00:00",
                    "retentionStart":"2021-09-04T00:00:00",
                    "drawDate":"2021-09-04T00:00:00",
                    "type":"FUTURE",
                    "drawAmount":20.000,
                    "customerAmount":70.000,
                    "currency":{
                        "code":"BHD",
                        "decimalPlaces":3
                    },
                    "noOfChances":2,
                    "timeZone":"UTC+03",
                    "grandPrize":20.000,
                    "prizes":[
                        {
                            "order":1,
                            "noOfWinner":1,
                            "amount":10
                        },
                        {
                            "order":2,
                            "noOfWinner":2,
                            "amount":5
                        },
                        {
                            "order":3,
                            "noOfWinner":3,
                            "amount":5
                        }
                    ]
                },
                {
                    "id":"00000000006",
                    "code":"DRAW-4G3",
                    "startDate":"2021-09-06T00:00:00",
                    "retentionStart":"2021-09-06T00:00:00",
                    "drawDate":"2021-09-06T00:00:00",
                    "type":"FUTURE",
                    "drawAmount":20.000,
                    "customerAmount":70.000,
                    "currency":{
                        "code":"BHD",
                        "decimalPlaces":3
                    },
                    "noOfChances":2,
                    "timeZone":"UTC+03",
                    "grandPrize":20.000,
                    "prizes":[
                        {
                            "order":1,
                            "noOfWinner":1,
                            "amount":10
                        },
                        {
                            "order":2,
                            "noOfWinner":2,
                            "amount":5
                        },
                        {
                            "order":3,
                            "noOfWinner":3,
                            "amount":5
                        }
                    ]
                },
                {
                    "id":"00000000007",
                    "code":"DRAW-3FS",
                    "startDate":"2021-09-03T00:00:00",
                    "retentionStart":"2021-09-03T00:00:00",
                    "drawDate":"2021-09-03T00:00:00",
                    "type":"FUTURE",
                    "drawAmount":20.000,
                    "customerAmount":70.000,
                    "currency":{
                        "code":"BHD",
                        "decimalPlaces":3
                    },
                    "noOfChances":2,
                    "timeZone":"UTC+03",
                    "grandPrize":20.000,
                    "prizes":[
                        {
                            "order":1,
                            "noOfWinner":1,
                            "amount":10
                        },
                        {
                            "order":2,
                            "noOfWinner":2,
                            "amount":5
                        },
                        {
                            "order":3,
                            "noOfWinner":3,
                            "amount":5
                        }
                    ]
                },
                {
                    "id":"00000000008",
                    "code":"DRAW-43S",
                    "startDate":"2021-09-01T00:00:00",
                    "retentionStart":"2021-09-01T00:00:00",
                    "drawDate":"2021-09-01T00:00:00",
                    "type":"FUTURE",
                    "drawAmount":20.000,
                    "customerAmount":70.000,
                    "currency":{
                        "code":"BHD",
                        "decimalPlaces":3
                    },
                    "noOfChances":2,
                    "timeZone":"UTC+03",
                    "grandPrize":20.000,
                    "prizes":[
                        {
                            "order":1,
                            "noOfWinner":1,
                            "amount":10
                        },
                        {
                            "order":2,
                            "noOfWinner":2,
                            "amount":5
                        },
                        {
                            "order":3,
                            "noOfWinner":3,
                            "amount":5
                        }
                    ]
                },
                {
                    "id":"00000000009",
                    "code":"DRAW-6JH",
                    "startDate":"2021-10-01T00:00:00",
                    "retentionStart":"2021-10-01T00:00:00",
                    "drawDate":"2021-10-15T00:00:00",
                    "type":"FUTURE",
                    "drawAmount":20.000,
                    "customerAmount":70.000,
                    "currency":{
                        "code":"BHD",
                        "decimalPlaces":3
                    },
                    "noOfChances":2,
                    "timeZone":"UTC+03",
                    "grandPrize":20.000,
                    "prizes":[
                        {
                            "order":1,
                            "noOfWinner":1,
                            "amount":10
                        },
                        {
                            "order":2,
                            "noOfWinner":2,
                            "amount":5
                        },
                        {
                            "order":3,
                            "noOfWinner":3,
                            "amount":5
                        }
                    ]
                },
                {
                    "id":"00000000010",
                    "code":"DRAW-5CD",
                    "startDate":"2021-05-15T00:00:00",
                    "retentionStart":"2021-05-15T00:00:00",
                    "drawDate":"2021-05-12T00:00:00",
                    "type":"FUTURE",
                    "drawAmount":20.000,
                    "customerAmount":70.000,
                    "currency":{
                        "code":"BHD",
                        "decimalPlaces":3
                    },
                    "noOfChances":2,
                    "timeZone":"UTC+03",
                    "grandPrize":20.000,
                    "prizes":[
                        {
                            "order":1,
                            "noOfWinner":1,
                            "amount":10
                        },
                        {
                            "order":2,
                            "noOfWinner":2,
                            "amount":5
                        },
                        {
                            "order":3,
                            "noOfWinner":3,
                            "amount":5
                        }
                    ]
                },
                {
                    "id":"00000000011",
                    "code":"DRAW-3T3",
                    "startDate":"2021-06-15T00:00:00",
                    "retentionStart":"2021-06-15T00:00:00",
                    "drawDate":"2021-06-15T00:00:00",
                    "type":"FUTURE",
                    "drawAmount":20.000,
                    "customerAmount":70.000,
                    "currency":{
                        "code":"BHD",
                        "decimalPlaces":3
                    },
                    "noOfChances":2,
                    "timeZone":"UTC+03",
                    "grandPrize":20.000,
                    "prizes":[
                        {
                            "order":1,
                            "noOfWinner":1,
                            "amount":10
                        },
                        {
                            "order":2,
                            "noOfWinner":2,
                            "amount":5
                        },
                        {
                            "order":3,
                            "noOfWinner":3,
                            "amount":5
                        }
                    ]
                }
            ]
        };


        var data;
        console.log('test demo');
        data = helper.formatData(component, DEMO_DATA);
        if(data.status === 'EXISTING' || data.status === 'EXISTING_NOT_ELIGIBLE') {
            component.set('v.data', data);
            helper.changePage(component);
            component.set('v.existing', true);
        } else {
            component.set('v.existing', false);
        }*/

         console.log('regionName########'+regionName);
        //  CH05 start 
           component.find('apexService').request(component.get('c.getJordanVisibility'), {
            customerId: customerId
        }, function (response) {
            component.set('v.hideJordanFinancialDetails', response.getReturnValue());
        });
        // CH05 end 
        component.find('apexService').request(component.get('c.loadPrizeLinkedAccount'), {
                customerId: customerId,
                caseId: caseId,
                regionName:regionName
        },function(response) {
            var result = response.getReturnValue();
            console.log(JSON.stringify(result));
            var data;
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                // If result data from API is EXISTING then component will display information
                data = result.responseData;
                //CH02: Start
                var accIBAN = data.account.iban;
                //CH02: END
                if(accIBAN != null && accIBAN != ''){
                    helper.loadAccountDetails(component,customerId,accIBAN,regionName);//#CH04
                }

              //  console.log('IBAN Number in Kanz:',data.account.iban);
                if(data.status === 'EXISTING' || data.status === 'EXISTING_NOT_ELIGIBLE') {
                    component.set('v.data', helper.formatData(component,data));
                    helper.changePage(component);
                    component.set('v.existing', true);
                } else {
                    component.set('v.existing', false);
                }
                //CH02: Start
                //helper.loadDataInAuditObject(component,accIBAN);
                var enableAuditComp = $A.get("$Label.c.ENABLE_AUDIT_COMPONENT");
                if(enableAuditComp == 'true'){
                     helper.loadDataInAuditObject(component,accIBAN);
                }
                //CH02: END
            }
        });

	},
    //CH02: Start
    loadDataInAuditObject: function(component,accIBAN){
        console.log('Calling Load Data in Audit Object')
        var action = component.get("c.createAuditRecordForKanzDetails");
        console.log('Acct IBAN in helper:',accIBAN);
        var account = component.get('v.account');
        var accCIF = account.CIF__pc;
        console.log('Acc CIF in helper:',accCIF);
        action.setParams({
            accCIF:accCIF,
            accIBAN:accIBAN
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('Fetched Audit Id:',result);
            }
            
        });
        $A.enqueueAction(action);
    },
    //CH02: END
    formatData: function(component, resultObj){
        console.log('formatData ---> ');
        // Formats and stores the information regarding account
        var helper = this;
        var result = {};
       // var mask = component.get('v.maskSensitiveInfo');
        var mask = component.get('v.viewDetails');
        result.draws = [];
        result.status = resultObj.account.status;//CH04
        result.accountBalance = mask ? resultObj.account.balance:' ';
        //CH01 Start
        result.ledgerBalance = mask ?resultObj.account.ledgerBalance: ' ';
        
        result.holdAmount = mask ? resultObj.account.holdAmount: ' ';
        //CH01 END
        result.accountCurrency = resultObj.account.currency.code;
        result.accountIBAN = resultObj.account.iban;
        result.lastWithdrawDate = mask ? helper.formatDateTime(new Date(resultObj.account.lastWithdrawDate)): ' ';//CH04
        
        let kanzStatus = resultObj.status;
        if(kanzStatus == 'NEW'){
            result.kanzStatus = 'Inactive (NEW)';
        }
        else if(kanzStatus == 'NOT_ELIGIBLE'){
            result.kanzStatus = 'Inactive (NOT_ELIGIBLE)';
        }
        else if(kanzStatus == 'EXISTING'){
            result.kanzStatus = 'Active (EXISTING)';
        }
        else if(kanzStatus == 'EXISTING_NOT_ELIGIBLE'){
            result.kanzStatus = 'Active (EXISTING_NOT_ELIGIBLE)';
        }
        console.log('result.kanzStatus ---> '+resultObj.status);
        resultObj.draws.forEach(unformattedDraw => {
            let draw = helper.formatDraw(component,unformattedDraw);
            draw.nextChanceReqAmnt = mask ? draw.drawAmount - result.accountBalance % draw.drawAmount: null;
            result.draws.push(draw);
        });
        result.draws.sort(function(a,b){
            // Turn your strings into dates, and then subtract them
            // to get a value that is either negative, positive, or zero.
            return (a.startDate < b.startDate) ? -1 : ((a.startDate > b.startDate) ? 1 : 0);
        });

        //assign closing balance based on the lastassigned one 
        /*let lastclosingBalance;
        result.draws.forEach(draw => {
            console.log(draw.closingBalance);
            if(draw.closingBalance != null){
                lastclosingBalance = draw.closingBalance;
            }else {
                draw.closingBalance = lastclosingBalance;
            }
        });*/

        return result;
    },
    formatDraw: function(component, resultObj){
        // Formats each draw information
        var result = {};
        var helper = this;
      //  var mask = component.get('v.maskSensitiveInfo');
        var mask = component.get('v.viewDetails');
        result.id = resultObj.id;
        result.code = resultObj.code;
        result.startDate = resultObj.startDate;
        result.cutOffDate = resultObj.retentionDate;
        result.drawDate = helper.formatDate(new Date(resultObj.drawDate));//CH04
        result.drawAmount = mask ? resultObj.drawAmount:' ';    
        result.type = resultObj.type;
        result.noOfChances = mask ?resultObj.noOfChances:' ';
        result.nextChanceReqAmnt = 0;
        result.retentionDate = helper.formatDateTime(new Date(resultObj.retentionDate));//CH04
        result.retentionEndDate = helper.formatDateTime(new Date(resultObj.retentionEndDate));//CH04
        result.currencyCode = resultObj.currency.code;//CH04
        result.closingBalance = mask?resultObj.closingBalance:' ';//CH04

        result.noOfTotalChances = mask ?((resultObj.noOfTotalChances != null)?resultObj.noOfTotalChances:'-'):' ';//CH04
        result.noOfLoyaltyChances =mask ?((resultObj.noOfLoyaltyChances != null)?resultObj.noOfLoyaltyChances:'-'):' ';//CH04
        result.withdrawFunds = (resultObj.withdrawFunds != null && resultObj.withdrawFunds != false)?'Yes':'No';//CH04
       

        return result;
    },
    numberOfPages: function(component) {
        // Returns the proper number of pages needed for pagination
        return Math.ceil(component.get('v.data.draws').length / component.get('v.recordsPerPage'));
    },
    changePage: function(component) {
        // Calculates the current page and loads the records properly, then calls the checkPagination method
        var helper = this;
        const page = component.get('v.currentPage');
        const step = component.get('v.recordsPerPage');
        const start = page * step - step;
        component.set('v.startDraw',start+1);
        const end = start + step;
        const draws = component.get('v.data.draws');
        component.set('v.endDraw',(start+step)>draws.length?draws.length:start+step);
        //component.set('v.drawsOnPage',draws.slice(start, end));
        component.set('v.drawsOnPage',draws);//#CH04
        helper.checkPagination(component);
    },
    checkPagination: function(component) {

        // Depending on the calculations made by changePage this method changes the
        // status of the previous and next buttons

        var helper = this;
        const totalPages = helper.numberOfPages(component);
        const currentPage = component.get('v.currentPage');


        if (totalPages === 1) {
            helper.setPagination(component,false,false);
        } else {
            if(currentPage === totalPages) {
                helper.setPagination(component,true,false);
            } else if (currentPage === 1) {
                helper.setPagination(component,false,true);
            } else if (currentPage > 1) {
                helper.setPagination(component,true,true);
            }
        }
    },
    setPagination: function(component,previous,next) {
        // Just a setter method for pagination
        component.set('v.disablePreviousPage', !previous);
        component.set('v.disableNextPage', !next);
    },


    showTransactions : function(component, customerId, account) {

        /*var DEMO_DATA = {"id":"8915297","transactionDate":"24 Jan 2022 11:09","transactionType":"ACTD","valueDate":"2018-01-01",
         //"amountCurrency" :{"code" : "1232"},
         "status":"Completed","transactionCurrency":"GBP","transactionDescription":"To My GBP Account BH87ABCO20537129101012",
         "amount":-485,"reference":"821852920000","originalAmount":"-935.230","transactionDescription1":"To My GBP Account",
         "transactionDescription2":"BH87ABCO20537129101012","transactionDescription3":"","transactionDescription4":"","transactionDescription5":"",
         "transactionDescription6":"","transactionData":{"id":"8915297","transactionDate":"2022-01-24T11:09:20","valueDate":"2022-01-24","transactionType":"ACTD",
         "transactionCurrency":{"code":"GBP","decimalPlaces":"2"},"transactionExchangeRate":"0.518592000000000000",
         "accountCurrency":{"code":"BHD","decimalPlaces":"3"},"transactionDescription1":"To My GBP Account",
         "transactionDescription2":"BH87ABCO20537129101012","transactionDescription3":"","transactionDescription4":"","transactionDescription5":"",
         "transactionDescription6":"","amount":-485,"originalAmount":-935.23,"reference":"821852920000","previousBalance":485.317,"currentBalance":0.317,
         "generateAdvice":true,"status":"Completed","merchantName":"","fullDescription":"To My GBP Account BH87ABCO20537129101012    "}}*/
      if ($A.util.isEmpty(customerId)) {
            console.error('kanzDetailHelper.js: customerId not provided');
            return;
        }
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
       
        //get the Iban number :
         var accountDetails =  component.get('v.data');
         console.error('DATA Account IBAN >>  ' +accountDetails.accountIBAN);
        var searchParametersJson = {
            "id": accountDetails.accountIBAN, //IBAN
             "offSet": 0,
            "pageSize": this.BATCH_SIZE, //"50",//'this.BATCH_SIZE',
            "fromDate": jsonToDate,
            "toDate": jsonFromDate,
            /* "fromDate": "2022-02-07",
            "toDate": "2022-02-08", */
            "debitCreditIndicator": "ALL" //TODO remove when API allows*//*

        };

      /*  var defaultSearchParametersJson = helper.getSearchJson(component, customerId, accountDetails.accountIBAN);
		var defaultSearchParametersAsBlank = helper.getDefaultSearchJson(component, customerId, accountDetails.accountIBAN);
        var searchParametersJson = undefined === providedSearchParametersJson ? defaultSearchParametersJson : providedSearchParametersJson;
		console.log('prevTransactionLength', prevTransactionLength);
        prevTransactionLength = prevTransactionLength && prevTransactionLength > 0 ? prevTransactionLength : 0;

        if(prevTransactionLength && prevTransactionLength > 0){
            searchParametersJson.offSet = prevTransactionLength;
        }*/

         console.log('searchParametersJson >>>>>'+JSON.stringify(searchParametersJson));
        console.log('account.Region_Flag__pc>>>>>'+JSON.stringify(account.Region_Flag__c));
        //alert('searchParametersJson >>>>>'+JSON.stringify(account.Region_Flag__pc));
        component.find('apexService').request(component.get('c.loadKanzAccountTransactions'), {
                "customerId": customerId,
                "searchParametersJson": JSON.stringify(searchParametersJson),
                "regionName" : account.Region_Flag__c
            },
            function(response) {
                var result = response.getReturnValue();
                console.log("result------------->>>", result.recordLength);
                  var data = [];
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
                         console.log(' status >> ' +transactionObj.status);
                         //if(transactionObj.transactionType == 'PAFC'){  //Only display one type of the status --> changed as txn history should show all types of transactions
                                 data.push(helper.formatDataForTransactionData(component, transactionObj));
                         //}
                        
                    }
                }

               // console.log('Setting data in JQ Table ' + JSON.stringify(data));
                component.set('v.gridDataRows', data);

            });
            // completed: Load card transactions
    },

    formatDataForTransactionData: function(component, transaction){
     
        var helper = this;
        var result = {};
      
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
      
        //result.originalAmount = transaction.originalAmount; //RM edit, added
        var tranAmt = transaction.originalAmount;
        var formatNum = helper.formatCurrency(tranAmt,3,undefined,undefined);
        result.originalAmount = formatNum;
        

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
    handleJqDataTableEvent: function(component, event) {
        console.log("KanzDetail.handleJqDataTableEvent=" + JSON.stringify(event));
        var message = event.getParam("message");
        var action = message.action;
        var thisHelper = this;
        console.log('handleJqDataTableEvent ||Action|| '+message);
        if ( "getSelectedRowsResponse" === action) {
             console.log("getSelectedRowsResponse=" + JSON.stringify(selectedIds));
        } else if ( "broadcastSelectedRows" === action) {
            var selectedIds = message.rowIds;
            console.log("selectedIds=" + JSON.stringify(selectedIds));
            var gridDataRows = component.get('v.gridDataRows');
            var selectedRows = [];
            if (!$A.util.isEmpty(gridDataRows)) {
                for (var i = 0; i < selectedIds.length; i++) {
                    var id = selectedIds[i];
                    var foundRow = gridDataRows.find(function(row) {
                        console.log(id+'||Row||'+JSON.stringify(row));
                        return row.id == id;
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
    },
    filterPrizeData: function(unfilteredData) {
        var data = unfilteredData;
        for (var i = data.length - 1; i >= 0; i--) {
            if (data[i].transactionType === 'PAPC') {
                data.splice(i, 1);
            }
        }
        return data;
    },
    runSearch: function(component, customerId, accountId) {
        var helper = this;
        console.log('Inside run Search method');
        if (!helper.validateFilters(component)) {
            return;
        }

        var helper = this;
       
        var searchParametersJson = helper.getSearchJson(component, customerId, accountId);
       
        console.log('Search Parameter JSON Value:'+searchParametersJson);
        helper.setIfNotEmpty(component.get('v.amountFrom'), searchParametersJson, 'fromAmount');
        helper.setIfNotEmpty(component.get('v.amountTo'), searchParametersJson, 'toAmount');
        helper.setIfNotEmpty(component.get('v.dateFrom'), searchParametersJson, 'fromDate');
        helper.setIfNotEmpty(component.get('v.dateTo'), searchParametersJson, 'toDate');
        helper.setIfNotEmpty(component.get('v.transactionStatus'), searchParametersJson, 'status');
        
        helper.showTransactions(component, customerId, accountId, searchParametersJson);
        
    },
    loadDataSensitiveData : function(component, customerId, mask) {
        if ($A.util.isEmpty(customerId)) {
            console.error('kanzDetailHelper.js: customerId not provided');
            return;
        }
	    var helper = this;
        var maskSensitiveInfo= mask;
         component.find('apexService').request(component.get('c.loadDataSensitiveData'), {
                customerId: customerId
        },function(response) {
            var result = response.getReturnValue();
            console.log(JSON.stringify(result));
            console.log(JSON.stringify(maskSensitiveInfo));
            var data;
          //  if (true === result.isSuccess) {
                if((maskSensitiveInfo && result)||(!maskSensitiveInfo)){
                    console.log('inside if sensitive');
                     component.set('v.viewDetails',true);
                }else{
                     component.set('v.viewDetails',false);
                }  
         //   }
        });
    },

    //#CH04 :Start
    loadAccountDetails : function(component,customerId,accountId,regionName) {
        console.log("loadAccountDetails --> customerId-> "+customerId+" ;accountId-> "+accountId + " ;regionName-> "+regionName);
	    var helper = this;
		component.find('apexService').request(component.get('c.loadAccountDetails'), {
		    customerId: customerId,
		    accountId: accountId,
		    regionName: regionName
        },
		function(response) {
            var result = response.getReturnValue();
            var data = {};
            console.log('Response Data',result.responseData);
            console.log('Boolean Value',!$A.util.isEmpty(result.responseData));
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                data = result.responseData;
                console.log('loadAccountDetails Data--> ',data);
            }

            component.set('v.accountObjdata', helper.formataccountObjData(component, data));
		});

    },
    formataccountObjData: function(component, accountObj){
	    var helper = this;
        var result = {};
        result.startDate = helper.formatDate(new Date(accountObj.account.startDate));//CH04
        if(accountObj.transferByMobile == false){
            result.transferByMobile = 'Disabled';
        }
        else if(accountObj.transferByMobile == true){
            result.transferByMobile = 'Enabled';
        }
        
        return result;
    },
    formatDate: function(date) {
        var options = {
            day: '2-digit',
            month: 'short',
            year: 'numeric'
        };
        
        return date.toLocaleString('en-GB', options); // You can change the locale if needed
    },
    formatDateTime: function(date) {
        var options = {
            day: '2-digit',
            month: 'short',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: true // AM/PM format
        };
        
        return date.toLocaleString('en-GB', options); // You can change the locale if needed
    }
    /*
    formatDateV2: function(date) {
        // Format the date
        var day = ("0" + date.getDate()).slice(-2); // Ensure two digits for the day
        var month = date.toLocaleString('default', { month: 'short' }); // Get short month name (e.g., 'Jan')
        var year = date.getFullYear(); // Get the full year
        var hours = date.getHours() % 12 || 12; // 12-hour format (handling 12 AM/PM)
        var minutes = ("0" + date.getMinutes()).slice(-2); // Ensure two digits for the minutes
        var ampm = date.getHours() >= 12 ? 'PM' : 'AM'; // AM/PM format

        // Combine everything into the desired format: "01 Jan 2025 12:00AM"
        return day + " " + month + " " + year + " " + hours + ":" + minutes + ampm;
    }
    */
    //#CH04 :End
})
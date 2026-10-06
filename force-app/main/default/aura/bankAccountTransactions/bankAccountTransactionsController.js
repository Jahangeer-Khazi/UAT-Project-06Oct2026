/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History: 
 *			   #CH01# Added #05-04-2021# 'changedateTo' and 'changedateFrom' Method in the JSController by Jahangeer Mohammed.
 *             #CH02# Added #11-11-2025# Transaction Excel Generation and added download button 			   
 */
({
    init : function(component, event, helper) {
        component.set("v.tbId", Math.random().toString(36).substr(2, 11));
        
        var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');

        component.set('v.gridDataColumns', helper.getDataColumns(component));
        component.set('v.gridDataColumnDefs', helper.getColumnDefs(component));

        helper.loadTransactions(component, customerId, accountId);
	},
    handleJqDataTableEvent: function(component, event, helper) {
        helper.handleJqDataTableEvent(component, event);
    },
     onSearchClick: function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');
        console.log('Customer Id:'+customerId);
        console.log('Account  Id:'+accountId);
        helper.runSearch(component, customerId, accountId, /*providedSearchParametersJson=*/undefined);
        component.set('v.isNoDataFound',false);
    },
    load : function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');
        helper.loadTransactions(component, customerId, accountId);
    },
    //CH01: Start
    changedateTo : function(component,event,helper){
		 var datefromString = component.get('v.dateFrom');
         var dateToString = component.get('v.dateTo');
         console.log('Geeting the Date from value:'+datefromString);
         if(event.getParam("oldValue") === null) 
         	helper.afterSixMonths(component,datefromString);
         else if(event.getParam("value") === ""){
            helper.beforeSixMonths(component,dateToString);
        }
         
	}, 
    changedateFrom : function(component,event,helper){
		 var dateToString = component.get('v.dateTo');
         var dateFromString = component.get('v.dateFrom');
         console.log('Geeting the Date To value:'+dateToString);
         console.log('Old Value 2:'+event.getParam("oldValue"));
         if(event.getParam("oldValue") === null)
         	helper.beforeSixMonths(component,dateToString);
         else if(event.getParam("value") === ""){
             helper.afterSixMonths(component,dateFromString);
         }
         
	}, 
	//CH01: END
	//CH02 - Start
    onDownloadExcelClick : function(component,event,helper){
		console.log("download excel");
        component.set('v.isNoDataFound',false);
        var transactionData = component.get("v.gridDataRows");
        if(transactionData.length == 0){
            component.set('v.isNoDataFound',true);
        }
        else {
        	helper.downloadExcel(component,helper);    
        }
    }
    //CH02 - End
})
({
    /*initial load of the component load default 50 transactions*/
    init : function(component, event, helper) {
        component.set("v.tbId", Math.random().toString(36).substr(2, 11));
        
        var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');
        console.log('customerId',customerId);
        component.set('v.gridDataColumns', helper.getDataColumns(component));
        component.set('v.gridDataColumnDefs', helper.getColumnDefs(component));
        helper.loadTransactions(component, customerId);
    },
    
    /*change of To date calculate From date*/ 
    changedateTo : function(component,event,helper){
        var datefromString = component.get('v.dateFrom');
        var dateToString = component.get('v.dateTo');
        console.log('Getting the Date from value:'+datefromString);
        if(event.getParam("oldValue") === null){
            helper.afterThreeMonths(component,datefromString);
        }else if(event.getParam("value") === ""){
            helper.beforeThreeMonths(component,dateToString);
        }
        
    }, 
     /*change of From calculate TO date*/ 
    changedateFrom : function(component,event,helper){
        var dateToString = component.get('v.dateTo');
        var dateFromString = component.get('v.dateFrom');
        console.log('Geeting the Date To value:'+dateToString);
        console.log('Geeting the Date From value:'+dateFromString);
        console.log('Old Value 2:'+event.getParam("oldValue"));
        if(event.getParam("oldValue") === null && dateFromString===null){
            helper.beforeThreeMonths(component,dateToString);
        }else if(event.getParam("value") === ""){
            helper.afterThreeMonths(component,dateFromString);
        }
        
    },
    /*Search based on criteria*/
    onSearchClick: function(component, event, helper) {
        debugger;
        var customerId = component.get('v.customerId');
        console.log('Customer Id:'+customerId);
        helper.runSearch(component, customerId, /*providedSearchParametersJson=*/undefined);
    }
})
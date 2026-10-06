({
    init : function(component, event, helper) {
        component.set("v.tbId", Math.random().toString(36).substr(2, 11));
        
        var customerId = component.get('v.customerId');
        var loanId = component.get('v.loanId');

        var isAlburaqProduct = component.get("v.isAlburaqProduct");
        var loanOrFinance = (isAlburaqProduct) ? 'Finance' : 'Loan';
        console.log('isAlburaqProduct => '+ isAlburaqProduct);
        component.set('v.loanOrFinance', loanOrFinance);
        component.set('v.viewTransactions', false);

        component.set('v.gridDataColumns', helper.getDataColumns(component));
        component.set('v.gridDataColumnDefs', helper.getColumnDefs(component));

        // helper.loadTransactions(component, customerId, loanId);
	},
    handleJqDataTableEvent: function(component, event, helper) {
        helper.handleJqDataTableEvent(component, event);
    },
     onSearchClick: function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var loanId = component.get('v.loanId');
        console.log('Customer Id:'+customerId);
        console.log('Account  Id:'+loanId);
        helper.runSearch(component, customerId, loanId, /*providedSearchParametersJson=*/undefined);
    },
    load : function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var loanId = component.get('v.loanId');
        helper.loadTransactions(component, customerId, loanId);
    },
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
})
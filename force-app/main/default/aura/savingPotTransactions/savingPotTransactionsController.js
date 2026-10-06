/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History: 
 *			   #CH01# Added #03-05-2021# 'changedateTo' and 'changedateFrom' Method in the JSController by Jahangeer Mohammed.
 *			   #CH02 MaksudAli 12-10-2025, Added downloadExcel method and event handler
 */
({
    init : function(component, event, helper) {
        component.set("v.tbId", Math.random().toString(36).substr(2, 11));
        
        var customerId = component.get('v.customerId');
        var potId = component.get('v.potId');

        component.set('v.gridDataColumns', helper.getDataColumns(component));
        component.set('v.gridDataColumnDefs', helper.getColumnDefs(component));

        helper.loadTransactions(component, customerId, potId);
	},
    handleJqDataTableEvent: function(component, event, helper) {
        helper.handleJqDataTableEvent(component, event);
    },
    onSearchClick: function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var potId = component.get('v.potId');
        component.set('v.isNoDataFound',false);
        helper.runSearch(component, customerId, potId, /*providedSearchParametersJson=*/undefined);
    },
    load : function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var potId = component.get('v.potId');
        helper.loadTransactions(component, customerId, potId);
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
	//CH02 Start
    generateExcel : function(component,event,helper){
        console.log('generating excel...');
        var transactionData = component.get("v.gridDataRows");
        component.set('v.isNoDataFound',false);
        if(transactionData.length == 0){
            component.set('v.isNoDataFound',true);
        }
        else {
            let podData = {};
            
            var earnInterest = false;
            var goalAmount = '';
            var monthlyDepositAmount = '';
            
            if(component.get('v.earnInterest')){
                earnInterest = component.get('v.earnInterest')
            }
            if(component.get('v.goalAmount')){
                goalAmount = component.get('v.goalAmount')
            }
            if(component.get('v.monthlyDepositAmount')){
                monthlyDepositAmount = component.get('v.monthlyDepositAmount')
            }
            
            var customerId = component.get('v.customerId');
        	var potId = component.get('v.potId');
            var potName = component.get('v.potName');
            var filterJSON = component.get('v.filterParametersJson');
            console.log('filterJSON ',filterJSON);
            var regionName = component.get('v.account.Region_Flag__c');
            if(component.get('v.isAlburaqProduct') == true){
                regionName += '_alburaq';
            }
            
            // Encode parameters in base64
            var encodedcustomerId = btoa(customerId);
            var encodedPotId = btoa(potId);
            var encodedRegName = btoa(regionName);
            var encodedPotName = btoa(potName);
            
            var encodedEarnInterest = btoa(earnInterest);
            var encodedGoalAmount = btoa(goalAmount);
            var encodedMonthlyDepositAmount = btoa(monthlyDepositAmount);
            
            const dateFrom = component.get('v.dateFrom');
            var datePopulated = 'N';
            if(dateFrom){
                datePopulated = 'Y';
            }
            var encodedDatePopulated = btoa(datePopulated);
            
            var vfPageUrl = '/apex/SavingPotTransactionExcel?cifno=' + encodeURIComponent(encodedcustomerId) +
            				'&potId=' + encodeURIComponent(encodedPotId) +
                			'&potName=' + encodeURIComponent(encodedPotName) +
                			'&region=' + encodeURIComponent(encodedRegName) +
               				'&filter=' + encodeURIComponent(filterJSON) +
                			'&earnInterest=' + encodeURIComponent(encodedEarnInterest) +
                			'&goalAmount=' + encodeURIComponent(encodedGoalAmount) +
                			'&monthlyDepositAmount=' + encodeURIComponent(encodedMonthlyDepositAmount) +
                			'&datePopulated=' + encodeURIComponent(encodedDatePopulated);
           	window.open(vfPageUrl, '_blank');
        }
    },
    savingPotHandleEvent : function(component,event,helper) {
    	var earnInterest = event.getParam("earnInterest");
	    var goalAmount = event.getParam("goalAmount");
	    var monthlyDepositAmount = event.getParam("monthlyDepositAmount");
        component.set('v.earnInterest',earnInterest);
        component.set('v.goalAmount',goalAmount);
        component.set('v.monthlyDepositAmount',monthlyDepositAmount);
	}
    //CH02 End
})
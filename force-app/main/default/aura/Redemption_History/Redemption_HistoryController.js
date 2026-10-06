/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History: 
 *			   #CH01# Added #05-04-2021# 'changedateTo' and 'changedateFrom' Method in the JSController by Jahangeer Mohammed.
 			   
 */
({
    init: function(component,event,helper){
        component.set('v.viewRedemption','true');
        component.set("v.tbId", Math.random().toString(36).substr(2, 11)); 
        component.set('v.gridDataColumns', helper.getDataColumns(component));
        component.set('v.gridDataColumnDefs', helper.getColumnDefs(component));
        component.set('v.viewRedemption','false');
        var Option = component.get('v.preferredRewardsOption');
        console.log('v.preferredRewardsOption'+Option);
    },
    onLoadRedemptionHistory: function(component, event, helper) { 
        var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');
        component.set('v.preferredRewardsOption',component.get('v.preferredReward')['preferredRewardsOption']);
        var Option = component.get('v.preferredRewardsOption');
        var cardId = component.get('v.cardId');
        component.set('v.gridDataColumns', helper.getDataColumns(component));
        component.set('v.gridDataColumnDefs', helper.getColumnDefs(component));
        component.set('v.viewRedemption','true');
       /* if(Option!='ILA_TOKENS'){
            component.set('v.isDisable','True');
            if(Option.includes('CASHBACK')){
                component.set('v.type','cashback');
            }else{
                component.set('v.type','miles');
            }
        }*/
        helper.loadRedemptions(component, customerId, accountId,Option,cardId);
    },
    onSearchClick: function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');
        console.log('Customer Id:'+customerId);
        console.log('Account  Id:'+accountId);
        helper.runSearch(component, customerId, accountId, /*providedSearchParametersJson=*/undefined);
    },
    load : function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');
        helper.loadRedemptions(component, customerId, accountId);
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
    generatePDF: function(component, event, helper) {
        var customerId = component.get('v.customerId');
        console.log('Customer CIF Number:',customerId);
        
        var selCardId = component.get('v.selectedCardId');
        console.log('Selected Card Id:',selCardId);
        
        var accDetails = component.get('v.account');
        console.log('Account Details:',accDetails.Name);
        var accName = accDetails.Name;
        
        // Encode parameters in base64
        var encodedcustomerId = btoa(customerId);
        var encodedselCardId = btoa(selCardId);
        var encodedaccName = btoa(accName);
        
        var transactionData = component.get("v.gridDataRows");
        console.log('Transaction Table:',transactionData);
        var selectedData = [];
        
        // Iterate over the tableData and select required fields
        for (var i = 0; i < transactionData.length; i++) {
            var record = transactionData[i];
            console.log('Credit Card Transaction:',record);
            selectedData.push({
                "RedemptionDate": record.transactionDateTime,
                "RewardsOption": record.preferredRewardsOption,
                "ilaTokensType": record.tokenType,
                "RedeemedTokens": record.tokens,
                "RedeemedTokensValue": record.tokensValue,
                "Curren": record.transactionCurrency,
                "status":record.status,
                "transactionReference": record.transactionId,
                "Airline":record.airlines,
                "AirlineMembershipNumber":record.flyNumber
           });
        }
        console.log('Selected Data for Pdf:',selectedData);
        if(selectedData.length > 0){
        	// Send the selected data to the Visualforce page
        	var vfPageUrl = '/apex/creditCardRewardRedemption?data=' + encodeURIComponent(JSON.stringify(selectedData)) +
            				'&accName=' + encodeURIComponent(encodedaccName) +
            				'&customerId=' + encodeURIComponent(encodedcustomerId) +
            				'&selCardId=' + encodeURIComponent(encodedselCardId);
        	//component.set("v.vfPageUrl", vfPageUrl);
        	//component.set("v.showVFPage", true);
        	// Open the Visualforce page in a new window
        	window.open(vfPageUrl, '_blank');
        }
        else{
            component.set('v.errorPage',true);
        }
        
    }
    
})
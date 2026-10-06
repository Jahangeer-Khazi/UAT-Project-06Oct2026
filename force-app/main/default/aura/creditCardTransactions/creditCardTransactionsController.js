/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History: 
 *			   #CH01# Added #06-05-2021# 'changedateTo' and 'changedateFrom' Method in the JSController by Jahangeer Mohammed.
 *			   #CH02# #Jahangeer Mohammed# #15-08-2023# Added Logic for Pdf Generation
 *			   #CH03# #Maksud Ali 24-Sept-2025 - Added new method 'generateExcel' to download the excel file.
 */
({
    init : function(component, event, helper) {
        component.set("v.tbId", Math.random().toString(36).substr(2, 11));
       // alert('ID'+component.get("v.tbId"));
        var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');

        component.set('v.gridDataColumns', helper.getDataColumns(component));
        component.set('v.gridDataColumnDefs', helper.getColumnDefs(component));

        helper.loadTransactions(component, customerId, accountId);
        
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        
        
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
    },
    load : function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');
        helper.loadTransactions(component, customerId, accountId);
        //CH02:Start
        component.set('v.errorPage',false);
        //CH02: END
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
	//CH02: Start
	generatePDF: function(component, event, helper) {
        var customerId = component.get('v.customerId');
        console.log('Customer CIF Number:',customerId);
        
        var selCardId = component.get('v.selectedCardId');
        console.log('Selected Card Id:',selCardId);
        
        var accDetails = component.get('v.account');
        console.log('Account Details:',accDetails.Name);
        console.log('Account Region Flag:',accDetails.Region_Flag__c);
        var accName = accDetails.Name;
        var regionName = accDetails.Region_Flag__c;
        // Encode parameters in base64
        var encodedcustomerId = btoa(customerId);
        var encodedselCardId = btoa(selCardId);
        var encodedaccName = btoa(accName);
        var encodedRegName = btoa(regionName);
        var transactionData = component.get("v.gridDataRows");
        console.log('gridDataRows >> '+ JSON.stringify(component.get('v.gridDataRows')))
        console.log('gridDataRows1 >> '+ component.get('v.gridDataRows'))
        var selectedData = [];
        var searchFilters = component.get('v.searchParameterJSON');
        console.log('Search Filter Values:',searchFilters);
       
        let filters = JSON.parse(JSON.stringify(searchFilters));
        console.log('Filter Value:',filters);
       
       if(filters === null){
           console.log('Filter Value in If:',filters);
           console.log('Transaction Data Length on Load:',transactionData.length);
           if(transactionData.length > 0){
        	var vfPageUrl = '/apex/creditCardTransactionVF?accName=' + encodeURIComponent(encodedaccName) +
            				'&customerId=' + encodeURIComponent(encodedcustomerId) +
            				'&selCardId=' + encodeURIComponent(encodedselCardId) +
                			'&regionName=' + encodeURIComponent(encodedRegName);
        	
        	window.open(vfPageUrl, '_blank');
        }
        else{
            component.set('v.errorPage',true);
        }
       }
       else{
           console.log('Filter Value in else:',filters);
           console.log('Transaction Data Length in Search:',transactionData.length);
           if(transactionData.length > 0){
               var stngifyFilters = JSON.stringify(filters);
               console.log('Filters in Stringify:',stngifyFilters);
               
               var vfPageUrl = '/apex/creditCardTransactionVF2?accName=' + encodeURIComponent(encodedaccName) +
            				'&customerId=' + encodeURIComponent(encodedcustomerId) +
            				'&selCardId=' + encodeURIComponent(encodedselCardId) +
                			'&regionName=' + encodeURIComponent(encodedRegName) +
               				'&stngifyFilters=' + encodeURIComponent(stngifyFilters);
           	   window.open(vfPageUrl, '_blank');
           }
           else{
               component.set('v.errorPage',true);
           }
       }
       	
       
        
    },
   //CH02: END
   //CH03 - Start
    generateExcel: function(component, event, helper){
        var transactionData = component.get("v.gridDataRows");
        if(transactionData.length == 0){
            component.set('v.errorPage',true);
        }
        else{
            var customerId = component.get('v.customerId');
            var selCardId = component.get('v.selectedCardId');
            var accDetails = component.get('v.account');
            var filterJSON = component.get('v.filterParametersJson');
            var filterSearchJSON = component.get('v.searchParameterJSON');
            var selectedCardType = component.get('v.selectedCardType');
            console.log('151 filterJSON ',filterJSON);
            if(filterSearchJSON != null){
                filterJSON = JSON.stringify(filterSearchJSON);
            }
            console.log('151 search filterJSON ',filterJSON);
            var accName = accDetails.Name;
            var regionName = accDetails.Region_Flag__c;
            
            // Encode parameters in base64
            var encodedaccName = btoa(accName);
            var encodedselCardId = btoa(selCardId);
            var encodedcustomerId = btoa(customerId);
            var encodedRegName = btoa(regionName);
            var encodedSelectedCardType = btoa(selectedCardType);
            
            const dateFrom = component.get('v.dateFrom');
            var datePopulated = 'N';
            if(dateFrom){
                datePopulated = 'Y';
            }
            var encodedDatePopulated = btoa(datePopulated);
            
            var vfPageUrl = '/apex/CreditCardTransactionExcel?customerId=' + encodeURIComponent(encodedcustomerId) +
            				'&accName=' + encodeURIComponent(encodedaccName) +
                			'&selCardId=' + encodeURIComponent(encodedselCardId) +
                			'&regionName=' + encodeURIComponent(encodedRegName) +
               				'&stngifyFilters=' + encodeURIComponent(filterJSON) +
                			'&cardType=' + encodeURIComponent(encodedSelectedCardType) +
                			'&datePopulated=' + encodeURIComponent(encodedDatePopulated);
           	window.open(vfPageUrl, '_blank'); 
        }
    }
    //CH03 - End
})
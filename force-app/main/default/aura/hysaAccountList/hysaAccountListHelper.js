/* 	Organization : ABC Bank
 * 		Created By: Maksud Ali
 *		Created Date: 08-12-2025 (Below code is cloned from bank account List cmp)
 * 		Change History:
 *	    	   
 */
({
	loadData : function(component, customerId) {
        if ($A.util.isEmpty(customerId)) {
            console.error('hysaAccountListHelper.js: customerId not provided');
            return;
        }
	    var helper = this;
        var account = component.get('v.account');
        var regionName = account.Region_Flag__c;
        if(component.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        console.log("hysa list is loading...");
		component.find('apexService').request(component.get('c.loadHysaList'), {
		    customerId: customerId,
		    regionName: regionName
        },
		function(response,error) {
		    
            var result = response.getReturnValue();
            console.log("hysa res ",result);
            var data = [];
            var accounts = [];
            if (result.isSuccess && !$A.util.isEmpty(result.responseData.accounts)) {
                accounts = result.responseData.accounts;
            }
			
            debugger;
            for (var i = 0; i < accounts.length; i++) {
                var hysaObj = accounts[i];
                data.push(helper.formatData(hysaObj));
            }
            
            component.set('v.data', data);
		});
	},
    
    formatData: function(accountObj){
        var result = {};
        result.id = accountObj.id;
        result.productName = accountObj.productName;
        result.accountNumber = accountObj.account.number;
        result.accountCurrency = accountObj.account.currency.code;
        result.availableBalance = accountObj.account.availableBalance;
        result.status = accountObj.account.status;

        if(accountObj.hysaRate == null || accountObj.hysaRate == undefined){
            result.hysaRate = 0;
        }
        else {
            result.hysaRate = accountObj.hysaRate;
        }

        if(accountObj.debitInterestHY == null || accountObj.debitInterestHY == undefined){
            result.debitInterestHY = 0;
        }
        else {
            result.debitInterestHY = accountObj.debitInterestHY;
        }
        
        return result;
    },
    
    openAccountDetails :  function(component, customerId, accountId,curency,accountNumber,accountType) {
       component.set('v.accountId', accountId);
       component.set('v.displayAccountDetails', true);
       component.set('v.accountNumber', accountNumber);
       component.set("v.bankProductName",accountType);
       this.openTransactionList(component, customerId, accountId);
	},
    
    openTransactionList : function(component, customerId, accountId) {
       component.set('v.accountId', accountId);
       component.set('v.displayAccountTransactions', true);
	},

    requestCashCollection : function(component, customerId, accountRow) {
       var accountObj = accountRow;
       component.set('v.accountId', accountObj.id);
       component.find('cashCollectionOrDelivery-popup').open(accountObj, 'Collection');

    },
    
    requestCashDelivery : function(component, customerId, accountRow) {
       var accountObj = accountRow;
       component.set('v.accountId', accountObj.id);
       component.find('cashCollectionOrDelivery-popup').open(accountObj, 'Delivery');
    },

    loadDataInAuditObject : function(component,accIBAN) {
        var action = component.get("c.createAuditRecordForBankAcctDetails");
        var account = component.get('v.account');
        var accCIF = account.CIF__pc;
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
})
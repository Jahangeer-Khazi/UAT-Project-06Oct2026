/* 		
 * 		Change History: 
 *              #CH01# : Added by Hamza Chaoui *** pass Bahrain_alburaq in case of alburaq Product
 * 				#CH02# : #Jahangeer Mohammed# #07-08-2023# Added Logic for CAS Status(NBA-7983)
 *              #CH03# : #Tsioucha Imane# #13-09-2023
 *              #CH04# : #Jahangeer Mohammed# #28-04-2024# Added Logic for Audit History Enhancements(NBA-9027)
 *              #CH05# : #Maksud Ali# #11-11-2025# Setting bankProductName Property
 *              #CH06# : #Aitogram omar# #01-04-2026 Added logic for Dormancy Visibility Restrictions (NBA-11705) 
 */
({
	loadData : function(component, customerId) {
        if ($A.util.isEmpty(customerId)) {
            console.error('bankAccountsListHelper.js: customerId not provided');
            return;
        }
	    var helper = this;
        


        var account = component.get('v.account');
        //CH01 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product
        var regionName = account.Region_Flag__c;
        var segment = account.Segment__pc;
        component.set('v.segment',segment);
        component.set('v.region',regionName);
        if(component.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        console.error(regionName);
        console.error(customerId);
        //CH01 -End
        // CH06 start
         component.find('apexService').request(component.get('c.getJordanVisibility'), {
            customerId: customerId
        }, function (response) {
            var hideJordanFinancialDetails = response.getReturnValue();
            component.set('v.hideJordanFinancialDetails', hideJordanFinancialDetails);
            helper.setColumns(component);
        // CH06 end


		component.find('apexService').request(component.get('c.loadAccountList'), {
		    customerId: customerId,
		    regionName: regionName
        },
		function(response) {
		    var result = response.getReturnValue();
            console.log("accountlist res ",result);
            var data = [];
            var accounts = [];
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData.accounts)) {
                var allAccounts = result.responseData.accounts;
                console.log('Before Filter --->',JSON.stringify(allAccounts));
                accounts = allAccounts.filter((acc) => acc.account.accountType != 'hysa');
                console.log('After Filter --->',JSON.stringify(accounts));
            }

            for (var i = 0; i < accounts.length; i++) {
                var accountObj = accounts[i];
                data.push(helper.formatData(component, accountObj));
            }
            component.set('v.data', data);
            //console.log('Account:', data);
		});
     });

	},

    // CH06 start
      setColumns: function (component) {
        
        var enableActions = component.get('v.enableActions');
        var rowLevelActions = [
            { label: 'Show transactions', name: 'show_transactions' },
        ];

        if (true === enableActions) {
            rowLevelActions.push({ label: 'Request Cash Collection', name: 'request_cash_collection' });
            rowLevelActions.push({ label: 'Request Cash Delivery', name: 'request_cash_delivery' });
        }

        var columns = [
            { label: 'Product Name', fieldName: 'productName', type: 'text', sortable: true },
            { label: 'Account Number', fieldName: 'accountNumber', type: 'text', sortable: true }
        ];

       
        columns.push({ label: 'Account Available Balance', fieldName: 'availableBalance', type: 'number', sortable: true });
        columns.push({ label: 'Account Currency', fieldName: 'accountCurrency', type: 'text', sortable: true });
        columns.push({ label: 'Account Status', fieldName: 'status', type: 'text', sortable: true });
        columns.push({ type: 'action', typeAttributes: { rowActions: rowLevelActions } });

        component.set('v.columns', columns);
    },

    // CH06 end 
    // CH06  added hideJordanFinancialDetails for availableBalance
    formatData: function(component, accountObj){
        var result = {};
        var hideJordanFinancialDetails = component.get('v.hideJordanFinancialDetails');
        result.id = accountObj.id;
        result.productName = accountObj.productName;
        result.accountNumber = accountObj.account.number;
        result.accountCurrency = accountObj.account.currency.code;
        result.availableBalance = hideJordanFinancialDetails ? '' : accountObj.account.availableBalance;
        result.status = accountObj.account.status;

        return result;

    },
    //CH02: Added one parameter accountType
    //CH03: Adding currency and Account Number
    openAccountDetails : function(component, customerId, accountId,curency,accountNumber,accountType) {
        /*
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
        	"title": "This is a demo!",
            "message": "This action will open details of selected account."
       });
       toastEvent.fire();
       */
       component.set('v.accountId', accountId);
       //CH03: Start
       component.set('v.curency', curency);
       component.set('v.accountNumber', accountNumber);
       //CH03: Start

        //CH05 - Start
        component.set("v.bankProductName",accountType);
        //CH05 = End 

       component.set('v.displayAccountDetails', true);
        
       //CH02: Start
        if(accountType === 'BHD Account'){
            component.set('v.checkCASStatus',true);
        }
        else if(accountType != 'BHD Account'){
            component.set('v.checkCASStatus',false);
        }
        //CH02: END

       this.openTransactionList(component, customerId, accountId);
	},
    openTransactionList : function(component, customerId, accountId) {
       component.set('v.accountId', accountId);
       component.set('v.displayAccountTransactions', true);
       /*
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
        	"title": "This is a demo!",
            "message": "This action will open list of transactions on selected account."
       });
       toastEvent.fire();
      */
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
      //CH04: Start
    loadDataInAuditObject : function(component,accIBAN) {
        var action = component.get("c.createAuditRecordForBankAcctDetails");
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
    //CH04: END
})
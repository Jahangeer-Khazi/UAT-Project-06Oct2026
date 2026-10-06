/* 		Organization : ABC Bank
 * 		Created By: ABC Support
 *		Created Date: 07-10-2019
 * 		Change History:  
 *                #CH01# : Added by Hamza Chaoui *** pass Bahrain_alburaq in case of alburaq Product
 *   		      #CH02# #Jahangeer Mohammed# #02-06-2022# Added holdAmount value(NBA-5191)
 *				  #CH03# #Jahangeer Mohammed #25-05-2022# Added new fields related to Change Interest Rates(NBA-3817)
 *				  #CH05# #Jahangeer Mohammed ##08-08-2023# Setting a Region Flag
                  #CH06# #Tsioucha Imane  ##13-09-2023# Minimum Balance Fee Logic
 *				 
 *
 */
 ({
    loadData : function(component, customerId, accountId,curency,accountNumber) {
        console.log('bankAccountDetails: loadData(customerId=' + customerId + ', accountId=' + accountId + ')'+', curency=' + curency +', accountNumber=' + accountNumber + ')');
        var account = component.get('v.account');
	    var helper = this;
        var regionName = account.Region_Flag__c;
        //CH05: Start
        console.log('Region Name in Bank Account Detail:',regionName);
        component.set('v.regionName',regionName);
        //CH05: END
        if(component.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
         
		component.find('apexService').request(component.get('c.loadBondDetails'), {
		    customerId: customerId,
		    accountId: accountId,
		    regionName: regionName
        },
		function(response) {
		    var result = response.getReturnValue();
			console.log('Result====',result);
            var data = {};
            console.log('Response Data',result.responseData);
            console.log('Boolean Value',!$A.util.isEmpty(result.responseData));
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                data = result.responseData;
                console.log('Data',data);
            }
            component.set('v.data', helper.formatData(component, data));
		});
        
    },
    //CH06: Start
    formatDataMinimumBalance: function(component, accountObj){
        var result = {};
        //CH04 : START Wissal
            result.averageBalance = accountObj.account.averageBalance;      
            result.threshold = accountObj.minimumBalance.threshold; 
            result.minFee = accountObj.minimumBalance.fee; 
        	result.feeWaiver = accountObj.minimumBalance.feeWaiver; 
            result.feeWaiverReason = accountObj.minimumBalance.feeWaiverReason;
        
        //CH04 : END
        return result;

    },
    //CH06: END
    formatData: function(component, accountObj){
        var result = {};
        result.id = accountObj.id;
        result.productName = accountObj.productName;
        result.branch = accountObj.account.branch;
        result.accountNumber = accountObj.account.number;
        result.accountCurrency = accountObj.account.currency.code;
        result.accountCurrencyDecimalPlaces = accountObj.account.currency.decimalPlaces;
        result.iban = accountObj.account.iban;
        result.availableBalance = accountObj.account.availableBalance;
        result.ledgerBalance = accountObj.account.ledgerBalance;
        result.startDate = accountObj.account.startDate;
        result.overdraftLimit = accountObj.account.overdraftLimit;
        result.status = accountObj.account.status;
        result.overdraftExpiryDate = accountObj.account.overdraftExpiryDate;
        result.overdraftAvailableLimit = accountObj.account.overdraftAvailableLimit;
        result.paymentsAllowed = true === accountObj.account.paymentsAllowed ? 'Yes': 'No';
		result.transferByMobile = accountObj.transferByMobile;
        result.changeEarnInterest = accountObj.account.changedEarnInterest;
        result.changeEarnInterestStatus = accountObj.account.changedEarnInterestStatus;
        result.changeEarnInterestEffectiveDate = accountObj.account.effectiveDate;
        result.holdAmount = accountObj.account.holdAmount;        
        return result;

    }

})
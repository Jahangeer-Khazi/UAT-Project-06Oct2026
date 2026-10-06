/**
Change History :
*        
          #CH01 :  #Jahangeer Mohammed# #16-12-2024# Added Logic for Co-brand Credit Cards(NBA-12524)
          #CH02 :  #Jahangeer Mohammed# #01-04-2026# Added Logic for Jordan Balance Transfer Process(NBA-15608)

*/
({
	showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    //CH01: Start
    handleSuccess : function(msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
             mode: "sticky",
            "type":"success",
            "title": "Success!",
            "message": msg
        });
        toastEvent.fire();
    },
    handleErrors: function (errors) {
        let toastParams = {
			mode: "sticky",
			title: "Error",
			message: errors, // Default error message
			type: "error"
		};
		if(errors && Array.isArray(errors) && errors.length > 0) {
			toastParams.message = errors[0].message;
		}
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams(toastParams);
		toastEvent.fire();
	},
    //CH01: END
    //CH02: Start
    loadTenureOptions : function(component) {
        
        var selectedCard = component.get("v.selectCard");
        var configList = component.get("v.cardTypeConfig");
        
        if(!selectedCard || !configList) 
            return;
        
        var selectedConfig = configList.find(function(item) {
            return item.key === selectedCard;
        });
        
        if(!selectedConfig || !selectedConfig.value) 
            return;
        
        var configs = selectedConfig.value.cardConfigurations;
        var tenureConfig = configs.find(function(cfg) {
            return cfg.configCode === 'CC_BALANCE_TRANSFER_TENURES_CONFIG';
        });
        
        if(!tenureConfig || !tenureConfig.configValue) {
            component.set("v.tenureOptions", []);
            return;
        }
        var tenureArray = JSON.parse(tenureConfig.configValue);
        
        console.log('Parsed Tenure:', tenureArray);
        component.set("v.tenureRawData", tenureArray);
        var options = tenureArray.map(function(item) {
            return {
                key: item.tenurePeriod + ' Months',
                value: item.balanceTransferTenureCode.toString()
            };
        });
        console.log('Tenure Options:',options);
        component.set("v.tenureOptions", options);
    },
    loadProviderOptions : function(component){
        var accId = component.get("v.recordId");
        console.log('Record Id:',accId);
        var action = component.get("c.getloadCreditCardBankList");
		action.setParams({
            accId: accId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
			if(state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Bank Provider Result:', result);
				component.set("v.providerOptions", result);
            }else{
                console.error('Error fetching Bank Provider data');
            }
        });
		$A.enqueueAction(action);
    },
    calculateBalanceTransferFee : function(component) {

        var amount = component.get("v.balTransferAmt");
        var feePercentStr = component.get("v.selectedFeePercentage");

        if (!amount || !feePercentStr) {
            component.set("v.balanceTransferFee", "");
            return;
        }

        // Convert values
        var feePercent = parseFloat(feePercentStr.replace('%',''));
        amount = parseFloat(amount);

        if(isNaN(amount) || isNaN(feePercent)) {
            component.set("v.balanceTransferFee", "");
            return;
        }

        // Formula
        var fee = (amount * feePercent) / 100;

        //  Format (2 decimal places)
        fee = fee.toFixed(2);

        //  Set result
        component.set("v.balanceTransferFee", fee + " JOD");
    },
    calculateRequestedCreditLimit : function(component) {

        var amount = component.get("v.balTransferotherCardLimit");
        var selectedCard = component.get("v.selectCard");
        var configList = component.get("v.cardTypeConfig");

        if(!amount || !selectedCard || !configList) {
            component.set("v.reqCreditLimit", "");
            return;
        }

        amount = parseFloat(amount);

        //  Find selected card
        var selectedConfig = configList.find(item => item.key === selectedCard);

        if (!selectedConfig || !selectedConfig.value) return;

        var configs = selectedConfig.value.cardConfigurations;

        // Find Promotion %
        var promoConfig = configs.find(cfg => 
            cfg.configCode === 'BT_LIMIT_PROMOTION_PERCENTAGE'
        );

        if (!promoConfig || !promoConfig.configValue) {
            component.set("v.reqCreditLimit", "");
            return;
        }

        var promoPercent = parseFloat(promoConfig.configValue); // e.g. 0.25

        if(isNaN(amount) || isNaN(promoPercent)) {
            component.set("v.reqCreditLimit", "");
            return;
        }

        // Formula
        var result = amount + (amount * promoPercent);

        // Format
        result = result.toFixed(2);
        console.log('Requested Credit Limit:',result);
		component.set("v.reqCreditLimit", result);
        component.set("v.defCreditLimit", result);
    },
    resetBalanceTransferFields : function(component) {

        //  Input Fields
        component.set("v.balTransferotherCardLimit", null);
        component.set("v.balTransferAmt", null);
        component.set("v.selectedTenure", "");
        component.set("v.balCardNumber", "");

        //  Calculated Fields
        component.set("v.selectedFeePercentage", "");
        component.set("v.balanceTransferFee", "");
        component.set("v.reqCreditLimit", "");

        //  Dropdown Data
        component.set("v.tenureOptions", []);
        component.set("v.tenureRawData", []);

        //  Clear UI validation errors (important)
        this.clearError(component, "btotherLimit");
        this.clearError(component, "btAmount");
    },
    
    showError : function(component, auraId, message) {
        var cmp = component.find(auraId);

        if (!cmp) return;

        // Handle single or multiple components
        if (Array.isArray(cmp)) {
            cmp.forEach(function(item) {
                item.setCustomValidity(message);
                item.reportValidity();
            });
        } else {
            cmp.setCustomValidity(message);
            cmp.reportValidity();
        }
    },
    clearError : function(component, auraId) {
        var cmp = component.find(auraId);

        if (!cmp) return;

        // Handle single or multiple components
        if (Array.isArray(cmp)) {
            cmp.forEach(function(item) {
                item.setCustomValidity("");
                item.reportValidity();
            });
        } else {
            cmp.setCustomValidity("");
            cmp.reportValidity();
        }
    }
    //CH02: END
})
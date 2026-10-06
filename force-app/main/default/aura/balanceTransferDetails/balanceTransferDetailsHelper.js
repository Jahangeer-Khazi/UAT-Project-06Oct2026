({
	showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
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
    },
     calculateRequestedCreditLimit : function(component) {

        var amount = component.get("v.balTransferotherCardLimit");
        var selectedCard = component.get("v.record.cc_Requested_Card_Type__c");
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
     loadTenureOptions : function(component) {
        console.log('Inside Tenure Options');
        var selectedCard = component.get("v.record.cc_Requested_Card_Type__c");
        var configList = component.get("v.cardTypeConfig");
        
        console.log('Selected Card Inside Tenure Option:',selectedCard);
        console.log('Config Inside Tenure Option:',configList);
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
        // Allow Aura to render the options first, then set the selected value
         setTimeout(function(){
             var savedTenure = component.get("v.record.Balance_Transfer_Tenor__c");
              console.log('Existing Tenure:',savedTenure);
             console.log('Saved Tenure inside timeout:', savedTenure);
             if (savedTenure) {
                 var match = options.find(function(opt) {
                     return String(opt.value) === String(savedTenure);
                 });
                 console.log('Match Found:', match);
                 if (match) {
                     component.set("v.selectedTenure", null); // ← Force reset first
                     setTimeout(function() {
                         component.set("v.selectedTenure", match.value); // ← Then re-set
                     }, 0);
                 }
             }
         }, 0);
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
    }
})
({
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    handleOnSuccess : function(component, event, helper) {
        helper.hideSpinner(component);
        var message = 'The record has been updated successfully.'
       
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"success",
            "title": "Success!",
            "message": message
        });
        toastEvent.fire();
        component.set("v.isChecker",true);
           component.set("v.isSubmitButtonDisabled", true);
    },
    handleOnError: function(component, event, helper) {
        helper.hideSpinner(component);
    
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "error",
            "title": "Error!",
            "message": "An error occurred while submitting the form."
        });
        toastEvent.fire();
    },

    setFieldVisibility : function (component, subType) {
        
        if(subType =='Top-up'){
            component.set("v.isTopUp",true);
            component.set("v.isPartialSettlement", false);
            component.set("v.isInstallment", false);
            component.set("v.isEarlySettlement", false);
            component.set("v.isWaiver", false);
            component.set("v.isAdvancePayment", false);
            component.set("v.isRestructuring", false);

        } else if (subType === 'Early Settlement') {
            component.set("v.isPartialSettlement", false);
            component.set("v.isInstallment", false);
            component.set("v.isTopUp", false);
            component.set("v.isWaiver", false);
            component.set("v.isEarlySettlement", true);  
            component.set("v.isAdvancePayment", false);
            component.set("v.isRestructuring", false);
        }
        else if (subType === 'Fees Reversal / Waivers') {
            
            component.set("v.isWaiver", true);
            component.set("v.isPartialSettlement", false);
            component.set("v.isInstallment", false);
            component.set("v.isTopUp", false);
            component.set("v.isEarlySettlement", false);
            component.set("v.isAdvancePayment", false);
            component.set("v.isRestructuring", false);
            component.set("v.hasContent", true);
        } 
        else if (subType === 'Instalment Deferment / Postponement') {
            component.set("v.isInstallment", true);
            component.set("v.isPartialSettlement", false);
            component.set("v.isTopUp", false);
            component.set("v.isEarlySettlement", false);
            component.set("v.isWaiver", false);
            component.set("v.isAdvancePayment", false);
            component.set("v.isRestructuring", false);
            
        } 
        else if (subType === 'Partial Settlement') {
            component.set("v.isPartialSettlement", true);
            component.set("v.isInstallment", false);
            component.set("v.isTopUp", false);
            component.set("v.isEarlySettlement", false);
            component.set("v.isWaiver", false);
            component.set("v.isAdvancePayment", false);
            component.set("v.isRestructuring", false);
            
        }
        else if (subType === 'Advance Payment') {
            component.set("v.isAdvancePayment", true);
            component.set("v.isPartialSettlement", false);
            component.set("v.isInstallment", false);
            component.set("v.isTopUp", false);
            component.set("v.isEarlySettlement", false);
            component.set("v.isWaiver", false);
            component.set("v.isRestructuring", false);
            
        } else if (subType === 'Restructuring') {
            component.set("v.isRestructuring", true);
            component.set("v.isPartialSettlement", false);
            component.set("v.isInstallment", false);
            component.set("v.isTopUp", false);
            component.set("v.isEarlySettlement", false);
            component.set("v.isWaiver", false);
   
            
        }
        else {
            component.set("v.isRestructuring", false);
            component.set("v.isAdvancePayment", false);
            component.set("v.isPartialSettlement", false);
            component.set("v.isInstallment", false);
            component.set("v.isTopUp", false);
            component.set("v.isEarlySettlement", false);
            component.set("v.isWaiver", false);
        }
       
        
    },
    download : function(url, filename) {
        if (!url) return;

        // Prefer anchor click for best browser support + avoids popup blockers
        const a = document.createElement('a');
        a.href = url;
        if (filename) a.setAttribute('download', filename); // some browsers may still open inline
        a.target = '_self'; // avoid popup blockers
        document.body.appendChild(a);
        a.click();
        a.remove();
    },
    loadPaymentsSchedule: function (component,helper) {
		console.log('loadData Payments Schedule ');
		var customerId = component.get('v.customerId');
		var arrangementId = component.get('v.loanNumber');
        
		var searchParametersJson = {
			"arrangementId": arrangementId, 
			"type": 'Schedule'
			};
		console.log('searchParametersJson : ', JSON.stringify(searchParametersJson));
		
        var regionName = component.find("Region_Flag").get("v.value");
        let Case_Model = component.find("Case_Model").get("v.value");
        if( Case_Model != null && Case_Model == 'alburaq' ){
            regionName += '_alburaq';
        }
        
        component.find('apexService').request(component.get('c.getPaymentList'), {
		    customerId: customerId,
            searchParametersJson : JSON.stringify(searchParametersJson),
			regionName: regionName
        },
		function(response) {
			console.log('repayment schedule response:',response);
			var statut = response.getState();
			
            if (statut === 'SUCCESS') {
                let result = response.getReturnValue();
				console.log('repayment schedule response:',result);

                if (result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                    let monthlyInstallment = Number(result.headerData.monthlyInstallment);
                    let minAmount = monthlyInstallment * 3;
                    component.set('v.minPartialAmount', minAmount);
    				console.log('v.minPartialAmount --> ',component.get('v.minPartialAmount'));

                    //#CH02 : Start
                    let payOffAmount = Number(component.get('v.selectedPayOffAmount'));
                    component.set('v.maxPartialAmount', payOffAmount);
    				console.log('v.maxPartialAmount --> ',component.get('v.maxPartialAmount'));

                    let inputCmp = component.find("partialAmountInput");
                    if (inputCmp) {
                        console.log("Amount must be at least " + minAmount+ " (the sum of 3 month installments)");
                        inputCmp.set("v.messageWhenRangeUnderflow", "Amount must be at least " + minAmount+ " (the sum of 3 month installments)");
                        
                        console.log("Amount must not exceed " + payOffAmount);
                        inputCmp.set("v.messageWhenRangeOverflow","Amount must not exceed " + payOffAmount);
                    }
                    //#CH02 : END

                }
				

            } else if (statut === 'ERROR') {
                console.error(actionResult.getError());
                helper.handleErrors(actionResult.getError());
            } else {
                console.error('OTHER ERROR');
            }
		});
	},
    handleErrors: function (errors) {
		// Configure error toast
		let toastParams = {
			mode: "sticky",
			title: "Error",
			message: errors, // Default error message
			type: "error"
		};
		// Pass the error message if any
		if (errors && Array.isArray(errors) && errors.length > 0) {
			toastParams.message = errors[0].message;
		}
		// Fire error toast
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams(toastParams);
		toastEvent.fire();
	},
})
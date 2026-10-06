({
	doInit : function(component, event, helper) {
        
	},
    /*handleRecordUpdated : function(component, event, helper) {
        console.log('Handle Record Updated 1');
		var eventParams = event.getParams();
		if(eventParams.changeType === "LOADED") {
            console.log('Handle Record Updated 2');
			var accId = component.get("v.record.AccountId");
			console.log('AccountId:', accId);
			component.set("v.accountId", accId);
		}
    },*/
   
     	
    onEditClick : function(component, event, helper) {
        component.set('v.mode', 'edit');
        var balTransferOtherLimit = component.get("v.record.Balance_Transfer_Other_Card_Limit__c");
        var balTransfAmt = component.get("v.record.cc_Balance_Transfer_Amount__c");
        //var balTransfTenure = component.get("v.record.Balance_Transfer_Tenor__c");
        var reqLimit = component.get("v.record.cc_Requested_Credit_Limit__c");
        var balRate = component.get("v.record.Balance_Transfer_Rate__c");
        var balFee = component.get("v.record.Balance_Transfer_Fee__c");
        
        component.set("v.balTransferotherCardLimit",balTransferOtherLimit);
        component.set("v.balTransferAmt",balTransfAmt);
       // component.set("v.selectedTenure",balTransfTenure);
        component.set("v.reqCreditLimit",reqLimit);
        component.set("v.selectedFeePercentage",balRate);
        component.set("v.balanceTransferFee",balFee);
        
        var accId = component.get("v.record.AccountId");
        console.log('Account Id:',accId);
        var cseModel = component.get("v.record.Case_Model__c");
        console.log('Case Model:',cseModel);
        var action = component.get("c.getCardConfigurations");
        action.setParams({
            accID : accId,
            caseModel : cseModel
        });
        action.setCallback(this, function(response){

        if(response.getState() === "SUCCESS"){
			var result = response.getReturnValue();
			var fieldMap = [];
			for(var key in result){
                fieldMap.push({key: key, value: result[key]});
            }
			console.log('Card Configuration:',fieldMap);
            component.set("v.cardTypeConfig", fieldMap);
            helper.loadTenureOptions(component);
        }else if(state === "ERROR"){
            console.log('Error Occured for Card Configuration');
        }
    });
		$A.enqueueAction(action);
   },
    onCancelClick : function(component, event, helper) {
        component.set('v.mode', 'view');
        //component.set('v.enableButton',false);
	},
     handleLimitChange : function(component, event, helper) {
        
        var enteredValue = component.get("v.balTransferotherCardLimit");
        var selectedCard = component.get("v.record.cc_Requested_Card_Type__c");
        var configList = component.get("v.cardTypeConfig");
        
        if(!enteredValue || !configList){
            return;
        }
        // Convert to number
        enteredValue = parseFloat(enteredValue);
        //  Format (2 decimal places)
        //enteredValue = enteredValue.toFixed(2);
        console.log('Balance Transfer Other Card Limit:',enteredValue);
        console.log('Selected Card:',selectedCard);
        
        var selectedConfig = configList.find(function(item){
            return item.key === selectedCard; //Check Requested Card Type in Card Configuration
        });
        
        if(!selectedConfig || !selectedConfig.value){
            return;
        }
        
        var configs = selectedConfig.value.cardConfigurations;
        var minLimitObj = configs.find(function(cfg){
            return cfg.configCode === 'BT_MINIMUM_ISSUER_LIMIT';
        });
        
        if(!minLimitObj){
            return;
        }
        var minLimit = parseFloat(minLimitObj.configValue);
        console.log('Entered BT Limit:', enteredValue, 'Min BT Limit:', minLimit);
        component.set('v.btminIssuerLmt',minLimit);
        if(enteredValue < minLimit){
			helper.showError(component,"btOtherLimit","Sorry, we can't proceed as the limit entered because it's less than minimum required limit to apply for a balance transfer which is 1000 JOD");
		}else {
            helper.clearError(component,"btOtherLimit");
            helper.calculateRequestedCreditLimit(component);
        }
        
    },
    handleAmountChange : function(component, event, helper){
        var enteredValue = component.get("v.balTransferAmt");
        var btIssuerLimit = component.get('v.btminIssuerLmt');
        console.log('Entered Balance Transfer Amount:',enteredValue);
        console.log('Min Issuer Limit:',btIssuerLimit);
        
        if(btIssuerLimit === undefined){
            var selectedCard = component.get("v.record.cc_Requested_Card_Type__c");
            var configList = component.get("v.cardTypeConfig");
            if(!configList){
                return;
            }
            var selectedConfig = configList.find(function(item){
                return item.key === selectedCard; //Check Requested Card Type in Card Configuration
            });
            
            if(!selectedConfig || !selectedConfig.value){
                return;
            }
            
            var configs = selectedConfig.value.cardConfigurations;
            var minLimitObj = configs.find(function(cfg){
                return cfg.configCode === 'BT_MINIMUM_ISSUER_LIMIT';
            });
            
            if(!minLimitObj){
                return;
            }
            var minLimit = parseFloat(minLimitObj.configValue);
            console.log('Entered BT Limit:', enteredValue, 'Min BT Limit:', minLimit);
            if(enteredValue > minLimit){
                 helper.showError(component,"btAmount","Amount exceeds the other bank credit card declared credit limit.");
                component.set("v.enableButton",false);
			}else{
                helper.clearError(component,"btAmount");
                component.set("v.enableButton",true);
                helper.calculateBalanceTransferFee(component);
            }
            
        }
        else if(btIssuerLimit != undefined){
            if(enteredValue > btIssuerLimit){
                helper.showError(component,"btAmount","Amount exceeds the other bank credit card declared credit limit.");
            }else{
                helper.clearError(component,"btAmount");
                helper.calculateBalanceTransferFee(component);
            }
        }
        
    },
      handleTenureChange : function(component, event, helper) {
        
        var selectedTenure = component.get("v.selectedTenure");
        var tenureData = component.get("v.tenureRawData");
        
        if (!selectedTenure || !tenureData) 
            return;
        
        // Find matching tenure object
        var match = tenureData.find(item => item.tenurePeriod == selectedTenure);
        if(match){
            var fee = match.oneTimeFeePercentage;
            var offerCode = match.balanceTransferOfferCode;
            //Store formatted value
            component.set("v.selectedFeePercentage", fee + "%");
            component.set("v.balTransferOfferCode",offerCode);
            helper.calculateBalanceTransferFee(component);
        }else{
            component.set("v.selectedFeePercentage", "");
            component.set("v.balTransferOfferCode","");
        }
    },
     handleReqLimitChange : function(component, event, helper){
        var defLimitValue = component.get("v.defCreditLimit");
        var reqLimitValue = component.get("v.reqCreditLimit");
        console.log('Default Requested Limit:',defLimitValue);
        console.log('Requested Limit:',reqLimitValue);
        if(defLimitValue === undefined){
            var balTransferLimit = component.get("v.record.Balance_Transfer_Other_Card_Limit__c");
            console.log('Balance Transfer Limit:',balTransferLimit);
            // Formula
        	var reqLimitPlusPromo = balTransferLimit + (balTransferLimit * 0.25);
            console.log('Requested Limit Plus Promo:',reqLimitPlusPromo);
            if(reqLimitValue > reqLimitPlusPromo){
                helper.showError(component,"reqLmt","Limit can’t exceed the other credit card limit + promotion %");
                 component.set("v.enableButton",false);
            }else{
                helper.clearError(component,"reqLmt");
                 component.set("v.enableButton",true);
            }
        }
        else if(defLimitValue != undefined){
            if(reqLimitValue > defLimitValue){
           		helper.showError(component,"reqLmt","Limit can’t exceed the other credit card limit + promotion %");
            }else{
                helper.clearError(component,"reqLmt");  
            }
        }
        
    },
    handleOnSubmit : function(component, event, helper){
        console.log('Submit Method Called');
        event.preventDefault();
        var fields = event.getParam("fields");
        console.log('Balance Other Limit:',component.get("v.balTransferotherCardLimit"));
        console.log('Balance Transfer Amt:',component.get("v.balTransferAmt"));
        console.log('Balance Transfer Tenure:',component.get("v.selectedTenure"));
        console.log('Balance Transfer Rate:',component.get("v.selectedFeePercentage"));
        console.log('Balance Transfer Fee:',component.get("v.balanceTransferFee"));
 		console.log('Req Limit:',component.get("v.reqCreditLimit"));
        fields.Balance_Transfer_Other_Card_Limit__c = component.get("v.balTransferotherCardLimit");
        fields.cc_Balance_Transfer_Amount__c = component.get("v.balTransferAmt");
        fields.Balance_Transfer_Tenor__c = component.get("v.selectedTenure");
        fields.Balance_Transfer_Rate__c = component.get("v.selectedFeePercentage");
        fields.Balance_Transfer_Fee__c = component.get("v.balanceTransferFee");
        fields.cc_Requested_Credit_Limit__c = component.get("v.reqCreditLimit");
        fields.cc_Approved_Credit_Limit__c = component.get("v.reqCreditLimit");
        component.find("form").submit(fields);
        helper.showSpinner(component);
    },
    handleOnSuccess : function(component, event, helper) {
        helper.hideSpinner(component);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"success",
            "title": "Success!",
            "message": "Balance Transfer Details updated successfully."
        });
        toastEvent.fire();
         
        $A.get("e.force:closeQuickAction").fire();
        component.set('v.mode', 'view');
        //component.set('v.enableButton',false);
        
    },
    handleOnError : function(component, event, helper) {
        helper.hideSpinner(component);
        var errors = event.getParam("error");
    	console.error('Error Occurred:', JSON.stringify(errors));
	},
    
})
/**
Change History :
*         #CH01 : #D&A Team #24-06-2022# Added Case model parameter to add alburaq logic.
          #CH02 :  Added by Elmustapha team 16-11-2023 add Is C2C Customer field
          #CH03 :  #Jahangeer Mohammed# #16-12-2024# Added Logic for Co-brand Credit Cards(NBA-12524)
          #CH04 :  #Jahangeer Mohammed# #09-10-2025# Added Logic for Credit Card Spouse(NBA-15728)
          #CH05 :  #Jahangeer Mohammed# #01-04-2026# Added Logic for Jordan Balance Transfer Process(NBA-15608)

*/
({
	handleOnload : function(component, event, helper) {
        //CH03: Start
		if(component.get("v.isInit") == false){
            component.set("v.isInit",true);
            //CH05: Start
			component.find('apexService').request(component.get('c.getCardConfigurations'), {
                accID : component.get("v.recordId"),
                caseModel : component.get("v.caseModel")
            },
            //CH05: END                                     
             function(response) {
             var result = response.getReturnValue();
                 
              var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }
             console.log('Card Configuartion on Load:',fieldMap);
             //CH05: Start
             component.set("v.cardTypeConfig",fieldMap);
             //CH05: END
           });
        	component.find('apexService').request(component.get('c.getDefaultName'), {
                accID : component.get("v.recordId")
            },
             function(response) {
             var result = response.getReturnValue();
             component.find("namOnCard").set("v.value",result);
           });
            component.find('apexService').request(component.get('c.getRegionName'), {
                    accID : component.get("v.recordId")
                },
                 function(response) {
                 var result = response.getReturnValue();
                 component.set('v.regionName',result);
               });
        } //If Ends
        //CH03: END
	},
    //CH05: Start
    resetBalTransfer: function(component, event, helper){
        console.log('Change of Requested card type');
    	var region = component.get("v.regionName");
        if(region == 'Bahrain'){
            return;
        }else{
            var checkIsBalanceTransfer = component.get("v.isBalanceTransfer");
            console.log('Check Balance Transfer value:',checkIsBalanceTransfer);
            if(!checkIsBalanceTransfer){
                console.log('Check Balance Transfer value in if');
                return;
            }else{
                console.log('Check Balance Transfer value in else');
                component.set("v.isBalanceTransfer",false);
                //RESET EVERYTHING
        	    helper.resetBalanceTransferFields(component);
            }
        }
	},
    isBalanceTransferChange: function(component, event, helper){
        const isBalTransfChecked = event.getSource().get("v.value");
        console.log('Has Balance Tansf Chcked for Jordan:',isBalTransfChecked);
        component.set("v.isBalanceTransfer", isBalTransfChecked);  
        if(isBalTransfChecked){
            helper.loadTenureOptions(component);
            helper.loadProviderOptions(component);
        }else{
            //RESET EVERYTHING
        	helper.resetBalanceTransferFields(component);
        }
    },
    handleProviderChange : function(component, event, helper){
        var selectedProvider = event.getSource().get("v.value");
        console.log('selectedProvider is:',selectedProvider);
        if(!selectedProvider){
            console.log('After Selecting None Option');
            component.find("isBT").set("v.value", false);
            //RESET EVERYTHING
        	helper.resetBalanceTransferFields(component);
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
    handleLimitChange : function(component, event, helper) {
        
        var enteredValue = component.get("v.balTransferotherCardLimit");
        var selectedCard = component.get("v.selectCard");
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
			helper.showError(component,"btotherLimit","Sorry, we can't proceed as the limit entered because it's less than minimum required limit to apply for a balance transfer which is 1000 JOD");
		}else {
            helper.clearError(component,"btotherLimit");
            helper.calculateRequestedCreditLimit(component);
        }
        
    },
    handleAmountChange : function(component, event, helper){
        var enteredValue = component.get("v.balTransferAmt");
        var btIssuerLimit = component.get('v.btminIssuerLmt');
        
        console.log('Entered Balance Transfer Amount:',enteredValue);
        console.log('Min Issuer Limit:',btIssuerLimit);
        
        if(enteredValue > btIssuerLimit){
            helper.showError(component,"btAmount","Amount exceeds the other bank credit card declared credit limit.");
 		}else{
            helper.clearError(component,"btAmount");
            helper.calculateBalanceTransferFee(component);
        }
    },
    handleReqLimitChange : function(component, event, helper){
        var defLimitValue = component.get("v.defCreditLimit");
        var reqLimitValue = component.get("v.reqCreditLimit");
        console.log('Default Requested Limit:',defLimitValue);
        console.log('Requested Limit:',reqLimitValue);
        if(reqLimitValue > defLimitValue){
           helper.showError(component,"reqLmt","Limit can’t exceed the other credit card limit + promotion %");
        }else{
          helper.clearError(component,"reqLmt");  
        }
    },
    //CH05: END
    handleOnSubmit: function(component, event, helper) {
        //CH03: Start
        console.log('In Submit Method');
        event.preventDefault();
        //CH04: Added hasSpouse in if condition 
        if(component.get("v.selectCard") == 'ILA_GULF_AIR_COBRAND_01' && ((component.get("v.hasCoBrandMembership") == true) && component.get("v.hasSpouse") == true)){
            console.log('Has Spouse CIF With Membership Number');
            var checkValidateNumberButtonClicked = component.get("v.hasValidateNumberButtonClicked");
            //CH04: Start
            var checkCIFNumberButtonClicked = component.get("v.hasValidateCIFButtonClicked");
            //CH04: END
            var membershipNo = component.get("v.embossingLine4");
            //CH04: Start
            var hasSpouse = component.get("v.hasSpouse");
            var cifNumber = component.get("v.spouseCif");
            //CH04: END
            console.log('Membership No:',membershipNo);
            console.log('Button Clicked:',checkValidateNumberButtonClicked);
            if(checkValidateNumberButtonClicked == false && membershipNo != ''){
                helper.handleErrors("Please Validate the Membership Number");
            }
            //CH04: Start
            else if(checkCIFNumberButtonClicked == false && cifNumber != ''){
                helper.handleErrors("Please Validate the CIF Number");
            }
            else if(hasSpouse == true && cifNumber == ''){
                helper.handleErrors("Please Enter the CIF Number");
            }
            //CH04: END
            else{
                console.log('submit the form for Ila Gulf With Cobrand Membership and Spouse CIF');
                component.find('form').submit();
                helper.showSpinner(component);
            }
        }
        else if(component.get("v.selectCard") == 'ILA_GULF_AIR_COBRAND_01' && ((component.get("v.hasCoBrandMembership") == true) && component.get("v.hasSpouse") == false)){
            console.log('Has Co-brand Membership Number Without Spouse CIF');
            var checkValidateNumberButtonClicked = component.get("v.hasValidateNumberButtonClicked");
            var membershipNo = component.get("v.embossingLine4");
            console.log('Membership No:',membershipNo);
            console.log('Button Clicked:',checkValidateNumberButtonClicked);
            if(checkValidateNumberButtonClicked == false && membershipNo != ''){
                helper.handleErrors("Please Validate the Membership Number");
            }
            else{
                console.log('submit the form for Ila Gulf With Cobrand Membership and Without Spouse CIF');
                component.find('form').submit();
                helper.showSpinner(component);
            }
        }
        //CH04: Start
        else if(component.get("v.selectCard") == 'ILA_GULF_AIR_COBRAND_01' && ((component.get("v.hasCoBrandMembership") == false) && component.get("v.hasSpouse") == true)){
            console.log('Has Spouse CIF Without Membership Number');
            var checkCIFNumberButtonClicked = component.get("v.hasValidateCIFButtonClicked");
            var hasSpouse = component.get("v.hasSpouse");
            var cifNumber = component.get("v.spouseCif");
            if(checkCIFNumberButtonClicked == false && cifNumber != ''){
                helper.handleErrors("Please Validate the CIF Number");
            }
            else if(hasSpouse == true && cifNumber == ''){
                helper.handleErrors("Please Enter the CIF Number");
            }
            else{
                console.log('submit the form for Ila Gulf Without Cobrand Membership and having Spouse CIF');
				component.find('form').submit();
            	helper.showSpinner(component);
            }
            
        }
        else if(component.get("v.selectCard") == 'ILA_GULF_AIR_COBRAND_01' && ((component.get("v.hasCoBrandMembership") == false) && component.get("v.hasSpouse") == false)){
            console.log('submit the form for Ila Gulf Without Cobrand Membership Number and Without Spouse CIF');
            component.find('form').submit();
            helper.showSpinner(component);
        }
        //CH04: END
        else if(component.get("v.selectCard") != 'ILA_GULF_AIR_COBRAND_01'){
            console.log('submit the form for Non Cobrand Cards');
            //CH05: Start
            var regionName = component.get('v.regionName');
            var isBlanceTransfer = component.get('v.isBalanceTransfer');
            console.log('Region Flag on Submit:',regionName);
            console.log('Is Balance Transfer on Submit:',isBlanceTransfer);
            if(regionName == 'Bahrain'){
                component.find('form').submit();
            	helper.showSpinner(component);
            }else if(regionName == 'Jordan' && isBlanceTransfer == false){
                component.find('form').submit();
            	helper.showSpinner(component);
            }else if(regionName == 'Jordan' && isBlanceTransfer == true){
                var fields = event.getParam("fields");
                fields.cc_Balance_Transfer_Card_Number__c = component.get("v.balCardNumber");
                fields.cc_Balance_Transfer_Amount__c = component.get("v.balTransferAmt");
                fields.cc_Balance_Transfer_Card_Provider__c = component.get("v.selectedProvider");
                component.find('form').submit(fields);
            	helper.showSpinner(component);
            }
            //CH05: END
            
        }
        //CH03: END 
        //helper.showSpinner(component);
    },
    handleOnSuccess : function(component, event, helper) {
        helper.hideSpinner(component);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"success",
            "title": "Success!",
            "message": "Case has been created successfully."
        });
        toastEvent.fire();
         
        $A.get("e.force:closeQuickAction").fire();
    },
    handleOnError : function(component, event, helper) {
        helper.hideSpinner(component);
	},
    onCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    caseModelIsChanged : function(component, event, helper) {
        console.error('is changed caseModelIsChanged');
        //#CH01
        component.find('requestedCardType').set('v.value','');
		component.find('apexService').request(component.get('c.getCardOptions'), {
            accID : component.get("v.recordId"),
            caseModel : component.get("v.caseModel")
        },
         function(response) {
         var result = response.getReturnValue();
             
          var fieldMap = [];
            for(var key in result){
                fieldMap.push({key: key, value: result[key]});
            }
         console.log('Array On Case Model Change:',fieldMap);
         component.set("v.cc_cardType",fieldMap);
       });
    },
    handleLoad: function (component, event, helper) {//CH01
		console.log('handleLoad  cmp---');
        let subscriptionModel = component.find("Subscription_Model").get("v.value");
        if( subscriptionModel != null && subscriptionModel == 'alburaq' ){
            component.set('v.caseModel',subscriptionModel);
        }else{
            component.set('v.caseModel','ila');
        }
        // Start CH02 
        let Segment = component.find("Customer_Segment").get("v.value");
        console.log(Segment);
        component.set('v.Segment', Segment);
        // End CH02 
	},
    //CH04: Start
    handleSpouseChange : function(component, event, helper){
        const isCheckedSpouse = event.getSource().get("v.value");
        console.log('Has Spouse Chcked:',isCheckedSpouse);
        component.set("v.hasSpouse", isCheckedSpouse);
    },
    handleSpouseCIFChange: function (component, event, helper){
       // Get the value of the Spouse CIF field
        var inputValue = event.getSource().get("v.value");
        // If the field is empty, clear the error and stop validation
    	if(!inputValue.trim()){
        	component.set("v.spouseCifError", "");
        	component.set("v.spouseCif", "");
        	return;
    	}
        // validate: exactly 7 digits
    	var isValid = /^\d{7}$/.test(inputValue);
        console.log('CIF Number:',isValid);
    	if(!isValid){
        	component.set("v.spouseCifError", "Please enter a 7-digit numeric value.");
    	}else{
        	component.set("v.spouseCifError", "");
        	component.set("v.spouseCif", inputValue); //Update the spouseCif attribute
    	}
    },
    //CH04: END
    //CH03: Start
     handleCobrandChange: function (component, event, helper) {
        const isChecked = event.getSource().get("v.value");
        console.log('Has Cobrand Chcked:',isChecked);
        component.set("v.hasCoBrandMembership", isChecked);
    },
    handleBalanceTransferChange: function (component, event, helper) {
        const isBalTransfChecked = event.getSource().get("v.value");
        console.log('Has Balance Tansf Chcked:',isBalTransfChecked);
        component.set("v.hasBalanceTransfer", isBalTransfChecked);
    },
    handleEmbossChange: function (component, event, helper) {
        // Get the value of the Embossing Line 4 field
        var inputValue = event.getSource().get("v.value");
        component.set("v.embossingLine4", inputValue); // Update the embossingLine4 attribute
    },
    fetchMembershipId: function (component, event, helper) {
        helper.showSpinner(component);
        component.set("v.hasValidateNumberButtonClicked",true);
        var accId = component.get("v.recordId");
        var memberId = component.get("v.embossingLine4");
        console.log('Record Idd:',accId);
        console.log('Membership Idd:',memberId);
        var action = component.get("c.fetchGulfAirId");
        action.setParams({
            customerId: accId,
            membershipId: memberId
        });
        action.setCallback(this, function (response){
            var state = response.getState();
            if(state === "SUCCESS"){
               console.log('Getting response Map:',response.getReturnValue());
               var response = response.getReturnValue();
                console.log('Code:',response.meta.code);
                if(response.meta.code === 'GULF-1000'){
                    helper.handleSuccess("Gulf air Membership Id have been found successfully.");
                    helper.hideSpinner(component);
                }
                else if(response.meta.code != 'GULF-1000'){
                    helper.handleErrors("Please Enter a Valid Membership Id of a customer");
                    helper.hideSpinner(component);
                    component.set("v.embossingLine4","");
                }
               
            }else if(state === "ERROR") {
                helper.handleErrors(response.getError());
                helper.hideSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    //CH03: END
    //CH04: Start
    ValidateCIFNumber: function (component, event, helper){
        helper.showSpinner(component);
         component.set("v.hasValidateCIFButtonClicked",true);
        var accId = component.get("v.recordId");
        var cifNumber = component.get("v.spouseCif");
        console.log('Acct Record Id:',accId);
        console.log('CIF Number:',cifNumber);
        var action = component.get("c.checkCIFNumber");
        action.setParams({
            accountId: accId,
            cifNumber: cifNumber
        });
        action.setCallback(this, function (response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log('Getting response CIF Number:',response.getReturnValue());
                var cifFound = response.getReturnValue();
                console.log('Response Value:',cifFound);
                if(cifFound === true){
                    helper.hideSpinner(component);
                    helper.handleSuccess("Entered CIF is valid.");
                    component.find('apexService').request(component.get('c.getFirstAndLastName'), {
                		cifNumber: cifNumber
            		},
             		function(response){
             			var result = response.getReturnValue();
                        console.log('First & Last Name:',result);
             			component.find("namOnCard").set("v.value",result);
           			});
                }
                else if(cifFound === false){
                    helper.hideSpinner(component);
                    helper.handleErrors("Entered CIF is not valid.");
                    component.set("v.spouseCif","");
                    component.find('apexService').request(component.get('c.getDefaultName'), {
                		accID : component.get("v.recordId")
            		},
             		function(response) {
             			var result = response.getReturnValue();
             			component.find("namOnCard").set("v.value",result);
           			});
                }
            }
            else if(state === "ERROR"){
                helper.hideSpinner(component);
                helper.handleErrors(response.getError());
                
            }
        });
        $A.enqueueAction(action);
 	}
    //CH04: END
})
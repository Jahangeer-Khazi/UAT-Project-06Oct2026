/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date: 15-08-2024
 * 		Change History: 
 * 						#CH01# #03-08-2026# #Jahangeer Mohammed# Added Campaign Upgrade Logic(NBA-17681)
 * 			
 *			  
 */
({
    handleOnload : function(component, event, helper) {
        if(component.get("v.ishandleLoad") == false){
            component.set("v.ishandleLoad",true);
            let subType = component.get("v.cc_subType");
            console.log('Sub Type Value:',subType);
            
            let creditCardExist;
            
            component.find('apexService').request(component.get('c.checkOtherCardsExist'),{
            	 accID : component.get("v.recordId") 
            },
            function(response){
                  creditCardExist = response.getReturnValue();
            	  console.log('Check Credit Cards Exist',creditCardExist);                                     
            });
            component.find('apexService').request(component.get('c.getCreditCardUpgradeOptions'), {
                accID : component.get("v.recordId"),
                caseModel : component.get("v.caseModel"),
                subType : component.get("v.cc_subType")
            },
            function(response) {
                var result = response.getReturnValue();
            	console.log('Result Value On Load:',result);   
                var fieldMap = [];
                for(var key in result){
                //"cardId":will contain the id of the card & "cardObj": will contain the cardObj data
                	fieldMap.push({key: key, value: result[key] });
                }
                console.log('Array On Load Upgrade Options:',fieldMap);
                if(creditCardExist === true && fieldMap.length === 0){
                     helper.handleErrors("Customer has an open credit card case");
                }
                else if(creditCardExist === true && fieldMap.length != 0){
                    helper.handleErrors("Customer has an open credit card case");
                }
                else{
                    component.set("v.cardUpgradeOptions",fieldMap);
                }
           });
            
       }
        
    },
    handleOnSubmit: function(component, event, helper) {
        event.preventDefault();
        var subType = component.get("v.cc_subType");
        var isDelinquent = component.get("v.isDelinquent");
        
        var currentCreditLimit = component.get("v.currentCreditLimit");
        console.log('Current Credit Limit:',currentCreditLimit);
        console.log('Current Credit Limit Type:',typeof currentCreditLimit);
        var currentCardMinCreditLimit = component.get("v.currentCardMinCreditLimit");
        
        var newCardMinCreditLimit = component.get("v.newCardMinCreditLimit");
        var newCreditMinLimit = parseInt(newCardMinCreditLimit);
        
        var newCardLimit = component.get("v.newCardLimit");
        var newCreditLimit = parseInt(newCardLimit);
        
        var isCashCol = component.get("v.isCashCollateral");
        console.log('Is CashCollateral:',isCashCol);
        var existingCreditNewLimit;
        var existingCardHoldAmount;
        var newCardHoldAmount;
        var diffofHoldAmmount;
        
        if(isCashCol == false){
            existingCreditNewLimit = currentCreditLimit - newCreditLimit; //Formula for Existing Card New Credit Limit
        	console.log('Existing Card New Credit Limit:',existingCreditNewLimit);
        	component.set("v.existingCardNewCreditLimit",existingCreditNewLimit);
        }
        else if(isCashCol == true)
        {
            ////////////////////////////////////////// START: CHECKING EXISTING CREDIT LIMIT LESS THEN 6000////////////////
            if(currentCreditLimit < 6000){
                existingCardHoldAmount = Math.trunc((currentCreditLimit * 120)/100);
                console.log('Existing Hold Amount in if condition:',existingCardHoldAmount);
                
                ///////////////////////////////////////  START: NEW CREDIT LIMIT LESS THEN 6000 /////////////////////////
                if(newCreditLimit < 6000){
                    newCardHoldAmount = Math.trunc((newCreditLimit * 120)/100);
                    console.log('New Card Hold Amount in if condition:',newCardHoldAmount);
                    diffofHoldAmmount = existingCardHoldAmount - newCardHoldAmount;
                    console.log('Difference Hold Amount in if condition:',diffofHoldAmmount);
                    var newCardPercentage = 120;
                    component.set("v.newHoldAmount",newCardHoldAmount);
                    component.set("v.newCardPercentage",newCardPercentage);
                    
                    if(diffofHoldAmmount < 6660){
                      existingCreditNewLimit = Math.trunc((diffofHoldAmmount/120) * 100);
                      var existCardNewPercentage = 120;
                      console.log('Hold Amount After Calculating < 6660:',existingCreditNewLimit);
                      component.set("v.existingCardNewCreditLimit",existingCreditNewLimit);
                      component.set("v.existingCardNewHoldAmount",diffofHoldAmmount);
                      component.set("v.existingCardNewPercentage",existCardNewPercentage);
                   }
                    
                }
                /////////////////////////////////////// END: NEW CREDIT LIMIT LESS THEN 6000 /////////////////////////

                ///////////////////////////////////////  START: NEW CREDIT LIMIT GREATER THEN 6000 /////////////////////////
				/*else if(newCreditLimit >= 6000){
                    newCardHoldAmount = (newCreditLimit * 111)/100;
                    console.log('New Card Hold Amount in else condition:',newCardHoldAmount);
                    diffofHoldAmmount = existingCardHoldAmount - newCardHoldAmount;
                    console.log('Difference Hold Amount in if condition:',diffofHoldAmmount);
                    
                    if(diffofHoldAmmount >= 6000){
                      existingCreditNewLimit = (diffofHoldAmmount/111) * 100;
                      console.log('Hold Amount After Calculating > 6000:',existingCreditNewLimit);
                    }
                    else if(diffofHoldAmmount < 6000){
                      existingCreditNewLimit = (diffofHoldAmmount/120) * 100;
                      console.log('Hold Amount After Calculating < 6000:',existingCreditNewLimit);
                    }
                }*/
                ///////////////////////////////////////  END: NEW CREDIT LIMIT GREATER THEN 6000 /////////////////////////

            }
            ////////////////////////////////////////// END: CHECKING EXISTING CREDIT LIMIT LESS THEN 6000////////////////

            else if(currentCreditLimit >= 6000){
                existingCardHoldAmount = Math.trunc((currentCreditLimit * 111)/100);
                console.log('Existing Hold Amount in else condition:',existingCardHoldAmount);
                if(newCreditLimit < 6000){
                    newCardHoldAmount = Math.trunc((newCreditLimit * 120)/100);
                    console.log('New Card Hold Amount in if condition:',newCardHoldAmount);
                    diffofHoldAmmount = existingCardHoldAmount - newCardHoldAmount;
                    console.log('Difference Hold Amount in if condition:',diffofHoldAmmount);
                    
                    var newCardPercentage = 120;
                    component.set("v.newHoldAmount",newCardHoldAmount);
                    component.set("v.newCardPercentage",newCardPercentage);
                    
                    if(diffofHoldAmmount >= 6660){
                      existingCreditNewLimit = Math.trunc((diffofHoldAmmount/111) * 100);
                      var existCardNewPercentage = 111;
                      console.log('Hold Amount After Calculating > 6660:',existingCreditNewLimit);
                      component.set("v.existingCardNewCreditLimit",existingCreditNewLimit);
                      component.set("v.existingCardNewHoldAmount",diffofHoldAmmount);
                      component.set("v.existingCardNewPercentage",existCardNewPercentage);
                    }
                    else if(diffofHoldAmmount < 6660){
                      existingCreditNewLimit = Math.trunc((diffofHoldAmmount/120) * 100);
                      var existCardNewPercentage = 120;
                      console.log('Hold Amount After Calculating < 6660:',existingCreditNewLimit);
                      component.set("v.existingCardNewCreditLimit",existingCreditNewLimit);
                      component.set("v.existingCardNewHoldAmount",diffofHoldAmmount);
                      component.set("v.existingCardNewPercentage",existCardNewPercentage);
                    }
                }
                else if(newCreditLimit >= 6000){
                    newCardHoldAmount = Math.trunc((newCreditLimit * 111)/100);
                    console.log('New Card Hold Amount in else condition:',newCardHoldAmount);
                    diffofHoldAmmount = existingCardHoldAmount - newCardHoldAmount;
                    console.log('Difference Hold Amount in else if condition:',diffofHoldAmmount);
                    
                    var newCardPercentage = 111;
                    component.set("v.newHoldAmount",newCardHoldAmount);
                    component.set("v.newCardPercentage",newCardPercentage);
                    
                    if(diffofHoldAmmount >= 6660){
                      existingCreditNewLimit = Math.trunc((diffofHoldAmmount/111) * 100);
                      var existCardNewPercentage = 111;
                      console.log('Hold Amount After Calculating > 6660:',existingCreditNewLimit);
                      component.set("v.existingCardNewCreditLimit",existingCreditNewLimit);
                      component.set("v.existingCardNewHoldAmount",diffofHoldAmmount);
                      component.set("v.existingCardNewPercentage",existCardNewPercentage);
                    }
                    else if(diffofHoldAmmount < 6660){
                      existingCreditNewLimit = Math.trunc((diffofHoldAmmount/120) * 100);
                      var existCardNewPercentage = 120;
                      console.log('Hold Amount After Calculating < 6660:',existingCreditNewLimit);
                      component.set("v.existingCardNewCreditLimit",existingCreditNewLimit);
                      component.set("v.existingCardNewHoldAmount",diffofHoldAmmount);
                      component.set("v.existingCardNewPercentage",existCardNewPercentage);
                    }
                }
            }
        }        
        var existingOutStandingBalance = component.get("v.currentCardMinOutStandingBalance");
        console.log('Out Standing Balance:',existingOutStandingBalance);
        var belowOutStandingBalance = existingOutStandingBalance - existingCreditNewLimit;
        
        console.log('Current Credit Limit Type:',typeof currentCardMinCreditLimit);
        console.log('New Credit Limit Type:',typeof newCardMinCreditLimit);
        
        console.log('New Credit Limit:',newCardLimit);
        console.log('New Card Min Credit Limit:',newCardMinCreditLimit);
        
        var sumOfExistingProductLimit = (parseInt(currentCardMinCreditLimit) + parseInt(newCardMinCreditLimit));
        
        console.log('Current Credit Limitt:',currentCreditLimit);
        console.log('Sum of Existing Product Limit:',sumOfExistingProductLimit);
        
        if(component.get("v.selectedCard") == 'ILA_GULF_AIR_COBRAND_01' && component.get("v.hasCoBrandMembership") == true && subType == 'Credit Card Upgrade - No Limit Increase'){
            var checkValidateNumberButtonClicked = component.get("v.hasValidateNumberButtonClicked");
            var membershipNo = component.get("v.embossingLine4");
            console.log('Membership No:',membershipNo);
            console.log('Button Clicked:',checkValidateNumberButtonClicked);
            
            if(checkValidateNumberButtonClicked == false && membershipNo != ''){
                helper.handleErrors("Please Validate the Membership Number");
            }
            else{
                console.log('submit the form for Ila Gulf With Cobrand Membership');
                component.find('form').submit();
                helper.showSpinner(component);
            }
        }
        else if(component.get("v.selectedCard") == 'ILA_GULF_AIR_COBRAND_01' && component.get("v.hasCoBrandMembership") == false && subType == 'Credit Card Upgrade - No Limit Increase'){
            console.log('submit the form for Ila Gulf Without  Cobrand Membership');
            component.find('form').submit();
            helper.showSpinner(component);
        }
         else if(component.get("v.selectedCard") != 'ILA_GULF_AIR_COBRAND_01' && subType == 'Credit Card Upgrade - No Limit Increase'){
            console.log('submit the form for Non Cobrand Cards');
            component.find('form').submit();
            helper.showSpinner(component);
        }
        /////////////////////////////////////// Checking Delinquency Status ///////////////////////////////
        
        else if(subType === 'Credit Card Limit Split' && isDelinquent == true){
            helper.handleErrors("Existing credit card is delinquent. Please pay your dues first");    
        }
        /////////////////////////////////////// Checking Delinquency Status ///////////////////////////////
 
        ////////////////////////////////////// Checking Current Limit with Existing Minimun Product + New Product Minimum Limit/////////////////////
        
        else if(subType === 'Credit Card Limit Split' && currentCreditLimit < sumOfExistingProductLimit){
            helper.handleErrors("Existing card credit limit doesn't meet product minimum limit for existing and new cards together");    
        }
        ////////////////////////////////////// Checking Current Limit with Existing Minimun Product + New Product Minimum Limit/////////////////////

        /////////////////////////////////////// Checking Current Limit with New Product Minimum Limit /////////////////////////////////////////////
        
        else if(subType === 'Credit Card Limit Split' && newCreditLimit < newCreditMinLimit){
            helper.handleErrors("New card credit limit doesn't meet new product minimum limit" + ' ' + newCardMinCreditLimit + ' ' + "BHD");    
        }
        /////////////////////////////////////// Checking Current Limit with New Product Minimum Limit /////////////////////////////////////////////

        ////////////////////////////////////// Checking Existing Card New Limit With Existing Product Minimum Limit //////////////////////////////////
        
        else if(subType === 'Credit Card Limit Split' && existingCreditNewLimit < parseInt(currentCardMinCreditLimit)){
            helper.handleErrors("Existing card credit new limit doesn't meet new product minimum limit " + ' ' + parseInt(currentCardMinCreditLimit) + ' ' + "BHD");    
        }
        ////////////////////////////////////// Checking Existing Card New Limit With Existing Product Minimum Limit //////////////////////////////////

        ///////////////////////////////////// Checking Existing Card New Limit With Outstanding Balance ///////////////////////////////////////////////
        //console.log('Absolute Value Outstanding Balance:',Math.abs(existingOutStandingBalance));
        else if(subType === 'Credit Card Limit Split' && existingCreditNewLimit < Math.abs(existingOutStandingBalance)){
            helper.handleErrors("New credit limit of existing card is below outstanding balance. Customer should pay " + ' ' + belowOutStandingBalance + ' ' + "BHD");    
        }
        ///////////////////////////////////// Checking Existing Card New Limit With Outstanding Balance ///////////////////////////////////////////////

        else if(component.get("v.selectedCard") == 'ILA_GULF_AIR_COBRAND_01' && component.get("v.hasCoBrandMembership") == true && subType == 'Credit Card Limit Split'){
            var checkValidateNumberButtonClicked = component.get("v.hasValidateNumberButtonClicked");
            var membershipNo = component.get("v.embossingLine4");
            console.log('Membership No:',membershipNo);
            console.log('Button Clicked:',checkValidateNumberButtonClicked);
            
            if(checkValidateNumberButtonClicked == false && membershipNo != ''){
                helper.handleErrors("Please Validate the Membership Number");
            }
            else if(checkValidateNumberButtonClicked == false && membershipNo == ''){
                helper.handleErrors("Co-brand membership number for new card is missing");
            }
            else{
                console.log('submit the form for Ila Gulf With Cobrand Membership in split');
                component.find('form').submit();
                helper.showSpinner(component);
            }
        }
        
        else if(subType === 'Credit Card Limit Split' && component.get("v.selectedCard") != 'ILA_GULF_AIR_COBRAND_01'){
            console.log('submit the form for Non Cobrand Cards in Split');
            component.find('form').submit();
            helper.showSpinner(component);    
        }
        else if(component.get("v.selectedCard") == 'ILA_GULF_AIR_COBRAND_01' && component.get("v.hasCoBrandMembership") == false && subType == 'Credit Card Limit Split'){
            console.log('submit the form for Ila Gulf Without  Cobrand Membership in Split');
            component.find('form').submit();
            helper.showSpinner(component);
        }
       
        
        
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
        	
        component.find('requestedPCINumber').set('v.value','');	
        component.find('apexService').request(component.get('c.getCreditCardPCIOptions'), {	
            accID : component.get("v.recordId"),	
            caseModel : component.get("v.caseModel")	
        },	
         function(response) {	
         	var result = response.getReturnValue();	
            console.log('Card Object Result:',result);	
          	var fieldMap = [];	
            	for(var key in result){	
                	fieldMap.push({cardId: key, cardObj: result[key]});	
            	}
            	console.log('Array On Case Model Change:',fieldMap);
         		component.set("v.cc_cardPCINumber",fieldMap);	
          });
        
         component.find('apexService').request(component.get('c.getDefaultName'), {
                accID : component.get("v.recordId")
            },
            function(response) {
            	var result = response.getReturnValue();
                component.find("namOnCard").set("v.value",result);
            });
        //CH01: Start
        component.find('apexService').request(component.get('c.isCampaignUpgradeUser'), {
                
            },
            function(response) {
            	var result = response.getReturnValue();
                console.log('Is Campaign Upgrade User:',result);
                component.set("v.isCampaignUpgradeUser",result);
            });
        //CH01: END	
    },	
    handleLoad: function (component, event, helper) {
		console.log('handleLoad  cmp---'+component.find("Subscription_Model").get("v.value"));	
        let subscriptionModel = component.find("Subscription_Model").get("v.value");	
        if( subscriptionModel != null && subscriptionModel == 'alburaq' ){	
            component.set('v.caseModel',subscriptionModel);	
        }else{	
            component.set('v.caseModel','ila');	
        }
        //CH01: Start
        let segment = component.find("Segment").get("v.value");
        console.log('Segment Value is:',segment);
        component.set('v.customerSegment',segment);
        //CH01: END
    },	
    requestPCINumberChange: function (component, event, helper) {	
		let requestedPCINumber = component.find("requestedPCINumber").get("v.value");
        console.log('Req PCI Number:',requestedPCINumber);
		if(requestedPCINumber != null && requestedPCINumber != ''){	
            var myValues = [];
            myValues= component.get("v.cc_cardPCINumber");	
            myValues.findIndex(item => {	//Fetching the Card Type on change of Mask Card Number
                if(item.cardId == requestedPCINumber){	
                    component.set( 'v.requestedCardType' , item.cardObj.productMappingCode );
                    component.set('v.maskCardNumber', item.cardObj.maskedCardNumber);
                    component.set('v.isDelinquent',item.cardObj.isDelinquent);
                    
                    console.log('Is Delinquent:',item.cardObj.isDelinquent);
                	console.log('Card Nature:',item.cardObj.cardNature);
                    console.log('Card Config:',item.cardObj.cardConfigurations);
                    console.log('Hold Acc IBAN:',item.cardObj.holdAccount);
                    console.log('Hold Ref Num:',item.cardObj.holdReference);
                    
                    component.set('v.currentCardMinCreditLimit','');
                    component.set('v.currentCardHoldIBAN','');
                    component.set('v.currentCardHoldRefNumber','');
                    
                    let configData = item.cardObj.cardConfigurations;
                    if(item.cardObj.cardNature === 'secured'){
                		component.set('v.isCashCollateral',true);
                        let minCurrentCardLimitSecured = configData.find((config) => config.configCode === 'MINIMUM_CREDIT_LIMIT_SECURED');
                	    console.log('Min Current Card Limit Secured:',minCurrentCardLimitSecured.configValue);
                		component.set('v.currentCardMinCreditLimit',minCurrentCardLimitSecured.configValue);
                		component.set('v.currentCardHoldIBAN',item.cardObj.holdAccount);
                		component.set('v.currentCardHoldRefNumber',item.cardObj.holdReference);
            		}
                    else if(item.cardObj.cardNature === 'unsecured'){
                        component.set('v.isCashCollateral',false);
                        let minCurrentCardLimitUnSecured = configData.find((config) => config.configCode === 'MINIMUM_CREDIT_LIMIT_UNSECURED');
                		console.log('Min Current Card Limit Unsecuredd:',minCurrentCardLimitUnSecured.configValue);
                        component.set('v.currentCardMinCreditLimit',minCurrentCardLimitUnSecured.configValue);
                    }
                    
                }	
            });	
		}else{	
			component.set("v.requestedCardType",null);	
		}
        //Call Again Credit Card List API to fetch only Supplementary Cards related to specific PCI Number
        component.find('apexService').request(component.get('c.getPCIOptionsSuppCards'), {
                accID : component.get("v.recordId"),
            	caseModel : component.get("v.caseModel"),
                requestedPCINumber :  requestedPCINumber
            },
             function(response) {
             	var result = response.getReturnValue();
             	console.log('Result Value On Change of PCI Number:',result); 
                console.log('Result Type On Change of PCI Number:',typeof result); //Object
             	var fieldMap = [];
             	var suppCard = [];
                 
             ////////////////////////////////////// Start : Checking the Response from the Server ////////////////////////////////////////////////
             	if(!$A.util.isEmpty(result)){
                 	for(var key in result){
                		//"cardId":will contain the id of the card & "cardObj": will contain the cardObj data
                		fieldMap.push({cardId: key, cardObj: result[key] });
                		suppCard.push({label: result[key].id+' - '+result[key].embossName, value: result[key].id+' - '+result[key].embossName});
               		}
            	console.log('Supp Array Related to PCI Number:',fieldMap);
             	console.log('Supp Card Lists:',suppCard);   
             	}
             	else{
                  	console.log('No Supplementary Cards found 1');
                  	component.set('v.isHavingSuppCards',false);
             	}
            ////////////////////////////////////// END : Checking the Response from the Server ////////////////////////////////////////////////
 
             	if(suppCard.length > 0){
                	component.set('v.isHavingSuppCards',true);
                	component.set('v.suppCardList',suppCard);
             	}
             
        	});
        //Call Credit Card Detail API to fetch Current Credit Limit
        component.find('apexService').request(component.get('c.loadCardDetails'), {
             accID : component.get("v.recordId"),
             caseModel : component.get("v.caseModel"),
             requestedPCINumber :  requestedPCINumber
        },
        function(response) {
            var result = response.getReturnValue();
            var data = [];
            console.log('Credit Card Details',result);
            console.log('Result Type:', typeof result);
            console.log('Credit Limit:',result.creditLimit);
            component.set('v.currentCreditLimit',result.creditLimit);
            component.set('v.pciNumber',result.pciNumber);
            component.set('v.currentCardMinOutStandingBalance',result.usedCreditLimit);
        });
	},
    handlesuppCardChange: function (component, event, helper) {
        console.log('*****************Handle Supp Card Change***********');
        //Get the Selected values   
        var selectedValues = event.getParam("value");
        console.log('Selected Value:',selectedValues);
        component.set("v.selectedsuppCardList", selectedValues);
        
        //Getting all the Supp Cards List related to the PCI Number
        var myValues= component.get("v.suppCardList");
        console.log('Getting the values:',myValues);
        var selSuppLst = [];
        //var unselSuppLst = [];
        
        ///////////////////////////////// Start : Logic to push selected supplementary cards into corresponding array ///////////////////////////////////
        for(var i = 0; i < selectedValues.length; i++){
           console.log('selectedValues[i]--> '+selectedValues[i]);
           myValues.map(function (element1) {
               console.log('element Labels--> '+element1.label);
               if(element1.label == selectedValues[i]){
                   selSuppLst.push(element1.label);
               }
          })
		} //for loop End
        console.log('Selected Supp Cards:',selSuppLst);
        //////////////////////////////////// END : Logic to push selected supplementary cards into corresponding array /////////////////////////////////
        
        ///////////////////////////////// Start : Logic to push un-selected supplementary cards into corresponding array ///////////////////////////////////
       
		var unselSuppLst = myValues.filter(function (element1){
            return selSuppLst.indexOf(element1.label) === -1;
        }).map(function(element1){
            return element1.label;
        });
        console.log('Un-Selected Supp Card',unselSuppLst);
        ///////////////////////////////// END : Logic to push un-selected supplementary cards into corresponding array ///////////////////////////////////

        
        ///////////////////////////////////// Start : Logic to display Selected Supplementary cards separated by comma ////////////////////////////////
        if(selSuppLst.length > 0){
            var strSuppList = '';
            for(var i = 0; i < selSuppLst.length; i++){
                if(i == 0){
                    strSuppList = selSuppLst[i] +'';
                }else{
                    strSuppList += ';'+selSuppLst[i];
                }
            }
            console.log('Selected Supp Cards comma separated:',strSuppList);
            component.set('v.suppPCINames', strSuppList)
        }else{
            component.set('v.suppPCINames',null)
        }
      ///////////////////////////////////// Start : Logic to display Selected Supplementary cards separated by comma //////////////////////////////////
 
     ///////////////////////////////////// Start : Logic to display Un-Selected Supplementary cards separated by comma ////////////////////////////////
     	if(unselSuppLst.length > 0){
            var strUnSelSuppList = '';
            for(var i = 0; i < unselSuppLst.length; i++){
                if(i == 0){
                    strUnSelSuppList = unselSuppLst[i] +'';
                }else{
                    strUnSelSuppList += ';'+unselSuppLst[i];
                }
            }
            console.log('Un-Selected Supp Cards comma separated:',strUnSelSuppList);
            component.set('v.unselsuppPCINames', strUnSelSuppList)
        }else{
            component.set('v.unselsuppPCINames',null)
        }
     ///////////////////////////////////// END : Logic to display Un-Selected Supplementary cards separated by comma ////////////////////////////////

    },
    handleCobrandChange: function (component, event, helper) {
        const isChecked = event.getSource().get("v.value");
        console.log('Has Cobrand Chcked:',isChecked);
        component.set("v.hasCoBrandMembership", isChecked);
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
     
    handlesubTypeChange: function (component, event, helper) {
        // Get the value of the Sub Type field
        var inputValue = event.getSource().get("v.value");
        component.set("v.cc_subType", inputValue);
        console.log('Sub Type Value:',inputValue);
        let selectedCardType = component.get("v.selectedCard");
        console.log('Selected Card is:',selectedCardType);
        if(selectedCardType != null || selectedCardType != ''){
            component.set("v.selectedCard",'');
        }
        let subType = component.get("v.cc_subType");
            console.log('Sub Type Value:',subType);
            component.find('apexService').request(component.get('c.getCreditCardUpgradeOptions'), {
                accID : component.get("v.recordId"),
                caseModel : component.get("v.caseModel"),
                subType : component.get("v.cc_subType")
            },
            function(response) {
            	var result = response.getReturnValue();
            	console.log('Result Value On Load:',result);   
                var fieldMap = [];
                for(var key in result){
                	fieldMap.push({key: key, value: result[key] });
                }
                console.log('Array On Load Upgrade Options:',fieldMap);
                component.set("v.cardUpgradeOptions",fieldMap);
           });
            
    },
    upgradeCardTypeChange: function (component, event, helper){
        var cardTypeChange = event.getSource().get("v.value");
        console.log('Card Type Change to:',cardTypeChange);
        let subType = component.get("v.cc_subType");
        if(subType === 'Credit Card Limit Split' && cardTypeChange != null && cardTypeChange != ''){
            var myValues= component.get("v.cardUpgradeOptions");
            console.log('Upgrade Options:',myValues);
            myValues.findIndex(item => {
                if(item.value.productMappingCode === cardTypeChange){
                	console.log('Product Mapping Code Matched');
                    var isCashCollateral = component.get("v.isCashCollateral");
                	if(isCashCollateral == false){
                		let configData = item.value.cardConfigurations;
                    	let newCardMinCreditLimitUnSecured = configData.find((config) => config.configCode === 'MINIMUM_CREDIT_LIMIT_UNSECURED');
                    	component.set('v.newCardMinCreditLimit',newCardMinCreditLimitUnSecured.configValue);
            		}
                    else if(isCashCollateral == true){
                		let configData = item.value.cardConfigurations;
                    	let newCardMinCreditLimitSecured = configData.find((config) => config.configCode === 'MINIMUM_CREDIT_LIMIT_SECURED');
                    	component.set('v.newCardMinCreditLimit',newCardMinCreditLimitSecured.configValue);
            		}
                    
                	let configId = (item.value.cardProductConfigurationId).toString();
                    console.log('Config Id:',configId);
                	if(configId != null || configId != ''){
                      	component.set('v.newCardConfigurationId',configId);
            		}
                    else{
                         component.set('v.newCardConfigurationId','');      
                    }
                	
				}
            });
            
            component.find('apexService').request(component.get('c.getDefaultName'), {
                accID : component.get("v.recordId")
            },
            function(response) {
            	var result = response.getReturnValue();
                component.find("newCardCustName").set("v.value",result);
            });
        }
    }
})
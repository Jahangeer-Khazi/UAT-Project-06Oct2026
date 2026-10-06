/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date: 07-09-2022
 * 		Change History: 
 *          CH01 : Aniss Mbarki 28/09/2024 -- Fixed deposit requirment
 *		    CH02 : #Jahangeer Mohammed# #02-10-2024# Added Existing IBAN Logic & Requested Credit Limit Validation for Cash Collateral Limit Increase Application(NBA-12324)
 *   		CH03 : #Jahangeer Mohammed# #27-07-2026 Added Logic for automated Credit Card Upgrade Cases(NBA-17560)
 * 			#CH04# #Jahangeer Mohammed# #08-09-2026 Added Logic for Reapply Restriction Period (NBA-16360)

 */
({
	handleOnload : function(component, event, helper) {
        if(component.get("v.isInit") == false){
            component.set("v.isInit",true);
            component.find('apexService').request(component.get('c.getPCIOptionsCashCollateralLimitIncrease'), {
                    accID : component.get("v.recordId")
                },
                 function(response) {
                 var result = response.getReturnValue();
                     
                  var fieldMap = [];
                    for(var key in result){
                        //"cardId":will contain the id of the card & "cardObj": will contain the cardObj data
                        fieldMap.push({cardId: key, cardObj: result[key] });//CH02
                    }
                 component.set("v.cc_cardPCINumber",fieldMap);
               });
            component.find('apexService').request(component.get('c.getDefaultName'), {
                    accID : component.get("v.recordId")
                },
                 function(response) {
                 var result = response.getReturnValue();
                 component.find("namOnCard").set("v.value",result);
               });
            //CH02:Start
            component.find('apexService').request(component.get('c.getRegionName'), {
                    accID : component.get("v.recordId")
                },
                 function(response) {
                 var result = response.getReturnValue();
                 component.set('v.regionName',result);
               });
            //CH02: END
        }
	},
    handleOnSubmit: function(component, event, helper) {
        event.preventDefault();
        let holdAccType = component.get("v.holdAccType");
        let accIbans = component.get("v.accIbans");
        //CH02: Start
        let reqLimit = component.get("v.reqCreditLimit");
        let availableSumofFDs = component.get("v.sumOfFixedDeposits");
        let existingHoldLimit = component.get("v.existingHoldAmount");
        let region = component.get("v.regionName");
        
        console.log('Requested Limit:',reqLimit);
        console.log('Existing Hold Limit:',existingHoldLimit);
        console.log('Available Sum of FD:',availableSumofFDs);
        console.log('Region Flag:',region);
        
        let existingCreditLimit;
        if(region == 'Bahrain'){
             existingCreditLimit = parseInt(existingHoldLimit) / 1.2;
             console.log('Existing Credit Limit BH:',Math.round(existingCreditLimit));
        }
        else if(region == 'Jordan'){
            existingCreditLimit = parseInt(existingHoldLimit) / 1.1;
            console.log('Existing Credit Limit JO:',Math.round(existingCreditLimit));
        }
        
        let requireHoldLimit;
        var thresholdLmt = $A.get("$Label.c.THRESHOLD_LMT"); //THRESHOLD_LMT = 6000
        var limit = parseInt(thresholdLmt);
        if(region == 'Bahrain'){
            if(reqLimit <= limit){
            	requireHoldLimit = (reqLimit * 1.2);
        	}
        	else if(reqLimit > limit){
            	requireHoldLimit = (reqLimit * 1.11);
        	}
        }
        else if(region == 'Jordan'){
            requireHoldLimit = (reqLimit * 1.1);
        }
        console.log('Require Hold Limit FDD:',requireHoldLimit);
        //CH02: END
        if (holdAccType == 'FIXED_DEPOSIT' && (accIbans == '' || accIbans == null ) && region == 'Jordan' ) {
            console.error("please fill the Hold Account Type");
            helper.handleErrors("please fill the Hold Account Type");
            // Set error//focuss the error
        } 
        //CH02: Start
        else if(holdAccType == 'FIXED_DEPOSIT' && reqLimit <= existingCreditLimit){
             console.error("The requested limit must be greater than existing credit limit");
             helper.handleErrors("The requested limit must be greater than existing credit limit");
		}
        else if(holdAccType == 'FIXED_DEPOSIT' && reqLimit > existingCreditLimit && requireHoldLimit > availableSumofFDs && region == 'Jordan'){
            console.error("The requested limit plus hold amount must be less than or equal to the sum of the selected fixed deposits");
            helper.handleErrors("The requested limit plus hold amount must be less than or equal to the sum of the selected fixed deposits");
        }
        else if(holdAccType == 'FIXED_DEPOSIT' && region == 'Bahrain'){
            helper.handleErrors($A.get("$Label.c.FIXED_DEPOSIT_BH_ERROR_MSG"));    
        }
        //CH02: END
        //CH03: Start
        else if(component.get("v.isInitiateUpgradeCard") == true && component.get("v.requestedCardType") == component.get("v.upgradeCardType")){
              helper.handleErrors("Current Card type cannot be the same as the requested upgraded card");
 		}
        else if(component.get("v.isInitiateUpgradeCard") == true && component.get("v.requestedCardType") != component.get("v.upgradeCardType")){
            var requestedLimit = parseInt(component.get("v.requestedCardLimit"));
            var upgMinLimit = parseInt(component.get("v.newCardMinCreditLimit"));
            console.log('Req Limit:',requestedLimit);
            console.log('Upgrade Limit:',upgMinLimit);
            if(requestedLimit < upgMinLimit){
               helper.handleErrors("Requested Limit must be greater than or equal to the minimum limit of the target credit card"); 
            }
            else{
                console.log('Is Upgraded Limit Increase Submission');
                //CH04: Start
                if(component.get("v.restrictionAppliedOnCard") == true){
                    helper.handleErrors("A temporary restriction is currently applied to your account. You can apply for a secure card limit increase after the restriction period ends.");
                }else{
                    component.find('form').submit();
                    helper.showSpinner(component);
                }
                //component.find('form').submit();
           		//helper.showSpinner(component); 
                //CH04: END
            }
            
        }
        //CH03: END
        else {
            console.log('submit the form');
            //CH04: Start
                if(component.get("v.restrictionAppliedOnCard") == true){
                    helper.handleErrors("A temporary restriction is currently applied to your account. You can apply for a secure card limit increase after the restriction period ends.");
                }else{
                    component.find('form').submit();
                    helper.showSpinner(component);
                }
            //component.find('form').submit();
            //helper.showSpinner(component);
            //CH04: END
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
    requestPCINumberChange: function (component, event, helper) {
		let requestedPCINumber = component.find("requestedPCINumber").get("v.value");
		if(requestedPCINumber != null && requestedPCINumber != ''){
            console.log('Requested PCI Number:'+requestedPCINumber);
            var myValues= component.get("v.cc_cardPCINumber");
            console.log("My Values",JSON.stringify(myValues));
            myValues.findIndex(item => {
                //console.log('Item Card Id:'+item.cardId);
                if(item.cardId == requestedPCINumber){
                	console.log('Item Card Id:'+item.cardId);
                	console.log('Item Card cardProductionConfigurationId:'+item.cardObj.cardProductionConfigurationId);
                	console.log('Requested PCI Number:'+requestedPCINumber);

                    if(item.cardObj.productMappingCode != '')
                    	component.set( 'v.requestedCardType' , item.cardObj.productMappingCode );
                    else
                		component.set('v.requestedCardType',null);
                	console.log('IBAN Account:'+item.cardObj.holdAccount);
                	
                	if(item.cardObj.holdAccount != '' && item.cardObj.holdAccount != null)
                    	component.set('v.holdAccount', item.cardObj.holdAccount);
                	else
                		component.set('v.holdAccount', null);
                	//CH02: Start
                    if(item.cardObj.holdAccount != '' && item.cardObj.holdAccount != null)
                    	component.set('v.existingAccount', item.cardObj.holdAccount);
                	else
                		component.set('v.existingAccount', null);
                    
                	//CH02: END
                	if(item.cardObj.holdAmount != '' && item.cardObj.holdAmount != null)
                    	component.set('v.existingHoldAmount', item.cardObj.holdAmount);
                	else
                		component.set('v.existingHoldAmount', null);
                	
                	if(item.cardObj.holdReference != '' && item.cardObj.holdReference != null)
                    	component.set('v.holdReferenceNumber', item.cardObj.holdReference);
                	else
                		component.set('v.holdReferenceNumber', null);
                
                	if(item.cardObj.cardProductionConfigurationId != '' && item.cardObj.cardProductionConfigurationId != null)
                    	component.set('v.cardProductionConfigurationId',JSON.stringify(item.cardObj.cardProductionConfigurationId));
                	else
                		component.set('v.cardProductionConfigurationId', null);

                }
                               
            });

		}else{
			component.set("v.requestedCardType",null);
            component.set('v.holdAccount', null);
            component.set('v.existingHoldAmount', null);
            component.set('v.holdReferenceNumber', null);
		}
         //CH03: Start
        component.find('apexService').request(component.get('c.loadCardDetailsToFetchLimit'), {
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
            
        });
        var checkIsInitiateUpgradeCard = component.get("v.isInitiateUpgradeCard");
        console.log('Check Is Initiate from Upgarde Card:',checkIsInitiateUpgradeCard);
        if(checkIsInitiateUpgradeCard == true){
            component.set("v.isInitiateUpgradeCard",false);
        }
        //CH03: END
	},
    //CH01 : Start
    holdAccTypeIsChanged: function (component, event, helper){
        console.log('holdAccTypeIsChanged=================+>>>>>');
        let holdAccType = component.get("v.holdAccType");
        let regionName = component.get("v.regionName");
        if(holdAccType == 'FIXED_DEPOSIT' && regionName == 'Jordan'){
            console.log('holdAccTypeIsChanged--->');
            component.find('apexService').request(component.get('c.termDepositListForLimitIncrease'), {
                accID : component.get("v.recordId"),
                caseModel : component.get("v.caseModel")
            },
             function(response) {
                var result = response.getReturnValue();
                if (result) {
                    console.log('result--->' + JSON.stringify(result));
                    component.set("v.holdAccTypesList", result);
                    var plValues = [];
                    
                    //CH02: Start
                    var existingFDValues = [];
                    var existingFDID = component.get("v.existingAccount");
                    console.log('Existing Contract ID:',existingFDID);
                    //CH02: END
                    for (var i = 0; i < result.length; i++) {
                        plValues.push({
                            	label: result[i].name+' - '+result[i].urbisContractId,
                            	value: result[i].urbisContractId
                        	});
                    }
                    //CH02: Start
                    console.log('Available FD:',plValues);
                    if(existingFDID != null && !existingFDID.startsWith('BH')){
                        // Split the string into an array of values
						let valuesToFindFDs = existingFDID.split(";");
                        console.log('FD Split:',valuesToFindFDs);
                        
                        // Find the object with the desired Fixed Deposit ID
                        //let deposit = plValues.find(deposit => deposit.value === existingFDID);
                        let existingdeposit = plValues.filter(deposit => valuesToFindFDs.includes(deposit.value))
                        					  		  .map(deposit => deposit.value);
                        
                        console.log('Existing FDS:',existingdeposit);
                        component.set("v.HoldAccountTypeList", plValues);
                        component.set("v.selectedHoldAccountTypeList",existingdeposit);
                        component.set('v.accIbans', existingFDID);
                        
                        //toDo : to populate this list with data  on doInit and Calculate the sum of deposits
        				var myValues= component.get("v.holdAccTypesList");
        				var accLst = [];
        				for (var i = 0; i < existingdeposit.length; i++) {
            				console.log('*********************existingdeposit[i]--> '+existingdeposit[i]);
            				myValues.map(function (element1) {
                				console.log('*********************Contract ID --> '+element1.urbisContractId);
                				if(element1.urbisContractId == existingdeposit[i]){
                    				console.log('*********************'+element1);
                    				accLst.push(element1);
                				}
            				})
        				} //for Loop Ends
                        console.log('Selected Account List Default:',accLst);
                        if(accLst.length>0){
                           var strDepositAmount = '';
                           for(var i = 0; i < accLst.length; i++){
                                if(i==0){
                                   strDepositAmount = accLst[i].depositAmount+'';
                                }else{
                                    strDepositAmount += ';'+accLst[i].depositAmount;
                                }
                            }
                            console.log('Deposit Amount Default:',strDepositAmount);
                            let sum = strDepositAmount.split(";").map(Number).reduce((total, num) => total + num, 0); // Sum the numbers
                            console.log("The sum in default: " + sum);
                            component.set('v.sumOfFixedDeposits',sum);
                        }else{
                            component.set('v.sumOfFixedDeposits',null);
                        }
                        
                    } //Main If Ends
                    else{
                        console.log('No Existing FD Found');
                        component.set("v.HoldAccountTypeList", plValues);
                        compoenent.set("v.accIbans",null);
                    }
                    //CH02: END
                }
            });
        }
        else if(holdAccType == 'FIXED_DEPOSIT' && regionName == 'Bahrain'){
            helper.handleErrors($A.get("$Label.c.FIXED_DEPOSIT_BH_ERROR_MSG"));
        }
        //CH02: Start
        else {
            component.set("v.selectedHoldAccountTypeList",[]);
            component.set("v.HoldAccountTypeList", []);

        }
        //CH02: END
    },
    handleHoldAccountTypeChange: function (component, event, helper) {
        console.log('*****************handleHoldAccountTypeChange***********');
        //Get the Selected values   
        var selectedValues = event.getParam("value");

        //Update the Selected Values  
        component.set("v.selectedHoldAccountTypeList", selectedValues);

        //toDo : to populate this list with data  on doInit...
        var myValues= component.get("v.holdAccTypesList");
        var accLst = [];
        for (var i = 0; i < selectedValues.length; i++) {
            console.log('*********************selectedValues[i]--> '+selectedValues[i]);
            myValues.map(function (element1) {
                console.log('*********************element--> '+element1.urbisContractId);
                if(element1.urbisContractId == selectedValues[i]){
                    console.log('*********************'+element1);
                    accLst.push(element1);
                }
            })
        }
        //CH02: Start
        console.log('Selected Account List:',accLst);
        //CH02: END
        if(accLst.length>0){
            var strIban = '';
            //CH02: Start
            var strDepositAmount = '';
            //CH02: END
            for(var i = 0; i < accLst.length; i++){
                if(i==0){
                    strIban = accLst[i].urbisContractId+'';
                    //CH02: Start
                    strDepositAmount = accLst[i].depositAmount+'';
                    //CH02: END
                }else{
                    strIban += ';'+accLst[i].urbisContractId;
                    //CH02: Start
                    strDepositAmount += ';'+accLst[i].depositAmount;
                    //CH02: END
                }
            }
            component.set('v.accIbans', strIban)
            //CH02: Start
            console.log('Deposit Amount:',strDepositAmount);
            let sum = strDepositAmount.split(";").map(Number).reduce((total, num) => total + num, 0); // Sum the numbers
			console.log("The sum is: " + sum);
            component.set('v.sumOfFixedDeposits',sum);
            //CH02: END
        }else{
            component.set('v.accIbans',null);
            //CH02: Start
            component.set('v.sumOfFixedDeposits',null);
            //CH02: END
        }
        
        
    },
    caseModelIsChanged : function(component, event, helper) {
        console.log('is changed caseModelIsChanged');
        //toContinue : ...
    },
    handleLoad: function (component, event, helper) {//CH01
        console.log('handleLoad=================+>>>>>');
		console.log('handleLoad  cmp---'+component.find("Subscription_Model").get("v.value"));
        let subscriptionModel = component.find("Subscription_Model").get("v.value");
        if( subscriptionModel != null && subscriptionModel == 'alburaq' ){
            component.set('v.caseModel',subscriptionModel);
        }else{
            component.set('v.caseModel','ila');
        }
        //CH04: Start
        let restrictionApply = component.find("restrictionApplied").get("v.value");
		console.log('Restriction Applied on Customer:',restrictionApply);
		component.set('v.restrictionAppliedOnCard',restrictionApply);
        //CH04: END
	},
    //CH01 : End
     //CH03: Start
    handleRequestedLimit: function (component, event, helper) {
        let requestedLimit = component.find("requestedCardLimit").get("v.value");
        console.log('Requested Credit Limit:',requestedLimit);
        component.set("v.requestedCardLimit",requestedLimit);
    },
    handleUpgradeCards: function (component, event, helper) {
        //let requestedPCI = component.find("requestedPCINumber").get("v.value");
        var requestedPCI = component.get("v.selectedPCINumber");
        console.log('Requested PCI Number on is Upgrade Card:',requestedPCI);
        const isInitiateUpgradeChecked = event.getSource().get("v.value");
        console.log('Is Initiate from Upgrade Card Chcked:',isInitiateUpgradeChecked);
        component.set("v.isInitiateUpgradeCard", isInitiateUpgradeChecked);
        if(isInitiateUpgradeChecked == true){
        component.find('apexService').request(component.get('c.getCreditCardUpgradeOptions'), {
                accID : component.get("v.recordId"),
                caseModel : component.get("v.caseModel")
                
            },
            function(response){
                var result = response.getReturnValue();
            	console.log('Result Value On Load:',result);   
                var cardUpgradeOptions = [];
                for(var key in result){
                //"cardId":will contain the id of the card & "cardObj": will contain the cardObj data
                	cardUpgradeOptions.push({key: key, value: result[key] });
                }
                console.log('Array On Load Upgrade Options:',cardUpgradeOptions);
                component.set("v.cardUpgradeOptions",cardUpgradeOptions);
                
           });
        
         //Call Again Credit Card List API to fetch only Supplementary Cards related to specific PCI Number
        component.find('apexService').request(component.get('c.getPCIOptionsSuppCards'), {
                accID : component.get("v.recordId"),
            	caseModel : component.get("v.caseModel"),
                requestedPCINumber :  requestedPCI
            },
             function(response) {
             	var result = response.getReturnValue();
             	console.log('Requested PCI Number on is Upgrade Card on Supp Card:',requestedPCI);
             	var suppfieldMap = [];
             	var suppCard = [];
                 
             ////////////////////////////////////// Start : Checking the Response from the Server ////////////////////////////////////////////////
             	if(!$A.util.isEmpty(result)){
                 	for(var key in result){
                		//"cardId":will contain the id of the card & "cardObj": will contain the cardObj data
                		suppfieldMap.push({cardId: key, cardObj: result[key] });
                		suppCard.push({label: result[key].id+' - '+result[key].embossName, value: result[key].id+' - '+result[key].embossName});
               		}
            	console.log('Supp Array Related to PCI Number:',suppfieldMap);
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
                    //component.set('v.selectedsuppCardList',suppCard);
                     //Select all supplementary cards by default
    				var defaultSelected = [];

    				suppCard.forEach(function(card) {
        						defaultSelected.push(card.value);
    				});

    				component.set("v.selectedsuppCardList", defaultSelected);
                    // Populate the fields
    				component.set("v.suppPCINames", defaultSelected.join(";"));
    				component.set("v.unselsuppPCINames", "");
             	}
             
        	});
        }else if(isInitiateUpgradeChecked == false){
            component.set("v.newCardMinCreditLimit", "");
        }
    },
    requestUpgradeCardChange: function (component, event, helper){
         let requestedUpgradedCard = component.find("upgradeCardTo").get("v.value");
         console.log('Upgrade Card Is:',requestedUpgradedCard);
         component.set("v.upgradeCardType", requestedUpgradedCard);
        if(requestedUpgradedCard != null || requestedUpgradedCard != ''){
            component.find('apexService').request(component.get('c.getCreditCardProductMappingCode'), {
                accID : component.get("v.recordId"),
                caseModel : component.get("v.caseModel")
                
            },
            function(response){
                var result = response.getReturnValue();
            	console.log('Result Value On Changing Card Type:',result);   
                var fieldMapInfo = [];
                for(var key in result){
                //"cardId":will contain the id of the card & "cardObj": will contain the cardObj data
                	fieldMapInfo.push({key: key, value: result[key] });
                }
                console.log('Array On Load Upgrade Options:',fieldMapInfo);
                component.set("v.cardOptions",fieldMapInfo);
                
                var myValues= component.get("v.cardOptions");
                myValues.findIndex(item => {
                if(item.value.productMappingCode === requestedUpgradedCard){
                	console.log('Product Mapping Code Matched');
                	let configData = item.value.cardConfigurations;
                    let newCardMinCreditLimitUnSecured = configData.find((config) => config.configCode === 'MINIMUM_CREDIT_LIMIT_SECURED');
                    component.set('v.newCardMinCreditLimit',newCardMinCreditLimitUnSecured.configValue);
                    
                }
            	});
                
           });
        }
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
    //CH03: END
    
    
})
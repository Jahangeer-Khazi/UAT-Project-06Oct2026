/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date: 07-11-2021
 * 		Change History: 
 * 			#CH01 : #D&A Team #24-06-2022# Added Case model parameter to add alburaq logic.
 * 			#CH02 : Aniss Mbarki 11/08/2022 Add requestedCardType Logic
 * 			#CH03# #Jahangeer Mohammed# #18-08-2025 Added Masked Card Number(NBA-15639)
 * 			#CH04# #Jahangeer Mohammed# #23-07-2026 Added Logic for automated Credit Card Upgrade Cases(NBA-17560)
 * 			#CH05# #Jahangeer Mohammed# #08-09-2026 Added Logic for Reapply Restriction Period (NBA-16360)

 *			  
 */
({
	handleOnload : function(component, event, helper) {
        console.log('Handle On Load Method');
        //CH04: Start
        if(component.get("v.isInit") == false){
        component.set("v.isInit",true);
		component.find('apexService').request(component.get('c.getPCIOptionsV2'), {//CH02 : use new function instead of c.getPCIOptions
                accID : component.get("v.recordId"),
            	caseModel : component.get("v.caseModel")//CH01
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
        }
        //CH04: END
	},
    //CH04: Start
    handleOnSubmit: function(component, event, helper) {
        event.preventDefault();
        if(component.get("v.isInitiateUpgradeCard") == false){
            console.log('Normal Limit Increase Submission')
            //CH05: Start
            if(component.get("v.restrictionAppliedOnCard") == true){
               helper.handleErrors("A temporary restriction is currently applied to your account. You can apply for a credit limit increase after the restriction period ends.");
        	}else{
               component.find('form').submit();
           	   helper.showSpinner(component); 
            }
            //CH05: END
          
        }
        else if(component.get("v.isInitiateUpgradeCard") == true && component.get("v.requestedCardType") == component.get("v.upgradeCardType")){
              helper.handleErrors("Current Card type cannot be the same as the requested upgraded card");
 		}
        else if(component.get("v.isInitiateUpgradeCard") == true && component.get("v.requestedCardType") != component.get("v.upgradeCardType")){
            var reqLimit = parseInt(component.get("v.requestedCardLimit"));
            var upgMinLimit = parseInt(component.get("v.newCardMinCreditLimit"));
            console.log('Req Limit:',reqLimit);
            console.log('Upgrade Limit:',upgMinLimit);
            if(reqLimit < upgMinLimit){
               helper.handleErrors("Requested Limit must be greater than or equal to the minimum limit of the target credit card"); 
            }
            else{
                console.log('Is Upgraded Limit Increase Submission');
                //CH05: Start
                if(component.get("v.restrictionAppliedOnCard") == true){
               		helper.handleErrors("A temporary restriction is currently applied to your account. You can apply for a credit limit increase after the restriction period ends.");
            	}else{
                	component.find('form').submit();
           			helper.showSpinner(component);
            	}
                //CH05: END
           }
            
        }
        
    },
    //CH04: END
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
        component.find('requestedPCINumber').set('v.value','');	
        component.find('apexService').request(component.get('c.getPCIOptionsV2'), {	
            accID : component.get("v.recordId"),	
            caseModel : component.get("v.caseModel")	
        },	
         function(response) {	
         var result = response.getReturnValue();	
             	
          var fieldMap = [];	
            for(var key in result){	
                fieldMap.push({key: key, value: result[key]});	
            }	
         component.set("v.cc_cardPCINumber",fieldMap);	
       });	
			
    },	
    handleLoad: function (component, event, helper) {//CH01	
		console.log('handleLoad  cmp---'+component.find("Subscription_Model").get("v.value"));	
        let subscriptionModel = component.find("Subscription_Model").get("v.value");	
        if( subscriptionModel != null && subscriptionModel == 'alburaq' ){	
            component.set('v.caseModel',subscriptionModel);	
        }else{	
            component.set('v.caseModel','ila');	
        }
        //CH05: Start
        let restrictionApply = component.find("restrictionApplied").get("v.value");
        console.log('Restriction Applied on Customer:',restrictionApply);
        component.set('v.restrictionAppliedOnCard',restrictionApply);
        //CH05: END
    },	
    requestPCINumberChange: function (component, event, helper) {//CH02	
		let requestedPCINumber = component.find("requestedPCINumber").get("v.value");	
		if(requestedPCINumber != null && requestedPCINumber != ''){	
            var myValues= component.get("v.cc_cardPCINumber");
            console.log("My Values",JSON.stringify(myValues));
            myValues.findIndex(item => {	
                if(item.cardId == requestedPCINumber){
                //CH03: Start
                    //component.set( 'v.requestedCardType' , item.cardObj.productMappingCode );	
                    if(item.cardObj.productMappingCode != '')
                    	component.set( 'v.requestedCardType' , item.cardObj.productMappingCode );
                    else
                		component.set('v.requestedCardType',null);
                
                	if(item.cardObj.maskedCardNumber != '' && item.cardObj.maskedCardNumber != null)
						component.set('v.maskedCardNumber', item.cardObj.maskedCardNumber);
                    else
                		component.set('v.maskedCardNumber', null);
                //CH03: END
                }	
            });	
		}else{	
			component.set("v.requestedCardType",null);	
		}	
        //CH04: Start
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
        //CH04: END
	},
    //CH04: Start
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
            component.set('v.newCardMinCreditLimit',"");
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
                    let newCardMinCreditLimitUnSecured = configData.find((config) => config.configCode === 'MINIMUM_CREDIT_LIMIT_UNSECURED');
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
    //CH04: END
})
/**
Change History :
*         #CH01 : #D&A Team #24-06-2022# Added Case model parameter to add alburaq logic.
*		  #CH02 : #Jahangeer Mohammed# #21-10-2024# Added Requested Credit Limit Validation for Cash Collateral Limit Increase Application(NBA-12324)
 		  #CH03 :  #Jahangeer Mohammed# #16-12-2024# Added Logic for Co-brand Credit Cards(NBA-12524)
 		  #CH04 :  #Jahangeer Mohammed# #26-04-2026# Added Logic for Cash Collateral Using FD for Bahrain(NBA-16935)
          #CH05# #Jahangeer Mohammed# #08-09-2026 Added Logic for Reapply Restriction Period (NBA-16360)
 */
({
	handleOnload : function(component, event, helper) {
        if(component.get("v.isInit") == false){
            component.set("v.isInit",true);
            console.log('handleOnload=================+>>>>>');
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
                 component.set("v.cc_cardType",fieldMap);
               });
            component.find('apexService').request(component.get('c.getDefaultName'), {
                    accID : component.get("v.recordId")
                },
                 function(response) {
                 var result = response.getReturnValue();
                 component.find("namOnCard").set("v.value",result);
               });
            //CH02: Start
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
        console.log('handleOnSubmit=================+>>>>>');

        event.preventDefault();
        if(component.get("v.selectCard") != 'ILA_GULF_AIR_COBRAND_01'){
            let holdAccType = component.get("v.holdAccType");
            let accIbans = component.get("v.accIbans");
            //CH02: Start
            let reqLimit = component.get("v.reqCreditLimit");
            let availableSumofFDs = component.get("v.sumOfFixedDeposits");
            let region = component.get("v.regionName");
            
            console.log('Requested Limit:',reqLimit);
            console.log('Available Sum of FD:',availableSumofFDs);
            console.log('Region Flag:',region);
            
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
            //CH04: Commented the condition region == 'Jordan'
            if (holdAccType == 'FIXED_DEPOSIT' && (accIbans == '' || accIbans == null ) /*&& region == 'Jordan'*/ ) {
                console.error("please fill the Hold Account Type");
                helper.handleErrors("please fill the Hold Account Type");
                // Set error//focuss the error
            } 
            //CH02: Start
            //CH04: Commented the condition region == 'Jordan'
            else if(holdAccType == 'FIXED_DEPOSIT' && requireHoldLimit > availableSumofFDs /*&& region == 'Jordan'*/){
                console.error("The requested limit plus hold amount must be less than or equal to the sum of the selected fixed deposits");
                helper.handleErrors("The requested limit plus hold amount must be less than or equal to the sum of the selected fixed deposits");
            }
            //CH04: Commented the else if block
            /*else if(holdAccType == 'FIXED_DEPOSIT' && region == 'Bahrain'){
                helper.handleErrors("Fixed Deposits are not applicable for Bahrain Customers");    
            }*/
            //CH04: END
            //CH02: END
            else{
                console.log('submit the form');
                //CH05: Start
                if(component.get("v.restrictionAppliedOnCard") == true){
    				helper.handleErrors("A temporary restriction is currently applied to your account. You can apply for a secure credit card after the restriction period ends.");
				}else{
    				component.find('form').submit();
    				helper.showSpinner(component);
				}
                //component.find('form').submit();
                //helper.showSpinner(component);
                //CH05: END
           }
        }
        else if(component.get("v.selectCard") == 'ILA_GULF_AIR_COBRAND_01' && component.get("v.hasCoBrandMembership") == true){
            var checkValidateNumberButtonClicked = component.get("v.hasValidateNumberButtonClicked");
            var membershipNo = component.get("v.embossingLine4");
            console.log('Membership No:',membershipNo);
            console.log('Button Clicked:',checkValidateNumberButtonClicked);
            if(checkValidateNumberButtonClicked == false && membershipNo != ''){
                helper.handleErrors("Please Validate the Membership Number");
            }
            else{
                console.log('submit the form for Ila Gulf With Cobrand Membership');
                //CH05: Start
                if(component.get("v.restrictionAppliedOnCard") == true){
    				helper.handleErrors("A temporary restriction is currently applied to your account. You can apply for a secure credit card after the restriction period ends.");
				}else{
    				component.find('form').submit();
    				helper.showSpinner(component);
				}
                //component.find('form').submit();
                //helper.showSpinner(component);
                //CH05: END
            }
        }
        else if(component.get("v.selectCard") == 'ILA_GULF_AIR_COBRAND_01' && component.get("v.hasCoBrandMembership") == false){
             console.log('submit the form for Ila Gulf Without  Cobrand Membership');
             //CH05: Start
                if(component.get("v.restrictionAppliedOnCard") == true){
    				helper.handleErrors("A temporary restriction is currently applied to your account. You can apply for a secure credit card after the restriction period ends.");
				}else{
    				component.find('form').submit();
    				helper.showSpinner(component);
				}
             //component.find('form').submit();
             //helper.showSpinner(component);
            //CH05: END
        }
    },
    handleOnSuccess : function(component, event, helper) {
        console.log('handleOnSuccess=================+>>>>>');

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
        console.log('handleOnError=================+>>>>>');

        helper.hideSpinner(component);
	},
    onCancel : function(component, event, helper) {
        console.log('onCancel=================+>>>>>');

        $A.get("e.force:closeQuickAction").fire();
    },
    caseModelIsChanged : function(component, event, helper) {
        console.log('is changed caseModelIsChanged');
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
         component.set("v.cc_cardType",fieldMap);
        });
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
        //CH05: Start
        let restrictionApply = component.find("restrictionApplied").get("v.value");
		console.log('Restriction Applied on Customer:',restrictionApply);
		component.set('v.restrictionAppliedOnCard',restrictionApply);
        //CH05: END
	},
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
                    //component.set("v.embossingLine4","");
                }
               
            }else if(state === "ERROR") {
                helper.handleErrors(response.getError());
                helper.hideSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    //CH03: END
    holdAccTypeIsChanged: function (component, event, helper){
        console.log('holdAccTypeIsChanged=================+>>>>>');
        let holdAccType = component.get("v.holdAccType");
        let regionName = component.get("v.regionName");
        //CH04: Commented the regionName == 'Jordan'
        if(holdAccType == 'FIXED_DEPOSIT' /*&& regionName == 'Jordan'*/){
            console.log('holdAccTypeIsChanged--->');
            component.find('apexService').request(component.get('c.termDepositList'), {
                accID : component.get("v.recordId"),
                caseModel : component.get("v.caseModel")
            },
             function(response) {
                var result = response.getReturnValue();
                if(result){
                    console.log('result--->' + JSON.stringify(result));
                    component.set("v.holdAccTypesList", result);
                    var plValues = [];
                    for (var i = 0; i < result.length; i++) {
                        plValues.push({
                            label: result[i].name+' - '+result[i].urbisContractId,
                            value: result[i].urbisContractId
                        });
                    }
                    component.set("v.HoldAccountTypeList", plValues);
                }
            });
        }
        //CH04: Commented the else if block
        /*else if(holdAccType == 'FIXED_DEPOSIT' && regionName == 'Bahrain'){
           helper.handleErrors("Fixed Deposits are not applicable for Bahrain Customers");
		}*/
        //CH04: END
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
                }
                else{
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
            component.set('v.accIbans',null)
            //CH02: Start
            component.set('v.sumOfFixedDeposits',null);
            //CH02: END
        }
        
    },
    
    
})
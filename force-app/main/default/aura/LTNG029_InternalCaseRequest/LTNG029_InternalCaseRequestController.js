/**
Change History :
 *			   #CH07# #Jahangeer Mohammed #24-02-2025# Added Logic for Re-applying Control Feature(NBA-13039)
          
*/
({
    doInit: function (component, event, helper) {
        helper.doInit(component, event, helper);
        
    
    },
    handleRecord: function(component, event, helper) {
        switch(event.getParams().changeType) {
          case "ERROR":
            // handle error
            break;
          case "LOADED":
            console.log('accountRecord==>'+JSON.parse(JSON.stringify(component.get("v.accountRecord"))));
            console.log(component.get("v.accountRecord")["PersonEmail"]);
            break;
        }
      },
    handleOnload : function(component, event, helper) {

    },

    handleOnSubmit: function (component, event, helper) {
        console.log('handleOnSubmit');
        
          event.preventDefault();
            var fields = event.getParam("fields");
            //omar start loans Collection change
            if (component.get("v.type") == 'Loans - Collection Case') {
                var loanAmount = component.get("v.creditLimit");
                var loanOutstanding = component.get("v.outstanding");
                loanAmount = (loanAmount !== null && loanAmount !== '') ? Number(loanAmount) : null;
                loanOutstanding = (loanOutstanding !== null && loanOutstanding !== '') ? Number(loanOutstanding) : null;
                fields.cc_Current_Credit_Limit__c = loanAmount;
                fields.Credit_Card_Outstanding_Balance__c = loanOutstanding;
                var limitField = component.find("loanCreditLimitField");
                var outstandingField = component.find("loanOutstandingField");
                if (limitField) {
                    limitField.set("v.value", loanAmount);
                }
                if (outstandingField) {
                    outstandingField.set("v.value", loanOutstanding);
                }
            }
            //omar end loans Collection change
            var selectedValue = component.get("v.Sub_Type__c");
           console.log('Sub Type Value:',selectedValue);
            if(selectedValue != null && selectedValue != '' && selectedValue=="Apply Restriction"){
                var val = component.find("Restriction_Reason1").get("v.value");
                console.log('Restriction_Reason1 '+val)
                component.find("Restriction_Reason1").set("v.value", "");
            	component.find("BUA_Reason").set("v.value", val);
                //CH07: Start
                component.find('form').submit(fields);
                helper.showSpinner(component);
                //CH07: END
            }
        //CH07: Start
            else if(selectedValue != null && selectedValue != '' && (selectedValue == 'CC Reapplying update' || selectedValue == 'Loan/ Finance Reapplying update')){
            	var userId = $A.get("$SObjectType.CurrentUser.Id");
            	if(userId != ''){
                	var action = component.get("c.checkCreditCardUser");
                	action.setParams({userId: userId});
                	action.setCallback(this,function(response){
                	var state = response.getState();
            		console.log('State from Apex class:'+state);
            		if(state == 'SUCCESS'){
                		var result = response.getReturnValue();
                    	if(result == false){
                        	console.log('Result to Check Credit Card User:',result);
                        	helper.handleErrors('Credit Retail Team is allowed to create the case', '');
                    	}
                        else if(result == true){
                            component.find('form').submit(fields);
                			helper.showSpinner(component);
                        }
                    
            		}
        		});
        		$A.enqueueAction(action);
              }
            }else{
               component.set("v.Restriction_Reason","");
               component.find('form').submit(fields);
               helper.showSpinner(component);
            }
        //CH07: END
        	//CH07: Start
            //component.find('form').submit();
        //CH07: END
            //  if (selectedValue == "Remove Restriction") {
            //     component.set("v.Restriction_Reason","");
            //     component.find('form').submit();
            //     helper.showSpinner(component);
           //  }
        
          // component.find('Restriction_Reason_Reason').submit();
           //CH07: Start   
        
        //CH07: END
    },
    handleOnSuccess: function (component, event, helper) {
        helper.hideSpinner(component);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Success!",
            "message": "Case has been created successfully."
        });
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.getParam("response").id,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    handleOnError: function (component, event, helper) {
        helper.hideSpinner(component);
    },
    onCancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    handleLoad: function (component, event, helper) {//CH01
		console.log('handleLoad  cmp---'+component.find("Subscription_Model").get("v.value"));
        let subscriptionModel = component.find("Subscription_Model").get("v.value");
        if( subscriptionModel != null && subscriptionModel == 'alburaq' ){
            component.set('v.caseModel',subscriptionModel);
        }else{
            component.set('v.caseModel','ila');
        }

        //#CH05 : start
        let feeWaiverFlag = component.find("Fee_Waiver_Flag").get("v.value");
        if( feeWaiverFlag != null && feeWaiverFlag == true ){
            component.set('v.feeWaiverSubType','Remove Flag');
        }else{
            component.set('v.feeWaiverSubType','Apply Flag');
        }
        //#CH05 : end
	},

    requestPCINumberChange: function (component, event, helper) {//CH02	
		let typeCase = component.get("v.type");
        //omar start loans Collection change
        let requestedPCINumber = typeCase == 'Loans - Collection Case'
            ? component.find("requestedLoanNumber").get("v.value")
            : component.find("requestedPCINumber").get("v.value");
        //omar end loans Collection change
        console.log('Id masterCard==> '+requestedPCINumber);
        console.log('test==>');
		if(requestedPCINumber != null && requestedPCINumber != ''){
            //omar start loans Collection change
            if(typeCase == 'Loans - Collection Case'){
                var loanValues = component.get("v.loanIdNumber");
                var loanIndex = loanValues.findIndex(item => item.cardId == requestedPCINumber);
                var selectedLoan = loanIndex >= 0 ? loanValues[loanIndex] : null;
                if(selectedLoan && selectedLoan.cardObj){
                    component.set('v.selectedPCINumber', requestedPCINumber);
                    component.set('v.selectedCardNumber', selectedLoan.cardObj.loanAccountNumber);
                    component.set('v.creditLimit', selectedLoan.cardObj.principalLoanAmount != null ? Number(selectedLoan.cardObj.principalLoanAmount) : null);
                    component.set('v.outstanding', selectedLoan.cardObj.loanOutstandingAmount != null ? Number(selectedLoan.cardObj.loanOutstandingAmount) : null);
                }
                return;
            }
            //omar end loans Collection change
            var myValues= component.get("v.cc_cardPCINumber"); 
            var value = component.find("requestedPCINumber").get("v.value");
            var index = myValues.findIndex(item => item.cardId == requestedPCINumber);
           // alert('index'+index);
            var selectedName = index >= 0? myValues[index].cardObj.maskedCardNumber: null;
            component.set('v.selectedCardNumber',selectedName);
            console.log('#####Name : '+selectedName );
            helper.loadCardDetails(component,event,helper,requestedPCINumber);
        }

        //     var myValues= component.get("v.cc_cardPCINumber");	
        //     myValues.findIndex(item => {	
        //         if(item.cardId == requestedPCINumber){	
        //             component.set( 'v.creditLimit' , item.cardObj.productMappingCode );	
        //             component.set( 'v.creditOutstanding' , item.cardObj.productMappingCode );	
        //         }	
        //     });	
		// }else{	
		// 	component.set("v.creditLimit",null);	
        //     component.set("v.creditOutstanding",null);
		// 		}	
	},
    //omar start loans Collection change
    handleLoanAmountChange : function(component, event, helper) {
        var newValue = event.getSource().get("v.value");
        console.log('this is the new Credit Limit');
        component.set("v.creditLimit", (newValue !== null && newValue !== '') ? Number(newValue) : null);
    },
    handleLoanBalanceChange : function(component, event, helper) {
        var newValue = event.getSource().get("v.value");
        console.log('this is the selectedCardNumber');
        component.set("v.outstanding", (newValue !== null && newValue !== '') ? Number(newValue) : null);
    },
    //omar end loans Collection change
    isChangeType : function(component, event, helper) {

        let typeCase = component.get("v.type");

        if(typeCase == 'Credit Card - Collection Case'){
            try {
                var action = component.get("c.getPCIOptionsV2");
                action.setParams({ accID : component.get("v.recordId"),
                caseModel : component.get("v.caseModel") });
    
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('state '+state);
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        console.log('result '+JSON.stringify(result));
                        var fieldMap = [];
                        for(var key in result){
                            fieldMap.push({cardId: key, cardObj: result[key] });//CH02
                        }
                        component.set("v.cc_cardPCINumber",fieldMap);
                        
                    }
                    else if (state === "INCOMPLETE") {
                        // do something
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                        errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });
    
                $A.enqueueAction(action);
            
              
            } catch (error) {
                console.log('Error '+error);            
            }
        }

        //omar start loans Collection change
        if(typeCase == 'Loans - Collection Case'){
            try {
                var accountRecord = component.get("v.accountRecord");
                var customerId = accountRecord ? accountRecord.CIF__pc : null;
                var action = component.get("c.loadLoansList");
                action.setParams({
                    customerId : customerId,
                    caseModel : component.get("v.caseModel")
                });

                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('loadLoansList state '+state);
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        console.log('loadLoansList result '+JSON.stringify(result));
                        var fieldMap = [];
                        var loans = [];
                        if (result && result.isSuccess && result.responseData && !$A.util.isEmpty(result.responseData.currentLoans)) {
                            loans = result.responseData.currentLoans;
                        }
                        for (var i = 0; i < loans.length; i++) {
                            var loan = loans[i];
                            fieldMap.push({
                                cardId: loan.arrangementId,
                                cardObj: loan
                            });
                        }
                        component.set("v.loanIdNumber", fieldMap);
                    }
                    else if (state === "INCOMPLETE") {
                        // do something
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });

                $A.enqueueAction(action);
            } catch (error) {
                console.log('Error '+error);
            }
        }
        //omar end loans Collection change

    },
    deviceNameChange: function (component, event, helper) {//#CH06
        let deviceId = component.find("deviceId").get("v.value");             
        console.log('Id deviceId==> '+deviceId);

        if(deviceId != null && deviceId != ''){       
            var myValues= component.get("v.devicesValues");
            var index = myValues.findIndex(item => item.deviceId == deviceId);
            var selecteDeviceName = index >= 0? myValues[index].label: null;
            console.log('#####Name : '+deviceId );
            component.set('v.selectedDeviceId',deviceId);
            component.set('v.selectedDeviceValue',selecteDeviceName);
        }
    },
    isChangeSubType : function(component, event, helper) {//#CH06
        let subtypeCase = component.get("v.Sub_Type__c");
        component.set("v.devicesValues",[]);
        if(subtypeCase == 'Revoke Device FCR' || subtypeCase == 'Device Dispute'){
            helper.loadDeviceList(component, event, helper);
        }
    },
    handleLoanAmountChange : function(component, event, helper) {
    var newValue = event.getSource().get("v.value");
    console.log('this is the new Credit Limit');
    component.set("v.creditLimit", newValue);

    },

    
    handleLoanBalanceChange : function(component, event, helper) {
    var newValue = event.getSource().get("v.value");
    console.log('this is the selectedCardNumber');
    component.set("v.outstanding", newValue);
    }
})
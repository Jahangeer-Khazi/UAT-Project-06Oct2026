/* 		
 * 		Change History:
 *			  
 			   #CH01# #Jahangeer Mohammed# #19-08-2025# Added Masked Card Number(NBA-15639)
               #CH02# #Jahangeer Mohammed #11-11-2025# Added Logic for World Elite Entitlement Process (NBA-15929)

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
    setFieldVisibility : function (component, subType, reqType) {
        
        if(subType =='Direct Debit Settings'){
            component.set("v.isDirectDebit",true);
        }
        if((subType =='Card Control Settings')||(subType =='Card Control - CC' && (reqType=='Spending Control' || reqType=='Allowed Countries' || reqType=='Allowed Merchant Categories'))){
            component.set("v.isCardControl",true);
            
        }
        if((subType =='Spending Limit Settings')||(subType =='Transaction amount' && reqType=='Release')){
            component.set("v.isSpendingLimit",true);
            
        }
        if(subType =='Statement Request'){
            component.set("v.isStatementReq",true);
            
        }
        if(subType =='Fees Reversal Request'){
            component.set("v.isFeeRev",true); 
        }
        if(subType =='Credit Limit Increase'){
            component.set("v.isCreditLimitInc",true); 
        }
        if(subType =='Credit Limit Decrease'){
            component.set("v.isCreditLimitDec",true);	
        }
        if(subType =='Credit Card Account Closing' || (subType == 'Account Closure' && (reqType == 'ila blue' ||reqType == 'ila switch' || reqType == 'ila prepaid' ))){
            component.set("v.isAccountClosure",true);    
        }
        if(subType =='No due certificate'){
            component.set("v.isNoDueCertificate",true);	
        }if(subType =='EPP Cancel Plan' || subType =='EPP Early Closure' || subType =='EPP Technical Error'){
            component.set("v.isEpp",true);	
        }
    },
    helperGenerateCertificate : function(component, event){
        //debugger;
        var method="post";
        var acc=component.get('v.account');
        var action=component.get('c.sendEmailWithPdf');
        action.setParams({
            'caseId':component.get("v.caseId"),
            'IBAN':'123456789',
            'startDate':'2021-07-21',
            'accountCurrency':'BHD'
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==='SUCCESS'){
                var emailResponse=response.getReturnValue();
                if(emailResponse ==='Success'){
                    var toastEvent = $A.get("e.force:showToast");  
                    toastEvent.setParams({  
                        "title": "Success!",  
                        "type": "success",  
                        "message": "Email Sent Successfully!"  
                    });  
                    toastEvent.fire(); 
                    
                }else{
                    var toastEvent = $A.get("e.force:showToast");  
                    toastEvent.setParams({  
                        "title": "Error!",  
                        "type": "error",  
                        "message":emailResponse 
                    });  
                    toastEvent.fire(); 
                }
            }
            
        });
        
        $A.enqueueAction(action);
    },
    helpersendBusinessApproval : function(component, event){
        
        var action=component.get('c.sendToBusinessApproval');
        action.setParams({
            'caseId':component.get("v.caseId")  
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==='SUCCESS'){  
                var recordUpdate=response.getReturnValue();
                if(recordUpdate ==='Success'){
                    var toastEvent = $A.get("e.force:showToast");  
                    toastEvent.setParams({  
                        "title": "Success!",  
                        "type": "success",  
                        "message": "Assigned To Business Queue!"  
                    });  
                    toastEvent.fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");  
                    toastEvent.setParams({  
                        "title": "Error!",  
                        "type": "error",  
                        "message":recordUpdate 
                    });  
                    toastEvent.fire(); 
                }
            }else{
                var toastEvent = $A.get("e.force:showToast");  
                toastEvent.setParams({  
                    "title": "Error!",  
                    "type": "error",  
                    "message": recordUpdate
                });  
                toastEvent.fire(); 
            }
        });
        $A.enqueueAction(action);
    },
    sendRejection : function(component, event){
        console.log('helpersendRejection|| '+component.get("v.caseId") );
        var action=component.get('c.sendForRejection');
        action.setParams({
            'caseId':component.get("v.caseId")  
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==='SUCCESS'){
                var recordUpdate=response.getReturnValue();
                if(recordUpdate ==='Success'){
                    var toastEvent = $A.get("e.force:showToast");  
                    toastEvent.setParams({  
                        "title": "Success!",  
                        "type": "success",  
                        "message": "Rejected the request and Closing the Case"  
                    });  
                    toastEvent.fire(); 
                    
                }else{
                    var toastEvent = $A.get("e.force:showToast");  
                    toastEvent.setParams({  
                        "title": "Error!",  
                        "type": "error",  
                        "message":recordUpdate 
                    });  
                    toastEvent.fire(); 
                } 
            }else{
                var toastEvent = $A.get("e.force:showToast");  
                toastEvent.setParams({  
                    "title": "Error!",  
                    "type": "error",  
                    "message": recordUpdate
                });  
                toastEvent.fire(); 
            }
        });
        $A.enqueueAction(action);
    },
    //not in use commented by Shashank UATNB-26830 || CRM Defects || Action required
    validationHelper : function(component, subtype){
        var isValid = true;
        if(subtype =='Credit Card Account Closing'){
            var cardNumber = component.get("v.cc_CardId");
            var lastFour = cardNumber.substr(cardNumber.length - 4);
            if(component.find("cclast4Digit").get("v.value") != lastFour){
                isValid = false;
            }
        }
        if(!isValid){
            var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"error",
            "title": "Error!",
            "message": 'Please Provide valid Last 4 Digit Card Number'
        });
        toastEvent.fire();  
        }
        component.set("v.isButtonVisible",isValid);
    },
    //CH01: Start
    updatePCIAndMaskCardNoCase :  function(component,caseId,pciNumber,mskCardNumber){
        console.log('Update PCI and Masked Card Number in Helper');
        var action = component.get('c.updatePCIMaskNumberOnCase');
        action.setParams({
            caseId:caseId,
            pciNumber:pciNumber,
            mskCardNumber:mskCardNumber
        });
        
        action.setCallback(this, function(response) {
            console.log('Response State:',response.getState());
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Result Value:',result)
            }
            else if(state === "INCOMPLETE"){
                console.log("Incomplete message");
            }
                else if(state === 'Error'){
                    var errors = response.getError();
                    if(errors){
                        console.log("Error message: ",+ errors[0].message);
                    }else{
                        console.log("UNKNOWN error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    //CH01: END
    //CH02: Start
    /*fetchIlaWorldMembershipNumber : function(component,caseId){
        var action = component.get('c.fetchWorldEliteMembershipNumber');
        action.setParams({
            caseId:caseId
        });
        action.setCallback(this, function(response) {
            console.log('Response State:',response.getState());
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Result Value Membership Number:',result);
                if(result != null){
                    component.set("v.membershipNumber", result);
				}else if(result == null){
                    component.set("v.membershipNumber", "");
                }
            }
            else if(state === "INCOMPLETE"){
                console.log("Incomplete message");
            }
                else if(state === 'Error'){
                    var errors = response.getError();
                    if(errors){
                        console.log("Error message: ",+ errors[0].message);
                    }else{
                        console.log("UNKNOWN error");
                    }
                }
        });
        $A.enqueueAction(action);
        
    },
     handleErrors: function (errors) {
		// Configure error toast
		let toastParams = {
			mode: "sticky",
			title: "Error",
			message: errors, // Default error message
			type: "error"
		};
		// Fire error toast
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams(toastParams);
		toastEvent.fire();
	},*/
    //CH02: END
})
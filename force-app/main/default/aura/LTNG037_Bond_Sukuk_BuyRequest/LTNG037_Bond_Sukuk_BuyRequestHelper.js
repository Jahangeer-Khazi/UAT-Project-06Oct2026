({
    doInit : function (component, event, helper, accId) {
        var action = component.get('c.getAccRequestCaseRecordType');
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if (data) {
                    component.set("v.recordTypeId", data);
                }
            } else if (statut === "ERROR") {
                // Process error returned by server
                helper.handleErrors(actionResult.getError(), '');
            }
                else {
                    console.error("AUTRE ERROR");
                    // Handle other reponse states
                }
        });
        $A.enqueueAction(action);
    },
    showSpinner: function (component, event, helper) {
        component.set("v.showSpinner",true);
    },
    hideSpinner: function (component, event, helper) {
        component.set("v.showSpinner",false);
    },
    handleErrors: function (errors, addError) {
        // Configure error toast
        let toastParams = {
            mode: "sticky",
            title: "Error",
            message: errors, // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = addError + '' + errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },  
    loadIban : function (component, event, helper) {
        var action = component.get('c.getAccountListViaApi');
        var recId = component.get('v.recordId');
        var caseModel=component.get('v.caseModel');
        //  alert('CaseMode##'+caseModel);
        action.setParams({'accountId':recId,'caseModel':caseModel});
        
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                //alert(JSON.stringify(data));
                if (data && data.length>0) {
                    component.set("v.currentAcc", null);
                    component.set("v.accToReleaseHoldList", data);
                    // alert(JSON.stringify(component.get("v.accToReleaseHoldList")));
                }else{
                    helper.handleErrors('No BHD '+ caseModel +' currency accounts returned', '');
                }
            } else if (statut === "ERROR") {
                // Process error returned by server
                helper.handleErrors(actionResult.getError(), '');
            }
                else {
                    console.error("AUTRE ERROR");
                    // Handle other reponse states
                }
        });
        $A.enqueueAction(action);
    }, loadInstrument : function (component, event, helper) {
        var action = component.get('c.getInstrumentListViaApi');
        var recId = component.get('v.recordId');
        var caseModel=component.get('v.caseModel');
        action.setParams({'accountId':recId,'caseModel':caseModel});
        
        action.setCallback(this, function (actionResult) {
            var status = actionResult.getState();
            if (status === "SUCCESS") {
                let data = actionResult.getReturnValue();
                console.log(JSON.stringify(data));
                if (data) {
                    
                    component.set("v.currentInst",null);
                    component.set("v.InstrumentList",data);
                    // alert(JSON.stringify(component.get("v.accToInstList")));
                }
            } else if (statut === "ERROR") {
                // Process error returned by server
                helper.handleErrors(actionResult.getError(), '');
            }
                else {
                    console.error("AUTRE ERROR");
                    // Handle other reponse states
                }
        });
        $A.enqueueAction(action);
    },loadBond : function (component, event, helper) {
        var action = component.get('c.getBondListViaApi');
        var recId = component.get('v.recordId');
        var caseModel=component.get('v.caseModel');
        action.setParams({'accountId':recId,'caseModel':caseModel});
        
        action.setCallback(this, function (actionResult) {
            var status = actionResult.getState();
            if (status === "SUCCESS") {
                let data = actionResult.getReturnValue();
                alert('Ibanacc'+data);
                if (data) {
                    //  component.set("v.currentInst", null);
                    component.set("v.BidInformationCal",data);
                    // alert(JSON.stringify(data));
                }
            } else if (statut === "ERROR") {
                // Process error returned by server
                helper.handleErrors(actionResult.getError(), '');
            }
                else {
                    console.error("AUTRE ERROR");
                    // Handle other reponse states
                }
        });
        $A.enqueueAction(action);
    },
    CalculateBid:function (component, event, helper,bidAmount,ISIN_Code,Iban) {
        var caseModel=component.get('v.caseModel');
        var action = component.get('c.getBondListViaApi');
        var recId = component.get('v.recordId');
        //  alert('recId##'+recId);
        action.setParams({'Bidamount':bidAmount,'isinCode':ISIN_Code,'Iban':Iban,'accountId':recId,'caseModel':caseModel});
        action.setCallback(this, function (actionResult) {
            var status = actionResult.getState();
            if (status === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if (data) {
                    component.set("v.BidInformationCal",data);
                    component.find("bs_Bid_Fees").set("v.value",data[0].bs_Bid_Fees);
                    component.find("bs_Bid_VAT").set("v.value",data[0].bs_Bid_VAT);
                    component.find("bs_Total_Bid_Amount").set("v.value",data[0].bs_Total_Bid_Amount);
                }
            } else if (statut === "ERROR") {
                helper.handleErrors(actionResult.getError(), '');
            }
                else {
                    console.error("AUTRE ERROR");
                }
        });
        $A.enqueueAction(action);
    },
    loadBondConfiguration:function (component, event, helper){
        var action = component.get('c.getBondConfiguration');
        var recId = component.get('v.recordId');
        var caseModel= component.get('v.caseModel');
        action.setParams({'accountId':recId,'caseModel':caseModel});
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                
                if (data) {
                    component.set("v.questionnaire",data[0].bs_Questionaire);
                    component.set("v.allowedMultiples",data[0].bs_ALLOWED_MULTIPLES);
                    console.log('data##3'+data);
                    let Consent_Status;
                    if(component.get("v.questionnaire")=='disabled'){
                        component.set("v.Consent_Status",'VALID');
                        Consent_Status='VALID';
                    }else{
                        component.set("v.Consent_Status",component.find("Consent_Status").get("v.value"));
                        Consent_Status=component.find("Consent_Status").get("v.value");
                    }
                    if(Consent_Status!='VALID') {
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                        component.find('notifyId').showNotice({
                            "variant": "warning",
                            "header": "Invalid Investment Questionarie",
                            "message": "There is not valid Bond/Sukuk Consent Status. Please proceed Submitting a valid Investment Questionarie Inorder to proceed with Buy Request",
                            closeCallback: function(component, event, helper) 
                            {window.setTimeout($A.getCallback(function() {}),100);}});              
                    }
                }
                let subscriptionModel = component.find("Subscription_Model").get("v.value");
                if( subscriptionModel != null && subscriptionModel == 'alburaq' ){
                    component.set('v.caseModel',subscriptionModel);
                }else{
                    component.set('v.caseModel','ila');
                }
                helper.loadIban(component,event,helper);
            } else if (statut === "ERROR") {
                // Process error returned by server
                helper.handleErrors(actionResult.getError(), '');
            }
                else {
                    console.error("AUTRE ERROR");
                    // Handle other reponse states
                }
        });
        $A.enqueueAction(action);
    }
})
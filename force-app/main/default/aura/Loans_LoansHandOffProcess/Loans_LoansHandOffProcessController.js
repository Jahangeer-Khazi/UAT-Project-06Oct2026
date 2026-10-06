({
    init : function(component, event, helper) {

        console.log('==== Init ========');
        var action = component.get("c.getCaseAnnexFields");
        action.setParams({
            caseId: component.get("v.caseId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('==== getCaseAnnexFields ========');
            if (state === "SUCCESS") {
                 var result = response.getReturnValue();
                 console.log("fetch CaseAnnex fields."+ JSON.stringify(result));
                //omar start
                component.set("v.hasContent", result.hasContent);
                //Omar end 

                // fetch isSubmitted current Value 
                component.set("v.isSubmit", result.isSubmitted);


                // Top-up
                //component.set("v.totalTopUpAmount", result.TotalTopUpAmount__c);
                //component.set("v.totalNumberOfInstallments", result.TotalNumberOfInstallments__c);

                // Early Settlement Reason
                component.set("v.earlySettlementReasonValue", result.cx_ln_Installment_Advance_Payment_reason__c);//to ptimise using fields I'm using an existing reason field and changing the label next 
                console.log("EarlySettlementReasonPicklistValues: " + result.EarlySettlementReasonPicklistValues);
                /*var EarlySettlementoptions = [];
                EarlySettlementoptions.push({ label: '--None--', value: null });
                result.EarlySettlementReasonPicklistValues.forEach(function(value) {
                    let parts = value.split(";");
                    EarlySettlementoptions.push({ label: parts[1], value: parts[0] });
                });
                component.set("v.earlySettlementReasonOptions", EarlySettlementoptions);*/

                //  waiver
                component.set("v.ReversalWaiverReason", result.ReversalWaiverReason__c);
                component.set("v.FEEAmount", result.FEEAmount__c);
                component.set("v.FEEType", result.FEEType__c); 

                //  Installment Deferment
                component.set("v.InstallDefermentReason", result.InstallDefermentReason__c);
                component.set("v.NumberDeferredInstallments", result.cx_ln_NumberDeferredInstallments__c);

               
                // Partial Settlement and "Top-up"
                component.set("v.PartialSettlementAmount", result.PartialSettlementAmount__c);
                component.set("v.PartialSettlementTerm", result.cx_ln_Requested_Duration_Months__c);  
                component.set("v.PartialSettlementRestructureValue", result.PartialSettlementRestructure__c); 
                console.log("PartialSettlementRestructureValue: " + result.PartialSettlementRestructure__c);
                console.log("PartialSettlementRestructureValues: " + result.PartialSettlementRestructureValues);
                var partSettlementoptions = [];
                
                partSettlementoptions.push({ label: '--None--', value: null });
               
                result.PartialSettlementRestructureValues.forEach(function(value) {
                    let parts = value.split(";");
                    partSettlementoptions.push({ label: parts[1], value: parts[0] });
                });
                component.set("v.PartialSettlementOptions", partSettlementoptions);
                

               

               //Restructuring
               
           
               console.log("ReasonForTheLoanFinanceRestructuring Value : " + result.ReasonForTheLoanFinanceRestructur__c);
               console.log("Restructure options : " + result.RestructuringValues);
               component.set("v.restructuringValue", result.cx_ln_RestructureOption__c); 
               component.set("v.newRate", result.cx_ln_ApprovedNewRate__c);  
               //component.set("v.reasonForRestructuring", result.ReasonForTheLoanFinanceRestructur__c); 
               var restructuringOptions = [];
                
               restructuringOptions.push({ label: '--None--', value: null });
              
               result.RestructuringValues.forEach(function(value) {
                let parts = value.split(";");
                restructuringOptions.push({ label: parts[1], value: parts[0] });
               });
               component.set("v.restructuringOptions", restructuringOptions);

                //Advance Payment
                component.set("v.InstalmentsForAdvancePayments", result.InstalmentsForAdvancePayments__c); 
                component.set("v.AdvancePaymentReason", result.cx_ln_Installment_Advance_Payment_reason__c); 
                // component.set("v.AdvancePaymentValue", result.AdvancePayment__c); 
                // console.log("AdvancePaymentValues: " + result.AdvancePaymentPicklistValues);
                // var AdvancePaymentOptions = [];

                // AdvancePaymentOptions.push({ label: '--None--', value: null });
                // result.AdvancePaymentPicklistValues.forEach(function(value) {
                //     AdvancePaymentOptions.push({ label: value, value: value });
                // });
                // component.set("v.AdvancePaymentOptions", AdvancePaymentOptions);
                 
            } else {
                 console.log("Failed to fetch CaseAnnex fields.");
                 console.log("Failed response => ", response);
            }
        });
        $A.enqueueAction(action);
    },
    handleOnload : function(component, event, helper) {
        
        helper.showSpinner(component);
        let subType = component.find("subType").get("v.value");
        helper.setFieldVisibility(component,subType);
        
        if(subType == 'Partial Settlement'){
            //get monthly instalmment 
            helper.loadPaymentsSchedule(component);
        }
        
        helper.hideSpinner(component);
         
	},
    handleOnSubmit : function(component, event, helper) {
            helper.showSpinner(component);
            event.preventDefault();
            var fields = event.getParam("fields");

            //#CH02
            var action1 = component.get("c.checkContentsofList");
            action1.setParams({
                "caseId": component.get("v.caseId")
            });
            action1.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                if (state === "SUCCESS") {
                       console.log("checkContentsofList called");
                       if(result == false && component.get("v.isWaiver") == false ){
                            component.set("v.hasContent", result);
                            let msg = $A.get("$Label.c.Content_Required_Message");
                            helper.handleErrors('Content Required: '+msg);
                            helper.hideSpinner(component);
                            return ;
                        }
                        
                        //submit logic : ..
                        if (component.get("v.loanNumber") === fields["Loan_Application_ID__c"] || fields["Loan_Application_ID__c"] === null) {
                            fields["Loan_Application_ID__c"] = component.get("v.loanNumber");
                            //var reasonForRestructuring = component.get("v.reasonForRestructuring");
                            var restructuringValue = component.get("v.restructuringValue");
                            //console.log("1 >> "+ reasonForRestructuring + "2 >>"+restructuringValue )
                            //var totalTopUpAmount = component.get("v.totalTopUpAmount");
                            //var totalNumberOfInstallments = component.get("v.totalNumberOfInstallments");
                            var earlySettlementReason = component.get("v.earlySettlementReasonValue");
                            var ReversalWaiverReason =  component.get("v.ReversalWaiverReason");
                            var FEEAmount =  component.get("v.FEEAmount");
                            var FEEType =  component.get("v.FEEType");
                            var InstallDefermentReason =  component.get("v.InstallDefermentReason");
                            var NumberDeferredInstallments =  component.get("v.NumberDeferredInstallments");
                            var PartialSettlementRestructureValue =  component.get("v.PartialSettlementRestructureValue");
                            var PartialSettlementAmount =  component.get("v.PartialSettlementAmount"); 
                            var PartialSettlementTerm =  component.get("v.PartialSettlementTerm");
                            var newRate =  component.get("v.newRate");
            
                            var InstalmentsForAdvancePayments =  component.get("v.InstalmentsForAdvancePayments"); 
                            var AdvancePaymentReason =  component.get("v.AdvancePaymentReason"); 
                            var AdvancePaymentValue =  component.get("v.AdvancePaymentValue"); 
            
                            var responseLoanListdata = component.get('v.responseLoanListdata');
                            console.log('component.get("v.responseLoanListdata") ',responseLoanListdata);
                            var LoanId = component.get("v.loanNumber");
            
                            var loanObj;
                            for (var i = 0; i < responseLoanListdata.currentLoans.length; i++) {
                                
                                if(responseLoanListdata.currentLoans[i].arrangementId == LoanId ){
                                    loanObj = responseLoanListdata.currentLoans[i];
                                    break;
                                }
                            }
                 
                            console.log('loanObj ',loanObj);
                            var action = component.get("c.submitForm");
                            action.setParams({
                                "caseId": component.get("v.caseId"),
                                //"totalTopUpAmount": totalTopUpAmount,
                                //"totalNumberOfInstallments": totalNumberOfInstallments,
                                "earlySettlementReason": earlySettlementReason,
                                "ReversalWaiverReason" : ReversalWaiverReason,
                                "FEEAmount" : FEEAmount,
                                "FEEType" : FEEType,
                                "InstallDefermentReason" : InstallDefermentReason,
                                "NumberDeferredInstallments" : NumberDeferredInstallments,
                                "PartialSettlementRestructureValue" : PartialSettlementRestructureValue,
                                "PartialSettlementAmount" : PartialSettlementAmount,
                                "PartialSettlementTerm" : PartialSettlementTerm,
                                "newRate" : newRate,
                                "InstalmentsForAdvancePayments" : InstalmentsForAdvancePayments,
                                "AdvancePaymentReason" : AdvancePaymentReason,
                                "AdvancePaymentValue" : AdvancePaymentValue,
                                //"reasonForRestructuring" : reasonForRestructuring,
                                "restructuringValue" : restructuringValue,
                                "LoanId" : component.get("v.loanNumber"),
                                "loanObj" : loanObj
                            });
                            action.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                       console.log("Form submitted successfully");
                            
                                        helper.handleOnSuccess(component, event, helper); 
                                        helper.hideSpinner(component);
                                        $A.get('e.force:refreshView').fire();
                                        console.log("refreshed successfully");
                                        component.set("v.isSubmit", true);
                                        component.set("v.isSubmittedToParent", true);
            
                                } else {
                                    // component.set("v.isSubmit", false);
                               
                                    console.error("Error occurred while submitting form");
                                    helper.handleOnError(component, event, helper); 
                                }
                            });
                            $A.enqueueAction(action);
                
                     
                        } else {
                            helper.hideSpinner(component);
                            console.log('Invalid Loan Application ID!');
                        }

                } else {
                    console.error("Error occurred while geeting Contents");
                    helper.handleOnError(component, event, helper); 
                }
            });
            $A.enqueueAction(action1);
    },
    validateTerm : function(component, event, helper) { //#CH02
        console.log('validateTerm --> ');
        let inputCmp = component.find("termInput");
        if (inputCmp) {
            inputCmp.reportValidity();
        }
    },
    handlePartialSettlementOptionChange : function(component, event, helper) {
        console.log('handlePartialSettlementOptionChange');
        var PartialSettlementRestructureValue =  component.get("v.PartialSettlementRestructureValue");
        var isPartialSettlementRequired = PartialSettlementRestructureValue == 'Change the loan term';
        console.log('handlePartialSettlementOptionChange',isPartialSettlementRequired);
        component.set("v.isPartialSettlementTermRquired", isPartialSettlementRequired);
    },
    handleDownload : function(component, event, helper) {
        var model = component.get('v.caseModel');
        console.log('model '+model);
        if(component.get("v.caseModel") == 'ila') {
            if(component.get('v.isTopUp') == true){
                const url = component.get('v.LoantemplateUrlTopUp');
                helper.download(url, 'Loan - Ila Topup Request Form.pdf');
            }
            else if(component.get('v.isInstallment') == true || component.get('v.isRestructuring') == true){
                const url = component.get('v.LoantemplateUrlRestrucuringInstallment');
                helper.download(url, 'Loan - Ila Restructuring Installment Deferment Request Form.pdf');
            }
            else{
                const url = component.get('v.LoantemplateUrl');
                helper.download(url, 'Loan Settlement Advance Payment ila.pdf');
            }
        }
    	if(component.get("v.caseModel") == 'alburaq') {
            if(component.get('v.isTopUp') == true){
                const url = component.get('v.FinancetemplateUrlTopUp');
                helper.download(url, 'Loan - Alburaq Topup Request Form.pdf');
            }
            else if(component.get('v.isInstallment') == true || component.get('v.isRestructuring') == true){
                const url = component.get('v.FinancetemplateUrlRestrucuringInstallment');
                helper.download(url, 'Finance Restructuring Installment Deferment Request Form.pdf');
            }else{
                const url = component.get('v.FinancetemplateUrl');
                 helper.download(url, 'Finance Settlement Advance Payment.pdf');
            }
        }
         
    },
})
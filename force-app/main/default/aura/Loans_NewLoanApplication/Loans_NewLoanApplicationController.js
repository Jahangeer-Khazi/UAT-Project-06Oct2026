/**
Change History :
*   
*/
({
    Init: function (component, event, helper) {
        
        let action = component.get("c.getAccountRecord");
        action.setParams({
            "accountId": component.get("v.recordId")
        });
        console.log('Init function ===', component.get("v.recordId"));
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                // Set the returned Account record to the Customer attribute
                var acc = response.getReturnValue()
                console.log('Fetched Account : ', acc);
                component.set("v.customer", acc);
                // let subscriptionModel = component.find("Subscription_Model1").get("v.value");
                let subscriptionModel = acc.Subscription_Model__pc;
                console.log('handleLoad  subscriptionModel --- ', subscriptionModel);
                if( subscriptionModel != null && subscriptionModel == 'alburaq' ){
                    component.set('v.caseModel',subscriptionModel);
                    component.set('v.subject','New Personal Finance Application');
                    component.set('v.description','New request for a Finance Application');
                }else{
                    component.set('v.caseModel','ila');
                    component.set('v.subject','New Personal Loan Application');
                    component.set('v.description','New request for a Loan Application');
                }

            } else if (state === "ERROR") {
                let errors = response.getError();
                console.error(errors);
            }
        });
        
        // Send action to server
        $A.enqueueAction(action);

	},
	handleOnload : function(component, event, helper) {
        component.set('v.showAdditionalInfoTemporary', false);
        // Define table columns
        component.set("v.LiabilitiesColumns", [
            { label: "Type", fieldName: "type", type: "text" },
            { label: "Outstanding", fieldName: "outstanding", type: "text" },
            { label: "MonthlyInstallment", fieldName: "monthlyInstallment", type: "text" }
        ]);
        component.set("v.CustomerProductsColumns", [
            { label: "Product Type", fieldName: "productType", type: "text" },
            { label: "Name", fieldName: "name", type: "text" },
            { label: "Account IBAN", fieldName: "accountId", type: "text" },
            { label: "Available Balance", fieldName: "availableBalance", type: "text" },
            // { label: "Id", fieldName: "id", type: "text" },
        ]);

        var requestedLoanTypes = component.get("v.requestedLoanTypes");
        if(!requestedLoanTypes){
            helper.fillRequestedLoansTypeOptions(component);
        }
        
	},
    handleOnSubmit: function(component, event, helper) {
        helper.showSpinner(component);
        event.preventDefault(); // Prevent default submission of the Case form
        var product = component.find("cx_ln_Product").get("v.value");
        console.log('isLoanCalculated : ', component.get("v.isLoanCalculated"));

        if (!component.get("v.isLoanCalculated")) {
            component.set("v.isLoanCalculatedValidationMessage", "Please click the button for calculation before saving.");
            helper.hideSpinner(component);
            return;
        }
        if(product == 'Secured'){
            var FinalselectedRows = component.get("v.FinalselectedRows");
            if (!FinalselectedRows || FinalselectedRows.length === 0) {
                component.set("v.CustomerProductsvalidationMessage", "Please select  one row from the Customer Products table before saving.");
                helper.hideSpinner(component);
                return;
            }

            component.set("v.CustomerProductsvalidationMessage", "");
        }
        
        var BusinessNatureType = component.find('cc_Business_Nature_Type').get("v.value");
        
        if(BusinessNatureType == 'Buyout Loan/Finance'){
            var FinalRequestedLiabilitiesSelectedRows = component.get("v.FinalRequestedLiabilitiesSelectedRows");
            if (!FinalRequestedLiabilitiesSelectedRows || FinalRequestedLiabilitiesSelectedRows.length === 0) {
                component.set("v.requestedLiabilitiesvalidationMessage", "Please select at least one row from the requested liabilities table before saving.");
                helper.hideSpinner(component);
                return;
            } 
            let loanAmount = (component.find("cx_ln_Loan_Calculation_Method").get("v.value") == 'By Loan/Finance Amount') ? component.find("Loans_Requested_Loan_Finance_Amount_Amount").get("v.value") : component.find("Loans_Requested_Loan_Finance_Amount_Installment").get("v.value");
            let existingLoans = 0;
            for (var i = 0; i < FinalRequestedLiabilitiesSelectedRows.length; i++) {
                if (FinalRequestedLiabilitiesSelectedRows[i].selected) {
                    existingLoans = existingLoans + FinalRequestedLiabilitiesSelectedRows[i].outstanding;
                }
            }
            if (existingLoans > loanAmount) {
                component.set("v.requestedLiabilitiesvalidationMessage", "The sum of all selected liabilies shouldn' be greater than the loan/finance amount, please review the selection.");
                helper.hideSpinner(component);
                return;
            }
            

            component.set("v.requestedLiabilitiesvalidationMessage", "");        
        } 
        
        var fld = component.find("RequestedDuration");
        var val = fld.get("v.value");
        if (val != null && Number(val) > 84) {
            let errMsg = "Requested Duration shouldn’t exceed 84 months.";
            helper.hideSpinner(component);
            helper.handleErrors(errMsg);
            return;
        }

        let configId = component.get("v.loanProductConfigurationId");
        if (configId == null || configId == '' ) {
            let errMsg = "loanProductConfigurationId is Empty please check with your Administrator.";
            helper.hideSpinner(component);
            helper.handleErrors(errMsg);
            return;
        }

        //NBA-16690 :Start
        const caseFields = event.getParam('fields');
        // Create the Case record
        component.find('caseform').submit(caseFields);
        //Restrict any loan/ CC (secured or unsecured) case creation from CRM if the customer has an exit case in progress (compliance exit recommendation case))
        /*var action = component.get('c.checkExistanceOfComplianceCase');
        action.setParams({
            accountId: component.get('v.recordId')
        });
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if (data != null) {
                    console.log('error on the check --> ' +data);
                    let errorTxt = 'You can’t create a Compliance Exit Recommendation case for this customer because they currently have an '+ data +' on their account.';
                    helper.handleErrors(errorTxt, '');
                }else {
                    console.log('no errors on the check');
                    const caseFields = event.getParam('fields');
                    // Create the Case record
                    component.find('caseform').submit(caseFields);
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
        $A.enqueueAction(action);*/
        //NBA-16690 :End
    },
    handleOnSuccess : function(component, event, helper) {
        console.log("Start handleOnSuccess");
        const caseId = event.getParam("response").id;
        const caseAnnexForm = component.find('caseAnnexform1');
        console.log("Before getting case annex fields", caseId, $A.get("$Label.c.CaseAnnex_LoanApplicationRecordTypeId"));
        const fields = {
            RecordTypeId : $A.get("$Label.c.CaseAnnex_LoanApplicationRecordTypeId"),
            Case__c: caseId,
            cx_ln_Product__c: component.find("cx_ln_Product") ? component.find("cx_ln_Product").get("v.value") : null,
            cx_ln_Business_Nature_Type__c: component.find("cc_Business_Nature_Type") ? component.find("cc_Business_Nature_Type").get("v.value") : null,
            cx_ln_Loan_Finance_Type__c: component.find("cx_ln_Loan_Finance_Type") ? component.find("cx_ln_Loan_Finance_Type").get("v.value") : null,
            cx_ln_Gross_Income_2__c: component.find("cx_ln_Gross_Income") ? component.find("cx_ln_Gross_Income").get("v.value") : null,
            cx_ln_Requested_Loan_Finance_Amount__c: (component.find("cx_ln_Loan_Calculation_Method").get("v.value") == 'By Loan/Finance Amount') ? component.find("Loans_Requested_Loan_Finance_Amount_Amount").get("v.value") : component.find("Loans_Requested_Loan_Finance_Amount_Installment").get("v.value"),
            cx_ln_Monthly_Instalment__c: (component.find("cx_ln_Loan_Calculation_Method").get("v.value") == 'By Loan/Finance Amount') ? component.find("RequestedMonthlyInstalment_Amount").get("v.value") : component.find("RequestedMonthlyInstalment_Installment").get("v.value"),
            cx_ln_Requested_Duration_Months__c: component.find("RequestedDuration") ? component.find("RequestedDuration").get("v.value") : null,
            cx_ln_Loan_Calculation_Method__c: component.find("cx_ln_Loan_Calculation_Method") ? component.find("cx_ln_Loan_Calculation_Method").get("v.value") : null,
            cx_ln_Requested_Liabilities__c: component.find("cx_ln_Requested_Liabilities") ? component.find("cx_ln_Requested_Liabilities").get("v.value") : null,
            cx_ln_TotalLiabilitiesAmount__c: component.find("cx_ln_TotalLiabilitiesAmount") ? component.find("cx_ln_TotalLiabilitiesAmount").get("v.value") : null,
            cx_ln_TotalLiabilityMonthlyInstallAmount__c: component.find("cx_ln_TotalLiabilityMonthlyInstallAmount") ? component.find("cx_ln_TotalLiabilityMonthlyInstallAmount").get("v.value") : null,
            cx_ln_Requested_Interest_Rate__c: component.find("cx_ln_Requested_Interest_Rate") ? component.find("cx_ln_Requested_Interest_Rate").get("v.value") : null,
            cx_ln_Requested_Insurance_Amount__c: component.find("cx_ln_Requested_Insurance_Amount") ? component.find("cx_ln_Requested_Insurance_Amount").get("v.value") : null,
            cx_ln_Requested_Processing_Fees__c: component.find("cx_ln_Requested_Processing_Fees") ? component.find("cx_ln_Requested_Processing_Fees").get("v.value") : null,
            cx_ln_Requested_Vat_Processing_Fees__c: component.find("cx_ln_Requested_Vat_Processing_Fees") ? component.find("cx_ln_Requested_Vat_Processing_Fees").get("v.value") : null,
            cx_ln_Requested_First_Payment_Date__c: component.find("cx_ln_Requested_First_Payment_Date") ? component.find("cx_ln_Requested_First_Payment_Date").get("v.value") : null,
            cx_ln_Requested_Maturity_Date__c: component.find("cx_ln_Requested_Maturity_Date") ? component.find("cx_ln_Requested_Maturity_Date").get("v.value") : null,
            cx_ln_Requested_Cash_in_Hand__c: component.find("cx_ln_Requested_Cash_in_Hand") ? component.find("cx_ln_Requested_Cash_in_Hand").get("v.value") : null,

            cx_ln_Administrative_Fee__c: component.find("cx_ln_Administrative_Fee") ? component.find("cx_ln_Administrative_Fee").get("v.value") : null,
            cx_ln_Processing_Fee_Type__c: component.find("cx_ln_Processing_Fee_Type") ? component.find("cx_ln_Processing_Fee_Type").get("v.value") : 'Upfront',
            cx_ln_Insurance_Premium__c: component.find("cx_ln_Insurance_Premium") ? component.find("cx_ln_Insurance_Premium").get("v.value") : null,
            cx_ln_Current_Address_confirmation__c : component.find("CurrentAddressConfirmation") ? component.find("CurrentAddressConfirmation").get("v.value") : null
        };

    
        console.log("Submitting case annex fields:", fields);
        caseAnnexForm.submit(fields);
        console.log('after submit');
    },
    handleOnSuccessAnnex : function(component, event, helper) {
        console.log("handleOnSuccessAnnex -->");
        var resp = event.getParam("response");
        //console.log("response:", JSON.stringify(resp));
    
        var caseId = null;
    
        // Primary: direct lookup on the saved record
        if (resp && resp.fields && resp.fields.Case__c && resp.fields.Case__c.value) {
            caseId = resp.fields.Case__c.value;
        }
        // Fallback: dereferenced relationship payload
        else if (resp && resp.fields && resp.fields.Case__r &&
                 resp.fields.Case__r.fields && resp.fields.Case__r.fields.Id &&
                 resp.fields.Case__r.fields.Id.value) {
            caseId = resp.fields.Case__r.fields.Id.value;
        }
    
        console.log("caseId -->", caseId);

        // setTimeout(function() {
            
            helper.hideSpinner(component);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":"success",
                "title": "Success!",
                "message": "Case has been created successfully."
            });
            toastEvent.fire(); 
            $A.get("e.force:closeQuickAction").fire();

            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": caseId,
                "slideDevName": "detail"
            });
            navEvt.fire();
        // }, 100); 

        
    },
    handleOnErrorAnnex : function(component, event, helper) {
        var errorMessages = event.getParam("message");
        console.log(errorMessages);
        helper.hideSpinner(component);
	},
    handleOnError : function(component, event, helper) {
        var errorMessages = event.getParam("message");
        console.log(errorMessages);
        helper.hideSpinner(component);
	},
    onCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    caseModelIsChanged : function(component, event, helper) {
        console.log('is changed caseModelIsChanged');
       
        var caseModel = component.get("v.caseModel");
        
        if( caseModel != null && caseModel == 'alburaq' ){
            component.set('v.subject','New Personal Finance Application');
            component.set('v.description','New request for a Finance Application');
        }else{
            component.set('v.subject','New Personal Loan Application');
            component.set('v.description','New request for a Loan Application');
        }
        // requested Loan type
        component.set("v.requestedLoanTypes",null);
        component.set("v.loanProductConfigurationId",null);
        console.log('is changed caseModelIsChanged -- ', caseModel);
        // Reset requested liabilities
        // component.find("TransferExistingLoansFinancesId").set("v.value", false);
        // component.set('v.LiabilitiesSelectedValues',[])
        component.set('v.LiabilitiesOptions',[])
        

        // Reset User Application Info
        var product = component.find("cx_ln_Product").get("v.value");
        if (product == 'Unsecured') {
            component.find("EmploymentStatus").set("v.value", null);
            component.set("v.isEmployed", false);
            component.find("EmployerName").set("v.value", null);
            component.find("cx_ln_Gross_Income").set("v.value", null);
            component.find("ResidenceOccupancyStatus").set("v.value", null);
            component.find("NumberYearsCurrentResidence").set("v.value", null);
            component.find("currentAddress").set("v.value", null);
            component.find("CurrentAddressConfirmation").set("v.value", false);
            component.find("MaritalStatus").set("v.value", null);
            component.find("NumberOfDependents").set("v.value", null);
            component.find("AcademicQualifications").set("v.value", null);
            component.find("FriendContactNumber").set("v.value", null);
            component.find("FriendName").set("v.value", null);
        }
        component.find("cx_ln_Product").set("v.value", null);
        component.set('v.Product',null);
        component.find("cc_Business_Nature_Type").set("v.value", null);
        helper.fillRequestedLoansTypeOptions(component);
    },

    BusinessNatureIsChanged : function(component, event, helper) {

        component.set('v.LiabilitiesOptions',[]); //UATNB-211338 : call this line all the time now
        /*
        //UATNB-211338 : comment this bloc because we are moving the "helper.getExistingLiabilitiesAPI(component)" to the calculate button click
        var BusinessNatureType = component.find('cc_Business_Nature_Type').get("v.value");
        
        if(BusinessNatureType == 'Buyout Loan/Finance'){
            helper.getExistingLiabilitiesAPI(component);
        } else{
            // component.set('v.LiabilitiesSelectedValues',[])
            component.set('v.LiabilitiesOptions',[])
            
        }*/
        
        helper.resetLoanCalculatorValues(component, event, helper);
        helper.checkCalculationButtonEnablement(component, event, helper);//UATNB-211338 
    },
    // handleLoad: function (component, event, helper) {
        

    //     let subscriptionModel = component.find("Subscription_Model").get("v.value");
    //     // let subscriptionModel = acc.Subscription_Model__pc;
    //     console.log('handleLoad  subscriptionModel --- ', subscriptionModel);
    //     if( subscriptionModel != null && subscriptionModel == 'alburaq' ){
    //         component.set('v.caseModel',subscriptionModel);
    //         component.set('v.subject','New Personal Finance Application');
    //         component.set('v.description','New request for a Finance Application');
    //     }else{
    //         component.set('v.caseModel','ila');
    //         component.set('v.subject','New Personal Loan Application');
    //         component.set('v.description','New request for a Loan Application');
    //     }

	// },
    
    handleRequestedLoanTypeChange : function(component, event, helper) {
        var loanProductConfigurationId;
        console.log('handleRequestedLoanTypeChange:');
        var requestedLoanTypes = component.get("v.requestedLoanTypes");
        console.log("requestedLoanTypes: ", requestedLoanTypes);
        var loanType = component.find("cx_ln_Loan_Finance_Type").get("v.value");
        var product = component.find("cx_ln_Product").get("v.value");
        component.set('v.Product',product);
        console.log('handleRequestedLoanTypeChange: ', loanType, product);
        if (loanType && product && requestedLoanTypes) {
            for (var i = 0; i < requestedLoanTypes.length; i++) {
                if (requestedLoanTypes[i].type == loanType && requestedLoanTypes[i].nature == product) {
                    loanProductConfigurationId = requestedLoanTypes[i].loanProductConfigurationId;
                    break;
                }
            }
            console.log('loanProductConfigurationId:', loanProductConfigurationId);
            component.set('v.loanProductConfigurationId',loanProductConfigurationId.toString());
        }
        
        component.set("v.CustomerProductsvalidationMessage", "");
        helper.resetLoanCalculatorValues(component, event, helper);
        if(product =='Secured'){
            // var holdProductField = component.find("holdProductField");
            // holdProductField.reset();
            //Show Requested Hold Product Fields
            helper.getHoldProductsAPI(component, event, helper)
            
        } 
        else if (product =='Unsecured'){
            console.log('product ==> ', product);
            // GetUserApplicationInfo API
            helper.getUserApplicationInfoAPI(component);
        }
        
        
    },
    handleEmploymentStatusChange: function(component, event, helper) {
        var employmentStatusField = component.find("EmploymentStatus");

        if (employmentStatusField.get("v.value") == "Employed") {
            component.set("v.isEmployed", true);
        } else {
            component.set("v.isEmployed", false);
        }
    },
    handleLoanCalculationMethodChange : function(component, event, helper) {
        component.set("v.holdAmount", null);
        var product = component.find("cx_ln_Product").get("v.value");

        if(product =='Secured'){
            var products = component.get("v.products");;
            console.log('result Loan Types products: ', products);
            component.set("v.products", products);
            var fieldMap = [];
            for(var i in products){
                var caseModel = component.get("v.caseModel");
                var productType = products[i].productType == 'FIXED_DEPOSIT' && caseModel == 'alburaq' ? 'WAKALA' : products[i].productType;
                fieldMap.push({productType, id: products[i].id, name: products[i].name, availableBalance: products[i].availableBalance, accountId: (products[i].accountId ? products[i].accountId : products[i].id) });
            }
            
            component.set("v.DisabledCustomerProductsOptions",fieldMap);
            component.set("v.CustomerProductsOptions",[]);
            
        } 

        helper.resetLoanCalculatorValues(component, event, helper);
        helper.checkCalculationButtonEnablement(component, event, helper);

    },
    handleLoanCalculationButton : function(component, event, helper) {
        console.log('handleLoanCalculationButton###');
        // Get Calculation Matrix
        var calculationMatrixResponse = component.get("v.calculationMatrixResponse");
        if (!calculationMatrixResponse) {
            helper.getLoanCalculatorMatrixAPI(component) 
        }
        // helper.resetLoanCalculatorValues(component, event, helper);
        //helper.calculateHoldAmount(component);
        
        //UATNB-211338 : Start
        var BusinessNatureType = component.find('cc_Business_Nature_Type').get("v.value");
        if(BusinessNatureType == 'Buyout Loan/Finance'){
            helper.getExistingLiabilitiesAndCalculateAPI(component, event, helper);
        } else{
            helper.calculatorApiCall(component, event, helper);
        }
        //UATNB-211338 : End
        
    },
    getLoanCalculatorMatrix : function(component, event, helper) {
        console.log('getLoanCalculatorMatrix Controller###');
        
        // Get Calculation Matrix
        var calculationMatrixResponse = component.get("v.calculationMatrixResponse");
        if (!calculationMatrixResponse) {
            helper.getLoanCalculatorMatrixAPI(component) 
        }
        helper.resetLoanCalculatorValues(component, event, helper);
        helper.checkCalculationButtonEnablement(component, event, helper);
    },
    handleRequestedHoldProductChange : function(component, event, helper) {
        
        const selectedRows = event.getParam("selectedRows");
        const selectedHoldProduct = selectedRows[0];
        console.log("selectedHoldProduct: ", selectedHoldProduct);
        if(selectedHoldProduct){
            var caseModel = component.get("v.caseModel");
            var productType = selectedHoldProduct.productType == 'FIXED_DEPOSIT' && caseModel == 'alburaq' ? 'WAKALA' : selectedHoldProduct.productType;
            console.log("selectedHoldProduct productType: ", productType);
            component.find("ccol_Hold_Account").set("v.value", productType );
            component.find("ccol_Hold_Account_IBAN").set("v.value", selectedHoldProduct.accountId );
            if(productType == 'WAKALA' || productType == 'FIXED_DEPOSIT'){
                component.find("ccol_Hold_Amount").set("v.value", selectedHoldProduct.availableBalance );
                component.find("ccol_Hold_Account_Balance").set("v.value", 0 );
            }else {
                //#CH01 : Start
                let ccol_Hold_Amount_val = component.find("ccol_Hold_Amount").get("v.value");
                let availableBalance_val = selectedHoldProduct.availableBalance;
                // Convert to float safely
                let holdAmountNum = parseFloat(ccol_Hold_Amount_val) || 0;
                let balanceNum = parseFloat(availableBalance_val) || 0;

                // Perform calculation
                let result = balanceNum - holdAmountNum;
                component.find("ccol_Hold_Account_Balance").set("v.value", result);
                //#CH01 : End
            }
        }
        component.set("v.CustomerProductsvalidationMessage", "");
        component.set("v.FinalselectedRows", selectedRows);

    },
    handleLiabilitiesRowSelection: function (component, event, helper) {
        const selectedRows = event.getParam("selectedRows");
        const selectedRowIds = selectedRows.map(row => row.Id);
        component.set("v.FinalRequestedLiabilitiesSelectedRows", selectedRows);

        let LiabilitiesOptions = component.get("v.LiabilitiesOptions");
        for (var i = 0; i < LiabilitiesOptions.length; i++) {
            if (selectedRowIds.includes(LiabilitiesOptions[i].Id)) {
                LiabilitiesOptions[i].selected = true;
            }else{
                LiabilitiesOptions[i].selected = false;
            }
        }
        // if(selectedRows.length > 0){
            component.set("v.requestedLiabilitiesvalidationMessage", ""); 
        // }
           
        component.set("v.LiabilitiesOptions", LiabilitiesOptions);
        component.find("cx_ln_Requested_Liabilities").set("v.value", JSON.stringify(LiabilitiesOptions));
        helper.calculateLiabilityTotals(component, event, helper,LiabilitiesOptions);
        
        //toDo : add logic to set the other 2 fields !!
        
        console.log("Selected Liabilities Options => ", JSON.stringify(LiabilitiesOptions));
        helper.resetLoanCalculatorValues(component, event, helper);

        // Onselection
        let loanAmount = (component.find("cx_ln_Loan_Calculation_Method").get("v.value") == 'By Loan/Finance Amount') ? component.find("Loans_Requested_Loan_Finance_Amount_Amount").get("v.value") : component.find("Loans_Requested_Loan_Finance_Amount_Installment").get("v.value");
        if(loanAmount){
            let existingLoans = 0;
            for (var i = 0; i < selectedRows.length; i++) {
                    existingLoans = existingLoans + selectedRows[i].outstanding;
            }
            if (existingLoans > loanAmount) {
                component.set("v.requestedLiabilitiesvalidationMessage", "The sum of all selected liabilies shouldn' be greater than the loan/finance amount, please review the selection.");
            }
        }
        
    },
    
})
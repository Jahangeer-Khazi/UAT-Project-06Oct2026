({
    calculatorApiCall: function (component, event, helper) {
        // Collect form data to pass to Apex
        component.set("v.showSpinner",true);
        var calculatMethod = component.find('calculationMethod').get('v.value');
        var formData = {
            regionName: "Bahrain",//default value
            segment: "Regular",//default value
            nationality: "BH",//default value
            customerId: null,//default value
            typeTxt: component.find('typeTxt').get('v.value'),
            loanSubType: component.find('loanSubType').get('v.value'),
            loanType: component.find('loanType').get('v.value'),
            businessNature: component.find('businessNature').get('v.value'),
            subscription: component.find('subscription').get('v.value'),
            calculationMethod: calculatMethod,
            LoanAmount: (component.find('LoanAmount') != null)?component.find('LoanAmount').get('v.value'):null,
            InstallmentAmount: (component.find('InstallmentAmount') != null)?component.find('InstallmentAmount').get('v.value'):null,
            LoanDuration: component.find('LoanDuration').get('v.value'),
            ExistingLoans: (component.find('ExistingLoans') != null)?component.find('ExistingLoans').get('v.value'):null
            //Firstpaymentdate: component.find('Firstpaymentdate').get('v.value')
        };

        // Call the Apex method with the form data as a map
        var action = component.get("c.calculatorApiCall");
        action.setParams({
            param: formData
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // Handle the response from Apex here (e.g., show the result to the user)
                console.log(result);
                console.log('api response calculation matrix :' +JSON.stringify(result.response));
                if(result.status == 'Success'){
                    // Continue with form submission logic
                    /*let dataRows = [];
                    
                    dataRows.push({ label: 'Interest Rate', value: result.interestRate });
                    dataRows.push({ label: 'Total Interest Amount', value: result.totalInterest });
                    dataRows.push({ label: 'Processing Fees', value: result.processingFee });
                    dataRows.push({ label: 'Vat Processing Fees', value: result.vatProcessingFee });
                    dataRows.push({ label: 'Hold Amount', value: result.holdAmount });
                    dataRows.push({ label: 'First payment date', value: result.firstPaymentDate });
                    dataRows.push({ label: 'Maturity Date', value: result.maturityDate });

                    if(calculatMethod == 'BY_MONTHLY_INSTALLMENT'){
                        dataRows.push({ label: 'Loan Amount', value: result.loanAmount });
                    }
                    else if(calculatMethod == 'BY_LOAN_AMOUNT'){
                        dataRows.push({ label: 'Monthly Installment', value: result.monthlyInstallment });
                    }
                    
                    dataRows.push({ label: 'Total Cash in Hand', value: result.totalCashInHand });
                    dataRows.push({ label: 'Total Repayment Amount', value: result.totalRepayment });
                    component.set("v.data", dataRows);
                    */
                    // Set these values to the component's attributes for the inputs
                    component.set("v.result", {
                        interestRate: result.interestRate,
                        totalInterest: result.totalInterest,
                        processingFee: result.processingFee,
                        vatProcessingFee: result.vatProcessingFee,
                        holdAmount: result.holdAmount,
                        firstPaymentDate: result.firstPaymentDate,
                        maturityDate: result.maturityDate,
                        loanAmount: result.loanAmount,
                        monthlyInstallment: result.monthlyInstallment,
                        totalCashInHand: result.totalCashInHand,
                        totalRepayment: result.totalRepayment
                    });
    
                    component.set("v.showResults", true);
                }else{
                    helper.handleErrors(result.message);
                }
                component.set("v.showSpinner",false);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors.length > 0) {
                    var message = errors[0].message;
                    console.log("Error: " + message);
                    helper.handleErrors(message);
                }
            }
        });

        $A.enqueueAction(action); // Enqueue the Apex action
    },
    handleErrors: function (errors) {
        // Configure error toast
        let toastParams = {
            mode:"sticky",
            title: "Erreur",
            message: errors, // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },
    handleSuccess: function (message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": 'success',
            "message": message
        });
        toastEvent.fire();
    }
})
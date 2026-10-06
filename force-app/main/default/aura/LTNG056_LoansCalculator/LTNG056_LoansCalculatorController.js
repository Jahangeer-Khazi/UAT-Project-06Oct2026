({
	doInit: function (component, event, helper) {
        // Define columns for the datatable
        component.set("v.columns", [
            { label: 'Label', fieldName: 'label', type: 'text' },
            { label: 'Value', fieldName: 'value', type: 'text' }
        ]);
	},
	onClickSubmitAction : function(component, event, helper) {
		console.log("onClickSubmitAction");
        component.set("v.showResults", false);

        var isValid = true;

        // Get all required fields
        var LoanDuration = component.find("LoanDuration");
        var LoanDurationValue = LoanDuration.get("v.value");

        if (!LoanDurationValue || LoanDurationValue === "") {
            LoanDuration.showHelpMessageIfInvalid();
            isValid = false;
        }
		console.log("testttt11");

        // For LoanAmount and InstallmentAmount (depending on calculation method)
        var calculationMethod = component.get("v.calculMeth");
        if (calculationMethod === "BY_LOAN_AMOUNT") {
			console.log("testttt2");
            var loanAmount = component.find("LoanAmount");
            var loanAmountValue = loanAmount.get("v.value");

            if (!loanAmountValue || loanAmountValue === "") {
                loanAmount.showHelpMessageIfInvalid();
                isValid = false;
            }
			console.log("testttt3");
        } else if (calculationMethod === "BY_MONTHLY_INSTALLMENT") {
            var installmentAmount = component.find("InstallmentAmount");
            var installmentAmountValue = installmentAmount.get("v.value");

            if (!installmentAmountValue || installmentAmountValue === "") {
                installmentAmount.showHelpMessageIfInvalid();
                isValid = false;
            }
        }

		console.log("testttt4");

        // If form is valid, proceed, else alert
        if (!isValid) {
            helper.handleErrors("Please fill in all the required fields.");
        } else {
            console.log("Form is valid, proceed with the submission.");
            helper.calculatorApiCall(component, event, helper);
        }
    },
    inputOnChange : function (component, event, helper) {
        console.error('inputOnChange =================>>>>');   
        component.set("v.showResults", false);
    }
})
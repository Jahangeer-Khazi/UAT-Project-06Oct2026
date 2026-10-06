({
    getPrepaidCardRecordType: function (component, event, helper) {
        var action = component.get('c.getPrepaidCardCaseRecordType');
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if (data) {
                    component.set("v.prepaidCardRecordTypeId", data);
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

    getPrepaidCardConfigViaApi: function (component, event, helper) {
        component.set("v.showCardOption", false);
        component.find("RequestedCardType").set("v.value", '');
        var accId = component.get('v.recordId');
        var action = component.get('c.getPrepaidCardConfigViaApi');
        action.setParams({
            accountId: accId,
            caseModel: component.get("v.caseModel")
        });
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                console.error('===>');
                console.error(data);
                component.set("v.cardOption", data);
            } else if (statut === "ERROR") {
                helper.handleErrors(actionResult.getError(), 'Error in Credit Card Options API : ');
            }
            else {
                console.error("AUTRE ERROR");
            }
        });
        $A.enqueueAction(action);
    },

    getAccountDetails: function (component, event, helper) {
        var action = component.get('c.getAccountDetails');
        action.setParams({
            accountId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var accountDetails = response.getReturnValue();
                component.set("v.accountDetails", accountDetails);
                console.log('Account details fetched:', accountDetails);
                
                // Populate OTP fields if they exist (they might not be rendered yet)
                // We'll set values when they become visible later.
                helper.initializeTransactionFields(component, event, helper);
            } else if (state === "ERROR") {
                console.error('Error fetching account details:', response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    handleNotificationChange: function (component, event, helper) {
        var otpNotificationValue = component.find("sendOtpNotification") ? component.find("sendOtpNotification").get("v.value") : '';
        var transactionNotificationValue = component.find("sendTransactionNotification") ? component.find("sendTransactionNotification").get("v.value") : '';
        var accountDetails = component.get("v.accountDetails");

        // Determine visibility
        var showPrimary = (otpNotificationValue === 'PRIMARY_CUSTOMER' || transactionNotificationValue === 'PRIMARY_CUSTOMER');
        var showCardholder = (otpNotificationValue === 'CARD_HOLDER' || transactionNotificationValue === 'CARD_HOLDER');

        // Set visibility attributes (triggers re-render)
        component.set("v.showOtpMobile", showPrimary);
        component.set("v.showOtpEmail", showPrimary);
        component.set("v.showCardholderMobile", showCardholder);
        component.set("v.showCardholderEmail", showCardholder);

        // Wait for re-render, then set values and required states
        setTimeout(function() {
            var otpMobileField = component.find("cardHolderMobile");
            var otpEmailField = component.find("cardHolderEmail");
            var transactionMobileField = component.find("cardHolderMobileNo");
            var transactionEmailField = component.find("cardHolderEmailAddress");

            // --- Primary fields ---
            if (showPrimary && accountDetails) {
                // Populate and disable
                if (otpMobileField && accountDetails.PersonMobilePhone) {
                    let primaryMobile = accountDetails.PersonMobilePhone;
                    primaryMobile = primaryMobile.startsWith("00") ? primaryMobile : "00" + primaryMobile.replace(/^0+/, '');
                    otpMobileField.set("v.value", primaryMobile);
                    otpMobileField.set("v.disabled", true);
                    otpMobileField.set("v.required", false);
                    otpMobileField.set("v.validity", { valid: true });
                }
                if (otpEmailField && accountDetails.PersonEmail) {
                    otpEmailField.set("v.value", accountDetails.PersonEmail);
                    otpEmailField.set("v.disabled", true);
                    otpEmailField.set("v.required", false);
                    otpEmailField.set("v.validity", { valid: true });
                }
            } else {
                // Hide -> clear values
                if (otpMobileField) {
                    otpMobileField.set("v.value", '');
                    otpMobileField.set("v.disabled", true);
                    otpMobileField.set("v.required", false);
                }
                if (otpEmailField) {
                    otpEmailField.set("v.value", '');
                    otpEmailField.set("v.disabled", true);
                    otpEmailField.set("v.required", false);
                }
            }

            // --- Cardholder fields ---
            if (showCardholder) {
                // Enable and clear previous values
                if (transactionMobileField) {
                    transactionMobileField.set("v.value", '');
                    transactionMobileField.set("v.disabled", false);
                    transactionMobileField.set("v.required", true); // always mandatory
                    transactionMobileField.set("v.validity", { valid: true });
                    transactionMobileField.reportValidity();
                }
                if (transactionEmailField) {
                    transactionEmailField.set("v.value", '');
                    transactionEmailField.set("v.disabled", false);
                    // Email optional only in Scenario 4 (OTP=Primary, Transaction=Card Holder)
                    var emailRequired = !(otpNotificationValue === 'PRIMARY_CUSTOMER' && transactionNotificationValue === 'CARD_HOLDER');
                    transactionEmailField.set("v.required", emailRequired);
                    transactionEmailField.set("v.validity", { valid: true });
                    transactionEmailField.reportValidity();
                }
            } else {
                // Hide -> clear values
                if (transactionMobileField) {
                    transactionMobileField.set("v.value", '');
                    transactionMobileField.set("v.disabled", true);
                    transactionMobileField.set("v.required", false);
                }
                if (transactionEmailField) {
                    transactionEmailField.set("v.value", '');
                    transactionEmailField.set("v.disabled", true);
                    transactionEmailField.set("v.required", false);
                }
            }

            // Force UI refresh
            setTimeout(function () {
                if (otpMobileField) otpMobileField.reportValidity();
                if (otpEmailField) otpEmailField.reportValidity();
                if (transactionMobileField) transactionMobileField.reportValidity();
                if (transactionEmailField) transactionEmailField.reportValidity();
            }, 50);
        }, 200); // Increased delay to ensure DOM is ready
    },

    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },

    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },

    handleErrors: function (errors, addError) {
        let toastParams = {
            mode: "sticky",
            title: "Erreur",
            message: errors,
            type: "error"
        };
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = addError + '' + errors[0].message;
        }
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },

    showErrorToast: function (component, event, helper, errorMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "error",
            "title": "Error!",
            "message": errorMessage
        });
        toastEvent.fire();
    },

    handleOtpNotificationChange: function (component, event, helper) {
        helper.handleNotificationChange(component, event, helper);
    },

    initializeTransactionFields: function (component, event, helper) {
        // This is called after account details are loaded.
        // We need to apply the current selection logic.
        helper.handleNotificationChange(component, event, helper);
    },

    showCardHolderMismatchError: function (component, message) {
        this.showErrorToast(component, null, this, message);
    },
})
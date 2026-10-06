({
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
   
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
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
   
    getAccountDetails: function (component, event, helper) {
        var action = component.get('c.getAccountDetails');
        action.setParams({
            accountId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var accountDetails = response.getReturnValue();
                component.set("v.accountDetails", accountDetails);
                console.log('Account details fetched:', accountDetails);
               
                helper.initializeOtpFields(component, event, helper);
                helper.initializeTransactionFields(component, event, helper);
            } else if (state === "ERROR") {
                console.error('Error fetching account details:', response.getError());
            }
        });
        $A.enqueueAction(action);
    },
   
    // ==================== UPDATED METHOD - #CH04 ====================
    handleNotificationChange: function (component, event, helper) {
        var transactionNotificationValue = component.find("sendTransactionNotification").get("v.value");
        var otpNotificationValue = component.find("sendOtpNotification").get("v.value");
        
        if (otpNotificationValue === 'CARD_HOLDER' && transactionNotificationValue === 'CARD_HOLDER') {
            let otpMobile = component.find("cardHolderMobile") ? component.find("cardHolderMobile").get("v.value") : '';
            let otpEmail = component.find("cardHolderEmail") ? component.find("cardHolderEmail").get("v.value") : '';

            let transMobile = component.find("cardHolderMobileNo");
            let transEmail = component.find("cardHolderEmailAddress");

            if (transMobile) transMobile.set("v.value", otpMobile);
            if (transEmail) transEmail.set("v.value", otpEmail);

            var mobileField = component.find("cardHolderMobileNo");
            var emailField = component.find("cardHolderEmailAddress");

            if (mobileField) {
                mobileField.set("v.disabled", true);
                mobileField.set("v.validity", { valid: true });
            }

            if (emailField) {
                emailField.set("v.disabled", true);
                emailField.set("v.validity", { valid: true });
            }

            setTimeout(function () {
                if (mobileField) mobileField.reportValidity();
                if (emailField) emailField.reportValidity();
            }, 100);
        }
        
        // ===================== YOUR ORIGINAL CODE STARTS HERE =====================
        var mobileField = component.find("cardHolderMobileNo");
        var emailField = component.find("cardHolderEmailAddress");
        
        if (transactionNotificationValue === 'PRIMARY_CUSTOMER') {
            if (mobileField) {
                mobileField.set("v.required", false);
                mobileField.set("v.disabled", true);
                mobileField.set("v.validity", { valid: true });
                var accountDetails = component.get("v.accountDetails");
                if (accountDetails && accountDetails.PersonMobilePhone) {
                    let mobilePhone = accountDetails.PersonMobilePhone;
                    mobilePhone = mobilePhone.startsWith("00") ? mobilePhone : "00" + mobilePhone.replace(/^0+/, '');
                    mobileField.set("v.value", mobilePhone);
                } else {
                    mobileField.set("v.value", '');
                }
            }
            if (emailField) {
                emailField.set("v.required", false);
                emailField.set("v.disabled", true);
                emailField.set("v.validity", { valid: true });
                var accountDetails = component.get("v.accountDetails");
                if (accountDetails && accountDetails.PersonEmail) {
                    emailField.set("v.value", accountDetails.PersonEmail);
                } else {
                    emailField.set("v.value", '');
                }
            }
        } else if (transactionNotificationValue === 'CARD_HOLDER' && otpNotificationValue !== 'CARD_HOLDER') {
            if (mobileField) {
                mobileField.set("v.required", true);
                mobileField.set("v.disabled", false);
                mobileField.set("v.validity", { valid: true });
                mobileField.reportValidity();
                var currentMobileValue = mobileField.get("v.value");
                var accountDetails = component.get("v.accountDetails");
                if (accountDetails && accountDetails.PersonMobilePhone && currentMobileValue === accountDetails.PersonMobilePhone) {
                    mobileField.set("v.value", '');
                }
            }
            if (emailField) {
                emailField.set("v.disabled", false);
                emailField.set("v.validity", { valid: true });
                emailField.reportValidity();
                var currentEmailValue = emailField.get("v.value");
                var accountDetails = component.get("v.accountDetails");
                if (accountDetails && accountDetails.PersonEmail && currentEmailValue === accountDetails.PersonEmail) {
                    emailField.set("v.value", '');
                }
            }
        } 
    },
   
    handleOtpNotificationChange: function (component, event, helper) {
        // Call original OTP logic
        var otpNotificationValue = component.find("sendOtpNotification").get("v.value");
        var otpMobileField = component.find("cardHolderMobile");
        var otpEmailField = component.find("cardHolderEmail");
        
        if (otpNotificationValue === 'PRIMARY_CUSTOMER') {
            if (otpMobileField) {
                otpMobileField.set("v.required", false);
                otpMobileField.set("v.disabled", true);
                otpMobileField.set("v.validity", { valid: true });
                var accountDetails = component.get("v.accountDetails");
                if (accountDetails && accountDetails.PersonMobilePhone) {
                    let mobilePhone = accountDetails.PersonMobilePhone;
                    mobilePhone = mobilePhone.startsWith("00") ? mobilePhone : "00" + mobilePhone.replace(/^0+/, '');
                    otpMobileField.set("v.value", mobilePhone);
                } else {
                    otpMobileField.set("v.value", '');
                }
            }
            if (otpEmailField) {
                otpEmailField.set("v.required", false);
                otpEmailField.set("v.disabled", true);
                otpEmailField.set("v.validity", { valid: true });
                var accountDetails = component.get("v.accountDetails");
                if (accountDetails && accountDetails.PersonEmail) {
                    otpEmailField.set("v.value", accountDetails.PersonEmail);
                } else {
                    otpEmailField.set("v.value", '');
                }
            }
        } else if (otpNotificationValue === 'CARD_HOLDER') {
            if (otpMobileField) {
                otpMobileField.set("v.required", true);
                otpMobileField.set("v.disabled", false);
                otpMobileField.set("v.validity", { valid: true });
                otpMobileField.reportValidity();
            }
            if (otpEmailField) {
                otpEmailField.set("v.required", true);
                otpEmailField.set("v.disabled", false);
                otpEmailField.set("v.validity", { valid: true });
                otpEmailField.reportValidity();
            }
        } else {
            if (otpMobileField) {
                otpMobileField.set("v.required", false);
                otpMobileField.set("v.disabled", false);
                otpMobileField.set("v.validity", { valid: true });
                otpMobileField.reportValidity();
            }
            if (otpEmailField) {
                otpEmailField.set("v.required", false);
                otpEmailField.set("v.disabled", false);
                otpEmailField.set("v.validity", { valid: true });
                otpEmailField.reportValidity();
            }
        }
        
        // Re-evaluate transaction fields visibility after OTP change
        helper.handleNotificationChange(component, event, helper);
    },
   
    initializeOtpFields: function (component, event, helper) {
        var otpNotificationField = component.find("sendOtpNotification");
        if (otpNotificationField) {
            helper.handleOtpNotificationChange(component, event, helper);
        }
    },
   
    initializeTransactionFields: function (component, event, helper) {
        var transactionNotificationField = component.find("sendTransactionNotification");
        if (transactionNotificationField) {
            helper.handleNotificationChange(component, event, helper);
        }
    },

    // Optional: If you want to keep toast logic centralized
    showCardHolderMismatchError: function (component, message) {
        this.showErrorToast(component, null, this, message);
    },
})
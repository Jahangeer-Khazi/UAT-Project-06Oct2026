({
    handleOnload: function (component, event, helper) {
        console.log("on load form !");
    },

    handleOnSubmit: function (component, event, helper) {
        event.preventDefault();

        let PrimaryCard = component.find("PrimaryCard");
        let phoneCmp = component.find("cardHolderMobile");
        let phoneValue = phoneCmp ? phoneCmp.get("v.value") : '';
        let emailCmp = component.find("cardHolderEmail");
        let emailValue = emailCmp ? emailCmp.get("v.value") : '';
        let errorMessage = "";

        let regex = /^00\d*$/;

        // Get notification values
        let otpNotificationValue = component.find("sendOtpNotification") ? component.find("sendOtpNotification").get("v.value") : '';
        let transactionNotificationValue = component.find("sendTransactionNotification") ? component.find("sendTransactionNotification").get("v.value") : '';

        if (PrimaryCard.get("v.value")) {
            console.log('submit the form');

            // #CH04 : Copy OTP values to Transaction fields when both are CARD_HOLDER
            if (otpNotificationValue === 'CARD_HOLDER' && transactionNotificationValue === 'CARD_HOLDER') {
                let otpMobile = component.find("cardHolderMobile") ? component.find("cardHolderMobile").get("v.value") : '';
                let otpEmail = component.find("cardHolderEmail") ? component.find("cardHolderEmail").get("v.value") : '';

                let transMobile = component.find("cardHolderMobileNo");
                let transEmail = component.find("cardHolderEmailAddress");

                if (transMobile) transMobile.set("v.value", otpMobile);
                if (transEmail) transEmail.set("v.value", otpEmail);
            }

            // ==================== ORIGINAL VALIDATION LOGIC (UNCHANGED) ====================
            let isMobileRequired = (otpNotificationValue === 'CARD_HOLDER' || transactionNotificationValue === 'CARD_HOLDER');
            let isEmailRequired = (otpNotificationValue === 'CARD_HOLDER');

            if (isMobileRequired) {
                if (!phoneValue) {
                    errorMessage = "Phone number is required when sending notifications to Card Holder.";
                    helper.showErrorToast(component, event, helper, errorMessage);
                    return;
                }

                if (!regex.test(phoneValue)) {
                    errorMessage = "Phone number must start with '00'.";
                    helper.showErrorToast(component, event, helper, errorMessage);
                    return;
                }
            } else if (otpNotificationValue === 'PRIMARY_CUSTOMER' || transactionNotificationValue === 'PRIMARY_CUSTOMER') {
                if (!phoneValue) {
                    errorMessage = "Account mobile number is missing. Please update the account record.";
                    helper.showErrorToast(component, event, helper, errorMessage);
                    return;
                }
            }

            if (isEmailRequired) {
                if (!emailValue) {
                    errorMessage = "Email address is required when sending OTP notifications to Card Holder.";
                    helper.showErrorToast(component, event, helper, errorMessage);
                    return;
                }
            } else if (otpNotificationValue === 'PRIMARY_CUSTOMER') {
                if (!emailValue) {
                    errorMessage = "Account email is missing. Please update the account record.";
                    helper.showErrorToast(component, event, helper, errorMessage);
                    return;
                }
            }

            if (phoneValue && !regex.test(phoneValue)) {
                errorMessage = "Phone number must start with '00'.";
                helper.showErrorToast(component, event, helper, errorMessage);
                return;
            }

            component.find('form').submit();
            helper.showSpinner(component);

        } else {
            console.error("Please fill the primary card");
            helper.showErrorToast(component, event, helper, "Please select a primary card.");
        }
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

    handleLoad: function (component, event, helper) {
        console.log('handleLoad cmp---');
        let subscriptionModel = component.find("Subscription_Model").get("v.value");
        if (subscriptionModel != null && subscriptionModel == 'alburaq') {
            component.set('v.caseModel', subscriptionModel);
        } else {
            component.set('v.caseModel', 'ila');
        }
        component.set('v.regionFlag', component.find("regionFlag").get("v.value"));

        helper.getAccountDetails(component, event, helper);
    },

    handleTransactionNotificationChange: function (component, event, helper) {
        helper.handleNotificationChange(component, event, helper);
    },

    handleOtpNotificationChange: function (component, event, helper) {
        helper.handleOtpNotificationChange(component, event, helper);
    },

    validateCardHolderNotMatchingPrimary: function (component, event, helper) {
    var accountDetails = component.get("v.accountDetails");
    if (!accountDetails) return;

    var source = event.getSource();
    var fieldName = source.getLocalId();
    
    // Important: Use setTimeout to let the pasted value settle in the field
    setTimeout(function() {
        var inputValue = source.get("v.value") || '';
        var errorMsg = "";

        // ==================== MOBILE VALIDATION ====================
        if ((fieldName === "cardHolderMobile" || fieldName === "cardHolderMobileNo") && inputValue) {
            var primaryMobile = accountDetails.PersonMobilePhone || '';
            
            var normalizedInput = inputValue.replace(/^00/, '').trim();
            var normalizedPrimary = primaryMobile.replace(/^00/, '').trim();

            if (normalizedInput === normalizedPrimary && normalizedInput !== '') {
                errorMsg = "Phone number cannot be the same as the primary customer mobile number.";
            }
        }
        // ==================== EMAIL VALIDATION ====================
        else if ((fieldName === "cardHolderEmail" || fieldName === "cardHolderEmailAddress") && inputValue) {
            var primaryEmail = accountDetails.PersonEmail || '';
            if (primaryEmail && inputValue.toLowerCase().trim() === primaryEmail.toLowerCase().trim()) {
                errorMsg = "Email Address cannot be the same as the primary customer email address.";
            }
        }

        if (errorMsg) {
            helper.showErrorToast(component, event, helper, errorMsg);
            
            // Clear the invalid value
            source.set("v.value", "");
            
            // Force validity check after clearing
            setTimeout(function() {
                source.reportValidity();
            }, 150);
        }
    }, 50);   // Small delay to capture pasted value
},
})
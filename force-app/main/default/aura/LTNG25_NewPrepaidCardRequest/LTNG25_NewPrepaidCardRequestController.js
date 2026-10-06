({
    doInit: function (component, event, helper) {
        helper.getPrepaidCardRecordType(component, event, helper);
        helper.getPrepaidCardConfigViaApi(component, event, helper);
        helper.getAccountDetails(component, event, helper);
    },
    handleOnload: function (component, event, helper) {
        console.log("on load form !");
    },
    handleOnSubmit: function (component, event, helper) {
        event.preventDefault();
        var relationshipVal = component.get("v.relationshipVal");
        let RequestedCardType = component.find("RequestedCardType");
        let cardTypeInput = component.find("cardTypeInput");
        let errorMessage = "";
        let regex = /^00\d*$/;
        let otpNotificationValue = component.find("sendOtpNotification") ? component.find("sendOtpNotification").get("v.value") : '';
        let transactionNotificationValue = component.find("sendTransactionNotification") ? component.find("sendTransactionNotification").get("v.value") : '';

        if (RequestedCardType.get("v.value") != '' && RequestedCardType.get("v.value") != null
            && cardTypeInput.get("v.value") != '' && cardTypeInput.get("v.value") != null) {
            console.log('submit the form');
            
            var showOtpMobile = component.get("v.showOtpMobile");
            var showOtpEmail = component.get("v.showOtpEmail");
            var showCardholderMobile = component.get("v.showCardholderMobile");
            var showCardholderEmail = component.get("v.showCardholderEmail");
            
            // Validate OTP fields if visible
            if (showOtpMobile) {
                let otpMobileCmp = component.find("cardHolderMobile");
                let otpMobileValue = otpMobileCmp ? otpMobileCmp.get("v.value") : '';
                if (!otpMobileValue) {
                    errorMessage = "Primary Mobile number is required.";
                    helper.showErrorToast(component, event, helper, errorMessage);
                    return;
                }
            }
            if (showOtpEmail) {
                let otpEmailCmp = component.find("cardHolderEmail");
                let otpEmailValue = otpEmailCmp ? otpEmailCmp.get("v.value") : '';
                if (!otpEmailValue) {
                    errorMessage = "Primary Email address is required.";
                    helper.showErrorToast(component, event, helper, errorMessage);
                    return;
                }
            }
            
            // Validate Card Holder fields if visible
            if (showCardholderMobile) {
                let transactionPhoneCmp = component.find("cardHolderMobileNo");
                let transactionPhoneValue = transactionPhoneCmp ? transactionPhoneCmp.get("v.value") : '';
                if (!transactionPhoneValue) {
                    errorMessage = "Card Holder Mobile number is required.";
                    helper.showErrorToast(component, event, helper, errorMessage);
                    return;
                }
                if (!regex.test(transactionPhoneValue)) {
                    errorMessage = "Card Holder Mobile number must start with '00'.";
                    helper.showErrorToast(component, event, helper, errorMessage);
                    return;
                }
            }
            
            if (showCardholderEmail) {
                let transactionEmailCmp = component.find("cardHolderEmailAddress");
                let transactionEmailValue = transactionEmailCmp ? transactionEmailCmp.get("v.value") : '';
                let isEmailRequired = transactionEmailCmp ? transactionEmailCmp.get("v.required") : false;
                if (isEmailRequired && !transactionEmailValue) {
                    errorMessage = "Card Holder Email address is required.";
                    helper.showErrorToast(component, event, helper, errorMessage);
                    return;
                }
            }
            
            component.find('form').submit();
            helper.showSpinner(component);
        } else {
            console.error("please fill the request Card Type");
            helper.handleErrors('please fill in all required fields', '');
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
    caseModelIsChanged: function (component, event, helper) {
        console.log('is changed caseModelIsChanged');
        component.set("v.showCardOption", false);
        component.set("v.cardOption", null);
        component.set("v.prepaidFees", null);
        helper.getPrepaidCardConfigViaApi(component, event, helper);
    },
    cardDesignIsChanged: function (component, event, helper) {
        console.log('is changed cardDesignIsChanged');
        component.set("v.cardType", null);
        component.set("v.prepaidFees", null);
        var cardDesign = component.get("v.cardDesign");
        var dataConfig = component.get("v.cardOption");
        console.log('dataConfig --->', JSON.stringify(dataConfig));
        console.log('cardDesign --->', cardDesign);
        if (!cardDesign || !dataConfig) {
            console.log('Waiting for required data...');
            return;
        }
        if (!dataConfig.cardTypeConfigurations ||
            !Array.isArray(dataConfig.cardTypeConfigurations) ||
            dataConfig.cardTypeConfigurations.length === 0) {
            console.log('No card type configurations available');
            return;
        }
        var cardTypes = dataConfig.cardTypeConfigurations;
        var foundMatch = false;
        for (var i = 0; i < cardTypes.length; i++) {
            var cardTypeObj = cardTypes[i];
            if (cardDesign === cardTypeObj.cardColor) {
                component.set("v.cardType", cardTypeObj.cardType);
                component.set("v.prepaidFees", cardTypeObj.prepaidFees);
                foundMatch = true;
                console.log('Match found: ', cardTypeObj.cardType);
                break;
            }
        }
        if (!foundMatch) {
            console.log('No matching card type found for design: ', cardDesign);
        }
    },
    handleLoad: function (component, event, helper) {
        console.log('handleLoad cmp---');
        let subscriptionModelField = component.find("Subscription_Model");
        if (subscriptionModelField) {
            let subscriptionModel = subscriptionModelField.get("v.value");
            if (subscriptionModel != null && subscriptionModel == 'alburaq') {
                component.set('v.caseModel', subscriptionModel);
            } else {
                component.set('v.caseModel', 'ila');
            }
        } else {
            console.warn('Subscription_Model field not found yet');
            component.set('v.caseModel', 'ila');
        }
    },
    requestCardTypeChange: function (component, event, helper) {
        let RequestedCardType = component.find("RequestedCardType").get("v.value");
        if (RequestedCardType != null && RequestedCardType != '') {
            component.set("v.showCardOption", true);
        } else {
            component.set("v.showCardOption", false);
        }
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
       
        setTimeout(function() {
            var inputValue = source.get("v.value") || '';
            var errorMsg = "";
            if (fieldName === "cardHolderMobileNo" && inputValue) {
                var primaryMobile = accountDetails.PersonMobilePhone || '';
                var normalizedInput = inputValue.replace(/^00/, '').trim();
                var normalizedPrimary = primaryMobile.replace(/^00/, '').trim();
                if (normalizedInput === normalizedPrimary && normalizedInput !== '') {
                    errorMsg = "Phone number cannot be the same as the primary customer mobile number.";
                }
            }
            else if (fieldName === "cardHolderEmailAddress" && inputValue) {
                var primaryEmail = accountDetails.PersonEmail || '';
                if (primaryEmail && inputValue.toLowerCase().trim() === primaryEmail.toLowerCase().trim()) {
                    errorMsg = "Email Address cannot be the same as the primary customer email address.";
                }
            }
            if (errorMsg) {
                helper.showErrorToast(component, event, helper, errorMsg);
                source.set("v.value", "");
                setTimeout(function() {
                    source.reportValidity();
                }, 150);
            }
        }, 50);
    },
})
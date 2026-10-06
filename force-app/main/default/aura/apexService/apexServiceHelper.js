({
    doRequest: function(component, action, params, successCallback, showLoading) {
        var helper = this;
        if (params) {
            action.setParams(params);
        }
        if (showLoading) {
            component.set('v.isLoading', true);
        }
        action.setCallback(this, function(response) {
            component.set('v.isLoading', false);
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.handleSuccess(response, successCallback);
            } else {
                console.log(action);
                helper.handleGenericError(response);
            }
        });
        $A.enqueueAction(action);
    },
    handleSuccess: function(response, successCallback) {
        var helper = this;
        if (helper.isApiError(response)) {
            helper.handleApiError(response);
        } else {
            successCallback(response);
        }
    },
    handleApiError : function(response) {
        var helper = this;
        var result = response.getReturnValue();
        if (!$A.util.isEmpty(result.errorData)) {
            var msg = JSON.stringify(result.errorData);
            helper.showErrorToastCustom(msg);
        } else {
            helper.showErrorToast();
        }
    },
    isApiError : function(response) {
        var result = response.getReturnValue();
        return false === result.isSuccess;
    },
    handleGenericError : function(response) {
        var helper = this;
        if (response.getError() && response.getError().length > 0) {
            var errObj = response.getError()[0];
            var msg = errObj.message;
            if (undefined === msg) {
                if (errObj.pageErrors.length > 0) {
                    msg = errObj.pageErrors[0].message;
                } else if (false === $A.util.isEmpty(errObj.fieldErrors)) {
                    //msg = JSON.stringify(errObj.fieldErrors);
                    msg = errObj.fieldErrors;
                }
            }
            console.log(msg);
            if (msg.indexOf('ERR:') !== -1) {
                helper.showErrorToastCustom(msg.replace('ERR:', '').trim());
                return;
            }
            if (msg.indexOf('ERR_PLACES') !== -1) {
                helper.showErrorToastCustom(msg.replace('ERR_PLACES', '').trim());
            } else {
                helper.showErrorToastCustom(msg);
            }
        }
        helper.showErrorToast();
    },
    showErrorToastCustom: function (msg) {
        // if there are curly brackets in the message then they have to be removed
        // if curly brackets are present in the text then SFDC displayes empty message
        var msgClean = msg.replace(new RegExp('{', 'g'), '').replace(new RegExp('}', 'g'), '');
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                "title": "Error!",
                "message": msgClean,
                "type": "error",
                "mode": "sticky"
            });
            toastEvent.fire();
        } else {
            alert(msg);
        }
    },
    showErrorToast: function () {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                "title": "Error!",
                "message": "Something has gone wrong.",
                "type": "error"
            });
            toastEvent.fire();
        } else {
            alert('Something has gone wrong.');
        }
    }
})
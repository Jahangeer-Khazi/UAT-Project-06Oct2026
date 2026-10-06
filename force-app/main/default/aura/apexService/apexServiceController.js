({
	doRequest : function(component, event, helper) {
		var params = event.getParams('arguments');
        if (params) {
            var action = params.arguments.action;
            var successCallback = params.arguments.successCallback;
            var showLoading = params.arguments.showLoading;
            var params = params.arguments.params;
            helper.doRequest(component, action, params, successCallback, showLoading);
        }
	},
    doShowSpinner : function(component, event, helper) {
     	component.set('v.isLoading', true);
    },
    showSuccess: function(component, event, helper) {
        var message = event.getParams('arguments').arguments.message;
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                "title": "Success!",
                "message": message,
                "type": "success"
            });
            toastEvent.fire();
        } else {
            alert(message);
        }
    },
    showWarning: function(component, event, helper) {
        var message = event.getParams('arguments').arguments.message;
        var toastEvent = $A.get("e.force:showToast");
        var mode = event.getParams('arguments').arguments.mode;
        if (toastEvent) {
            toastEvent.setParams({
                "title": "Warning!",
                "message": message,
                "type": "warning",
                "mode": mode
            });
            toastEvent.fire();
        } else {
            alert(message);
        }
    },

    showError: function(component, event, helper) {
        var message = event.getParams('arguments').arguments.message;
        var toastEvent = $A.get("e.force:showToast");
        var mode = event.getParams('arguments').arguments.mode;
        if (toastEvent) {
            toastEvent.setParams({
                "title": "Error!",
                "message": message,
                "type": "error",
                "mode": mode
            });
            toastEvent.fire();
        } else {
            alert(message);
        }
    }
})
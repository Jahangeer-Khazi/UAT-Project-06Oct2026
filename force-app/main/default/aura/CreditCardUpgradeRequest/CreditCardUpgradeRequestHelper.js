/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:15-08-2024
 * 		Change History: 
 *			  
 */
({
	showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    handleSuccess : function(msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
             mode: "sticky",
            "type":"success",
            "title": "Success!",
            "message": msg
        });
        toastEvent.fire();
    },
    handleErrors: function (errors) {
        let toastParams = {
			mode: "sticky",
			title: "Error",
			message: errors, // Default error message
			type: "error"
		};
		if(errors && Array.isArray(errors) && errors.length > 0) {
			toastParams.message = errors[0].message;
		}
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams(toastParams);
		toastEvent.fire();
	},
})
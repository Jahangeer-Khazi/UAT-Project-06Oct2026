/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:07-11-2021
 * 		Change History: 
 * 					#CH01# #Jahangeer Mohammed# #27-07-2026 Added Logic for automated Credit Card Upgrade Cases(NBA-17560)
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
    //CH01: Start
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
    //CH01: END
})
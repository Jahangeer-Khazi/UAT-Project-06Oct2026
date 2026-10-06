/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:02-07-2025
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
    }
})
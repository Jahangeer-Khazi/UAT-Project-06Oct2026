/**
Change History :
*        
          #CH01 :  #Jahangeer Mohammed# #16-12-2024# Added Logic for Co-brand Credit Cards(NBA-12524)

*/
({
	showSpinner: function (component, event, helper) {
                console.log('*****************showSpinner***********');
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component, event, helper) {
                console.log('*****************hideSpinner***********');

        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    //CH01: Start
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
    //CH01: END
    handleErrors: function (errors) {
		// Configure error toast
		let toastParams = {
			mode: "sticky",
			title: "Error",
			message: errors, // Default error message
			type: "error"
		};
		// Fire error toast
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams(toastParams);
		toastEvent.fire();
	},
})
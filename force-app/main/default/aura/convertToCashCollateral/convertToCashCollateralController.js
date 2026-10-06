/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:
 * 		Change History: 
 *			  
*/
({
	init : function(component, event, helper) {
       helper.loadCurrentCase(component);
      
	},
     
    handleOnSubmit: function(component, event, helper) {
        helper.showSpinner(component);
    },
    handleOnSuccess : function(component, event, helper) {
        helper.hideSpinner(component);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"success",
            "title": "Success!",
            "message": "Case has been created successfully."
        });
        toastEvent.fire();
        component.set("v.enableForm",false);
   },
    
})
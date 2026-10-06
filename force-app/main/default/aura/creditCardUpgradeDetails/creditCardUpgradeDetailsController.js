({
    init : function(component, event, helper) {
       
        console.log('--->Default Load CustomerId in Upgrade Cmp--> ', component.get('v.customerId'));
        console.log('--->Default Load CardId in Upgrade Cmp -->  ', component.get('v.cardId'));
        console.log('--->Default Load AccountId in Upgrade Cmp --> ', component.get('v.account.PersonEmail'));
      
        helper.loadCardDetails(component, component.get('v.customerId'), component.get('v.cardId'), component.get('v.account'));
	},

    load : function(component, event, helper) {
        
        console.log('---> onLoad CustomerId in Upgrade Cmp --> ', component.get('v.customerId'));
        console.log('---> onLoad CardId in Upgrade Cmp --> ', component.get('v.cardId'));
        console.log('---> onLoad AccountId in Upgrade Cmp --> ', component.get('v.account'));
        component.set('v.isEnableButton',false);
        helper.loadCardDetails(component, component.get('v.customerId'), component.get('v.cardId'), component.get('v.account'));
	},
    handleOnSubmit: function(component, event, helper) {
        helper.showSpinner(component, event, helper);
        //helper.saveCase(component, event, helper);
    },
    handleOnSuccess : function(component, event, helper) {
        helper.hideSpinner(component);
        console.log("Case have been Updated successfully.");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"success",
            "title": "Success!",
            "message": "Case details has been updated successfully !!!."
        });
        toastEvent.fire();
        component.set('v.isEnableButton',false);
   },
})
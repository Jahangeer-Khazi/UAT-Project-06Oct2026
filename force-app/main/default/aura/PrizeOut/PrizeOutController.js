({
    doInit: function (component, event, helper) {
       
        helper.showSpinner(component);
        helper.doInit(component, event, helper);
        //helper.hideSpinner(component);
    },
    handleOnload: function (component, event, helper) {
        helper.showSpinner(component);
        var accId=component.get('v.recordId');
       // helper.handlecustomerName(component, event, helper, accId);
        console.log("on load form !");
        helper.hideSpinner(component);
    },
    handleOnSubmit: function (component, event, helper) {
        console.log('handleOnSubmit');
        event.preventDefault();
        console.error(component.get('v.recordTypeId'));
        component.find('form').submit();
        helper.showSpinner(component);
    },
    handleOnSuccess: function (component, event, helper) {
         console.log('handleOnSuccess');
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
})
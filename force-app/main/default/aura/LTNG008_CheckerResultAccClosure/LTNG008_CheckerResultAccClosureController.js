({
    handleOnSubmit: function (component, event, helper) {
        console.log('handleOnSubmit');
        event.preventDefault();
        helper.updateCheckerSection(component,event, helper);
    },
    onCancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})
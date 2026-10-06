({
    init: function(component, event, helper) {
        const pageReference = component.get("v.pageReference");
        const state = pageReference.state;
        
        // Handle URL parameters
        if (state && state.c__currentDrawId) {
            component.set("v.currentDrawId", state.c__currentDrawId);
        }
        if (state && state.c__currentPrizeType) {
            component.set("v.currentPrizeType", state.c__currentPrizeType);
        }
        if (state && state.c__currentDrawName) {
            component.set("v.currentDrawName", state.c__currentDrawName);
        }
    }
})
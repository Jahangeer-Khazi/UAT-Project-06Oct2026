({
    doInit : function(component, event, helper) {
        helper.init(component, event, helper);
    },
	doRequestDocs : function(component, event, helper) {
        // helper.requestDocs(component, event, helper);
        helper.requestOnBoarding(component);
	}
})
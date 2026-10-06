({
	doInit : function(component, event, helper) {
		var sObjectName = component.get("v.sObjectName");
        var recordId = component.get("v.recordId");
        
        helper.doInitHelper(component, event,helper,sObjectName,recordId);
	}
})
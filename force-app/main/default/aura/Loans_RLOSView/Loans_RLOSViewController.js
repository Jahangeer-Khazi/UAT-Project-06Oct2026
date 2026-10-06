({
	doInit : function(component, event, helper) {
		
    },
	handleLoad: function (component, event, helper) {
        
        
		console.log("handleLoad function " );
		var recordId = component.get("v.recordId");
        console.log("Record ID: " + recordId);
        
		helper.getPendingLoan(component);


	}
})
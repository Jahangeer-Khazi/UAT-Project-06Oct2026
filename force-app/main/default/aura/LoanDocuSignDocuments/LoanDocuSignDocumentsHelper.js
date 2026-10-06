({
	loadDocumentdata : function(component, event, helper) {
		
        var action = component.get('c.getDocumentList');
        action.setParams(
        {
			caseId : component.get("v.recordId"),
            fetchAllDocument : false
        });
        
        action.setCallback(this, function (actionResult) {
            
            
            var status = actionResult.getState();
            let data = actionResult.getReturnValue();
            
            if(data.length == 0){
                component.set("v.isNoRecordFound",true);
            }
            
            console.log("document list ",data);
            console.log("document status ",status);
            component.set("v.data",data);
        });
        
        $A.enqueueAction(action);
	}
})
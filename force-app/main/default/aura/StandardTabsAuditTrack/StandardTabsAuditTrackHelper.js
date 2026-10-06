({
    loadDataInAuditObject : function(component,recordId,tabName) {
        var action = component.get("c.createAuditRecord");
        action.setParams({"recordId":recordId,
                          "tabName":tabName});
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('Fetched Audit Id:',result);
            }
            
        });
        $A.enqueueAction(action);
	},
    
    loadContentDataInAuditObject : function(component,recordId,tabName) {
        console.log('Load Content Data in Audit Object');
        var action = component.get("c.createAuditRecordForContent");
        action.setParams({"recordId":recordId,
                          "tabName":tabName});
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('Fetched Audit Id:',result);
            }
            
        });
        $A.enqueueAction(action);
	},
    
    loadCaseDataInAuditObject : function(component,recordId,tabName) {
        console.log('Load Case Data in Audit Object');
        var action = component.get("c.createAuditRecordForCase");
        action.setParams({"recordId":recordId,
                          "tabName":tabName});
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('Fetched Audit Id:',result);
            }
            
        });
        $A.enqueueAction(action);
	},
	
	
})
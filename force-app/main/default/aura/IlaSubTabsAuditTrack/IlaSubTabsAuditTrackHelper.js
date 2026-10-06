({
    loadDataInAuditObject : function(component,accId,subTabName) {
        var action = component.get("c.createAuditRecordSubTabs");
        console.log('Acct Id in helper:',accId);
        action.setParams({
            accId:accId,
            subTabName:subTabName
        });
        
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
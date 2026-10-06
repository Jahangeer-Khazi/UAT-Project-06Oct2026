({
    loadRetrieveCustomerRestrictions : function(component,recordId,pageType) {
        var action = component.get("c.loadRetrieveCustomerRestrictions");
        console.log('loadRetrieveCustomerRestrictions in helper:',recordId);
        action.setParams({
            recordId:recordId,
            pageType:pageType
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('Fetched loadRetrieveCustomerRestrictions result :',result);
				component.set("v.errorMsg",result);
            }
        });
        $A.enqueueAction(action);
	},
	
})
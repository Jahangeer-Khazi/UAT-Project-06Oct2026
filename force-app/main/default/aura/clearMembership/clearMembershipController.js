({
	doInit : function(component, event, helper) {
		
	},
    clearMembership : function(component, event, helper){
        helper.showSpinner(component);
        console.log('Clear Membership Button Clicked');
        var acctId = component.get("v.record.AccountId");
        console.log('Account Id:',acctId);
       
        var action = component.get("c.clearMembershipNumber");
        action.setParams({
            accountId : acctId
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log('Membership cleared successfully');
                helper.handleSuccessMessage(component,event,helper);
                //Refresh the record
                component.find("recordLoader").reloadRecord();
            }else{
                console.error('Error:', response.getError());
            }
        });
        
        $A.enqueueAction(action);
    }
})
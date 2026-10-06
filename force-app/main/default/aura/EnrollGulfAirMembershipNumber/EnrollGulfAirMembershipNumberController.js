({
	enrollMembershipId : function(component, event, helper) {
		console.log('Enroll for Membership Id');
        helper.enrollMembership(component,event,helper);
	},
    
    manageMembershipId : function(component, event, helper) {
		console.log('Manage for Membership Id');
        helper.manageMembership(component,event,helper);
	},
    handleRecordUpdated : function(component, event, helper){
        console.log('Handler Updated Record');
        var eventParams = event.getParams();
        if(eventParams.changeType === "CHANGED") {
            var changedFields = eventParams.changedFields;
            console.log('Fields that are changed: ' + JSON.stringify(changedFields));
            if(changedFields && changedFields['Relationship_Termination_Button_Checks__c']){
                var oldValue = changedFields['Relationship_Termination_Button_Checks__c'].oldValue;
                var newValue = changedFields['Relationship_Termination_Button_Checks__c'].value;
                if(oldValue != newValue && newValue == true){
                    console.log('Value Changes to true');
                    component.set("v.enableButton", false);
                }
                else if(oldValue != newValue && newValue == false){
                    console.log('Value Changes to false');
                    component.set("v.enableButton", true);
                }
            }
        }
        else if(eventParams.changeType === "LOADED"){
            console.log('Record loaded:');
        } 
        else if(eventParams.changeType === "REMOVED"){
            console.log('Record removed');
        } 
        else if(eventParams.changeType === "ERROR"){
            console.log('Error occurred:');
        }
        
    },
    
})
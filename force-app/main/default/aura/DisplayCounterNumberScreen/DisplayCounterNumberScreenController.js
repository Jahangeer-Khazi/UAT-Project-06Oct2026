({
	doInit : function(component, event, helper) {
        console.log('Display Monitor Component Loaded')
		
	},
    
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "CHANGED") {
            // Handle record change
            console.log('Record updated:');
            var changedFields = eventParams.changedFields;
            console.log('Fields that are changed: ' + JSON.stringify(changedFields));
            if(changedFields && changedFields['Counter_Number__c']) {
                // Handle change specific to 'Counter_Number__c' field
                var oldValue = changedFields['Counter_Number__c'].oldValue;
                var newValue = changedFields['Counter_Number__c'].value;
                console.log('Field "Counter_Number__c" updated from ' + oldValue + ' to ' + newValue);
                if(oldValue != newValue){
                    var caseId = component.get('v.recordId');
                    console.log('Case Id in Handle Record:',caseId);
                	helper.redirectToVF(component,caseId);
                }
                
            }
        } else if(eventParams.changeType === "LOADED") {
            // Handle record load
            console.log('Record loaded:');
        } else if(eventParams.changeType === "REMOVED") {
            // Handle record removal
            console.log('Record removed');
        } else if(eventParams.changeType === "ERROR") {
            // Handle error while loading or updating record
            console.log('Error occurred:');
        }
    }
})
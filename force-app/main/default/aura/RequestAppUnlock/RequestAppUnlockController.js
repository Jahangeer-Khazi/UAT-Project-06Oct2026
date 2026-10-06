({
	handleClick : function(component, event, helper) {
		var emailNumberOfDays=component.get("v.caseRecord.Last_Date_Email_Changed__c");
        var mobileNumberOfDays=component.get("v.caseRecord.Last_Date_Mobile_Changed__c");
        /*if(Last_Date_Mobile_Changed__c>3 || mobileNumberOfDays>3)
        {
            
        }*/
        var csId=component.get('v.recordId');
        console.log('csId==>'+csId);
        
            if (confirm('Proceed with App Unlock')) {
            helper.handleloadCardDetails(component, event, helper, csId);

        }
	}
})
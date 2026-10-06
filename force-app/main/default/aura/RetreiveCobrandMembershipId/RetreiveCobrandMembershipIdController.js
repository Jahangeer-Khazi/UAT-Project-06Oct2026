({
	handleOnload: function(component, event, helper) {
        let embossLine4 = component.get("v.caseRecord.cc_Embossing_Line_4__c");
        console.log('MembershipId onload:',embossLine4);
        component.set("v.embossingLine4",embossLine4);
    },
    toggleEditForm: function(component, event, helper) {
        const isFormVisible = component.get("v.showEditForm");
        component.set("v.showEditForm", !isFormVisible);
        if(!isFormVisible){
            component.set('v.isButtonDisabled',true);
        }else{
           component.set('v.isButtonDisabled',false); 
        }
        //component.set('v.enableButton',false);
    },
    handleEmbossChange: function (component, event, helper) {
        // Get the value of the Embossing Line 4 field
        var inputValue = event.getSource().get("v.value");
        component.set("v.embossingLine4", inputValue); // Update the embossingLine4 attribute
        console.log('Emboss Line 4 value:',inputValue);
    },
    handleOnSubmit: function(component, event, helper) {
        event.preventDefault();
        let membershipId = component.get("v.embossingLine4");
        console.log('Member Id in submit:',membershipId);
        helper.fetchMembershipId(component, event, helper);
    },
})
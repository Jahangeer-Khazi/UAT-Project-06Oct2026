({
	doInit: function (component, event, helper) {
         helper.doInit(component, event, helper);
    },
    handleOnload: function (component, event, helper) {
        console.log("on load form !");
    },
    handleOnSubmit: function (component, event, helper) {
        console.log('handleOnSubmit');
        var fields = event.getParam('fields');
        try{
            event.preventDefault();
            if(component.get("v.type") == '' || component.get("v.type") == null  || component.get("v.caseModel") == null || 
               component.get("v.caseModel") == '' || component.get("v.originOption") == null || component.get("v.originOption") == '' || 
              (component.get("v.type") == 'Marketing Preference' && 
             (component.get("v.selectedSubType") == null || component.get("v.selectedSubType") == ''))){
                helper.handleErrors('Please fill in all the required fields');
            }else{
                
                helper.showSpinner(component);
                if(component.get("v.type") == 'Marketing Preference') {
                    fields.Sub_Type__c = component.get("v.selectedSubType");
                }
                component.find('form').submit(fields);
            }
            //component.find('Restriction_Reason_Reason').submit();
        } catch (error) {
            console.log('Error ',error);            
        }


    },

    handleOnSuccess: function (component, event, helper) {
        helper.hideSpinner(component);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Success!",
            "message": "Case has been created successfully."
        });
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.getParam("response").id,
            "slideDevName": "detail"
        });
        navEvt.fire();
     //   helper.closeCase(component, event, helper,event.getParam("response").id);
    },
    handleOnError: function (component, event, helper) {
        helper.hideSpinner(component);
    },
    onCancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleLoad: function (component, event, helper) { 
        console.log('handleLoad  cmp---');
        
        
        let subscriptionModel = component.find("Subscription_Model").get("v.value");
        if( subscriptionModel != null && subscriptionModel == 'alburaq' ){
            component.set('v.caseModel',subscriptionModel);
        }else{
            component.set('v.caseModel','ila');
        }
        
        let dndValue = component.find("DND").get("v.value");
        console.error('dndValue---->>> '+dndValue);
        var options = [	{label: '--None--', apiName: '' }];
        if( dndValue != null && dndValue == true ){
            options.push({label: 'Remove from DND List', apiName: 'Remove from DND List' });
        }else{
            options.push({label: 'Add to DND List', apiName: 'Add to DND List' });
        }
        options.push({label: 'Register Interest in ila GulfAir Card', apiName: 'Register Interest in ila GulfAir Card' })
        component.set('v.subTypeOptions', options);
    },
    caseModelIsChanged : function(component, event, helper) {
        console.error('is changed caseModelIsChanged');
        let casemodel = component.get('v.caseModel');
        if(casemodel == 'alburaq'){
            component.set('v.subjectDefault','');
        }
        else if(casemodel == 'ila'){
            component.set('v.subjectDefault','');
        } 
    },
})
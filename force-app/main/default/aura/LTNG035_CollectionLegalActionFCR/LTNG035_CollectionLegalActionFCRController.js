({
    doInit: function (component, event, helper) {
        helper.doInit(component, event, helper);
    },
    handleOnload: function (component, event, helper) {
        console.log("on load form !");
    },
    handleOnSubmit: function (component, event, helper) {
        console.log('handleOnSubmit');
        event.preventDefault();
        console.error(component.get('v.recordTypeId'));
        component.find('form').submit();
        helper.showSpinner(component);

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
    },
    onSubmit: function (component, event, helper) {
        var isCreditCardCollectionChecked = null;
        var isCreditCardLegalChecked = null;
        var isLoanCollectionChecked = null;
        var isLoanLegalChecked = null;
        var caseNature = component.find("caseNature").get("v.value");
        var TypeField = component.find("type");
        var TypeValue = TypeField.get("v.value");
        console.log("caseNature Value: " + caseNature);
        console.log("tyyype Value: " + TypeValue);
        var subTypeField = component.find("subType");
        var subTypeValue = subTypeField.get("v.value");
        console.log("suuuuubbbtyyype Value: " + subTypeValue);

        if(caseNature == 'Credit Card'){
            if(TypeValue=="Collection Case" && subTypeValue=="Apply Flag"){
                isCreditCardCollectionChecked=true;
            }
            else if(TypeValue=="Collection Case" && subTypeValue=="Remove Flag"){
                isCreditCardCollectionChecked=false;

            } else  if(TypeValue=="Legal Action" && subTypeValue=="Apply Flag"){
                isCreditCardLegalChecked=true;

            } else if(TypeValue=="Legal Action" && subTypeValue=="Remove Flag"){

                isCreditCardLegalChecked=false;
            }
        } else {
            if(TypeValue=="Collection Case" && subTypeValue=="Apply Flag"){
                isLoanCollectionChecked = true;
            }
            else if(TypeValue=="Collection Case" && subTypeValue=="Remove Flag"){
                isLoanCollectionChecked = false;

            } else  if(TypeValue=="Legal Action" && subTypeValue=="Apply Flag"){
                isLoanLegalChecked = true;

            } else if(TypeValue=="Legal Action" && subTypeValue=="Remove Flag"){
                isLoanLegalChecked = false;
            }
        }
        
        helper.UpdateCheckboxes(component, event, helper,isCreditCardCollectionChecked,isCreditCardLegalChecked, isLoanCollectionChecked, isLoanLegalChecked);
       
     },

    handleOnError: function (component, event, helper) {
        helper.hideSpinner(component);
    },
    onCancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleLoad: function (component, event, helper) {
		console.log('handleLoad  cmp---'+component.find("Subscription_Model").get("v.value"));
        let subscriptionModel = component.find("Subscription_Model").get("v.value");
        if( subscriptionModel != null && subscriptionModel == 'alburaq' ){
            component.set('v.caseModel',subscriptionModel);
        }else{
            component.set('v.caseModel','ila');
        }
	},
    
})
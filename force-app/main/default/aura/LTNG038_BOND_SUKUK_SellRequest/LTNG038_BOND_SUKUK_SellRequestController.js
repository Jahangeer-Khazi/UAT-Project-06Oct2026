({
	 doInit: function (component, event, helper) {
        helper.doInit(component, event, helper);
        helper.loadBond(component,event,helper);
    },
    OncaseModelChange:function (component, event, helper) {
         helper.loadBond(component,event,helper);
    },
    handleOnload: function (component, event, helper) {
        console.log("on load form !");
    },
    handleOnSubmit: function (component, event, helper) {
        console.log('handleOnSubmit');
        event.preventDefault();
        console.error(component.get('v.recordTypeId'));
        var fields = event.getParam('fields');
        var selvalue = component.find("SelBond").get("v.value");
        //alert('selvalue##'+selvalue);
        fields["OwnerId"] = $A.get("$Label.c.Investment_Sell_Request_Maker");
        fields["bs_Investment_ID__c"]=selvalue;
        component.find('form').submit(fields);
        //helper.SellRequest(component,event,helper);
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
    handleOnError: function (component, event, helper) {
        helper.hideSpinner(component);
    },
    onCancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleLoad: function (component, event, helper) {//CH01
        console.log('handleLoad  cmp---'+component.find("Subscription_Model").get("v.value"));
        console.log('consentstatus',component.find("Consent_Status").get("v.value"));
        component.set("v.Consent_Status",component.find("Consent_Status").get("v.value"));
        let Consent_Status=component.find("Consent_Status").get("v.value");
       /* if(Consent_Status!='VALID') {
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
            component.find('notifyId').showNotice({
                "variant": "warning",
                "header": "Invalid Investment Questionarie",
                "message": "There is not valid Bond/Sukuk Consent Status. Please proceed Submitting a valid Investment Questionarie Inorder to proceed with Buy Request",
                closeCallback: function(component, event, helper) 
                {window.setTimeout($A.getCallback(function() {}),100);}});              
        }*/
        let subscriptionModel = component.find("Subscription_Model").get("v.value");
        if( subscriptionModel != null && subscriptionModel == 'alburaq' ){
            component.set('v.caseModel',subscriptionModel);
        }else{
            component.set('v.caseModel','ila');
        }
        helper.loadBond(component,event,helper);
    },
    OnSelectingBond: function (component, event, helper) {
        console.error('First Picklist accToReleaseHoldChange =================>>>>');
        var myValues= component.get("v.accountBondList");
        var value = component.find("SelBond").get("v.value");
        if(value == ''){
            component.set('v.currentBond',null);
            return ;
        }
        myValues.findIndex(item => {
            if(item.referenceNo == value){
            console.log('item##'+JSON.stringify(item));
            component.set('v.currentBond',item)
        }
                           });
    }
})
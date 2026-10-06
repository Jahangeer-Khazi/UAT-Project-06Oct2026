({
    doInit: function (component, event, helper) {
        helper.loadInstrument(component,event,helper);
    },
    handleOnload: function (component, event, helper) {
        console.log("on load form !");
    },
    handleOnSubmit: function (component, event, helper) {
        console.log('handleOnSubmit');
        event.preventDefault();
        var fields = event.getParam('fields');
        fields["OwnerId"] = $A.get("$Label.c.Ila_Ops_Maker");
        //fields["Maker__c"] =  $A.get("$SObjectType.CurrentUser.Id");
        fields["Status__c"] = 'In-Progress';
        fields["Instrument_ID__c"]=component.find("instId").get("v.value");
        component.find('form').submit(fields);
        helper.showSpinner(component);
    },
    handleOnSuccess: function (component, event, helper) {
        helper.hideSpinner(component);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Success!",
            "message": "Distribution has been created successfully."
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
        var navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
            "listViewId": '00BQI000000u0be2AA',
            "listViewName": null,
            "scope": "Investment_Distribution__c"
        });
        navEvent.fire();
    },
    OnSelectingInstrument : function (component, event, helper) {
        console.error('First Picklist accToReleaseHoldChange =================>>>>');
        var myValues= component.get("v.InstrumentList");
        var value = component.find("ISINCODE").get("v.value");
        console.log("mycodeAcc");
        if(value == ''){
            component.set('v.SelInstrument',null);
            return ;
        }
        myValues.findIndex(item => {
            if(item.bs_label == value){
            console.log('item##'+JSON.stringify(item));
            component.set('v.SelInstrument',item)
            
        }
      });
    }
})
({
    doInit : function(component, event, helper) {
        helper.doInit(component,event,helper);
        

    },
    close: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    getSelectedSubType:function(component, event, helper) {


    },
    recordUpdate: function(component, event, helper) {
        // let subTypeValue=component.get(("v.record").Sub_Type__c);
        component.set("v.SubTypeSelected",component.get("v.record").Sub_Type__c);

    },
    saveRecord:function(component, event, helper) {
        helper.saveRecord(component,event,helper);

    }

    
    
})
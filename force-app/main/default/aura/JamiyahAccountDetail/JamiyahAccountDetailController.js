({
    init : function(component, event, helper) {
        //alert('test--->');
        component.set('v.data',undefined);
        helper.loadData(component);
    },
    load : function(component, event, helper) {
        component.set('v.data',undefined);
        helper.loadData(component);
    },
})
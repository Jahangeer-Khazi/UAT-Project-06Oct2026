({
    doInit : function(component, event, helper) {
        helper.handleInit(component,event);
    },
    saveSignatureOnClick : function(component, event, helper,data){
        helper.handleSaveSignature(component,event,helper,component.get("v.recordId"));
    },
    clearSignatureOnClick : function(component,event,helper){
        helper.clearCanvas(component,event);
    },
    IsCanvasEmpty: function(component, event, helper){
        return helper.checkCanvasStatus(component,event);
    }
})
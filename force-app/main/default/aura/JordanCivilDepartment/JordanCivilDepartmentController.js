({
    doInit  : function(component, event, helper) {
        helper.init(component);
    },
    onClickeKycRetry : function(component, event, helper) {
        //component.set("v.isSavedOnBoarding", false);
        helper.eKycRetryLogic(component);
    },
    onClickeKycConvert : function(component, event, helper) {
        //component.set("v.isSavedOnBoarding", false);
        helper.eKycConvertLogic(component);
    },
    onClickeKYCDetailsRetry : function(component, event, helper) {
        helper.eKycDetailRetryLogic(component);
    }
})
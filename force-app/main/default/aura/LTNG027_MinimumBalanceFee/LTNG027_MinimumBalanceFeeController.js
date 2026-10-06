({
    doInit: function (component, event, helper) {
        var accId = component.get('v.accountId');
        helper.getAccounts(component, event, helper,accId);
    },
    AccountChange : function (component, event, helper) {
        console.error('AccountChange =================>>>>');
        var myValues= component.get("v.AccountsList");
        var value = component.find("MinimumBalanceFeeReversal").get("v.value");
        if(value == ''){
            component.set('v.currentAcc',null);
            return ;
        }
        myValues.findIndex(item => {
            if(item.ac_label == value){
                component.set('v.currentAcc',item)
            }
        });
    },
    caseModelIsChanged : function(component, event, helper) {
        console.error('is changed caseModelIsChanged');
        //#CH01
        var accId = component.get('v.accountId');
        helper.getAccounts(component, event, helper,accId);
    },
})
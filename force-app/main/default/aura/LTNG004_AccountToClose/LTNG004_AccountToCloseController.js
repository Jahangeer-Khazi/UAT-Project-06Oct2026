({
    doInit: function (component, event, helper) {
        var accId = component.get('v.accountId');
        helper.getAccountToClose(component, event, helper,accId);
    },
    accToCloseChange : function (component, event, helper) {
        console.error('accToCloseChange =================>>>>');
        var myValues= component.get("v.accToCloseList");
        var value = component.find("accToClose").get("v.value");
        if(value == ''){
            component.set('v.currentAcc',null);
            return ;
        }
        myValues.findIndex(item => {
            if(item.iban == value){
            	component.set('v.currentAcc',item)
            }
        });
    },
    
    caseModelIsChanged : function(component, event, helper) {
        //#CH01 :
        console.error('is changed caseModelIsChanged');
        var accId = component.get('v.accountId');
        component.set("v.currentAcc", null);
        component.find("accToClose").set("v.value", "");
        component.set("v.accToCloseList", []);

        helper.getAccountToClose(component, event, helper,accId);
    }
})
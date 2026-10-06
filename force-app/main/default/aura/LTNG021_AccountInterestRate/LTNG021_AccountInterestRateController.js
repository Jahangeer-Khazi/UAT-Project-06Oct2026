/**
Change History :
*         #CH01 : #D&A Team #24-06-2022# Added Case model parameter to add alburaq logic.
*/
({
    doInit: function (component, event, helper) {
        var accId = component.get('v.accountId');
        helper.getAccounts(component, event, helper,accId);
    },
    accChange : function (component, event, helper) {
        console.error('accChange =================>>>>');
        var myValues= component.get("v.accList");
        var value = component.find("accs").get("v.value");
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
        console.error('is changed caseModelIsChanged');
        //#CH01
        component.find('accs').set('v.value','');
        component.set('v.accList',[]);
        var accId = component.get('v.accountId');
        helper.getAccounts(component, event, helper,accId);
    }
})
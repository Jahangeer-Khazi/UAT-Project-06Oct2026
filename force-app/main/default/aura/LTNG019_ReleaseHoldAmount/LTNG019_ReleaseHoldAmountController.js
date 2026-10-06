/**
Change History :
*         #CH01 : #D&A Team #24-06-2022# Added Case model parameter to add alburaq logic.
*/
({
	 doInit: function (component, event, helper) {
        var accId = component.get('v.accountId');
        helper.getAccountToReleaseHold(component, event, helper,accId);
    },
    accountToReleaseHoldChange : function (component, event, helper) {
        debugger;
        
        var myValues= component.get("v.accToReleaseHoldList");
        var value = component.find("accToReleaseHold").get("v.value");
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
        console.error('First Picklist  is changed caseModelIsChanged ==============>>> ');
        //#CH01
        component.set("v.accToReleaseHoldList",[]);
        component.find('accToReleaseHold').set('v.value','');
        var accId = component.get('v.accountId');
        helper.getAccountToReleaseHold(component, event, helper,accId);
    }
})
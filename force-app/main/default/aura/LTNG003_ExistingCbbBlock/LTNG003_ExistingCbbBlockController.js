/**
Change History :
*         #CH01 : #D&A Team #24-06-2022# Added Case model parameter to add alburaq logic.
*/
({
    doInit: function (component, event, helper) {
        var accId = component.get('v.accountId');
        helper.getExistingCbbBlocks(component, event, helper,accId);
    },
    cbbBlockChange : function (component, event, helper) {
        console.error('cbbBlockChange =================>>>>');
        var myValues= component.get("v.blockAmountList");
        var value = component.find("cbbBlock").get("v.value");
        if(value == ''){
            component.set('v.currentBlockAmount',null);
            return ;
        }
        myValues.findIndex(item => {
            if(item.blockId == value){
                component.set('v.currentBlockAmount',item)
            }
        });
    },
    caseModelIsChanged : function(component, event, helper) {
        console.error('is changed caseModelIsChanged');
        //#CH01
        var accId = component.get('v.accountId');
        helper.getExistingCbbBlocks(component, event, helper,accId);
    },
})
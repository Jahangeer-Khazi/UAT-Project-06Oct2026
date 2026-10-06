/**
Change History :
*         #CH01 : #D&A Team #24-06-2022# Added Case model parameter to add alburaq logic.
*/
({
    doInit: function (component, event, helper) {
        var accId = component.get('v.accountId');
        helper.getAccountToBlockUnblock(component, event, helper, accId);
    },
    accToBlockUnblockChange: function (component, event, helper) {
        /* console.error('accToBlockUnblockChange =================>>>>');
        var myValues= component.get("v.accToBlockUnblockList");
        var value = component.find("accToBlockUnblock").get("v.value");
        if(value == ''){
            component.set('v.accDetails',null);
            return ;
        }
        myValues.findIndex(item => {
            if(item.iban == value){
                component.set('v.accDetails',item)
            }
        }); */
    },
    handleAccChange: function (component, event, helper) {
        console.error('*****************handleAccChange***********');
        //Get the Selected values   
        var selectedValues = event.getParam("value");

        //Update the Selected Values  
        component.set("v.selectedAccList", selectedValues);
        var myValues= component.get("v.accToBlockUnblockList");
        var accLst = [];
        for (var i = 0; i < selectedValues.length; i++) {
            myValues.map(function (element) {
                if(element.iban == selectedValues[i]){
                    console.error('*********************'+element);
                    accLst.push(element);
                }
            })
        }
        
        if(accLst.length>0){
            var str = '';
            var strIban = '';
            for(var i = 0; i < accLst.length; i++){
                if(i==0){
                    str = accLst[i].ac_label+',';
                    strIban = accLst[i].iban+'';
                }else{
                    str += '\n'+accLst[i].ac_label+',';
                    strIban += ','+accLst[i].iban;
                }
            }
            component.set('v.accDetails', str)
            component.set('v.accIbans', strIban)
        }else{
            component.set('v.accDetails',null)
            component.set('v.accIbans',null)
        }
        
    },
    caseModelIsChanged : function(component, event, helper) {
        console.error('is changed caseModelIsChanged');
        //#CH01
        var accId = component.get('v.accountId');
        component.set('v.selectedAccList',null);
        component.set('v.AccList',null);
        helper.getAccountToBlockUnblock(component, event, helper, accId);
    },
})
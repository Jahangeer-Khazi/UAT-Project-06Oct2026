/**
Change History :
*         #CH01 : #D&A Team #24-06-2022# Added Case model parameter to add alburaq logic.
*/
({
    doInit: function (component, event, helper) {
        var currentAcco = component.get('v.currentAcc');
        debugger;
        if(currentAcco != null){
            helper.getAccDetails(component, event, helper,currentAcco);
        }
    },
	 
    TransactionsToHoldChange : function (component, event, helper) {
        debugger;
        var myValues= component.get("v.TransactionsToHoldList");
        console.log(myValues);
        var value = component.find("TransactionsToHold").get("v.value");
        if(value == ""){
            component.set("v.accDetails", {holdReferenceNumber: null,holdAmount:null,holdDate:null,holdExpiryDate:null,HoldType:null} );
        }else {
            console.log(value);
            myValues.findIndex(item => {
                if(item.HoldId == value){
                    component.set('v.accDetails',item)
                }
            });
        }
    },
    handleCurrentAccChange : function (component, event, helper) {
        component.set("v.accDetails", {holdReferenceNumber: null,holdAmount:null,holdDate:null,holdExpiryDate:null,HoldType:null} );
        component.find('TransactionsToHold').set('v.value','');
        var currentAcco = component.get('v.currentAcc');
        if(currentAcco != null){
            helper.getAccDetails(component, event, helper,currentAcco);
        }else{
            component.set('v.TransactionsToHoldList',null);
        }
    },
    caseModelIsChanged : function(component, event, helper) {
        console.error('Second PickList is changed caseModelIsChanged =================>>');
        //#CH01 -Start
        component.set("v.accDetails", {holdReferenceNumber: null,holdAmount:null,holdDate:null,holdExpiryDate:null,HoldType:null} );
        component.set('v.TransactionsToHoldList',[]);
        component.find('TransactionsToHold').set('v.value','');
        //#CH01 -End
    }
})
({
    doInit: function (component, event, helper) {
        helper.doInit(component, event, helper);
        // helper.loadIban(component,event,helper);
        helper.loadInstrument(component,event,helper);
       // helper.loadBondConfiguration(component,event,helper);
    },
    handleOnload: function (component, event, helper) {
        console.log("on load form !");
    },
    OncaseModelChange:function (component, event, helper) {
        helper.loadIban(component,event,helper);
        helper.loadInstrument(component,event,helper);
    },
    handleOnSubmit: function (component, event, helper) {
          console.log('handleOnSubmit');
        var bidAmount=component.get('v.bidAmount');
        var minAmount=component.get('v.minAmount');
        var maxAmount=component.get('v.maxAmount');
        var investMentExist = component.get('v.investmenExist');
        console.log('investmenExist###'+investMentExist);
        var allowedMultiples = component.get('v.allowedMultiples');
        event.preventDefault();
        console.error(component.get('v.recordTypeId'));
        var fields = event.getParam('fields');
        fields["OwnerId"] = $A.get("$Label.c.Investment_Buy_Request_Maker");
        fields["Status"] = 'Open';
        if(investMentExist){
            helper.handleErrors('Only 1 bid can be placed for the same instrument. Existing pending bid request to be canceled to create a new bid request.', 'Only 1 bid can be placed for the same instrument. Existing pending bid request to be canceled to create a new bid request.');
        }else{
        if(bidAmount<minAmount){
            helper.handleErrors('Amount entered is less than allowed minimum order amount', 'Amount entered is less than allowed minimum order amount');
        }else if(bidAmount>maxAmount){
            helper.handleErrors('Amount entered is more than allowed maximum order amount', 'Amount entered is more than allowed maximum order amount');
        }else{
            if(bidAmount%allowedMultiples===0){
            component.find('form').submit(fields);
            helper.showSpinner(component);
            }  else{
                 helper.handleErrors('Amount entered needs to be in multiples of BHD '+allowedMultiples, 'Amount entered needs to be in multiples of BHD '+allowedMultiples);
            } 
           
        }  
        }

    },
    handleOnSuccess: function (component, event, helper) {
        helper.hideSpinner(component);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Success!",
            "message": "Case has been created successfully."
        });
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.getParam("response").id,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    handleOnError: function (component, event, helper) {
        helper.hideSpinner(component);
    },
    onCancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleLoad: function (component, event, helper) {//CH01
        console.log('handleLoad  cmp---'+component.find("Subscription_Model").get("v.value"));
        console.log('consentstatus',component.find("Consent_Status").get("v.value"));
        helper.loadBondConfiguration(component,event,helper);
        // helper.loadBond(component,event,helper);
    }, accountToReleaseHoldChange : function (component, event, helper) {
        var myValues= component.get("v.accToReleaseHoldList");
        var value = component.find("accToReleaseHold").get("v.value");
        console.log("accountToReleaseHoldChange");
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
    OnSelectingInstrument : function (component, event, helper) {
        var myValues= component.get("v.InstrumentList");
        // var myBond= component.get("v.BidInformationCal");
        var value = component.find("InsUnit").get("v.value");
        var caseModel =component.get("v.caseModel");
        var regionFlag = component.find("regionFlag").get("v.value");
        var segment = component.find("segment").get("v.value");
        console.log("mycodeAcc");
        if(value == ''){
            component.set('v.currentInst',null);
            return ;
        }
        myValues.findIndex(item => {
            if(item.bs_ISIN_Code == value){
            component.set('v.currentInst',item)
            //const bidAmount=Number(component.get("v.noofUnits"))*10000;
            const bidAmount=Number(component.find("bs_Bid_Amount").get("v.value"));
            const minAmount = Number(item.bs_Min_Amount);
            const maxAmount = Number(item.bs_Max_Amount);
            component.set('v.minAmount',minAmount);
            component.set('v.maxAmount',maxAmount);
            //  alert('bidAmount',bidAmount);
            component.set('v.bidAmount',bidAmount);
            /*   if(bidAmount<minAmount){
              helper.handleErrors('Amount entered is less than allowed minimum order amount', 'Amount entered is less than allowed minimum order amount');
        }else if(bidAmount>maxAmount){
             helper.handleErrors('Amount entered is more than allowed minimum order amount', 'Amount entered is more than allowed minimum order amount');
        }else{*/
              console.log('bs_allowedActions##'+item.bs_allowedActions);
            console.log('result##'+item.bs_allowedActions.includes('has_investment'));
            component.set('v.investmenExist',item.bs_allowedActions.includes('has_investment'));
            if(bidAmount>0){
            helper.CalculateBid(component,event,helper,bidAmount,item.bs_ISIN_Code,component.find('ac_Iban').get('v.value'));
        }
                           //}
                           
                           /*   const BidFee = bidAmount*Number(item.bs_Process_Per)<Number(item.bs_Bid_Fees)?Number(item.bs_Bid_Fees):bidAmount*Number(item.bs_Process_Per);
            //  const BidFee=Number(component.get("v.noofUnits"))*Number(bitem.Minimum_Fee_Amount__c) * Number(bitem.Fee_Amount__c);
            component.find("bs_Bid_Fees").set("v.value",BidFee);
            component.find("bs_Bid_VAT").set("v.value",BidFee*Number(item.bs_Bid_VAT));
            const Total=Number(component.find("bs_Bid_Amount").get("v.value"))+Number(component.find("bs_Bid_Fees").get("v.value"))+Number(component.find("bs_Bid_VAT").get("v.value"));
            component.find("bs_Total_Bid_Amount").set("v.value",Total);*/
                           
                           }
                           });
    },
})
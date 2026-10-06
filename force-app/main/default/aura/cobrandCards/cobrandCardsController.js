/**
Change History :
*         #CH01 : #D&A Team #24-06-2022# Added Case model parameter to add alburaq logic.
          #CH02 :  Added by Elmustapha team 16-11-2023 add Is C2C Customer field
*/
({
	handleOnload : function(component, event, helper) {
        if(component.get("v.isInit") == false){
            component.set("v.isInit",true);
			component.find('apexService').request(component.get('c.getCardOptions'), {
                accID : component.get("v.recordId"),
                caseModel : component.get("v.caseModel")
            },
             function(response) {
             var result = response.getReturnValue();
                 
              var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }
             component.set("v.cc_cardType",fieldMap);
           });
        	component.find('apexService').request(component.get('c.getDefaultName'), {
                accID : component.get("v.recordId")
            },
             function(response) {
             var result = response.getReturnValue();
             component.find("namOnCard").set("v.value",result);
           });
        } //If Ends
	},
    handleOnSubmit: function(component, event, helper) {
        helper.showSpinner(component);
        
        
    },
    handleOnSuccess : function(component, event, helper) {
        helper.hideSpinner(component);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"success",
            "title": "Success!",
            "message": "Case has been created successfully."
        });
        toastEvent.fire();
         
        $A.get("e.force:closeQuickAction").fire();
        
        
    },
    handleOnError : function(component, event, helper) {
        helper.hideSpinner(component);
	},
    onCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    caseModelIsChanged : function(component, event, helper) {
        console.error('is changed caseModelIsChanged');
        //#CH01
        component.find('requestedCardType').set('v.value','');
		component.find('apexService').request(component.get('c.getCardOptions'), {
            accID : component.get("v.recordId"),
            caseModel : component.get("v.caseModel")
        },
         function(response) {
         var result = response.getReturnValue();
             
          var fieldMap = [];
            for(var key in result){
                fieldMap.push({key: key, value: result[key]});
            }
         component.set("v.cc_cardType",fieldMap);
       });
    },
    handleLoad: function (component, event, helper) {//CH01
		console.log('handleLoad  cmp---');
        let subscriptionModel = component.find("Subscription_Model").get("v.value");
        if( subscriptionModel != null && subscriptionModel == 'alburaq' ){
            component.set('v.caseModel',subscriptionModel);
        }else{
            component.set('v.caseModel','ila');
        }
        // Start CH02 
        let Segment = component.find("Customer_Segment").get("v.value");
        console.log(Segment);
        component.set('v.Segment', Segment);
        // End CH02 
	},
    handleCobrandChange: function (component, event, helper) {
        const isChecked = event.getSource().get("v.value");
        console.log('Has Cobrand Chcked:',isChecked);
        component.set("v.hasCoBrandMembership", isChecked);
    },
    handleBalanceTransferChange: function (component, event, helper) {
        const isBalTransfChecked = event.getSource().get("v.value");
        console.log('Has Balance Tansf Chcked:',isBalTransfChecked);
        component.set("v.hasBalanceTransfer", isBalTransfChecked);
    },
    handleEmbossChange: function (component, event, helper) {
        // Get the value of the Embossing Line 4 field
        var inputValue = event.getSource().get("v.value");
        component.set("v.embossingLine4", inputValue); // Update the embossingLine4 attribute
    },
    fetchMembershipId: function (component, event, helper) {
        helper.showSpinner(component);
        var accId = component.get("v.recordId");
        var memberId = component.get("v.embossingLine4");
        console.log('Record Idd:',accId);
        console.log('Membership Idd:',memberId);
        var action = component.get("c.fetchGulfAirId");
        action.setParams({
            customerId: accId,
            membershipId: memberId
        });
        action.setCallback(this, function (response){
            var state = response.getState();
            if(state === "SUCCESS"){
               console.log('Getting response Map:',response.getReturnValue());
               var response = response.getReturnValue();
                console.log('Code:',response.meta.code);
                if(response.meta.code === 'GULF-1000'){
                    helper.handleSuccess("Gulf air Membership Id have been found successfully.");
                    helper.hideSpinner(component);
                }
                else if(response.meta.code != 'GULF-1000'){
                    helper.handleErrors("Please Enter a Valid Membership Id of a customer");
                    helper.hideSpinner(component);
                    //component.set("v.embossingLine4","");
                }
               
            }else if(state === "ERROR") {
                helper.handleErrors(response.getError());
                helper.hideSpinner(component);
            }
        });
        $A.enqueueAction(action);
    },
    
    
})
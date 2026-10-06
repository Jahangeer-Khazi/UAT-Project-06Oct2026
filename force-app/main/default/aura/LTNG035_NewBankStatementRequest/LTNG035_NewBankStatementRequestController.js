({
	doInit: function (component, event, helper) {
        helper.getBankStatementRecordType(component, event, helper);
    },
	handleOnload: function (component, event, helper) {
        console.log("on load form !");
    },
    handleChange: function (component, event, helper) {
        console.log("on handle change form !");
        helper.getAccountConfigViaApi(component, event, helper);
    },
    handleOnSubmit: function (component, event, helper) {
        event.preventDefault();

        var subType = component.get("v.subType");
		if ( subType == 'Request Account Bank Statement' ) {
            let requestedAccount = component.find("requestedAccount");
            if (requestedAccount.get("v.value") != '' && requestedAccount.get("v.value") != null) {
                console.log('submit the form');
                component.find('form').submit();
                helper.showSpinner(component);
            } else {
                console.error("please fill the Bank Accounts");
                // Set error//focuss the error
            }
        }
        else if ( subType == 'Request Credit Card Bank Statement' || subType == 'Request Prepaid Card Bank Statement' ){
            let requestedCard = component.find("requestedCard");
            if (requestedCard.get("v.value") != '' && requestedCard.get("v.value") != null) {
                console.log('submit the form');
                component.find('form').submit();
                helper.showSpinner(component);
            } else {
                console.error("please fill the Credit Cards");
                // Set error//focuss the error
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
    caseModelIsChanged : function(component, event, helper) {
		console.log('is changed caseModelIsChanged');
        //reset All boolean sections to false  : ..
        component.set("v.showAccountsSection",false);
        component.set("v.showCCSection",false);
        component.set("v.subType",null);
    },
    subTypeIsChanged : function(component, event, helper) {
		console.log('is changed subTypeIsChanged');
        //reset All boolean sections to false  : ..
        component.set("v.showAccountsSection",false);
        component.set("v.showCCSection",false);
        
		var subType = component.get("v.subType");
		if ( subType == 'Request Account Bank Statement' ) {
            component.set("v.showAccountsSection",true);
        }
        else if ( subType == 'Request Credit Card Bank Statement' ) {
            helper.getCCardOptionsViaApi(component, event, helper, subType);
        }
        else if ( subType == 'Request Prepaid Card Bank Statement' ) {
            helper.getCCardOptionsViaApi(component, event, helper, subType);
        }
    },
    handleLoad: function (component, event, helper) {
		console.log('handleLoad  cmp---');
        let subscriptionModel = component.find("Subscription_Model").get("v.value");
        let Segment = component.find("Segment").get("v.value");
        component.set('v.segment',Segment);
        
        //#CH02 :start
        let Fee_Waiver_Flag = component.find("Fee_Waiver_Flag").get("v.value");
        let Fee_Waiver_Reason = component.find("Fee_Waiver_Reason").get("v.value");
        component.set('v.feeWaiver',Fee_Waiver_Flag);
        component.set('v.feeWaiverReason',Fee_Waiver_Reason);
        //#CH02 :end

        if( subscriptionModel != null && subscriptionModel == 'alburaq' ){
            component.set('v.caseModel',subscriptionModel);
        }else{
            component.set('v.caseModel','ila');
        }

        //get accounts List and default Account 
        helper.getAccountConfigViaApi(component, event, helper);
        
	},
    requestedAccountChange: function (component, event, helper) {
        console.error('requestedAccountChange =================>>>>');
        var myValues= component.get("v.accountOptions");
        console.log('myValues ===>',JSON.stringify(myValues));
        var value = component.find("requestedAccount").get("v.value");
        console.log('value ===>',JSON.stringify(value));
        if(value == ''){
            component.set('v.currentAcc',null);
            component.set('v.selectedCurrency', null);
            return ;
        }
        
        var selectedAccount = myValues.find(item => item.id == value);
        
        if (selectedAccount) {
            console.log('selectedAccount ===>', JSON.stringify(selectedAccount));
            component.set('v.currentAcc', selectedAccount);
            console.log('selectedAccount.account ===>', JSON.stringify(selectedAccount.account));
            console.log('selectedAccount.account.currency ===>', JSON.stringify(selectedAccount.account.currency));
            // Set the currency value from the account
            if (selectedAccount.account && selectedAccount.account.currency) {
                console.log('reached ===>');
                component.set('v.selectedCurrency', selectedAccount.account.currency.code);
                console.log('selectedCurrency ===>', JSON.stringify(selectedAccount.account.currency.code));
            }
        }
	},
    requestedCardChange: function (component, event, helper) {
        console.error('requestedCardChange =================>>>>');
        var myValues= component.get("v.creditOptions");
        var value = component.find("requestedCard").get("v.value");
        if(value == ''){
            component.set('v.currentCard',null);
            return ;
        }
        myValues.findIndex(item => {
            if(item.id == value){
                component.set('v.currentCard',item)
            }
        });
	},
})
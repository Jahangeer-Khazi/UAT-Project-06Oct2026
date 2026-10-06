({
    init : function(component, event, helper) {
        //debugger;
        console.log('---> Customer ID 1 --> ', component.get('v.customerId'));
        console.log('---> Card ID 1 -->  ', component.get('v.cardId'));
        console.log('---> Account ID 1 --> ', component.get('v.account.PersonEmail'));
        //console.log('Sub status value in credit detail:',component.get('v.caseSubType'));
        helper.loadCardDetails(component, component.get('v.customerId'), component.get('v.cardId'), component.get('v.account'));
        
        //CH07 START
        helper.checkCreditCardUser(component,helper);
        //CH07 END
	},

    load : function(component, event, helper) {
        console.log('---> Customer ID --> ', component.get('v.customerId'));
        console.log('---> Card ID --> ', component.get('v.cardId'));
        console.log('---> Account ID --> ', component.get('v.account'));
        helper.loadCardDetails(component, component.get('v.customerId'), component.get('v.cardId'), component.get('v.account'));
	},
    //CH07 START
    onDownloadCashCollateralClick: function(component, event, helper) {
    	helper.downloadCashCollateralCert(component,helper);
    },
    onSendCashCollateralClick: function(component, event, helper) {
    	helper.senEmailCashCollateralCert(component,helper);
    }
    //CH07 END
})
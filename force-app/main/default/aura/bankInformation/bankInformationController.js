/*
 * 		#CH01# Added #Jahangeer Moahmmed# #29-05-2023# DebitCardStatusChange(NBA-7010)
 */
({
    init : function(component, event, helper) {
        component.set('v.enableActions', 'Case' == component.get('v.sObjectName'));
        
        var defaultTabsConfig = {
            Bank_Accounts__c: false,
            Bank_Cards__c: false,
            Profile__c: false,
        };
        component.set('v.tabsConfig', defaultTabsConfig);
        //console.log('Bank Information Comp Init');
        var enableAudit = component.get('v.enableAuditComp');
        //console.log('Audit Custom Label Value:',enableAudit);
        helper.loadData(component, component.get('v.recordId'));
		
	},
    onStatusChange : function(component, event, helper) {
      /*  component.set('v.enableActions', 'Case' == component.get('v.sObjectName'));
        
        var defaultTabsConfig = {
            Bank_Accounts__c: false,
            Bank_Cards__c: false,
            Profile__c: false,
        };
        component.set('v.tabsConfig', defaultTabsConfig);*/
        helper.cardStatusCall(component, component.get('v.recordId'));
        
    },
    //CH01: Start
    onDebitCardStatusChange : function(component, event, helper){
        var debitCardSelected = component.get('v.selectedDebitCardStatus');
        console.log('Selected Debit Card:'+debitCardSelected);
        helper.loadDebitCardsBasedOnSelectedOption(component,component.get('v.recordId'));
    },
    //CH01: END
    handleCreditCardStatus : function(component, event, helper) {
		var hasCreditCards = event.getParam("hasCreditCards");
		console.log("Has Credit Cards:",hasCreditCards);
		component.set("v.hasCreditCards",hasCreditCards);
	}
})
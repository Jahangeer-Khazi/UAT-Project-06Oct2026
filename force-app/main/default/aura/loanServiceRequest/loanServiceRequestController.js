({
    init : function(component, event, helper) {
        component.set('v.enableActions', 'Case' == component.get('v.sObjectName'));
        
        var defaultTabsConfig = {
            Bank_Accounts__c: false,
            Bank_Cards__c: false,
            Profile__c: false,
        };
        component.set('v.tabsConfig', defaultTabsConfig);
        
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
    }
    //CH01: END
    
})
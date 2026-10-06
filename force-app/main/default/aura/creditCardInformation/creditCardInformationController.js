/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History:
 *	   			  #CH01# #Jahangeer Mohammed# #29-08-2021# Uncommented the helper.cardStatusCall
 *
 */
({
    init : function(component, event, helper) {
        component.set('v.enableActions', 'Case' == component.get('v.sObjectName'));
        
        var defaultTabsConfig = {
            Bank_Accounts__c: false,
            Bank_Cards__c: false,
            Profile__c: false,
            Credit_Cards__c: false
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
        //CH01 Start Uncommented by Jahangeer Mohammed on 29-08-2021
        helper.cardStatusCall(component, component.get('v.recordId'));
        //CH01 END
    }
    
})
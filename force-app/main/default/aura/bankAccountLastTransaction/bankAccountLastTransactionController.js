/* 	Organization : ABC Bank
 * 		Created By:Jayanth Manickam
 *		Created Date:17/10/2023
 * 		Change History:
 */


({
	 init : function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');
        helper.loadData(component, customerId, accountId);
    },
    load : function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');
        helper.loadData(component, customerId, accountId);
    }
})
/* 	Organization : ABC Bank
 * 		Created By: Maksud Ali
 *		Created Date: 08-12-2025 (Below code is cloned from account last transaction)
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
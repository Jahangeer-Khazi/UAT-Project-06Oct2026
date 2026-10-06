/* 		Organization : ABC Bank
 * 		Created By: ABC Support
 *		Created Date: 07-10-2019
 * 		Change History: 
 *			   
 *
 */
({
    init : function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var potId = component.get('v.potId');
        helper.loadData(component, customerId, potId);
    },
    load : function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var potId = component.get('v.potId');
        helper.loadData(component, customerId, potId);
    },
})
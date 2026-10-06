/* 		Organization : ABC Bank
 * 		Created By: ABC Support
 *		Created Date: 07-10-2019
 * 		Change History: 
 *			   #CH01 : Added by Imane Tsioucha 13-09-2023
 *
 */
 ({
    init : function(component, event, helper) {
      /*  var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');
        var accountNumber=component.get('v.accountNumber');
        var curency=component.get('v.curency');
        helper.loadData(component, customerId, accountId,curency,accountNumber);*/
         $A.get('e.force:refreshView').fire();
    },
    load : function(component, event, helper) {
     /*   var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');
        var accountNumber=component.get('v.accountNumber');
        var curency=component.get('v.curency');
        helper.loadData(component, customerId, accountId,curency,accountNumber);*/
    }
 
})
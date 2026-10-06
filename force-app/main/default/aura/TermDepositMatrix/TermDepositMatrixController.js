/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:03-01-2022
 * 		Change History: 
 *			  
*/
({
    doInit : function(component, event, helper) {
    helper.loadTermDepositMatrix(component, component.get('v.customerId'),helper);  
}
 })
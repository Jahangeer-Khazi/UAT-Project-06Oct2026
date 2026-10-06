/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:08-01-2023
 * 		Change History: 
 *			  
*/
({
	close: function (component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
	approveSupplementaryCard: function (component, event, helper) {
        component.set("v.disableButton",true);		
        helper.approveSupplementaryCard(component, event, helper);
	}
})
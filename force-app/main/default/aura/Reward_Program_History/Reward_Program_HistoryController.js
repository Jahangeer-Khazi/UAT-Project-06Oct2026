/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History: 
 *			   #CH01# Added #05-04-2021# 'changedateTo' and 'changedateFrom' Method in the JSController by Jahangeer Mohammed.
 			   
 */
({
    init: function(component,event,helper){
        component.set('v.viewRewardPgm','true');
        component.set("v.tbId", Math.random().toString(36).substr(2, 11)); 
        component.set('v.gridDataColumns', helper.getDataColumns(component));
        component.set('v.gridDataColumnDefs', helper.getColumnDefs(component));
        component.set('v.viewRewardPgm','false');
       // document.getElementById("histTable").style.display = 'none';
       // elements[0].style.display = 'none';
    },
    onLoadRewardHistory: function(component, event, helper) { 
        var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');
		//document.getElementById("histTable").style.display = 'block';
        component.set('v.gridDataColumns', helper.getDataColumns(component));
        component.set('v.gridDataColumnDefs', helper.getColumnDefs(component));
        component.set('v.viewRewardPgm','true');

        helper.loadRewardHistory(component, customerId, accountId);
	},
    load : function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');
        helper.loadRedemptions(component, customerId, accountId);
    }, 
	//CH01: END
   
})
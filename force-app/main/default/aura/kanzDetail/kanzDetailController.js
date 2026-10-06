/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History:
 * 			#CH01 : Hamza Chaoui 20/06/2022 Alburaq Logic
 *
 */
({
    init : function(component, event, helper) {

        var account = component.get('v.account');

        // Mask sensitive information depending on Account Segment
        //#CH01
        var mask = (account.Segment__pc === 'Staff' || account.Alburaq_Segment__pc === 'Staff')? true : false;
        component.set('v.maskSensitiveInfo',mask);
        var customerId = component.get('v.customerId');
        var caseId = component.get('v.caseId');
        var regionName= component.get('v.regionName');
        if (customerId) {
            helper.loadDataSensitiveData(component, customerId, mask);
            helper.loadData(component, customerId, caseId,regionName);
            
        }
      
      
       component.set("v.tbId", Math.random().toString(36).substr(2, 11));
	   component.set('v.gridDataColumns', helper.getDataColumns(component));
       component.set('v.gridDataColumnDefs', helper.getColumnDefs(component));

    },
    load: function (component, event, helper) {

        var account = component.get('v.account');

        // Mask sensitive information depending on Account Segment
        //#CH01
        var mask = (account.Segment__pc === 'Staff' || account.Alburaq_Segment__pc === 'Staff')? true : false;
        component.set('v.maskSensitiveInfo',mask);

        var customerId = component.get('v.customerId');
        var caseId = component.get('v.caseId');
        var regionName= component.get('v.regionName');
        if (customerId) {
            helper.loadData(component, customerId, caseId,regionName);
            helper.loadDataSensitiveData(component, customerId, mask);
        }

    },
    nextPage: function(component,event,helper) {

        // Handles next page behavior on component pagination
        var current = component.get('v.currentPage');
        component.set('v.currentPage',current+1);

        helper.changePage(component);

    },
    previousPage: function(component,event,helper) {

        // Handles previous page behavior on component pagination
        var current = component.get('v.currentPage');
        component.set('v.currentPage',current-1);

        helper.changePage(component);
    },
    showTransactions :function(component, event, helper){

        var customerId = component.get('v.customerId');
        var account = component.get('v.account');
        helper.showTransactions(component, customerId, account);
    },

      handleJqDataTableEvent: function(component, event, helper) {
       helper.handleJqDataTableEvent(component, event);
    },
    onSearchClick: function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');
        console.log('Customer Id:'+customerId);
        console.log('Account  Id:'+accountId);
        helper.runSearch(component, customerId, accountId, /*providedSearchParametersJson=*/undefined);
    }
})
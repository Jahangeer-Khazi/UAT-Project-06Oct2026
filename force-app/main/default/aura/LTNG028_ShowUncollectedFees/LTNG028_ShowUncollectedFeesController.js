/**		
 *      Organization : ABC Bank
 * 		Created By: Wissal Benqezza
 *		Created Date: 02-11-2022
 * 		Change History: 
 *          CH01: Added by Imane Tsioucha #07/11/2023# Add Hold Description 3 
 */
({
    init: function (component, event, helper) {
        console.log('init LTNG028_ShowUncollectedFeesController');
        var columns = [];
        columns = [
            { label: 'Hold Reference Number', fieldName: 'holdReferenceNumber', type: 'text', sortable: true },
            { label: ' Date', fieldName: 'holdDate', type: 'text', sortable: true },
            { label: 'Hold Amount', fieldName: 'holdAmount', type: 'text', sortable: true },
            { label: 'Hold Currency', fieldName: 'holdCurrency', type: 'text', sortable: true },
            { label: 'Hold Description Line 1 ', fieldName: 'holdDescription1', type: 'text', sortable: true },
            { label: 'Hold Description Line 2', fieldName: 'holdDescription2', type: 'text', sortable: true },
            // START: CH01
            { label: 'Hold Description Line 3', fieldName: 'holdDescription3', type: 'text', sortable: true }
            // END: CH01
            

        ];
        component.set('v.columns', columns);
        helper.doInit(component, event, helper);
      
    },
            
    onLoadUncollectedFees: function (component, event, helper) {
        component.set("v.viewUncollectedFees", true);
    },
   
})
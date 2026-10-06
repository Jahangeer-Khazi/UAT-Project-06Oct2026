/**		
 *      Organization : ABC Bank
 * 		Created By: Jayanth Manickam
 *		Created Date: 24-09-2024
 * 		Change History: 
 */
({
    init: function (component, event, helper) {
        console.log('init LTNG006_StampedStatementsController');
         component.set("v.viewAccStat", false);
        var columns = [];
        columns = [
            { label: 'Statement Date', fieldName: 'statementDate', type: 'text', sortable: true },
            { label: 'Statement Description', fieldName: 'statementDescription', type: 'text', sortable: true },
            {
                label: 'Download',
                type: 'button-icon',
                initialWidth: 135,
                typeAttributes: { iconName: 'utility:download', name: 'download_file', title: 'Click to download' }
            }

        ];
        component.set('v.columns', columns);
        helper.doInit(component, event, helper);
    },
    onLoadAccStatement: function (component, event, helper) {
        component.set("v.viewAccStat", true);
    },
    handleRowAction: function (component, event, helper) {
        var selectedRow = event.getParam('row');
        helper.handleAccStatementDetails(helper,component, selectedRow);
    },

})
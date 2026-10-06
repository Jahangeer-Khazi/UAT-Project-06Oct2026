/**		
 *      Organization : ABC Bank
 * 		Created By: Aniss Mbarki
 *		Created Date: 21-06-2024
 * 		Change History: 
 */
 ({
    init: function (component, event, helper) {
        console.log('init LTNG052_DeviceActivitiesController');
        var columns = [];
        columns = [
            { label: 'ID', fieldName: 'idRow', type: 'text',hideDefaultActions: true,sortable: false },
            { label: 'Action', fieldName: 'action', type: 'text',hideDefaultActions: true,sortable: false },
            { label: 'Triggered By', fieldName: 'triggeredBy', type: 'text',hideDefaultActions: true,sortable: false },
            { label: 'Device Manufacturer', fieldName: 'deviceManufacturer', type: 'text',hideDefaultActions: true ,sortable: false},
            { label: 'Device Model', fieldName: 'deviceModel', type: 'text', hideDefaultActions: true ,sortable: false},
            { label: 'Device OS', fieldName: 'deviceOs', type: 'text',hideDefaultActions: true ,sortable: false},
            { label: 'Reason', fieldName: 'reason', type: 'text', hideDefaultActions: true ,sortable: false},
            { label: 'Device ID', fieldName: 'deviceId', type: 'text',hideDefaultActions: true,sortable: false },
            { label: 'Action Date', fieldName: 'actionDate', type: 'text',hideDefaultActions: true,sortable: false }
        ];
        component.set('v.columns', columns);
        helper.doInit(component, event, helper);
    }
})
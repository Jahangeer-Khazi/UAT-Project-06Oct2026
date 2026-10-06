/* 		Organization : ABC Bank
 * 		Created By: 
 *		Created Date:
 * 		Change History: 
 *             
 *            #CH01# : #Jahangeer Mohammed# #08-05-2024# Added Logic for Audit History Enhancements(NBA-9027)


*/
({
    init : function(component, event, helper) {

        var rowLevelActions = helper.getRowActions.bind(component, this);
        
        component.set('v.columns', [
            {label: 'Jamiyah Id', fieldName: 'id', type: 'text',sortable:true},
            {label: 'Name', fieldName: 'name', type: 'text',sortable:true},
            {label: 'Category', fieldName: 'category', type: 'text',sortable:true},
            {label: 'Status', fieldName: 'jameyaStatus', type: 'text',sortable:true},
            {label: 'Org Cust Id', fieldName: 'organiserCustomerId', type: 'text',sortable:true},
            {label: 'Shares', fieldName: 'claimedShares', type: 'number',sortable:true},
            {label: '1st Coll Date', fieldName: 'firstCollectionDate', type: 'date',sortable:true},
            {label: 'Contrib. Amount', fieldName: 'cycleContributionAmount', type: 'number',sortable:true},
            {label: 'No. of Staff', fieldName: 'numberOfStaff', type: 'number',sortable:true},
            { type: 'action', typeAttributes: { rowActions: rowLevelActions } } 
        ]);
        
        //component.set('v.customerId', '1258254');
        // component.set('v.customerId', '1108487');
        var customerId = component.get('v.customerId');
        if (customerId) {
            helper.loadData(component, customerId);
        }
    },
    load: function (component, event, helper) {
        var customerId = component.get('v.customerId');
        helper.loadData(component, customerId);
    },
    
    handleRowAction: function (component, event, helper) {
        
        var action = event.getParam('action');
        var row = event.getParam('row'); 
        switch (action.name) {
            case 'stop_jamiyah': 
                console.log('row>>>>>>', row);
                component.set('v.stopJamiyah', row);
                //alert( component.get('v.stopJamiyah'));
                helper.handleLoad(component);
                //helper.generateNewCase(component);
                component.find('stop-jamiyah-popup').open();
                break;
            case 'freeze':
                break;
        }
    },    

    closeStopJamiyahPopup: function (component) {
        component.find('stop-jamiyah-popup').close();
    },
    stopJamiyah:function(component, event, helper){
        helper.doStopJamiyah(component);
    },
    handleRowSelection: function (component, event, helper) {
        var customerId = component.get('v.customerId');
        var selectedRows = event.getParam('selectedRows');
        // Display that id of the selected row
        for (var i = 0; i < selectedRows.length; i++){
            var jameyaId = selectedRows[i].id;
            console.log("---------On selection jameyaId--------", jameyaId);

            helper.openRecordDetails(component, customerId, jameyaId);
            //CH01: Start
            var enableAuditComp = $A.get("$Label.c.ENABLE_AUDIT_COMPONENT");
            if(enableAuditComp == 'true'){
                helper.loadDataInAuditObject(component,jameyaId);
            }
            //CH01: END
            break;
        }
    },    
   
	updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    handleOnSuccess : function(component, event, helper) {
    var record = event.getParam("response");
        console.log(record.caseNumber);
        component.set("v.newCaseId",record.id);
         var customerId = component.get('v.customerId');
        var toastEvent = $A.get("e.force:showToast");
    		toastEvent.setParams({
                "type":"success",
        		"title": "Success!",
        		"message": "The Case has been created successfully."
    		});
    		toastEvent.fire();
        	component.find("stop-jamiyah-popup").destroy();
        	
        	
        
        	var urlEvent = $A.get("e.force:navigateToURL");
    		urlEvent.setParams({
      		"url": "/"+record.id
    		});
    		urlEvent.fire();
        
            component.find('apexService').request(component.get('c.apexStopJamiyah'), {
            customerId : customerId, 
            isAdmin: record.Is_Organizer__c,
            newCaseId : component.get("v.newCaseId")
        },
        function(response){
            console.log('>>>>>>>doStopJamiyah res', response);
            component.find('stop-jamiyah-popup').close();
            component.set("v.loadingStopJamiyah", false);
            //component.set('v.recordTypId', response);
        
             $A.get('e.force:refreshView').fire();
        },
        function(resErr){
             component.set("v.loadingStopJamiyah", false);
        });
},
    handleOnSubmit : function(component, event, helper) {
        if(component.find("requestedByAdmin").get("v.value")){
            //component.find("closureReason").set("v.value","Approved");
        }    
        
        //component.find("accId").set("v.value", component.get("v.recordId"));
        //component.find("recId").set("v.value",component.get("v.recordTypId"));
},
    handleOnload : function(component, event, helper) {
        /*if(component.get('v.stopJamiyah') != 'undefined'){
           var selectedJamiyah = component.get('v.stopJamiyah'); 
        }
        component.find("jamiyahId").set("v.value",selectedJamiyah.id.toString());
        component.find("isOrganiser").set("v.value",selectedJamiyah.isOrganiser); 
        */
    }
    
})
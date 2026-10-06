({
	init : function(component, event, helper) {
		var recordId = component.get('v.recordId');
        console.log("recordId ",recordId);
        component.set("v.columns", [
            { label: 'S.No', fieldName: 'sno', type: 'text',fixedWidth:70 },
            { label: 'Doc Name', fieldName: 'contentName', type: 'text',width:120 },
            { label: 'File Name', fieldName: 'fileName', type: 'text',width:150 },
            { label: 'File Size', fieldName: 'fileSize', type: 'text',width:110 }, 
            { label: 'Last Modified Date', fieldName: 'lastModifiedDate', type: 'text',width:170 },
            { label: 'Owner', fieldName: 'ownerName', type: 'text',width:110 },
            { label: 'Source', fieldName: 'caseNumber', type: 'text',width:130 },
            {
                type: 'action',
                typeAttributes:{
                    rowActions:[
                        { label: 'View', name: 'view'},
                        { label: 'Download', name: 'download'}
                    ]
                }
            }
        ]);
        
        
        helper.loadDocumentdata(component, event, helper);
	},
    handleRowAction:function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        
        console.log('row data ',JSON.stringify(row));
        console.log('action data ',action);
        
        if(action.name == 'view'){
            window.open(row.documentURL,'_blank');
        }
        else if(action.name == 'download'){
            window.open('/sfc/servlet.shepherd/document/download/' + row.contentDocumentId,'_blank');
        }
    }
})
({
	init : function(component, event, helper) {
        helper.initDateFields(component);
		helper.loadIlaAccountList(component);
        helper.loadAlburaqAccountList(component);
        component.set("v.columns", [
            { label: 'Reference', fieldName: 'reference', type: 'text' },
            { label: 'Description', fieldName: 'transactionDescription1', type:'text'},
            { label: 'Type', fieldName: 'transactionType', type: 'text',fixedWidth:90 },
            { label: 'Amount', fieldName: 'originalAmount', type: 'text',fixedWidth:110 }, 
            { label: 'Date', fieldName: 'transactionDate', type: 'text',fixedWidth:110 } 
        ]);
	},
    handleOnSubmit: function (component, event, helper) {
        const file = component.get("v.waiverFile");
        component.set("v.claimAmountError",false); 
        component.set("v.isTransRef",false);
        debugger;
        event.preventDefault();
        
        let transRef = component.get("v.selectedReference");
        if(!transRef){
            component.set("v.isTransRef",true);
            return;
        }
        let claimAmount = parseFloat(component.find("claimAmount").get("v.value"));
        let totalAmount = parseFloat(component.get("v.totalAmount"));
        if(claimAmount > totalAmount){
        	component.set("v.claimAmountError",true);    
        }
        else {
            helper.showSpinner(component);
            helper.saveWaiverWithFile(component,event);
        }
        //
        /*
        //Below code would only execute when a file is attach for uploading.
        if(file){
        	const maxSize = 25 * 1024 * 1024; // 25 MB
            const fileReader = new FileReader();
            fileReader.onload = function(){
                const base64 = fileReader.result.split(',')[1];
                helper.saveWaiverWithFile(component,event,base64);
            }
            fileReader.readAsDataURL(file);
        }
        else {
            helper.saveWaiverWithFile(component,event,"");
        }*/
    },
    handleOnSuccess: function (component, event, helper) {
    	helper.hideSpinner(component);
        
        //navigating the newly created record.
        var navEvt = $A.get("e.force:navigateToSObject");
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "mode" : "dismissible",
            "type" : "success",
            "title" : "Success!",
            "message" : "Waiver Case has been created successfully."
        });
        toastEvent.fire();
        
        navEvt.setParams({
            "recordId": event.getParam("response").id,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    handleOnError: function (component, event, helper) {
        helper.hideSpinner(component);
    },
    onCancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleFileChange: function(component, event){
        const file = event.getSource().get("v.files")[0];
        component.set("v.fileSizeError","");
        component.set("v.isDisabled",false);
        const maxSize = 25 * 1024 * 1024; // 25 MB
        if (file.size > maxSize) {
        	component.set("v.fileSizeError","File size cannot be more than 25 MB.");
            component.set("v.isDisabled",true);
        }
        else {
            component.set("v.waiverFile",file);
        	component.set("v.waiverFileName",file.name);
        }
    },
    handleUploadFinished : function(component, event, helper) {
    	const uploadedFiles = event.getParam("files");
        console.log("Uploaded file(s): ", uploadedFiles);
        component.set("v.contentDocumentId",uploadedFiles[0].documentId);
        var docIds = component.get("v.documentIdList");
        docIds.push(uploadedFiles[0].documentId);
        component.set("v.documentIdList",docIds);
        helper.validateFileSize(component, event, uploadedFiles[0].name);
    },
    handleAccountChange : function(component, event, helper){
        var selectedAccountValue = event.getSource().get("v.value");
        component.set("v.selectedAccount",selectedAccountValue);
        console.log("selectedAccountValue ",selectedAccountValue);
        if(selectedAccountValue != 'none'){
            const arrCustomerDetails = selectedAccountValue.split(';');
            helper.getAccountTransaction(component,arrCustomerDetails[0],arrCustomerDetails[1]);
        }
    },
    onSearchClick : function(component, event, helper){
        
    },
    fromDateChanged : function(component, event, helper){
        var selectedDate = component.get("v.selectedDateFrom");
        console.log('selectedDate from ',selectedDate);
    },
    toDateChanged : function(component, event, helper){
        var selectedDate = component.get("v.selectedDateTo");
        console.log('selectedDate to ',selectedDate);
    },
    searchFilterClicked : function(component, event, helper){
        component.set("v.filterError","");
        var selectedDateFrom = component.get("v.selectedDateFrom");
        var selectedDateTo = component.get("v.selectedDateTo");
        var datePartsFrom = selectedDateFrom.split("-");
        var datePartsTo = selectedDateTo.split("-");
        var selectedFrom = new Date(datePartsFrom[0],datePartsFrom[1] - 1,datePartsFrom[2]);
        var selectedTo = new Date(datePartsTo[0],datePartsTo[1] - 1,datePartsTo[2]);
        selectedFrom.setHours(0, 0, 0, 0);
        selectedTo.setHours(0, 0, 0, 0);
        
        if(selectedTo < selectedFrom){
            component.set("v.filterError","To Date cannot be earlier than From Date.");
            return;
        }
        
        //max date one month range only.
        var maxDate = new Date(selectedFrom);
        maxDate.setMonth(maxDate.getMonth() + 1);
        
        if(selectedTo > maxDate){
            component.set("v.filterError","From Date and To Date must be within one month.");
            return;
        }
        
        var selectedAccountValue = component.get("v.selectedAccount");
        const arrCustomerDetails = selectedAccountValue.split(';');
        helper.getAccountTransaction(component,arrCustomerDetails[0],arrCustomerDetails[1]);
    },
    handleTransactionCellChange : function(component, event, helper){
    	var currentRows = event.getParam("selectedRows") || [];
	    var previousIds = component.get("v.selectedRows") || [];
        
        var currentIds = currentRows.map(function(row) {
            return row.rowNo;
        });
        
        let selectedRow = null;
        let isSelected = false;
        let isDeselected = false;
        
        if(currentRows.length > previousIds.length){
            //row is selected.
            console.log('row is selected.');
            let newRowReference = '';
            for(let i = 0; i < currentRows.length; i++){
                
                if(!previousIds.includes(currentRows[i].rowNo)){
                    newRowReference = currentRows[i].reference;
                    break;
                }
            }
            
            if(previousIds.length == 0){ //considering the first record.
                newRowReference = currentRows[0].reference;
            }
            
            let arrReferences = [];
            let rowsToSelect = [];
            let totalAmount = 0;
            if(newRowReference){
            	let allData = component.get("v.transactionData");
                for(let i = 0; i < allData.length; i++){
                	if(newRowReference == allData[i].reference){
                    	rowsToSelect.push(allData[i].rowNo);
                        arrReferences.push(allData[i].reference);
                        totalAmount += allData[i].originalAmount;
                    }
                }
            }
            component.set("v.selectedReference",arrReferences.join(","));
            component.set("v.totalAmount",`${totalAmount}`);
            component.set("v.selectedRows", rowsToSelect);
        }
        else{
            //row is deselected.
            console.log('row is deselected.');
            let arrReferences = [];
            let totalAmount = 0;
            for(let i = 0; i < currentRows.length; i++){
                arrReferences.push(currentRows[i].reference);
                totalAmount += currentRows[i].originalAmount;
            }
            
            component.set("v.selectedReference",arrReferences.join(","));
	        component.set("v.totalAmount",`${totalAmount}`);
            component.set("v.selectedRows", currentIds);
        }
        
        
        /*
        let allData = component.get("v.transactionData");
        for(let i = 0; i < allData.length; i++){
            if(allData[i].reference == referenceNo && !rowsToSelect.includes(allData[i].id)){
                rowsToSelect.push(allData[i].id);
                arrReferences.push(allData[i].reference);
                totalAmount += allData[i].originalAmount;
            }
        }*/ 
        
        
        /*
        // Find the row whose selection state changed
        var changedRow = null;
        var isSelected = false;
    
        // Check for newly selected row
        currentIds.forEach(function(id) {
            if (previousIds.indexOf(id) === -1) {
                changedRow = currentRows.find(function(row) {
                    return (row.Id || row.id) === id;
                });
                isSelected = true;
            }
        });
    
        // Check for newly unselected row
        previousIds.forEach(function(id) {
            if (currentIds.indexOf(id) === -1) {
                changedRow = component.get("v.data").find(function(row) {
                    return (row.Id || row.id) === id;
                });
    
                isSelected = false;
            }
        });
    
        if (changedRow) {
            console.log("Changed Row:", changedRow);
            console.log("Reference:", changedRow.reference);
            console.log("Is Selected:", isSelected);
    
            if (isSelected) {
                console.log("USER SELECTED THE ROW");
            } else {
                console.log("USER UNSELECTED THE ROW");
            }
        }
    	*/
        // Save current selection for next event
        
    },
    handleTransactionCellChange1 : function(component, event, helper){
        debugger;
        var selectedRows = event.getParam('selectedRows');
        let allData = component.get("v.transactionData");
		
		var previousSelectionRows = new Set(component.get("v.selectedRows")); 
        if(selectedRows.length === 0){
            component.set("v.selectedRows", []);
            component.set("v.selectedReference","");
	        component.set("v.totalAmount","");
            return;
        }
        
        var currentSelectedIds = selectedRows.map(function(row) {
            return row.Id || row.id;
        });
        
        var previousSelectedIds = component.get("v.prevSelectedRows");
        
        var newlySelectedId = currentSelectedIds.find(function(id) {
            return previousSelectedIds.indexOf(id) === -1;
        });
        
        var newlySelectedRow = selectedRows.find(function(row) {
            const rowId = row.Id || row.id;
            return rowId === newlySelectedId;
        });
        
        
        
        
        
        // Get the specific row that was toggled
        //var config = event.getParam('config');
        console.log('Selected Row:', selectedRows);
        const arrReferences = [];
        let rowsToSelect = [];
        let totalAmount = 0;

		for(let i = 0; i < selectedRows.length; i++){
            rowsToSelect.push(selectedRows[i].id);
            arrReferences.push(selectedRows[i].reference);
            totalAmount += selectedRows[i].originalAmount;
        }
        
        //Below code would only execute when user selects a new row.
        if(previousSelectionRows.size == 0 || selectedRows.length > previousSelectionRows.size){
         	
            // First selected row
        	let referenceNo = newlySelectedRow.reference;
            
            //getting referenceno from newly selected rows.
            if(previousSelectionRows.size != 0){
            	const newRowSelected = selectedRows.filter(obj => !previousSelectionRows.has(obj.id));
                referenceNo = newRowSelected[0].reference; //there should always be a one record.
	            console.log('newly selected record ' + newRowSelected);    
            }
            
            
            for(let i = 0; i < allData.length; i++){
                if(allData[i].reference == referenceNo && !rowsToSelect.includes(allData[i].id)){
                    rowsToSelect.push(allData[i].id);
                    arrReferences.push(allData[i].reference);
            		totalAmount += allData[i].originalAmount;
                }
            }   
        }
        
        component.set("v.selectedRows", rowsToSelect);
        component.set("v.prevSelectedRows",currentSelectedIds);
        component.set("v.selectedReference",arrReferences.join(","));
        component.set("v.totalAmount",`${totalAmount}`);
    }
})
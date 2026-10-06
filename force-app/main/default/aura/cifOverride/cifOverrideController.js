({
	doInit : function(component, event, helper) {
        component.set("v.actionOptions", [
            {
                label: "View",
                value: "View"
            },
            {
                label: "Add",
                value: "Add"
            }
        ]);
        
        component.set("v.selectedAction", "View");
        // Datatable columns
        component.set("v.columns", [
            {
                label: "Created Date Timestamp",
                fieldName: "creationDatetime",
                type: "text",
                sortable: true
            },
            /*{
                label: "PCI Number",
                fieldName: "pciNumber",
                type: "text"
            },*/
            {
                label: "Performed By",
                fieldName: "whitelistedBy",
                type: "text"
            },
            {
                label: "From Date",
                fieldName: "fromDate",
                type: "text"
            },
            {
                label: "To Date",
                fieldName: "toDate",
                type: "text"
            },
            {
                label: "Expired",
                fieldName: "expired",
                type: "text"
            },
           
        ]);


        // Since View is selected by default,
        // call API immediately.
        helper.getWhitelistDetails(component);
		
	},
    handleActionChange : function(component, event, helper) {
		var selectedAction = component.get("v.selectedAction");
		console.log("Selected Action:", selectedAction);
        console.log("Selected Action:",selectedAction);
		if(selectedAction === "View") {
            component.set("v.isWhitelistSuccess",false);
            component.set("v.fromDate",null);
            component.set("v.toDate",null);
			// Call View API
            helper.getWhitelistDetails(component);
		}else if(selectedAction === "Add") {
			// Clear View information
            component.set("v.whitelistData",[]);
			component.set("v.errorMessage",null);
            // Clear previous dates
            component.set("v.fromDate", null);
            component.set("v.toDate", null);
		}
    },
    handleWhitelist : function(component, event, helper) {
        /*var fromDate = component.get("v.fromDate");
        var toDate = component.get("v.toDate");
        console.log("From Date:", fromDate);
        console.log("To Date:", toDate);*/
    
        // We will implement the Whitelist API call here
        helper.createWhitelist(component);
    },
    handleSort : function(component, event, helper) {
        var fieldName = event.getParam("fieldName");
        console.log('Field Name:',fieldName);
    
        var sortDirection = event.getParam("sortDirection");
        console.log('Sort Direction:',sortDirection);

        // Maintain the selected column
        component.set("v.sortedBy",fieldName);
    
        // Maintain the selected direction
        component.set("v.sortedDirection",sortDirection);
        helper.sortData(component,fieldName,sortDirection);
    }
})
({
	doInit : function(component, event, helper) {
        console.log('Inside init method of History Logs component');
    	console.log('sobjectName==> '+component.get('v.sObjectName'));
        // Set today's date
        var today = new Date();

        var year = today.getFullYear();

        var month = String(today.getMonth() + 1).padStart(2, '0');

        var day = String(today.getDate()).padStart(2, '0');

        var formattedDate = year + '-' + month + '-' + day;

        component.set("v.selectedDate", formattedDate);


        // Define datatable columns
        component.set("v.columns", [

            {
                label: "Payment Timestamp",
                fieldName: "paymentTimestamp",
                type: "text",
                sortable: true
            },

            {
                label: "Card Number",
                fieldName: "cardNumber",
                type: "text"
            },

            {
                label: "Payment Amount",
                fieldName: "paymentAmount",
                type: "text"
            },
            {
                label: "Remaining Limit Amount",
                fieldName: "remainingDailyLimit",
                type: "text"
            },

            
			{
                label: "Status",
                fieldName: "status",
                type: "text"
            }

        ]);


        // Load mock history response
        //helper.loadMockData(component);
        helper.getHistoryLogs(component,event,helper);
		
	},
    handleDateChange : function(component, event, helper) {

        var selectedDate = event.getSource().get("v.value");

        console.log("Selected Date:", selectedDate);

        component.set("v.selectedDate", selectedDate);

        // Filter records based on selected date
        //helper.filterHistoryByDate(component);
        helper.getHistoryLogs(component,event,helper);
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
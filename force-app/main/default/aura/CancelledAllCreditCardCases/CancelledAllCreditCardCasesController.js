({
	doInit : function(component, event, helper) {
        component.set("v.columns", [
            { label: 'Sno', fieldName: 'serialNumber', type: 'number', sortable: false,initialWidth: 75,
            cellAttributes: { alignment: 'center' }},
            { label: 'Case Number', fieldName: 'caseLink', type: 'url', sortable: true, 
            typeAttributes: { 
            	label: { fieldName: 'CaseNumber' }, 
            	target: '_blank' 
        	} 
            },
            { label: 'Subject', fieldName: 'Subject', type: 'text',sortable: true, },
            { label: 'Type', fieldName: 'Type', type: 'text',sortable: true, },
            { label: 'Sub Type', fieldName: 'Sub_Type__c', type: 'text',sortable: true, },
            { label: 'Status', fieldName: 'Status', type: 'text',sortable: true, },
            { label: 'Sub Status', fieldName: 'Sub_Status__c', type: 'text',sortable: true, },
            
            { label: 'Date/Time Opened', fieldName: 'CreatedDate', type: 'date', sortable: true,
            typeAttributes: {
            	 year: "numeric", 
            	 month: "short", 
                 day: "2-digit", 
            	 hour: "2-digit", 
            	 minute: "2-digit" 
            } 
            },

    		{ label: 'Date/Time Closed', fieldName: 'ClosedDate', type: 'date', sortable: true,
      		typeAttributes: { 
            	year: "numeric", 
                month: "short", 
            	day: "2-digit", 
            	hour: "2-digit", 
            	minute: "2-digit" 
            } 
            },

    		{ label: 'Owner', fieldName: 'OwnerName', type: 'text', sortable: true }
            
        	]);
        
        
        // Get the recordId from URL state
        var myPageRef = component.get("v.pageReference");
        if (myPageRef && myPageRef.state && myPageRef.state.c__recordId) {
            component.set("v.recordId", myPageRef.state.c__recordId);
        }
        
        
        // Set proper tab title and icon
        var workspaceAPI = component.find("workspace");
        if (workspaceAPI) {
            workspaceAPI.getEnclosingTabId().then(function(tabId) {
                workspaceAPI.setTabLabel({
                    tabId: tabId,
                    label: "Cancelled Credit Card Cases"
                });
                workspaceAPI.setTabIcon({
                    tabId: tabId,
                    icon: "utility:error",
                    iconAlt: "Cancelled Cases"
                });
            }).catch(function(error) {
                console.log('Error setting tab properties:', error);
            });
        }
		helper.fetchCases(component);
        helper.getContactDetails(component);
    },
    
    handleSort : function(component, event, helper) {
        var fieldName = event.getParam("fieldName");
        let sortDirection = event.getParam("sortDirection");

        component.set("v.sortedBy", fieldName);
        component.set("v.sortDirection", sortDirection);

        helper.sortData(component, fieldName, sortDirection);
    },
    filterByStatus: function(component, event, helper) {
        let selectedStatus = component.get("v.statusFilter");
        let allCases = component.get("v.allFiltercaseData");
        let filtered = [];

        if (selectedStatus === "") {
            filtered = allCases;
        } else {
            filtered = allCases.filter(function(c) {
                return c.Type === selectedStatus;
            });
        }

        component.set("v.allCases", filtered);
    }

})
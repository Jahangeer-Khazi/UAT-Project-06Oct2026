({
	doInit : function(component, event, helper) {
        component.set("v.columns", [
            { label: 'Case Number', fieldName: 'caseLink', type: 'url', 
            typeAttributes: { 
            	label: { fieldName: 'CaseNumber' }, 
            	target: '_blank' 
        	} 
            },
            /*{ label: 'Subject', fieldName: 'Subject', type: 'text' },
            { label: 'Type', fieldName: 'Type', type: 'text' },
            { label: 'Sub Type', fieldName: 'Sub_Type__c', type: 'text' },
            { label: 'Status', fieldName: 'Status', type: 'text' },*/
            { label: 'Sub Status', fieldName: 'Sub_Status__c', type: 'text' },
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
            }
            
        ]);
	     helper.fetchCases(component);
	},
    navigateToRelatedList : function(component, event, helper) {
        event.preventDefault();
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__CancelledAllCreditCardCases'
            },
            state: {
                c__recordId: component.get("v.recordId")
            }
        };
        var navService = component.find("navService");
        if (navService) {
            navService.navigate(pageReference);
        } else {
            console.error('Navigation service not found');
            // Fallback to your original method if needed
            var navEvt = $A.get("e.force:navigateToComponent");
            navEvt.setParams({
                componentDef: "c:CancelledAllCreditCardCases",
                componentAttributes: {
                    recordId: component.get("v.recordId")
                }
            });
            navEvt.fire();
        }
    }
    
})
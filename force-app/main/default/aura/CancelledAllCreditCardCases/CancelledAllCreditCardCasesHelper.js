({
    fetchCases : function(component) {
        var action = component.get("c.getCreditCardCancelledCases");
        action.setParams({ caseId: component.get("v.recordId") });

        action.setCallback(this, function(response){
            if (response.getState() === "SUCCESS") {
                let cases = response.getReturnValue();
                cases.forEach(function(item,index){
                    //item.caseLink = '/' + item.Id;
                    item.serialNumber = index + 1;
                    item.caseLink = '/lightning/r/Case/' + item.Id + '/view';
                    item.CaseNumberInt = parseInt(item.CaseNumber.replace(/^0+/, '')); // numeric sort field
					item.OwnerName = item.Owner.Name;
                });
                component.set("v.allCases", cases);
                component.set("v.recordCount", cases.length);
                component.set("v.allFiltercaseData", cases);
             }
            
        });

        $A.enqueueAction(action);
    },
    getContactDetails: function(component) {
        const action = component.get("c.getContactFromRecord");
        action.setParams({ cseId: component.get("v.recordId") });

        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const contact = response.getReturnValue();
                component.set("v.contactName", contact.Name);
                component.set("v.contactId", contact.Id);
            }
        });
        $A.enqueueAction(action);
    },
    sortData : function(component, fieldName, sortDirection) {
        var data = component.get("v.allCases");
        var reverse = sortDirection !== 'asc';
		//numeric sort for CaseNumber
        let actualField = fieldName === 'caseLink' ? 'CaseNumberInt' : fieldName;
        data.sort(this.sortBy(actualField, reverse));
        component.set("v.allCases", data);
        
    },

    /*sortBy : function(field, reverse) {
        var key = function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },*/
    sortBy: function(field, reverse, primer) {
        const key = primer
        ? function(x) { return primer(x[field]); }
        : function(x) { return x[field]; };
        
        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse ? ((a > b) ? -1 : ((a < b) ? 1 : 0)) : ((a < b) ? -1 : ((a > b) ? 1 : 0));
        };
    }
})
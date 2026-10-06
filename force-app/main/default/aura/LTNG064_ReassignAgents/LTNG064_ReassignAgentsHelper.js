({setupDataTable: function (component) {
        component.set('v.columns', [
                {label: 'Subject', fieldName: 'Subject', type: 'text'},
            	{label: 'Customer Name', fieldName: 'Contact_Name__c', type: 'text'},
                {label:'CIF', fieldName:'Customer_CIF__c', type:'text'},
                {label: 'Open Date', fieldName:'CreatedDate', type: 'date-local'},
            	{label: 'Status', fieldName: 'Status', type: 'text'},  
                {label: 'Request Type', fieldName: 'Type', type: 'text'}
            ]);
    },
   /* getData : function(cmp) {
        var action = cmp.get('c.getCases');
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.mydata', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },*/
  getReassignQueue:function(component, event, helper) {
        var action = component.get("c.getCCqueue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Populate the attribute with the list from Apex
                component.set("v.optionsList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    AssignSA:function(cmp) {
        var action = cmp.get('c.assignCases');
        action.setParams({"assignedSA":cmp.get("v.CCApplication")});
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
             /*  cmp.set("v.isModalOpen", false);
               cmp.set("v.isAssignTo", false);
            var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewId": '00B7Y000004JNloUAG',
                "listViewName": null,
                "scope": "Case"
            });
            navEvent.fire();*/
            cmp.set("v.isLoading",false);
             $A.get('e.force:showToast').setParams
                ({
                  "title": "",
                   "message": "successfully reassigned to Queue",
                   "type": "success",
                }).fire();
              $A.get('e.force:refreshView').fire();
            } else if (state === "ERROR") {
                $A.get('e.force:showToast').setParams
                ({
                  "title": "",
                   "message": "failed during assignment,Please try again later",
                   "type": "error",
                }).fire();
              $A.get('e.force:refreshView').fire();
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },
helperFun : function(component,event,secId) {
var acc = component.find(secId);
for(var cmp in acc) {
$A.util.toggleClass(acc[cmp], 'slds-show');
$A.util.toggleClass(acc[cmp], 'slds-hide');
}
},
   getData: function (component) {
        return this.callAction(component)
            .then(
                $A.getCallback(caseRecords => {
                    component.set('v.allData', caseRecords);
                    component.set('v.filteredData', caseRecords);
                    this.preparePagination(component, caseRecords);
                })
            )
            .catch(
                $A.getCallback(errors => {
                    if (errors && errors.length > 0) {
                        $A.get("e.force:showToast")
                            .setParams({
                                message: errors[0].message != null ? errors[0].message : errors[0],
                                type: "error"
                            })
                            .fire();
                    }
                })
            );
    },
 
    callAction: function (component) {
        component.set("v.isLoading", true);
        return new Promise(
            $A.getCallback((resolve, reject) => {
                const action = component.get("c.getCases");
                var agentid= component.get("v.value");                
                action.setParams({"AgentId":agentid});
                action.setCallback(this, response => {
                    component.set("v.isLoading", false);
                    const state = response.getState();
                    if (state === "SUCCESS") {
                        return resolve(response.getReturnValue());
                    } else if (state === "ERROR") {
                        return reject(response.getError());
                    }
                    return null;
                });
                $A.enqueueAction(action);
            })
        );
    },
 
    preparePagination: function (component, imagesRecords) {
        let countTotalPage = Math.ceil(imagesRecords.length/component.get("v.pageSize"));
        let totalPage = countTotalPage > 0 ? countTotalPage : 1;
        component.set("v.totalPages", totalPage);
        component.set("v.currentPageNumber", 1);
        this.setPageDataAsPerPagination(component);
    },
 
    setPageDataAsPerPagination: function(component) {
        let data = [];
        let pageNumber = component.get("v.currentPageNumber");
        let pageSize = component.get("v.pageSize");
        let filteredData = component.get('v.filteredData');
        let x = (pageNumber - 1) * pageSize;
        for (; x < (pageNumber) * pageSize; x++){
            if (filteredData[x]) {
                data.push(filteredData[x]);
            }
        }
        component.set("v.tableData", data);
    },
 
    searchRecordsBySearchPhrase : function (component) {
        let searchPhrase = component.get("v.searchPhrase");
        let requestType = component.get("v.RequestType");
        let filterdate = component.get("v.pending");
       // alert('filterdate##'+filterdate);
       // alert('searchPhrase##'+searchPhrase);
        //alert('requestType##'+requestType);
        if (!$A.util.isEmpty(searchPhrase) && requestType!='None') {
            let allData = component.get("v.allData");
            let filteredData = allData.filter(record => record.Contact_Name__c.toLowerCase().includes(searchPhrase.toLowerCase()));
            if($A.util.isEmpty(filteredData)){
              filteredData = allData.filter(record => record.Customer_CIF__c.includes(searchPhrase));  
            }
   
            filteredData = filteredData.filter(record =>record.Type.includes(requestType));
            if(filterdate){
                var d = new Date(); // today!
				var x = 20; // go back 5 days!
				d.setDate(d.getDate() - x);
                filteredData = filteredData.filter(record =>record.Sub_Status__c.includes('Pending'));
                filteredData = filteredData.filter(record =>record.CreatedDate < d);
            }
            component.set("v.filteredData", filteredData);
            this.preparePagination(component, filteredData);
        }else if(!$A.util.isEmpty(searchPhrase) && requestType =='None'){
            let allData = component.get("v.allData");
            let filteredData = allData.filter(record => record.Contact_Name__c.toLowerCase().includes(searchPhrase.toLowerCase()));
            if($A.util.isEmpty(filteredData)){
              filteredData = allData.filter(record => record.Customer_CIF__c.includes(searchPhrase));  
            }
              if(filterdate){
               var d = new Date(); // today!
				var x = 20; // go back 5 days!
				d.setDate(d.getDate() - x);
                filteredData = filteredData.filter(record => record.Sub_Status__c.includes('New'));
                filteredData = filteredData.filter(record =>record.CreatedDate < d);
            }
            component.set("v.filteredData", filteredData);
            this.preparePagination(component, filteredData);
        }else if($A.util.isEmpty(searchPhrase) && requestType !='None'){
            let allData = component.get("v.allData");
            let filteredData = allData.filter(record => record.Type.includes(requestType));
              if(filterdate){
                 var d = new Date(); // today!
				 var x = 20; // go back 5 days!
				 d.setDate(d.getDate() - x);
                filteredData = filteredData.filter(record =>record.Sub_Status__c.includes('Pending'));
                filteredData = filteredData.filter(record =>record.CreatedDate < d);
            }
            component.set("v.filteredData", filteredData);
            this.preparePagination(component, filteredData);
        }
    },
        _timer: null,

    debounceSearch : function(component) {
        const helper = this;
        if (helper._timer) {
            clearTimeout(helper._timer);
        }
        helper._timer = setTimeout($A.getCallback(function(){
            helper.search(component);
        }), 250);
    },

    search : function(component) {
        const key = component.get("v.searchKey") || '';
        if (key.trim().length < 2) {
            component.set("v.results", []);
            return;
        }
        const action = component.get("c.searchUsers");
        action.setParams({ searchKey: key });
        action.setCallback(this, function(resp) {
            if (resp.getState() === "SUCCESS") {
                component.set("v.results", resp.getReturnValue());
            } else {
                component.set("v.results", []);
                // Optionally surface errors
                // const errors = resp.getError();
            }
        });
        $A.enqueueAction(action);
    }
})
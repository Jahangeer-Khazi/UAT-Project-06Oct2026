({
    init: function (cmp, event, helper) {
        //helper.getData(cmp);
        helper.setupDataTable(cmp);
        helper.getReassignQueue(cmp);
         cmp.set("v.results", []);
    },
    getSelectedId:function (cmp,event,helper){
        let selectedRows = [];
        selectedRows = cmp.find('caseTable').getSelectedRows();
        // Display that fieldName of the selected rows
        //    for (var i = 0; i < selectedRows.length; i++){
        //        alert("You selected: " + selectedRows[i].Id);
        //    }
        if(selectedRows.length>0){
            cmp.set("v.isAssignTo",true);
            cmp.set("v.CCApplication",selectedRows);
        }
    },
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        component.set("v.isAssignTo", false);
        var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
               // "listViewId": '00B3N000007moOaUAI',
                "listViewName": 'Sales_Support_Team',
                "scope": "Case"
            });
            navEvent.fire();
    },
    assignSalesAgent: function(component, event, helper){
        let selectedRows = [];
        selectedRows = component.find('caseTable').getSelectedRows();
        component.set("v.isLoading",true);
        var salesAgnt = component.get("v.salesagent");
        for (var i = 0; i < selectedRows.length; i++){
            selectedRows[i].Sales_Agent__c=component.get("v.salesagent");
        }
        //alert(JSON.stringify(salesAgnt));
        if(selectedRows.length>0 && salesAgnt){
        component.set("v.CCApplication",selectedRows);
        helper.AssignSA(component, event);  
        }else if(selectedRows.length==0){
            $A.get('e.force:showToast').setParams
                ({
                  "title": "",
                   "message": "Please select atleast one applications for assignment",
                   "type": "warning",
                }).fire();
            component.set("v.isLoading",false);
        }else if(!salesAgnt){
             $A.get('e.force:showToast').setParams
                ({
                  "title": "",
                   "message": "Please select an Sales Agent for assignment",
                   "type": "warning",
                }).fire();
            component.set("v.isLoading",false);
        }
    },
    sectionOne : function(component, event, helper) {
        helper.helperFun(component,event,'articleOne');
    },
    onNext: function(component, event, helper) {        
        let pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber + 1);
        helper.setPageDataAsPerPagination(component);
    },
    
    onPrev: function(component, event, helper) {        
        let pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber - 1);
        helper.setPageDataAsPerPagination(component);
    },
    
    onFirst: function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.setPageDataAsPerPagination(component);
    },
    
    onLast: function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.setPageDataAsPerPagination(component);
    },
    
    onPageSizeChange: function(component, event, helper) {        
        helper.preparePagination(component, component.get('v.filteredData'));
    },
    
    onChangeSearchPhrase : function (component, event, helper) {
        if ($A.util.isEmpty(component.get("v.searchPhrase"))) {
            let allData = component.get("v.allData");
            component.set("v.filteredData", allData);
            helper.preparePagination(component, allData);
        }
    },
    
    handleSearch : function (component, event, helper) {
       // helper.searchRecordsBySearchPhrase(component);
        helper.getData(component);
    },
    selectedType : function(component, event, helper) {
        component.set('v.RequestType',component.find("typePicklist").get("v.value"));
        //alert();
    },
    onCheck : function(component, event, helper){
        
      var checkCmp1 =component.find("checkbox").get("v.value");
      component.set('v.pending',checkCmp1);
    },
    onKeyUp : function(component, event, helper) {
        helper.debounceSearch(component);
    },
    onChange : function(component, event, helper) {
        helper.debounceSearch(component);
    },
    select : function(component, event, helper) {
        // Retrieve the clicked User's Id and full object from the rendered element
         const userId = event.currentTarget.getAttribute("data-id");
        const results = component.get("v.results") || [];
        const selected = results.find(u => u.Id === userId);
        //const elt = event.currentTarget;
        //alert(elt);
        // Get the inner hiddenId value:
        //const idSpan = elt.querySelector('.hiddenId'); // ui:outputText renders a span
       // alert(idSpan);
       // const userId = idSpan ? idSpan.textContent : null;
       // const results = component.get("v.results") || [];
      //  const selected = results.find(u => u.Id === userId);
        if (selected) {
            component.set("v.selectedUser", selected);
            component.set("v.value", selected.Id);
            component.set("v.results", []);
        }
    },
    clearSelection : function(component, event, helper) {
        component.set("v.selectedUser", null);
        component.set("v.value", null);
        // keep the searchKey for convenience, or clear if preferred:
        // component.set("v.searchKey", "");
    },
     ReassigntoQueue: function(component, event, helper){
        let selectedRows = [];
        selectedRows = component.find('caseTable').getSelectedRows();
        var queueId = component.find('queuelist').get('v.value');
        component.set("v.isLoading",true);
        for (var i = 0; i < selectedRows.length; i++){
            selectedRows[i].Status='Reassign to New Agent';
            alert('OwnerId'+queueId);
            selectedRows[i].OwnerId=queueId;
        }
        //alert(JSON.stringify(salesAgnt));
        if(selectedRows.length>0 && queueId){
        component.set("v.CCApplication",selectedRows);
        helper.AssignSA(component, event);  
        }else if(selectedRows.length==0){
            $A.get('e.force:showToast').setParams
                ({
                  "title": "",
                   "message": "Please select atleast one applications for assignment",
                   "type": "warning",
                }).fire();
            component.set("v.isLoading",false);
        }else if(!queueId){
             $A.get('e.force:showToast').setParams
                ({
                  "title": "",
                   "message": "Please select an Queue to Reassign",
                   "type": "warning",
                }).fire();
            component.set("v.isLoading",false);
        }
    }
})
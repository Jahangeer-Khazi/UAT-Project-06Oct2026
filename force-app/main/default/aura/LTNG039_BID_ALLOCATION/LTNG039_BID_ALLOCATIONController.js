({
	doInit: function (component, event, helper) {
        helper.doInit(component, event, helper);
        helper.loadInstrument(component,event,helper);
           component.set('v.columns', [
            {label: 'ISIN Code', fieldName: 'bs_ISIN_Code', type: 'text',sortable:true},
            {label: 'ISIN Name', fieldName: 'bs_ISIN_Type', type: 'text',sortable:true},
            {label: 'Bid Due Date', fieldName: 'bs_Bid_Due_Date', type: 'text',sortable:true}
        ]);
    } ,
    GenerateBID: function (component, event, helper) {
        console.log('handleOnSubmit');
        console.error(component.get('v.recordTypeId'));
       // var fields = event.getParam('fields');
        //fields['ISIN_Code__c']=component.find("ISINCODE").get("v.value");
        //component.find('form').submit(fields);
        helper.GenerateBIDAllocation(component,event,helper);
        helper.showSpinner(component);
    },
     closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        var navEvent = $A.get("e.force:navigateToList");
            navEvent.setParams({
                "listViewId": '00BPw000001eUurMAE',
                "listViewName": null,
                "scope": "Bid_Allocation__c"
            });
            navEvent.fire();
    },
     handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var customerId = component.get('v.customerId');
        switch (action.name) {
            case 'show_transactions':
                helper.openTransactionList(component, customerId, row.id);
                break;
        }
    },    
    handleRowSelection: function (component, event, helper) {
        var customerId = component.get('v.customerId');
        var selectedRows = event.getParam('selectedRows');
        // Display that id of the selected row
        for (var i = 0; i < selectedRows.length; i++){
            var instrumentId = selectedRows[i].ReferenceNo;
            var investmentId= selectedRows[i].investmentid;
            //CH02: Start
            var isinCode= selectedRows[i].ISINCode;
            var isinName=selectedRows[i].ISINName;
            //CH02: End
            console.log('==> selectedRows '+JSON.stringify(selectedRows[i]));

            //CH01: Start
         /*   var getAccountIdevent = $A.get("e.c:PassAccountIdEvent");
            if(getAccountIdevent){
                getAccountIdevent.setParams({
                    "globalAccountId": accountId
                    });
                var test = getAccountIdevent.getParam("globalAccountId");
                console.log("global account ID is set in Bank account list to  ", test);
                getAccountIdevent.fire();
            }*/

            //CH01: Added one parameter accountType
            helper.openInstrumentDetails(component, instrumentId,investmentId);
            //CH01: END
           // break;
        }
    }
})
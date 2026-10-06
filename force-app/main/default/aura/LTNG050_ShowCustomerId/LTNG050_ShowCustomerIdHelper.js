({
    doInit : function (component, event, helper, accId) {
        var action = component.get('c.getAccountDetails');
        action.setParams({
            recordId: component.get("v.recordId")
           
        });
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if (data) {
                    console.log('test==>>>'+data);
                    component.set("v.CIF",data.CIF__pc);
                    component.set("v.RegionFlag",data.Region_Flag__c);

                }
            } else if (statut === "ERROR") {
                // Process error returned by server
               console.log('error==> '+actionResult.getError());
            }
      
        });
        $A.enqueueAction(action);
    },
    SearchIban : function(component, event, helper) {

        // var accountDetail=component.get("v.account");
        console.log('************start SearchIban*************** ');
        console.log('testtt==> '+component.get("v.CIF"));
        console.log('testtt==> '+component.get("v.RegionFlag"));
		var searchTerm = component.get("v.searchTerm");
        console.log("search value >> "+searchTerm);
        helper.showSpinner(component, event, helper);
        var action = component.get("c.loadAccountDetails");
        action.setParams({
            //customerId: component.get("v.CIF"),
            accountId: searchTerm, 
            regionName: component.get("v.RegionFlag")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('response value '+result);
                if(result == null || result == ''){
                    component.set("v.searchResult", 'IBAN entered doesn’t belong to any CIF in CRM. Please try again.');
                    component.set("v.responseExist", false);
                }else{
                    component.set("v.searchResult", "CIF: "+result);
                    component.set("v.rawResult", +result);
                     component.set("v.responseExist", true);
                }
            } else {
                console.log("Error occurred: " + JSON.stringify( response.getError()));
            }
            helper.hideSpinner(component, event, helper);
        });

        $A.enqueueAction(action);
    },
    showSpinner: function (component, event, helper) {
        component.set("v.showSpinner",true);
    },
    hideSpinner: function (component, event, helper) {
        component.set("v.showSpinner",false);
    },

   
    
})
/**
Change History :
*         #CH01 : #Imane Tsioucha #16-06-2023" Logic of Download Bahraini ID
*/
({
    doInit : function(component, event, helper) {
        // START CH01 Imane Tsioucha
       // helper.getCustomerData(component, event, helper);
        // END
        var rid = component.get("v.recordId");
        var action = component.get("c.fetchCustomerDetail");
        action.setParams({key : rid});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                component.set("v.Customer", res);
                console.log('---> Response --->  ',res);
                if(!res.Alburaq_Segment__pc){
//                    alert('false');
                    component.set('v.isAlubraq',false);
                }
                if(!res.Segment__pc){
                    component.set('v.isila',false);
                }
                component.set('v.subscriptionModel',res.Subscription_Model__pc);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);	
    },
      // START CH01 Imane Tsioucha
    /*downloadFile: function(component, event, helper) {
        var idDocumentList=[];
		var action = component.get("c.getAccountDocuments");

        action.setParams({
            objectId: component.get('v.recordId')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var objData = response.getReturnValue();
				
				console.log('message from apexXXXX==> '+JSON.stringify(objData));
				for(var i in objData) {
					idDocumentList.push(objData[i].Id);

				}
				console.log('TESSSSSSSSSSSSSSSSSST==> '+idDocumentList);
				for (var i=0; i < idDocumentList.length; i++) {
					var redirect = $A.get("e.force:navigateToURL");
						 redirect.setParams({
						"url": "/sfc/servlet.shepherd/version/download/"+idDocumentList[i]
				});
				redirect.fire();
			   }
					 
			
            }

        });

		$A.enqueueAction(action);
		
		
    },*/
    // END
})
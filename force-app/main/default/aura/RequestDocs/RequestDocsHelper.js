/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History: 
 *	        2021-11-27 - #CH01# - YZ Region Name changes
 *			   
 */
({
    init : function(cmp, event, helper) {
        var caseId = cmp.get("v.caseId");
        console.log(">>>>>>case Id", caseId);
        // var action = cmp.get("c.isValidCase");
		// action.setParams({
		// 	caseId : caseId
		// });
        // action.setCallback(this, function(response) {
		// 	var state = response.getState();
		// 	if (state == "SUCCESS") {
        //         var result = response.getReturnValue();
        //         cmp.set("v.isValidCase", result);
        //     }
        // });
        // $A.enqueueAction(action);

        cmp.find('apexService').request(cmp.get('c.loadCase'), {
		    recordId: caseId
        },
		function(response) {
		    var result = response.getReturnValue();

            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                var caseObj = result.responseData;

                console.log(">>>>>>case", caseObj);
                cmp.set("v.isValidCase", true);  
                cmp.set("v.caseRecord", caseObj);
            } 
        });
        
    },
	requestDocs : function(cmp, event, helper) {
		var self = this;
        cmp.set("v.spinner", true);
		var caseId = cmp.get("v.caseId");
        var action = cmp.get("c.sendRequestDocs");
		action.setParams({
			caseId : caseId
		});
        
        action.setCallback(this, function(response) {
			var state = response.getState();
            //console.log("state", state);
			if (state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log("success", result.errorData.fault.faultstring);
                if(result.isSuccess){
                    self.showToast("Success", result.responseData.meta.message, "success");
                }else{
                    self.showToast("Fail", result.errorData.fault.faultstring, "error");
                }
                console.log("success", result);
            }else{
                var errors = response.getError();
                var strError;
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        strError = errors[0].message;
                    }
                } else {
                    strError = "Unknown error";
                }
            	self.showToast("Error!", strError, "error");
            }
            cmp.set("v.spinner", false);
		});
        $A.enqueueAction(action);
        
    },
    requestOnBoarding: function(cmp){ 
        console.log("do request");
        var caseRecord = cmp.get("v.caseRecord"); 
        var email = cmp.get("v.caseRecord.Account.PersonEmail");
        email = email ? email : '';
        console.log("do request", caseRecord);

        var requestBody = {
            caseStatus: "Visit to Service Center",
            email: email,
            caseType: "Name Screening"
        };
		cmp.find('apexService').request(cmp.get('c.sendOnboardingContinueRequest'), {
		    caseId: caseRecord.Id,
            customerId: caseRecord.Account.CIF__pc,
            actionName: "Name Screening",
            requestBody: JSON.stringify(requestBody),
            email: email,
            regionName: cmp.get('v.caseRecord.Region_Flag__c') // #CH01#
        },
		function(response) {
            var result = response.getReturnValue();
            console.log("result", result);  
		});

    },
    showToast : function(title, message, type){
    	var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
            "title"		: title,
            "message"	: message,
            "duration"	: 10000,
            "type"		: type
        });
        toastEvent.fire();
    }
})
({
    init  : function(component) {
        component.find('apexService').request(component.get('c.getCaseDetails'), {
            caseId : component.get("v.recordId")
        },
		function(response) {
            var result = response.getReturnValue();
            console.log("@@@ result ", result);
            component.set("v.case", result);
		});         
    },
    eKycRetryLogic: function(component) { 
        component.find('apexService').request(component.get('c.eKycRetry'), {
            caseId : component.get("v.recordId")
        },
        function(response) {
            var result = response.getReturnValue();
            console.log("RESPONSE RESULT", result);
            var toastEvent = $A.get("e.force:showToast");
            if(result == true) {  
                toastEvent.setParams({
                    "type":"success",
                    "title": "API",
                    "message": "The Retry call was successful"
                    });    										 
            }
            else {                                                    
            toastEvent.setParams({
                "type":"error",
                "title": "API",
                "message": "The Retry call was not successful"
                });                                                    
            }
            toastEvent.fire();
        });
    },
    eKycConvertLogic: function(component) { 
        component.find('apexService').request(component.get('c.eKycConvert'), {
            caseId : component.get("v.recordId")
        },
        function(response) {
            var result = response.getReturnValue();
            console.log("RESPONSE RESULT", result);
            var toastEvent = $A.get("e.force:showToast");
            if(result == true) {  
                toastEvent.setParams({
                    "type":"success",
                    "title": "API",
                    "message": "The Convert call was successful"
                    });    										 
            }
            else {                                                    
            toastEvent.setParams({
                "type":"error",
                "title": "API",
                "message": "The Convert call was not successful"
                });                                                    
            }
            toastEvent.fire();
        });
    },
    eKycDetailRetryLogic: function(component) { 
        component.find('apexService').request(component.get('c.eKYCCase'), {
            caseId : component.get("v.recordId")
        },
        function(response) {
            var result = response.getReturnValue();
            console.log("RESPONSE RESULT", result);
            var toastEvent = $A.get("e.force:showToast");
            if(result == true) {  
                toastEvent.setParams({
                    "type":"success",
                    "title": "API",
                    "message": "The Retry call was successful"
                    });    										 
            }
            else {                                                    
            toastEvent.setParams({
                "type":"error",
                "title": "API",
                "message": "The Retry call was not successful"
                });                                                    
            }
            toastEvent.fire();
        });
    }
})
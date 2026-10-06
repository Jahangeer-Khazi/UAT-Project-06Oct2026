({
	fetchIdExpiryDate : function(component,event,caseId) {
        console.log('Helper Function in fetch Id Expiry Method');
        var helper = this;
         var action = component.get("c.retreiveIDExpiryDate");
         action.setParams({
            caseId: caseId
         });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('Response from server:',state);
            
            var data = '';
                
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                
                var jsonData = JSON.parse(result);
                console.log('Complete JSON Data:',jsonData);
                
                var objData = jsonData.data;
                console.log('Type of the Data:',typeof objData);
                
                if(objData.hasOwnProperty('customerCivilDetailResponse')){ // Checking customerCivilDetailResponse Property in API Response
                    //var joIDExpiryDate = jsonData.data.cardInfo.cexpDt;
                    var joIDExpiryDate = objData.customerCivilDetailResponse.cexpDt;
                	console.log('Type of Jordanian Date:',typeof joIDExpiryDate);
                
                	if(joIDExpiryDate != null && joIDExpiryDate != ''){
                    	console.log('Jordan ID Expiry Date',joIDExpiryDate);
                    	helper.updateCaseIDExpiryDate(component,caseId,joIDExpiryDate);
                	}
                	else{
                     	helper.updateCounter(component,caseId);
                     	helper.handleErrors(component,'Server Error Getting Null Values from API !!!');
 					}
                }
                else{
                    console.log('Getting Data parameter empty in API Response');
                    helper.updateCounter(component,caseId);
                    helper.handleErrors(component,'Server Error Getting Null Values from API !!!');
                }
                
                
            }
            else if (state === "ERROR") {
                helper.updateCounter(component,caseId);
            	helper.handleErrors(component,response.getError());
            }
            
        });
        $A.enqueueAction(action);
		
	},
    
    updateCounter: function(component,caseId){
        var helper = this;
        var action = component.get("c.updateButtonCounter");
        action.setParams({
            caseId: caseId,
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('Response from server After Case Id Expiry Update:',state);
            
            if(state === 'SUCCESS'){
              var result = response.getReturnValue();
                if(result != null && result != ''){
                    
                }else{
                    helper.handleErrors(component,'Server Error Counter value Failed !!! ');
				}
            }
            else if(state === "ERROR") {
                console.log('Error Response 1:',response.getError());
            	helper.handleErrors(component,response.getError());
            }
            
        });
        $A.enqueueAction(action);
    },
    updateCaseIDExpiryDate: function(component,caseId,joIDExpiryDate){
        
        var helper = this;
        var action = component.get("c.updateIdExpiry");
         action.setParams({
            caseId: caseId,
            joIDExpiryDate: joIDExpiryDate
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('Response from server After Case Id Expiry Update:',state);
            
            if(state === 'SUCCESS'){
              var result = response.getReturnValue();
                if(result != null && result != ''){
                    helper.handleSuccess(component,result);
                    component.set('v.enableButton',false);
                }else{
                    helper.handleErrors(component,'Server Error Getting Null Values from API !!! ');
				}
            }
            else if(state === "ERROR") {
                console.log('Error Response 1:',response.getError());
            	helper.handleErrors(component,response.getError());
            }
            
        });
        $A.enqueueAction(action);
    },
    handleSuccess: function (component,message) {
        var helper = this;
        this.hideSpinner(component);
        let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": "Success!",
			"type": 'success',
			"message": message
		});
		toastEvent.fire();
        
	},
    handleErrors: function (component,errors) {
        var helper = this;
        this.hideSpinner(component);
        component.set('v.enableButton',false);
        console.log('Inside Error Method');
       
		let toastParams = {
			mode: "sticky",
			title: "Error",
			message: errors, // Default error message
			type: "error"
		};
		
        console.log('Error Data 1:',errors[0].message);
        console.log('Error Length:',errors.length);
		
        if(errors && Array.isArray(errors) && errors.length > 0) {
            console.log('Inside if Error Method');
			toastParams.message = errors[0].message;
		}
		// Fire error toast
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams(toastParams);
		toastEvent.fire();
	},
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
})
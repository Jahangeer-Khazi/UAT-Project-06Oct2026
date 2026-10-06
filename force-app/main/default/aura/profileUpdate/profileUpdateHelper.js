/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History:
 *  			CH01 : #Jahangeer Mohammed# #10-03-2026# Added Logic for Credit Card Guarantor CIF (NBA-16525)
 *
 * 
*/
({
    init  : function(component) {
        var helper = this;
        var caseId = component.get("v.caseId"); 
		var action = component.get("c.checkCaseSubType"); 
        action.setParams({
            caseId : caseId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log('Case Sub type:',response.getReturnValue());
                if(response.getReturnValue() == "Mobile update"){
                    component.set("v.caseSubType",response.getReturnValue());
                }
                else if(response.getReturnValue() == "Email update"){
                    component.set("v.caseSubType",response.getReturnValue());
                }
                else if(response.getReturnValue() == "Expired ID Update"  || response.getReturnValue() == "ID Expiry Update" || response.getReturnValue() == "ID Type Update"){
                    component.set("v.caseSubType",response.getReturnValue());
  				}
                else if(response.getReturnValue() == "Name Fix / Update" || response.getReturnValue() == "Name Update"){
                    component.set("v.caseSubType",response.getReturnValue());
                }
                else if(response.getReturnValue() == "Address update"){
                    component.set("v.caseSubType",response.getReturnValue());    
                }
                else if(response.getReturnValue() == "Additional Information"){
                    component.set("v.caseSubType",response.getReturnValue());    
                }
                else if(response.getReturnValue() == "Guardian Info"){
                    component.set("v.caseSubType",response.getReturnValue());    
   				}else if(response.getReturnValue() == "Geo-Location Check"){
                    component.set("v.caseSubType",response.getReturnValue());    
   				}
                //CH01: Start
                else if(response.getReturnValue() == "Credit Card Guarantor CIF"){
                    component.set("v.caseSubType",response.getReturnValue());     
                }
                //CH01: END
            }
            else if(state === "Error"){
                //Apex Class Server Side Error
                 helper.handleErrors(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    checkMakerResultOnCase  : function(component) {
        var helper = this;
        var caseId = component.get("v.caseId"); 
		var action = component.get("c.checkMakerResult"); 
        action.setParams({
            caseId : caseId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log('Check Maker result:',response.getReturnValue());
                if(response.getReturnValue() == "Send to Checker"){
                    component.set("v.enableChecker",true);
                }
                else{
                    component.set("v.enableChecker",false);
                }
            }
            else if(state === "Error"){
                 helper.handleErrors(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    saveAddInfor: function(component, account, customerId, caseId) {
        var helper = this; 
       //delete ready only field
       delete account.Name;
       component.set('v.showLoadingSpinner',true);
       
        var action = component.get("c.updateCustomerTemporaryFields");
        action.setParams({
            acc: account,
            customerId: customerId,
            caseId: caseId,
            personEmail: account.PersonEmail,
            regionName : account.Region_Flag__c
        });
        
        action.setCallback(this, function(response){ 
            var state = response.getState();
           // alert('state##'+state);
            if(state === "SUCCESS"){ 
               if(response.getReturnValue() == 'Bypass Account Successfully'){
                	component.set('v.showLoadingSpinner',false);
                	component.find('apexService').showSuccessMessage("Record has been updated successfully"); 
                	component.set("v.mode", "view");
             }else{
                      console.log('Return value from Class',response.getReturnValue());
                      helper.handleErrors(component,'Server Error Please Check System Action Or Contact your administrator for more infos ! ');
				}
            }
            else if(state === "Error"){
                helper.handleErrors(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    sendEmail: function(component, account, customerId, caseId){
        var helper = this;
        console.log('Account Email:',account.PersonEmail);
        var regionName=component.get('v.regionName');
        var acc=account.PersonEmail;
        var action=component.get('c.sendingEmailNotification');
         action.setParams({
            acc: account,
            customerId: customerId,
            caseId: caseId        
        });
         action.setCallback(this,function(response){
            var state=response.getState();
            console.log('State after Sending Email',state);
            if(state==='SUCCESS'){
                var emailResponse=response.getReturnValue();
                if(emailResponse = 'Success'){
                    var toastEvent = $A.get("e.force:showToast");  
           				toastEvent.setParams({  
             							"title": "Success!",  
             							"type": "success",  
             							"message": "Email Sent Successfully!"  
           			});  
           			toastEvent.fire(); 
                }else{
                     var toastEvent = $A.get("e.force:showToast");  
           				toastEvent.setParams({  
             							"title": "Error!",  
             							"type": "error",  
             							"message":emailResponse 
           				});  
           			toastEvent.fire(); 
                }
                
            }
            else if (status === "ERROR") {
                // Process error returned by server
                helper.handleErrors(component,response.getError());
            }
            
            
        });
        
        $A.enqueueAction(action);
        
    },
    handleErrors: function (component,errors) {
        var helper = this;
        component.set('v.showLoadingSpinner',false);
		// Configure error toast
		let toastParams = {
			mode: "sticky",
			title: "Error",
			message: errors, // Default error message
			type: "error"
		};
		// Pass the error message if any
		if (errors && Array.isArray(errors) && errors.length > 0) {
			toastParams.message = errors[0].message;
		}
		// Fire error toast
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams(toastParams);
		toastEvent.fire();
	},
})
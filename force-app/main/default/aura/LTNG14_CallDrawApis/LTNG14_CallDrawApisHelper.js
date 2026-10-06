({
    callDrawApi: function (component, event, helper) {
		var drawApiName = component.get('v.drawApiName');
		if(drawApiName == 'CREATE_DRAW'){
			helper.createDrawApi(component, event, helper);
		}else if(drawApiName == 'APPROVED_DRAW'){
			helper.updateDrawStatusApi(component, event, helper,'APPROVED');
		}else if(drawApiName == 'REJECTED_DRAW'){
			helper.updateDrawStatusApi(component, event, helper,'REJECTED');
		}
	},
    createDrawApi: function (component, event, helper) {
		console.error(component.get('v.recordId'));
		component.set("v.isProcessing", true);
		var action = component.get("c.createDrawApi");
		action.setParams({
			drawId: component.get('v.recordId')
		});

		action.setCallback(this, function (response) {
            var state = response.getState();
			if (state == "SUCCESS") {
				let isError = response.getReturnValue();
				if(isError == true){
					helper.handleErrors('Server Error Please Check System Action Or Contact your administrator for more infos !');
				}else{
					helper.handleSuccess('Created Draw Api called Successfully!');
				}
				$A.get("e.force:closeQuickAction").fire();
			}
			if (state == "ERROR") {
				$A.get("e.force:closeQuickAction").fire();
				helper.handleErrors(response.getError());
			}
			$A.get('e.force:refreshView').fire();
			component.set("v.isProcessing", false);
		});
		$A.enqueueAction(action);
	},
    updateDrawStatusApi: function (component, event, helper,status) {
		console.error(component.get('v.recordId'));
		component.set("v.isProcessing", true);
		var action = component.get("c.updateDrawStatusApi");
		action.setParams({
			drawId: component.get('v.recordId'),
			status: status
		});

		action.setCallback(this, function (response) {
            var state = response.getState();
			if (state == "SUCCESS") {
				let data = response.getReturnValue();
				if(data == true){
					helper.handleErrors('Server Error Please Check System Action Or Contact your administrator for more infos !');
				}else{
					helper.handleSuccess('Update Draw Status Api called Successfully!');
				}
				$A.get("e.force:closeQuickAction").fire();
				$A.get('e.force:refreshView').fire();
			}
			if (state == "ERROR") {
				$A.get("e.force:closeQuickAction").fire();
				helper.handleErrors(response.getError());
			}
			component.set("v.isProcessing", false);
		});
		$A.enqueueAction(action);
	},
	handleErrors: function (errors) {
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
	handleSuccess: function (message) {
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": "Success!",
			"type": 'success',
			"message": message
		});
		toastEvent.fire();
	},
})
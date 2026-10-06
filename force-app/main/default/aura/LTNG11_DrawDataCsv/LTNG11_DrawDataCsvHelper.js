({
    downloadAction: function (component, event, helper) {
		component.set("v.isProcessing", true);
		var action = component.get("c.getDrawDataViaApi");
		action.setParams({
			recordId: component.get('v.recordId'),
			dataType: component.find("AWSfiles").get("v.value")
		});

		action.setCallback(this, function (response) {
			var state = response.getState();

			component.find("AWSfiles").set("v.value","original_eligible");
			
			if (state == "SUCCESS") {

                let result = response.getReturnValue();
                if(true === result.isSuccess && result.responseData != null && result.responseData.fileMimeType != null ){
                    let downloadLink = document.createElement("a");
                    downloadLink.setAttribute("type", "hidden");
					
					if(result.responseData.fileMimeType != null ){
						if(result.responseData.fileMimeType.toLowerCase().includes('csv')){
							console.log('csv File href');
							downloadLink.href = "data:text/csv;base64," + result.responseData.fileContent;
							downloadLink.download = result.responseData.fileName;
						}else if(result.responseData.fileMimeType.toLowerCase().includes('gzip')){
							console.log('zip File href');
							downloadLink.href = "data:application/gzip;base64," + result.responseData.fileContent;
							downloadLink.download = result.responseData.fileName;
						}
					}


                    //downloadLink.download = component.find("AWSfiles").get("v.value")+'.csv';
                    document.body.appendChild(downloadLink);
                    downloadLink.click();
                    downloadLink.remove();
                    helper.handleSuccess('File downloaded Successfully!');
				}
				else if(true === result.isSuccess && (result.responseData == null || result.responseData.fileMimeType == null) ){
					helper.handleInfoMsg('Draw data file is being generated, please try after few seconds.');
					console.error(result.errorData);
				}
				else{
					helper.handleErrors('Server Error Please Check System Action Or Contact your administrator for more infos !');
                }
                $A.get('e.force:refreshView').fire();
    			component.set("v.isProcessing", false);
			}
			if (state == "ERROR") {
				helper.handleErrors(response.getError());
			}
		});
		$A.enqueueAction(action);
	},
	trackWhoClickedOnShowFiles : function (component, event, helper,buttonDesc) {
		var action = component.get("c.trackClickedButton");
		action.setParams({
			recordId: component.get('v.recordId'),
			buttonDesc: buttonDesc
		});

		action.setCallback(this, function (response) {
            var state = response.getState();
			if (state == "SUCCESS") {
				component.set("v.showFiles", true);
                $A.get('e.force:refreshView').fire();
			}
			if (state == "ERROR") {
				console.error(response.getError());
				helper.handleErrors('You are not the owner of this draw ,you cannot View Files!');
			}
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
	handleInfoMsg: function (msg) {
		// Configure error toast
		let toastParams = {
			title: "Info",
			message: msg, // Default error message
			type: "info"
		};
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
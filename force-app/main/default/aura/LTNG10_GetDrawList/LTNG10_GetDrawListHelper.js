({
	getDrawList: function (component, event, helper) {
		var drawType = component.get('v.drawType');
		var regionFlag = component.get('v.regionFlag');
		if (drawType != null && drawType != '' && regionFlag != null && regionFlag != '') {
			var action = component.get('c.getDrawListViaApi');
			action.setParams(
				{
					drawType: drawType,
					regionFlag: regionFlag
				});
			action.setCallback(this, function (actionResult) {
				component.set("v.showCmp", true);
				var statut = actionResult.getState();
				if (statut === "SUCCESS") {
					let result = actionResult.getReturnValue();
					var data = [];
					if (result.isSuccess == true) {
						var responseResult = result.responseData;
						for (var i = 0; i < responseResult.draws.length; i++) {
							var draw = responseResult.draws[i];
							//change decimal to string for draw id 
							draw.id = draw.id.toString();
							data.push(draw);
						}

						component.set("v.currentDraw", '{}');
						component.set("v.drawList", data);
						component.find("drawToChange").set("v.value",'');
						console.error('call api =================>>>>'+component.find("drawToChange").get("v.value"));
					} else {
						console.error(result.errorData);
						helper.handleErrors('The status code returned was not expected when we are calling Get Draw List API', '');
					}
				} else if (statut === "ERROR") {
					// Process error returned by server
					helper.handleErrors(actionResult.getError(), '');
				}
				else {
					console.error("AUTRE ERROR");
					// Handle other reponse states
				}
			});
			$A.enqueueAction(action);
		} else {
			let em= [];
			component.set("v.drawList", em );
			component.set("v.showCmp", false);
			component.set("v.currentDraw", '{}');
			component.find("drawToChange").set("v.value",'');
			console.error('not calling the api =================>>>>'+component.find("drawToChange").get("v.value"));
		}
	},
	handleErrors: function (errors, addError) {
		// Configure error toast
		let toastParams = {
			mode: "sticky",
			title: "Error",
			message: errors, // Default error message
			type: "error"
		};
		// Pass the error message if any
		if (errors && Array.isArray(errors) && errors.length > 0) {
			toastParams.message = addError + '' + errors[0].message;
		}
		// Fire error toast
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams(toastParams);
		toastEvent.fire();
	},
})
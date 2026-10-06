({
	getDrawRecordType: function (component, event, helper) {
		console.log('------------>> getDrawRecordType --------->>>');
		var regionFlag = component.get('v.regionFlag');
		var drawType = component.get('v.drawType');//#CH01
		if(regionFlag != null && regionFlag != ''){
			var action = component.get('c.getDrawRecordType');
			action.setParams(
				{
					regionFlag: regionFlag,
					drawType: drawType//#CH01
				}
			);
			action.setCallback(this, function (actionResult) {
				var statut = actionResult.getState();
				if (statut === "SUCCESS") {
					let data = actionResult.getReturnValue();
					if (data) {
						console.log('---> recordTypeID '+data);
						component.set("v.recordTypeId", data);
					}
				} else if (statut === "ERROR") {
					// Process error returned by server
					console.error(actionResult.getError());
				}
				else {
					console.error("AUTRE ERROR");
					// Handle other reponse states
				}
			});
			$A.enqueueAction(action);
		}
	},
})
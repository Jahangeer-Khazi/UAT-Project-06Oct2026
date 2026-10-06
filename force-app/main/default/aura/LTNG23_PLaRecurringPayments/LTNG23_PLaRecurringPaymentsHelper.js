({
	loadData: function (component,helper) {
		console.log('loadData LTNG23_PLaRecurringPaymentsHelper ');
		
		var customerId = component.get('v.customerId');
        var regionName = component.get('v.regionName');
		console.error('**********>>>>> '+customerId);
		/* console.error('**********>>>>> '+component.get('v.account').Id);
		var requestData = {
            accountId: component.get('v.account').Id
        } */

		var action = component.get('c.getScheduledPlaPayments');
		action.setParams(
			{
				customerId: customerId,
				requestTextJson: null,
                regionName:regionName
			});

		action.setCallback(this, function (actionResult) {
			var statut = actionResult.getState();
			if (statut === "SUCCESS") {
				console.error('SUCCESS******');
				let result = actionResult.getReturnValue();
				console.error(result);
				var data = [];
				if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
					var responseResult = result.responseData;
					for (var i = 0; i < responseResult.paymentSchedules.length; i++) {
						var recPay = responseResult.paymentSchedules[i];
						data.push(helper.formatData(component, recPay));
					}
				}else if (result.isSuccess === false ){
					console.error("Error: "+ result.errorData);
					helper.handleErrors(result.errorData.message, '');
				}

				component.set('v.data', data);
				component.set("v.viewReccPay", true);

			} else if (statut === "ERROR") {
				// Process error returned by server
				console.error(actionResult.getError());
				helper.handleErrors(actionResult.getError(), '');
			}
			else {
				console.error("AUTRE ERROR");
				// Handle other reponse states
			}
		});
		$A.enqueueAction(action);
	},

	formatData: function (component, recPayObj) {
		var result = {};
		result.id = recPayObj.id;
		result.scheduleId = recPayObj.id;
		result.amount = recPayObj.currency +' '+ recPayObj.amount;
		if(recPayObj.account){
			result.sourceAccount = recPayObj.account.iban;
		}
		result.frequency = recPayObj.frequency;
		result.startDate = recPayObj.startDate;
		result.nextPaymentDate = recPayObj.nextPaymentDate;
		result.status = recPayObj.status;
		result.endOfTheMonth = recPayObj.endOfMonth;
		return result;

	},

	openSchedulRecPayDetails: function (component, helper,schedulRecPayId) {
		var customerId = component.get('v.customerId');
		/* var requestData = {
            schedulRecPayId: schedulRecPayId
        } */
		console.log('openSchedulRecPayDetails LTNG23_PLaRecurringPaymentsHelper : schedulRecPayId = ' + schedulRecPayId );
		var action = component.get('c.getSchedulRecPayDetails');
        var regionName = component.get('v.regionName');
		action.setParams(
			{
				customerId: customerId,
				scheduleId: schedulRecPayId,
                regionName: regionName
			});

		action.setCallback(this, function (actionResult) {
			var statut = actionResult.getState();
			if (statut === "SUCCESS") {
				let result = actionResult.getReturnValue();
				var data = [];
				if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
					var responseResult = result.responseData;
					
					for (var i = 0; i < responseResult.paymentSchedules.length; i++) {
						var recPay = responseResult.paymentSchedules[i];
						data.push(helper.formatDataPaymentDetails(component, recPay,schedulRecPayId));
					}
				}
				component.set('v.dataPaymentDetails', data);
				component.set("v.viewPaymentDetails", true);
				component.set("v.scheduleId", schedulRecPayId);

			} else if (statut === "ERROR") {
				// Process error returned by server
				console.error(actionResult.getError());
				helper.handleErrors(actionResult.getError(), '');
			}
			else {
				console.error("AUTRE ERROR");
				// Handle other reponse states
			}
		});
		$A.enqueueAction(action);
	},
	formatDataPaymentDetails: function (component, payDetailsObj,schedulRecPayId) {

		var result = {};
		result.id = payDetailsObj.iban;
		result.scheduleId = schedulRecPayId;
		if(payDetailsObj.currency){
			result.amount = payDetailsObj.currency.code +' ' +payDetailsObj.amount;
		}
		result.sourceAccount = payDetailsObj.iban;
		result.transactionDate =  payDetailsObj.transactionDate;
		result.transactionPaymentStatus =  payDetailsObj.status;

		return result;

	},

	handleErrors: function (errors, addError) {
		// Configure error toast
		let toastParams = {
			mode: "sticky",
			title: "Erreur",
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
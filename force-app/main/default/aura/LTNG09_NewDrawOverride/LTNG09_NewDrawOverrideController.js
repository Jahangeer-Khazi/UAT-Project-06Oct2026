({
	doInit: function (component, event, helper) {
		console.log('LTNG09 doInit ');
        var regionFlag = component.get('v.regionFlag');
		console.log('------------>> '+ regionFlag);
		helper.getDrawRecordType(component, event, helper);
	},
	cancelDialog: function (component, helper) {
		/* var homeEvt = $A.get("e.force:navigateToObjectHome");
		homeEvt.setParams({
			"scope": "Draw__c"
		});
		homeEvt.fire(); */
		history.back();
	},
	handleOnSubmit: function (component, event, helper) {
		console.log('==============handleOnSubmit====>');
		component.set("v.showSpinner",true);
        //event.preventDefault();
		//component.find('myRecordForm').submit();
	},
	handleSuccess: function (component, event, helper) {
		var resultsToast = $A.get("e.force:showToast");
		resultsToast.setParams({
			"title": "success",
			"type": 'success',
			"message": "Draw was created."
		});
		resultsToast.fire();

		// navigate to new record on successful save
		var navEvt = $A.get("e.force:navigateToSObject");
		navEvt.setParams({
			"recordId": event.getParam("response").id,
			"slideDevName": "detail"
		});
		navEvt.fire();
		component.set("v.showSpinner",false);
	},
	handleError: function (component, event, helper) {
		console.error('handleError');
	},
	regionFlagChange : function (component, event, helper) {
        console.error('LTNG09_regionFlagChange =================>>>>');
        helper.getDrawRecordType(component, helper);
	},
	drawTypeChange : function (component, event, helper) {//#CH01
        console.error('LTNG09_drawTypeChange =================>>>>');
		var drawType = component.get('v.drawType');
		if(drawType == 'kanzStaff'){//toDo : check label/apiName
			helper.getDrawRecordType(component, helper);
		}
	}
})
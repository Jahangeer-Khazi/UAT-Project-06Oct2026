/* 		
 *   Organization : ABC Bank
 * 	 Created By: Aniss Mbarki
 *	 Created Date: 21-06-2024
 * 	 Change History:
 *			   
 */
 ({
    doInit: function (component, event, helper) {
        var action = component.get('c.loadDeviceActivities');
        action.setParams(
            {
                accountId: component.get('v.recordId')
            });
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                component.set('v.showCmp', true);
                let result = actionResult.getReturnValue();
                var data = [];
                if ( !$A.util.isEmpty(result) ) {
                    for (var i = 0; i < result.deviceActivities.length; i++) {
                        var deviceActivity = result.deviceActivities[i];
                        console.log('---LTNG052 loadData --> ', deviceActivity);
                        data.push(helper.formatData(component, deviceActivity));
                    }
                }
                console.log('---LTNG052 JSON.stringify(data) --> ', JSON.stringify(data));
                component.set('v.data', data);
            } else if (statut === "ERROR") {
                console.error(actionResult.getError());
                helper.handleErrors(actionResult.getError(), '')
            }
            else {
                console.error("AUTRE ERROR");
            }
        });
        $A.enqueueAction(action);
    },
    formatData: function (component, deviceActivity) {
        var rec = {};
        rec.idRow = deviceActivity.id;
        rec.action = deviceActivity.action;
        rec.triggeredBy = deviceActivity.triggeredBy=='CRM'?'By Agent':(deviceActivity.triggeredBy=='OTHER'?'By Backend':'By Customer');
        rec.deviceManufacturer = deviceActivity.deviceManufacturer;
        rec.deviceModel = deviceActivity.deviceModel;
        rec.deviceOs = deviceActivity.deviceOs;
        rec.reason = deviceActivity.reason=='REASON_LOST'?'I lost this device':(deviceActivity.reason=='REASON_DONT_KNOW'?'I dont know this device':(deviceActivity.reason=='REASON_DONT_USE'?'I no longer use this device':(deviceActivity.reason=='DORMANT_ACCOUNT'?'Account dormancy':(deviceActivity.reason=='TERMINATED_ACCOUNT'?'Account termination':(deviceActivity.reason=='ARCHIVED_ACCOUNT'?'Account archiving':'')))));
        rec.deviceId = deviceActivity.deviceId;
        rec.actionDate = (this.addHours(this.parseDate(deviceActivity.actionDate),3)).toLocaleString();
        return rec;

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
  parseDate:function (dateTimeString){
  // Split the date and time parts
  const [datePart, timePart] = dateTimeString.split('T');
  // Split the date into day, month, and year
  const [year, month, day] = datePart.split('-').map(Number);
  // Split the time into hours, minutes, and seconds
  const [hours, minutes, seconds] = timePart.split(':').map(Number);
  return new Date(year, month - 1, day, hours, minutes, seconds);
},
  addHours:function(date, hours) {
  const hoursToAdd = hours * 60 * 60 * 1000;
  date.setTime(date.getTime() + hoursToAdd);
  return date;
},
})
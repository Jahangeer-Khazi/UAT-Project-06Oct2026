({
	fetchDevices : function(component) {

        let action = component.get("c.loadDeviceList");
		//var accId = component.get("v.recordId");
        //console.log('Account Id:',accId);
        action.setParams({
            accID : component.get("v.customerId")
        });

        action.setCallback(this, function(response) {

            let state = response.getState();

            if(state === "SUCCESS") {

                let result = response.getReturnValue();

                console.log('API Result ==> ', result);

                let deviceList = [];
				var summaryParts = [];
                // MAP ITERATION
                for(let key in result) {

                    if(result.hasOwnProperty(key)) {

                        let deviceObj = result[key];

                        deviceList.push({
                            id : deviceObj.id,
                            status : deviceObj.status,
                            manufacturer : deviceObj.manufacturer,
                            model : deviceObj.model.name,
                            os : deviceObj.os.name,
                            deviceLastLogin : deviceObj.lastLogin.deviceLastLogin
                        });
                        //var summary ='Manufacturer: ' + deviceObj.manufacturer +', Model: ' + deviceObj.model.name +', OS: ' + deviceObj.os.name;
                        //console.log('Device Summary:',summary);
                        //component.set("v.deviceSummary", summary);
                        summaryParts.push(
                            'Manufacturer: ' + deviceObj.manufacturer +
                            ' | Model: '     + deviceObj.model.name   +
                            ' | OS: '        + deviceObj.os.name
                        );
                    }
                }
                var finalSummary = summaryParts.join(';  ');
                console.log('Device Summary:',finalSummary);
				component.set("v.deviceSummary", finalSummary);
                
                console.log('deviceList ==> ', deviceList);
				component.set("v.deviceData", deviceList);

            }else{
				console.log('ERROR ==> ', response.getError());
            }
        });

        $A.enqueueAction(action);
    }
})
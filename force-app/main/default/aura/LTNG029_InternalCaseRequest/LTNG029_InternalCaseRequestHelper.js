({
    doInit : function (component, event, helper, accId) {
        
        var action = component.get('c.getInternalCaseRecordType');
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                if (data) {
                    component.set("v.recordTypeId", data);
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
    },
    loadCardDetails : function (component, event, helper,cardId) {
        console.log('PersonEmail==> '+component.get("v.accountRecord")["PersonEmail"]);
        console.log('Region_Flag__pc==> '+component.get("v.accountRecord")["Region_Flag__pc"]);
        console.log('CIF__pc==> '+component.get("v.accountRecord")["CIF__pc"]);
        var action = component.get('c.loadCardDetails');
        action.setParams({
			customerId: component.get("v.accountRecord")["CIF__pc"],
            cardId:cardId,
            personEmail: component.get("v.accountRecord")["PersonEmail"],
            regionName: component.get("v.accountRecord")["Region_Flag__pc"]
		});
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let data = actionResult.getReturnValue();
                console.log('datta==> '+JSON.stringify(data));
                var fieldMap = [];
                for(var key in data){
                   
                   console.log('datta==> '+JSON.stringify(fieldMap));
                   if(key=='responseData'){
                    fieldMap.push({cardId: key, cardObj: data[key] });
                   }
                   for(var key in fieldMap ){
                 
                    var myValues= component.get("v.cc_cardPCINumber");	
                    myValues.findIndex(item => {	
                        if(item.cardId == cardId){	
                            component.set( 'v.creditLimit' , fieldMap[key].cardObj.creditLimit );
                            component.set( 'v.outstanding' , fieldMap[key].cardObj.usedCreditLimit );	
                        }	
                    });	
                   }
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
    },
	showSpinner: function (component, event, helper) {
        component.set("v.showSpinner",true);
    },
    hideSpinner: function (component, event, helper) {
        component.set("v.showSpinner",false);
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
    //#CH06
    loadDeviceList : function (component, event, helper) {
        var action = component.get("c.loadDeviceList");
        action.setParams({
            accID : component.get("v.recordId"),
            caseModel : component.get("v.caseModel") }
        );
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state '+state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result '+JSON.stringify(result));
                var fieldMap = [];
                for(var key in result){
                    let deviceObj = result[key];
                    let stringList = [];

                    if( deviceObj.manufacturer != null ){
                        stringList.push(deviceObj.manufacturer);
                    }
                    
                    if( deviceObj.model != null && deviceObj.model.marketingName != null ){
                        stringList.push(deviceObj.manufacturer);
                    }

                    
                    if( deviceObj.os != null ){
                        if( deviceObj.os.name != null ){
                            stringList.push(deviceObj.os.name);
                        }
                        if( deviceObj.os.version != null ){
                            stringList.push(deviceObj.os.version);
                        }
                    }

                    if(deviceObj.lastLogin != null && deviceObj.lastLogin.deviceLastLogin != null){//PI-3765
                        let dateForm = new Date(deviceObj.lastLogin.deviceLastLogin);
                        const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                        let hours = dateForm.getHours();
                        let minutes = dateForm.getMinutes();
                        let formattedDate = `${dateForm.getDate()} ${months[dateForm.getMonth()]}, ${dateForm.getFullYear()} ${hours}:${minutes.toString().padStart(2, '0')}`;
                        stringList.push(formattedDate);
                    }

                    fieldMap.push({deviceId: key, label: stringList.join(" - ") });

                }
                component.set("v.devicesValues",fieldMap);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                        errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
})
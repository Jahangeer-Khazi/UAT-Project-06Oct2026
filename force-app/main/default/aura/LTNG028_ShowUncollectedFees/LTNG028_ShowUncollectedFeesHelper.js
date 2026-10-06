/* 		
 *   Organization : ABC Bank
 * 	Created By: Wissal Benqezza
 *	Created Date: 02-11-2022
 * 	Change History: 
 *			  CH02: Added by Imane Tsioucha #07/11/2023# Add Hold Description 3 
 */
({
    doInit: function (component, event, helper) {
      console.log('helper doInit LTNG028_ShowUncollectedFeesController'); 
      helper.loadData(component, event, helper);
           
    },
    loadData: function (component, event, helper) {
        //CH01 -Start added by elmustapha elgarni : pass Bahrain_alburaq in case of alburaq Product
        var regionName = component.get('v.account').Region_Flag__c;
        if(component.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        //CH01 -End

        var action = component.get('c.callUncollectedFeesApi');
        var requestData = {
            accountId: component.get('v.accountId')
            
        }

        action.setParams(
            {
                customerId: component.get('v.customerId'),
                // requestTextJson: JSON.stringify(requestData),
                requestTextJson: component.get('v.accountId'),
                regionName: regionName
            });
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                
               	component.set('v.showCmp', true);
                let result = actionResult.getReturnValue();
                console.log('LTNG028_ShowUncollectedFeesController callUncollectedFeesApi success -->' );
                console.log(result);
                var data = [];
                if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                    var responseResult = result.responseData;
                    for (var i = 0; i < responseResult.transactions.length; i++) {
                        var stment = responseResult.transactions[i];
                        console.log('---LTNG028_ShowUncollectedFeesController loadData --> ', stment);
                        data.push(helper.formatData(component, stment));
                    }
                }
                component.set('v.data', data);
            } else if (statut === "ERROR") {
                //toDo : ....
                // Process error returned by server
                console.error(actionResult.getError());
                //helper.handleErrors(actionResult.getError(), '');
            }
            else {
                //toDo : ....
                console.error("AUTRE ERROR");
                // Handle other reponse states
            }
        });
        $A.enqueueAction(action);

    },
    formatData: function (component, statObj) {
        var rec = {};
        rec.holdReferenceNumber = statObj.holdReferenceNumber;
        rec.holdDate = statObj.holdDate;
        rec.holdAmount = statObj.holdAmount;
        rec.holdCurrency = statObj.holdCurrency.code ;
        rec.holdDescription1 = statObj.holdDescription1;
        rec.holdDescription2 = statObj.holdDescription2;
        // START: CH02
        rec.holdDescription3 = statObj.holdDescription3;
        //END: CH02
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
})
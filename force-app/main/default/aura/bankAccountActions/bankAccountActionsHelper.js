/* 		
 * 		Change History: 
 *              #CH01# : Added by Hamza Chaoui *** pass Bahrain_alburaq in case of alburaq Product
 */
({

    processRequestFirstCard : function(component, customerId, requestData, caseId, account) {
        var helper = this;

        var extraParameters = {
            isCaseClosureRequired: true,
            systemActionType: 'Request First Card',
            //caseType: 'Card Service',
            //caseSubType: 'First Card'
        }
        helper.requestNewCard(component, customerId, requestData, caseId, extraParameters, account);
    },

    requestNewCard : function(component, customerId, requestData, caseId, extraParameters, account) {
        var helper = this;

        //CH01 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product
        var regionName = account.Region_Flag__c;
        if(component.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        //CH01 -End

        component.find('apexService').request(component.get('c.requestNewCard'), {
            //account ID is required?? not sure as BankCardAction issuance api it is required
            customerId: customerId,
            requestTextJson: JSON.stringify(requestData),
            caseId: caseId,
            extraParameters: JSON.stringify(extraParameters),
            personEmail: account.PersonEmail,
            regionName: regionName
        },
        function(response) {
            var result = response.getReturnValue();
            var data = [];
            if (true === result.isSuccess ) {
                component.set('v.selectedAccountActionType', undefined);
                component.set('v.productType', undefined);
                component.set('v.deliveryType', undefined);

                // give user an indication that the action was a success
                component.find('apexService').showSuccessMessage("Request successful");
                // refresh cards list
                helper.requestAccountListRefresh(component);
                // refresh the standard page view
                $A.get('e.force:refreshView').fire();
            }else{
                component.set("v.isButtonDisabled","false"); 
            }

        });
	},
    requestAccountListRefresh: function(component) {
            var appEvent = $A.get("e.c:appEvent");
            var message = {
                "action": 'refresh',
            };
            appEvent.setParams(
                {
                    "source": "accountActions",
                    "target": "accountList",
                    "message": message
                }
            );
            appEvent.fire();

    }
})
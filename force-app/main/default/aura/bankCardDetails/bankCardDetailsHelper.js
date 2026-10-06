/* 	
 * 		Change History: 
 *              #CH01# : added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product

 */
({
    loadCardDetails : function(component, customerId, cardId, account) {
	    var helper = this;
        //CH01 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product
        var regionName = account.Region_Flag__c;
        if(component.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        //CH01 -End
        console.log("Hi -----> ");
        console.log("customerId -> ", customerId);
        console.log("cardId -> ", cardId);
        console.log("personEmail -> ", account.personEmail);
        console.log("regionName -> ", regionName);

		component.find('apexService').request(component.get('c.loadCardDetails'), {
            customerId: customerId,
            cardId: cardId,
            personEmail: account.PersonEmail,
            regionName:regionName
        },
		function(response) {
		    var result = response.getReturnValue();
            // single card data
            var data = {};
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                data = result.responseData;
            }
            //data.id = cardId;
            component.set('v.cardData', data);
            console.log("data", data);
		});
	},
})
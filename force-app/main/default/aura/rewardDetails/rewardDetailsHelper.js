({
	loadRewardDetails : function(component, customerId, cardId, account, Option) {
	    var helper = this;
		component.find('apexService').request(component.get('c.loadRewardDetails'), {
		    customerId: customerId,
            cardId: cardId,
            regionName: account.Region_Flag__c,
            Option:Option
        },
		function(response) {
		    var result = response.getReturnValue();
            // single card data
            var data = {};
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData))//responseData.currentCards))
            {
                data = result.responseData;//result.responseData.currentCards;
            }
            console.log("Card Details data---->",JSON.stringify(data));
            component.set("v.rewardDetail",data);
             $A.get('e.force:refreshView').fire();
           
		});
        
	},

})
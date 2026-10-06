({
    init  : function(component) {
        this.loadProfileVisibility(component);
    },
	save : function(component, account, customerId, caseId) { 

        //delete ready only field
        delete account.Name;
		component.find('apexService').request(component.get('c.updateProfile'), {
            acc: account,
            customerId: customerId,
            caseId: caseId,
            personEmail: account.PersonEmail,
            regionName : account.Region_Flag__c
        },
		function(response) {
		    var result = response.getReturnValue();
            if (true === result.isSuccess ) {
               	component.set('v.accountOld', JSON.parse(JSON.stringify(account)));
                component.find('apexService').showSuccessMessage("Request successful");

                component.set("v.mode", "view");

                // refresh the standard page view
                $A.get('e.force:refreshView').fire();
            }
		});
	},
    loadProfileVisibility : function(component) {
		component.find('apexService').request(component.get('c.loadCusProVisibility'), { },
		function(response) {
		    var result = response.getReturnValue();
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                var proVisibility = result.responseData;
                if(proVisibility.Field_Read_Only__c){
                    var strFields = proVisibility.Field_Read_Only__c;
                    strFields = strFields.toLowerCase();
                    var lstFields = (strFields.indexOf(",") > -1 ? strFields.split(","): [strFields]);
                    var mapField = {};
                    lstFields.forEach(function(field){
                        mapField[field] = 1;//put number 1 just to set value for mapping
                    });
                    component.set("v.readOnlyFields", mapField);
                }
            }
		});
	},
})
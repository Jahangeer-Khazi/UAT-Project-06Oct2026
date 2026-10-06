({
	doInit : function(component, event, helper) {

        component.set("v.fColumns", [

            {
                label : 'Account Number',
                fieldName : 'accNumber',
                type : 'text'
            },

            {
                label : 'Alias Name',
                fieldName : 'aliasName',
                type : 'text'
            },

            {
                label : 'Currency',
                fieldName : 'currencyCode',
                type : 'text'
            },

            {
                label : 'Available Balance',
                fieldName : 'availableBalance',
                type : 'number',
                cellAttributes: {
        			alignment: 'left'
    			},
                typeAttributes: {
                    minimumFractionDigits: 0,
       			    maximumFractionDigits: 3
                }
            },
		]);

        helper.fetchActiveForeignAccts(component);
    }
})
({
	doInit : function(component, event, helper) {

        component.set("v.spColumns", [

            {
                label : 'Pot Id',
                fieldName : 'id',
                type : 'text'
            },

            {
                label : 'Name',
                fieldName : 'name',
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

        helper.fetchSavingPots(component);
    }
})
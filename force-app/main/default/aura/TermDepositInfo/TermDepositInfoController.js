({
	doInit : function(component, event, helper) {

        component.set("v.fdColumns", [

            {
                label : 'Id',
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
                label : 'Deposit Amount',
                fieldName : 'depositAmount',
                type : 'number',
                cellAttributes: {
        			alignment: 'left'
    			},
                typeAttributes: {
                    minimumFractionDigits: 0,
       			    maximumFractionDigits: 3
                }
            },

            {
                label : 'Maturity Amount',
                fieldName : 'maturityAmount',
                type : 'number',
                cellAttributes: {
        			alignment: 'left'
    			},
                typeAttributes: {
                    minimumFractionDigits: 0,
        			maximumFractionDigits: 3
                }
            },

            {
                label : 'Status',
                fieldName : 'status',
                type : 'text'
            }

        ]);

        helper.fetchFixedDeposits(component);
    }
})
({
	doInit : function(component, event, helper) {
        component.set("v.columns", [
    {
        label: 'Card Classification',
        fieldName: 'cardClassification',
        type: 'text'
    },
    {
        label: 'Card Status',
        fieldName: 'cardStatus',
        type: 'text'
    },
    {
        label: 'Card Type',
        fieldName: 'cardType',
        type: 'text'
    },
    {
        label: 'Card Number',
        fieldName: 'cardNumber',
        type: 'text'
    }
    
    ]);
        
     component.set("v.debitColumns", [
    {
        label: 'Card Classification',
        fieldName: 'productName',
        type: 'text'
    },
    {
        label: 'Card Status',
        fieldName: 'status',
        type: 'text'
    },
    {
        label: 'Card Type',
        fieldName: 'cardType',
        type: 'text'
    },
    
    {
        label: 'Card Number',
        fieldName: 'cardNumber',
        type: 'text'
    }
    
    ]);
	helper.fetchCurrentCards(component);
    helper.fetchDebitCards(component);
  }
})
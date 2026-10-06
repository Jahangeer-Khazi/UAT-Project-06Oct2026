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
    },
    {
    label: 'Is Delinquent',
    type: 'button-icon',
    cellAttributes: {
        alignment: 'left'
    },
    	typeAttributes: {
        	iconName: { fieldName: 'delinquentIcon' },
        	disabled: false,
        	variant: 'bare'
    	}
	}
    ]);
	helper.fetchCurrentCards(component);	
	},
    handleRowSelection: function (component, event, helper) {
         var selectedRows = event.getParam('selectedRows');
         console.log('--> SELECTED ROW CARD ID first-> ',selectedRows);
         console.log('--> SELECTED ROW Length-> ',selectedRows.length);
         for(var i=0; i<selectedRows.length; i++){
            var selectedRow = selectedRows[0];
            var cardId = selectedRow.id;
            console.log('PCI Number:',cardId);
            component.set('v.pciNumber',cardId);
            // Store card name
            component.set('v.selectedCardName',selectedRow.cardClassification);
            console.log('Masked Number:',selectedRow.cardNumber);
            component.set('v.cardNumber',selectedRow.cardNumber);
            component.set('v.isLoadingLimit', true);
            // Clear previous limit
        	component.set('v.currentCreditLimit', null);
            helper.fetchCurrentLimit(component,cardId);
            break;
        }
    }
})
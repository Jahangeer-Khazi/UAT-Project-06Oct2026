import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAccountDetails from '@salesforce/apex/LTNG050_ShowCustomerIdController.getAccountByCIF';

const actions = [
    { label: 'Show details', name: 'show_details' }
];

const columns = [
    { label: 'Customer Name', fieldName: 'nameUrl', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_self' } },
    { label: 'CIF', fieldName: 'CIF__pc'},
    { label: 'Mobile', fieldName: 'Mobile_Phone_Check__pc'},
    { label: 'Segment', fieldName: 'Segment__pc'},
    { label: 'Relationship Status', fieldName: 'CustomerStatus__c'},
    {
        type: 'action',
        typeAttributes: { rowActions: actions }
    },
];

export default class CustomerCIFDetails extends NavigationMixin(LightningElement) {
    @api CIF;
    data = [];
    columns = columns;
    error;

    connectedCallback() {
        if (this.CIF) {
            this.loadAccountData();
        }
    }

    loadAccountData() {
        getAccountDetails({ cif: this.CIF })
            .then(result => {
                if (result) {
                    this.data = [{
                        id: result.Id,
                        Name: result.Name,
                        CIF__pc: result.CIF__pc,
                        Mobile_Phone_Check__pc: result.Mobile_Phone_Check__pc,
                        Segment__pc: result.Segment__pc,
                        CustomerStatus__c: result.CustomerStatus__c,
                        nameUrl: `/lightning/r/Account/${result.Id}/view`
                    }];
                    this.error = undefined;
                } else {
                    this.data = [];
                    this.error = 'No account found with this CIF';
                }
            })
            .catch(error => {
                this.error = error.body.message;
                this.data = [];
            });
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        
        if (action.name === 'show_details') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: row.id,
                    actionName: 'view'
                }
            });
        }
    }
}
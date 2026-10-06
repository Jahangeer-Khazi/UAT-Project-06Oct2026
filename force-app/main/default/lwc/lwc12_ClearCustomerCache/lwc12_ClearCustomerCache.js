import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import clearCache from '@salesforce/apex/lwc12_ClearCustomerCacheController.clearCache';

export default class Lwc12_ClearCustomerCache extends LightningElement {
    @api recordId;
    @track isLoading = false;

    handleClearCache() {
        this.isLoading = true;
        clearCache({ accountId: this.recordId })
            .then(result => {
                this.isLoading = false;
                if (result.isSuccess) {
                    this.showToast('Success', result.message, 'success');
                } else {
                    this.showToast('Error', result.message, 'error');
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.showToast('Error', error.body ? error.body.message : error.message, 'error');
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}
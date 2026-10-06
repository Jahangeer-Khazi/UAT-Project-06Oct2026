import { LightningElement, api, track } from 'lwc';
import getLastLoginAttempt from '@salesforce/apex/LoginActivityService.getLastLoginAttempt';

export default class Lwc06_LoginActivityTracker extends LightningElement {
    @api recordId;
    @api pageSize = 100;
    @api maxRangeMonths = 6;

    @track lastLogin;
    @track error;
    @track isLoading = true;

    get locationDisplay() {
        if (!this.lastLogin) {
            return '';
        }
        return this.lastLogin.location || this.lastLogin.unit || '';
    }

    connectedCallback() {
        this.loadInitialData();
    }

    async loadInitialData() {
        this.isLoading = true;
        try {
            this.lastLogin = await getLastLoginAttempt({ customerId: this.recordId });
            this.error = undefined;
        } catch (error) {
            this.error = this.reduceErrors(error);
            this.lastLogin = undefined;
        } finally {
            this.isLoading = false;
        }
    }

    reduceErrors(errors) {
        if (!errors) return 'Unknown error';
        if (Array.isArray(errors)) return errors[0].message || errors[0];
        if (typeof errors === 'object') return errors.body?.message || errors.message || 'Unknown error';
        return errors;
    }
}
import { LightningElement, wire, track, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getCustomerHolds from '@salesforce/apex/CollateralsHoldsController.getCustomerHolds';

const CIF_FIELD = 'Account.CIF__pc';
const REGION_NAME_FIELD = 'Account.Region_Flag__pc';
const XCANARY_FIELD = 'Account.x_canary__pc';

export default class CollateralsHolds extends LightningElement {
    _recordId;
    @api 
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        // Reset state and show spinner
        this.isLoading = true;
        this.isEmpty = false;
        this.selectedAccount = null;
        this.accountsWithHolds = [];
        // The wire will automatically re-run because recordId changed
    }

    @track accountsWithHolds = [];
    @track selectedAccount = null;
    @track isLoading = true;
    @track isEmpty = false;
    @api isAlburaqProduct = false;

    // Reactive CIF value from Account
    cif;
    regionName;
    xcanary;

    // Wire to get the Account record and extract CIF__pc
    @wire(getRecord, { recordId: '$recordId', fields: [CIF_FIELD, REGION_NAME_FIELD, XCANARY_FIELD] })
    wiredAccount({ error, data }) {
        if (data) {
            this.cif = getFieldValue(data, CIF_FIELD);
            this.regionName = getFieldValue(data, REGION_NAME_FIELD);
            this.xcanary = getFieldValue(data, XCANARY_FIELD);

            console.log('cif --->', this.cif);
            console.log('regionName --->', this.regionName);
            console.log('xcanary --->', this.xcanary);

            // If CIF is blank, we can stop loading and show empty state
            if (String.isBlank(this.cif)) {
                this.isLoading = false;
                this.isEmpty = true;
                this.accountsWithHolds = [];
                this.selectedAccount = null;
            }
            // else keep isLoading true until holds are fetched
        } else if (error) {
            console.error('Error fetching Account CIF:', error);
            this.isLoading = false;
            this.isEmpty = true;
            this.accountsWithHolds = [];
            this.selectedAccount = null;
        }
    }

    // Wire to get holds – triggered when cif changes
    @wire(getCustomerHolds, { cif: '$cif', regionName: '$regionName', xCanaryValue: '$xcanary' })
    wiredHolds({ error, data }) {
        // Always turn off spinner when this wire returns
        this.isLoading = false;
        console.log('Data --->', JSON.stringify(data));
        if (data) {
            // Sort holds within each account by FromDate (oldest first)
            this.accountsWithHolds = data.map(account => {
                const sortedHolds = [...account.holds].sort(
                    (a, b) => new Date(a.fromDate) - new Date(b.fromDate)
                );
                return {
                    ...account,
                    holds: sortedHolds,
                    isSelected: false
                };
            });
            this.isEmpty = this.accountsWithHolds.length === 0;
            this.selectedAccount = null;
        } else if (error) {
            console.error('Error fetching holds:', error);
            this.isEmpty = true;
            this.accountsWithHolds = [];
            this.selectedAccount = null;
        }
    }

    // Handle radio button change
    handleRadioChange(event) {
        const selectedAccNumber = event.target.value;
        this.accountsWithHolds = this.accountsWithHolds.map(acc => ({
            ...acc,
            isSelected: acc.accountNumber === selectedAccNumber
        }));
        this.selectedAccount = this.accountsWithHolds.find(
            acc => acc.accountNumber === selectedAccNumber
        );
    }
}
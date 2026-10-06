import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getTransactions from '@salesforce/apex/UARController.getTransactions';
import deleteTransactions from '@salesforce/apex/UARController.deleteTransactions';
import updateTransactions from '@salesforce/apex/UARController.updateTransactions';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CHECKER_RESULT_FIELD from '@salesforce/schema/UAR__c.Checker_Result__c';

export default class UarTransactionViewer extends LightningElement {
    @api recordId;
    @track transactions = [];
    @track originalTransactions = [];
    @track editedTransactions = [];
    @track deletedTransactionIds = [];
    @track isEditMode = false;
    @track isLoading = false;
    @track refreshTrigger = 0;

    wiredTransactionsResult;
    wiredRecordResult;

    today = new Date().toISOString().split('T')[0];

    // Wire service to fetch the Checker_Result__c field
    @wire(getRecord, { recordId: '$recordId', fields: [CHECKER_RESULT_FIELD] })
    wiredRecord({ error, data }) {
        this.wiredRecordResult = data;
        if (error) {
            this.showToast('Error', error.body?.message || error.message, 'error');
        }
    }

    // Getter to disable the button
    get isButtonDisabled() {
        return getFieldValue(this.wiredRecordResult, CHECKER_RESULT_FIELD) === 'Approved';
    }

    get saveDisabled() {
        return this.isLoading || !this.haschanges;
    }

    get isTransactionLimitReached() {
        return this.transactions && this.transactions.length >= 100;
    }

    @wire(getTransactions, { uarId: '$recordId' })
    wiredTransactions(result) {
        this.wiredTransactionsResult = result;
        const { data, error } = result;

        if (data) {
            this.transactions = data.map(trans => ({
                ...trans,
                originalAmount: trans.Transaction_Amount__c,
                originalDate: trans.Transaction_Date__c
            }));
            this.originalTransactions = JSON.parse(JSON.stringify(this.transactions));
            this.editedTransactions = [];
            this.deletedTransactionIds = [];
            this.isLoading = false;
        } else if (error) {
            this.showToast('Error', error.body?.message || error.message, 'error');
            this.isLoading = false;
        }
    }

    handleEdit() {
        this.isEditMode = true;
    }

    handleCancel() {
        this.isEditMode = false;
        this.transactions = JSON.parse(JSON.stringify(this.originalTransactions));
        this.editedTransactions = [];
        this.deletedTransactionIds = [];
    }

    handleTransactionChange(event) {
        const index = event.target.dataset.index;
        const field = event.target.dataset.field;
        const value = event.target.value;

        this.transactions[index] = {
            ...this.transactions[index],
            [field]: value
        };

        const existingEditIndex = this.editedTransactions.findIndex(
            t => t.Id === this.transactions[index].Id
        );

        if (existingEditIndex >= 0) {
            this.editedTransactions[existingEditIndex] = this.transactions[index];
        } else if (!this.transactions[index].isNew) {
            this.editedTransactions.push(this.transactions[index]);
        }
    }

    handleDelete(event) {
        const index = parseInt(event.target.dataset.index, 10);
        const transactionId = this.transactions[index].Id;

        if (transactionId) {
            this.deletedTransactionIds.push(transactionId);
        }

        this.transactions = this.transactions.filter((_, i) => i !== index);
        this.editedTransactions = this.editedTransactions.filter(t => t.Id !== transactionId);
    }

    handleAddNew() {
        this.transactions = [
            ...this.transactions,
            {
                UAR__c: this.recordId,
                Transaction_Amount__c: null,
                Transaction_Date__c: null,
                isNew: true
            }
        ];
    }

    async handleSave() {
        if (!this.validateTransactions()) {
            this.showToast('Error', 'Please fill in all transaction fields before saving', 'error');
            return;
        }

        this.isLoading = true;
        try {
            // Process deletes first
            if (this.deletedTransactionIds.length > 0) {
                await deleteTransactions({ transactionIds: this.deletedTransactionIds });
            }

            // Prepare new transactions (without temporary IDs)
            const newTransactions = this.transactions
                .filter(t => t.isNew)
                .map(({ isNew, ...rest }) => rest);

            // Prepare updates (only changed fields for existing transactions)
            const updates = this.editedTransactions.map(transaction => {
                const { originalAmount, originalDate, ...rest } = transaction;
                return rest;
            });

            // Combine updates and new transactions
            const transactionsToSave = [...updates, ...newTransactions];

            if (transactionsToSave.length > 0) {
                await updateTransactions({ transactions: transactionsToSave });
            }

            this.showToast('Success', this.getSuccessMessage(), 'success');
            this.isEditMode = false;
            await refreshApex(this.wiredTransactionsResult);

        } catch (error) {
            this.showToast('Error', error.body?.message || error.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    validateTransactions() {
        const today = new Date().toISOString().split('T')[0]; // "YYYY-MM-DD"

        for (let i = 0; i < this.transactions.length; i++) {
            const trans = this.transactions[i];

            // ✨ Check amount
            if (!trans.Transaction_Amount__c || isNaN(trans.Transaction_Amount__c) || trans.Transaction_Amount__c <= 0) {
                this.showToast('Error', `Row ${i + 1}: Enter a valid positive transaction amount.`, 'error');
                return false;
            }

            // ✨ Check date
            if (!trans.Transaction_Date__c) {
                this.showToast('Error', `Row ${i + 1}: Transaction date is required.`, 'error');
                return false;
            }

            if (trans.Transaction_Date__c > today) {
                this.showToast('Error', `Row ${i + 1}: Future dates are not allowed.`, 'error');
                return false;
            }
        }

        return true;
    }


    getSuccessMessage() {
        const messageParts = [
            this.deletedTransactionIds.length > 0 ? `${this.deletedTransactionIds.length} deleted` : null,
            this.editedTransactions.length > 0 ? `${this.editedTransactions.length} updated` : null,
            this.transactions.filter(t => t.isNew).length > 0 ? `${this.transactions.filter(t => t.isNew).length} added` : null
        ].filter(Boolean);

        return messageParts.length > 0
            ? `Transactions updated (${messageParts.join(', ')})`
            : 'No changes to save';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    get hasTransactions() {
        return this.transactions && this.transactions.length > 0;
    }

    get haschanges() {
        return this.editedTransactions.length > 0 ||
            this.deletedTransactionIds.length > 0 ||
            this.transactions.some(t => t.isNew);
    }

    get isReadOnly() {
        return !this.isEditMode;
    }
}
import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import PERSON_CONTACT_ID from '@salesforce/schema/Account.PersonContactId';
import getQueueNameToIdMap from '@salesforce/apex/CaseFieldDependencyController.getQueueNameToIdMap';
import createSuspiciousTransactions from '@salesforce/apex/UARController.createSuspiciousTransactions';
import modal from "@salesforce/resourceUrl/custommodalcss";
import { loadStyle } from "lightning/platformResourceLoader";
import { CloseActionScreenEvent } from 'lightning/actions';

export default class UarQuickAction extends NavigationMixin(LightningElement) {
    @track showOtherField = false;
    @track isLoading = false;
    @track queueMap = {};
    @api recordId;
    @track caseModel = 'ila';
    @track transactions = [];
    nextTransactionId = 1;

    today = new Date().toISOString().split('T')[0]; // "YYYY-MM-DD"

    // Wired methods
    @wire(getQueueNameToIdMap)
    wiredQueueMap({ error, data }) {
        if (data) {
            this.queueMap = data;
        } else if (error) {
            console.error('Error loading queue map:', error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [PERSON_CONTACT_ID] })
    personContact;

    get isTransactionLimitReached() {
        return this.transactions && this.transactions.length >= 100;
    }

    // Lifecycle hook
    connectedCallback() {
        loadStyle(this, modal);
        this.handleAddTransaction();
    }

    // Transaction methods
    handleAddTransaction = () => {
        this.transactions = [
            ...this.transactions,
            {
                id: this.nextTransactionId++,
                amount: null,
                date: null
            }
        ];
    }

    handleDeleteTransaction = (event) => {
        const indexToDelete = parseInt(event.target.dataset.index, 10);
        this.transactions = this.transactions.filter(
            (transaction, index) => index !== indexToDelete
        );
    }

    handleTransactionChange = (event) => {
        const index = parseInt(event.target.dataset.index, 10);
        const field = event.target.dataset.field;
        const value = event.target.value;

        this.transactions = this.transactions.map((transaction, idx) => {
            if (idx === index) {
                return { ...transaction, [field]: value };
            }
            return transaction;
        });
    }

    // Form methods
    handleSubTypeChange = (event) => {
        this.showOtherField = event.detail.value === 'Other';
    }

    handleCancel = () => {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSave() {
        this.isLoading = true;
        const recordForm = this.template.querySelector('lightning-record-edit-form');

        // 🔸 Validate transactions
        let transactionValid = true;
        for (let i = 0; i < this.transactions.length; i++) {
            const tx = this.transactions[i];

            // 🔸 Check missing or invalid amount
            if (!tx.amount || isNaN(tx.amount) || tx.amount <= 0) {
                this.showToast('Error', `Transaction ${i + 1}: Please enter a valid transaction amount.`, 'error');
                this.isLoading = false;
                transactionValid = false;
                break;
            }

            // 🔸 Check missing or future date
            if (!tx.date) {
                this.showToast('Error', `Transaction ${i + 1}: Date is required.`, 'error');
                this.isLoading = false;
                transactionValid = false;
                break;
            }

            if (tx.date > this.today) {
                this.showToast('Error', `Transaction ${i + 1}: Future dates are not allowed.`, 'error');
                this.isLoading = false;
                transactionValid = false;
                break;
            }
        }

        if (!transactionValid) {
            return; // 🔒 Block form submission if any transaction is invalid
        }

        if (recordForm) {
            const fields = {};
            let allValid = true;

            recordForm.querySelectorAll('lightning-input-field').forEach(field => {
                fields[field.fieldName] = field.value;
                if (!field.value) {
                    allValid = false;
                    field.reportValidity(); // Show error if field is required but empty
                }
            });

            if (!allValid) {
                this.isLoading = false;
                this.showToast('Error', 'Please fill in all required fields.', 'error');
                return;
            }

            // Set additional required fields
            fields.OwnerId = this.queueMap['UAR Maker'];
            fields.Account__c = this.recordId;
            fields.Contact__c = this.personContactId;
            fields.Sub_Status__c = 'New';
            fields.Status__c = 'UAR Maker Review';

            recordForm.submit(fields); // ✅ Safe to submit
        } else {
            this.isLoading = false;
            console.error('Form not found');
        }
    }


    // Success/error handlers
    async handleSuccess(event) {
        try {
            const uarId = event.detail.id;
            const transactionsToCreate = this.transactions.map(transaction => ({
                UAR__c: uarId,
                Transaction_Amount__c: transaction.amount,
                Transaction_Date__c: transaction.date
            }));

            await createSuspiciousTransactions({ transactions: transactionsToCreate });

            this.showToast('Success', 'UAR created successfully', 'success');
            this.navigateToRecord(uarId);
            this.dispatchEvent(new CustomEvent('close'));

        } catch (error) {
            this.showToast('Error', error.body?.message || error.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleError(event) {
        this.isLoading = false;
        this.showToast('Error', event.detail.message || 'An error occurred', 'error');
    }

    // Navigation
    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId,
                actionName: 'view'
            }
        });
    }

    // Helper
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    get personContactId() {
        return this.personContact?.data?.fields?.PersonContactId?.value || null;
    }
}
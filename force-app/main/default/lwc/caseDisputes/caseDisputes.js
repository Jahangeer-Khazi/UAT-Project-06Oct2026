import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import getCaseDisputesRecordTypeId
    from '@salesforce/apex/CaseDisputesController.getCaseDisputesRecordTypeId';
import { loadStyle } from "lightning/platformResourceLoader";
import modal from "@salesforce/resourceUrl/custommodalcss";
import getAccountIdByCIF from '@salesforce/apex/CaseDisputesController.getAccountIdByCIF';
import getCustomerNameByCIF from '@salesforce/apex/CaseDisputesController.getCustomerNameByCIF';

export default class CaseDisputes extends NavigationMixin(LightningElement) {
    recordTypeId;
    @api recordId;

    isLoading = false;
    accountId = null;
    interactionId = null;
    wrapupCode = null; // NEW: raw value from URL

    @track cif;
    @track customerName;

    connectedCallback() {
        loadStyle(this, modal);
    }

    @wire(getCaseDisputesRecordTypeId)
    wiredRecordType({ data, error }) {
        if (data) {
            this.recordTypeId = data;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(CurrentPageReference)
    getPageReference(pageRef) {
        if (pageRef && pageRef.state) {
            const cif = pageRef.state.c__cif;
            this.cif = cif;
            this.interactionId = pageRef.state.c__interactionId || null;
            this.wrapupCode = pageRef.state.c__wrapupcode || null; // NEW

            if (cif) {
                this.loadAccountByCIF(cif);
            }
        }
    }

    async loadAccountByCIF(cif) {
        if (!cif) return;
        this.isLoading = true;
        try {
            this.accountId = await getAccountIdByCIF({ cif });
            if (!this.accountId) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'No Account found for the provided CIF.',
                        variant: 'error'
                    })
                );
            }

            this.customerName = await getCustomerNameByCIF({ cif });
            if (!this.customerName) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'No Account found for the provided CIF.',
                        variant: 'error'
                    })
                );
            }
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to fetch Account for CIF.',
                    variant: 'error'
                })
            );
            console.error(error);
        } finally {
            this.isLoading = false;
        }
    }

    get effectiveAccountId() {
        return this.recordId || this.accountId;
    }

    get isUrlMode() {
        return !this.recordId && (this.interactionId || this.accountId);
    }

    get containerStyle() {
        if (this.isUrlMode) {
            return 'max-width: 40%; margin: 0 auto; padding: 1rem;';
        }
        return '';
    }

    // NEW: transform raw wrapup code to user-friendly label
    get wrapupLabel() {
        const map = {
            'FCR': 'FCR',
            'customerAbandoned': 'Customer abandoned',
            'EscalatedComplaint': 'Escalated complaint',
            'handoffFault': 'Handed off – Fault',
            'handoffRequest': 'Handed off – Request',
            'disputeFraud': 'Dispute – Fraud'
        };
        return map[this.wrapupCode] || this.wrapupCode; // fallback to raw value
    }

    handleSubmit(event) {
        event.preventDefault();
        const accountId = this.effectiveAccountId;
        if (!accountId) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Account is required. Please ensure a valid Account is selected.',
                    variant: 'error'
                })
            );
            return;
        }

        this.isLoading = true;
        const fields = event.detail.fields;
        fields.AccountId = accountId;
        fields.Origin = 'Phone';
        fields.Sub_Status__c = 'In-Progress';

        // NEW: store interaction ID and wrapup code if present
        if (this.interactionId) {
            fields.bs_Instrument_ID__c = this.interactionId;
        }
        if (this.wrapupCode) {
            fields.Sales_Out_Come__c = this.wrapupCode; // store raw API value
        }

        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event) {
        this.isLoading = false;
        const caseId = event.detail.id;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Case created successfully.',
                variant: 'success'
            })
        );
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseId,
                objectApiName: 'Case',
                actionName: 'view'
            }
        });
    }

    handleError(event) {

        this.isLoading = false;
        console.log('Error -->'+JSON.stringify(event.detail));
        let message = 'An unexpected error occurred.';
        if (event.detail?.detail) {
            message = event.detail.detail;
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error',
                mode: 'sticky'
            })
        );
        
    }

    handleCancel() {
        window.history.back();
    }
}
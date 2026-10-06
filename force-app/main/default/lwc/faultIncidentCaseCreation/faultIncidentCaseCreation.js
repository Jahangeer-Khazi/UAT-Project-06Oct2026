import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { loadStyle } from "lightning/platformResourceLoader";
import modal from "@salesforce/resourceUrl/custommodalcss";

import getFaultIncidentRecordTypeId
    from '@salesforce/apex/FaultIncidentCaseController.getFaultIncidentRecordTypeId';
import getAccountIdByCIF
    from '@salesforce/apex/FaultIncidentCaseController.getAccountIdByCIF';
import createCaseAnnex
    from '@salesforce/apex/FaultIncidentCaseController.createCaseAnnex';
import getCustomerNameByCIF from '@salesforce/apex/FaultIncidentCaseController.getCustomerNameByCIF';

export default class FaultIncidentCaseCreation extends NavigationMixin(LightningElement) {

    recordTypeId;
    @api recordId; // from Quick Action

    // Existing properties
    incidentOutage = false;
    incidentOutageNumber = '';
    isLoading = false;

    // URL mode properties
    accountId = null;
    interactionId = null;
    wrapupCode = null; // NEW

    @track cif;
    @track customerName;

    @wire(getFaultIncidentRecordTypeId)
    wiredRecordType({ data, error }) {
        if (data) {
            this.recordTypeId = data;
        } else if (error) {
            console.error(error);
        }
    }

    // Wire to read URL parameters
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

    // Load Account from CIF
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
            'handoffRequest': 'Handed off – Request'
        };
        return map[this.wrapupCode] || this.wrapupCode;
    }

    // Lifecycle hook
    connectedCallback() {
        loadStyle(this, modal);
    }

    handleIncidentOutage(event) {
        this.incidentOutage = event.target.checked;
        if (!this.incidentOutage) {
            this.incidentOutageNumber = '';
        }
    }

    handleIncidentOutageNumber(event) {
        const value = event.target.value;
        this.incidentOutageNumber = value; // keep the raw value

        // Check if the value contains invalid characters
        if (!/^[a-zA-Z0-9]*$/.test(value)) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Invalid Input',
                    message: 'Only alphanumeric characters are allowed.',
                    variant: 'warning'
                })
            );
        }
    }

    handleSubmit(event) {
        event.preventDefault();

        this.isLoading = true;

        const fields = event.detail.fields;
        const accountId = this.effectiveAccountId;

        if (!accountId) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Account is required. Please ensure a valid Account is selected.',
                    variant: 'error'
                })
            );
            this.isLoading = false;
            return;
        }

        // ---- VALIDATE INCIDENT / OUTAGE NUMBER ----
        if (this.incidentOutage) {
            const number = this.incidentOutageNumber || '';
            // Check if value contains only letters and digits
            if (!/^[a-zA-Z0-9]*$/.test(number)) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Validation Error',
                        message: 'Incident / Outage Number must contain only alphanumeric characters (letters and digits).',
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                this.isLoading = false;
                return; // Prevents the submission
            }
        }
        // -------------------------------------------

        // Set required fields
        fields.AccountId = accountId;
        fields.Status = 'New';
        fields.Sub_Status__c = 'In-Progress';

        if (this.interactionId) {
            fields.bs_Instrument_ID__c = this.interactionId;
        }
        if (this.wrapupCode) {
            fields.Sales_Out_Come__c = this.wrapupCode;
        }

        try {
            this.template
                .querySelector('lightning-record-edit-form')
                .submit(fields);
        } catch (error) {
            console.log('Error Details --->', error);
            this.isLoading = false;
        }
    }

    async handleSuccess(event) {
        const caseId = event.detail.id;

        try {
            await createCaseAnnex({
                caseId: caseId,
                incidentOutage: this.incidentOutage,
                incidentOutageNumber: this.incidentOutageNumber
            });

            this.isLoading = false;

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

        } catch (error) {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.reduceError(error),
                    variant: 'error',
                    mode: 'sticky'
                })
            );
            console.error(error);
        }
    }

    handleError(event) {
        this.isLoading = false;
        let errorMessage = 'An unexpected error occurred.';
        if (event.detail?.detail) {
            errorMessage = event.detail.detail;
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: errorMessage,
                variant: 'error',
                mode: 'sticky'
            })
        );
        console.error(event.detail);
    }

    handleCancel() {
        window.history.back();
    }

    reduceError(error) {
        if (!error) return 'Unknown error';
        if (Array.isArray(error.body)) {
            return error.body.map(e => e.message).join(', ');
        }
        if (error.body?.message) return error.body.message;
        if (error.message) return error.message;
        return 'Unknown error';
    }
}
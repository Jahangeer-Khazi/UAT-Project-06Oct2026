import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';

import CASE_ACCOUNT_ID_FIELD from '@salesforce/schema/Case.AccountId';
import CASE_FATCA_EXPIRY_FIELD from '@salesforce/schema/Case.FATCA_Document_Expiry_Date__c';


const CASE_FIELDS = [CASE_ACCOUNT_ID_FIELD, CASE_FATCA_EXPIRY_FIELD];

export default class Lwc15_FatcaOnboarding extends LightningElement {
    @api recordId;
    isSectionOpen = true;
    isEditMode = false;
    loadingSpinner = false;

    // To track success of both forms
    caseSuccess = false;
    accountSuccess = false;

    selectedFormType = '';

    get isTaxCountryRequired() {
        return this.selectedFormType === 'W-9';
    }

    handleAccountFormLoad(event) {
        if (!this.accountId) return;
        const record = event.detail.records[this.accountId];
        if (record && record.fields && record.fields.FATCA_Declaration_Form_Type__pc) {
            this.selectedFormType = record.fields.FATCA_Declaration_Form_Type__pc.value;
        }
    }

    handleFormTypeChange(event) {
        this.selectedFormType = event.detail.value;
    }

    @wire(getRecord, { recordId: '$recordId', fields: CASE_FIELDS })
    caseRecord;

    get accountId() {
        return getFieldValue(this.caseRecord.data, CASE_ACCOUNT_ID_FIELD);
    }

    subscription = {};
    channelName = '/event/Refresh_Custom_Components__e';

    connectedCallback() {
        this.handleSubscribe();
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }

    handleSubscribe() {
        const messageCallback = (response) => {
            console.log('Refresh event received: ', JSON.stringify(response));
            this.refreshUI();
        };

        subscribe(this.channelName, -1, messageCallback).then((response) => {
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

    handleUnsubscribe() {
        unsubscribe(this.subscription, (response) => {
            console.log('unsubscribe() response: ', JSON.stringify(response));
        });
    }

    async refreshUI() {
        await notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
        if (this.accountId) {
            await notifyRecordUpdateAvailable([{ recordId: this.accountId }]);
        }
    }

    get sectionClass() {
        return this.isSectionOpen ? 'slds-section slds-is-open' : 'slds-section';
    }

    get iconName() {
        return this.isSectionOpen ? 'utility:chevrondown' : 'utility:chevronright';
    }

    toggleSection() {
        this.isSectionOpen = !this.isSectionOpen;
    }

    handleChangeFormValeurs() {
        this.isEditMode = true;
    }

    handleCancel() {
        this.isEditMode = false;
        this.currentSuccessCount = 0;
        this.totalSuccessExpected = 0;
    }

    handleSave() {
        this.loadingSpinner = true;

        let isValid = true;
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        inputFields.forEach(field => {
            if (!field.reportValidity()) {
                isValid = false;
            }
        });

        if (!isValid) {
            this.loadingSpinner = false;
            return;
        }

        const forms = this.template.querySelectorAll('lightning-record-edit-form');
        this.totalSuccessExpected = forms.length;
        this.currentSuccessCount = 0;

        if (forms.length > 0) {
            forms.forEach(form => form.submit());
        } else {
            this.loadingSpinner = false;
            this.isEditMode = false;
        }
    }

    handleSuccess() {
        this.currentSuccessCount++;
        if (this.currentSuccessCount === this.totalSuccessExpected) {
            this.loadingSpinner = false;
            this.isEditMode = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Records updated successfully',
                    variant: 'success'
                })
            );
        }
    }

    handleError(event) {
        this.loadingSpinner = false;
        console.error('Error updating records', event.detail.message);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error updating records',
                message: event.detail.message || event.detail.detail,
                variant: 'error'
            })
        );
    }
}
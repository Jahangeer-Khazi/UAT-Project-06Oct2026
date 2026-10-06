import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecordTypeId } from './temporaryCreditUtils';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getPicklistData from '@salesforce/apex/TemporaryCreditHandler.getConsolidatedRoutingDetails';

import CASE_OBJECT from '@salesforce/schema/Case';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import CASEMODEL_FIELD from '@salesforce/schema/Case.Case_Model__c';
import TYPE_FIELD from '@salesforce/schema/Case.Type';
import SUBTYPE_FIELD from '@salesforce/schema/Case.Sub_Type__c';
import REQUESTTYPE_FIELD from '@salesforce/schema/Case.cc_Request_Type__c';
import CASEORIGIN_FIELD from '@salesforce/schema/Case.Origin';
import CASENATURE_FIELD from '@salesforce/schema/Case.Case_Nature__c';
import MERCHANTNAME_FIELD from '@salesforce/schema/Case.Merchant_Name__c';
import RECORDTYPE_FIELD from '@salesforce/schema/Case.RecordTypeId';
import CUSTOMER_FIELD from '@salesforce/schema/Case.AccountId';
import SUBSTATUS_FIELD from '@salesforce/schema/Case.Sub_Status__c';
import OWNER_FIELD from '@salesforce/schema/Case.OwnerId';

import CASEANNEX_OBJECT from '@salesforce/schema/CaseAnnex__c';
import APPROVEDBY_FIELD from '@salesforce/schema/CaseAnnex__c.Approved_by__c';
import CREDITAMOUNT_FIELD from '@salesforce/schema/CaseAnnex__c.Credit_Amount__c';
import CREDITREASON_FIELD from '@salesforce/schema/CaseAnnex__c.Credit_Reason__c';
import OTHERREASON_FIELD from '@salesforce/schema/CaseAnnex__c.Other_Reason__c';
import CASE_FIELD from '@salesforce/schema/CaseAnnex__c.Case__c';

export default class TemporaryCreditRequest extends NavigationMixin(LightningElement) {
    // Fields for Case
    @track subject = 'New Temporary Credit Request';
    @track description = '';
    @track caseModel = '';
    @track caseType = '';
    @track caseSubType = '';
    @track caseRequestType = '';
    @track caseOrigin = '';
    @track caseNature = '';
    @track merchantName = '';

    // Fields for Case Annex
    @track tempCreditReason = '';
    @track showOtherReason = false;
    @track otherReason = '';
    @track tempCreditAmount = null;
    @track approvedBy = '';

    // Miscellaneous Fields
    isLoading = false;
    isLoaded = false;
    noAccess = false;
    caseId;
    @track caseTypeSelected = false; // Tracks if Type is selected
    @track caseSubTypeSelected = false; // Tracks if Sub Type is selected

    // Picklist Options
    @track caseModelOptions = [];
    @track caseTypeOptions = [];
    @track caseSubTypeOptions = [];
    @track caseOriginOptions = [];
    @track caseNatureOptions = [];
    @track caseRequestTypeOptions = [];
    @track tempCreditReasonOptions = [];
    @track currencyOptions = [
        { label: 'BHD', value: 'BHD' },
        { label: 'USD', value: 'USD' },
        { label: 'EUR', value: 'EUR' },
        { label: 'AED', value: 'AED' },
        { label: 'SAR', value: 'SAR' },
        { label: 'KWD', value: 'KWD' },
        { label: 'GBP', value: 'GBP' },
        { label: 'CAD', value: 'CAD' }
    ];
    @track approvedByOptions = [];
    @track recordTypeMap;
    @track profileName;
    @track queueId;

    @api recordId;

    @wire(getPicklistData)
    picklistValuesConsolidatedData({ error, data }) {
        if (data) {
            if (data.length > 0 && data[0].Error) {
                this.noAccess = true;
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: data[0].Error,
                    variant: 'error'
                });
                this.dispatchEvent(event);
            } else {
                this.profileName = data[0].ProfileName;
                this.queueId = data[0].QueueId;
                this.populatePicklistOptionsCustom(data[0], {
                    Type: 'caseTypeOptions',
                    Sub_Type__c: 'caseSubTypeOptions',
                    cc_Request_Type__c: 'caseRequestTypeOptions',
                    Origin: 'caseOriginOptions',
                    Case_Nature__c: 'caseNatureOptions'
                });
            }
        } else if (error) {
            this.noAccess = true;
            console.error('Error fetching picklist values:', error);
        }
    }

    // Fetch picklist values for the Case Object
    @wire(getPicklistValuesByRecordType, { objectApiName: CASE_OBJECT, recordTypeId: '012000000000000AAA' })
    casePicklistValuesHandler({ error, data }) {
        if (data) {
            this.populatePicklistOptionsForCaseModel(data, {
                Case_Model__c: 'caseModelOptions'
                //Currency__c: 'currencyOptions'
            });
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    // Fetch picklist values for the Case Annex Object
    @wire(getPicklistValuesByRecordType, { objectApiName: CASEANNEX_OBJECT, recordTypeId: '012000000000000AAA' })
    caseAnnexPicklistValuesHandler({ error, data }) {
        if (data) {
            this.populatePicklistOptions(data, {
                Approved_by__c: 'approvedByOptions',
                Credit_Reason__c: 'tempCreditReasonOptions',
            });
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    // Fetch record type ID for the Case Object
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseObjectInfoHandler({ error, data }) {
        if (data) {
            this.recordTypeMap = new Map(Object.values(data.recordTypeInfos).map(item => [item.name, item.recordTypeId]));
            console.log('recordTypeMap -->', this.recordTypeMap);
        } else if (error) {
            console.error('Error fetching record type info:', error);
        }
    }

    renderedCallback() {
        // Ensure the style is added only once
        if (this.isLoaded) return;

        // Create a <style> element
        const STYLE = document.createElement("style");
        STYLE.innerText = `
        .uiModal--horizontalForm .modal-container {
            width: 40% !important;
            max-width: 40% !important;
            height: 100%;
        }
    `;

        // Append the style element to the component
        const lightningCard = this.template.querySelector('lightning-card');
        if (lightningCard) {
            lightningCard.appendChild(STYLE);
            this.isLoaded = true; // Mark as loaded
        }
    }

    // Populate picklist options
    populatePicklistOptions(data, fieldMapping) {
        for (const fieldName in fieldMapping) {
            const options = data.picklistFieldValues[fieldName]?.values || [];
            this[fieldMapping[fieldName]] = options.map(item => ({
                label: item.label,
                value: item.value,
            }));
        }
    }

    // Populate picklist options
    populatePicklistOptionsForCaseModel(data, fieldMapping) {
        for (const fieldName in fieldMapping) {
            const options = data.picklistFieldValues[fieldName]?.values || [];
            this[fieldMapping[fieldName]] = [
                { label: 'None', value: '' }, // Adding 'None' as the first option
                ...options.map(item => ({
                    label: item.label,
                    value: item.value,
                }))
            ];
        }
    }

    populatePicklistOptionsCustom(data, fieldMapping) {
        for (const fieldName in fieldMapping) {
            let fldName = fieldName.toString();
            // Split the comma-separated values into an array
            const values = data[fieldName]?.split(',') || [];

            // Map the values to a format required by the UI (label & value)
            this[fieldMapping[fieldName]] = [
                { label: 'None', value: '' }, // Add the "None" option
                ...values.map(item => ({
                    label: item.trim(), // Trim to remove extra spaces
                    value: item.trim()
                }))
            ];
        }
    }

    // Handle changes for Temporary Credit Reason
    handleTempCreditReasonChange(event) {
        this.tempCreditReason = event.detail.value;
        this.showOtherReason = this.tempCreditReason === 'Other Reason';
    }

    // Handle Save
    handleSave() {
        this.isLoading = true;
        const isValid = [...this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea')]
            .reduce((valid, field) => valid && field.reportValidity(), true);

        if (isValid) {
            this.createCase();
        } else {
            this.isLoading = false;
        }
    }

    createCase() {
        const fields = {
            [SUBJECT_FIELD.fieldApiName]: this.subject,
            [DESCRIPTION_FIELD.fieldApiName]: this.description,
            [CASEMODEL_FIELD.fieldApiName]: this.caseModel,
            [TYPE_FIELD.fieldApiName]: this.caseType,
            [SUBTYPE_FIELD.fieldApiName]: this.caseSubType,
            [REQUESTTYPE_FIELD.fieldApiName]: this.caseRequestType,
            [CASEORIGIN_FIELD.fieldApiName]: this.caseOrigin,
            [CASENATURE_FIELD.fieldApiName]: this.caseNature,
            [MERCHANTNAME_FIELD.fieldApiName]: this.merchantName,
            //[RECORDTYPE_FIELD.fieldApiName]: this.requestRecordTypeId,
            [CUSTOMER_FIELD.fieldApiName]: this.recordId,
            [SUBSTATUS_FIELD.fieldApiName]: 'In-Progress',
        };

        const recordTypeId = getRecordTypeId(this.caseType, this.caseSubType, this.caseRequestType);
        if (recordTypeId) {
            fields[RECORDTYPE_FIELD.fieldApiName] = this.recordTypeMap.get(recordTypeId);
        }

        if (recordTypeId == 'Request' && (this.profileName == 'RMT' || this.profileName == 'ila Risk')) {
            fields[OWNER_FIELD.fieldApiName] = this.queueId;
        }

        console.log('Fields -->', JSON.stringify(fields));

        createRecord({ apiName: CASE_OBJECT.objectApiName, fields })
            .then(caseRecord => this.createCaseAnnex(caseRecord))
            .catch(error => {
                // Log the error message for debugging
                console.error('Error creating Case:', error);

                let errorMessage = 'An error occurred while creating the case.';

                // Extracting the custom validation message
                if (error && error.body && error.body.output && error.body.output.errors) {
                    let errors = error.body.output.errors;
                    if (errors.length > 0 && errors[0].message) {
                        errorMessage = errors[0].message;
                    }
                }

                this.showErrorToast('Error', errorMessage);
            });
    }

    createCaseAnnex(caseRecord) {
        const fields = {
            [APPROVEDBY_FIELD.fieldApiName]: this.approvedBy,
            [CREDITAMOUNT_FIELD.fieldApiName]: this.tempCreditAmount,
            [CREDITREASON_FIELD.fieldApiName]: this.tempCreditReason,
            [OTHERREASON_FIELD.fieldApiName]: this.otherReason,
            [CASE_FIELD.fieldApiName]: caseRecord.id,
        };

        createRecord({ apiName: CASEANNEX_OBJECT.objectApiName, fields })
            .then(() => this.navigateToRecord(caseRecord))
            .catch(error => this.showErrorToast('Error creating Case Annex', error.body.message));
    }

    navigateToRecord(caseRecord) {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseRecord.id,
                actionName: 'view',
            },
        }).then(url => {
            this.showSuccessToast('Case created successfully!', url, caseRecord.fields.CaseNumber.value);
            this.closeQuickAction();
        });
    }

    // Toast Notifications
    showSuccessToast(title, url, caseNumber) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message: `Case {0} was created!`,
            messageData: [{ url, label: caseNumber }],
            variant: 'success',
        }));
    }

    showErrorToast(title, message) {
        this.isLoading = false;
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant: 'error',
        }));
    }

    // Handle Cancel
    handleCancel() {
        this.closeQuickAction();
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    // Handle input changes dynamically
    handleChange(event) {
        this[event.target.name] = event.target.value;
        const { name, value } = event.target;

        if (name === 'caseType') {
            this.caseTypeSelected = value !== ''; // Enable Sub Type if Type is selected
            if (!this.caseTypeSelected) {
                this.caseSubTypeSelected = false; // Reset Sub Type selection
                this.caseSubType = ''; // Clear Sub Type value
                this.caseRequestType = ''; // Clear Request Type value
            }
        }

        if (name === 'caseSubType') {
            if (this.caseSubType == 'Temporary Credit') {
                this.caseRequestType = 'Temporary Credit Case';
                this.caseOrigin = 'Phone';
            }
            this.caseSubTypeSelected = value !== ''; // Enable Request Type if Sub Type is selected
            if (!this.caseSubTypeSelected) {
                this.caseRequestType = ''; // Clear Request Type value
            }
        }
    }

    get isSubTypeDisabled() {
        return !this.caseTypeSelected; // Determines if Sub Type should be disabled
    }

    get isRequestTypeDisabled() {
        return !this.caseSubTypeSelected; // Determines if Request Type should be disabled
    }

    get isTempCreditCase() {
        return this.caseRequestType === 'Temporary Credit Case';
    }
}
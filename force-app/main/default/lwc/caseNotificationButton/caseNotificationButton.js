import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import sendDiscrepancySMS from '@salesforce/apex/CaseNotificationController.sendDiscrepancySMS';

const FIELDS = [
    'Case.Case_Model__c',
    'Case.Owner.Name',
    'Case.Account.Name',
    'Case.Account.PersonMobilePhone',
    'Case.Sub_Type__c'          // added for Top‑up detection
];

// Queue → display stage mapping (must match Apex logic)
const STAGE_KEYWORDS = {
    'Loan Pre-Screener Queue': 'Pre‑Screener',
    'Loan Document Verifier OBL': 'OBL',
    'Loan Document Verifier NDL': 'NDL',
    'Loan Document Verifier STL': 'STL'
};

export default class CaseNotificationButton extends LightningElement {
    @api recordId;

    caseData = {};
    isProcessing = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredCase({ error, data }) {
        if (data) {
            const ownerName = getFieldValue(data, 'Case.Owner.Name') || '';
            const subType = getFieldValue(data, 'Case.Sub_Type__c') || '';

            this.caseData = {
                customerName: getFieldValue(data, 'Case.Account.Name') || 'N/A',
                customerPhone: getFieldValue(data, 'Case.Account.PersonMobilePhone') || 'Not available',
                product: getFieldValue(data, 'Case.Case_Model__c') || 'Unknown',
                stage: this.extractStage(ownerName, subType)
            };
        } else if (error) {
            console.error('Error loading case:', error);
            this.caseData = {
                customerName: 'N/A',
                customerPhone: 'Not available',
                product: 'Unknown',
                stage: 'N/A'
            };
        }
    }

    // Enhanced stage detection: first check Sub_Type for "Top-up"
    extractStage(ownerName, subType) {
        // 1. If Sub_Type is "Top-up", return "Top‑up" (display friendly)
        if (subType && subType.toLowerCase() === 'top-up') {
            return 'Top‑up';
        }

        // 2. Otherwise derive from owner name (queue mapping)
        if (!ownerName) return 'N/A';
        const lower = ownerName.toLowerCase();
        for (const [key, value] of Object.entries(STAGE_KEYWORDS)) {
            if (lower.includes(key.toLowerCase())) {
                return value;
            }
        }
        return 'N/A';
    }

    // Getters for template
    get customerName() { return this.caseData.customerName; }
    get customerPhone() { return this.caseData.customerPhone; }
    get product() { return this.caseData.product; }
    get stage() { return this.caseData.stage; }

    get sendButtonLabel() {
        return this.isProcessing ? 'Sending...' : 'Send SMS';
    }

    get sendButtonIcon() {
        return this.isProcessing ? null : 'utility:send';
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSend() {
        this.isProcessing = true;

        sendDiscrepancySMS({ caseId: this.recordId })
            .then(result => {
                const isSuccess = result.startsWith('SUCCESS');
                this.showToast(isSuccess ? 'success' : 'error', result);
                setTimeout(() => {
                    this.dispatchEvent(new CloseActionScreenEvent());
                }, 2200);
            })
            .catch(error => {
                const errMsg = error.body?.message || error.message || 'Unknown error';
                this.showToast('error', 'Failed to send SMS: ' + errMsg);
                this.isProcessing = false;
            });
    }

    showToast(variant, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: variant === 'success' ? 'Success' : 'Error',
                message: message,
                variant: variant,
                mode: 'dismissable'
            })
        );
    }
}
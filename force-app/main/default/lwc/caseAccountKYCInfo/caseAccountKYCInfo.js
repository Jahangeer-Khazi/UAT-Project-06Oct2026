import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import ACCOUNT_ID from '@salesforce/schema/Case.AccountId';

export default class CaseRelatedAccountDetails extends LightningElement {
    @api recordId; // Case Record ID
    accountId;
    isLoaded = false;

    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_ID] })
    wiredCase({ error, data }) {
        if (data) {
            this.accountId = data.fields.AccountId.value;
        } else {
            this.accountId = null;
        }
    }

    renderedCallback() {
        // Ensure the style is added only once
        if (this.isLoaded) return;

        // Create a <style> element
        const STYLE = document.createElement("style");
        STYLE.innerText = `
        .slds-accordion__summary {
            font-size: 1rem;
            background: #f3f2f2;
            padding: 0.50rem;
            cursor: pointer;
        }
        .lightning-output-field {
            border-bottom: 1px solid #c9c9c9;
        }
    `;

        // Append the style element to the component
        const lightningCard = this.template.querySelector('lightning-record-view-form');
        if (lightningCard) {
            lightningCard.appendChild(STYLE);
            this.isLoaded = true; // Mark as loaded
        } 
    }
}
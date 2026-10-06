import { LightningElement, wire, api, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import CASE_OBJECT from '@salesforce/schema/Case';
import modal from "@salesforce/resourceUrl/custommodalcss";
import { loadStyle } from "lightning/platformResourceLoader";
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CreateCreditCardServiceRequest extends NavigationMixin(LightningElement) {
    recordTypeId;
    @api recordId;
    @track caseModel = 'ila';
    @track isLoading = false;

    connectedCallback() {
        loadStyle(this, modal);
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            const rtis = data.recordTypeInfos;
            this.recordTypeId = Object.keys(rtis).find(
                rtId => rtis[rtId].name === 'Credit Card Services'
            );
        }
        if (error) {
            console.error(error);
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    handleError(event) {
        this.isLoading = false;
        this.showToast('Error', event.detail.message || 'An error occurred', 'error');
    }

    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId,
                actionName: 'view'
            }
        });
    }

    handleCancel = () => {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}
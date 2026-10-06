import { LightningElement, api, wire  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import updateCaseStatus from '@salesforce/apex/Loans_CaseReopenController.updateCaseStatus';
import { getRecord, getFieldValue  } from 'lightning/uiRecordApi';
import CASE_MODEL_FIELD from "@salesforce/schema/Case.Case_Model__c";

export default class ReopenExpiredCase extends LightningElement {
    @api recordId;
    isLoading = false;

    @wire(getRecord, { recordId: '$recordId', fields: [CASE_MODEL_FIELD] })
    caseDetail;

    get confirmationMessage() {
        const caseModel = getFieldValue(this.caseDetail.data, CASE_MODEL_FIELD);
        if (!caseModel) {
            return 'Loading case details...';
        }
        console.log('caseModel --->',caseModel);
        return caseModel === 'ila'
            ? 'By proceeding with reopening the case, it will be routed back to the Pre-Screener Queue and the Status of the Expired Loan Application will be changed to "Under Review".'
            : 'By proceeding with reopening the case, it will be routed back to the Pre-Screener Queue and the Status of the Expired Finance Application will be changed to "Under Review".';
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    async handleConfirm() {
        this.isLoading = true;

        try {
            const result = await updateCaseStatus({ caseId: this.recordId });

            if (result.statusCode === 200) {
                this.showToast('Success', 'Case has been successfully reopened and routed to Pre-Screener Queue.', 'success');

                // Refresh the view to show updated values
                eval("$A.get('e.force:refreshView').fire();");

                // Close the action
                this.handleCancel();
            } else {
                throw new Error(result.message || 'Unknown error occurred');
            }
        } catch (error) {
            console.error('Error updating case:', error);
            this.showToast(
                'Error',
                'The Case cannot be reopened, please check system Action/ Logs and call the system admin',
                'error'
            );
        } finally {
            this.isLoading = false;
            this.handleCancel();
        }
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(toastEvent);
    }
}
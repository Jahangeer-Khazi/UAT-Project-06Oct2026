import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import cancelFawriTransaction from '@salesforce/apex/CaseFawriTransferController.cancelFawriTransaction';
import getFawriApiCount from '@salesforce/apex/CaseFawriTransferController.getFawriApiCount';
import isUserInCheckerQueue from '@salesforce/apex/CaseFawriTransferController.isUserInCheckerQueue';
import BATCHID_FIELD from '@salesforce/schema/Case.New_Mobile_Number__c';

const FIELDS = [BATCHID_FIELD];

export default class FawriCancelTransactionButton extends LightningElement {

    @api recordId;
    userInCheckerQueue = false;
    exhauseexhaustedApiLimit = false;
    currentCancelApiCount = 0;
    currentCancelApiCount = 0;
    showSpinner = false;
    batchId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredCase({ error, data }) {
        if (data) {
            this.batchId = getFieldValue(data, BATCHID_FIELD);
            console.log('Batch ID from Case:', this.batchId);
        } else if (error) {
            console.error('Error fetching Case record:', error);
        }
    }

    @wire(isUserInCheckerQueue)
    checkerUserResult({ data, error }) {
        if (data) {
            console.log("isUserInCheckerQueue response ", data);
            this.userInCheckerQueue = data;
        }
        else {
            console.error("Error while checking Checker Queue User ", error);
        }
    }

    @wire(getFawriApiCount, { recordId: '$recordId' })
    fawriRecordApiCount({ data, error }) {
        if (data) {
            console.log("Fawri Record count api ", data);
            this.currentCancelApiCount = data.Fawri_Cancel_Api_Count__c;

            if (data.Fawri_Cancel_Api_Count__c >= 3) {
                this.exhauseexhaustedApiLimit = true;
            }
        }
        else {
            console.log("Fawri Record count api error ", error);
        }
    }

    handleClick() {
        if (!this.batchId) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Batch ID is missing. The transaction cannot be cancelled.',
                    variant: 'error'
                })
            );
            return;
        }

        this.showSpinner = true;
        cancelFawriTransaction({
            recordId: `${this.recordId}`
        })
            .then((response) => {
                this.showSpinner = false;
                console.log('response Fawri Cancel Api ', response);
                this.currentCancelApiCount = this.currentCancelApiCount + 1;
                if (this.currentCancelApiCount >= 3) {
                    this.exhauseexhaustedApiLimit = true;
                }

                if (response && response.isSuccess) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Cancellation request initiated successfully.',
                            variant: 'success'
                        })
                    );
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Cancellation request failed. Please retry.',
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(error => {
                this.showSpinner = false;
                console.log('error 104 ', JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Cancellation request failed. Please retry.',
                        variant: 'error'
                    })
                );
            });
    }
}
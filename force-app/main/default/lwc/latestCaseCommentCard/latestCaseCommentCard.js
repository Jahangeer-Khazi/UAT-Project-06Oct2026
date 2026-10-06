import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from "@salesforce/apex";
import { updateRecord } from "lightning/uiRecordApi";
import ID_FIELD from "@salesforce/schema/Case.Id";
import { NavigationMixin } from 'lightning/navigation';
import RECENT_UPDATE_FIELD from "@salesforce/schema/Case.Recent_Updates__c";
import getRecentCaseComments from '@salesforce/apex/CaseCommentController.getRecentCaseComments';
import {
    subscribe,
    unsubscribe,
    onError,
    setDefaultFlag,
    isEmpEnabled
} from 'lightning/empApi';

export default class CaseCommentCard extends NavigationMixin(LightningElement) {
    @api recordId;
    @api channelName = '/event/Refresh_Custom_Components__e';
    @track commentData = [];
    error;
    noData = false;
    isLoading = false;
    @track wiredCommentData = {};
    activeSections = ['A'];

    @wire(getRecentCaseComments, { accountId: '$recordId' })
    wiredComments(result) {
        this.wiredCommentData = result
        console.log('wired data -->' + JSON.stringify(this.wiredCommentData));

        if (result.data) {
            this.commentData = result.data;
            this.noData = result.data.length === 0;

        } else if (result.error) {
            this.error = result.error;
            this.noData = true;
        }
    }

    connectedCallback() {
        this.isLoading = true;
        const self = this;
        const callbackFunction = function (response) {
            self.refreshMyData();
        }
        subscribe(this.channelName, -1, callbackFunction).then(response => {
            this.isLoading = false;
        })
    }

    get innerCardClass() {
        return this.commentData && this.commentData.length > 0 ? 'inner-card' : '';
    }

    refreshMyData() {
        refreshApex(this.wiredCommentData).then(() => {
            console.log('2');
            this.collapseSections();
        })
    }

    renderedCallback() {
        console.log('1');
        this.collapseSections();
    }

    collapseSections() {
        const elements = this.template.querySelectorAll('[data-ssexpanded]');

        console.log('Found sections:', elements); // Debugging

        elements.forEach((element, index) => {
            console.log('Processing section', index, element); // Debugging

            if (index === 0) {
                console.log('Expanding first section:', element); // Debugging

                element.dataset.ssexpanded = "true";
                element.classList.add('slds-is-open');

                let elementId = element.dataset.id;
                let theObj = this.template.querySelector(`lightning-button-icon[data-id="${elementId}"]`);
                if (theObj) {
                    theObj.iconName = 'utility:chevrondown';
                }
            } else {
                console.log('Collapsing section:', element); // Debugging

                element.dataset.ssexpanded = "false";
                element.classList.remove('slds-is-open');

                let elementId = element.dataset.id;
                let theObj = this.template.querySelector(`lightning-button-icon[data-id="${elementId}"]`);
                if (theObj) {
                    theObj.iconName = 'utility:chevronright';
                }
            }
        });
    }

    markAsRead(event) {
        const caseId = event.currentTarget.title;
        // Set loading state
        this.isLoading = true;

        // Define the two asynchronous operations
        const updateOperation = this.updateCaseCommentRead(caseId);
        const navigationOperation = this.navigateToCaseRecord(caseId);

        // Run both operations concurrently
        Promise.all([updateOperation, navigationOperation])
            .then(([updateResult, navigateResult]) => {
                console.log('Record updated and navigation successful:', updateResult, navigateResult);
            })
            .catch(error => {
                // Handle any error in either operation
                console.error('Error during update or navigation:', error);
            })
            .finally(() => {
                // Reset loading state regardless of success or failure
                this.isLoading = false;
            });
    }

    // Helper method for updating the Case Comment Read field
    updateCaseCommentRead(caseId) {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = caseId;
        fields[RECENT_UPDATE_FIELD.fieldApiName] = false;

        const recordInput = { fields };

        return updateRecord(recordInput)
            .then((record) => {
                console.log('Record updated successfully:', record);
                return record;
            })
            .catch((error) => {
                console.error('Error updating the record:', error);
                throw error;
            });
    }

    // Helper method for navigating to the Case record page
    navigateToCaseRecord(caseId) {
        return this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseId,
                actionName: 'view'
            }
        });
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
    }

    handleSubSectionToggle(event) {
        this.sectionToggleHelper(event, 'subSection');
    }

    sectionToggleHelper(event, level) {
        let currentId = event.target.dataset.id;
        var divblock = this.template.querySelector(`[data-id="${currentId}"]`);
        if (divblock) {
            if ((divblock.dataset.expanded && divblock.dataset.expanded == "true") || (level && level == 'subSection' && divblock.dataset.ssexpanded && divblock.dataset.ssexpanded == "true")) {
                divblock.classList.remove('slds-is-open');

                if (level && level == 'subSection') {
                    event.target.iconName = 'utility:chevronright';
                    divblock.dataset.ssexpanded = "false";
                }
                else {
                    divblock.dataset.expanded = "false";
                }
            }
            else {
                divblock.classList.add('slds-is-open');
                if (level && level == 'subSection') {
                    event.target.iconName = 'utility:switch';
                    divblock.dataset.ssexpanded = "true";
                }
                else {
                    divblock.dataset.expanded = "true";
                }
            }
        }
    }
}
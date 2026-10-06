import { LightningElement, api, track, wire } from 'lwc';
import cloneRecordWithFiles from '@salesforce/apex/CloneRecordController.cloneRecordWithFiles';
import insertClonedRecord from '@salesforce/apex/CloneRecordController.insertClonedRecord';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import { IsConsoleNavigation, closeTab, getFocusedTabInfo } from 'lightning/platformWorkspaceApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import ALERTIFYJS from '@salesforce/resourceUrl/Alertify';

export default class CustomRelatedListLWC extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track data;
    caseId;

    alertifyJsLoaded = false;

    // Reference to the loaded JS and CSS files
    alertifyJs;
    alertifyCss;

    @wire(IsConsoleNavigation)
    isConsoleNavigation;

    async connectedCallback() {
        if (this.isConsoleNavigation) {
            try {
                const tabInfo = await getFocusedTabInfo();
                console.log('tab ' + JSON.stringify(tabInfo));
                //this.caseId = tabInfo.recordId;
            } catch (error) {
                console.error('Error setting tab info:', error);
            }
        }
        this.loadCustomStyles();
    }

    loadCustomStyles() {
        Promise.all([
            loadScript(this, ALERTIFYJS + '/alertify.min.js'),
            loadStyle(this, ALERTIFYJS + '/css/alertify.min.css')
        ])
            .then(() => {
                this.alertifyJsLoaded = true; // Set flag when loaded
                alertify.defaults.position = 'top-center';
            })
            .catch(error => {
                console.error('Error loading AlertifyJS static resource:', error);
            });
    }

    @wire(cloneRecordWithFiles, { recordId: '$recordId' })
    cloneRecord({ data, error }) {
        this.dispatchEvent(new CloseActionScreenEvent());
        this.isLoading = true;

        if (data) {
            this.data = data;
            this.handleFileCloning(data.cloneContentDocumentLinkList);
        } else if (error) {
            this.handleError(error);
        }

        this.isLoading = false;
    }

    handleFileCloning(fileList) {
        if (fileList && fileList.length > 0) {
            this.handleConfirm();
        } else {
            alertify.error('There are no files linked to the Content for cloning. Please try another Content Record.');
            //this.showToast('Error', 'There are no files linked to the Content for cloning. Please try another Content Record.', 'error');
            this.closeTabIfConsoleNavigation();
        }
    }

    handleError(error) {
        console.error('Error:', JSON.stringify(error));
        alertify.error(error.body.message || 'An error occurred');
        //this.showToast('Error', error.body.message || 'An error occurred', 'error');
        this.closeTabIfConsoleNavigation();
    }

    closeTabIfConsoleNavigation() {
        if (this.isConsoleNavigation) {
            getFocusedTabInfo()
                .then(tabInfo => closeTab(tabInfo.tabId))
                .catch(console.error);
        }
    }

    async handleConfirm() {
        const confirmed = await LightningConfirm.open({
            message: 'Are you sure you want to clone the Content Record with its related files?',
            theme: 'Info',
            label: 'Confirmation'
        });

        if (confirmed) {
            this.cloneContentRecord();

        } else {
            this.closeTabIfConsoleNavigation();
        }
    }

    cloneContentRecord() {
        insertClonedRecord({ cloneJSON: JSON.stringify(this.data), caseRecordId: this.caseId })
            .then(() => {
                alertify.success("The Content record has been cloned and linked");
                this.closeTabIfConsoleNavigation();
            })
            .catch(error => {
                console.error('Error during clone insert:', error);
                alertify.error(error.body.message || 'An error occurred while cloning.');
            });
    }

}
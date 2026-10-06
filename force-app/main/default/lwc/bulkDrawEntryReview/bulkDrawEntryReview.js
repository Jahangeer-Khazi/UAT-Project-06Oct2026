import { LightningElement, api, track, wire } from 'lwc';
import getParticipantDetails from '@salesforce/apex/RaffleBulkExclusionController.getParticipantDetails';
import saveBulkExclusions from '@salesforce/apex/RaffleBulkExclusionController.saveBulkExclusions';
import getDrawRegion from '@salesforce/apex/RaffleBulkExclusionController.getDrawRegion';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';

export default class RaffleBulkExclusion extends NavigationMixin(LightningElement) {
    // Private properties with getters/setters
    _currentDrawId;
    _currentPrizeType;
    _currentDrawName;

    @api
    get currentDrawId() {
        return this._currentDrawId;
    }
    set currentDrawId(value) {
        this._currentDrawId = value;
        this.displayedDrawId = value || '';
    }

    @api
    get currentDrawName() {
        return this._currentDrawName;
    }
    set currentDrawName(value) {
        this._currentDrawName = value;
        this.displayedDrawName = value || '';
    }

    @api
    get currentPrizeType() {
        return this._currentPrizeType;
    }
    set currentPrizeType(value) {
        this._currentPrizeType = value;
        this.displayedPrizeType = value || '';
    }

    // Tracked properties
    @track justification = '';
    @track parsedData = [];
    @track isLoading = false;
    @track contentDocId;
    @track contentDocIds = [];
    @track displayedDrawId = '';
    @track displayedPrizeType = '';
    @track displayedDrawName = '';

    // Add new tracked property
    @track isBahrainRegion = false;
    @track showWarningBanner = false;

    // Wire service for page reference
    @wire(CurrentPageReference)
    wiredPageRef(currentPageReference) {
        if (currentPageReference?.state) {
            const state = currentPageReference.state;
            this.currentDrawId = state.c__currentDrawId || this.currentDrawId;
            this.currentPrizeType = state.c__currentPrizeType || this.currentPrizeType;
            this.currentDrawName = state.c__currentDrawName || this.currentDrawName;
        }
    }

    connectedCallback() {
        if (this.currentDrawId) {
            this.isLoading = true;
            getDrawRegion({ drawId: this.currentDrawId })
                .then(result => {
                    this.isBahrainRegion = result === 'Bahrain';
                    this.showWarningBanner = !this.isBahrainRegion;
                })
                .catch(error => {
                    console.error('Error fetching region:', error);
                    // Default to Bahrain region if there's an error
                    this.isBahrainRegion = true;
                    this.showWarningBanner = false;
                })
                .finally(() => {
                    this.isLoading = false;
                });
        }
    }

    handleBack() {
        this.isLoading = true;
        try {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordRelationshipPage',
                attributes: {
                    recordId: this.currentDrawId,
                    objectApiName: 'Draw__c',
                    relationshipApiName: 'Draw_Entries_Review__r',
                    actionName: 'view'
                }
            });
        } catch (error) {
            console.error('Navigation error:', error);
            window.location.href = `/lightning/r/Draw__c/${this.currentDrawId}/related/Draw_Entries_Review__r/view`;
        } finally {
            this.isLoading = false;
        }
    }

    handleJustificationChange(event) {
        this.justification = event.target.value;
    }

    handleFileUpload(event) {
        const uploadedFiles = event.detail.files;
        if (uploadedFiles.length === 0) return;

        // Filter only CSV files
        const csvFiles = uploadedFiles.filter(file => file.name.endsWith('.csv'));

        if (csvFiles.length === 0) {
            this.showErrorToast('Invalid File Format', 'Please upload valid CSV files with .csv extension.');
            return;
        }

        this.isLoading = true;
        this.contentDocIds = csvFiles.map(file => file.documentId);
        this.processAllFiles();
        //this.readCSVFile(latestFile.documentId);
    }

    // Handle file upload error
    handleFileUploadError(event) {
        const errorMessage = 'Invalid format';
        this.showToast('Error', errorMessage, 'error');
    }

    // New method to process all files
    async processAllFiles() {
        try {
            let allResults = [];
            let currentIndex = 1;

            for (const docId of this.contentDocIds) {
                const fileResults = await this.readCSVFile(docId, currentIndex);
                allResults = [...allResults, ...fileResults];
                currentIndex += fileResults.length;
            }

            this.parsedData = allResults;

            if (this.parsedData.length === 0) {
                this.showErrorToast('No Valid Records', 'The uploaded CSV files do not contain any valid CIF numbers.');
            }
        } catch (error) {
            console.error('Error processing files:', error);
            this.showErrorToast('Data Processing Error', this.parseError(error));
            this.parsedData = [];
        } finally {
            this.isLoading = false;
        }
    }

    // Modified readCSVFile method
    readCSVFile(contentDocumentId, startIndex = 1) {
        return new Promise((resolve, reject) => {
            getParticipantDetails({
                contentDocumentId: contentDocumentId,
                drawId: this.currentDrawId,
                prizeType: this.currentPrizeType
            })
                .then(result => {
                    console.log('result ---->',JSON.stringify(result));
                    try {
                        const formattedResults = result?.length > 0
                        ? result.map((item, index) => ({
                            index: startIndex + index,
                            CIF: item.CIF || '',
                            Id: item.Id || `tmp-${startIndex + index}`
                        }))
                        : [];
                        console.log('formattedResults ---->',JSON.stringify(formattedResults));
                    resolve(formattedResults);
                    } catch (error) {
                        console.log('Error ===>',JSON.stringify(error));
                    }
                    
                })
                .catch(error => {
                    console.log('error -->',JSON.stringify(error));
                    this.isLoading = false;
                    this.showErrorToast('Kindly enter valid data', 'The entered CIF is invalid as it contains letters. It should contain only numbers.');
                });
        });
    }

    handleSave() {
        if (!this.justification) {
            this.showErrorToast('Validation Error', 'Justification is required to proceed.');
            return;
        }

        if (this.parsedData.length === 0) {
            this.showErrorToast('No Data', 'No valid records to save. Please upload a CSV file with valid CIF numbers.');
            return;
        }

        this.isLoading = true;
        const recordsToSave = this.parsedData.map(record => ({
            CIF: record.CIF,
            justification: this.justification,
            drawId: this.currentDrawId,
            prizeType: this.currentPrizeType,
            category: 'EXC'
        }));

        saveBulkExclusions({
            records: recordsToSave,
            contentDocumentId: this.contentDocId
        })
            .then(() => {
                this.showSuccessToast('Success', `${this.parsedData.length} CIFs have been excluded successfully.`);
                this.closeModal();
            })
            .catch(error => {
                console.error('Error saving records:', error);
                this.showErrorToast('Save Error', this.parseError(error));
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleCancel() {
        this.closeModal();
    }

    closeModal() {
        //this.justification = '';
        this.parsedData = [];
    }

    showSuccessToast(title, message) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant: 'success',
            mode: 'dismissable'
        }));
    }

    showErrorToast(title, message) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant: 'error',
            mode: 'sticky'
        }));
    }

    parseError(error) {
        // Extract the meaningful part of the error message
        const fullMessage = error?.body?.message || error?.message || 'An unexpected error occurred.';
        return fullMessage.includes('AuraHandledException') ?
            fullMessage.split('AuraHandledException:').pop().trim() :
            fullMessage;
    }
}
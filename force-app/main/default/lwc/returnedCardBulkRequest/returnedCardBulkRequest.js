import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import validateFile from '@salesforce/apex/ReturnedCardBulkController.validateFile';
import createBatch from '@salesforce/apex/ReturnedCardBulkController.createBatch';
import uploadFile from '@salesforce/apex/ReturnedCardBulkController.uploadFile';
import templateFileBahrain from '@salesforce/resourceUrl/ReturnedCardTemplate';
import templateFileJordan from '@salesforce/resourceUrl/ReturnedCardTemplateJordan';

export default class ReturnedCardBulkRequest extends NavigationMixin(LightningElement) {
    @track isLoading = false;
    @track parsedData = [];
    @track validationErrors = [];
    @track validationWarnings = [];
    @track showValidationModal = false;
    @track showRegionModal = false;
    @track showTemplateModal = false;
    @track batchId;
    @track fileName;
    @track showProceedButton = false;
    @track showFooter = false;
    @track contentDocumentId;
    @track uploadedFile; // Track uploaded file object
    @track selectedRegion = '';
    @track selectedTemplateRegion = '';
    @track pendingFile = null; // Store file while waiting for region selection

    regionOptions = [
        { label: 'Bahrain', value: 'Bahrain' },
        { label: 'Jordan', value: 'Jordan' }
    ];

    columns = [
        { label: 'Row', fieldName: 'rowNumber', type: 'number', initialWidth: 70 },
        { label: 'AWB', fieldName: 'awb', type: 'text', initialWidth: 120 },
        { label: 'CIF', fieldName: 'cif', type: 'text', initialWidth: 100 },
        { label: 'Card Type', fieldName: 'cardType', type: 'text', initialWidth: 100 },
        { label: 'Pick-up Date', fieldName: 'pickupDate', type: 'date', initialWidth: 110 },
        { label: 'Returned Reason', fieldName: 'returnedReason', type: 'text', initialWidth: 150, wrapText: true },
        { label: 'Status', fieldName: 'status', type: 'text', initialWidth: 100 },
        { label: 'Error/Warning', fieldName: 'message', type: 'text', initialWidth: 350, wrapText: true, cellAttributes: { class: 'message-cell' } }
    ];

    // Handle file selection from lightning-input
    handleFileChange(event) {
        const files = event.target.files;
        if (files.length === 0) return;

        const file = files[0];
        this.fileName = file.name;

        // Show region selection modal
        this.pendingFile = file;
        this.showRegionModal = true;
    }

    handleRegionChange(event) {
        this.selectedRegion = event.detail.value;
    }

    closeRegionModal() {
        this.showRegionModal = false;
        this.selectedRegion = '';
        this.pendingFile = null;
        this.fileName = null;

        // Reset file input
        const fileInput = this.template.querySelector('lightning-input[name="csvFileInput"]');
        if (fileInput) {
            fileInput.value = null;
        }
    }

    handleRegionConfirm() {
        if (!this.selectedRegion) {
            this.showError('Error', 'Please select a region before uploading');
            return;
        }

        this.showRegionModal = false;
        // Process the file with selected region
        this.readFileContent(this.pendingFile);
    }

    // Read CSV file content
    readFileContent(file) {
        this.isLoading = true;

        const reader = new FileReader();

        reader.onload = (e) => {
            const fileContent = e.target.result;
            // Upload file to Salesforce with region info
            this.uploadFileToSalesforce(file.name, fileContent, this.selectedRegion);
        };

        reader.onerror = () => {
            this.showError('Error', 'Failed to read file');
            this.isLoading = false;
            this.resetFileUpload();
        };

        reader.readAsText(file);
    }

    // Upload file to Salesforce
    uploadFileToSalesforce(fileName, fileContent, region) {
        // Convert to base64
        const base64Data = this.encodeToBase64(fileContent);

        uploadFile({
            fileName: fileName,
            base64Data: base64Data,
            region: region
        })
            .then(result => {
                this.contentDocumentId = result;
                this.validateUploadedFile(region);
            })
            .catch(error => {
                console.error('File upload error:', error);
                this.showError('Error', 'Failed to upload file to Salesforce: ' + (error.body?.message || error.message));
                this.isLoading = false;
                this.resetFileUpload();
            });
    }

    // Helper to encode to base64
    encodeToBase64(str) {
        try {
            return btoa(unescape(encodeURIComponent(str)));
        } catch (error) {
            console.error('Base64 encoding error:', error);
            // Fallback encoding
            return btoa(str);
        }
    }

    validateUploadedFile(region) {
        // Clear previous data
        this.parsedData = [];
        this.validationErrors = [];
        this.validationWarnings = [];
        this.showValidationModal = false;
        this.showProceedButton = false;
        this.showFooter = false;

        validateFile({
            contentDocumentId: this.contentDocumentId,
            region: region
        })
            .then(result => {
                console.log('Validation result:', JSON.stringify(result));

                // Always populate data regardless of success flag
                this.parsedData = result.parsedData || [];
                this.validationErrors = result.errors || [];
                this.validationWarnings = result.warnings || [];

                if (result.success) {
                    // SUCCESS CASE: No blocking errors
                    if (this.validationErrors.length > 0) {
                        // Show errors but still allow proceeding if success is true
                        this.showValidationResults();
                        this.showFooter = false; // Don't show footer when there are errors
                        this.showProceedButton = false;
                    } else if (this.validationWarnings.length > 0) {
                        // Show warnings
                        this.showValidationResults();
                        this.showProceedButton = true;
                        this.showFooter = true; // Show footer even with warnings
                    } else {
                        // No errors, no warnings - show success and enable proceed
                        this.showSuccess('Validation Successful', `${result.parsedData.length} records ready for processing.`);
                        this.showProceedButton = true;
                        this.showFooter = true;
                    }
                } else {
                    // FAILURE CASE: There are blocking errors
                    if (this.validationErrors.length > 0 || this.validationWarnings.length > 0) {
                        // Show validation results in modal
                        this.showValidationResults();
                        this.showFooter = false;
                        this.showProceedButton = false;

                        // Also show toast with error message
                        this.showError('Validation Failed', result.message || 'File validation failed');
                    } else {
                        // No specific errors/warnings but still failed
                        this.showError('Validation Failed', result.message || 'File validation failed');
                        this.resetFileUpload();
                    }
                }
            })
            .catch(error => {
                console.error('Validation error:', JSON.stringify(error));
                this.showError('Error', error.body?.message || error.message || 'An error occurred during validation');
                this.resetFileUpload();
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    showValidationResults() {
        this.showValidationModal = true;
    }

    closeValidationModal() {
        this.showValidationModal = false;
        this.showProceedButton = false;
        this.showFooter = false;
        this.fileName = null;
        // Don't reset form when closing modal, just close it
    }

    handleProceed() {
        this.showValidationModal = false;
        this.createBatchOperation();
    }

    createBatchOperation() {
        this.isLoading = true;

        createBatch({
            records: this.parsedData,
            fileName: this.fileName,
            contentDocumentId: this.contentDocumentId,
            region: this.selectedRegion
        })
            .then(result => {
                console.log('Batch created:', result);
                this.batchId = result.batchId;

                this.showSuccess('Success', `Batch created with ${result.totalRecords} records`);

                if (result.batchId) {
                    this.navigateToRecord(result.batchId);
                    this.resetForm();
                    this.isLoading = false;
                }
            })
            .catch(error => {
                console.error('Batch creation error:', JSON.stringify(error));

                let errorMessage = 'Failed to create batch';
                let fullErrorMessage = '';

                // Extract the error message from various possible locations
                if (error.body) {
                    if (error.body.message) {
                        fullErrorMessage = error.body.message;
                    } else if (error.body.exceptionType === 'AuraHandledException') {
                        fullErrorMessage = error.body.message;
                    }
                } else if (error.message) {
                    fullErrorMessage = error.message;
                }

                // Check for specific error patterns and provide user-friendly messages
                if (fullErrorMessage.includes('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY')) {
                    errorMessage = 'You do not have sufficient permissions to create this batch. The operation requires access to certain records that you cannot access. Please contact your system administrator.';
                }
                else if (fullErrorMessage.includes('INSUFFICIENT_ACCESS') || fullErrorMessage.includes('access rights')) {
                    errorMessage = 'You are not allowed to create the batch due to insufficient access rights. Please check your permissions or contact your administrator.';
                }
                else if (fullErrorMessage.includes('FIELD_INTEGRITY_EXCEPTION')) {
                    if (fullErrorMessage.includes('invalid')) {
                        errorMessage = 'Invalid data found in your file. Please check that all values are correct and try again.';
                    } else {
                        errorMessage = 'Data validation failed. Please review your file for any incorrect values.';
                    }
                }
                else if (fullErrorMessage.includes('DUPLICATE_VALUE')) {
                    errorMessage = 'Duplicate records detected. Please remove duplicates from your file and try again.';
                }
                else if (fullErrorMessage.includes('REQUIRED_FIELD_MISSING')) {
                    errorMessage = 'Required information is missing. Please ensure all mandatory fields are filled in your file.';
                }
                else if (fullErrorMessage.includes('INVALID_FIELD')) {
                    errorMessage = 'Invalid field values found. Please check that all values match the expected format.';
                }
                else if (fullErrorMessage.includes('MIXED_DML_OPERATION')) {
                    errorMessage = 'Unable to process due to system limitations. Please try again in a few moments.';
                }
                else if (fullErrorMessage.includes('UNAUTHORIZED')) {
                    errorMessage = 'You are not authorized to perform this action. Please contact your administrator for access.';
                }
                else if (fullErrorMessage.includes('limit')) {
                    errorMessage = 'System limit exceeded. Please try with fewer records or contact support.';
                }
                else if (fullErrorMessage.includes('timeout')) {
                    errorMessage = 'Operation timed out. Please try again with a smaller file.';
                }
                else {
                    // If no specific pattern matched, format the original error message
                    errorMessage = this.formatErrorMessage(fullErrorMessage);
                }

                // Show the formatted error message
                this.showError('Batch Creation Failed', errorMessage);

                // Reset loading state and form
                this.isLoading = false;
                this.resetForm();
            });
    }

    resetForm() {
        this.parsedData = [];
        this.validationErrors = [];
        this.validationWarnings = [];
        this.showProceedButton = false;
        this.showFooter = false;
        this.contentDocumentId = null;
        this.fileName = null;
        this.uploadedFile = null;
        this.showValidationModal = false;
        this.selectedRegion = '';
        this.pendingFile = null;

        // Reset file input
        const fileInput = this.template.querySelector('lightning-input[name="csvFileInput"]');
        if (fileInput) {
            fileInput.value = null;
        }
    }

    resetFileUpload() {
        const fileInput = this.template.querySelector('lightning-input[name="csvFileInput"]');
        if (fileInput) {
            fileInput.value = null;
        }
        this.fileName = '';
        this.contentDocumentId = '';
        this.uploadedFile = null;
        this.showFooter = false;
        this.parsedData = [];
        this.validationErrors = [];
        this.validationWarnings = [];
        this.selectedRegion = '';
        this.pendingFile = null;
    }

    handleDownloadTemplate() {
        // Show template selection modal
        this.showTemplateModal = true;
    }

    handleTemplateRegionChange(event) {
        this.selectedTemplateRegion = event.detail.value;
    }

    closeTemplateModal() {
        this.showTemplateModal = false;
        this.selectedTemplateRegion = '';
    }

    handleTemplateDownload() {
        if (!this.selectedTemplateRegion) {
            this.showError('Error', 'Please select a region');
            return;
        }

        if (this.selectedTemplateRegion === 'Bahrain') {
            window.open(templateFileBahrain, '_blank');
        } else if (this.selectedTemplateRegion === 'Jordan') {
            window.open(templateFileJordan, '_blank');
        }

        this.showTemplateModal = false;
        this.selectedTemplateRegion = '';
    }

    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    showSuccess(title, message) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: 'success'
        }));
    }

    showError(title, message) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: 'error'
        }));
    }

    get hasValidationIssues() {
        return this.validationErrors.length > 0 || this.validationWarnings.length > 0;
    }

    get showErrorsTable() {
        return this.validationErrors.length > 0;
    }

    get showWarningsTable() {
        return this.validationWarnings.length > 0;
    }

    get totalRecords() {
        return this.parsedData.length + this.validationErrors.length + this.validationWarnings.length;
    }

    get validRecordsCount() {
        return this.parsedData.filter(record => record && !record.hasError).length;
    }

    get previewColumns() {
        return [
            { label: 'AWB', fieldName: 'AWB', type: 'text' },
            { label: 'CIF', fieldName: 'CIF', type: 'text' },
            { label: 'Card Type', fieldName: 'CardType', type: 'text' },
            {
                label: 'Pick-up Date', fieldName: 'PickupDate', type: 'date-local',
                typeAttributes: {
                    year: "numeric",
                    month: "short",
                    day: "2-digit"
                }
            },
            { label: 'Returned Reason', fieldName: 'ReturnedReason', type: 'text' }
        ];
    }
}
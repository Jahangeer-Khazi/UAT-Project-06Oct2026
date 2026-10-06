// clearCache.js (with minor optional fixes)
import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import processCSVFile from '@salesforce/apex/CacheServiceController.processCSVFile';
import clearCache from '@salesforce/apex/CacheServiceController.clearCache';
import { NavigationMixin } from 'lightning/navigation';
import getRecentCacheLogs from '@salesforce/apex/CacheServiceController.getRecentCacheLogs';

export default class CacheService extends NavigationMixin(LightningElement) {
    @track isLoading = false;
    @track isProcessing = false;
    @track selectedOption = '';
    @track selectedOptionLabel = '';
    @track cifList = [];
    @track fileName = '';
    @track isFileUploaded = false;
    @track recentLogs = [];
    @track contentDocId;

    cacheOptions = [
        {
            label: 'Clear All Cache',
            value: 'All',
            description: 'Clear all types of cache',
            icon: 'utility:clear',
            cardClass: 'cache-option-card slds-box slds-box_link slds-theme_shade'
        },
        {
            label: 'Clear Credit Card Cache',
            value: 'Credit Card',
            description: 'Clear credit card cache only',
            icon: 'utility:coupon_codes',
            cardClass: 'cache-option-card slds-box slds-box_link slds-theme_shade'
        },
        {
            label: 'Clear Debit Card Cache',
            value: 'Debit Card',
            description: 'Clear debit card cache only',
            icon: 'utility:money',
            cardClass: 'cache-option-card slds-box slds-box_link slds-theme_shade'
        }
    ];

    connectedCallback() {
        // Uncomment when you're ready to load logs
        // this.loadRecentLogs();
    }

    loadRecentLogs() {
        getRecentCacheLogs()
            .then(result => {
                this.recentLogs = result;
            })
            .catch(error => {
                console.error('Error loading logs:', error);
            });
    }

    handleOptionSelect(event) {
        // Remove selected class from all cards
        this.cacheOptions = this.cacheOptions.map(option => ({
            ...option,
            cardClass: 'cache-option-card slds-box slds-box_link slds-theme_shade'
        }));

        // Add selected class to clicked card
        const selectedValue = event.currentTarget.dataset.value;
        this.cacheOptions = this.cacheOptions.map(option => ({
            ...option,
            cardClass: option.value === selectedValue
                ? 'cache-option-card slds-box slds-box_link slds-theme_success selected'
                : 'cache-option-card slds-box slds-box_link slds-theme_shade'
        }));

        const selected = this.cacheOptions.find(opt => opt.value === selectedValue);
        this.selectedOption = selectedValue;
        this.selectedOptionLabel = selected.label;
    }

    clearSelection() {
        this.selectedOption = '';
        this.selectedOptionLabel = '';
        this.cifList = [];
        this.isFileUploaded = false;
        this.fileName = '';

        this.cacheOptions = this.cacheOptions.map(option => ({
            ...option,
            cardClass: 'cache-option-card slds-box slds-box_link slds-theme_shade'
        }));
    }

    handleFileUploaded(event) {
        const files = event.detail.files;
        if (!files || files.length === 0) return;

        this.isLoading = true;
        const file = files[0];

        this.contentDocId = file.documentId;
        processCSVFile({ contentDocumentId: file.documentId })
            .then(result => {
                if (result.success) {
                    this.cifList = result.cifList;
                    this.fileName = result.fileName;
                    this.isFileUploaded = true;

                    this.showToast('Success', `Loaded ${result.totalCount} CIF(s) from file`, 'success');
                } else {
                    this.showToast('Error', result.error, 'error');
                }
            })
            .catch(error => {
                this.showToast('Error', error.body?.message || 'Error processing file', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleClearCache() {
        if (!this.selectedOption) {
            this.showToast('Warning', 'Please select a cache type', 'warning');
            return;
        }

        if (this.cifList.length === 0) {
            this.showToast('Warning', 'Please upload a CSV file with CIFs', 'warning');
            return;
        }

        this.isProcessing = true;
        this.isLoading = true;

        clearCache({
            cacheType: this.selectedOption,
            cifList: this.cifList,
            fileName: this.fileName,
            contentDocumentId: this.contentDocId
        })
            .then(result => {
                if (result.success) {
                    this.showToast('Success', result.message, 'success');
                    this.clearFile();
                    this.clearSelection();
                    this.loadRecentLogs();

                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: result.logId,
                            actionName: 'view',
                        },
                    });
                } else {
                    this.showToast('Error', result.message, 'error');
                }
            })
            .catch(error => {
                this.showToast('Error', error.body?.message || 'Error clearing cache', 'error');
            })
            .finally(() => {
                this.isProcessing = false;
                this.isLoading = false;
            });
    }

    handleCancel() {
        this.clearFile();
    }

    clearFile() {
        this.cifList = [];
        this.isFileUploaded = false;
        this.fileName = '';

        // Reset file uploader
        const fileUploader = this.template.querySelector('lightning-file-upload');
        if (fileUploader) {
            fileUploader.value = null;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }

    // Fixed: Converted to a proper getter method for use in template
    getStatusClass(status) {
        switch (status) {
            case 'Completed': return 'slds-badge slds-theme_success';
            case 'Failed': return 'slds-badge slds-theme_error';
            case 'In Progress': return 'slds-badge slds-theme_info';
            default: return 'slds-badge';
        }
    }
}
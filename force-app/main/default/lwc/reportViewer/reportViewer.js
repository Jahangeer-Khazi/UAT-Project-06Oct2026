import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPaginatedReportData from '@salesforce/apex/DynamicCaseReportController.getPaginatedReportData';
import calculateTotalTime from '@salesforce/apex/DynamicCaseReportController.calculateTotalTime';
import startBatchExport from '@salesforce/apex/DynamicCaseReportController.startBatchExport';
import getCaseCounts from '@salesforce/apex/DynamicCaseReportController.getCaseCounts';
import { subscribe, unsubscribe } from 'lightning/empApi';
import { refreshApex } from "@salesforce/apex";

export default class DynamicCaseReport extends LightningElement {
    @api channelName = '/event/Case_Export_Progress__e';

    // Data and columns
    @track caseData = [];
    @track fixedColumns = [];
    @track dynamicColumns = [];
    @track tableHeaders = [];
    @track tableSubHeaders = [];
    @track wiredCommentData = {};

    // Export configuration
    batchSize = 75;
    @track isExporting = false;
    @track exportProgress = 0;
    @track exportStatus = '';

    // *** New properties for email export ***
    @track isEmailExporting = false;
    @track emailExportProgress = 0;
    @track emailExportStatus = '';
    subscription = {};
    @track isConnectedToEvents = false;

    // Pagination properties
    @track currentPage = 1;
    @track recordsPerPage = 75;
    @track totalRecords = 0;
    @track totalPages = 1;
    @track pageNumbers = [];
    @track isLoading = false;
    @track filters = {}; // Add your filter properties

    // Initialize all variables
    vipTotal = 0;
    vipMet = 0;
    vipInProgress = 0;
    vipBreached = 0;
    totalCases = 0;
    totalMet = 0;
    totalInProgress = 0;
    totalBreached = 0;

    @track selectedDateRange = '60';
    @track dateRangeOptions = [
        { label: 'Last 30 Days', value: '30' },
        { label: 'Last 60 Days', value: '60' },
        { label: 'Last 90 Days', value: '90' },
        { label: 'Last 6 Months', value: '180' },
        { label: 'Custom Range', value: 'custom' }
    ];

    // Add these with your other properties
    @track caseStatusFilter = 'all'; // 'all', 'open', or 'closed'
    @track caseStatusOptions = [
        { label: 'All Cases', value: 'all' },
        { label: 'Open Cases', value: 'open' },
        { label: 'Closed Cases', value: 'closed' }
    ];

    // Add these properties at the top of your class
    @track showCustomDatePicker = false;
    @track customFromDate = '';
    @track customToDate = '';
    @track isCustomDateRange = false;

    // Add this property at the top of your class
    @track hasRendered = false;

    // Add this at the top of your class with other properties
    @track initialLoadComplete = false;
    @track isLoadingCalculations = false;

    // Wire method to get paginated data
    @wire(getPaginatedReportData, {
        pageNumber: '$currentPage',
        pageSize: '$recordsPerPage',
        dateRange: '$selectedDateRange',
        statusFilter: '$caseStatusFilter',
        fromDateStr: '$computedFromDate',
        toDateStr: '$computedToDate'
    })
    wiredReportData(result) {
        this.isLoading = true;
        console.log('Status Filter:', this.caseStatusFilter); // Verify filter value
        console.log('Raw Data:', JSON.stringify(result)); // Inspect raw data
        this.wiredCommentData = result;
        const { data, error } = result;
        if (data) {
            requestAnimationFrame(() => {
                this.caseData = data.caseData;
                this.totalRecords = data.totalCount;
                this.totalPages = Math.ceil(this.totalRecords / this.recordsPerPage);
                this.updatePageNumbers();

                // Only process headers on first load
                if (this.currentPage === 1) {
                    this.fixedColumns = data.fixedColumns || [];
                    this.dynamicColumns = data.dynamicColumns || [];
                    this.prepareTableHeaders();
                }
                this.isLoading = false;
            });
        } else if (error) {
            console.error('Error loading data:', error);
            this.isLoading = false;
            this.showError('Error loading report data');
            this.caseData = [];
            this.totalRecords = 0;
            this.totalPages = 1;
        }
    }

    @wire(getCaseCounts, {
        pageNumber: '$currentPage',
        pageSize: '$recordsPerPage',
        dateRange: '$selectedDateRange',
        statusFilter: '$caseStatusFilter',
        fromDateStr: '$computedFromDate',
        toDateStr: '$computedToDate'
    })
    caseCounts({ error, data }) {
        if (data) {
            this.vipTotal = data.vipTotal || 0;
            this.vipMet = data.vipMet || 0;
            this.vipInProgress = data.vipInProgress || 0;
            this.vipBreached = data.vipBreached || 0;
            this.totalCases = data.totalCases || 0;
            this.totalMet = data.totalMet || 0;
            this.totalInProgress = data.totalInProgress || 0;
            this.totalBreached = data.totalBreached || 0;
        } else if (error) {
            console.error('Error loading case counts:', error);
        }
    }

    get filteredCases() {
        if (!this.caseData || !this.caseData.length) return [];

        return this.caseData.filter(caseItem => {
            if (this.caseStatusFilter === 'open') return caseItem.Status !== 'Closed';
            if (this.caseStatusFilter === 'closed') return caseItem.Status === 'Closed';
            return true; // Show all cases when filter is 'all'
        });
    }

    // *** New method to initialize platform event subscription ***
    connectedCallback() {
        console.log('Date Range Options:', JSON.stringify(this.dateRangeOptions));
        this.subscribeToProgressEvents();
    }

    // *** New method to clean up subscription ***
    disconnectedCallback() {
        if (this.subscription) {
            unsubscribe(this.subscription, (response) => {
                console.log('Unsubscribed successfully:', response);
                this.subscription = null;
            });
        }
    }

    // Add this new method to handle initial calculations
    renderedCallback() {
        console.log('Component rendered, showCustomDatePicker:', this.showCustomDatePicker);
        if (!this.initialLoadComplete && this.caseData && this.caseData.length > 0) {
            this.initialLoadComplete = true;
            this.triggerCalculations();
        }
    }

    refreshMyData() {
        console.log('Success --->');
        refreshApex(this.wiredCommentData);
    }

    handleDateRangeChange(event) {
        const selectedValue = event.detail.value;
        console.log('Selected Date Range:', selectedValue);
        if (selectedValue === 'custom') {
            const today = new Date();
            this.customToDate = today.toISOString().split('T')[0];
            const thirtyDaysAgo = new Date();
            thirtyDaysAgo.setDate(today.getDate() - 30);
            this.customFromDate = thirtyDaysAgo.toISOString().split('T')[0];
            this.showCustomDatePicker = true;
            console.log('showCustomDatePicker set to:', this.showCustomDatePicker);
        } else {
            this.isCustomDateRange = false;
            this.selectedDateRange = selectedValue;
            this.currentPage = 1; // Reset to first page when filter changes
            this.isLoading = true;
        }
    }

    handleFromDateChange(event) {
        this.customFromDate = event.detail.value;
    }

    handleToDateChange(event) {
        this.customToDate = event.detail.value;
    }

    closeCustomDatePicker() {
        console.log('Closing custom date picker');
        this.showCustomDatePicker = false;
        this.selectedDateRange = '90'; // Reset to default if canceled
    }

    applyCustomDateRange() {
        if (!this.customFromDate || !this.customToDate) {
            this.showError('Please select both From and To dates');
            return;
        }

        const fromDate = new Date(this.customFromDate);
        const toDate = new Date(this.customToDate);

        if (fromDate > toDate) {
            this.showError('From date cannot be after To date');
            return;
        }

        this.isCustomDateRange = true;
        this.selectedDateRange = 'custom'; // This will be handled specially in the Apex controller
        this.showCustomDatePicker = false;
        this.currentPage = 1; // Reset to first page when filter changes
        this.isLoading = true;
    }

    // *** New method to subscribe to platform events ***
    subscribeToProgressEvents() {
        // Unsubscribe first if already subscribed
        if (this.subscription) {
            this.unsubscribeFromProgressEvents();
        }

        // Changed to arrow function for proper 'this' binding
        const callbackFunction = (response) => {
            const result = response.data.payload;
            console.log('Received progress event:', result);

            // Update progress UI for all events
            this.emailExportStatus = result.Status__c;
            this.emailExportProgress = result.Progress__c;

            // Highlight Change 1: Specific handling for CALCULATION type
            if (result.Operation_Type__c === 'CALCULATION' && result.Progress__c === 100) {
                this.refreshMyData();
                this.showSuccess('Calculation completed successfully!');
                setTimeout(() => {
                    this.isEmailExporting = false;
                    this.emailExportProgress = 0;
                    this.emailExportStatus = '';
                }, 2000);
            }
            // Highlight Change 2: Separate handling for other operations
            else if (result.Progress__c === 100) {
                this.showSuccess('Operation completed successfully!');
                setTimeout(() => {
                    this.isEmailExporting = false;
                    this.emailExportProgress = 0;
                    this.emailExportStatus = '';
                }, 2000);
            }
            // Error handling remains the same
            else if (result.ErrorMessage__c) {
                this.showError(result.ErrorMessage__c);
                this.isEmailExporting = false;
                this.emailExportProgress = 0;
            }
        };

        subscribe(this.channelName, -1, callbackFunction)
            .then(response => {
                console.log('Subscription successful:', response);
                this.subscription = response;
                this.showToast('Success', 'Connected to progress updates', 'success');
                this.isConnectedToEvents = true;
            })
            .catch(error => {
                console.error('Subscription error:', error);
                this.isEmailExporting = false;
                this.isConnectedToEvents = false;
            });
    }

    unsubscribeFromProgressEvents() {
        unsubscribe(this.subscription, (response) => {
            console.log('Unsubscribed successfully:', response);
            this.subscription = null;
        });
    }

    get computedFromDate() {
        // Only return fromDate if we're using custom date range
        return this.selectedDateRange === 'custom' ? this.customFromDate : null;
    }

    get computedToDate() {
        // Only return toDate if we're using custom date range
        return this.selectedDateRange === 'custom' ? this.customToDate : null;
    }

    handleStatusFilterChange(event) {
        this.caseStatusFilter = event.detail.value;
        this.currentPage = 1; // Reset to first page when filter changes
        this.isLoading = true;
    }

    handlePlatformEvent(event) {
        try {
            const data = event.data.payload;
            // All UI updates must be synchronous
            this.emailExportStatus = data.Status__c;
            this.emailExportProgress = data.Progress__c;

            if (data.ErrorMessage__c) {
                this.showError(data.ErrorMessage__c);
                this.isEmailExporting = false;
                this.emailExportProgress = 0;
            } else if (data.Progress__c === 100) {
                this.showSuccess('Email sent successfully!');
                // Defer the state reset
                setTimeout(() => {
                    this.isEmailExporting = false;
                    this.emailExportProgress = 0;
                    this.emailExportStatus = '';
                }, 2000);
            }
        } catch (error) {
            console.error('Error handling platform event:', error);
        }
    }

    // Add computed properties
    get connectionStatus() {
        return this.isConnectedToEvents ? 'Connected to updates' : 'Not connected to updates';
    }

    get connectionStatusVariant() {
        return this.isConnectedToEvents ? 'success' : 'warning';
    }

    // *** Modified handleEmailClick to start batch job ***
    async handleEmailClick() {
        try {
            // Reset state
            this.isEmailExporting = true;
            this.emailExportStatus = 'Initializing export...';
            this.emailExportProgress = 5;

            // Start the batch job
            const result = await startBatchExport({ dateRange: this.selectedDateRange });
            console.log('Batch job started with ID:', result);

            // Update status to show we're waiting for progress
            this.emailExportStatus = 'Preparing data...';
            this.emailExportProgress = 10;

        } catch (error) {
            console.error('Error starting batch:', error);
            this.showError('Failed to start export: ' + error.body.message);
            this.isEmailExporting = false;
            this.emailExportProgress = 0;
        }
    }

    get visiblePages() {
        const maxVisible = 5; // Show maximum 5 page buttons
        const halfVisible = Math.floor(maxVisible / 2);
        let startPage = Math.max(1, this.currentPage - halfVisible);
        let endPage = Math.min(this.totalPages, startPage + maxVisible - 1);

        // Adjust if we're at the beginning or end
        if (endPage - startPage + 1 < maxVisible) {
            startPage = Math.max(1, endPage - maxVisible + 1);
        }

        return Array.from({ length: endPage - startPage + 1 }, (_, i) => ({
            number: startPage + i,
            variant: (startPage + i) === this.currentPage ? 'brand' : 'neutral'
        }));
    }


    get showFirstPage() {
        return this.visiblePages[0] > 1;
    }

    get showLastPage() {
        return this.visiblePages[this.visiblePages.length - 1] < this.totalPages;
    }

    // Update page numbers array for pagination controls
    updatePageNumbers() {
        this.pageNumbers = [];
        for (let i = 1; i <= this.totalPages; i++) {
            this.pageNumbers.push(i);
        }
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage--;
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
        }
    }

    handlePageChange(event) {
        const pageNumber = parseInt(event.currentTarget.dataset.page, 10);
        this.currentPage = pageNumber;
    }

    // Add filter handlers if needed
    handleFilterChange(event) {
        this.filters = { ...this.filters, ...event.detail };
        this.currentPage = 1; // Reset to first page when filters change
    }

    get isPreviousDisabled() {
        return this.currentPage === 1 || this.isExporting;
    }

    get isNextDisabled() {
        return this.currentPage === this.totalPages || this.isExporting;
    }

    // Returns true if a button should be highlighted as active (brand)
    getPageVariant(pageNumber) {
        return this.currentPage === pageNumber ? 'brand' : 'neutral';
    }

    get computedPageNumbers() {
        return this.pageNumbers.map(pageNumber => ({
            number: pageNumber,
            variant: pageNumber === this.currentPage ? 'brand' : 'neutral'
        }));
    }

    prepareTableHeaders() {
        // Prepare main headers
        this.tableHeaders = [
            ...this.fixedColumns.map(col => ({
                label: col.label,
                colspan: 1,
                rowspan: 1,
                isFixed: true
            })),
            ...this.dynamicColumns.map(team => ({
                label: team.label,
                colspan: 1,
                rowspan: 1,
                isFixed: false
            }))
        ];

        // Prepare subheaders
        this.tableSubHeaders = [];
    }

    get tableRows() {
        if (!this.caseData || !Array.isArray(this.caseData)) {
            return [];
        }

        return this.caseData.map(row => {
            const cells = [];

            // Fixed columns
            this.fixedColumns.forEach(col => {
                if (!col || !col.label) return;

                const value = row[col.label] !== null && row[col.label] !== undefined ? row[col.label] : '';
                let cellClass = '';

                if (col.label === 'SLA Status') {
                    if (value === 'Breached') {
                        cellClass = 'breached-cell';
                    } else if (value === 'In Progress') {
                        cellClass = 'warning-cell';
                    } else {
                        cellClass = 'met-cell';
                    }
                }

                cells.push({
                    value: value,
                    isFixed: true,
                    cellClass: cellClass
                });
            });

            // Dynamic columns
            this.dynamicColumns.forEach(team => {
                if (!team || !team.label) return;

                cells.push({
                    value: row[team.label] !== null && row[team.label] !== undefined ? row[team.label] : '0',
                    cellClass: ''
                });
            });

            return {
                id: row.Id || 'no-id-' + Math.random().toString(36).substring(2, 9),
                cells: cells
            };
        });
    }

    // *** New method for success toast ***
    showSuccess(message) {
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);
    }

    showError(message) {
        const toastEvent = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(toastEvent);
    }

    triggerCalculations() {
        if (this.caseData && this.caseData.length > 0 && !this.isLoadingCalculations) {
            this.isLoadingCalculations = true;

            calculateTotalTime({ caseIds: null })
                .then(() => {
                    this.showSuccess('Calculations completed');
                })
                .catch(error => {
                    this.showError('Calculation Error');
                    this.hasRendered = false;
                })
                .finally(() => {
                    this.isLoadingCalculations = false;
                });
        }
    }
}
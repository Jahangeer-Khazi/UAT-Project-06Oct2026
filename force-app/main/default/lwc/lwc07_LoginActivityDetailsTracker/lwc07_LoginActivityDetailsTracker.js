import { LightningElement, api, track } from 'lwc';
import getRecentActivityDetails from '@salesforce/apex/LoginActivityDetailsService.getRecentActivityDetails';
import getLatestActivityDetails from '@salesforce/apex/LoginActivityDetailsService.getLatestActivityDetails';
import requestLoginHistoryReport from '@salesforce/apex/LoginActivityService.requestLoginHistoryReport';
import getLoginHistoryReportStatus from '@salesforce/apex/LoginActivityService.getLoginHistoryReportStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Timestamp', fieldName: 'timestamp', type: 'date', typeAttributes: { year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' } },
    { label: 'Result', fieldName: 'result', type: 'text' },
    { label: 'Device ID', fieldName: 'channel', type: 'text' },
    { label: 'IP Address', fieldName: 'category', type: 'text' },
    { label: 'Location', fieldName: 'unit', type: 'text' },
    { label: 'Description', fieldName: 'description', type: 'text' },
    { label: 'Error', fieldName: 'errorCode', type: 'text' }
];

export default class Lwc07_LoginActivityDetailsTracker extends LightningElement {
    @api recordId;
    @api pageSize = 50;
    @api maxRangeMonths = 3;

    @track recentActivity = [];
    @track historyData = [];
    @track fullHistory = [];
    @track error;
    @track isLoading = true;
    @track isExpanded = false;

    // Report Generation
    @track isReportModalOpen = false;
    @track isGeneratingReport = false;
    @track isPollingReport = false;
    @track isReportReady = false;
    @track reportProgress = 0;
    @track pollAttempt = 0;
    @track currentTaskStatus = '';
    reportTaskId;
    reportDownloadUrl = '';
    reportExpiresAt;
    reportFromDate;
    reportToDate;
    reportDateError = '';
    pollTimeout;

    // Expanded View Filters
    filterFromDate;
    filterToDate;
    filterStatus = '';
    filterDateError = '';
    unfilteredHistory = [];
    fetchedFromDate;
    fetchedToDate;

    MAX_RANGE_DAYS = 90;
    MAX_STATUS_POLLS = 10;
    POLL_INTERVAL_MS = 5000;

    // Pagination
    currentPage = 1;
    totalPages = 1;

    columns = COLUMNS;

    get statusOptions() {
        return [
            { label: 'All', value: '' },
            { label: 'Success', value: 'Success' },
            { label: 'Failed', value: 'Failed' }
        ];
    }

    get hasData() {
        return this.recentActivity && this.recentActivity.length > 0;
    }

    get disableGenerate() {
        return !this.reportFromDate || !this.reportToDate || this.isGeneratingReport || this.isPollingReport;
    }

    get pollStatusLabel() {
        const status = this.currentTaskStatus ? ' (' + this.currentTaskStatus + ')' : '';
        return 'Checking report status ' + this.pollAttempt + '/' + this.MAX_STATUS_POLLS + status;
    }

    get hasReportDownload() {
        return Boolean(this.reportDownloadUrl);
    }

    get reportModalCloseLabel() {
        return this.isReportReady ? 'Close' : 'Cancel';
    }

    get isFirstPage() { return this.currentPage === 1; }
    get isLastPage() { return this.currentPage >= this.totalPages; }

    get pageList() {
        const total = this.totalPages;
        const current = this.currentPage;
        const delta = 2;
        const range = [];
        const rangeWithDots = [];

        for (let i = 1; i <= total; i++) {
            if (i === 1 || i === total || (i >= current - delta && i <= current + delta)) {
                range.push(i);
            }
        }

        let l;
        for (let i of range) {
            if (l) {
                if (i - l === 2) {
                    rangeWithDots.push({ label: l + 1, value: l + 1, isDots: false, variant: 'neutral' });
                } else if (i - l !== 1) {
                    rangeWithDots.push({ label: '...', value: 'dots', isDots: true, variant: 'base' });
                }
            }
            rangeWithDots.push({
                label: i,
                value: i,
                isDots: false,
                variant: i === current ? 'brand' : 'neutral'
            });
            l = i;
        }
        return rangeWithDots;
    }

    connectedCallback() {
        this.loadRecent();
        const end = new Date();
        const start = new Date();
        start.setDate(end.getDate() - 30);
        this.filterToDate = end.toISOString().split('T')[0];
        this.filterFromDate = start.toISOString().split('T')[0];
        this.reportToDate = end.toISOString().split('T')[0];
        this.reportFromDate = start.toISOString().split('T')[0];
    }

    disconnectedCallback() {
        this.stopPolling();
    }

    daysAgoFromToday(dateStr) {
        const target = new Date(dateStr);
        const today = new Date();
        target.setHours(0, 0, 0, 0);
        today.setHours(0, 0, 0, 0);
        return Math.round((today.getTime() - target.getTime()) / (1000 * 60 * 60 * 24));
    }

    mapDetailRows(items) {
        return (items || []).map((item, index) => ({
            ...item,
            id: item.id || (item.timestamp + '-' + index),
            badgeClass: item.result === 'Success' ? 'slds-theme_success' : 'slds-theme_error'
        }));
    }

    async fetchChunks(startDaysAgo, totalDays) {
        const rows = [];
        const chunkSize = 8;
        for (let offset = 0; offset < totalDays; offset += chunkSize) {
            const chunk = await getRecentActivityDetails({
                customerId: this.recordId,
                startDaysAgo: startDaysAgo + offset,
                daysToScan: Math.min(chunkSize, totalDays - offset)
            });
            rows.push(...(chunk || []));
        }
        return rows;
    }

    async loadRecent() {
        this.isLoading = true;
        try {
            const items = await getLatestActivityDetails({ customerId: this.recordId });
            this.recentActivity = this.mapDetailRows(items);
            this.error = undefined;
        } catch (error) {
            this.error = this.reduceErrors(error);
            this.recentActivity = [];
        } finally {
            this.isLoading = false;
        }
    }

    async loadHistory() {
        this.isLoading = true;
        try {
            const startAgo = Math.max(0, this.daysAgoFromToday(this.filterToDate));
            const fromAgo = Math.max(startAgo, this.daysAgoFromToday(this.filterFromDate));
            const totalDays = Math.max(1, fromAgo - startAgo + 1);
            const items = await this.fetchChunks(startAgo, totalDays);
            this.unfilteredHistory = this.mapDetailRows(items);
            this.fetchedFromDate = this.filterFromDate;
            this.fetchedToDate = this.filterToDate;
            this.applyClientFilters();
            this.error = undefined;
        } catch (error) {
            this.error = this.reduceErrors(error);
            this.historyData = [];
            this.fullHistory = [];
            this.unfilteredHistory = [];
        } finally {
            this.isLoading = false;
        }
    }

    applyClientFilters() {
        let items = this.unfilteredHistory || [];
        if (this.filterStatus) {
            items = items.filter(item => item.result === this.filterStatus);
        }
        this.fullHistory = items;
        this.totalPages = Math.max(1, Math.ceil(this.fullHistory.length / this.pageSize));
        this.currentPage = 1;
        this.applyHistoryPage();
    }

    applyHistoryPage() {
        const start = (this.currentPage - 1) * this.pageSize;
        this.historyData = this.fullHistory.slice(start, start + this.pageSize);
    }

    handleViewAll() {
        this.isExpanded = true;
        this.loadHistory();
    }

    handleCollapse() {
        this.isExpanded = false;
    }

    handleFilterChange(event) {
        const field = event.target.name;
        if (field === 'fromDate') {
            this.filterFromDate = event.detail.value;
            this.filterDateError = '';
        }
        if (field === 'toDate') {
            this.filterToDate = event.detail.value;
            this.filterDateError = '';
        }
        if (field === 'status') {
            this.filterStatus = event.detail.value;
            this.applyClientFilters();
        }
    }

    applyFilters() {
        const rangeError = this.getDateRangeError(this.filterFromDate, this.filterToDate);
        if (rangeError) {
            this.filterDateError = rangeError;
            this.showToast('Error', rangeError, 'error');
            return;
        }
        this.filterDateError = '';
        const datesUnchanged =
            this.fetchedFromDate != null &&
            this.filterFromDate === this.fetchedFromDate &&
            this.filterToDate === this.fetchedToDate;
        if (datesUnchanged) {
            this.applyClientFilters();
            return;
        }
        this.loadHistory();
    }

    getDateRangeError(fromDate, toDate) {
        if (!fromDate || !toDate) {
            return 'Please select both start and end dates.';
        }
        const start = new Date(fromDate);
        const end = new Date(toDate);
        if (start > end) {
            return 'Start date must be before end date.';
        }
        const diffDays = Math.ceil(Math.abs(end - start) / (1000 * 60 * 60 * 24));
        if (diffDays > this.MAX_RANGE_DAYS) {
            return 'The date range cannot exceed 90 days (3 months).';
        }
        return '';
    }

    // --- Report Generation ---

    openReportModal() {
        this.reportDateError = '';
        this.isReportReady = false;
        this.isReportModalOpen = true;
    }

    closeReportModal() {
        if (this.isPollingReport) {
            this.stopPolling();
        }
        this.isReportModalOpen = false;
        this.reportDateError = '';
        this.isGeneratingReport = false;
        this.isReportReady = false;
    }

    handleReportFilterChange(event) {
        const field = event.target.name;
        if (field === 'reportFromDate') this.reportFromDate = event.detail.value;
        if (field === 'reportToDate') this.reportToDate = event.detail.value;
        this.reportDateError = '';
    }

    handleGenerateAndDownload() {
        const rangeError = this.getDateRangeError(this.reportFromDate, this.reportToDate);
        if (rangeError) {
            this.reportDateError = rangeError;
            this.showToast('Error', rangeError, 'error');
            return;
        }

        this.reportDateError = '';
        this.isGeneratingReport = true;
        this.isPollingReport = true;
        this.pollAttempt = 0;
        this.reportProgress = 0;
        this.currentTaskStatus = 'SUBMITTING';
        this.isReportReady = false;
        this.reportDownloadUrl = '';
        this.reportExpiresAt = null;
        requestLoginHistoryReport({
            customerId: this.recordId,
            fromDate: this.reportFromDate,
            toDate: this.reportToDate
        })
            .then(taskId => {
                this.isGeneratingReport = false;
                this.startStatusPolling(taskId);
            })
            .catch(error => {
                this.stopPolling();
                this.showToast('Error', 'Failed to generate report: ' + this.reduceErrors(error), 'error');
            });
    }

    startStatusPolling(taskId) {
        this.reportTaskId = taskId;
        this.isPollingReport = true;
        this.pollAttempt = 0;
        this.reportProgress = 0;
        this.currentTaskStatus = 'PENDING';
        this.pollStatus();
    }

    async pollStatus() {
        if (!this.isPollingReport) {
            return;
        }
        try {
            await this.wait(this.POLL_INTERVAL_MS);
            if (!this.isPollingReport) {
                return;
            }
            this.pollAttempt += 1;
            const result = await getLoginHistoryReportStatus({
                customerId: this.recordId,
                taskId: this.reportTaskId
            });
            const status = result && result.status ? result.status : '';
            this.currentTaskStatus = status;
            this.reportProgress = Math.round((this.pollAttempt / this.MAX_STATUS_POLLS) * 100);

            if (this.isCompletedStatus(status)) {
                this.finishPolling(true, result);
                return;
            }
            if (this.isFailedStatus(status)) {
                this.finishPolling(false, result);
                return;
            }
            if (this.pollAttempt >= this.MAX_STATUS_POLLS) {
                this.showToast(
                    'Info',
                    'The report is still ' + (status || 'PENDING') + ' after 10 checks. Please try again later.',
                    'info'
                );
                this.stopPolling();
                return;
            }
            this.pollStatus();
        } catch (error) {
            this.showToast('Error', 'Failed to check report status: ' + this.reduceErrors(error), 'error');
            this.stopPolling();
        }
    }

    finishPolling(succeeded, result) {
        const taskId = (result && result.taskId) || this.reportTaskId;
        const status = result && result.status ? result.status : '';
        if (succeeded) {
            this.reportProgress = 100;
            this.reportDownloadUrl = result && result.downloadUrl ? result.downloadUrl : '';
            this.reportExpiresAt = this.toDateTimeValue(result && result.expiresAt);
            this.isReportReady = true;
            this.isPollingReport = false;
            this.isGeneratingReport = false;
            if (this.pollTimeout) {
                clearTimeout(this.pollTimeout);
                this.pollTimeout = null;
            }
            if (this.reportDownloadUrl) {
                this.showToast('Success', 'Your Excel report is ready. Click Download Excel Report to save it.', 'success');
            } else {
                this.showToast(
                    'Success',
                    'The login history report is completed, but no download link was returned. Task ' + taskId + '.',
                    'success'
                );
            }
            return;
        }
        this.showToast(
            'Error',
            'The login history report failed. Task ' + taskId + (status ? ' is ' + status : '') + '.',
            'error'
        );
        this.stopPolling();
    }

    openReportDownload() {
        if (!this.reportDownloadUrl) {
            this.showToast('Error', 'The download link is not available yet.', 'error');
            return;
        }
        window.open(this.reportDownloadUrl, '_blank');
    }

    toDateTimeValue(value) {
        if (!value) {
            return null;
        }
        const text = String(value);
        if (text.endsWith('Z') || text.includes('+') || text.includes('GMT')) {
            return text;
        }
        return text + 'Z';
    }

    stopPolling() {
        this.isPollingReport = false;
        this.isGeneratingReport = false;
        if (this.pollTimeout) {
            clearTimeout(this.pollTimeout);
            this.pollTimeout = null;
        }
    }

    wait(ms) {
        return new Promise(resolve => {
            this.pollTimeout = setTimeout(resolve, ms);
        });
    }

    isCompletedStatus(status) {
        const value = (status || '').toUpperCase();
        return value === 'COMPLETED' || value === 'COMPLETE' || value === 'SUCCESS' || value === 'DONE';
    }

    isFailedStatus(status) {
        const value = (status || '').toUpperCase();
        return value === 'FAILED' || value === 'FAILURE' || value === 'ERROR' || value === 'CANCELLED';
    }

    // --- Pagination Actions ---

    handlePrevPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.applyHistoryPage();
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.applyHistoryPage();
        }
    }

    handlePageClick(event) {
        const page = event.target.dataset.value;
        if (page && page !== 'dots' && parseInt(page, 10) !== this.currentPage) {
            this.currentPage = parseInt(page, 10);
            this.applyHistoryPage();
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    reduceErrors(errors) {
        if (!errors) return 'Unknown error';
        if (Array.isArray(errors)) return errors[0].message || errors[0];
        if (typeof errors === 'object') return errors.body?.message || errors.message || 'Unknown error';
        return errors;
    }
}
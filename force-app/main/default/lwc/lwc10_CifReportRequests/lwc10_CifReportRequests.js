import { LightningElement, api, wire, track } from 'lwc';
import getReportRequests from '@salesforce/apex/CBJCifReportService.getReportRequests';
import getAccountDetails from '@salesforce/apex/CBJCifReportService.getAccountDetails';
import getCustomerInfo from '@salesforce/apex/CBJCifReportService.getCustomerInfo';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Lwc10_CifReportRequests extends NavigationMixin(LightningElement) {
    @api recordId;
    @track activeReports = [];
    @track expiredReports = [];
    @track isLoading = true;
    @track error;
    @track cif;
    @track email;
    @track region;
    @track jodAccountNumber = 'N/A';

    @track isModalOpen = false;
    @track pdfUrl = '';

    @wire(getCustomerInfo, { recordId: '$recordId' })
    wiredCustomerInfo({ error, data }) {
        if (data) {
            this.cif = data.cif;
            this.customerName = data.name;
            this.sapId = data.customerId;
            this.email = data.email;
            this.region = data.region;
            console.log('cif >> ', this.cif);
            this.fetchData();
        } else if (error) {
            this.error = error;
            console.error('Error fetching customer info:', error);
            this.isLoading = false;
        }
    }

    async fetchData() {
        // For testing/mocking, we allow calling even without a CIF.
        const cifToUse = this.cif || '';
        console.log('Fetching data for CIF:', cifToUse + ' ' + this.email+ ' ' + this.region);

        try {
            const reportsPromise = getReportRequests({ cif: cifToUse, email: this.email, region: this.region });
            const accountPromise = getAccountDetails({ cif: cifToUse , region: this.region });

            const results = await Promise.allSettled([reportsPromise, accountPromise]);
            console.log('Reports Result:', results[0]);
            console.log('Account Details Result:', results[1]);

            if (results[0].status === 'fulfilled' && results[0].value) {
                if (results[0].value.data) {
                    this.processReports(results[0].value.data);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Credit reports fetched successfully.',
                            variant: 'success'
                        })
                    );
                } else if (results[0].value.meta) {
                    console.warn('API returned meta but no data:', results[0].value.meta);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'API Status',
                            message: results[0].value.meta.message || 'No reports found.',
                            variant: 'info'
                        })
                    );
                }
            } else if (results[0].status === 'rejected') {
                console.error('Error fetching reports:', results[0].reason);
                this.error = results[0].reason;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to fetch credit reports.',
                        variant: 'error'
                    })
                );
            }

            if (results[1].status === 'fulfilled' && results[1].value && results[1].value.data && results[1].value.data.account) {
                const acc = results[1].value.data.account;
                if (acc.currency_z && acc.currency_z.code === 'JOD') {
                    this.jodAccountNumber = acc.number_z;
                }
            }
        } catch (err) {
            this.error = err;
            console.error('Unexpected error fetching data:', err);
        } finally {
            this.isLoading = false;
        }
    }

    processReports(data) {
        const active = [];
        const expired = [];

        data.forEach(report => {
            const processed = {
                ...report,
                formattedGenerateDate: this.formatDate(report.generateDate, true),
                formattedExpiryDate: this.formatDate(report.expiryDate, false),
                statusLabel: this.getStatusLabel(report.status.name),
                statusClass: this.getStatusClass(report.status.name),
                sortDate: this.parseDate(report.generateDate)
            };

            if (report.status.name && report.status.name.toLowerCase() === 'expired') {
                expired.push(processed);
            } else {
                active.push(processed);
            }
        });

        // Sort newest to oldest
        this.activeReports = [...active].sort((a, b) => b.sortDate - a.sortDate);
        this.expiredReports = [...expired].sort((a, b) => b.sortDate - a.sortDate);
    }

    getStatusLabel(status) {
        const s = status.toUpperCase();
        if (s === 'COMPLETED') return 'Active';
        if (s === 'PENDING') return 'Pending';
        if (s === 'FAILED') return 'Failed';
        return status;
    }

    getStatusClass(status) {
        const s = status.toUpperCase();
        if (s === 'COMPLETED') return 'status-active';
        if (s === 'PENDING') return 'status-pending';
        if (s === 'FAILED') return 'status-failed';
        return '';
    }

    formatDate(dateStr, includeTime) {
        const date = this.parseDate(dateStr);
        if (date && !isNaN(date.getTime())) {
            const options = { day: '2-digit', month: 'short', year: 'numeric' };
            let formatted = date.toLocaleDateString('en-GB', options).replace(/ /g, ' ');
            if (includeTime) {
                formatted += ', 00:00';
            }
            return formatted;
        }
        return dateStr || '';
    }

    parseDate(dateStr) {
        if (!dateStr) return null;
        const parts = dateStr.split('-');
        if (parts.length === 3) {
            //DD-MM-YYYY
            return new Date(parts[2], parts[1] - 1, parts[0]);
        }
        const d = new Date(dateStr);
        return isNaN(d.getTime()) ? null : d;
    }

    get activeCount() { return this.activeReports.length; }
    get expiredCount() { return this.expiredReports.length; }
    get hasActiveReports() { return this.activeReports.length > 0; }
    get hasExpiredReports() { return this.expiredReports.length > 0; }

    get activeTabLabel() {
        return `Active (${this.activeCount})`;
    }

    get expiredTabLabel() {
        return `Expired (${this.expiredCount})`;
    }

    handleExport() {
        this.pdfUrl = '/apex/CRIFReportPDF?id=' + this.recordId;
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
        this.pdfUrl = '';
    }
}
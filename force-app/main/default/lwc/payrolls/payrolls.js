import { LightningElement, track, wire, api } from 'lwc';
import getPayrolls from '@salesforce/apex/PayrollController.getPayrolls';
import getPayrollDetailandSalaries from '@salesforce/apex/PayrollController.getPayrollDetailandSalaries';
import downloadPayrollDocument from '@salesforce/apex/PayrollController.downloadPayrollDocument';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from "lightning/uiRecordApi";
import calculateFees from '@salesforce/apex/WPSPayrollHandler.calculateFees';

import CIF_FIELD from '@salesforce/schema/Account.Customer_CIF__c';
import REGION_FLAG_FIELD from '@salesforce/schema/Account.Region_Flag__c';

export default class PayrollList extends NavigationMixin(LightningElement) {
    @track records = [];
    @track filteredRecords = [];
    @track selectedRecord = null;
    @track isLoading = true;
    @track detailLoading = false;
    @track isSpinnerLoading = false;
    @track selectedRef = '';
    @track fileOutputType = 'file';
    @api isAlburaqProduct;
    @track selectedSalaryMonth = '';

    // Pagination properties
    currentPage = 1;
    recordsPerPage = 5;

    // Filter property
    @track selectedFilter = 'all'; // 'all', 'available', 'historical'

    @track customerId = '';
    @track regionName = '';
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: [CIF_FIELD, REGION_FLAG_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            console.log('Customer Data --->', data);
            this.customerId = data.fields?.Customer_CIF__c?.value || '';
            this.regionName = data.fields?.Region_Flag__c?.value || '';
        } else if (error) {
            console.error('Error --->', error);
            this.customerId = '';
            this.regionName = '';
        }
    }


    @wire(getPayrolls, { customerId: '$customerId', regionName: '$regionName', isAlburaqProd: '$isAlburaqProduct' })
    wiredPayrolls({ error, data }) {
        this.isLoading = false;
        this.isSpinnerLoading = true;
        if (data) {
            console.log('payroll data --->', JSON.stringify(data));
            if (data.length > 0) {
                this.records = data.map((record, index) => {
                    const recordData = {
                        id: index + 1,
                        selected: false,
                        debitAccount: record.debitAccount || '',
                        reference: record.reference || '',
                        salaryMonth: record.salaryMonth || '',
                        salaryMonthBeforeFormatting: record.salaryMonthBeforeFormatting || '',
                        paymentDate: record.paymentDate || '',
                        currency: record.currencyValue || 'BHD',
                        amount: this.formatAmount(record.payrollAmount) || '0.000',
                        status: record.status || '',
                        statusClass: this.getStatusClass(record.status),
                        employerName: record.employerName || '',
                        employeeCount: record.numberOfSalaries || '0',
                        originalReference: record.payrollId || '',
                        vat: record.vat,
                        transactionFees: record.transactionFees,
                        resultDescription: record.resultDescription,
                        resultCode: record.resultCode,
                        totalDebitAmount: record.totalDebitAmount,
                        rowClass: '',
                        numberOfSalaries: record.numberOfSalaries,
                        payrollRef: record.payrollRef,
                        creationDate: record.creationDate
                    };

                    return recordData;
                }).sort((a, b) => {
                    // Create a sortable key: date + sequence
                    const createSortKey = (record) => {
                        // Try to get date from paymentDate or reference
                        let dateStr = '';

                        // First priority: paymentDate
                        if (record.paymentDate) {
                            dateStr = record.paymentDate.replace(/-/g, '');
                        }
                        // Second priority: extract from reference
                        else if (record.reference) {
                            const dateMatch = record.reference.match(/(\d{8})/);
                            if (dateMatch) {
                                dateStr = dateMatch[1];
                            }
                        }

                        // Extract sequence from reference
                        let seqStr = '000';
                        if (record.reference) {
                            const seqMatch = record.reference.match(/(\d{3,})$/);
                            if (seqMatch) {
                                // Pad to 4 digits for proper sorting
                                seqStr = String(parseInt(seqMatch[1], 10)).padStart(4, '0');
                            }
                        }

                        // Combine for sorting: YYYYMMDD + SEQ (padded)
                        // For DESC order, we'll reverse in comparison
                        return dateStr + seqStr;
                    };

                    const keyA = createSortKey(a);
                    const keyB = createSortKey(b);

                    console.log('Sort keys:', { keyA, keyB, refA: a.reference, refB: b.reference });

                    // For descending order: compare b to a
                    return keyB.localeCompare(keyA);
                });

                // Apply initial filter (all records)
                this.applyFilter();
            } else {
                this.records = [];
                this.filteredRecords = [];
            }
            this.isSpinnerLoading = false;
        } else if (error) {
            console.error('Error loading payrolls:', error);
            this.records = [];
            this.filteredRecords = [];
            this.showToast('Error', 'Failed to load payroll data', 'error');
            this.isSpinnerLoading = false;
        }
    }

    // Helper method to determine if a payroll is "Available"
    isAvailablePayroll(status) {
        if (!status) return false;

        const statusLower = status.toLowerCase();
        // Available payrolls are those with "Pending" or "Approved" status
        return statusLower.includes('pending') || statusLower.includes('approved');
    }

    // Apply filter based on selected filter type
    applyFilter() {
        if (!this.records || this.records.length === 0) {
            this.filteredRecords = [];
            return;
        }

        switch (this.selectedFilter) {
            case 'all':
                this.filteredRecords = [...this.records];
                break;

            case 'available':
                // Filter for "Pending" and "Approved" statuses
                this.filteredRecords = this.records.filter(record =>
                    this.isAvailablePayroll(record.status)
                );
                break;

            case 'historical':
                // Filter for all other statuses (not "Pending" or "Approved")
                this.filteredRecords = this.records.filter(record =>
                    !this.isAvailablePayroll(record.status)
                );
                break;

            default:
                this.filteredRecords = [...this.records];
        }

        // Reset to first page when filter changes
        this.currentPage = 1;
    }

    // Handle filter dropdown change
    handleFilterChange(event) {
        this.selectedFilter = event.target.value;
        this.applyFilter();
    }

    // Getters for computed properties
    get hasDataLoaded() {
        return !this.isLoading;
    }

    get hasData() {
        return this.filteredRecords.length > 0;
    }

    get filteredRecordsLength() {
        return this.filteredRecords.length;
    }

    get totalPages() {
        return Math.ceil(this.filteredRecordsLength / this.recordsPerPage);
    }

    get startRecord() {
        return (this.currentPage - 1) * this.recordsPerPage + 1;
    }

    get endRecord() {
        const end = this.currentPage * this.recordsPerPage;
        return end > this.filteredRecordsLength ? this.filteredRecordsLength : end;
    }

    get displayedRecords() {
        const startIndex = (this.currentPage - 1) * this.recordsPerPage;
        const records = this.filteredRecords.slice(startIndex, startIndex + this.recordsPerPage);

        return records.map(record => {
            // Update row class based on current selection state
            record.rowClass = record.selected ? 'selected' : '';
            record.statusClass = this.getStatusClass(record.status);
            return record;
        });
    }

    get pageButtons() {
        const buttons = [];
        for (let i = 1; i <= this.totalPages; i++) {
            const isActive = this.currentPage === i;
            buttons.push({
                page: i,
                label: i.toString(),
                className: isActive ? 'page-btn active' : 'page-btn'
            });
        }
        return buttons;
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }

    get isDetailLoading() {
        return this.detailLoading;
    }

    get totalDebitAmt() {
        const totalDebt = parseFloat(this.selectedRecord.totalDebt) || 0;
        const txnAmount = parseFloat(this.selectedRecord.transactionAmount) || 0;
        const vat = parseFloat(this.selectedRecord.vat) || 0;

        return totalDebt + txnAmount + vat;
    }

    // Helper method to format amount
    formatAmount(amount) {
        if (!amount) return '0.000';

        const num = parseFloat(amount);
        if (isNaN(num)) return amount;

        return num.toLocaleString('en-US', {
            minimumFractionDigits: 3,
            maximumFractionDigits: 3
        });
    }

    getStatusClass(status) {
        if (!status) return 'status-pending';

        const statusLower = status.toLowerCase();
        if (statusLower.includes('approved') || statusLower.includes('authorized')) {
            return 'status-authorized';
        } else if (statusLower.includes('pending')) {
            return 'status-pending';
        } else if (statusLower.includes('rejected') || statusLower.includes('failed') || statusLower.includes('canceled')) {
            return 'status-rejected';
        } else {
            return 'status-pending';
        }
    }

    handleEntriesChange(event) {
        this.recordsPerPage = parseInt(event.target.value, 10);
        this.currentPage = 1;
    }

    async handleRadioChange(event) {
        this.isSpinnerLoading = true;
        const recordId = parseInt(event.target.dataset.id, 10);

        // Deselect all records
        this.records.forEach(record => {
            record.selected = false;
            record.rowClass = '';
        });

        // Find and select the clicked record
        const selectedRecord = this.records.find(record => record.id === recordId);

        console.log('selectedRecord --->',selectedRecord);
        this.selectedRef = selectedRecord.reference;
        this.selectedSalaryMonth = selectedRecord.salaryMonthBeforeFormatting;

        if (selectedRecord) {
            selectedRecord.selected = true;
            selectedRecord.rowClass = 'selected';

            this.detailLoading = true;

            try {
                // Call Apex method to get payroll details and salaries
                const detailData = await getPayrollDetailandSalaries({
                    customerId: this.customerId,
                    regionName: this.regionName,
                    payrollReference: selectedRecord.originalReference || selectedRecord.reference,
                    recordId: null
                });

                if (detailData) {
                    console.log('selectedRecord -->', JSON.stringify(selectedRecord));
                    console.log('detailData -->', JSON.stringify(detailData));
                    this.selectedRecord = {
                        // Payroll Details
                        detailAccount: detailData.debitAccount || '',
                        references: detailData.reference || '',
                        salaryMonth: detailData.salaryMonth || '',
                        paymentDate: detailData.paymentDate || '',
                        employerName: detailData.employerName || '',
                        employeeCount: detailData.employeeCount || '0',
                        currency: detailData.currency || 'BHD',
                        payrollAmount: this.formatAmount(detailData.payrollAmount) || '0.000',
                        transactionAmount: selectedRecord.transactionFees || '0.000',
                        vat: selectedRecord.vat || '0.000',
                        totalDebt: this.formatAmount(selectedRecord.totalDebitAmount) || '0.000',
                        status: selectedRecord.status || '',
                        statusClass: this.getStatusClass(detailData.status),
                        reason: selectedRecord.resultCode || '-',
                        description: selectedRecord.resultDescription || '-',
                        creationDate: selectedRecord.creationDate || '',
                        ref: detailData.ref || '',
                        employees: detailData.salaries ? detailData.salaries.map(salary => ({
                            id: salary.recordNo,
                            recordNo: salary.recordNo || '',
                            name: salary.employeeName || '',
                            creditAccount: salary.creditAccount || '',
                            bankSec: salary.bankSec || '',
                            currency: salary.currencyValue || '',
                            amount: this.formatAmount(salary.amount) || '0.000',
                            idType: salary.idType || '',
                            idNumber: salary.idNumber || ''
                        })).sort((a, b) => Number(a.recordNo) - Number(b.recordNo)) : []
                    };

                    this.selectedRecord.employees.sort((a, b) => Number(a.recordNo) - Number(b.recordNo));

                    if (this.selectedRecord && this.selectedRecord.status == 'Pending') {
                        await this.callCalculateFees();
                    }
                    console.log('this.selectedRecord ---->', JSON.stringify(this.selectedRecord));
                } else {
                    console.error('Error loading payroll details:');
                }
                this.isSpinnerLoading = false;
            } catch (error) {
                console.error('Error loading payroll details:', error);
                this.showToast('Warning', 'Using basic data as detail API failed', 'warning');
                this.isSpinnerLoading = false;
            } finally {
                this.detailLoading = false;
                this.isSpinnerLoading = false;
            }

            // Update filtered records to reflect selection changes
            this.filteredRecords = [...this.records];
            // Reapply filter to maintain consistency
            this.applyFilter();
        }
    }

    async callCalculateFees() {
        try {
            console.log('Calling calculateFees...');

            const feesResponse = await calculateFees({
                recordId: this.recordId,
                regionName: this.regionName,
                payrollAmount: this.selectedRecord.totalDebt || 0,
                payrollCurrency: this.selectedRecord.currency || 'BHD',
                payrollDebitAccountIBAN: this.selectedRecord.detailAccount || '',
                payrollNoOfSalaries: this.selectedRecord.employeeCount || '0',
                cif: this.customerId,
                customerId: this.customerId
            });

            console.log('Fees Response:', JSON.stringify(feesResponse));

            if (feesResponse && feesResponse.addition) {
                let vatValue = '';
                let taxValue = '';

                // Extract VAT and TAX values from response
                feesResponse.addition.forEach(item => {
                    if (item.key === 'VAT') {
                        vatValue = item.value;
                    } else if (item.key === 'TAX') {
                        taxValue = item.value;
                    }
                });

                // Store VAT and TAX values for later use
                this.vatValue = vatValue;
                this.taxValue = taxValue;

                console.log('VAT Value:', vatValue);
                console.log('TAX Value:', taxValue);

                this.selectedRecord = { ...this.selectedRecord, transactionAmount: taxValue, vat: vatValue };

                // Optional: Dispatch an event or update UI
                this.dispatchEvent(new CustomEvent('feescalculated', {
                    detail: {
                        vat: vatValue,
                        tax: taxValue,
                        success: true
                    }
                }));
            }

        } catch (error) {
            console.error('Error calculating fees:', error);
            // Handle error gracefully without breaking the main flow
            this.dispatchEvent(new CustomEvent('feescalculated', {
                detail: {
                    vat: '0',
                    tax: '0',
                    success: false,
                    error: error.message
                }
            }));
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
        }
    }

    handlePageClick(event) {
        const page = parseInt(event.currentTarget.dataset.page, 10);
        this.currentPage = page;
    }

    async handleDownload() {
        if (!this.selectedRecord) {
            this.showToast('Error', 'Please select a payroll record to download', 'error');
            return;
        }
        console.log('selected record -->', JSON.stringify(this.selectedRecord));
        const url = '/apex/PayrollPDF?reference=' + encodeURIComponent(this.selectedRef) +
            '&customerId=' + this.customerId +
            '&regionName=' + this.regionName +
            '&recordId=' + this.recordId;

        //window.open(url, '_blank');
        try {
            this.isLoading = true;
            this.error = null;
            console.log('status -->', this.selectedRecord.status);
            const result = await downloadPayrollDocument({
                customerId: this.customerId,
                regionName: this.regionName,
                payrollRef: this.selectedRecord.references,
                payrollId: this.selectedRef,
                status: this.selectedRecord.status,
                fileOutputType: this.fileOutputType,
                fees: this.selectedRecord.transactionAmount,
                vat: this.selectedRecord.vat,
                salaryMonth: this.selectedSalaryMonth
            });
            console.log('result --->', JSON.stringify(result));
            if (result.success) {
                // Check if we have fileContent (Base64 encoded PDF)
                if (result.fileContent) {
                    const pdfBase64 = result.fileContent;
                    const filename = result.fileName || this.generateFilename(this.selectedRecord.references, this.status);

                    // Create and trigger download
                    const element = document.createElement('a');
                    element.href = `data:${result.fileMimeType || 'application/pdf'};base64,${pdfBase64}`;
                    element.download = filename;
                    element.style.display = 'none';

                    document.body.appendChild(element);
                    element.click();
                    document.body.removeChild(element);

                    console.log('PDF downloaded successfully:', filename);
                } else {
                    console.error('No file content in response');
                    // Handle case where fileContent is missing
                    this.showError('No file content available for download');
                }
            } else {
                // Handle API error
                console.error('API call failed:', result.error);
                this.showError(result.error || 'Failed to download document');
            }
        } catch (error) {
            console.error('Download error:', error);
            this.error = error.body?.message || error.message || 'Unknown error occurred';
            this.showToast('Error', this.error, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    generateFilename(payrollRef, status) {
        return `CIF_PAYROLLREF_${payrollRef}_${status || 'pending'}.pdf`;
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    get hasError() {
        return this.error;
    }

    get isLinkType() {
        return this.fileOutputType === 'link';
    }

    get isFileType() {
        return this.fileOutputType === 'file';
    }

    handleBase64Download(base64Data, fileName) {
        try {
            // Decode base64 to binary
            const binaryString = atob(base64Data);
            const bytes = new Uint8Array(binaryString.length);

            for (let i = 0; i < binaryString.length; i++) {
                bytes[i] = binaryString.charCodeAt(i);
            }

            // Create blob and download
            const blob = new Blob([bytes]);
            const url = window.URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.href = url;
            link.download = fileName || 'payroll_document.pdf';
            link.click();

            // Clean up
            window.URL.revokeObjectURL(url);
        } catch (error) {
            console.error('Base64 download error:', error);
            this.error = 'Error processing file download';
            this.showToast('Error', this.error, 'error');
        }
    }

    get formattedMonthYear() {
        const val = this.selectedRecord.salaryMonth; // e.g., "052025"
        if (!val || val.length !== 6) return '';

        const month = val.substring(0, 2); // "05"
        const year = val.substring(2);     // "2025"

        // Convert month number to month name
        const monthName = new Date(`${year}-${month}-01`).toLocaleString('en-US', {
            month: 'long'
        });

        return `${monthName} ${year}`;
    }

    get formattedPaymentDate() {
        if (!this.selectedRecord.paymentDate) {
            return '';
        }

        const [year, month, day] = this.selectedRecord.paymentDate.split('-');
        return `${day}-${month}-${year}`;
    }

    get formattedCreationDate() {
        if (!this.selectedRecord.creationDate) {
            return '';
        }

        const [year, month, day] = this.selectedRecord.creationDate.split('-');
        return `${day}-${month}-${year}`;
    }
}
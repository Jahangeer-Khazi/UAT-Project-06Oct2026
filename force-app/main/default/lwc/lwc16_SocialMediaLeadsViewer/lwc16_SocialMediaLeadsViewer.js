import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getSocialMediaLeads from '@salesforce/apex/lwc16_SocialMediaLeadsViewerController.getSocialMediaLeads';
import assignLeads from '@salesforce/apex/lwc16_SocialMediaLeadsViewerController.assignLeads';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

/**
 * Column Definitions for the Social Media Leads Viewer Table
 */
const COLUMNS = [
    {
        label: 'Name',
        fieldName: 'recordUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' },
        initialWidth: 160,
        sortable: true
    },
    { label: 'Email Address', fieldName: 'Email__c', type: 'email', initialWidth: 200, sortable: true },
    { label: 'Phone Number', fieldName: 'Mobile__c', type: 'text', initialWidth: 140, sortable: true },

    { label: 'Lead ID', fieldName: 'Id', type: 'text', initialWidth: 170 },
    {
        label: 'IsCustomer',
        fieldName: 'isCustomer_str',
        type: 'text',
        initialWidth: 115,
        sortable: true,
        cellAttributes: { alignment: 'center', class: { fieldName: 'isCustomer_class' } }
    },
    {
        label: 'CIF',
        fieldName: 'accountUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'CIF__c' }, target: '_blank' },
        initialWidth: 120,
        sortable: true
    },
    {
        label: 'Blacklisted',
        fieldName: 'isBlacklisted_str',
        type: 'text',
        initialWidth: 110,
        sortable: true,
        cellAttributes: { alignment: 'center', class: { fieldName: 'isBlacklisted_class' } }
    },
    {
        label: 'Terminated Relationship',
        fieldName: 'terminatedRelationship_str',
        type: 'text',
        initialWidth: 175,
        sortable: true,
        cellAttributes: { alignment: 'center', class: { fieldName: 'terminatedRelationship_class' } }
    },
    {
        label: 'Active Credit Card',
        fieldName: 'hasActiveCreditCard_str',
        type: 'text',
        initialWidth: 145,
        sortable: true,
        cellAttributes: { alignment: 'center', class: { fieldName: 'hasActiveCreditCard_class' } }
    },
    {
        label: 'Pending Credit Card',
        fieldName: 'hasPendingCreditCard_str',
        type: 'text',
        initialWidth: 148,
        sortable: true,
        cellAttributes: { alignment: 'center', class: { fieldName: 'hasPendingCreditCard_class' } }
    },
    {
        label: 'Declined Credit Card',
        fieldName: 'hasDeclinedCreditCard_str',
        type: 'text',
        initialWidth: 152,
        sortable: true,
        cellAttributes: { alignment: 'center', class: { fieldName: 'hasDeclinedCreditCard_class' } }
    },
    { label: 'Owner', fieldName: 'ownerName', type: 'text', initialWidth: 150, sortable: true },
    { label: 'Sales Agent', fieldName: 'salesAgentName', type: 'text', initialWidth: 150, sortable: true },
    { label: 'Status', fieldName: 'Status__c', type: 'text', initialWidth: 120, sortable: true },
    { label: 'Secondary Phone', fieldName: 'Secondary_Phone_Number__c', type: 'text', initialWidth: 150, sortable: true },
    { label: 'WhatsApp', fieldName: 'Whatsapp_number__c', type: 'text', initialWidth: 140, sortable: true },
    { label: 'Source', fieldName: 'Source__c', type: 'text', initialWidth: 130, sortable: true }
];

const YES_CLASS = 'slds-text-color_success slds-text-title_bold';
const NO_CLASS = 'slds-text-color_weak';
const WARN_CLASS = 'slds-text-color_error slds-text-title_bold';

export default class Lwc16_SocialMediaLeadsViewer extends NavigationMixin(LightningElement) {
    // ── UI States ──────────────────────────────────────────────────────────
    @track isMainTableVisible = false;
    @track isMainLoading = false;
    @track isAssignmentLoading = false;
    @track errorMessage = '';
    @track isAssignModalOpen = false;

    // ── Main Table Parameters ──────────────────────────────────────────────
    // ── Main Table Parameters (Staged - not yet applied to SOQL) ──────────
    @track stageOwnerFilter = 'All';
    @track stagePageSize = '10';
    @track stageSearchTerm = '';

    // ── Applied Parameters (Direct @wire dependencies) ─────────────────────
    @track ownerFilter = 'All';
    @track pageSize = '10';
    @track searchTerm = '';
    @track currentPage = 1;
    @track sortedBy;
    @track sortedDirection = 'desc';

    // ── Assignment Modal Parameters ────────────────────────────────────────
    @track stageAssignmentOwnerFilter = 'All';
    @track stageAssignmentPageSize = '10';
    @track stageAssignmentSearchTerm = '';

    @track assignmentOwnerFilter = 'All';
    @track assignmentPageSize = '10';
    @track assignmentSearchTerm = '';
    @track assignmentCurrentPage = 1;

    // ── Data Storage ───────────────────────────────────────────────────────
    @track mainTableData = [];
    @track assignmentTableData = [];
    @track totalItemCount = 0;
    @track assignmentTotalItemCount = 0;
    @track selectedLeads = [];
    @track selectedAgentId;

    @track accountIdMap = {};
    wiredLeadsResult;
    wiredAssignmentLeadsResult;
    columns = COLUMNS;

    // ── Wired Data ─────────────────────────────────────────────────────────

    @wire(getSocialMediaLeads, {
        pageSize: '$pageSize',
        pageNumber: '$currentPage',
        ownerFilter: '$ownerFilter',
        searchTerm: '$searchTerm',
        onlyUnassigned: false
    })
    wiredLeads(result) {
        this.wiredLeadsResult = result;
        const { data, error } = result;
        if (data) {
            if (data.accountIdMap) {
                this.accountIdMap = { ...this.accountIdMap, ...data.accountIdMap };
            }
            this.mainTableData = this.formatRecordsForTable(data.leads);
            this.totalItemCount = data.totalItemCount;
            this.errorMessage = '';
            this.isMainLoading = false;
        } else if (error) {
            this.errorMessage = 'Error loading leads: ' + (error.body?.message || error.message);
            this.mainTableData = [];
            this.isMainLoading = false;
        }
    }

    @wire(getSocialMediaLeads, {
        pageSize: '$assignmentPageSize',
        pageNumber: '$assignmentCurrentPage',
        ownerFilter: '$assignmentOwnerFilter',
        searchTerm: '$assignmentSearchTerm',
        onlyUnassigned: true
    })
    wiredAssignmentLeads(result) {
        this.wiredAssignmentLeadsResult = result;
        const { data, error } = result;
        if (data) {
            if (data.accountIdMap) {
                this.accountIdMap = { ...this.accountIdMap, ...data.accountIdMap };
            }
            this.assignmentTableData = this.formatRecordsForTable(data.leads);
            this.assignmentTotalItemCount = data.totalItemCount;
            this.isAssignmentLoading = false;
        } else if (error) {
            console.error('Error in assignment fetch:', error);
            this.isAssignmentLoading = false;
        }
    }

    // ── Computed Properties ──────────────────────────────────────────────────

    get pagedData() { return this.mainTableData; }
    get assignmentPagedData() { return this.assignmentTableData; }

    get recordCountLabel() {
        return `${this.totalItemCount} record(s) found`;
    }

    get isTableVisible() { return this.isMainTableVisible; }

    get showEmptyState() {
        return this.isMainTableVisible && this.mainTableData.length === 0 && !this.errorMessage;
    }

    get selectedCount() { return this.selectedLeads.length; }

    get isAssignDisabled() { return !this.selectedAgentId || this.isAssignmentLoading; }

    get isApplyAssignmentDisabled() {
        return (
            this.stageAssignmentOwnerFilter === this.assignmentOwnerFilter &&
            this.stageAssignmentPageSize === this.assignmentPageSize &&
            this.stageAssignmentSearchTerm === (this.assignmentSearchTerm || '')
        );
    }

    get isApplyMainDisabled() {
        return (
            this.stageOwnerFilter === this.ownerFilter &&
            this.stagePageSize === this.pageSize &&
            this.stageSearchTerm === (this.searchTerm || '')
        );
    }

    // ── Pagination Logic ───────────────────────────────────────────────────

    get totalPages() { return Math.ceil(this.totalItemCount / Number(this.pageSize)) || 1; }
    get isFirstPage() { return this.currentPage === 1; }
    get isLastPage() { return this.currentPage >= this.totalPages; }

    get assignmentTotalPages() { return Math.ceil(this.assignmentTotalItemCount / Number(this.assignmentPageSize)) || 1; }
    get isAssignmentFirstPage() { return this.assignmentCurrentPage === 1; }
    get isAssignmentLastPage() { return this.assignmentCurrentPage >= this.assignmentTotalPages; }

    // ── Filter Options ─────────────────────────────────────────────────────

    get ownerOptions() {
        return [
            { label: 'All', value: 'All' },
            { label: 'Social Media Leads Queue', value: 'Social_Media_Leads_Queue' },
            { label: 'Fawaz', value: 'Fawaz' },
            { label: 'Hasan', value: 'Hasan' },
            { label: 'Fatema', value: 'Fatema' }
        ];
    }

    get pageSizeOptions() {
        return [
            { label: '10', value: '10' },
            { label: '20', value: '20' },
            { label: '50', value: '50' },
            { label: '100', value: '100' },
            { label: '150', value: '150' },
            { label: '200', value: '200' }
        ];
    }

    // ── Action Handlers (Main Viewer) ──────────────────────────────────────

    handleViewLeads() {
        this.isMainTableVisible = true;
        // Only show spinner if data hasn't already been loaded by the wire service
        if (this.mainTableData.length === 0) {
            this.isMainLoading = true;
        }
    }

    handleRefresh() {
        this.isMainLoading = true;
        refreshApex(this.wiredLeadsResult).finally(() => { this.isMainLoading = false; });
    }

    handleAssignmentRefresh() {
        this.isAssignmentLoading = true;
        refreshApex(this.wiredAssignmentLeadsResult).finally(() => { this.isAssignmentLoading = false; });
    }

    handleHideTable() {
        this.isMainTableVisible = false;
        this.ownerFilter = 'All';
        this.searchTerm = '';
        this.currentPage = 1;
    }

    handleSearch(event) {
        this.stageSearchTerm = event.target.value;
    }

    handleOwnerFilterChange(event) {
        this.stageOwnerFilter = event.detail.value;
    }

    handlePageSizeChange(event) {
        this.stagePageSize = event.detail.value;
    }

    handleApplyFilters() {
        this.isMainLoading = true;
        this.ownerFilter = this.stageOwnerFilter;
        this.pageSize = String(parseInt(this.stagePageSize, 10) || 10);
        this.searchTerm = this.stageSearchTerm;
        this.currentPage = 1; // Reset to page 1
    }

    handlePreviousPage() { if (this.currentPage > 1) this.currentPage--; }
    handleNextPage() { if (this.currentPage < this.totalPages) this.currentPage++; }

    handleSort(event) {
        // Note: Server-side sorting not yet fully implemented in Apex, 
        // but we preserve the UI state here.
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
    }

    // ── Action Handlers (Assignment Local) ──────────────────────────────────

    handleOpenAssignModal() {
        this.stageAssignmentOwnerFilter = 'All';
        this.stageAssignmentPageSize = '10';
        this.stageAssignmentSearchTerm = '';
        this.assignmentOwnerFilter = 'All';
        this.assignmentPageSize = '10';
        this.assignmentSearchTerm = '';
        this.assignmentCurrentPage = 1;
        this.isAssignModalOpen = true;
        this.selectedLeads = [];
        this.selectedAgentId = null;
    }

    handleCloseAssignModal() { this.isAssignModalOpen = false; }

    handleAssignmentSearch(event) {
        this.stageAssignmentSearchTerm = event.target.value;
    }

    handleAssignmentOwnerFilterChange(event) {
        this.stageAssignmentOwnerFilter = event.detail.value;
    }

    handleAssignmentPageSizeChange(event) {
        this.stageAssignmentPageSize = event.detail.value;
    }

    handleApplyAssignmentFilters() {
        this.isAssignmentLoading = true;
        this.assignmentOwnerFilter = this.stageAssignmentOwnerFilter;
        this.assignmentPageSize = String(parseInt(this.stageAssignmentPageSize, 10) || 10);
        this.assignmentSearchTerm = this.stageAssignmentSearchTerm;
        this.assignmentCurrentPage = 1;
    }

    handleAssignmentPrev() { if (this.assignmentCurrentPage > 1) this.assignmentCurrentPage--; }
    handleAssignmentNext() { if (this.assignmentCurrentPage < this.assignmentTotalPages) this.assignmentCurrentPage++; }

    handleAssignmentRowSelection(event) { this.selectedLeads = event.detail.selectedRows; }

    handleAgentChange(event) {
        const value = event.detail.value;
        this.selectedAgentId = Array.isArray(value) ? value[0] : value;
    }

    handleConfirmAssignment() {
        if (!this.selectedAgentId) {
            this.showToast('Warning', 'Please select a Sales Agent.', 'warning');
            return;
        }
        if (this.selectedLeads.length === 0) {
            this.showToast('Warning', 'Please select at least one lead to assign.', 'warning');
            return;
        }

        this.isMainLoading = true;
        this.isAssignmentLoading = true;
        const leadsToUpdate = this.selectedLeads.map(lead => ({ Id: lead.Id }));

        assignLeads({ leads: leadsToUpdate, agentId: this.selectedAgentId })
            .then(() => {
                this.showToast('Success', `Assigned ${this.selectedLeads.length} lead(s).`, 'success');
                this.isAssignModalOpen = false;
                // Refresh both datasets
                return Promise.all([
                    refreshApex(this.wiredLeadsResult),
                    refreshApex(this.wiredAssignmentLeadsResult)
                ]);
            })
            .catch(error => {
                this.showToast('Error', error.body?.message || error.message, 'error');
            })
            .finally(() => {
                this.isMainLoading = false;
                this.isAssignmentLoading = false;
            });
    }

    // ── Helper Methods ─────────────────────────────────────────────────────

    formatRecordsForTable(records) {
        return records.map(record => {
            const row = { ...record };
            row.ownerName = record.Owner?.Name || '';
            row.salesAgentName = record.Sales_Agent__r?.Name || '';

            row.isCustomer_str = record.Is_Customer__c ? 'Yes' : 'No';
            row.isBlacklisted_str = record.Is_Blacklisted__c ? 'Yes' : 'No';
            row.terminatedRelationship_str = record.Terminated_Relationship__c ? 'Yes' : 'No';
            row.hasActiveCreditCard_str = record.Active_Credit_Card__c ? 'Yes' : 'No';
            row.hasPendingCreditCard_str = record.Pending_Credit_Card__c ? 'Yes' : 'No';
            row.hasDeclinedCreditCard_str = record.Declined_Credit_Card__c ? 'Yes' : 'No';

            row.isCustomer_class = record.Is_Customer__c ? YES_CLASS : NO_CLASS;
            row.isBlacklisted_class = record.Is_Blacklisted__c ? WARN_CLASS : NO_CLASS;
            row.terminatedRelationship_class = record.Terminated_Relationship__c ? WARN_CLASS : NO_CLASS;
            row.hasActiveCreditCard_class = record.Active_Credit_Card__c ? YES_CLASS : NO_CLASS;
            row.hasPendingCreditCard_class = record.Pending_Credit_Card__c ? YES_CLASS : NO_CLASS;
            row.hasDeclinedCreditCard_class = record.Declined_Credit_Card__c ? WARN_CLASS : NO_CLASS;

            row.recordUrl = `/lightning/r/Social_Media_Leads__c/${record.Id}/view`;
            const accId = record.CIF__c && this.accountIdMap ? this.accountIdMap[record.CIF__c] : null;
            row.accountUrl = accId ? `/lightning/r/Account/${accId}/view` : '';
            return row;
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
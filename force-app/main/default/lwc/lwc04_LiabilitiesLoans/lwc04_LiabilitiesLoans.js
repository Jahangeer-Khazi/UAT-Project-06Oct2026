import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import getCaseAnnexFieldsMap from '@salesforce/apex/Lwc03_FinancialDetailsController.getCaseAnnexFieldsMap';
import getCaseFieldsMap from '@salesforce/apex/Lwc03_FinancialDetailsController.getCaseFieldsMap';
import updateCaseAnnexRecord from '@salesforce/apex/Lwc03_FinancialDetailsController.updateCaseAnnexRecord';

export default class Lwc04_LiabilitiesLoans extends LightningElement {
    @api recordId;
    @track loadingSpinner = false;
    @track liabilitiesOptions = [];
    @track requestedLiabilitiesSelectedRows = [];
    @track draftValues = [];
    @track originalLiabilities = []; // Stores the last saved state
    @track recordAnnexId;
    @track cx_ln_total_current_obligations;
    @track cx_ln_Approved_Loan_Amount;
    @track wiredCaseAnnexFields; // Store the wired data

    @track liabilitiesColumns = [
        { label: 'Type', fieldName: 'type', type: 'text', editable: true },
        { label: 'Outstanding', fieldName: 'outstanding', type: 'number', editable: true },
        { label: 'Monthly Installment', fieldName: 'monthlyInstallment', type: 'number', editable: true },
        { label: 'Comment', fieldName: 'comment', type: 'text', editable: true }
    ];

    @track totalSelectedLiabilities = 0;
    @track totalSelectedMonthlyInstallment = 0;
    @track totalActualObligations = 0;

    // Keep both sections mounted when collapsed so in-progress edits are preserved.
    @track isLiabilitiesSectionOpen = true;
    @track isMultiBankSectionOpen = true;

    get liabilitiesSectionClass() {
        return `slds-section slds-box slds-theme_default slds-m-bottom_large${this.isLiabilitiesSectionOpen ? ' slds-is-open' : ''}`;
    }

    get multiBankSectionClass() {
        return `slds-section slds-box slds-theme_default slds-m-bottom_large${this.isMultiBankSectionOpen ? ' slds-is-open' : ''}`;
    }

    get liabilitiesContentClass() {
        return `slds-section__content${this.isLiabilitiesSectionOpen ? '' : ' slds-hide'}`;
    }

    get multiBankContentClass() {
        return `slds-section__content${this.isMultiBankSectionOpen ? '' : ' slds-hide'}`;
    }

    get liabilitiesSectionIcon() {
        return 'utility:chevronright';
    }

    get multiBankSectionIcon() {
        return 'utility:chevronright';
    }

    toggleLiabilitiesSection() {
        this.isLiabilitiesSectionOpen = !this.isLiabilitiesSectionOpen;
    }

    toggleMultiBankSection() {
        this.isMultiBankSectionOpen = !this.isMultiBankSectionOpen;
    }

    connectedCallback() {
        this.loadingSpinner = true;
        this.loadData();
    }

    @wire(getCaseFieldsMap, { recordId: '$recordId' })
    wiredGetCaseFields({ data, error }) {
            this.loadData();
    }

    @wire(getCaseAnnexFieldsMap, { recordId: '$recordId' })
    wiredGetCaseAnnexFields(result) {
        this.wiredCaseAnnexFields = result; // Store result to use in refreshApex
        if (result.data && result.data[0]?.cx_ln_requested_liabilities__c) {
            this.liabilitiesOptions = this.formatJsonTable(result.data[0].cx_ln_requested_liabilities__c);
            this.originalLiabilities = JSON.parse(JSON.stringify(this.liabilitiesOptions)); // Store last saved state

            this.requestedLiabilitiesSelectedRows = this.liabilitiesOptions
                .filter(row => row.selected)
                .map(row => row.Id);

            this.calculateTotals();
        } else if (result.error) {
            console.error('Error fetching case annex fields:', result.error);
        }
    }

    formatJsonTable(stringInputJson) {
        let liabilitiesParsed = JSON.parse(stringInputJson);
    
        liabilitiesParsed = liabilitiesParsed.map((item, index) => {
            // Add 'id' if not present, starting from 1
            if (!('Id' in item)) {
                item.Id = (index + 1).toString();
            }
    
            // Add 'selected' if not present
            if (!('selected' in item)) {
                item.selected = true;
            }
    
            return item;
        });
        console.log('liabilitiesParsed --->>>');
        console.log(liabilitiesParsed);
        return liabilitiesParsed;
    }

    loadData() {
        this.liabilitiesOptions = []; // Reset before loading
        getCaseAnnexFieldsMap({ recordId: this.recordId })
            .then(data => {
                this.recordAnnexId = data[0].id;
                this.cx_ln_total_current_obligations = data[0].cx_ln_totalcurrentobligations__c;
                this.cx_ln_Approved_Loan_Amount = data[0].cx_ln_approved_loan_amount__c;
                console.log('this.recordAnnexId --> ' + this.recordAnnexId);
                if (data[0]?.cx_ln_requested_liabilities__c) {
                    this.liabilitiesOptions = this.formatJsonTable(data[0].cx_ln_requested_liabilities__c);
                    
                    this.originalLiabilities = JSON.parse(JSON.stringify(this.liabilitiesOptions)); // Store last saved state
                    console.log("after loading --> "+data[0].cx_ln_requested_liabilities__c);

                    // Ensure checkbox selection is based on "selected" field
                    this.requestedLiabilitiesSelectedRows = this.liabilitiesOptions
                    .filter(row => row.selected)
                    .map(row => row.Id);

                this.calculateTotals();
                this.loadingSpinner = false;
            }
        })
        .catch(error => {
            console.error('Error loading liabilities:', error);
        });
    }

    handleLiabilitiesRowSelection(event) {
        console.log("handleLiabilitiesRowSelection --> ");

        let selectedRows = event.detail.selectedRows;
        this.requestedLiabilitiesSelectedRows = selectedRows.map(row => row.Id);

        // Step 2: Update "selected" property
        this.liabilitiesOptions = this.liabilitiesOptions.map(row => ({
            ...row,
            selected: this.requestedLiabilitiesSelectedRows.includes(row.Id)
        }));
    
        // Step 3: Ensure draftValues are not reset
        this.draftValues = [...this.liabilitiesOptions]; // Assigning draftValues to trigger changes
    
        this.calculateTotals();
    }
    

    handleAddRow() {
        let newId = this.liabilitiesOptions.length + 1;
        let newRow = {
            Id: newId,
            selected: false,
            type: '',
            outstanding: 0,
            monthlyInstallment: 0,
            comment: ''
        };
        this.liabilitiesOptions = [...this.liabilitiesOptions, newRow];
        // Trick `lightning-datatable` into showing Save/Cancel buttons 
        this.draftValues = [...this.liabilitiesOptions]; // Assigning draftValues to trigger changes
    }

    handleSave(event) {
        const updatedValues = event.detail.draftValues; // Get only modified rows
        console.log("Draft Values:", JSON.stringify(updatedValues));
        
        // Ensure proper ID matching by converting `Id` to a number
        this.liabilitiesOptions = this.liabilitiesOptions.map(existingRow => {
            let updatedRow = updatedValues.find(row => Number(row.Id) === Number(existingRow.Id));
            return updatedRow ? { ...existingRow, ...updatedRow } : existingRow;
        });

        //ensure params are decimals
        this.liabilitiesOptions = this.liabilitiesOptions.map(liability => ({
            ...liability,
            outstanding: Number(liability.outstanding),
            monthlyInstallment: Number(liability.monthlyInstallment)
        }));

        console.log('after converted --> this.liabilitiesOptions --> ');
        console.log(this.liabilitiesOptions);

        if (this.validateData()) {
            this.draftValues = [];
            let updatedJson = JSON.stringify(this.liabilitiesOptions);
            this.calculateTotals();
            console.log("check onSave2 --> ");
            console.log(this.totalSelectedLiabilities);
            console.log(this.totalSelectedMonthlyInstallment);
            if(this.totalSelectedLiabilities > this.cx_ln_Approved_Loan_Amount ){
                this.showToast('Error', 'The Total Selected Liabilities Amount shouldn’t exceed the approved loan amount ( '+this.cx_ln_Approved_Loan_Amount+' ).', 'error');
            }
            else{
                this.updateRecordField(updatedJson);
            }
        }
    }

    handleCancel() {
        console.log("lwc04-> handleCancel()");
        this.liabilitiesOptions = JSON.parse(JSON.stringify(this.originalLiabilities));
        this.draftValues = [];
        this.requestedLiabilitiesSelectedRows = this.liabilitiesOptions
            .filter(row => row.selected)
            .map(row => row.Id);
        this.calculateTotals();
    }

    updateRecordField(updatedJson) {
        this.loadingSpinner = true;
        updateCaseAnnexRecord({
            recordAnnexId: this.recordAnnexId,
            cx_ln_Requested_Liabilities: updatedJson,
            cx_ln_TotalLiabilitiesAmount: this.totalSelectedLiabilities,
            cx_ln_TotalLiabilityMonthlyInstallAmount: this.totalSelectedMonthlyInstallment
        })
            .then(() => {
                this.showToast('Success', 'Liabilities updated successfully', 'success');
                return refreshApex(this.wiredCaseAnnexFields); // Ensure UI refresh
            })
            .then(() => {
                this.loadData();
            })
            .catch(error => {
                console.error('Error updating record:', error);
                this.showToast('Error', 'Failed to update record.', 'error');
            })
            .finally(() => {
                this.loadingSpinner = false;
            });
    }

    validateData() {
        //toDo : check also comment field should not passe 80 char : ...
        console.log('validateData() --> ');
        for (let row of this.liabilitiesOptions) {
            if (!row.type || row.outstanding == null || row.outstanding === '' || row.monthlyInstallment == null || row.monthlyInstallment === '') {
                console.log('error on row  --> '+ row.Id);
                console.log(row);
                this.showToast('Error', 'All fields except Comment are required.', 'error');
                return false;
            }
            else if (row.outstanding < 0 || row.monthlyInstallment < 0) {
                this.showToast('Error', 'amounts cannot be negative or empty.', 'error');
                return false;
            }
        }
        return true;
    }

    calculateTotals() {
        this.totalSelectedLiabilities = this.liabilitiesOptions
            .filter(row => row.selected)
            .reduce((sum, row) => sum + row.outstanding, 0);

        this.totalSelectedMonthlyInstallment = this.liabilitiesOptions
            .filter(row => row.selected)
            .reduce((sum, row) => sum + row.monthlyInstallment, 0);

        this.totalActualObligations = this.cx_ln_total_current_obligations - this.totalSelectedMonthlyInstallment;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant, mode: 'dismissible' }));
    }
}
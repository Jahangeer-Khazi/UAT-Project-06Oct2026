import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import { refreshApex } from '@salesforce/apex';
import getPayrolls from '@salesforce/apex/PayrollController.getPayrolls';
import savePayrollTotal from '@salesforce/apex/PayrollController.savePayrollTotal';
import getPayrollDetailandSalaries from '@salesforce/apex/PayrollController.getPayrollDetailandSalaries';
import calculateFees from '@salesforce/apex/WPSPayrollHandler.calculateFees';
import getStoredPayrollData from '@salesforce/apex/PayrollController.getStoredPayrollData';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import WPS_PAYROLL_OBJECT from "@salesforce/schema/WPSPayroll__c";
import PAYROLL_REASON_FIELD from "@salesforce/schema/WPSPayroll__c.Payroll_Reason__c";

import CIF_FIELD from '@salesforce/schema/WPSPayroll__c.Customer__r.Customer_CIF__c';
import REGION_FLAG_FIELD from '@salesforce/schema/WPSPayroll__c.Customer__r.Region_Flag__c';
import IS_ACTIONED_FIELD from '@salesforce/schema/WPSPayroll__c.is_Actioned__c';
import CASE_MODEL_FIELD from '@salesforce/schema/WPSPayroll__c.Case_Model__c';
import PAYROLL_ACTION_FIELD from '@salesforce/schema/WPSPayroll__c.Payroll_Action__c';
import PAYROLL_REFERENCE_FIELD from '@salesforce/schema/WPSPayroll__c.Payroll_Reference__c';

export default class PayrollRecordComponent extends LightningElement {
    @api recordId;
    @track customerId = '';
    @track regionName = '';
    @track isActioned = false;
    @track storedPayrollAction = '';
    @track storedPayrollReference = '';
    @track hasRecordData = false;
    @track rejectReason = ''; // NEW: Track reject reason
    @track isAlburaqProduct = false;
    isLoading = false;
    showError = false;
    errorMessage = '';
    payrollOptions = [];
    showPayrollDetails = false;
    isPicklistDisabled = false;
    showConfirmButton = false;
    showEditButton = false;
    selectedPayroll = {};
    makerResult = null;
    payrolls = [];
    payrollstatus = '';
    allowedActions = [];
    actionValue = '';
    showActionCombobox = false;
    selectedPayRollRef = '';
    @track payrollDetail = {};
    showRejectReasonField = false;
    wpsPayrollRecordTypeId;
    cancelRejectReasons;
    error;
    @track filteredDependencyList = [];
    wiredRecordResult;
    @track disableCombobox;
    @track caseModel;

    // 🔥 ADDED: Store complete payroll data for actioned records
    @track actionedPayrollData = {};

    @wire(getObjectInfo, { objectApiName: WPS_PAYROLL_OBJECT })
    results({ error, data }) {
        if (data) {
            this.wpsPayrollRecordTypeId = data.defaultRecordTypeId;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.wpsPayrollRecordTypeId = undefined;
        }
    }

    @wire(getPicklistValues, { recordTypeId: "$wpsPayrollRecordTypeId", fieldApiName: PAYROLL_REASON_FIELD })
    picklistResults({ error, data }) {
        if (data) {
            this.cancelRejectReasons = data.values;
            console.log('cancelRejectReasons ---->', JSON.stringify(this.cancelRejectReasons));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.cancelRejectReasons = undefined;
        }
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [CIF_FIELD, REGION_FLAG_FIELD, IS_ACTIONED_FIELD, PAYROLL_ACTION_FIELD, PAYROLL_REFERENCE_FIELD, CASE_MODEL_FIELD]
    })
    wiredRecord(result) {
        this.wiredRecordResult = result; // Store the result for refresh

        const { error, data } = result;
        if (data) {
            console.log('Data --->', data);
            this.customerId = data.fields?.Customer__r?.value?.fields?.Customer_CIF__c?.value || '';
            this.regionName = data.fields?.Customer__r?.value?.fields?.Region_Flag__c?.value || '';

            if (!this.isActioned) {
                this.isActioned = data.fields?.is_Actioned__c?.value || false;
            }

            this.storedPayrollAction = data.fields?.Payroll_Action__c?.value || '';
            this.storedPayrollReference = data.fields?.Payroll_Reference__c?.value || '';
            this.caseModel = data.fields?.Case_Model__c?.value || '';

            console.log('this.caseModel  --->',this.caseModel);
            if(this.caseModel == 'alburaq') {
                this.isAlburaqProduct = true;
            }
            this.hasRecordData = true;

            console.log('Is Actioned:', this.isActioned);
            console.log('Stored Payroll Action:', this.storedPayrollAction);
            console.log('Stored Payroll Reference:', this.storedPayrollReference);

        } else if (error) {
            console.error('Error --->', error);
            this.customerId = '';
            this.regionName = '';
            this.hasRecordData = true;
        }
    }

    // Load stored payroll data for actioned records
    async loadStoredPayrollData() {
        this.isLoading = true;
        try {
            const storedData = await getStoredPayrollData({
                recordId: this.recordId
            });

            if (storedData) {
                console.log('Loaded stored payroll data:', storedData);

                // 🔥 FIX: Store the stored data separately
                this.selectedPayroll = {
                    ...storedData,
                    debitAccount: storedData.debitAccount,
                    reference: storedData.reference,
                    salaryMonth: storedData.salaryMonth,
                    paymentDate: storedData.paymentDate,
                    employerName: storedData.employerName,
                    employeeCount: storedData.employeeCount,
                    currencyValue: storedData.currencyValue,
                    payrollAmount: storedData.payrollAmount,
                    transactionFees: storedData.transactionFees,
                    vat: storedData.vat,
                    totalDebt: storedData.totalDebt,
                    status: storedData.status,
                    action: storedData.action,
                    reason: storedData.reason,
                    creationDate: storedData.creationDate
                };

                console.log('storedData.status --->', storedData.status);
                console.log('payrollDetail.status --->', this.payrollDetail.status);

                // 🔥 FIX: Create a complete actionedPayrollData object with ALL details
                this.actionedPayrollData = {
                    // From stored data (action, status, reason)
                    action: storedData.action || this.storedPayrollAction,
                    status: storedData.status || this.payrollDetail.status,
                    reason: storedData.reason || this.rejectReason,

                    // From original payrollDetail (API 1 details)
                    debitAccount: storedData.debitAccount || this.payrollDetail.debitAccount,
                    currencyValue: storedData.currencyValue || this.payrollDetail.currencyValue,
                    transactionFees: storedData.transactionFees || this.payrollDetail.transactionFees,
                    vat: storedData.vat || this.payrollDetail.vat,
                    totalDebitAmount: this.payrollDetail.totalDebitAmount,
                    creationDate: storedData.creationDate || this.payrollDetail.creationDate,

                    // From selectedPayroll (API 2 details)
                    salaryMonth: storedData.salaryMonth || this.selectedPayroll.salaryMonth,
                    paymentDate: storedData.paymentDate || this.selectedPayroll.paymentDate,
                    employerName: storedData.employerName || this.selectedPayroll.employerName,
                    employeeCount: storedData.employeeCount || this.selectedPayroll.employeeCount,
                    payrollAmount: storedData.payrollAmount || this.selectedPayroll.payrollAmount,
                    totalDebt: storedData.totalDebt || this.selectedPayroll.totalDebt
                };

                this.showPayrollDetails = true;

                // Set the action value for the combobox
                this.actionValue = this.storedPayrollAction;

                // Show the action combobox with the selected value
                this.showActionCombobox = true;
                this.disableCombobox = true;

                // 🔥 FILTER DEPENDENCY VALUES
                if (this.storedPayrollAction === 'Cancel') {
                    this.filteredDependencyList = this.getValuesByValidFor(2);
                } else if (this.storedPayrollAction === 'Reject') {
                    this.filteredDependencyList = this.getValuesByValidFor(1);
                } else {
                    this.filteredDependencyList = [];
                }


                // If stored action is Reject, show the reject reason field
                if (this.storedPayrollAction === 'Reject' || this.storedPayrollAction === 'Cancel') {
                    this.showRejectReasonField = true;
                    this.rejectReason = storedData.reason || '';
                }

                // Set allowed actions based on the stored action (for display purposes)
                this.setAllowedActionsForStoredData();

                // Disable all interactions
                this.disableAllInteractions();

            } else {
                console.log('No stored data found for actioned record');
            }
        } catch (error) {
            console.error('Error loading stored payroll data:', error);
            this.handleError('Failed to load stored payroll data: ' + error.message);
        } finally {
            this.isLoading = false;
        }
    }

    // Set allowed actions based on stored action for display
    setAllowedActionsForStoredData() {
        if (this.storedPayrollAction === 'Approve' || this.storedPayrollAction === 'Reject') {
            this.allowedActions = [
                { label: 'Approve', value: 'Approve' },
                { label: 'Reject', value: 'Reject' }
            ];
        } else if (this.storedPayrollAction === 'Cancel') {
            this.allowedActions = [
                { label: 'Cancel', value: 'Cancel' }
            ];
        } else {
            this.allowedActions = [
                { label: this.storedPayrollAction, value: this.storedPayrollAction }
            ];
        }
    }

    disableAllInteractions() {
        this.isPicklistDisabled = true;
        this.showConfirmButton = false;
        //this.showEditButton = false;
    }

    @wire(getPayrolls, { customerId: '$customerId', regionName: '$regionName', isAlburaqProd: '$isAlburaqProduct' })
    wiredPayrolls({ error, data }) {
        if (!this.hasRecordData) {
            console.log('Waiting for record data to load...');
            return;
        }

        if (data) {
            this.isLoading = true;

            try {
                console.log('Full data --->', JSON.stringify(data));
                const filtered = data.filter(p => p.status === 'Pending' || p.status === 'Approved');

                if (filtered.length === 0 && !this.isActioned) {
                    this.handleError('No payrolls to update have been returned');
                    return;
                }

                this.payrolls = filtered;
                this.payrollOptions = [
                    { label: 'None', value: '' },
                    ...filtered.map(p => ({
                        label: p.payrollRef + ' - ' + p.salaryMonth + ' - ' + p.reference + ' - ' + p.status,
                        value: p.reference
                    }))
                ];

                console.log('payrolls --->', JSON.stringify(this.payrolls));

                this.makerResult = data.makerResult || null;

                // If already actioned, load stored data
                if (this.isActioned) {
                    console.log('payrollOptions --->', JSON.stringify(this.payrollOptions));
                    this.selectedPayRollRef = this.storedPayrollReference;
                    console.log('selectedPayRollRef --->', this.selectedPayRollRef);
                    this.loadStoredPayrollData();
                }

            } catch (error) {
                console.log('Error 1 --->', JSON.stringify(error));
                if (!this.isActioned) {
                    this.handleError('Failed to process payrolls: ' + error.message);
                }
            } finally {
                this.isLoading = false;
            }
        } else if (error) {
            console.log('Error 2 --->', JSON.stringify(error));
            if (!this.isActioned) {
                this.handleError('Failed to fetch payrolls: ' + error.message);
            }
            this.isLoading = false;
        }
    }

    get isPicklistDisabledState() {
        return this.isPicklistDisabled || this.isLoading || this.isButtonsDisabled || this.isActioned;
    }

    get isActionComboboxDisabled() {
        console.log('isActioned --->', this.isActioned);
        console.log('disableCombobox --->', this.disableCombobox);
        console.log('final --->', (this.isActioned && this.disableCombobox));
        return this.isActioned && this.disableCombobox;
    }

    get isButtonsDisabled() {
        return (this.makerResult !== null && this.makerResult !== undefined && this.makerResult !== '') || this.isActioned;
    }

    get statusClass() {
        // Use appropriate data source based on action state
        if (this.isActioned) {
            return this.actionedPayrollData.status
                ? `status-${this.actionedPayrollData.status.toLowerCase()}`
                : '';
        } else {
            return this.selectedPayroll.status
                ? `status-${this.selectedPayroll.status.toLowerCase()}`
                : '';
        }
    }

    get isShowDetailWhenActioned() {
        return this.isActioned && this.showPayrollDetails && this.actionedPayrollData;
    }

    get isShowDetailWhenNotActioned() {
        return !this.isActioned && this.showPayrollDetails;
    }

    handleActionChange(event) {
        // Only allow action change if not actioned
        if (!this.isActioned) {
            this.actionValue = event.detail.value;

            // Show/Hide reject reason field based on selected action
            if (this.actionValue === 'Reject' || this.actionValue === 'Cancel') {
                this.showRejectReasonField = true;
                this.rejectReason = ''; // Clear previous reason
            } else {
                this.showRejectReasonField = false;
                this.rejectReason = ''; // Clear reason when not rejecting
            }

            // 🔥 FILTER DEPENDENCY VALUES
            if (this.actionValue === 'Cancel') {
                this.filteredDependencyList = this.getValuesByValidFor(2);
            } else if (this.actionValue === 'Reject') {
                this.filteredDependencyList = this.getValuesByValidFor(1);
            } else {
                this.filteredDependencyList = [];
            }

            console.log('Filtered Dependency List ===>', this.filteredDependencyList);
        }
    }

    getValuesByValidFor(code) {
        if (!this.cancelRejectReasons) {
            return [];
        }

        return this.cancelRejectReasons
            .filter(item => item.validFor && item.validFor.includes(code))
            .map(item => ({
                label: item.label,
                value: item.value
            }));
    }


    // NEW: Handle reject reason change
    handleRejectReasonChange(event) {
        this.rejectReason = event.target.value;
    }

    async handlePayrollSelection(event) {
        if (event.target.value != '') {
            // If already actioned, don't process selection
            if (this.isActioned) {
                return;
            }

            const ref = event.target.value;
            this.selectedPayRollRef = ref;

            this.actionValue = '';
            this.showActionCombobox = false;
            this.showRejectReasonField = false; // Reset reject reason field
            this.rejectReason = ''; // Clear reject reason

            if (!ref) {
                this.showPayrollDetails = false;
                this.updateButtonVisibility();
                return;
            }

            this.payrollDetail = this.payrolls.filter(x => x.reference == ref)[0];
            this.payrollstatus = this.payrolls.filter(x => x.reference == ref)[0].status;

            console.log('payrollDetail --->', JSON.stringify(this.payrollDetail));

            if (this.payrollstatus == 'Pending') {
                this.allowedActions = [
                    { label: 'Approve', value: 'Approve' },
                    { label: 'Reject', value: 'Reject' }
                ];
            } else if (this.payrollstatus == 'Approved') {
                this.allowedActions = [
                    { label: 'Cancel', value: 'Cancel' }
                ];
            }

            this.showActionCombobox = true;
            this.isLoading = true;

            try {
                const payrolls = await getPayrollDetailandSalaries({
                    customerId: this.customerId,
                    regionName: this.regionName,
                    payrollReference: ref,
                    recordId: this.recordId
                });

                const record = payrolls;

                if (!record) {
                    this.handleError('Payroll not found');
                    return;
                }

                this.selectedPayroll = { ...record };
                console.log('selectedPayroll --->', this.selectedPayroll);

                this.showPayrollDetails = true;
                this.updateButtonVisibility();

                if (this.selectedPayroll) {
                    await this.callCalculateFees();
                }
            }
            catch (error) {
                this.handleError('Unable to load payroll details: ' + error.message);
            } finally {
                this.isLoading = false;
            }
        } else {
            this.selectedPayRollRef = '';
            this.actionValue = '';
            this.showActionCombobox = false;
            this.showRejectReasonField = false;
            this.rejectReason = '';
            this.showPayrollDetails = false;
            this.updateButtonVisibility();
        }
    }

    async callCalculateFees() {
        try {
            console.log('Calling calculateFees...');

            const feesResponse = await calculateFees({
                recordId: this.recordId,
                regionName: this.regionName,
                payrollAmount: this.selectedPayroll.totalDebitAmount || 0,
                payrollCurrency: this.selectedPayroll.currencyValue || 'BHD',
                payrollDebitAccountIBAN: this.selectedPayroll.debitAccount || '',
                payrollNoOfSalaries: this.selectedPayroll.numberOfSalaries || '0',
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

                this.payrollDetail = {...this.payrollDetail, transactionFees: taxValue, vat: vatValue};
                //this.payrollDetail.transactionFees = taxValue;
                //this.payrollDetail.vat = vatValue;

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

    updateButtonVisibility() {
        // If already actioned, don't show any buttons
        if (this.isActioned) {
            this.showConfirmButton = false;
            this.showEditButton = false;

            // Ensure picklist is disabled
            this.isPicklistDisabled = true;
            return;
        }

        const canEditConfirm = !this.makerResult || this.makerResult === '' ||
            this.makerResult === null || this.makerResult === undefined;

        if (this.showPayrollDetails && canEditConfirm) {
            this.showConfirmButton = true;
            this.showEditButton = false;
            this.isPicklistDisabled = false;
        } else {
            this.showConfirmButton = false;
            this.showEditButton = false;
            this.isPicklistDisabled = false;
        }
    }

    async handleConfirm() {
        if (this.isActioned) {
            return;
        }

        if (!this.actionValue) {
            this.handleError('Please select an action before confirming.');
            return;
        }

        // Validate reject reason if action is Reject
        if (this.actionValue === 'Reject' && (!this.rejectReason || this.rejectReason.trim() === '')) {
            this.handleError('Please provide a rejection reason.');
            return;
        }

        // Validate reject reason if action is Cancel
        if (this.actionValue === 'Cancel' && (!this.rejectReason || this.rejectReason.trim() === '')) {
            this.handleError('Please provide a cancellation reason.');
            return;
        }

        this.isLoading = true;

        try {
            // Prepare payroll data with reject reason
            const payrollDataToSave = {
                ...this.payrollDetail,
                reason: (this.actionValue === 'Reject' || this.actionValue === 'Cancel') ?
                    this.rejectReason : this.selectedPayroll.reason || ''
            };

            await savePayrollTotal({
                recordId: this.recordId,
                totalAmount: this.selectedPayroll.totalDebt,
                actionStatus: this.actionValue,
                payrollData: payrollDataToSave, // Pass updated payroll data with reason
                selectedPayrollReference: this.selectedPayRollRef,
                CIF: this.customerId
            });

            /* this.actionValue === 'Approve' ? 'Approved' : 
                       this.actionValue === 'Reject' ? 'Rejected' : 
                       this.actionValue === 'Cancel' ? 'Cancelled' :  */
            // 🔥 FIX: Create complete actionedPayrollData BEFORE setting isActioned
            this.actionedPayrollData = {
                // From current selections
                action: this.actionValue,
                reason: (this.actionValue === 'Reject' || this.actionValue === 'Cancel') ?
                    this.rejectReason : this.payrollDetail.reason || '',
                status: this.payrollDetail.status,

                // From payrollDetail (API 1)
                debitAccount: this.payrollDetail.debitAccount,
                currencyValue: this.payrollDetail.currencyValue,
                transactionFees: this.payrollDetail.transactionFees,
                vat: this.payrollDetail.vat,
                totalDebitAmount: this.payrollDetail.totalDebitAmount,
                creationDate: this.payrollDetail.creationDate,

                // From selectedPayroll (API 2)
                salaryMonth: this.selectedPayroll.salaryMonth,
                paymentDate: this.selectedPayroll.paymentDate,
                employerName: this.selectedPayroll.employerName,
                employeeCount: this.selectedPayroll.employeeCount,
                payrollAmount: this.selectedPayroll.payrollAmount,
                totalDebt: this.selectedPayroll.totalDebt
            };

            // 🔥 CRITICAL: Manually update the actioned state for immediate UI response
            this.isActioned = true;
            this.disableCombobox = true;
            //this.showEditButton = true;
            this.storedPayrollAction = this.actionValue;
            this.storedPayrollReference = this.selectedPayRollRef;

            // 🔥 CRITICAL: Refresh the wired record data to get updated field values from database
            if (this.wiredRecordResult) {
                await refreshApex(this.wiredRecordResult);
            }

            // Now load the stored payroll data with the updated values
            await this.loadStoredPayrollData();

            // Disable all interactions
            this.disableAllInteractions();

            // Clear any error messages
            this.showError = false;
            this.errorMessage = '';

        } catch (error) {
            this.handleError('Failed to save: ' + error.message);
        } finally {
            this.isLoading = false;
        }
    }

    handleEdit() {
        if (!this.isButtonsDisabled) {
            this.isPicklistDisabled = false;
            this.showConfirmButton = true;
            this.showActionCombobox = true;
            this.showRejectReasonField = true;
            this.showEditButton = false;
            this.showConfirmButton = true;
        }
    }

    handleError(msg) {
        this.errorMessage = msg;
        this.showError = true;
        this.showPayrollDetails = false;
        this.payrollOptions = [];
        this.selectedPayroll = {};
        this.showConfirmButton = false;
        this.showEditButton = false;
        this.showActionCombobox = false;
        this.actionValue = '';
        this.showRejectReasonField = false;
        this.rejectReason = '';
    }

    get formattedPayrollAmount() {
        if (this.actionedPayrollData?.payrollAmount) {
            return Number(this.actionedPayrollData.payrollAmount).toFixed(3);
        }
        return '0.000';
    }

    get formattedPayrollDebitAmount() {
        if (this.actionedPayrollData?.totalDebt) {
            return Number(this.actionedPayrollData.totalDebt).toFixed(3);
        }
        return '0.000';
    }

    get formattedPayrollAmountNotActioned() {
        if (this.selectedPayroll?.payrollAmount) {
            return Number(this.selectedPayroll.payrollAmount).toFixed(3);
        }
        return '0.000';
    }

    get formattedPayrollDebitAmountNotActioned() {
        if (this.payrollDetail?.totalDebitAmount) {
            return Number(this.payrollDetail.totalDebitAmount).toFixed(3);
        }
        return '0.000';
    }
}
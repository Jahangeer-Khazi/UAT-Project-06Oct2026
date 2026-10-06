import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInitializationData from '@salesforce/apex/Lwc07_MultiBankLiabilityController.getInitializationData';
import saveMultiBankLiabilities from '@salesforce/apex/Lwc07_MultiBankLiabilityController.saveMultiBankLiabilities';

export default class Lwc07MultiBankLiability extends LightningElement {
    _recordId;
    _connected = false;

    loadingSpinner = false;

    multiBankLiabilities = [];
    originalMultiBankLiabilities = [];
    entityOptions = [];

    approvedBuyoutAmount = 0;
    persistedApprovedBuyoutAmount = 0;

    permissions = {
        isAdmin: false,
        isPreScreenerContext: false,
        isOperationsContext: false,
        canEditEntityOutstanding: false,
        canEditLiabilityId: false,
        canAddRow: false,
        canModifySelection: false,
        canModifyTable: false,
        showLiabilityId: true
    };

    editingEntityRowIds = [];
    editingOutstandingRowIds = [];
    editingLiabilityIdRowIds = [];
    editingChequeNumberRowIds = [];

    @api
    get recordId() {
        return this._recordId;
    }

    set recordId(value) {
        const changed = value !== this._recordId;
        this._recordId = value;

        if (this._connected && changed && value) {
            this.loadData();
        }
    }

    connectedCallback() {
        this._connected = true;
        if (this._recordId) {
            this.loadData();
        }
    }

    async loadData() {
        this.loadingSpinner = true;

        try {
            const result = await getInitializationData({ recordId: this.recordId });

            this.entityOptions = (result.entityOptions || []).map(option => ({
                label: option.label,
                value: option.value,
                paymentType: option.paymentType || ''
            }));

            this.permissions = {
                ...this.permissions,
                ...(result.permissions || {})
            };

            const rows = this.parseAndNormalizeRows(result.multiBankLiabilitiesJson);
            this.multiBankLiabilities = rows;
            this.originalMultiBankLiabilities = this.cloneRows(rows);

            // Keep the persisted field value only as a backend snapshot/reference.
            // Live UI calculations always come from multiBankLiabilities.
            this.persistedApprovedBuyoutAmount = this.toNumber(result.approvedBuyoutAmount) || 0;
            this.calculateApprovedBuyoutAmount();
            this.clearEditingState();
        } catch (error) {
            this.showToast('Error', this.getErrorMessage(error), 'error');
        } finally {
            this.loadingSpinner = false;
        }
    }

    parseAndNormalizeRows(jsonValue) {
        if (!jsonValue) {
            return [];
        }

        let parsed;
        try {
            parsed = JSON.parse(jsonValue);
        } catch (e) {
            throw new Error('The stored Multi-Bank Liability JSON is invalid.');
        }

        if (!Array.isArray(parsed)) {
            throw new Error('The stored Multi-Bank Liability data must be a JSON array.');
        }

        return parsed.map((row, index) => ({
            Id: String(row.Id ?? index + 1),
            selected: row.selected === undefined ? true : Boolean(row.selected),
            entity: row.entity ?? '',
            outstanding: this.normalizeOutstanding(row.outstanding),
            liabilityID: row.liabilityID ?? '',
            chequeNumber: row.chequeNumber ?? ''
        }));
    }

    get viewRows() {
        return this.multiBankLiabilities.map(row => {
            const isChequePayment = this.isChequeEntity(row.entity);

            return {
                ...row,
                isChequePayment,
                canEditChequeNumber: this.canEditLiabilityId && isChequePayment,
                isEditingEntity: this.editingEntityRowIds.includes(String(row.Id)),
                isEditingOutstanding: this.editingOutstandingRowIds.includes(String(row.Id)),
                isEditingLiabilityId: this.editingLiabilityIdRowIds.includes(String(row.Id)),
                isEditingChequeNumber:
                    this.canEditLiabilityId &&
                    isChequePayment &&
                    this.editingChequeNumberRowIds.includes(String(row.Id)),
                entityOptions: this.getAvailableEntityOptions(row.Id, row.entity)
            };
        });
    }

    get hasRows() {
        return this.multiBankLiabilities.length > 0;
    }

    get showLiabilityIdColumn() {
        return Boolean(this.permissions.showLiabilityId);
    }

    get canEditEntityOutstanding() {
        return Boolean(this.permissions.canEditEntityOutstanding);
    }

    get canEditLiabilityId() {
        return Boolean(this.permissions.canEditLiabilityId);
    }

    get canAddRow() {
        return Boolean(this.permissions.canAddRow);
    }

    get canModifyTable() {
        return Boolean(this.permissions.canModifyTable);
    }

    get disableSelection() {
        return this.loadingSpinner || !this.permissions.canModifySelection;
    }

    get emptyStateColspan() {
        return this.showLiabilityIdColumn ? 5 : 3;
    }

    get hasEditingCells() {
        return this.editingEntityRowIds.length > 0 ||
            this.editingOutstandingRowIds.length > 0 ||
            this.editingLiabilityIdRowIds.length > 0 ||
            this.editingChequeNumberRowIds.length > 0;
    }

    get isDirty() {
        return JSON.stringify(this.getSerializableRows(this.multiBankLiabilities)) !==
            JSON.stringify(this.getSerializableRows(this.originalMultiBankLiabilities));
    }

    get showGlobalActions() {
        // Selection/deselection is also a persisted JSON change, so it must
        // expose the same global Save/Cancel controls as cell edits and Add Row.
        return this.canModifyTable && (this.isDirty || this.hasEditingCells);
    }

    get disableSave() {
        return this.loadingSpinner || !this.isDirty;
    }

    get disableCancel() {
        return this.loadingSpinner;
    }

    handleEditEntity(event) {
        if (!this.canEditEntityOutstanding) {
            return;
        }
        this.addEditingRowId('entity', event.currentTarget.dataset.rowId);
    }

    handleEditOutstanding(event) {
        if (!this.canEditEntityOutstanding) {
            return;
        }
        this.addEditingRowId('outstanding', event.currentTarget.dataset.rowId);
    }

    handleEditLiabilityId(event) {
        if (!this.canEditLiabilityId) {
            return;
        }
        this.addEditingRowId('liabilityId', event.currentTarget.dataset.rowId);
    }

    handleEditChequeNumber(event) {
        const rowId = event.currentTarget.dataset.rowId;
        const row = this.multiBankLiabilities.find(
            item => String(item.Id) === String(rowId)
        );

        if (!row || !this.canEditLiabilityId || !this.isChequeEntity(row.entity)) {
            return;
        }

        this.addEditingRowId('chequeNumber', rowId);
    }

    handleEntityChange(event) {
        const rowId = event.currentTarget.dataset.rowId;
        const value = event.detail.value;
        const valueKey = this.normalizeEntityKey(value);

        // Defensive live check: even if another open combobox had stale options,
        // never allow the same Entity/Bank to be selected in two rows.
        const alreadyUsed = this.multiBankLiabilities.some(row =>
            String(row.Id) !== String(rowId) &&
            this.normalizeEntityKey(row.entity) === valueKey
        );

        if (alreadyUsed) {
            this.showToast('Error', `${value} is already used by another row.`, 'error');
            return;
        }

        this.updateRow(rowId, {
            entity: value,
            chequeNumber: this.isChequeEntity(value)
                ? this.multiBankLiabilities.find(row => String(row.Id) === String(rowId))?.chequeNumber || ''
                : ''
        });

        // viewRows derives the picklist options from the current working table,
        // so all other rows immediately exclude this newly selected entity.
    }

    handleOutstandingChange(event) {
        const rowId = event.currentTarget.dataset.rowId;
        const value = event.target.value;
        const outstanding = value === '' || value === null || value === undefined
            ? null
            : Number(value);

        this.updateRow(rowId, {
            outstanding: Number.isNaN(outstanding) ? null : outstanding
        });
        this.calculateApprovedBuyoutAmount();
    }

    handleLiabilityIdChange(event) {
        const rowId = event.currentTarget.dataset.rowId;
        this.updateRow(rowId, { liabilityID: event.target.value });
    }

    handleChequeNumberChange(event) {
        const rowId = event.currentTarget.dataset.rowId;
        this.updateRow(rowId, { chequeNumber: event.target.value });
    }

    handleSelectionChange(event) {
        if (!this.permissions.canModifySelection) {
            return;
        }

        const rowId = event.currentTarget.dataset.rowId;
        this.updateRow(rowId, { selected: event.target.checked });
        this.calculateApprovedBuyoutAmount();
    }

    handleAddRow() {
        if (!this.canAddRow) {
            return;
        }

        const availableOptions = this.getAvailableEntityOptions(null, null);
        if (availableOptions.length === 0) {
            this.showToast(
                'Information',
                'All active Entity/Bank values are already used in the table.',
                'info'
            );
            return;
        }

        const newId = this.getNextRowId();
        const newRow = {
            Id: newId,
            selected: false,
            entity: '',
            outstanding: null,
            liabilityID: '',
            chequeNumber: ''
        };

        this.multiBankLiabilities = [...this.multiBankLiabilities, newRow];

        // A new row starts directly in edit mode for the fields this context can edit.
        if (this.canEditEntityOutstanding) {
            this.addEditingRowId('entity', newId);
            this.addEditingRowId('outstanding', newId);
        }
        if (this.canEditLiabilityId) {
            this.addEditingRowId('liabilityId', newId);
        }

        this.calculateApprovedBuyoutAmount();
    }

    async handleSave() {
        if (!this.canModifyTable || !this.isDirty) {
            return;
        }

        if (!this.validateBeforeSave()) {
            return;
        }

        this.loadingSpinner = true;

        try {
            const liabilitiesJson = JSON.stringify(this.getSerializableRows(this.multiBankLiabilities));

            // Apex recalculates cx_ln_Approved_Buyout_Amount__c from this JSON.
            // The client total is deliberately not trusted as a save parameter.
            const result = await saveMultiBankLiabilities({
                recordId: this.recordId,
                liabilitiesJson
            });

            const savedRows = this.parseAndNormalizeRows(result.multiBankLiabilitiesJson);
            this.multiBankLiabilities = savedRows;
            this.originalMultiBankLiabilities = this.cloneRows(savedRows);
            this.persistedApprovedBuyoutAmount = this.toNumber(result.approvedBuyoutAmount) || 0;

            // Continue to derive the displayed value from the saved JSON.
            this.calculateApprovedBuyoutAmount();
            this.clearEditingState();

            this.showToast('Success', 'Multi-Bank liabilities updated successfully.', 'success');
        } catch (error) {
            this.showToast('Error', this.getErrorMessage(error), 'error');
        } finally {
            this.loadingSpinner = false;
        }
    }

    handleCancel() {
        this.multiBankLiabilities = this.cloneRows(this.originalMultiBankLiabilities);

        // Restore both snapshots from the last successful backend state.
        // Future UI changes will again recalculate the displayed amount from
        // the current working JSON. No backend call is made on Cancel.
        this.approvedBuyoutAmount = this.persistedApprovedBuyoutAmount;
        this.clearEditingState();
    }

    validateBeforeSave() {
        const entityKeys = new Set();

        for (let index = 0; index < this.multiBankLiabilities.length; index += 1) {
            const row = this.multiBankLiabilities[index];
            const displayRow = index + 1;
            const entity = (row.entity || '').trim();
            const entityKey = this.normalizeEntityKey(entity);

            if (entityKey) {
                if (entityKeys.has(entityKey)) {
                    this.showToast(
                        'Error',
                        `Entity/Bank must be unique. Duplicate value found on row ${displayRow}.`,
                        'error'
                    );
                    return false;
                }
                entityKeys.add(entityKey);
            }

            if (this.canEditEntityOutstanding) {
                if (!entity) {
                    this.showToast('Error', `Entity/Bank is required on row ${displayRow}.`, 'error');
                    return false;
                }

                if (row.outstanding === null || row.outstanding === undefined || row.outstanding === '') {
                    this.showToast('Error', `Outstanding Amount is required on row ${displayRow}.`, 'error');
                    return false;
                }

                const amount = Number(row.outstanding);
                if (Number.isNaN(amount) || amount < 0) {
                    this.showToast('Error', `Outstanding Amount must be zero or greater on row ${displayRow}.`, 'error');
                    return false;
                }
            }

            if (this.canEditLiabilityId && !(row.liabilityID || '').trim()) {
                this.showToast('Error', `Liability ID is required on row ${displayRow}.`, 'error');
                return false;
            }

            if (
                this.canEditLiabilityId &&
                this.isChequeEntity(entity) &&
                !(row.chequeNumber || '').trim()
            ) {
                this.showToast(
                    'Error',
                    `Cheque Number is required on row ${displayRow}.`,
                    'error'
                );
                return false;
            }
        }

        return true;
    }

    getAvailableEntityOptions(currentRowId, currentEntity) {
        const currentId = currentRowId === null || currentRowId === undefined
            ? null
            : String(currentRowId);

        const usedEntities = new Set(
            this.multiBankLiabilities
                .filter(row => currentId === null || String(row.Id) !== currentId)
                .map(row => this.normalizeEntityKey(row.entity))
                .filter(Boolean)
        );

        const options = this.entityOptions.filter(option => {
            const optionKey = this.normalizeEntityKey(option.value);
            return !usedEntities.has(optionKey) || option.value === currentEntity;
        });

        // Preserve a legacy/current value even if that metadata entry was later deactivated.
        if (currentEntity && !options.some(option => option.value === currentEntity)) {
            options.unshift({
                label: `${currentEntity} (Current value)`,
                value: currentEntity
            });
        }

        return options;
    }

    updateRow(rowId, changes) {
        const id = String(rowId);
        this.multiBankLiabilities = this.multiBankLiabilities.map(row =>
            String(row.Id) === id
                ? { ...row, ...changes }
                : row
        );
    }

    addEditingRowId(type, rowId) {
        const id = String(rowId);

        if (type === 'entity' && !this.editingEntityRowIds.includes(id)) {
            this.editingEntityRowIds = [...this.editingEntityRowIds, id];
        } else if (type === 'outstanding' && !this.editingOutstandingRowIds.includes(id)) {
            this.editingOutstandingRowIds = [...this.editingOutstandingRowIds, id];
        } else if (type === 'liabilityId' && !this.editingLiabilityIdRowIds.includes(id)) {
            this.editingLiabilityIdRowIds = [...this.editingLiabilityIdRowIds, id];
        } else if (type === 'chequeNumber' && !this.editingChequeNumberRowIds.includes(id)) {
            this.editingChequeNumberRowIds = [...this.editingChequeNumberRowIds, id];
        }
    }

    clearEditingState() {
        this.editingEntityRowIds = [];
        this.editingOutstandingRowIds = [];
        this.editingLiabilityIdRowIds = [];
        this.editingChequeNumberRowIds = [];
    }

    calculateApprovedBuyoutAmount() {
        this.approvedBuyoutAmount = this.multiBankLiabilities
            .filter(row => row.selected)
            .reduce((sum, row) => sum + (this.toNumber(row.outstanding) || 0), 0);
    }

    getSerializableRows(rows) {
        return rows.map(row => ({
            Id: String(row.Id),
            selected: Boolean(row.selected),
            entity: row.entity || '',
            outstanding: row.outstanding === null || row.outstanding === undefined || row.outstanding === ''
                ? null
                : Number(row.outstanding),
            liabilityID: row.liabilityID || '',
            chequeNumber: row.chequeNumber || ''
        }));
    }

    cloneRows(rows) {
        return JSON.parse(JSON.stringify(this.getSerializableRows(rows)));
    }

    getNextRowId() {
        const maxNumericId = this.multiBankLiabilities.reduce((maxId, row) => {
            const value = String(row.Id || '');
            if (!/^\d+$/.test(value)) {
                return maxId;
            }
            return Math.max(maxId, Number(value));
        }, 0);

        return String(maxNumericId + 1);
    }

    normalizeOutstanding(value) {
        if (value === null || value === undefined || value === '') {
            return null;
        }
        const numberValue = Number(value);
        return Number.isNaN(numberValue) ? null : numberValue;
    }

    toNumber(value) {
        if (value === null || value === undefined || value === '') {
            return null;
        }
        const numberValue = Number(value);
        return Number.isNaN(numberValue) ? null : numberValue;
    }

    isChequeEntity(entity) {
        const entityKey = this.normalizeEntityKey(entity);
        const option = this.entityOptions.find(
            item => this.normalizeEntityKey(item.value) === entityKey
        );

        return (option?.paymentType || '').trim().toLowerCase() === 'cheque';
    }

    normalizeEntityKey(value) {
        return (value || '').trim().toLowerCase();
    }

    getErrorMessage(error) {
        return error?.body?.message || error?.message || 'An unexpected error occurred.';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant, mode: 'dismissible' }));
    }
}
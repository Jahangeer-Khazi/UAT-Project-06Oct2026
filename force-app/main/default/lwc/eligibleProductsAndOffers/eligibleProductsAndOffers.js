import { LightningElement, api, track } from 'lwc';
import createCases from '@salesforce/apex/EligibleProductsAndOffersController.createCases';
import updateProductDecisions from '@salesforce/apex/EligibleProductsAndOffersController.updateProductDecisions';
import getNBOData from '@salesforce/apex/EligibleProductsAndOffersController.getNBOData';

export default class EligibleProductsAndOffers extends LightningElement {
    @api recordId;
    @track isShowModal = true;
    @track isApplyDisabled = true;
    @track isLoading = true;
    @track isProcessing = false;
    @track loadingMessage = 'Loading eligible products and offers...';
    @track showSummary = false;

    // ✅ NEW: inline error surface so failures are ALWAYS visible
    //    even if the parent doesn't wire up the `onshowtoast` handler.
    @track inlineError = '';

    @track yesCount = 0;
    @track noCount = 0;
    @track products = [];
    @track offers = [];

    // ===================== GETTERS =====================
    get activeProducts() {
        return this.products.filter(p => !p.isActioned);
    }

    get activeOffers() {
        return this.offers.filter(o => !o.isActioned);
    }

    get hasNoProducts() {
        return this.activeProducts.length === 0;
    }

    get hasNoOffers() {
        return this.activeOffers.length === 0;
    }

    get productCountDisplay() {
        const count = this.activeProducts.length;
        return count + ' ' + (count === 1 ? 'Product' : 'Products');
    }

    get offerCountDisplay() {
        const count = this.activeOffers.length;
        return count + ' ' + (count === 1 ? 'Offer' : 'Offers');
    }

    get hasYesSelections() {
        return this.yesCount > 0;
    }

    get hasNoSelections() {
        return this.noCount > 0;
    }

    get hasAnySelections() {
        return this.hasYesSelections || this.hasNoSelections;
    }

    // ✅ NEW getter used by the template
    get hasInlineError() {
        return !!(this.inlineError && this.inlineError.length > 0);
    }

    // ===================== PUBLIC API =====================
    @api
    openModal() {
        this.isShowModal = true;
        this.isLoading = true;
        this.isProcessing = false;
        this.showSummary = false;
        this.inlineError = '';           // ✅ clear stale error
        this.yesCount = 0;
        this.noCount = 0;
        this.resetSelections();
        this.fetchNBOData();
    }

    @api
    closeModal() {
        this.hideModalBox();
    }

    // ===================== MODAL CONTROL =====================
    hideModalBox() {
        if (this.isProcessing) return;
        this.isShowModal = false;
        const closeEvent = new CustomEvent('modalclosed', {
            detail: { isClosed: true }
        });
        this.dispatchEvent(closeEvent);
    }

    // ===================== DATA FETCH =====================
    fetchNBOData() {
        this.isLoading = true;
        this.loadingMessage = 'Fetching eligible products and offers...';

        if (!this.recordId) {
            this.isLoading = false;
            this.showToast('Error', 'Account ID is missing. Please refresh and try again.', 'error');
            return;
        }

        getNBOData({ accountId: this.recordId })
            .then(result => {
                this.isLoading = false;

                const rawProducts = (result && result.products) ? result.products : [];
                const rawOffers = (result && result.offers) ? result.offers : [];

                this.products = rawProducts.map((p, index) => ({
                    id: p.id,
                    name: p.name,
                    customerInterest: null,
                    isActioned: false,
                    radioName: 'product-' + (index + 1),
                    yesId: 'product-' + (index + 1) + '-yes',
                    noId: 'product-' + (index + 1) + '-no'
                }));

                this.offers = rawOffers.map((o, index) => ({
                    id: o.id,
                    name: o.name,
                    customerInterest: null,
                    isActioned: false,
                    radioName: 'offer-' + (index + 1),
                    yesId: 'offer-' + (index + 1) + '-yes',
                    noId: 'offer-' + (index + 1) + '-no'
                }));

                this.recalculateCounts();
                this.updateApplyButton();

                const totalItems = this.activeProducts.length + this.activeOffers.length;
                this.showToast(
                    'Data Loaded',
                    'Found ' + totalItems + ' eligible items (' +
                        this.activeProducts.length + ' products, ' +
                        this.activeOffers.length + ' offers)',
                    'success'
                );
            })
            .catch(error => {
                this.isLoading = false;
                console.error('Error fetching NBO data:', error);
                const msg = error.body ? error.body.message : error.message;
                this.inlineError = msg;
                this.showToast('Error', 'Failed to load eligible products and offers: ' + msg, 'error');
            });
    }

    // ===================== SELECTION HELPERS =====================
    resetSelections() {
        this.products = this.products.map(p => ({
            ...p,
            customerInterest: null,
            isActioned: false
        }));
        this.offers = this.offers.map(o => ({
            ...o,
            customerInterest: null,
            isActioned: false
        }));
        this.isApplyDisabled = true;
        this.yesCount = 0;
        this.noCount = 0;
    }

    handleRadioChange(event) {
        if (this.isProcessing) return;

        const itemId = event.target.dataset.id;
        const type = event.target.dataset.type;
        const value = event.target.value;

        if (type === 'product') {
            const idx = this.products.findIndex(p => p.id === itemId && !p.isActioned);
            if (idx < 0) return;
            if (this.products[idx].customerInterest === value) return;

            this.products = this.products.map((p, i) =>
                i === idx ? { ...p, customerInterest: value } : p
            );
        } else if (type === 'offer') {
            const idx = this.offers.findIndex(o => o.id === itemId && !o.isActioned);
            if (idx < 0) return;
            if (this.offers[idx].customerInterest === value) return;

            this.offers = this.offers.map((o, i) =>
                i === idx ? { ...o, customerInterest: value } : o
            );
        }

        this.recalculateCounts();
        this.updateApplyButton();
        this.showSummary = this.hasAnySelections;
    }

    recalculateCounts() {
        this.yesCount =
            this.products.filter(p => p.customerInterest === 'yes' && !p.isActioned).length +
            this.offers.filter(o => o.customerInterest === 'yes' && !o.isActioned).length;

        this.noCount =
            this.products.filter(p => p.customerInterest === 'no' && !p.isActioned).length +
            this.offers.filter(o => o.customerInterest === 'no' && !o.isActioned).length;
    }

    updateApplyButton() {
        const hasSelection =
            this.products.some(p => p.customerInterest && !p.isActioned) ||
            this.offers.some(o => o.customerInterest && !o.isActioned);
        this.isApplyDisabled = !hasSelection;
    }

    // ===================== APPLY =====================
    async handleApply() {
        if (this.isProcessing) return;

        const selectedYesProducts = this.products.filter(p => p.customerInterest === 'yes' && !p.isActioned);
        const selectedNoProducts  = this.products.filter(p => p.customerInterest === 'no'  && !p.isActioned);
        const selectedYesOffers   = this.offers.filter(o => o.customerInterest === 'yes' && !o.isActioned);
        const selectedNoOffers    = this.offers.filter(o => o.customerInterest === 'no'  && !o.isActioned);

        if (!this.hasAnySelections) {
            this.showToast('No Selection', 'Please select Yes or No for at least one product or offer', 'warning');
            return;
        }

        this.isProcessing = true;
        this.isApplyDisabled = true;
        this.inlineError = '';           // ✅ clear stale error at start

        const successMessages = [];
        const errorMessages = [];

        try {
            // --- "No" Products ---
            if (selectedNoProducts.length > 0) {
                const result = await this.handleItemUpdate(selectedNoProducts, 'Product');
                if (result.success) {
                    successMessages.push(result.message);
                    this.markItemsAsActioned(selectedNoProducts);
                } else {
                    errorMessages.push(result.message);
                }
            }

            // --- "Yes" Products ---
            if (selectedYesProducts.length > 0) {
                const updateResult = await this.handleItemUpdate(selectedYesProducts, 'Product');
                if (updateResult.success) {
                    const caseResult = await this.handleCaseCreation(selectedYesProducts, []);
                    if (caseResult.success) {
                        successMessages.push(caseResult.message);
                        this.markItemsAsActioned(selectedYesProducts);
                    } else {
                        errorMessages.push(caseResult.message);
                    }
                } else {
                    errorMessages.push(updateResult.message);
                }
            }

            // --- "No" Offers ---
            if (selectedNoOffers.length > 0) {
                const result = await this.handleItemUpdate(selectedNoOffers, 'Offer');
                if (result.success) {
                    successMessages.push(result.message);
                    this.markItemsAsActioned(selectedNoOffers);
                } else {
                    errorMessages.push(result.message);
                }
            }

            // --- "Yes" Offers ---
            if (selectedYesOffers.length > 0) {
                const updateResult = await this.handleItemUpdate(selectedYesOffers, 'Offer');
                if (updateResult.success) {
                    const caseResult = await this.handleCaseCreation([], selectedYesOffers);
                    if (caseResult.success) {
                        successMessages.push(caseResult.message);
                        this.markItemsAsActioned(selectedYesOffers);
                    } else {
                        errorMessages.push(caseResult.message);
                    }
                } else {
                    errorMessages.push(updateResult.message);
                }
            }

            this.products = [...this.products];
            this.offers = [...this.offers];

            this.recalculateCounts();
            this.updateApplyButton();
            this.showSummary = false;
            this.isProcessing = false;

            const remainingItems = this.activeProducts.length + this.activeOffers.length;

            if (remainingItems === 0 && errorMessages.length === 0) {
                // All items actioned → success + auto-close
                let finalMessage = 'All items processed successfully.';
                if (successMessages.length > 0) {
                    finalMessage = successMessages.join(' | ');
                }
                this.showToast('Success', finalMessage, 'success');

                setTimeout(() => {
                    this.hideModalBox();
                }, 2000);
            } else {
                if (errorMessages.length > 0) {
                    const msg = errorMessages.join(' | ');

                    // ✅ Always show inside the modal, regardless of the parent toast wiring
                    this.inlineError = msg;

                    // Also dispatch the toast event for parents that listen
                    this.showToast('Error', msg, 'error');
                    console.error('[handleApply] Errors:', msg);
                } else {
                    this.showToast(
                        'Remaining Items',
                        remainingItems + ' items still pending for review',
                        'info'
                    );
                }
            }

        } catch (error) {
            console.error('Error in handleApply:', error);
            const msg = error.body ? error.body.message : error.message;
            this.inlineError = msg;
            this.showToast('Error', 'An unexpected error occurred: ' + msg, 'error');
            this.isProcessing = false;
            this.updateApplyButton();
        }
    }

    // ===================== APEX INTERACTIONS =====================
    handleItemUpdate(items, itemType) {
        return new Promise((resolve) => {
            if (!items || items.length === 0) {
                resolve({ success: true, message: 'No ' + itemType + 's to update' });
                return;
            }
            const selectedItems = items.map(item => ({
                id: item.id,
                name: item.name,
                itemType: itemType,
                customerInterest: item.customerInterest
            }));

            updateProductDecisions({ accountId: this.recordId, selectedItems: selectedItems })
                .then(result => resolve(result))
                .catch(error => {
                    resolve({
                        success: false,
                        message: 'Failed to update ' + itemType + 's: ' +
                            (error.body ? error.body.message : error.message)
                    });
                });
        });
    }

    handleCaseCreation(yesProducts, yesOffers) {
        return new Promise((resolve) => {
            const selectedItems = [];

            yesProducts.forEach(p => {
                selectedItems.push({
                    id: p.id,
                    name: p.name,
                    itemType: 'Product',
                    customerInterest: 'yes'
                });
            });

            yesOffers.forEach(o => {
                selectedItems.push({
                    id: o.id,
                    name: o.name,
                    itemType: 'Offer',
                    customerInterest: 'yes'
                });
            });

            if (selectedItems.length === 0) {
                resolve({ success: true, message: 'No items to create cases for' });
                return;
            }

            createCases({ accountId: this.recordId, selectedItems: selectedItems })
                .then(result => {
                    if (result.success) {
                        const caseEvent = new CustomEvent('casescreated', {
                            detail: {
                                products: yesProducts,
                                offers: yesOffers,
                                accountId: this.recordId,
                                totalCases: result.caseCount || selectedItems.length,
                                cases: result.cases || [],
                                timestamp: new Date().toISOString()
                            }
                        });
                        this.dispatchEvent(caseEvent);
                    }
                    resolve(result);
                })
                .catch(error => {
                    resolve({
                        success: false,
                        message: 'Failed to create cases: ' +
                            (error.body ? error.body.message : error.message)
                    });
                });
        });
    }

    // ============================================================
    // Immutable update: new array + new object references.
    // ============================================================
    markItemsAsActioned(items) {
        if (!items || items.length === 0) return;

        const actionedIds = new Set(items.map(i => i.id));

        this.products = this.products.map(p => {
            if (actionedIds.has(p.id) && !p.isActioned) {
                return { ...p, isActioned: true, customerInterest: null };
            }
            return p;
        });

        this.offers = this.offers.map(o => {
            if (actionedIds.has(o.id) && !o.isActioned) {
                return { ...o, isActioned: true, customerInterest: null };
            }
            return o;
        });

        console.log('[markItemsAsActioned] Actioned IDs:', Array.from(actionedIds));
        console.log('[markItemsAsActioned] Remaining products:', this.products.filter(p => !p.isActioned).length);
        console.log('[markItemsAsActioned] Remaining offers:', this.offers.filter(o => !o.isActioned).length);
    }

    // ===================== TOAST =====================
    showToast(title, message, variant) {
        console.log('[showToast]', title, message, variant);   // ✅ debug — remove later if noisy
        const toastEvent = new CustomEvent('showtoast', {
            detail: {
                title,
                message,
                variant,
                duration: variant === 'error' ? 5000 : 3000
            }
        });
        this.dispatchEvent(toastEvent);
    }
}
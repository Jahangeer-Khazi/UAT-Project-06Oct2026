import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getMetalAccounts from '@salesforce/apex/MetalAccountController.getMetalAccounts';
import getMetalTransactions from '@salesforce/apex/MetalAccountController.getMetalTransactions';
import getMetalStatements from '@salesforce/apex/MetalAccountController.getMetalStatements';
import getUserSettings from '@salesforce/apex/MetalAccountController.getUserSettings';
import getAccountStatementDetails from '@salesforce/apex/LTNG006_StampedStatementsController.getAccountStatementDetails';
import Id from '@salesforce/user/Id';
import getChartData from '@salesforce/apex/ChartDataController.getChartData';
import getPortfolioOverview from '@salesforce/apex/ChartDataController.getPortfolioOverview';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Field API Names
const REGION_FLAG_FIELD = 'Account.Region_Flag__c';
const CIF_FIELD = 'Account.CIF__pc';
const X_CANARY_FIELD = 'Account.x_canary__pc';
const SEGMENT_FIELD = 'Account.Segment__pc';

const FIELDS = [REGION_FLAG_FIELD, CIF_FIELD, X_CANARY_FIELD, SEGMENT_FIELD];

export default class SilverAccountDetails extends LightningElement {
    @api recordId;
    @track isLoading = false;

    // Account data from LDS
    @track regionName = 'Bahrain';
    @track customerId = null;
    @track xCanary = 'cbs';
    @track segment = 'Premium';

    // Loading states
    @track isLoadingLDS = true;
    @track ldsError = null;

    // Account data
    @track silverAccountExists = true;
    @track isLoadingAccount = false;
    @track accountError = null;
    @track silverAccount = {
        accountNumber: '—',
        status: '—',
        statusClass: 'status-inactive',
        createdDate: '—',
        closureDate: '—',
        availableBalance: '—',
        holdBalance: '—',
        bookBalance: '—',
        fiatEquivalent: null
    };

    // Transactions
    @track isLoadingTransactions = false;
    @track transactionsError = null;
    @track originalTransactions = [];
    @track transactions = [];

    // Statements
    @track isLoadingStatements = false;
    @track statementsError = null;
    @track statements = [];
    @track showStatements = true;

    // Pagination
    @track totalRecords = 0;
    @track currentPage = 1;
    @track totalPages = 0;

    // Filters
    @track searchTerm = '';
    @track statusFilter = 'all';
    @track typeFilter = 'all';
    @track amountFrom = null;
    @track amountTo = null;
    @track dateFrom = null;
    @track dateTo = null;

    // API Parameters - SILVER (XAG)
    metalCurrency = 'XAG';
    pageNumber = 1;
    pageSize = 50;
    fromAmount = null;
    toAmount = null;
    fromDate = null;
    toDate = null;
    tradeType = 'all';

    accountId = null;
    silverAccountData = null;

    // User settings
    @track showTransactionsAndStatements = false;
    @track isLoadingSettings = true;
    @track settingsError = null;
    @track showStatementsTable = false;
    @track userId = Id;

    // Hero / Price Movement
    @track selectedDuration = '5d';
    @track transferType = 'buy';
    @track isPriceLoading = false;
    @track hasPriceData = false;

    // Raw numeric values
    currentPrice = null;
    change = null;
    changePercent = null;

    // Formatted display strings
    @track changeValueDisplay = '—';
    @track changePercentDisplay = '—';
    @track changeDirection = 'neutral';

    @track buttonClass5D = '';
    @track buttonClass1M = '';
    @track buttonClass3M = '';
    @track buttonClass6M = '';
    @track buttonClassYTD = '';
    @track buttonClass1Y = '';

    @track summary = {
        totalPL: 0,
        unrealizedPL: 0,
        realizedPL: 0,
        averageCost: 0,
        totalPLClass: '',
        unrealizedPLClass: '',
        realizedPLClass: '',
        averageCostClass: 'summary-value'
    };

    initialDataLoaded = false;

    // ==================== GETTERS ====================
    get accountSectionLabel() {
        return 'Silver Account Details';
    }

    get displaySilverAccount() {
        if (this.showTransactionsAndStatements) return this.silverAccount;

        return {
            accountNumber: this.silverAccount.accountNumber,
            status: this.silverAccount.status,
            statusClass: 'status-inactive',
            createdDate: this.silverAccount.createdDate,
            closureDate: this.silverAccount.closureDate,
            availableBalance: '',
            holdBalance: '',
            bookBalance: '',
            fiatEquivalent: ''
        };
    }

    get isSellMode() {
        return this.transferType === 'sell';
    }

    // Hide pill icon when there is no real movement
    get isNeutral() {
        return this.changeDirection === 'neutral';
    }

    get heroClass() {
        return `hero-card hero-${this.changeDirection}`;
    }

    get changeArrowIcon() {
        if (this.changeDirection === 'positive') return 'utility:arrowup';
        if (this.changeDirection === 'negative') return 'utility:arrowdown';
        return 'utility:dash';
    }

    get investedAmount() {
        const availableBalance = parseFloat(
            String(this.displaySilverAccount?.availableBalance || '').replace(/,/g, '')
        );

        const averageCost = parseFloat(
            String(this.summary?.averageCost || '').replace(/,/g, '')
        );

        if (isNaN(availableBalance) || isNaN(averageCost)) {
            return null;
        }

        const result = availableBalance * averageCost;

        return `BHD ${result.toLocaleString(undefined, {
            minimumFractionDigits: 3,
            maximumFractionDigits: 3
        })}`;
    }

    // ==================== LIFECYCLE ====================
    connectedCallback() {
        if (!this.recordId) {
            this.showErrorToast('Account ID Required', 'Account recordId is required');
            this.silverAccountExists = false;
            this.isLoadingLDS = false;
        }
    }

    // ==================== WIRE ====================
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredAccount({ error, data }) {
        if (data) {
            this.isLoadingLDS = false;
            this.ldsError = null;

            this.regionName = getFieldValue(data, REGION_FLAG_FIELD) || 'Bahrain';
            this.customerId = getFieldValue(data, CIF_FIELD);
            this.xCanary    = getFieldValue(data, X_CANARY_FIELD) || 'cbs';
            this.segment    = getFieldValue(data, SEGMENT_FIELD) || 'Premium';

            if (!this.customerId) {
                this.showErrorToast('Missing CIF', 'CIF (Customer ID) is not set on this Account');
                this.silverAccountExists = false;
                this.isLoadingLDS = false;
                return;
            }

            this.tryFetchInitialData();
            this.loadUserSettings();

        } else if (error) {
            this.isLoadingLDS = false;
            this.ldsError = error.body?.message || error.message || 'Failed to load Account data';
            this.showErrorToast('Account Load Error', this.ldsError);
            this.silverAccountExists = false;
        }
    }

    tryFetchInitialData() {
        if (!this.segment) return;
        if (!this.customerId) return;
        if (this.initialDataLoaded) return;
        this.initialDataLoaded = true;
        this.updateButtonClasses(this.selectedDuration);
        this.fetchData(this.selectedDuration);
    }

    // ==================== USER SETTINGS ====================
    loadUserSettings() {
        this.isLoadingSettings = true;
        this.settingsError = null;

        getUserSettings({ userId: this.userId, customerId: this.recordId })
            .then(result => {
                if (result && result.success === true) {
                    this.processUserSettings(result);
                } else if (result && result.success === false) {
                    const errorMsg = result.message || 'Failed to load user settings';
                    this.settingsError = errorMsg;
                    this.showErrorToast('Settings Error', errorMsg);
                    this.showTransactionsAndStatements = true;
                } else {
                    this.showTransactionsAndStatements = true;
                }

                this.loadAccountDetails();
                this.loadTransactions();
                this.loadStatements();
            })
            .catch(error => {
                console.error('Error loading user settings:', error);
                this.settingsError = error.message || 'Failed to load user settings';
                this.showTransactionsAndStatements = true;
                this.loadAccountDetails();
                this.loadTransactions();
                this.loadStatements();
            })
            .finally(() => {
                this.isLoadingSettings = false;
            });
    }

    processUserSettings(apiData) {
        let settings = null;

        if (apiData.data && apiData.data.settings) settings = apiData.data.settings;
        else if (apiData.settings) settings = apiData.settings;
        else if (apiData.data) settings = apiData.data;
        else settings = apiData;

        if (settings) {
            const viewStaffData = settings['viewStaffData'] || false;
            const viewStaffDataJordan = settings['viewStaffDataJordan'] || false;
            this.showTransactionsAndStatements = viewStaffData || viewStaffDataJordan;
        } else {
            this.showTransactionsAndStatements = true;
        }
    }

    // ==================== ACCOUNT ====================
    loadAccountDetails() {
        if (!this.customerId) {
            this.accountError = 'Customer ID (CIF) is required';
            this.silverAccountExists = false;
            return;
        }

        this.isLoadingAccount = true;
        this.accountError = null;

        getMetalAccounts({
            metalType: 'Silver',
            customerId: this.customerId,
            regionName: this.regionName || '',
            xCanary: this.xCanary,
            segment: this.segment
        })
        .then(result => {
            if (result && result.success === true) {
                this.processAccountResponse(result);
            } else if (result && result.success === false) {
                const errorMsg = result.message || result.meta?.message || 'Failed to load account details';
                this.accountError = 'We are unable to fetch the data at the moment. Please try again later.';
                this.silverAccountExists = false;
                this.showErrorToast('Account Error', errorMsg);
            } else {
                if (result && result.data && result.data.accounts && Array.isArray(result.data.accounts)) {
                    this.processAccountResponse(result);
                } else if (result && result.accounts && Array.isArray(result.accounts)) {
                    this.processAccountResponse(result);
                } else {
                    this.accountError = 'No silver account found for this customer';
                    this.silverAccountExists = false;
                }
            }
        })
        .catch(error => {
            console.error('Account API error:', error);
            const errorMsg = error.body?.message || error.message || 'Failed to load account details';
            this.accountError = 'We are unable to fetch the data at the moment. Please try again later.';
            this.silverAccountExists = false;
            this.showErrorToast('API Error', errorMsg);
        })
        .finally(() => {
            this.isLoadingAccount = false;
        });
    }

    processAccountResponse(apiData) {
        let accountsList = [];

        if (apiData.data && apiData.data.accounts && Array.isArray(apiData.data.accounts)) {
            accountsList = apiData.data.accounts;
        } else if (apiData.accounts && Array.isArray(apiData.accounts)) {
            accountsList = apiData.accounts;
        }

        if (accountsList.length > 0) {
            const matchedAccount = accountsList.find(acc => acc.metalCurrency === 'XAG');

            if (matchedAccount) {
                this.silverAccountData = matchedAccount;

                const status = matchedAccount.status || 'ACTIVE';
                const metalAmount = parseFloat(matchedAccount.metalAmount) || 0;
                const fiatBalance = this.parseFiatBalance(matchedAccount.fiatBalance);
                const linkedCurrency = matchedAccount.linkedAccountCurrency || 'BHD';
                const metalCreatedDate = matchedAccount.accountCreatedDate
                    ? matchedAccount.accountCreatedDate.split('T')[0] : '';

                this.silverAccount = {
                    accountNumber: `XAG-${this.customerId}`,
                    status: this.formatStatus(status),
                    statusClass: this.getStatusClass(status),
                    createdDate: metalCreatedDate,
                    closureDate: '—',
                    availableBalance: `${metalAmount.toLocaleString(undefined, { minimumFractionDigits: 3, maximumFractionDigits: 3 })} XAG`,
                    holdBalance: 'XAG 0.000',
                    bookBalance: `${metalAmount.toLocaleString(undefined, { minimumFractionDigits: 3, maximumFractionDigits: 3 })} XAG`,
                    fiatEquivalent: fiatBalance > 0
                        ? `${linkedCurrency} ${fiatBalance.toLocaleString(undefined, { minimumFractionDigits: 3, maximumFractionDigits: 3 })}`
                        : null
                };

                this.accountId = `XAG-${this.customerId}`;
                this.silverAccountExists = true;
            } else {
                this.silverAccountExists = false;
                this.accountError = 'No Silver account (XAG) found for this customer';
            }
        } else {
            this.silverAccountExists = false;
            this.accountError = 'No metal accounts found for this customer';
        }
    }

    parseFiatBalance(fiatBalanceStr) {
        if (!fiatBalanceStr) return 0;
        const cleaned = fiatBalanceStr.replace(/,/g, '');
        const numValue = parseFloat(cleaned);
        return isNaN(numValue) ? 0 : numValue;
    }

    formatStatus(status) {
        if (!status) return 'Inactive';
        const s = status.toLowerCase();
        if (s === 'active') return 'Active';
        if (s === 'inactive') return 'Inactive';
        if (s === 'closed') return 'Closed';
        if (s === 'suspended') return 'Suspended';
        return status;
    }

    getStatusClass(status) {
        if (!status) return 'status-inactive';
        const s = status.toLowerCase();
        if (s === 'active') return 'status-active';
        if (s === 'inactive') return 'status-inactive';
        if (s === 'closed') return 'status-closed';
        if (s === 'suspended') return 'status-suspended';
        return 'status-inactive';
    }

    retryLoadAccount() {
        this.loadAccountDetails();
    }

    // ==================== TRANSACTIONS ====================
    loadTransactions() {
        if (!this.showTransactionsAndStatements) return;
        if (!this.customerId) {
            this.transactionsError = 'Customer ID (CIF) is required';
            return;
        }

        this.isLoadingTransactions = true;
        this.transactionsError = null;

        const params = this.buildTransactionParams();

        getMetalTransactions(params)
            .then(result => {
                if (result && result.success === true) {
                    this.processTransactionsResponse(result);
                } else if (result && result.success === false) {
                    const errorMsg = result.message || result.meta?.message || 'Failed to load transactions';
                    this.transactionsError = errorMsg;
                    this.showErrorToast('Transactions Error', errorMsg);
                    this.originalTransactions = [];
                    this.transactions = [];
                } else if (result && result.data && result.data.trades && Array.isArray(result.data.trades)) {
                    this.processTransactionsResponse(result);
                } else if (result && result.trades && Array.isArray(result.trades)) {
                    this.processTransactionsResponse(result);
                } else {
                    this.originalTransactions = [];
                    this.transactions = [];
                    this.transactionsError = null;
                }
            })
            .catch(error => {
                console.error('Transactions API error:', error);
                const errorMsg = error.body?.message || error.message || 'Failed to load transactions';
                this.transactionsError = errorMsg;
                this.showErrorToast('API Error', errorMsg);
                this.originalTransactions = [];
                this.transactions = [];
            })
            .finally(() => {
                this.isLoadingTransactions = false;
            });
    }

    buildTransactionParams() {
        const params = {};

        if (this.metalCurrency) params.metalCurrency = this.metalCurrency;
        if (this.pageNumber) params.pageNumber = this.pageNumber;
        if (this.pageSize) params.pageSize = this.pageSize;
        if (this.fromAmount) params.fromAmount = this.fromAmount;
        if (this.toAmount) params.toAmount = this.toAmount;
        if (this.fromDate) params.fromDate = this.fromDate;
        if (this.toDate) params.toDate = this.toDate;
        if (this.tradeType && this.tradeType !== 'all') params.tradeType = this.tradeType;
        if (this.customerId) params.customerId = this.customerId;
        if (this.regionName) params.regionName = this.regionName;
        if (this.xCanary) params.xCanary = this.xCanary;

        return params;
    }

    processTransactionsResponse(apiData) {
        let transactionsList = [];
        let pageInfo = null;

        if (apiData.data && apiData.data.trades && Array.isArray(apiData.data.trades)) {
            transactionsList = apiData.data.trades;
            pageInfo = apiData.data.page;
        } else if (apiData.trades && Array.isArray(apiData.trades)) {
            transactionsList = apiData.trades;
            pageInfo = apiData.page;
        } else if (apiData.data && apiData.data.transactions && Array.isArray(apiData.data.transactions)) {
            transactionsList = apiData.data.transactions;
            pageInfo = apiData.data.page;
        } else if (apiData.transactions && Array.isArray(apiData.transactions)) {
            transactionsList = apiData.transactions;
            pageInfo = apiData.page;
        }

        if (pageInfo) {
            this.totalRecords = pageInfo.totalRecords || 0;
            this.currentPage = pageInfo.page || 1;
            this.totalPages = pageInfo.totalPages || 0;
        }

        if (transactionsList.length > 0) {
            const metalTransactions = transactionsList.filter(txn => txn.metalCurrency === 'XAG');
            this.originalTransactions = metalTransactions.map((txn, index) => this.mapTransaction(txn, index));
            this.transactions = [...this.originalTransactions];
            this.transactionsError = null;
        } else {
            this.originalTransactions = [];
            this.transactions = [];
            this.transactionsError = null;
        }
    }

    mapTransaction(txn, index) {
        const tradeType = txn.tradeType || '';
        const isBuy = tradeType === 'BUY';
        const isSell = tradeType === 'SELL';

        const amount = txn.amount || 0;
        const transactionType = isBuy ? 'Debit' : (isSell ? 'Credit' : '');
        const amountClass = isBuy ? 'debit' : (isSell ? 'credit' : '');
        const displayAmount = Math.abs(amount);

        const accountCurrency = txn.accountCurrency?.code || 'BHD';
        const tradeCurrency = txn.tradeCurrency?.code || 'XAG';
        const metalQuantity = txn.quantity || 0;

        return {
            id: txn.reference || txn.id || index,
            description: txn.tradeDescription || (isBuy ? 'Buy Silver' : (isSell ? 'Sell Silver' : 'Silver Transaction')),
            debitAccount: txn.accountName || `${accountCurrency} Account`,
            transactionDate: this.formatDate(txn.tradeDate),
            transactionAmount: this.formatCurrency(displayAmount, accountCurrency),
            amountClass: amountClass,
            exchangeRate: txn.tradeExchangeRate
                ? `${tradeCurrency} 1 = ${this.formatNumber(txn.tradeExchangeRate)} ${accountCurrency}`
                : '—',
            metalAmount: `${this.formatNumber(metalQuantity)} ${tradeCurrency}`,
            reference: txn.reference || '—',
            status: txn.status || 'Completed',
            type: transactionType,
            amount: displayAmount,
            date: this.formatDateForFilter(txn.tradeDate),
            tradeType: tradeType,
            quantity: metalQuantity,
            tradeExchangeRate: txn.tradeExchangeRate
        };
    }

    refreshTransactions() {
        this.loadTransactions();
    }

    // ==================== STATEMENTS ====================
    loadStatements() {
        if (!this.showTransactionsAndStatements) return;
        if (!this.customerId) {
            this.statementsError = 'Customer ID (CIF) is required';
            return;
        }

        this.isLoadingStatements = true;
        this.statementsError = null;

        if (!this.accountId && this.silverAccount.accountNumber !== '—') {
            this.accountId = this.silverAccount.accountNumber;
        }

        const params = {
            accountId: this.accountId || `XAG-${this.customerId}`,
            statementType: 'Statement',
            customerId: this.customerId,
            regionName: this.regionName,
            xCanary: this.xCanary
        };

        getMetalStatements(params)
            .then(result => {
                if (result && result.success === true) {
                    this.processStatementsResponse(result);
                } else if (result && result.success === false) {
                    const errorMsg = result.message || 'Failed to load statements';
                    this.statementsError = errorMsg;
                    this.showErrorToast('Statements Error', errorMsg);
                    this.statements = [];
                } else if (result && result.statements && Array.isArray(result.statements)) {
                    this.processStatementsResponse(result);
                } else if (result && result.data && result.data.statements) {
                    this.processStatementsResponse(result.data);
                } else {
                    this.statements = [];
                    this.statementsError = null;
                }
            })
            .catch(error => {
                this.statements = [];
                this.statementsError = null;
            })
            .finally(() => {
                this.isLoadingStatements = false;
            });
    }

    processStatementsResponse(apiData) {
        let statementsList = [];

        if (apiData.statements && Array.isArray(apiData.statements)) {
            statementsList = apiData.statements;
        } else if (apiData.data && apiData.data.statements && Array.isArray(apiData.data.statements)) {
            statementsList = apiData.data.statements;
        }

        if (statementsList.length > 0) {
            this.statements = statementsList.map((stmt, index) => ({
                id: stmt.id || stmt.statementId || index,
                statementDescription: stmt.statementDescription,
                generatedDate: stmt.statementDate
            }));
            this.statementsError = null;
        } else {
            this.statements = [];
        }
    }

    fetchStatements() {
        this.showStatementsTable = true;
        this.loadStatements();
    }

    downloadStatement(event) {
        const statementId = event.currentTarget.dataset.id;
        this.isLoading = true;

        const stmt = this.statements.find(s => String(s.id) === String(statementId));
        if (!stmt) {
            this.isLoading = false;
            this.showErrorToast('Error', 'Statement not found.');
            return;
        }

        const statementDate = stmt.generatedDate;
        const ibanNumber = this.accountId;

        const requestData = {
            accountId: ibanNumber,
            statementDate: statementDate,
            statementType: "Statement"
        };

        getAccountStatementDetails({
            customerId: this.customerId,
            requestTextJson: JSON.stringify(requestData)
        })
        .then(result => {
            this.isLoading = false;

            if (result.isSuccess) {
                const downloadLink = document.createElement("a");
                downloadLink.setAttribute("type", "hidden");
                downloadLink.href = "data:text/html;base64," + result.responseData.fileContent;

                const lastFourDigits = ibanNumber.substr(-4);
                const formattedDate = statementDate.replace(/-/g, "");
                downloadLink.download = `Statement-${lastFourDigits}-${formattedDate}.pdf`;

                document.body.appendChild(downloadLink);
                downloadLink.click();
                downloadLink.remove();
            } else {
                this.showErrorToast('Error', result.errorData.code + ' : ' + result.errorData.message);
            }
        })
        .catch(error => {
            this.isLoading = false;
            this.showErrorToast('Error', 'An error occurred while downloading the statement');
        });
    }

    // ==================== FILTERS ====================
    get filteredTransactions() {
        let filtered = [...this.transactions];

        if (this.searchTerm) {
            const searchLower = this.searchTerm.toLowerCase();
            filtered = filtered.filter(txn =>
                (txn.description && txn.description.toLowerCase().includes(searchLower)) ||
                (txn.reference && txn.reference.toLowerCase().includes(searchLower)) ||
                (txn.debitAccount && txn.debitAccount.toLowerCase().includes(searchLower))
            );
        }

        if (this.statusFilter !== 'all') filtered = filtered.filter(txn => txn.status === this.statusFilter);
        if (this.typeFilter !== 'all') filtered = filtered.filter(txn => txn.type === this.typeFilter);

        if (this.amountFrom !== null && !isNaN(this.amountFrom)) filtered = filtered.filter(txn => txn.amount >= this.amountFrom);
        if (this.amountTo !== null && !isNaN(this.amountTo)) filtered = filtered.filter(txn => txn.amount <= this.amountTo);

        if (this.dateFrom) filtered = filtered.filter(txn => txn.date >= this.dateFrom);
        if (this.dateTo) filtered = filtered.filter(txn => txn.date <= this.dateTo);

        return filtered;
    }

    get hasTransactions() { return this.filteredTransactions && this.filteredTransactions.length > 0; }
    get hasStatements() { return this.statements && this.statements.length > 0; }
    get noTransactionsFound() {
        return this.transactions.length === 0 && !this.isLoadingTransactions && !this.transactionsError;
    }

    handleTransactionSearch(event) { this.searchTerm = event.target.value; }
    filterByStatus(event) { this.statusFilter = event.target.value; }
    filterByType(event) { this.typeFilter = event.target.value; }
    filterAmountFrom(event) { this.amountFrom = event.target.value ? parseFloat(event.target.value) : null; }
    filterAmountTo(event) { this.amountTo = event.target.value ? parseFloat(event.target.value) : null; }
    filterDateFrom(event) { this.dateFrom = event.target.value; }
    filterDateTo(event) { this.dateTo = event.target.value; }

    // ==================== UTILITY ====================
    formatDate(dateValue) {
        if (!dateValue) return '—';
        try {
            let date = (typeof dateValue === 'string' || typeof dateValue === 'number')
                ? new Date(dateValue) : null;
            if (!date || isNaN(date.getTime())) return dateValue;

            return date.toLocaleDateString('en-GB', {
                day: '2-digit', month: 'short', year: 'numeric',
                hour: '2-digit', minute: '2-digit'
            });
        } catch (e) { return dateValue; }
    }

    formatDateForFilter(dateValue) {
        if (!dateValue) return '';
        try {
            let date = (typeof dateValue === 'string' || typeof dateValue === 'number')
                ? new Date(dateValue) : null;
            if (!date || isNaN(date.getTime())) return '';
            return date.toISOString().split('T')[0];
        } catch (e) { return ''; }
    }

    formatCurrency(amount, currency = 'BHD') {
        if (!amount && amount !== 0) return '—';
        const numValue = parseFloat(amount);
        if (isNaN(numValue)) return '—';
        return `${currency} ${numValue.toLocaleString(undefined, { minimumFractionDigits: 3, maximumFractionDigits: 3 })}`;
    }

    formatNumber(value) {
        if (!value && value !== 0) return '—';
        const numValue = parseFloat(value);
        if (isNaN(numValue)) return '—';
        return numValue.toLocaleString(undefined, { minimumFractionDigits: 3, maximumFractionDigits: 3 });
    }

    showErrorToast(title, message) {
        try {
            this.dispatchEvent(new ShowToastEvent({
                title, message, variant: 'error', mode: 'dismissible'
            }));
        } catch (e) {
            console.error('Toast error:', title, message);
        }
    }

    showToast(title, message, variant = 'info') {
        try {
            this.dispatchEvent(new ShowToastEvent({
                title, message, variant, mode: 'dismissible'
            }));
        } catch (e) {
            console.log('ShowToastEvent not available');
        }
    }

    // ==================== TRUNCATION HELPER ====================
    // Truncates (does NOT round). Also normalizes -0 → 0.
    truncateDecimals(value, places) {
        if (value == null || isNaN(value)) return 0;
        const factor = Math.pow(10, places);
        const truncated = Math.trunc(value * factor) / factor;
        return truncated === 0 ? 0 : truncated;
    }

    // ==================== HERO / PRICE MOVEMENT ====================
    fetchData(duration) {
        this.isPriceLoading = true;

        getChartData({
            selectedDuration: duration,
            transferType: this.transferType,
            metalCurrency: this.metalCurrency,   // 'XAG' for Silver
            segment: this.segment || 'Premium',
            customerId: this.customerId
        })
        .then(chartData => {
            // No data → show empty state
            if (!chartData || (chartData.change == null && chartData.changePercent == null)) {
                this.resetHero();
                return;
            }

            this.currentPrice  = chartData.currentPrice  != null ? chartData.currentPrice  : null;
            this.change        = chartData.change        != null ? chartData.change        : 0;
            this.changePercent = chartData.changePercent != null ? chartData.changePercent : 0;

            // Truncate (no rounding)
            const tChange = this.truncateDecimals(this.change, 3);
            const tPct    = this.truncateDecimals(this.changePercent, 2);

            // Direction based on TRUNCATED values (so 0.00 → neutral, no minus)
            const directionValue = tPct !== 0 ? tPct : tChange;
            if (directionValue > 0)      this.changeDirection = 'positive';
            else if (directionValue < 0) this.changeDirection = 'negative';
            else                         this.changeDirection = 'neutral';

            // Change amount display
            if (this.change != null) {
                const absChange = Math.abs(tChange).toLocaleString(undefined, {
                    minimumFractionDigits: 3,
                    maximumFractionDigits: 3
                });
                if (tChange > 0)      this.changeValueDisplay = `+${absChange}`;
                else if (tChange < 0) this.changeValueDisplay = `-${absChange}`;
                else                  this.changeValueDisplay = absChange;
            } else {
                this.changeValueDisplay = '—';
            }

            // Change percent display (absolute value; arrow shows direction)
            if (this.changePercent != null) {
                const absPercent = Math.abs(tPct).toLocaleString(undefined, {
                    minimumFractionDigits: 2,
                    maximumFractionDigits: 2
                });
                this.changePercentDisplay = `${absPercent}%`;
            } else {
                this.changePercentDisplay = '—';
            }

            this.hasPriceData = true;
            this.updateButtonClasses(duration);
        })
        .catch(error => {
            console.error('Error fetching chart data:', error);
            this.resetHero();
        })
        .finally(() => {
            this.isPriceLoading = false;
        });

        // ---- API #2: Portfolio overview (independent) ----
        getPortfolioOverview({
            customerId: this.customerId,
            metalCurrency: this.metalCurrency,
            segment: this.segment || 'Premium'
        })
        .then(summary => {
            const s = summary || {};

            const tTotal      = this.truncateDecimals(s.totalPL,      3);
            const tUnrealized = this.truncateDecimals(s.unrealizedPL, 3);
            const tRealized   = this.truncateDecimals(s.realizedPL,   3);
            const tAvgCost    = this.truncateDecimals(s.averageCost,  3);

            this.summary = {
                totalPL:      tTotal.toLocaleString(undefined,      { minimumFractionDigits: 3, maximumFractionDigits: 3 }),
                unrealizedPL: tUnrealized.toLocaleString(undefined, { minimumFractionDigits: 3, maximumFractionDigits: 3 }),
                realizedPL:   tRealized.toLocaleString(undefined,   { minimumFractionDigits: 3, maximumFractionDigits: 3 }),
                averageCost:  tAvgCost.toLocaleString(undefined,    { minimumFractionDigits: 3, maximumFractionDigits: 3 }),
                totalPLClass:      this.getPLClass(tTotal),
                unrealizedPLClass: this.getPLClass(tUnrealized),
                realizedPLClass:   this.getPLClass(tRealized),
                averageCostClass:  'summary-value'
            };
        })
        .catch(error => {
            console.error('Error fetching portfolio overview:', error);
        });
    }

    resetHero() {
        this.changeValueDisplay = '—';
        this.changePercentDisplay = '—';
        this.changeDirection = 'neutral';
        this.hasPriceData = false;
    }

    getPLClass(value) {
        const base = 'summary-value ';
        if (value == null || value === 0) return base;
        return base + (value > 0 ? 'slds-text-color_success' : 'slds-text-color_error');
    }

    updateButtonClasses(selected) {
        this.buttonClass5D = selected === '5d' ? 'duration-btn is-active' : 'duration-btn';
        this.buttonClass1M = selected === '1m' ? 'duration-btn is-active' : 'duration-btn';
        this.buttonClass3M = selected === '3m' ? 'duration-btn is-active' : 'duration-btn';
        this.buttonClass6M = selected === '6m' ? 'duration-btn is-active' : 'duration-btn';
        this.buttonClassYTD = selected === 'ytd' ? 'duration-btn is-active' : 'duration-btn';
        this.buttonClass1Y = selected === '1y' ? 'duration-btn is-active' : 'duration-btn';
    }

    handleDurationClick(event) {
        const duration = event.currentTarget.dataset.duration;
        if (duration === this.selectedDuration) return;
        this.selectedDuration = duration;
        this.updateButtonClasses(duration);
        this.fetchData(duration);
    }

    handleTransferTypeChange(event) {
        this.transferType = event.target.checked ? 'sell' : 'buy';
        this.fetchData(this.selectedDuration);
    }
}
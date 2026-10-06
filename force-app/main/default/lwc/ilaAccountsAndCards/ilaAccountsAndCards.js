import { LightningElement, track } from 'lwc';

export default class IlaAccountsAndCards extends LightningElement {
    @track activePrimaryTab = 'savings';
    @track activeSubTab = 'gold';
    @track showBankSubTabs = false;
    @track showCardsSubTabs = false;
    @track showSavingsSubTabs = true;
    @track showPayrollSubTabs = false;
    
    // Gold Account Data
    @track goldAccountExists = true;
    @track goldAccount = {
        status: 'Active',
        statusClass: 'status-active',
        createdDate: '29 Jan 2026 19:16',
        closureDate: '—',
        availableBalance: 'XAU 1,000.000',
        holdBalance: 'XAU 500.000',
        bookBalance: 'XAU 1,500.000'
    };

    // Silver Account Data
    @track silverAccountExists = true;
    @track silverAccount = {
        status: 'Active',
        statusClass: 'status-active',
        createdDate: '15 Feb 2026 10:30',
        closureDate: '—',
        availableBalance: 'XAG 5,000.000',
        holdBalance: 'XAG 1,000.000',
        bookBalance: 'XAG 6,000.000'
    };

    // Gold Transactions
    @track transactions = [
        {
            id: 1,
            description: 'Buy Gold',
            debitAccount: 'BHD Account (****1234)',
            transactionDate: '28 Jan 2026 14:22',
            transactionAmount: 'BHD 1,698.321',
            amountClass: 'debit',
            exchangeRate: 'XAU 1 = 1,698.321',
            metalAmount: 'XAU 1.000',
            reference: 'TXN202601281422',
            status: 'Completed',
            type: 'Debit',
            amount: 1698.321,
            date: '2026-01-28'
        },
        {
            id: 2,
            description: 'Sell Gold',
            debitAccount: 'USD Account (****5678)',
            transactionDate: '25 Jan 2026 09:15',
            transactionAmount: 'USD 2,500.000',
            amountClass: 'credit',
            exchangeRate: 'XAU 1 = 2,500.000',
            metalAmount: 'XAU 1.000',
            reference: 'TXN202601250915',
            status: 'Completed',
            type: 'Credit',
            amount: 2500,
            date: '2026-01-25'
        },
        {
            id: 3,
            description: 'Gold Transfer',
            debitAccount: 'Internal Account',
            transactionDate: '20 Jan 2026 11:30',
            transactionAmount: 'BHD 849.160',
            amountClass: 'debit',
            exchangeRate: 'XAU 1 = 1,698.321',
            metalAmount: 'XAU 0.500',
            reference: 'TXN202601201130',
            status: 'Pending',
            type: 'Debit',
            amount: 849.16,
            date: '2026-01-20'
        }
    ];

    // Silver Transactions
    @track silverTransactions = [
        {
            id: 1,
            description: 'Buy Silver',
            debitAccount: 'BHD Account (****1234)',
            transactionDate: '28 Jan 2026 14:22',
            transactionAmount: 'BHD 500.000',
            amountClass: 'debit',
            exchangeRate: 'XAG 1 = 0.500',
            metalAmount: 'XAG 1,000.000',
            reference: 'SILV202601281422',
            status: 'Completed',
            type: 'Debit',
            amount: 500,
            date: '2026-01-28'
        },
        {
            id: 2,
            description: 'Sell Silver',
            debitAccount: 'USD Account (****5678)',
            transactionDate: '25 Jan 2026 09:15',
            transactionAmount: 'USD 750.000',
            amountClass: 'credit',
            exchangeRate: 'XAG 1 = 0.750',
            metalAmount: 'XAG 1,000.000',
            reference: 'SILV202601250915',
            status: 'Completed',
            type: 'Credit',
            amount: 750,
            date: '2026-01-25'
        }
    ];

    // Gold Statements
    @track statements = [
        {
            id: 1,
            period: 'January 2026',
            openingBalance: 'XAU 500.000',
            closingBalance: 'XAU 1,500.000',
            totalCredits: 'XAU 1,200.000',
            totalDebits: 'XAU 200.000',
            generatedDate: '01 Feb 2026'
        },
        {
            id: 2,
            period: 'December 2025',
            openingBalance: 'XAU 450.000',
            closingBalance: 'XAU 500.000',
            totalCredits: 'XAU 100.000',
            totalDebits: 'XAU 50.000',
            generatedDate: '01 Jan 2026'
        }
    ];

    // Silver Statements
    @track silverStatements = [
        {
            id: 1,
            period: 'January 2026',
            openingBalance: 'XAG 4,000.000',
            closingBalance: 'XAG 6,000.000',
            totalCredits: 'XAG 2,500.000',
            totalDebits: 'XAG 500.000',
            generatedDate: '01 Feb 2026'
        }
    ];

    // Filter states
    @track searchTerm = '';
    @track statusFilter = 'all';
    @track typeFilter = 'all';
    @track amountFrom = null;
    @track amountTo = null;
    @track dateFrom = null;
    @track dateTo = null;

    @track silverSearchTerm = '';
    @track silverStatusFilter = 'all';
    @track silverTypeFilter = 'all';
    @track silverAmountFrom = null;
    @track silverAmountTo = null;
    @track silverDateFrom = null;
    @track silverDateTo = null;

    @track showStatements = true;
    @track showSilverStatements = true;

    // Getters for computed properties
    get showGoldContent() {
        return this.activePrimaryTab === 'savings' && this.activeSubTab === 'gold';
    }

    get showSilverContent() {
        return this.activePrimaryTab === 'savings' && this.activeSubTab === 'silver';
    }

    get filteredTransactions() {
        return this.transactions.filter(txn => {
            // Search filter
            if (this.searchTerm && !txn.description.toLowerCase().includes(this.searchTerm.toLowerCase()) &&
                !txn.reference.toLowerCase().includes(this.searchTerm.toLowerCase())) {
                return false;
            }
            
            // Status filter
            if (this.statusFilter !== 'all' && txn.status !== this.statusFilter) {
                return false;
            }
            
            // Type filter
            if (this.typeFilter !== 'all' && txn.type !== this.typeFilter) {
                return false;
            }
            
            // Amount range filter
            if (this.amountFrom && txn.amount < this.amountFrom) {
                return false;
            }
            if (this.amountTo && txn.amount > this.amountTo) {
                return false;
            }
            
            // Date range filter
            if (this.dateFrom && txn.date < this.dateFrom) {
                return false;
            }
            if (this.dateTo && txn.date > this.dateTo) {
                return false;
            }
            
            return true;
        });
    }

    get filteredSilverTransactions() {
        return this.silverTransactions.filter(txn => {
            // Search filter
            if (this.silverSearchTerm && !txn.description.toLowerCase().includes(this.silverSearchTerm.toLowerCase()) &&
                !txn.reference.toLowerCase().includes(this.silverSearchTerm.toLowerCase())) {
                return false;
            }
            
            // Status filter
            if (this.silverStatusFilter !== 'all' && txn.status !== this.silverStatusFilter) {
                return false;
            }
            
            // Type filter
            if (this.silverTypeFilter !== 'all' && txn.type !== this.silverTypeFilter) {
                return false;
            }
            
            // Amount range filter
            if (this.silverAmountFrom && txn.amount < this.silverAmountFrom) {
                return false;
            }
            if (this.silverAmountTo && txn.amount > this.silverAmountTo) {
                return false;
            }
            
            // Date range filter
            if (this.silverDateFrom && txn.date < this.silverDateFrom) {
                return false;
            }
            if (this.silverDateTo && txn.date > this.silverDateTo) {
                return false;
            }
            
            return true;
        });
    }

    get noTransactionsFound() {
        return this.filteredTransactions.length === 0;
    }

    get noSilverTransactionsFound() {
        return this.filteredSilverTransactions.length === 0;
    }

    // Primary Tab Switching
    switchPrimaryTab(event) {
        const tab = event.currentTarget.dataset.tab;
        this.activePrimaryTab = tab;
        
        const tabs = this.template.querySelectorAll('.tab-item');
        tabs.forEach(t => t.classList.remove('active'));
        event.currentTarget.classList.add('active');
        
        this.showBankSubTabs = tab === 'bank-accounts';
        this.showCardsSubTabs = tab === 'cards';
        this.showSavingsSubTabs = tab === 'savings';
        this.showPayrollSubTabs = tab === 'payroll';
        
        if (tab === 'savings') {
            this.activeSubTab = 'gold';
            this.updateSubTabActiveState();
        }
    }

    // Sub Tab Switching
    switchSubTab(event) {
        const subtab = event.currentTarget.dataset.subtab;
        this.activeSubTab = subtab;
        
        const subTabs = this.template.querySelectorAll('.sub-tab-item');
        subTabs.forEach(t => t.classList.remove('active'));
        event.currentTarget.classList.add('active');
        
        // Reset filters when switching tabs
        this.resetFilters();
        this.resetSilverFilters();
    }

    // Filter Handlers for Gold
    handleTransactionSearch(event) {
        this.searchTerm = event.target.value;
    }

    filterByStatus(event) {
        this.statusFilter = event.target.value;
    }

    filterByType(event) {
        this.typeFilter = event.target.value;
    }

    filterAmountFrom(event) {
        this.amountFrom = event.target.value ? parseFloat(event.target.value) : null;
    }

    filterAmountTo(event) {
        this.amountTo = event.target.value ? parseFloat(event.target.value) : null;
    }

    filterDateFrom(event) {
        this.dateFrom = event.target.value;
    }

    filterDateTo(event) {
        this.dateTo = event.target.value;
    }

    // Filter Handlers for Silver
    handleSilverTransactionSearch(event) {
        this.silverSearchTerm = event.target.value;
    }

    filterSilverByStatus(event) {
        this.silverStatusFilter = event.target.value;
    }

    filterSilverByType(event) {
        this.silverTypeFilter = event.target.value;
    }

    filterSilverAmountFrom(event) {
        this.silverAmountFrom = event.target.value ? parseFloat(event.target.value) : null;
    }

    filterSilverAmountTo(event) {
        this.silverAmountTo = event.target.value ? parseFloat(event.target.value) : null;
    }

    filterSilverDateFrom(event) {
        this.silverDateFrom = event.target.value;
    }

    filterSilverDateTo(event) {
        this.silverDateTo = event.target.value;
    }

    // Statement Handlers
    fetchStatements() {
        // Simulate API call
        this.showStatements = true;
        // In real implementation, this would call an API
        console.log('Fetching gold statements...');
    }

    fetchSilverStatements() {
        this.showSilverStatements = true;
        console.log('Fetching silver statements...');
    }

    downloadStatement(event) {
        const statementId = event.currentTarget.dataset.id;
        console.log('Downloading statement:', statementId);
        // Implement download logic
    }

    downloadSilverStatement(event) {
        const statementId = event.currentTarget.dataset.id;
        console.log('Downloading silver statement:', statementId);
        // Implement download logic
    }

    // Reset Filters
    resetFilters() {
        this.searchTerm = '';
        this.statusFilter = 'all';
        this.typeFilter = 'all';
        this.amountFrom = null;
        this.amountTo = null;
        this.dateFrom = null;
        this.dateTo = null;
    }

    resetSilverFilters() {
        this.silverSearchTerm = '';
        this.silverStatusFilter = 'all';
        this.silverTypeFilter = 'all';
        this.silverAmountFrom = null;
        this.silverAmountTo = null;
        this.silverDateFrom = null;
        this.silverDateTo = null;
    }

    updateSubTabActiveState() {
        setTimeout(() => {
            const subTabs = this.template.querySelectorAll('.sub-tab-item');
            subTabs.forEach(t => {
                if (t.dataset.subtab === this.activeSubTab) {
                    t.classList.add('active');
                } else {
                    t.classList.remove('active');
                }
            });
        }, 0);
    }
}
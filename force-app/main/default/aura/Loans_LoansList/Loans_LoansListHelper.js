({
    loadData : function(component, customerId, loanStatus) {
        console.log('Loans_LTNG36_LoansListHelper.js: LoadData Method 1');
        if ($A.util.isEmpty(customerId)) {
            console.error('LTNG36_LoansList.Helper.js: customerId not provided');
            return;
        }
        var helper = this;
        
        var caseId =component.get('v.caseId');
        
        var isAlburaq = component.get("v.isAlburaqProduct");
        
        var accountLabel = isAlburaq
        ? 'Finance Account Number'
        : 'Loan Account Number';
        
        //var isAlburaqProduct = component.get("v.isAlburaqProduct");
        //component.set('v.caseModel', (isAlburaqProduct ? 'alburaq' : 'ila'));

        var rowLevelActions = [
            // { label: 'Show transactions', name: 'show_transactions' },
        ];
        var loanOrFinance = component.get('v.loanOrFinance');

        console.log('RecordId => ',caseId);
        if(caseId != null && caseId != '' && caseId.startsWith('500')){
            //Case Id always starts with '500'
            console.log('getCase!!')
            component.find('apexService').request(component.get('c.getCaseRecord'), {
                caseId: caseId
            },
            function(response) {
                var caseRecord = response.getReturnValue();
                console.log('caseRecord ',caseRecord);
                component.set('v.caseModel', caseRecord.Case_Model__c);
                component.set('v.caseType', caseRecord.Type);
                component.set('v.caseSubType',caseRecord.Sub_Type__c);
                component.set('v.isSubmitted', caseRecord.isSubmitted__c);
                component.set('v.submittedLoanId', caseRecord.cc_PCI_Id__c);//toDo : check if we still need to use this on case level for loan service request ??
                
                //set columns
                var subTypeCase = component.get('v.caseSubType');
                console.log('case subTypeCase ',subTypeCase);
                
                // In the caseId block - replace the column setting code:
                if(subTypeCase == 'Early Settlement' || subTypeCase == 'Partial Settlement' || subTypeCase == 'Advance Payment' || subTypeCase == 'Top-up'|| subTypeCase == 'Fees Reversal / Waivers'|| subTypeCase == 'Restructuring'|| subTypeCase == 'Instalment Deferment / Postponement') {
                    baseColumns = [
                        {label: loanOrFinance+ ' Account Number', fieldName: 'loanAccountNumber', type: 'text',sortable:true},
                        {label: 'Product Name', fieldName: 'productName', type: 'text',sortable:true},
                        {label: 'Nature', fieldName: 'productNature', type: 'text',sortable:true},
                        {label: loanOrFinance+ ' Amount', fieldName: 'LoanAmount', type: 'text',sortable:true},
                        {label: 'Total installments', fieldName: 'Totalinstallments', type: 'text',sortable:true},
                        {label: 'Installment Amount', fieldName: 'installmentAmount', type: 'text',sortable:true}, 
                        {label: loanOrFinance+ ' Status', fieldName: 'LoanStatus', type: 'text',sortable:true},
                        {label: 'Payoff Amount', fieldName: 'payAmount', type: 'text',sortable:true},
                        {label: 'Paid no. of installments', fieldName: 'paidInstallment', type: 'text',sortable:true},
                        {label: 'Approved CRM Case', fieldName: 'approvedCaseNumber', type: 'text', sortable: true},
                        { type: 'action', typeAttributes: { rowActions: rowLevelActions } } 
                        
                    ];
                } else {
                    baseColumns = [
                        {label: loanOrFinance+ ' Account Number', fieldName: 'loanAccountNumber', type: 'text',sortable:true},
                        {label: 'Product Name', fieldName: 'productName', type: 'text',sortable:true},
                        {label: 'Nature', fieldName: 'productNature', type: 'text',sortable:true},
                        {label: loanOrFinance+ ' Amount', fieldName: 'LoanAmount', type: 'text',sortable:true},
                        {label: 'Total installments', fieldName: 'Totalinstallments', type: 'text',sortable:true},
                        {label: loanOrFinance+ ' Status', fieldName: 'LoanStatus', type: 'text',sortable:true},
                        {label: 'Approved CRM Case', fieldName: 'approvedCaseNumber', type: 'text', sortable: true},
                        { type: 'action', typeAttributes: { rowActions: rowLevelActions } } 
                    ];
                }
   
                // Add rowColorClass binding to every non-action column
                var columnsWithClass = baseColumns.map(function(col){
                    if (col.type && col.type === 'action') return col;
                    col.cellAttributes = col.cellAttributes || {};
                    col.cellAttributes.class = { fieldName: 'rowColorClass' };
                    return col;
                });
   
                component.set('v.columns', columnsWithClass);
            });
        }
        else {
            // In the else block (customer level) - replace the column setting code:
            //set columns to use on customer level
            var baseColumns = [
                {label: loanOrFinance+ ' Account Number', fieldName: 'loanAccountNumber', type: 'text',sortable:true},
                {label: 'Product Name', fieldName: 'productName', type: 'text',sortable:true},
                {label: 'Nature', fieldName: 'productNature', type: 'text',sortable:true},
                {label: loanOrFinance+ ' Amount', fieldName: 'LoanAmount', type: 'text',sortable:true},
                {label: 'Total installments', fieldName: 'Totalinstallments', type: 'text',sortable:true},
                {label: loanOrFinance+ ' Status', fieldName: 'LoanStatus', type: 'text',sortable:true},
                {label: 'Closed Date', fieldName: 'LoanClosedDate', type: 'text',sortable:true},//#CH02
                {label: 'Approved CRM Case', fieldName: 'approvedCaseNumber', type: 'text', sortable: true},
                { type: 'action', typeAttributes: { rowActions: rowLevelActions } } 
            ];

            // Add rowColorClass binding to every non-action column
            var columnsWithClass = baseColumns.map(function(col){
                if (col.type && col.type === 'action') return col;
                col.cellAttributes = col.cellAttributes || {};
                col.cellAttributes.class = { fieldName: 'rowColorClass' };
                return col;
            });

            component.set('v.columns', columnsWithClass);
        }
        
        // console.error(customerId);
        var model = component.get('v.caseModel') != null  && component.get('v.caseModel') != '' ? 
                    component.get('v.caseModel') :
                    ( component.get("v.isAlburaqProduct") ? 'alburaq' : 'ila');

        component.find('apexService').request(component.get('c.loadLoansList'), {
            customerId: customerId,
            caseModel: model
        },
        function(response) {
            console.log('Loans_LTNG36_LoansListHelper.js response: ',response);
            var result = response.getReturnValue();
            console.log('Loans_LTNG36_LoansListHelper.js result::: ',result);
            var data = [];
            var loans = [];
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData.currentLoans)) {
                loans = result.responseData.currentLoans;
            }
            
            for (var i = 0; i < loans.length; i++) {
                var loanObj = loans[i];
                var loanObjStatus = loanObj.status.toLowerCase();
                
                // New logic: When loanStatus is 'Default', include 'Active' and 'Overdue' records
                if (loanStatus != null && loanStatus.toLowerCase() == 'default') {
                    if (loanObjStatus == 'active' || loanObjStatus == 'overdue') {
                        data.push(helper.formatData(component, loanObj));
                    }
                }
                // Original logic for all other cases
                else if ((loanStatus != null && loanObjStatus == loanStatus.toLowerCase()) || loanStatus == '' || loanStatus == 'All') {
                    data.push(helper.formatData(component, loanObj));
                }
            }
            
            component.set('v.responseLoanListdata', result.responseData);
            console.log('#######1 '+JSON.stringify(result.responseData));
            component.set('v.data', data);

            //omar start
            var arrangementIds = data.map(function(loan) { return loan.id; });
            if (arrangementIds.length > 0) {
                var caseAction = component.get("c.getApprovedCases");
                caseAction.setParams({ arrangementIds: arrangementIds });
             
                caseAction.setCallback(this, function(caseResponse) {
                if (caseResponse.getState() === "SUCCESS") {
                    var caseMap = caseResponse.getReturnValue();
                    var loansData = component.get('v.data');
                    console.log('loans > ', loansData)
                    loansData.forEach(function(loan) {
                        if (caseMap[loan.id]) {
                            loan.approvedCaseNumber = caseMap[loan.id].CaseNumber;
                            loan.approvedCaseUrl = '/' + caseMap[loan.id].Id;
                        } else {
                            loan.approvedCaseNumber = null;
                        }
                    });
                    component.set('v.data', loansData);
                }
            });
                $A.enqueueAction(caseAction);
            }
            //omar end

            data.forEach(function(loan) {
                helper.loadEarlySettlment(component, customerId, loan.id, function(payAmount) {
                    // Update payAmount in data array
                    var loansData = component.get('v.data');
                    var foundLoan = loansData.find(l => l.id === loan.id);
                    if (foundLoan) {
                        foundLoan.payAmount = payAmount;
                    }
                    component.set('v.data', loansData);
                });
            });

            console.log('#######2 '+JSON.stringify(data));
            var loanIdToSelect = component.get('v.submittedLoanId');
            if(loanIdToSelect != null && loanIdToSelect != '' ){
                console.log('#######333 '+ loanIdToSelect );
                var selectedRow = data.find(row => row.id === loanIdToSelect);
                console.log('#######555 '+ selectedRow.id );
                var selectedKeys = [];
                selectedKeys.push(selectedRow.id);
                component.set("v.selectedRows", selectedKeys);
                console.log('#######66 '+ JSON.stringify(component.get("v.selectedRows")) );
                //component.find('loanListTable').set("v.selectedRows", [ {id :selectedRow.id,selected: true} ]);
                //var selectedRows = dataTable.rows( { selected: true } );
            }
            //console.log('Account:', data);
            
        });
        
    },
    formatData: function(component, loanObj){
        var result = {};
        result.id = loanObj.arrangementId;
        result.ContractNumber = loanObj.arrangementId;
        result.productName = loanObj.productName;
        result.productNature = loanObj.productNature;
        result.LoanAmount = String(loanObj.principalLoanAmount);
        result.installmentAmount = String(loanObj.nextInstallmentAmount);//#CH01 : phase 3 change change it from "monthlyInstallment" to "nextInstallmentAmount" (UATNB-210713)
        result.Totalinstallments = String(loanObj.totalInstallments);
        result.LoanStatus = loanObj.status;
        result.paidInstallment = loanObj.paidInstallments;
        result.loanAccountNumber = loanObj.loanAccountNumber;
        //result.LoanClosedDate = loanObj.LoanClosedDate;//#CH02
        result.LoanClosedDate = '-';//toDo : check mapping with shameer//#CH02
        result.payAmount = 'Loading...';
        // omar start
        if (loanObj.status && loanObj.status.toLowerCase() === 'overdue') {
            console.log('loanObj overdue')
            result.rowColorClass = 'overdue-hover'; // adds hover style
        } else {
            result.rowColorClass = '';
        }
        
        // omar end
        return result;
        
    },
    openLoanDetails : function(component, customerId, loanId) {
        /*
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
        	"title": "This is a demo!",
            "message": "This action will open details of selected account."
       });
       toastEvent.fire();
       */
        var recordTypeName = component.get("v.recordTypeName");
        
        component.set('v.loanId', loanId);
        component.set('v.submittedLoanId', loanId);
        if (recordTypeName !== "Loan / Finance Service Request"){
            console.log('recordTypeName!!!!!! '+recordTypeName)
            component.set('v.displayLoanDetails', true);
            
            this.openTransactionList(component, customerId, loanId);
        } else {
            
            console.log("Cannot open loan details");
        }
    },
    openTransactionList : function(component, customerId, loanId) {
        console.log('openTransactionList --> '+loanId);
        component.set('v.loanId', loanId);
        component.set('v.submittedLoanId', loanId);
        component.set('v.displayLoanTransactions', true);
        /*
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
        	"title": "This is a demo!",
            "message": "This action will open list of transactions on selected account."
       });
       toastEvent.fire();
      */
    },
     // omar start
   loadEarlySettlment : function(component, customerId, loanId, callback) {
        var model = component.get('v.caseModel') != null  && component.get('v.caseModel') != '' ? 
                    component.get('v.caseModel') :
                    ( component.get("v.isAlburaqProduct") ? 'alburaq' : 'ila');
        console.log('new caseproduct >>> '+ model)
        var action = component.get("c.loadLoansEarlySettlmentApiList");
        action.setParams({
            customerId: customerId,
            loanId: loanId, 
            caseModel: model
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var payAmount = result.responseData ? result.responseData.totalPayoffAmount : null;
                console.log('EarlySettlment for ' + loanId + ' = ' + payAmount);
                if (callback) callback(payAmount);
            } else {
                var errors = response.getError();
                console.error('Error in loadEarlySettlment for ' + loanId + ': ', errors);
                if (callback) callback(null);
            }
        });

        $A.enqueueAction(action);
}

    // omar end
})
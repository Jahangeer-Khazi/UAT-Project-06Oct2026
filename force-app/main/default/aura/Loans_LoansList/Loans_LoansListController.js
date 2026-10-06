({
    init : function(component, event, helper) {
        console.log('--> customerId : '+component.get("v.customerId"));
        var caseId = component.get("v.caseId");
        if(caseId != null && caseId != '' && caseId.startsWith('500')){
            console.log('--> caseId : '+caseId);
            var action = component.get("c.caseRecordType");
            action.setParams({ "caseId": caseId });
    
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('recordType >> '+ response.getReturnValue());
                    component.set("v.recordTypeName", response.getReturnValue());
                    
    
                } else {
                    console.log('recordType not found>> ' );
                    console.log("Error: " + response.getError());
                }
            });
    
            $A.enqueueAction(action);
        }
     
        console.log('Loans_LTNG36_LoansList.js: Init Method 1');
        
        var isAlburaqProduct = component.get("v.isAlburaqProduct");

        var loanOrFinance = (isAlburaqProduct) ? 'Finance' : 'Loan';
        console.log('isAlburaqProduct ===> '+ isAlburaqProduct);
        console.log('loanOrFinance ===> '+ loanOrFinance);
        component.set('v.loanOrFinance', loanOrFinance);
        // // if (true === component.get('v.enableActions')) {
        // //     // add action buttons
        // //     rowLevelActions.push( { label: 'Request Cash Collection', name: 'request_cash_collection' });
        // //     rowLevelActions.push( { label: 'Request Cash Delivery', name: 'request_cash_delivery' });
        // // }
    
        var customerId = component.get('v.customerId');
        var selectedLoanStatus = component.get('v.selectedLoanStatus');
        console.log('selectedLoanStatus ',selectedLoanStatus);

        if (customerId) {
            helper.loadData(component, customerId, selectedLoanStatus);
        }
    },
    load: function (component, event, helper) {
        // Hide Loan details components
        component.set('v.displayLoanDetails', false);
        component.set('v.data', null);
        // //Deselect the already selected row
        // var loanListTable = component.find("loanListTable");
        // loanListTable.selectedRows = [];
        component.set('v.selectedRows', []);

        var customerId = component.get('v.customerId');
        var selectedLoanStatus = component.get('v.selectedLoanStatus');
        console.log('selectedLoanStatus ',selectedLoanStatus);
        helper.loadData(component, customerId, selectedLoanStatus);
    },
    
    handleRowAction: function (component, event, helper) {
         var action = event.getParam('action');
         var row = event.getParam('row');
         var customerId = component.get('v.customerId');
         switch (action.name) {
             case 'show_transactions':
                 helper.openTransactionList(component, customerId, row.id);
                 break;
         }
     },    
    handleRowSelection: function (component, event, helper) {
        var caseType = component.get('v.caseType');
        var subTypeCase = component.get('v.caseSubType');
        var loanIdToSelect = component.get('v.submittedLoanId');
        var isSubmitted = component.get('v.isSubmitted');
        if( isSubmitted){
            component.set("v.selectedRows", [loanIdToSelect]);
            console.log('The row selection was blocked. '+ loanIdToSelect);
            var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "You Cannot Change The Selected Loan!",
                            "message": "To select this Loan you need to create a new loan Service request case",
                            "type": "warning"
                        });
                        toastEvent.fire();
            return;
        }
        
        var customerId = component.get('v.customerId');
        
        var caseId = component.get('v.caseId');
        var selectedRows = event.getParam('selectedRows');
        console.log('selectedRows shubham '+JSON.stringify(selectedRows));
        component.set('v.selectedRows', selectedRows);
        
        // Display that id of the selected row
        for (var i = 0; i < selectedRows.length; i++){
             // Omar - start
             console.log("On selection Status--------> ", selectedRows[i].LoanStatus);

        
        
            // omar start 
            let currentData = component.get('v.data') || [];
            
            // Reset all rows to their default state based on status
            currentData.forEach(row => {
                if (row.LoanStatus && row.LoanStatus.toLowerCase() === 'overdue') {
                    row.rowColorClass = 'overdue-hover'; // Keep overdue styling
                } else {
                    row.rowColorClass = '';
                }
            });

            // If selected loan is overdue, add BOTH classes
            if (selectedRows.length > 0 && selectedRows[i].LoanStatus && selectedRows[i].LoanStatus.toLowerCase() === "overdue") {
               
                const selectedId = selectedRows[i].Id || selectedRows[i].id;
                 console.log('this is overdue !!!' + selectedId)
                currentData.forEach(row => {
                    if ((row.Id || row.id) === selectedId) {
                           console.log('this is overdue !!!' + row.Id + ' ... ' + row.id +' ... ' + row.rowColorClass )
                        row.rowColorClass = 'overdue-hover selected-row'; 
                    }
                });
            }

            component.set('v.data', currentData);
            // omar end


            component.set('v.isHandOffVisible',true);
            console.log("selectedRows[i].paidInstallment--------> ", selectedRows[i].paidInstallment);
            console.log("selectedRows[i].payAmount--------> ", selectedRows[i].payAmount);//#CH02
            component.set('v.selectedPayOffAmount',selectedRows[i].payAmount);//#CH02

            console.log("subTypeCase--------> ", subTypeCase);

            if(  caseType == 'New Loan / Finance Service Request' && selectedRows[i].LoanStatus && selectedRows[i].LoanStatus.toLowerCase() == "closed"){
                component.set("v.selectedRows", [loanIdToSelect]);
                console.log('The row selection was with wrong status. '+ loanIdToSelect);
                var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "You Cannot Select a Loan with Status : "+selectedRows[i].LoanStatus+ "!",
                                "message": "You Cannot Select a Loan with Status : "+selectedRows[i].LoanStatus+ "!",
                                "type": "warning"
                            });
                            toastEvent.fire();
                return;
            }

            if(  caseType == 'New Loan / Finance Service Request' && subTypeCase != 'Fees Reversal / Waivers' && subTypeCase != 'Restructuring' && subTypeCase != 'Instalment Deferment / Postponement' && selectedRows[i].LoanStatus && selectedRows[i].LoanStatus.toLowerCase() != "active"){
                component.set("v.selectedRows", [loanIdToSelect]);
                console.log('The row selection was with wrong status. '+ loanIdToSelect);
                var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "You Cannot Select a Loan with Status : "+selectedRows[i].LoanStatus+ "!",
                                "message": "You Cannot Select a Loan with Status : "+selectedRows[i].LoanStatus+ "!",
                                "type": "warning"
                            });
                            toastEvent.fire();
                return;
            }
            if( selectedRows[i].paidInstallment != null ) {
                if(subTypeCase == 'Top-up'){
                    let loanTopUpSettlementNumber = Number(component.get('v.loanTopUpSettlementNumber'));
                    if( Number(selectedRows[i].paidInstallment) < loanTopUpSettlementNumber ){
                        console.log("v.isHandOffVisible Top-up --------> false");
                        component.set('v.isHandOffVisible',false);
                        component.set('v.loanPaidNumber',loanTopUpSettlementNumber);
                    }
                }
                else if(subTypeCase == 'Restructuring'){
                    let loanRestructuringSettlementNumber = Number(component.get('v.loanRestructuringSettlementNumber'));
                    if( Number(selectedRows[i].paidInstallment) < loanRestructuringSettlementNumber ){
                        console.log("v.isHandOffVisible Restructuring --------> false");
                        component.set('v.isHandOffVisible',false);
                        component.set('v.loanPaidNumber',loanRestructuringSettlementNumber);
                    }
                }
                else if(subTypeCase == 'Early Settlement' || subTypeCase == 'Partial Settlement' || subTypeCase == 'Advance Payment'  || subTypeCase == 'Fees Reversal / Waivers'){
                    //toDo : later if needed and use these variables to do the comparaison 
                    /*
                    let loanFeesReversalSettlementNumber = Number(component.get('v.loanFeesReversalSettlementNumber'));
                    let loanAdvancePaymentSettlementNumber = Number(component.get('v.loanAdvancePaymentSettlementNumber'));
                    let loanPartialSettlementNumber = Number(component.get('v.loanPartialSettlementNumber'));
                    let loanEarlySettlementNumber = Number(component.get('v.loanEarlySettlementNumber'));
                    */
                }
            }

            // if(selectedRows[i].LoanStatus.toLowerCase() !== 'active'){
            //       var toastEvent = $A.get("e.force:showToast");
            //        toastEvent.setParams({
            //         "type": "warning",
            //         "title": "Warning!",
            //         "message": "Select an Active Loan"
            //     });
            //     toastEvent.fire();
            // }
            // Omar - End
            var loanId = selectedRows[i].id;           
                    
            console.log("---------On selection loanId--------> ", loanId);
            //helper.openLoanDetails(component, component.get('v.customerId'), loanId);
            
            setTimeout($A.getCallback(function() {
                helper.openLoanDetails(component, component.get('v.customerId'), loanId);
            }), 0);

            /*
                var action = component.get('c.getCaseRecord');
                action.setParams({
                    caseId: caseId
                });

                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('second : ', state);
                    var caseRecord = response.getReturnValue();
                    if (state == 'SUCCESS' && caseRecord != null) {
                        
                        var caseLoanId = caseRecord.Loan_Application_ID__c;

                        console.log('caseLoanId: ', caseLoanId);
                        
                        
                        if (loanId !== caseLoanId && caseLoanId !== undefined) {
                            
                            component.set('v.isLoanExist', false);

                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Create a new Case for this Loan",
                                "message": "To select this Loan you need to create a new loan Service request case",
                                "type": "warning"
                            });
                            toastEvent.fire();
                        }  
                        else  {
                            component.set('v.isLoanExist', true);
                            //pass the ID to Bank card list controller
                            var getAccountIdevent = $A.get("e.c:PassAccountIdEvent");
                            if(getAccountIdevent){
                                getAccountIdevent.setParams({
                                    "globalAccountId": loanId
                                    });
                                var test = getAccountIdevent.getParam("globalAccountId");
                                //alert("global account ID is set in Bank account list to  " +test);
                                console.log("global account ID is set in Bank account list to  ", test);
                                getAccountIdevent.fire();
                            }

                            helper.openLoanDetails(component, component.get('v.customerId'), loanId);
                        }
        
                    
                    } else {
                        component.set('v.isLoanExist', true);
                        //pass the ID to Bank card list controller
                            var getAccountIdevent = $A.get("e.c:PassAccountIdEvent");
                            if(getAccountIdevent){
                                getAccountIdevent.setParams({
                                    "globalAccountId": loanId
                                    });
                                var test = getAccountIdevent.getParam("globalAccountId");
                                //alert("global account ID is set in Bank account list to  " +test);
                                console.log("global account ID is set in Bank account list to  ", test);
                                getAccountIdevent.fire();
                            }

                            helper.openLoanDetails(component, component.get('v.customerId'), loanId);
                    }
                });

                $A.enqueueAction(action);
            */
            break;
        }
 
    },
})
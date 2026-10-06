({
	init : function(component, event, helper) {
        try {
            //omar - start
        
        console.log('1 --->',component.get("v.page"));
        console.log('2 --->',component.get("v.viewReccPay"));
        let page =  component.get('v.page');
        let columns = [];
        //toDo : based on "page" we will decide what columns to display on the table!!
        if(page == 'customer'){
            var isAlburaqProduct = component.get("v.isAlburaqProduct");
            console.log('isAlburaqProduct ===> '+ isAlburaqProduct);
            var loanOrFinance = (isAlburaqProduct) ? 'Finance' : 'Loan';
            console.log('loanOrFinance ===> '+ loanOrFinance);
            component.set('v.loanOrFinance', loanOrFinance);
            var InterestOrProfit = (isAlburaqProduct) ? 'Profit' : 'Interest';
            console.log('InterestOrProfit ===> '+ InterestOrProfit);
            component.set('v.InterestOrProfit', InterestOrProfit);
            //columns.push({ label: 'Status', fieldName: 'status', type: 'text', sortable: true });
            //columns.push({ label: 'Payment Type', fieldName: 'PaymentType', type: 'text', sortable: true });
            
        } else if (page == 'case') {
            var caseModel = component.find("caseModel").get("v.value");
            var loanOrFinance = (caseModel == 'alburaq') ? 'Finance' : 'Loan';
            var InterestOrProfit = (caseModel == 'alburaq') ? 'Profit' : 'Interest';
            component.set('v.loanOrFinance', loanOrFinance);
            component.set('v.InterestOrProfit', InterestOrProfit);
        }
        columns.push({ label: 'No.', fieldName: 'instalNo', type: 'text', sortable: true, wrapText: true, initialWidth: 80, minWidth: 80 });
        columns.push({ label: 'Installment Due Date', fieldName: 'instalDueDate', type: 'text', sortable: true, wrapText: true, initialWidth: 160, minWidth: 160 });
        
        if(page == 'customer'){
            columns.push({ label: 'Status', fieldName: 'billStatus', type: 'text', sortable: true, wrapText: true, initialWidth: 120, minWidth: 120 });
        }else if (page == 'case') {
            console.log('case page --->');
            /*var subtypeField = component.find("subtypeField").get("v.value");//NBA-16487
            console.log('subtypeField inside --->'+ subtypeField);
            if(subtypeField == 'Advance Payment' || subtypeField == 'Fees Reversal / Waivers'){//NBA-16487
            }*/
            columns.push({ label: 'Status', fieldName: 'billStatus', type: 'text', sortable: true, wrapText: true, initialWidth: 120, minWidth: 120 });
        }
        
        
        columns.push({ label: 'Monthly Installment (full amount)', fieldName: 'totalAmount', type: 'text', sortable: true, wrapText: true, initialWidth: 160, minWidth: 160});
        columns.push({ label: 'No. of Days (accrued no. of days of this installment)', fieldName: 'nbrInstaDays', type: 'text', sortable: true, wrapText: true, initialWidth: 160, minWidth: 160 });
        columns.push({ label: 'Beginning Balance', fieldName: 'beginBalance', type: 'text', sortable: true, wrapText: true, initialWidth: 160, minWidth: 160 });
        columns.push({ label: 'Monthly Insurance Fees (reducing balance)', fieldName: 'monthInsurance', type: 'text', sortable: true, wrapText: true, initialWidth: 160, minWidth: 160 });
        columns.push({ label: 'Monthly Insurance Fees (flat distribution)', fieldName: 'monthInsuranceFlat', type: 'text', sortable: true, wrapText: true, initialWidth: 160, minWidth: 160 });
        //columns.push({ label: 'Admin Fees (flat distribution)', fieldName: 'AdminFeeFlat', type: 'text', sortable: true, wrapText: true, initialWidth: 160, minWidth: 160 });
        //columns.push({ label: 'Admin Fees VAT', fieldName: 'AdminFeeVat', type: 'text', sortable: true, wrapText: true, initialWidth: 160, minWidth: 160 });
        columns.push({ label: 'Monthly Installment (excluding charges)', fieldName: 'monthInstaExc', type: 'text', sortable: true, wrapText: true, initialWidth: 160, minWidth: 160 });
        columns.push({ label: 'Principal Amount', fieldName: 'principalAmount', type: 'text', sortable: true, wrapText: true, initialWidth: 160, minWidth: 160 });
        columns.push({ label: 'Interest/Profit Amount', fieldName: 'interestAmount', type: 'text', sortable: true, wrapText: true, initialWidth: 160, minWidth: 160 });

        if(page == 'customer'){
            //columns.push({ label: 'Payment due', fieldName: 'Paymentdue', type: 'text', sortable: true });
        }
        columns.push({ label: 'Ending Balance', fieldName: 'endingBalance', type: 'text', sortable: true, wrapText: true, initialWidth: 160, minWidth: 160 });
        
        component.set('v.columns', columns);
        component.set('v.viewReccPay', false);

        //transaction cmp datable not used any more !! to remove this after!!!
        component.set('v.columnsDataPaymentDetails', [
            { label: 'Transaction Type', fieldName: 'transactionType', type: 'text', sortable: true },
            { label: 'Schedule Type', fieldName: 'scheduleType', type: 'text', sortable: true },
            { label: 'Settle Date', fieldName: 'settleDate', type: 'text', sortable: true },
            { label: 'Payment Date', fieldName: 'paymentDate', type: 'text', sortable: true },
            { label: 'Outstanding Amount', fieldName: 'outstandingAmount', type: 'text', sortable: true }
            
            // { label: 'Total Amount', fieldName: 'totalAmount', type: 'text', sortable: true },
        ]);
        //omar - end
        console.log('3 --->',component.get("v.page"));
        console.log('4 --->',component.get("v.viewReccPay"));
        console.log('5 --->',component.get("v.columns"));
        console.log('6 --->',component.get("v.columnsDataPaymentDetails"));
        } catch (error) {
            console.error(error);
        }
        
	},
    handleLoadOnCasePage: function (component, event, helper) {
        console.log('handleLoadOnCasePage');
		var action = component.get('c.getCaseRecord');
		action.setParams({
			caseId: component.get("v.recordId")
		 });
		
		action.setCallback(this, function(actionResult) {
			var statut = actionResult.getState();
			if (statut === 'SUCCESS') {
				let result = actionResult.getReturnValue();
				if (!$A.util.isEmpty(result)) {
                    component.set('v.subtypeCase', result.Sub_Type__c);
                    console.log("typeField --> " + result.Sub_Type__c);
                    if (result.CaseAnnex__r) {
                        component.set('v.Approved_Loan_Amount',result.CaseAnnex__r.cx_ln_Approved_Loan_Amount__c);
                        console.log("Approved_Loan_Amount --> " + result.CaseAnnex__r.cx_ln_Approved_Loan_Amount__c);

                    } else {
                        component.set('v.Approved_Loan_Amount', 0);
                        console.log("Approved_Loan_Amount --> " + 0);
                    }
                    helper.loadDataOnInit(component, helper);
				}
			} else if (statut === 'ERROR') {
				console.error(actionResult.getError());
				helper.handleErrors(actionResult.getError(), '');
			} else {
				console.error('OTHER ERROR');
			}
		});
	   $A.enqueueAction(action);
	},
	onLoadviewReccPayments: function (component, event, helper) {
        console.log('onLoadviewReccPayments');
        helper.loadData(component,helper);
	},
	handleRowSelection: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        // Display that id of the selected row
        for (var i = 0; i < selectedRows.length; i++){
            var schedulRecPayId = selectedRows[i].id;
            console.log("---------On selection schedulRecPayId--------", schedulRecPayId);
            helper.openSchedulRecPayDetails(component,helper,schedulRecPayId);
            break;
        }
    },  
    generateCasePDF:function(component, event, helper){
        var caseId = component.get("v.recordId");
        console.log("caseId ",caseId);
        var encodedCaseId = btoa(caseId);
        var encodedPgName = btoa('case');
        var vfPageUrl = '/apex/loanPaymentScheduleVF?caseId=' + encodeURIComponent(encodedCaseId) +
                	'&pageName=' + encodeURIComponent(encodedPgName);
            window.open(vfPageUrl, '_blank');
    },
    generateCaseExcel:function(component, event, helper){
        var caseId = component.get("v.recordId");
        console.log("caseId ",caseId);
        var encodedCaseId = btoa(caseId);
        var encodedPgName = btoa('case');
        var vfPageUrl = '/apex/loanPaymentScheduleExcel?caseId=' + encodeURIComponent(encodedCaseId) +
                	'&pageName=' + encodeURIComponent(encodedPgName);
            window.open(vfPageUrl, '_blank');
    },
    generateActiveLoanExcel: function(component, event, helper) {
    	console.log("PDF is Getting generated. ");
        helper.generateFile(component, event, helper,"excel");
    },
    generatePDF: function(component, event, helper) {
    	console.log("PDF is Getting generated. ");
        helper.generateFile(component, event, helper,"pdf");
    },
	generateFile: function(component, event, helper,fileType) {
        var customerCIFNo = component.get('v.customerId');
        console.log('Customer CIF Number:',customerId);
        
        var loanFacilityNumber = component.get('v.loanFacilityNumber');
        console.log('Customer loanFacilityNumber >>> ',loanFacilityNumber);
            
        var selLoanId = component.get('v.loanId');
        console.log('Selected Loan Id:',selLoanId);
        
        var isAlburaqProduct = component.get("v.isAlburaqProduct");
        
        var accDetails = component.get('v.account');
        var customerId = accDetails.Id;
        console.log('Account Details:',JSON.stringify(accDetails));
        console.log('Account Details:',accDetails.Name);
        console.log('Account Region Flag:',accDetails.Region_Flag__c);
        var accName = accDetails.Name;
        var regionName = accDetails.Region_Flag__c;
        
        if(component.get('v.isAlburaqProduct') == true){
			regionName += '_alburaq';
		}
        
        // Encode parameters in base64
        var encodedIsAlburaqProduct = btoa(isAlburaqProduct);
        var encodedloanFacilityNumber = btoa(loanFacilityNumber);
        console.log("Original customerId: ", customerId);
        var encodedcustomerId = btoa(customerId);
        var encodedcustomerCIFNo = btoa(customerCIFNo);
        console.log("Encoded customerId: ", encodedcustomerId);
        
        console.log("Original selLoanId: ", selLoanId);
        var encodedselLoanId = btoa(selLoanId);
        console.log("Encoded selLoanId: ", encodedselLoanId);
        
        console.log("Original accName: ", accName);
        var encodedaccName = btoa(accName);
        console.log("Encoded accName: ", encodedaccName);
        
        console.log("Original regionName: ", regionName);
        var encodedRegName = btoa(regionName);
        console.log("Encoded regionName: ", encodedRegName);

        var repaymentDataData = component.get("v.data");
		console.log("data retrieved: "+JSON.stringify(repaymentDataData));
        
        const pgName = component.get("v.page");
        var encodedPgName = btoa(pgName);
        console.log("Encoded pgName: ", encodedPgName);
        
        const scheduleType = component.get('v.scheduleType');
        console.log("scheduleType: ", scheduleType);
        const encodedScheduleType = btoa(scheduleType);
        console.log("encodedScheduleType: ", encodedScheduleType);
        
        console.log('Transaction Data Length in Search:',repaymentDataData.length);
        console.log('encodeURIComponent Search:',encodeURIComponent(encodedaccName) );
        if(repaymentDataData.length > 0){

            
            var vfPageUrl = '/apex/loanPaymentScheduleVF?accName=' + encodeURIComponent(encodedaccName) +
                        '&customerId=' + encodeURIComponent(encodedcustomerId) +
                		'&customerCIFNo=' + encodeURIComponent(encodedcustomerCIFNo) +
                        '&selLoanId=' + encodeURIComponent(encodedselLoanId) +
                        '&regionName=' + encodeURIComponent(encodedRegName)+
                    '&loanFacilityNumber=' + encodeURIComponent(encodedloanFacilityNumber)+
                	'&pageName=' + encodeURIComponent(encodedPgName)+
                	'&scheduleType=' + encodeURIComponent(encodedScheduleType) +
                	'&isAlburaq=' + encodeURIComponent(encodedIsAlburaqProduct);
            console.log('vfpageurl ', vfPageUrl);
            window.open(vfPageUrl, '_blank');
        }
        else{
            component.set('v.errorPage',true);
        }
    },
    handleLwcMessage: function(component, message, helper) {
        // “message” contains the JSON payload you published
        if (message != null && message.getParam("notify") == true) {
            let page =  component.get('v.page');
            if(page == 'case'){
                console.log("handleLwcMessage triggered on aura 'Loans_PaymentSchedule.cmp' --->>> ");
                helper.loadDataOnInit(component, helper);
            }
        }
    }
       	
})
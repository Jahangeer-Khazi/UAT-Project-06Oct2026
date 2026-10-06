({
	loadDataOnInit: function (component,helper) {
		console.log('loadDataOnInit Payments Schedule ');
		
		var caseId = component.get("v.recordId");

		
		var action = component.get('c.getSimulationPaymentList');
		action.setParams({
			caseId: caseId,
			saveLog : false
		 });
		
		action.setCallback(this, function(actionResult) {
			var statut = actionResult.getState();
			if (statut === 'SUCCESS') {
				let result = actionResult.getReturnValue();
				console.log('repayment schedule result => ', result);
				var data = [];
				
				// Helper function to apply 3-decimal formatting safely
				const format = (val) => val != null ? parseFloat(val).toFixed(3) : null;
				
				if (result.isSuccess && !$A.util.isEmpty(result.responseData)) {
					var responseResult = result.responseData;
					let subtypeCase = component.get('v.subtypeCase');
					let approvedLoanAmount = Number(component.get('v.Approved_Loan_Amount')) || 0;
					
					for (var i = 0; i < responseResult.length; i++) {
						var payment = responseResult[i];
						// console.log('payment is  >> '+JSON.stringify(payment))
						//toDo : do mapping for the response related to simulation api response !!
						console.log("testtt222 --> "+format(payment.monthlyInsuranceFeesReducing));
						data.push({
							paymentDate: helper.updateDateFormat(payment.paymentDate),
							billStatus: payment.billStatus,//NBA-16487
							instalDueDate: helper.updateDateFormat(payment.installmentDueDate),
							totalAmount: helper.formatCurrency(format(payment.monthlyInstallmentFull)), 
							nbrInstaDays: payment.noOfDays,
							beginBalance: helper.formatCurrency(format(payment.beginningBalance)),
							principalAmount: helper.formatCurrency(format(payment.principalAmount)),
							interestAmount: helper.formatCurrency(format(payment.interestAmount)),
							AdminFeeVat: helper.formatCurrency(format(payment.adminFeesVat)),
							instalNo: payment.installmentNo,
							monthInsurance: helper.formatCurrency(format(payment.monthlyInsuranceFeesReducing)),
							monthInsuranceFlat: helper.formatCurrency(format(payment.monthlyInsuranceFeesFlat)),
							AdminFeeFlat: helper.formatCurrency(format(payment.adminFeesFlat)),
							monthInstaExc: helper.formatCurrency(format(payment.monthlyInstallmentExcludingCharges)),
							endingBalance: helper.formatCurrency(format(payment.endingBalance)),
							OutstandingBalance: helper.formatCurrency(format(payment.outstandingAmount))
						});
					}
                    result.headerData.totalCostOfLoan = helper.formatCurrency(result.headerData.totalCostOfLoan);
               	    result.headerData.principleAmount = helper.formatCurrency(result.headerData.principleAmount);
					//#CH02 : Start
					let remainingPrincipalAmount = Number(result.headerData.remainingPrincipalAmount) || 0;
               	    result.headerData.remainingPrincipalAmount = helper.formatCurrency(result.headerData.remainingPrincipalAmount);
					console.log(" remainingPrincipalAmount --> "+ remainingPrincipalAmount );
					//console.log(" approvedLoanAmount --> "+ approvedLoanAmount );
					if(subtypeCase == 'Top-up'){
						let calcul = remainingPrincipalAmount;
						console.log(" Top-up --> "+ calcul );
						result.headerData.principleAmountChanged = helper.formatCurrency(calcul);
					}
					else if(subtypeCase == 'Partial Settlement'){
						let calcul = remainingPrincipalAmount;
						console.log(" Partial Settlement --> "+ calcul );
						result.headerData.principleAmountChanged = helper.formatCurrency(calcul);
					}
					//#CH02 : End

					console.log('testtttt1 principleAmount --> '+ result.headerData.principleAmount);
					console.log('testtttt1 remainingPrincipalAmount --> '+ result.headerData.remainingPrincipalAmount);
                    result.headerData.monthlyInstallment = helper.formatCurrency(result.headerData.nextInstallmentAmount);//change it from "monthlyInstallment" to "nextInstallmentAmount" (UATNB-210713)
                    result.headerData.cashInHand = helper.formatCurrency(result.headerData.cashInHand);
                    result.headerData.administrationFeesVat = helper.formatCurrency(result.headerData.administrationFeesVat);
                    result.headerData.totalInterest = helper.formatCurrency(result.headerData.totalInterest);
                    result.headerData.insuranceAmount = helper.formatCurrency(result.headerData.insuranceAmount);
                    result.headerData.administrationFees = helper.formatCurrency(result.headerData.administrationFees);
                    
                    //updating the date format
                    result.headerData.firstInstallmentDate = helper.updateDateFormat(result.headerData.firstInstallmentDate);
                    result.headerData.firstInterestAccrualDate = helper.updateDateFormat(result.headerData.firstInterestAccrualDate);
                    result.headerData.lastInstallmentDate = helper.updateDateFormat(result.headerData.lastInstallmentDate);
                    result.headerData.loanStartDate = helper.updateDateFormat(result.headerData.loanStartDate);
                    result.headerData.maturityDate = helper.updateDateFormat(result.headerData.maturityDate);
                    
                   	result.headerData.interestRate = helper.formatCurrency(result.headerData.interestRate);
					component.set('v.headerData', result.headerData);
					component.set('v.data', data);
					component.set('v.viewReccPay', true);
				}else {
					console.log("error from api : "+result.errorData.message);
					helper.handleErrors(result.errorData.message, '');
				}
 
			} else if (statut === 'ERROR') {
				console.error(actionResult.getError());
				helper.handleErrors(actionResult.getError(), '');
			} else {
				console.error('OTHER ERROR');
			}
		});

	   $A.enqueueAction(action);
	   // End Call Paymenr Schedule API
	},
	/*loadDataOnInit: function (component,helper) {
		console.log('loadDataOnInit Payments Schedule ');
		
		var customerId = component.find("customerIdField").get("v.value");
		//var LoanApplicationId = component.find("LoanApplicationId").get("v.value");

		component.find('apexService').request(component.get('c.callLoanOptionsAPI'), {
            caseId : component.get("v.recordId")
            },
            function(response) {
                var result = response.getReturnValue();
                var pendingLoans = result.responseData.pendingLoans;
                console.log('result Loan Types pendingLoans: ', pendingLoans);
                var LoanApplicationId = component.find("LoanApplicationId").get("v.value");
                console.log("LoanApplicationId: " + LoanApplicationId);
                // var fieldMap = [];
				var loanObj;
                for(var key in pendingLoans){
					console.log('result Loan Type pendingLoan: ', pendingLoans[key].applicationId);
		
                    if (pendingLoans[key].applicationId == LoanApplicationId) {
						component.set("v.pendingLoan", pendingLoans[key]);
						loanObj = pendingLoans[key]
					}
                }
				console.log('result Final pending Loan: ', loanObj);

				// Call Payment schedule API

				 if (!loanObj) {
					return;
				 }
				console.log('Loan loanObj : '+ loanObj);
				var searchParametersJson = {
                 	"arrangementId": loanObj.arrangementId, 
					"loanFacilityNumber": loanObj.simRef,
					"type": "Simulation"
					};
					
              
				console.log('searchParametersJson : ', JSON.stringify(searchParametersJson));
				// viewReccPay
				component.set("v.viewReccPay", true);
				
				// omar - start 
				var action = component.get('c.getPaymentList');
				action.setParams({
					customerId: customerId,
					searchParametersJson : JSON.stringify(searchParametersJson),
					
				});
		
				action.setCallback(this, function(actionResult) {
					var statut = actionResult.getState();
					if (statut === 'SUCCESS') {
						let result = actionResult.getReturnValue();
						console.log('repayment schedule result => ', result);
						var data = [];
		
						if (result.isSuccess && !$A.util.isEmpty(result.responseData)) {
							var responseResult = result.responseData;
		
							for (var i = 0; i < responseResult.length; i++) {
								var payment = responseResult[i];
								// console.log('payment is  >> '+JSON.stringify(payment))
								
								data.push({
									paymentDate: payment.paymentDate,
									instalDueDate: '{!}',
									totalAmount: payment.totalAmount,
									nbrInstaDays: '{!}',
									beginBalance: '{!}',
									principalAmount: payment.principalAmount,
									interestAmount: payment.interestAmount,
									AdminFeeVat:  (payment.adminFeesFlat ? payment.adminFeesFlat : 0) +  (payment.adminFeesVat ? payment.adminFeesVat : 0) ,
									instalNo: '{!}',
									monthInsurance: '{!}',
									monthInsuranceFlat: '{!}',
									AdminFeeFlat: '{!}',
									monthInstaExc: '{!}',
									endingBalance: '{!}',
									Insurance: payment.monthlyInsuranceFeesFlat,
									OutstandingBalance: payment.outstandingAmount
								});
							}
						}
						component.set('v.headerData', result.headerData);
						component.set('v.data', data);
						component.set('v.viewReccPay', true);
		
					} else if (statut === 'ERROR') {
						console.error(actionResult.getError());
						helper.handleErrors(actionResult.getError(), '');
					} else {
						console.error('OTHER ERROR');
					}
				});
		
				$A.enqueueAction(action);
				// End Call Paymenr Schedule API

                });

	},*/
	loadData: function (component,helper) {
		console.log('loadData Payments Schedule ');
		
		var customerId = component.get('v.customerId');
		var arrangementId = component.get('v.loanId');
		var scheduleType = component.get('v.scheduleType');

		var searchParametersJson = {
			"arrangementId": arrangementId, 
			"type": scheduleType
			};
		// var searchParametersJson = {"crmCaseId": "500Pw00000K6ZHJIA3","simulationReference":"AASIM25177B9ZQPZYZ","type": "Simulation"}
		console.log('searchParametersJson : ', JSON.stringify(searchParametersJson));
		// viewReccPay
		var account = component.get('v.account');
		var regionName = account.Region_Flag__c;
		if(component.get('v.isAlburaqProduct') == true){
			regionName += '_alburaq';
		}
        
        component.find('apexService').request(component.get('c.getPaymentList'), {
		    customerId: customerId,
            searchParametersJson : JSON.stringify(searchParametersJson),
			regionName: regionName
        },
		function(response) {
			console.log('repayment schedule response:',response);
			var statut = response.getState();
			
            if (statut === 'SUCCESS') {
                let result = response.getReturnValue();
                var data = [];
				console.log('repayment schedule response:',result);

				// Helper function to apply 3-decimal formatting safely
				const format = (val) => val != null ? parseFloat(val).toFixed(3) : null;


                if (result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                    var responseResult = result.responseData;

                    for (var i = 0; i < responseResult.length; i++) {
                        var payment = responseResult[i];
                        // console.log('payment is  >> '+JSON.stringify(payment))
						//toDo : do mapping for the response related to Schedule api response !!
						console.log("testtt1 --> "+format(payment.monthlyInsuranceFeesReducing));

						data.push({
							paymentDate: helper.updateDateFormat(payment.paymentDate),
                            billStatus: payment.billStatus,
							instalDueDate: helper.updateDateFormat(payment.installmentDueDate),
							totalAmount: helper.formatCurrency(format(payment.monthlyInstallmentFull)), 
							nbrInstaDays: payment.noOfDays,
						    beginBalance: helper.formatCurrency(format(payment.beginningBalance)),
							principalAmount: helper.formatCurrency(format(payment.principalAmount)),
							interestAmount: helper.formatCurrency(format(payment.interestAmount)),
							AdminFeeVat: helper.formatCurrency(format(payment.adminFeesVat)),
							instalNo: payment.installmentNo,
							monthInsurance: helper.formatCurrency(format(payment.monthlyInsuranceFeesReducing)),
							monthInsuranceFlat: helper.formatCurrency(format(payment.monthlyInsuranceFeesFlat)),
							AdminFeeFlat: helper.formatCurrency(format(payment.adminFeesFlat)),
							monthInstaExc: helper.formatCurrency(format(payment.monthlyInstallmentExcludingCharges)),
							endingBalance: helper.formatCurrency(format(payment.endingBalance)),
							OutstandingBalance: helper.formatCurrency(format(payment.outstandingAmount))
						});
                    }
                   
                    result.headerData.totalCostOfLoan = helper.formatCurrency(result.headerData.totalCostOfLoan);
               	    result.headerData.principleAmount = helper.formatCurrency(result.headerData.principleAmount);
					result.headerData.remainingPrincipalAmount = helper.formatCurrency(result.headerData.remainingPrincipalAmount);//#CH02
					console.log('testtttt principleAmount --> '+ result.headerData.principleAmount);
					console.log('testtttt remainingPrincipalAmount --> '+ result.headerData.remainingPrincipalAmount);
                    result.headerData.monthlyInstallment = helper.formatCurrency(result.headerData.nextInstallmentAmount);//change it from "monthlyInstallment" to "nextInstallmentAmount" (UATNB-210713)
                    result.headerData.cashInHand = helper.formatCurrency(result.headerData.cashInHand);
                    result.headerData.administrationFeesVat = helper.formatCurrency(result.headerData.administrationFeesVat);
                    result.headerData.totalInterest = helper.formatCurrency(result.headerData.totalInterest);
                    result.headerData.insuranceAmount = helper.formatCurrency(result.headerData.insuranceAmount);
                    result.headerData.administrationFees = helper.formatCurrency(result.headerData.administrationFees);
                    
                    //updating the date format
                    result.headerData.firstInstallmentDate = helper.updateDateFormat(result.headerData.firstInstallmentDate);
                    result.headerData.firstInterestAccrualDate = helper.updateDateFormat(result.headerData.firstInterestAccrualDate);
                    result.headerData.lastInstallmentDate = helper.updateDateFormat(result.headerData.lastInstallmentDate);
                    result.headerData.loanStartDate = helper.updateDateFormat(result.headerData.loanStartDate);
                    result.headerData.maturityDate = helper.updateDateFormat(result.headerData.maturityDate);
                    
                   	result.headerData.interestRate = helper.formatCurrency(result.headerData.interestRate);
                    console.log("v.headerData ",result.headerData);
					component.set('v.headerData', result.headerData);
					component.set('v.data', data);
					component.set('v.viewReccPay', true);
                }
				

            } else if (statut === 'ERROR') {
                console.error(actionResult.getError());
                helper.handleErrors(actionResult.getError(), '');
            } else {
                console.error('OTHER ERROR');
            }
		});

        // omar - start 
        // var action = component.get('c.getPaymentList');
        // action.setParams({
        //     customerId: customerId,
        //     searchParametersJson : JSON.stringify(searchParametersJson),
            
        // });

        // action.setCallback(this, function(actionResult) {
        //     var statut = actionResult.getState();
		// 	component.set('v.showSpinner', false);
        //     if (statut === 'SUCCESS') {
        //         let result = actionResult.getReturnValue();
        //         var data = [];
		// 		console.log('repayment schedule response:',result);
        //         if (result.isSuccess && !$A.util.isEmpty(result.responseData)) {
        //             var responseResult = result.responseData;

        //             for (var i = 0; i < responseResult.length; i++) {
        //                 var payment = responseResult[i];
        //                 // console.log('payment is  >> '+JSON.stringify(payment))
		// 				//toDo : do mapping for the response related to Schedule api response !!
		// 				data.push({
		// 					paymentDate: payment.paymentDate,
		// 					instalDueDate: payment.installmentDueDate,
		// 					totalAmount: payment.monthlyInstallmentFull, 
		// 					nbrInstaDays: payment.noOfDays,
		// 					beginBalance: payment.beginningBalance,
		// 					principalAmount: payment.principalAmount,
		// 					interestAmount: payment.interestAmount,
		// 					AdminFeeVat: payment.adminFeesVat,
		// 					instalNo: payment.installmentNo,
		// 					monthInsurance: payment.monthlyInsuranceFeesReducing,
		// 					monthInsuranceFlat: payment.monthlyInsuranceFeesFlat,
		// 					AdminFeeFlat: payment.adminFeesFlat,
		// 					monthInstaExc: payment.monthlyInstallmentExcludingCharges,
		// 					endingBalance: payment.endingBalance,
		// 					OutstandingBalance: payment.outstandingAmount
		// 				});
        //             }
		// 			component.set('v.headerData', result.headerData);
		// 			component.set('v.data', data);
		// 			component.set('v.viewReccPay', true);
        //         }
				

        //     } else if (statut === 'ERROR') {
        //         console.error(actionResult.getError());
        //         helper.handleErrors(actionResult.getError(), '');
        //     } else {
        //         console.error('OTHER ERROR');
        //     }
        // });

        // $A.enqueueAction(action);
   
    // omar - end 
	},
    formatCurrency: function(number) {
        
        if (number === null || number === undefined || number === '') {
            return '0.000';
        }
        const num = typeof number === 'string' ? parseFloat(number) : number;
        
        if (isNaN(num)) {
            return '0.000';
        }
        
        return   num.toLocaleString('en-US', {
            minimumFractionDigits: 3,
            maximumFractionDigits: 3
        });
    },
	
	/*loadData: function (component,helper) {
		console.log('loadData Payments Schedule ');
		
		var customerId = component.get('v.customerId');
        var loanObj;
		var loanId = component.get('v.loanId');
		var responseLoanListdata = component.get('v.responseLoanListdata');
		var scheduleType = component.get('v.scheduleType');
        for (var i = 0; i < responseLoanListdata.currentLoans.length; i++) {
            
            if(responseLoanListdata.currentLoans[i].arrangementId == loanId ){
                loanObj = responseLoanListdata.currentLoans[i];
                break;
            }
        }
        component.set("v.loanFacilityNumber",loanObj.loanFacilityNumber);
		component.set("v.pendingLoan",loanObj);
        console.log('Loan loanObj : '+ loanObj);
		var searchParametersJson = {
			"arrangementId": loanObj.arrangementId, 
			"loanFacilityNumber": loanObj.loanFacilityNumber,
			"type": scheduleType
			};
		console.log('searchParametersJson : ', JSON.stringify(searchParametersJson));
		// viewReccPay
        component.set("v.viewReccPay", true);
        
        // omar - start 
        var action = component.get('c.getPaymentList');
        action.setParams({
            customerId: customerId,
            searchParametersJson : JSON.stringify(searchParametersJson),
            
        });

        action.setCallback(this, function(actionResult) {
            var statut = actionResult.getState();
            if (statut === 'SUCCESS') {
                let result = actionResult.getReturnValue();
                var data = [];
				console.log('repayment schedule response:',result);
                if (result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                    var responseResult = result.responseData;

                    for (var i = 0; i < responseResult.length; i++) {
                        var payment = responseResult[i];
                        // console.log('payment is  >> '+JSON.stringify(payment))
                     
						data.push({
							status: payment.scheduleType,
							PaymentType: payment.transactionType,
							paymentDate: payment.paymentDate,
							instalDueDate: '{!}',
							totalAmount: payment.totalAmount,
							nbrInstaDays: '{!}',
							beginBalance: '{!}',
							principalAmount: payment.principalAmount,
							interestAmount: payment.interestAmount,
							AdminFeeVat:  (payment.adminFeesFlat ? payment.adminFeesFlat : 0) +  (payment.adminFeesVat ? payment.adminFeesVat : 0) ,
							instalNo: '{!}',
							monthInsurance: '{!}',
							monthInsuranceFlat: '{!}',
							AdminFeeFlat: '{!}',
							monthInstaExc: '{!}',
							endingBalance: '{!}',
							Insurance: payment.monthlyInsuranceFeesFlat,
							Paymentdue: payment.Paymentdue,
							OutstandingBalance: payment.outstandingAmount
						});
                    }
                }
				component.set('v.headerData', result.headerData);
                component.set('v.data', data);
                component.set('v.viewReccPay', true);

            } else if (statut === 'ERROR') {
                console.error(actionResult.getError());
                helper.handleErrors(actionResult.getError(), '');
            } else {
                console.error('OTHER ERROR');
            }
        });

        $A.enqueueAction(action);
   
    // omar - end 
	},*/

	/*
 	formatData: function (component, recPayObj) {
		var result = {};
		result.id = recPayObj.id;
		result.scheduleId = recPayObj.id;
		result.amount = recPayObj.currency +' '+ recPayObj.amount;
		if(recPayObj.account){
			result.sourceAccount = recPayObj.account.iban;
		}
		result.frequency = recPayObj.frequency;
		result.startDate = recPayObj.startDate;
		result.nextPaymentDate = recPayObj.nextPaymentDate;
		result.status = recPayObj.status;
		result.endOfTheMonth = recPayObj.endOfMonth;
		return result;

	},
    */

	/*openSchedulRecPayDetails: function (component, helper,schedulRecPayId) {
		var customerId = component.get('v.customerId');
		/* var requestData = {
            schedulRecPayId: schedulRecPayId
        } */
	/*	console.log('openSchedulRecPayDetails LTNG23_PLaRecurringPaymentsHelper : schedulRecPayId = ' + schedulRecPayId );
		var action = component.get('c.getSchedulRecPayDetails');
		action.setParams(
			{
				customerId: customerId,
				scheduleId: schedulRecPayId
			});

		action.setCallback(this, function (actionResult) {
			var statut = actionResult.getState();
			if (statut === "SUCCESS") {
				let result = actionResult.getReturnValue();
				var data = [];
				if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
					var responseResult = result.responseData;
					
					for (var i = 0; i < responseResult.paymentSchedules.length; i++) {
						var recPay = responseResult.paymentSchedules[i];
						data.push(helper.formatDataPaymentDetails(component, recPay,schedulRecPayId));
					}
				}
				component.set('v.dataPaymentDetails', data);
				component.set("v.viewPaymentDetails", true);
				component.set("v.scheduleId", schedulRecPayId);

			} else if (statut === "ERROR") {
				// Process error returned by server
				console.error(actionResult.getError());
				helper.handleErrors(actionResult.getError(), '');
			}
			else {
				console.error("AUTRE ERROR");
				// Handle other reponse states
			}
		});
		$A.enqueueAction(action);
	},
	formatDataPaymentDetails: function (component, payDetailsObj,schedulRecPayId) {

		var result = {};
		result.id = payDetailsObj.iban;
		result.scheduleId = schedulRecPayId;
		if(payDetailsObj.currency){
			result.amount = payDetailsObj.currency.code +' ' +payDetailsObj.amount;
		}
		result.sourceAccount = payDetailsObj.iban;
		result.transactionDate =  payDetailsObj.transactionDate;
		result.transactionPaymentStatus =  payDetailsObj.status;

		return result;

	},
*/
    
	handleErrors: function (errors, addError) {
		// Configure error toast
		let toastParams = {
			mode: "sticky",
			title: "Erreur",
			message: errors, // Default error message
			type: "error"
		};
		// Pass the error message if any
		if (errors && Array.isArray(errors) && errors.length > 0) {
			toastParams.message = addError + '' + errors[0].message;
		}
		// Fire error toast
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams(toastParams);
		toastEvent.fire();
	},
    updateDateFormat:function(dateString){
        console.log("updateDateFormat ",dateString);
        if(dateString && dateString.length == 10){ //10 is a total length of a date yyyy-mm-dd
            const arrDateComponent = dateString.split('-');
            if(arrDateComponent.length == 3){
                return arrDateComponent[2] + '-' + arrDateComponent[1] + '-' + arrDateComponent[0];
            }
            else {
                return dateString;
            }
        }
        return dateString;
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

            var pagePath = '/apex/loanPaymentScheduleVF?accName=';
            
            if(fileType == 'excel'){
                pagePath = '/apex/loanPaymentScheduleExcel?accName=';
            }
            
            var vfPageUrl = pagePath + encodeURIComponent(encodedaccName) +
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
    }
	/*getPendingLoan: function (component) {
        
        component.find('apexService').request(component.get('c.callLoanOptionsAPI'), {
            caseId : component.get("v.recordId")
            },
            function(response) {
                var result = response.getReturnValue();
                var pendingLoans = result.responseData.pendingLoans;
                console.log('result Loan Types pendingLoans: ', pendingLoans);
                var LoanApplicationId = component.find("LoanApplicationId").get("v.value");
                console.log("LoanApplicationId: " + LoanApplicationId);
                // var fieldMap = [];
                for(var key in pendingLoans){
					console.log('result Loan Type pendingLoan: ', pendingLoans[key].applicationId);
		
                    if (pendingLoans[key].applicationId == LoanApplicationId) {
						component.set("v.pendingLoan", pendingLoans[key]);
					}
                }
				console.log('result Final pending Loan: ', component.get("v.pendingLoan"));
                // component.set("v.pendingLoan", pendingLoan);
                });
            
    }*/
})
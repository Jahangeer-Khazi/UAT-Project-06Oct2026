({
	getPendingLoan: function (component, event, helper) {
        
        component.find('apexService').request(component.get('c.callLoanOptionsAPI'), {
            caseId : component.get("v.recordId")
            },
            function(response) {
                var result = response.getReturnValue();
                var pendingLoans = result.responseData.pendingLoans;
                console.log('Loans Options response: ', result.responseData);
                console.log('result Loan Types pendingLoans: ', pendingLoans);
                var LoanApplicationId = component.find("LoanApplicationId").get("v.value");
                console.log("LoanApplicationId: " + LoanApplicationId);
                // var fieldMap = [];
                for(var key in pendingLoans){
					console.log('result Loan Type pendingLoan: ', pendingLoans[key].applicationId);
		
                    if (pendingLoans[key].applicationId == LoanApplicationId) {
						component.set("v.pendingLoan", pendingLoans[key]);
                        
                        var pendingLoanStatus = pendingLoans[key].status;
                        if(pendingLoanStatus.toLowerCase().includes('pending')) {
                            component.set("v.pendingLoanstatus", 'Pending');

                        } else if(pendingLoanStatus.toLowerCase().includes('discrepancies')) {
                            component.set("v.pendingLoanstatus", 'Discrepancies');

                        } else if(pendingLoanStatus.toLowerCase().includes('review')) {
                            component.set("v.pendingLoanstatus", 'Review');

                        } else if(pendingLoanStatus.toLowerCase().includes('referred')) {
                            component.set("v.pendingLoanstatus", 'Referred');

                        } else if(pendingLoanStatus.toLowerCase().includes('closed')) {
                            component.set("v.pendingLoanstatus", 'Closed');
                        }  

						console.log('result Loan Type pendingLoan: ', pendingLoans[key]);
						break;
					}
                }
                
                var divElement = component.find("NoDataDivElement").getElement();
                // Remove the 'slds-hidden' class from the classList
                divElement.classList.remove("slds-hidden");

				console.log('result Final pending Loan: ', component.get("v.pendingLoan"));
                // component.set("v.pendingLoan", pendingLoan);
                });
            
    }
})
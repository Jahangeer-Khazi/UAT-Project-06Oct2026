({
    loadData : function(component, customerId, loanId, responseLoanListdata, responseLoanEarlySettlementdata) {
        console.log('loanDetails: loadData(customerId=' + customerId + ', loanId=' + loanId + ')');
        // var account = component.get('v.account');
	    var helper = this;
        var loanObj;
        for (var i = 0; i < responseLoanListdata.currentLoans.length; i++) {
            
            if(responseLoanListdata.currentLoans[i].arrangementId == loanId ){
                helper.loadEarlySettlment(component, customerId, loanId);
                // omar start
                helper.fetchApprovedCase(component, loanId);
                // omar end
                loanObj = responseLoanListdata.currentLoans[i];
                break;
            }
        }
        
         
        console.log('Loan responseLoanEarlySettlementdata : '+ JSON.stringify(responseLoanEarlySettlementdata));
        console.log('Loan Details loanObj : '+ JSON.stringify(loanObj));

        component.set('v.data', helper.formatData(component, loanObj));

        if (loanObj && loanObj.totalInstallments !== undefined && loanObj.paidInstallments !== undefined) {
            var remainingInstallments = parseInt(loanObj.totalInstallments) - parseInt(loanObj.paidInstallments);
            console.log('Loan Details remainingInstallments : '+ remainingInstallments);
            component.set('v.remainingInstallments', remainingInstallments);
        }
        

    },
    formatData: function(component, loanObj){
        var result = {};
        result.loan = loanObj;
        return result;
    },
    // omar start
    loadEarlySettlment : function(component, customerId, loanId) {
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
                console.log('earlySettlmentresponsedetails1: ', result);
                console.log('earlySettlmentresponsedetails2: ', result.responseData);
                console.log('earlySettlmentresponsedetails3: ', result.responseData.totalPayoffAmount);
                component.set('v.responseLoanEarlySettlementdata', result.responseData);
            } else {
                var errors = response.getError();
                console.error('Error in loadEarlySettlment: ', errors);
            }
        });

        $A.enqueueAction(action);
    },
    // omar end
    // omar start

     fetchApprovedCase : function(component, arrangementId) {
    var action = component.get("c.getApprovedCases"); // Use the same unified method
    action.setParams({
        arrangementIds: [arrangementId] // Pass as a list
    });

    action.setCallback(this, function(response) {
        if (response.getState() === "SUCCESS") {
            var caseMap = response.getReturnValue();
            // Get the first item from the map since we only sent one ID
            var result = caseMap[arrangementId]; 
            component.set('v.approvedCase', result);
        }
    });

    $A.enqueueAction(action);
}
    // omar end
})
({
    handleSectionToggle: function (component, event) {
        var openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            component.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            component.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },
    loadData : function(component) {

        //data table columns Display
        component.set('v.columns', [
            {label: 'Share Date', fieldName: 'shareDate'},
           // {label: 'Share Participant Amount', fieldName: 'amount', type: 'text'},
            {label: 'Receiver Name', fieldName: 'jameyaReceiverName', type: 'text'},
           // {label: 'Contribution Amount', fieldName: 'amount', type: 'text'},
           // {label: 'Participant Name', fieldName: 'name', type: 'text'},
           // {label: 'Pay Status', fieldName: 'participants.name', type: 'text'}
        ]);

        component.set('v.Partcolumns', [
           // {label: 'Share Date', fieldName: 'shareDate'},
           // {label: 'Receiver Name', fieldName: 'jameyaReceiverName', type: 'text'},
            {label: 'Participant Name', fieldName: 'name', type: 'text'},
            {label: 'Share Participant Amount', fieldName: 'amount', type: 'text'},
            {label: 'Contribution Amount', fieldName: 'amount', type: 'text'},
            {label: 'Pay Status', fieldName: 'payInStatus', type: 'text'}
        ]);

        var customerId = component.get('v.customerId');
        var jameyaId = component.get('v.jameyaId');
        var account = component.get('v.account');
        console.log('jamiyahAccountDetails: loadData(customerId=' + customerId + ', jameyaId=' + jameyaId + ')');

	    var helper = this;
		component.find('apexService').request(component.get('c.loadJamiyahAccountDetails'), {
		    customerId: customerId,
		    jameyaId: jameyaId,
		    regionName : account.Region_Flag__c
        },
		function(response) {
		    var result = response.getReturnValue();

            console.log('result detail', result);
            var data = {};

            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                data = result.responseData;
                component.set('v.data', data);
				console.log('data--->');
                console.log(data);
                var lstparticipants = data.participants;
                var lstshares = data.shares;
                var lstpayment = data.payments;
                //data.payments.participants;
                var lstpartPay={};

                console.log('---> Payments --> '+JSON.stringify(lstpayment));


                //loop to get the correct participant
                lstparticipants.forEach(participant => {
                    if(participant.fullName &&
                        data.organiserName &&
                        participant.fullName.toLowerCase() == data.organiserName.toLowerCase())
                        {
                            component.set("v.participant", participant);
                        }
                });

                lstshares.forEach(share => {
                    if(share.participantId == data.memberParticipantId)
                    {
                        component.set("v.share", share);
                    }
                });

                var parList=[];
                lstpayment.forEach(payment  => {
                    console.log('payment participants-->'+JSON.stringify(payment.participants));
                    parList.push(payment.participants);
                    component.set("v.payment", data.payments);
                });

                console.log('parPay-->'+JSON.stringify(parList));
                component.set("v.parPay",parList);
                console.log('component Data-->'+component.get("v.parPay"));

            }
            //component.set('v.data', data);
		});

    },

    formatData: function(component, accountObj){
        var result = {};
        result.id = accountObj.id;
        result.productName = accountObj.productName;
        result.branch = accountObj.account.branch;
        result.accountNumber = accountObj.account.number;
        result.accountCurrency = accountObj.account.currency.code;
        result.accountCurrencyDecimalPlaces = accountObj.account.currency.decimalPlaces;

        result.iban = accountObj.account.iban;
        result.availableBalance = accountObj.account.availableBalance;
        result.ledgerBalance = accountObj.account.ledgerBalance;
        result.startDate = accountObj.account.startDate;
        result.endDate = accountObj.account.endDate;
        result.status = accountObj.account.status;
        result.overdraftLimit = accountObj.account.overdraftLimit;
        result.overdraftExpiryDate = accountObj.account.overdraftExpiryDate;
        result.overdraftAvailableLimit = accountObj.account.overdraftAvailableLimit;
        result.paymentsAllowed = true === accountObj.account.paymentsAllowed ? 'Yes': 'No';

        // not currently provided via API
        result.debitInterestRate = accountObj.account.debitInterestRate;
        result.creditInterestRate = accountObj.account.creditInterestRate;

        return result;

    },

})
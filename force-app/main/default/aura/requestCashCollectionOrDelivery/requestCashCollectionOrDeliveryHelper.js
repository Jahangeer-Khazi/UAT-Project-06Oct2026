({
    sendRequest : function(component, customerId, requestData, caseId, requestType) {
        var helper = this;
        var countries = component.get("v.countryOptions");
        requestData.country = helper.countryCodeToLabel(countries, requestData.country);
        var account = component.get('v.account');
        component.find('apexService').request(component.get('c.requestCashCollectionOrDelivery'), {
            customerId: customerId,
            caseId: caseId,
            requestData: JSON.stringify(requestData),
            requestType: requestType,
            regionName : account.Region_Flag__c
        },
        function(response) {
            var result = response.getReturnValue();
            var data = [];
            if (true === result.isSuccess ) {
                helper.resetRequestData(component);

                helper.closeRequestPopup(component);
            }
        });
	},
    resetRequestData: function(component) {
        var requestData = component.get('v.requestData');
        // reset non address fields
        requestData.currency = null;
        requestData.amount = null;
        component.set('v.requestData', requestData);
    },
    /**
     * PersonMailingCountry is a free text field
     * need to convert selected country Code into country Label
     */
    countryCodeToLabel: function(countries, countryCode) {
        for (var i = 0; i < countries.length; i++) {
            var countryObj = countries[i];
            if (countryCode === countryObj.value) {
                return countryObj.label;
            }
        }
        return countryCode;

    },
    openRequestPopup: function(component, requestData) {
        //component.set('v.requestData', requestData);
        component.find('request-popup').open();
        // focus "reason" input
        window.setTimeout(function(){
            component.find("collection-time").focus();
        }, 100);
    },

    closeRequestPopup: function (component) {
        component.find('request-popup').close();
    },
    loadCountryOptions: function(component, selectedValue) {
        //loadCountryPicklistValues
        var helper = this;
        component.find('apexService').request(component.get('c.loadCountryPicklistValues'),
        {},// method takes no parameters
        function(response) {
            var result = response.getReturnValue();
            var countries = JSON.parse(result);
            if (!$A.util.isEmpty(selectedValue)) {
                var selectedCountry = selectedValue.toUpperCase();
                // set default selected value
                for (var i = 0; i < countries.length; i++) {
                    if (selectedCountry === countries[i].value.toUpperCase()) {
                        countries[i].selected = true;
                        break;
                    }
                }
            }

            component.set("v.countryOptions", countries);
            component.set('v.isInitialised', true);
        });
    },
    loadCurrencyOptions: function(component) {
        //loadCountryPicklistValues
        var helper = this;
        component.find('apexService').request(component.get('c.loadCurrencyPicklistValues'),
        {},// method takes no parameters
        function(response) {
            var result = response.getReturnValue();
            var currencies = JSON.parse(result);
            currencies.unshift({"MasterLabel": "--None--", "DeveloperName": ""});

            component.set("v.currencyOptions", currencies);
        });
    },
    loadAccount: function(component, customerId) {
        //loadCountryPicklistValues
        var helper = this
        component.find('apexService').request(component.get('c.loadAccountByCif'), {
            "cif": customerId
        },
        function(response) {
            var result = response.getReturnValue();
            var requestData = component.get('v.requestData');
            requestData = null == requestData ? {} : requestData;
            requestData.street = result.PersonMailingStreet;
            requestData.city = result.PersonMailingCity;
            requestData.province = result.PersonMailingState;
            requestData.country = result.PersonMailingCountry;
            requestData.postalCode = result.PersonMailingPostalCode;
            component.set('v.requestData', requestData);

            helper.loadCountryOptions(component, requestData.country);
        });
    },
    isValidInput: function(component) {
        var requestData =  component.get('v.requestData');
        var fieldsToCheck = ['time', 'street', 'city', 'country', 'postalCode', 'currency', 'amount'];
        for (var i = 0; i < fieldsToCheck.length; i++) {
            if ($A.util.isEmpty(requestData[fieldsToCheck[i]])) {
                console.log('Missing value for field: ' + fieldsToCheck[i]);
                return false;
            }
        }
        return true;
    }

})
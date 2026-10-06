({
	loadMockData : function(component,event,helper) {
		//helper.showSpinner(component,event,helper);
        // Mock API response
        var mockResponse = {
            "meta": {
                "code": "GET-CREDIT-PAYMENT-1000",
                "message": "payment limit retrieved successfully"
            },
            "data": {
                "maxDailyPaymentCap": 1000.000,
                "consumedDailyLimit": 800.000,
                "remainingDailyLimit": 200.000
            }
        };

        console.log("Daily Payment Limit Mock Response:",JSON.stringify(mockResponse));

        // Check whether API returned data
        if (mockResponse && mockResponse.data) {

            var data = mockResponse.data;

            // Convert API response into datatable row
            var tableData = [
                {
                    id: "dailyPaymentLimit",
                    dailyPaymentCap: data.maxDailyPaymentCap,
                    usedAmount: data.consumedDailyLimit,
                    remainingLimit: data.remainingDailyLimit
                }
            ];

            console.log("Daily Payment Limit Table Data:",JSON.stringify(tableData));

            component.set("v.dailyLimitData", tableData);
            // Hide spinner after data is loaded
            component.set("v.isLoading", false);
            //helper.hideSpinner(component,event,helper);
        }
    },
    fetchPaymentLimits : function(component,event,helper) {
        component.set("v.isLoading", true);
        component.set("v.errorMessage", "");

        // Determine record ID to pass (falls back to recordId if accountId is empty)
        var targetAccountId = component.get("v.caseId");

        var action = component.get("c.getDailyPaymentLimit");
        action.setParams({
            accountId: targetAccountId
        });

        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
            var state = response.getState();

            if (state === "SUCCESS") {
                var apiResponse = response.getReturnValue();

                if (apiResponse && apiResponse.data) {
                    var data = apiResponse.data;
                    var tableData = [
                        {
                            id: "dailyPaymentLimit",
                            dailyPaymentCap: data.maxDailyLimit,
                            usedAmount: data.consumedDailyLimit,
                            remainingLimit: data.remainingDailyLimit
                        }
                    ];
                    component.set("v.dailyLimitData", tableData);
                }
            }else if(state === "ERROR") {
                var errors = response.getError();
                var msg = "Unknown error occurred while fetching payment limits.";
                if (errors && errors[0] && errors[0].message) {
                    msg = errors[0].message;
                }
                component.set("v.errorMessage", msg);
            }
        });

        $A.enqueueAction(action);
    },
    showSpinner: function (component,event,helper) {
        console.log('Inside Spinner');
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component,event,helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
})
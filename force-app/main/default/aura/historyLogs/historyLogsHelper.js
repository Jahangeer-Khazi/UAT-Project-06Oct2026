({
    getHistoryLogs : function(component,event,helper) {
	component.set("v.isLoading",true);
	component.set("v.historyData",[]);
	component.set("v.errorMessage",null);
	var customerId = component.get("v.caseId");
	var selectedDate = component.get("v.selectedDate");
    console.log('Customer Id:',customerId);
	console.log('Selected Date:',selectedDate);

	var action = component.get("c.getHistoryLogs");
	action.setParams({
			accountId : customerId,
			selectedDate : selectedDate
	});

	action.setCallback(this,function(response) {
		var state =	response.getState();
		console.log('Apex Response State:',state);
		if(state === "SUCCESS") {
			var result = response.getReturnValue();
			console.log('History API Response:',JSON.stringify(result));
			if(result && result.success && result.data) {
				if(result.data.history) {
					this.processResponse(component,result.data.history);
				}else{
					component.set("v.historyData",[]);
                 }

			}else{
				component.set("v.historyData",[]);
				component.set("v.errorMessage",result && result.message? result.message: "Unable to retrieve payment history.");
              }
		}
		else if(state === "ERROR"){
			var errors = response.getError();
			var errorMessage = "An error occurred while retrieving payment history.";
			if(errors && errors.length > 0 && errors[0].message){
				errorMessage = errors[0].message;
             }
			console.error('History Logs Error:',errorMessage);
			component.set("v.historyData",[]);
			component.set("v.errorMessage",errorMessage);
        }

		component.set("v.isLoading",false);
       });

		$A.enqueueAction(action);
    },

	processResponse : function(component,historyList){
		var tableData = [];
		if(!historyList || historyList.length === 0) {
			component.set("v.historyData",[]);
			return;
        }
		historyList.forEach(function(record, index) {
			tableData.push({
						id:"history_" + index,
						paymentTimestamp:this.formatUtcToBahrainTime(record.creationDatetime),
						cardNumber:this.getLastFourDigits(record.maskedCardNumber),
						paymentAmount:this.formatAmount(record.paymentAmount),
						remainingDailyLimit:this.formatAmount(record.remainingDailyLimit),
						status:record.status
			});
		},
            this);
		console.log('History Table Data:',JSON.stringify(tableData));
		component.set("v.historyData",tableData);
		/*
     * Default sorting:
     * Payment Timestamp - Ascending
     */

		component.set("v.sortedBy","paymentTimestamp");
		component.set("v.sortedDirection","asc");
		this.sortData(component,"paymentTimestamp","asc");
    },


    // ==============================================
    // Format Amount
    // ==============================================

    formatAmount : function(value) {
		if (value === null || value === undefined) {
			return "";
        }
		return Number(value).toLocaleString('en-US',
            {
                minimumFractionDigits: 0,
                maximumFractionDigits: 3
            }
        );
    },
    
    formatDateTime : function(dateTimeString) {
    if (!dateTimeString) {
        return "";
    }

    var date = new Date(dateTimeString);

    if (isNaN(date.getTime())) {
        return dateTimeString;
    }

    var day = String(date.getDate()).padStart(2, '0');
    var month = String(date.getMonth() + 1).padStart(2, '0');
    var year = date.getFullYear();

    var hours = String(date.getHours()).padStart(2, '0');
    var minutes = String(date.getMinutes()).padStart(2, '0');

    return day + "-" + month + "-" + year + " " + hours + ":" + minutes;
},
formatUtcToLocalTimezone: function(utcDateString) {
	console.log('UTC Date:',utcDateString);
	if (!utcDateString) {
		return '';
	}

	var str = String(utcDateString).trim();

	// If it lacks UTC indicator ('Z') or offset (+/-), append 'Z' so JS treats it as UTC
	if (!str.endsWith('Z') && !/[+-]\d{2}:?\d{2}$/.test(str)) {
		str += 'Z';
	}
	console.log('UTC Date:',str);
	var d = new Date(str);

	// If date is invalid, return original string
	if (isNaN(d.getTime())) {
		return utcDateString;
	}

	var pad = function(num) {
		return (num < 10 ? '0' : '') + num;
	};

	var day = pad(d.getDate());
	var month = pad(d.getMonth() + 1);
	var year = d.getFullYear();
	var hours = pad(d.getHours());
	var minutes = pad(d.getMinutes());

	// Returns "dd-MM-yyyy HH:mm" (e.g., "21-09-2026 16:00")
	return day + '-' + month + '-' + year + ' ' + hours + ':' + minutes;
},
formatUtcToBahrainTime: function(utcDateString) {
    if (!utcDateString) {
        return '';
    }

    var str = String(utcDateString).trim();

    // Ensure JS treats it as UTC if it's missing the 'Z' or offset
    if (!str.endsWith('Z') && !/[+-]\d{2}:?\d{2}$/.test(str)) {
        str += 'Z';
    }

    var d = new Date(str);

    if (isNaN(d.getTime())) {
        return utcDateString;
    }

    // Force formatting to Bahrain Time Zone (Asia/Bahrain / UTC+3)
    var formatter = new Intl.DateTimeFormat('en-GB', {
        timeZone: 'Asia/Bahrain',
        year: 'numeric',
        month: 'short',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        hour12: false
    });

    var parts = formatter.formatToParts(d);
    var map = {};
    parts.forEach(function(part) {
        map[part.type] = part.value;
    });

    // Returns "dd-MM-yyyy HH:mm" (e.g., "21-09-2026 16:00")
    return map.day + '-' + map.month + '-' + map.year + ' ' + map.hour + ':' + map.minute;
},
getLastFourDigits : function(cardNumber) {
    if (!cardNumber) {
        return "";
    }
	cardNumber = String(cardNumber).trim();
	if (cardNumber.length <= 4) {
        return cardNumber;
    }

    return cardNumber.slice(-4);
},
sortData : function(component, fieldName, sortDirection) {
	var data = component.get("v.historyData");
	var reverse = sortDirection !== "asc";

	data.sort(function(a, b) {
		var valueA = a[fieldName] || "";
		var valueB = b[fieldName] || "";

		if (fieldName === "paymentTimestamp") {
			valueA = this.convertDateForSorting(valueA);
			valueB = this.convertDateForSorting(valueB);
		}

		if (valueA < valueB) {
			return reverse ? 1 : -1;
		}

		if (valueA > valueB) {
			return reverse ? -1 : 1;
		}

		return 0;

	}.bind(this));

	component.set("v.historyData",data);
},


convertDateForSorting : function(dateTime) {

	if (!dateTime) {
		return "";
	}

	// Expected:
	// 22-09-2026 17:35

	var parts = dateTime.split(" ");

	if (parts.length < 2) {
		return dateTime;
	}

	var dateParts =
		parts[0].split("-");

	if (dateParts.length !== 3) {
		return dateTime;
	}

	// Convert:
	// DD-MM-YYYY HH:mm
	//
	// to:
	// YYYYMMDDHHmm

	return dateParts[2] +
		dateParts[1] +
		dateParts[0] +
		parts[1];
}
})
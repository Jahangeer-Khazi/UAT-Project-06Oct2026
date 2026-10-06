({
    getWhitelistDetails : function(component) {
		component.set("v.isLoading", true);
        component.set("v.errorMessage", null);
        component.set("v.whitelistData", []);
		var customerId = component.get("v.caseId");
        var action = component.get("c.getWhitelistDetails");
		action.setParams({
			accountId : customerId
		});

        action.setCallback(this, function(response) {
		var state = response.getState();
		console.log("Whitelist API State:",state);
		if(state === "SUCCESS") {
			var result = response.getReturnValue();
			console.log("Whitelist API Result:",JSON.stringify(result));
				if(result && result.success && result.data) {
					if(result.data.whitelists && result.data.whitelists.length > 0) {
						this.processWhitelistResponse(component,result.data.whitelists);

                    }else{
						component.set("v.whitelistData",[]);
                    }

                }else{
                    	component.set("v.whitelistData",[]);
						component.set("v.errorMessage",result && result.message ? result.message : "Unable to retrieve whitelist details."
                    );
                }

            }else if(state === "ERROR") {
				var errors = response.getError();
				var errorMessage = "An error occurred while retrieving whitelist details.";

				if(errors && errors.length > 0 && errors[0].message) {
					errorMessage =	errors[0].message;
                }
				component.set("v.errorMessage",errorMessage);
				component.set("v.whitelistData",[]);
            }
			component.set("v.isLoading",false);

        });
		$A.enqueueAction(action);
    },


    processWhitelistResponse : function(component, whitelistList) {
		var tableData = [];
		whitelistList.forEach(function(record, index) {
			tableData.push({
					id:record.id? record.id : "whitelist_" + index,
					pciNumber:record.pciNumber,
                    whitelistedBy:record.whitelistedBy,
					fromDate:this.formatUtcToBahrainTime(record.fromDate),
					toDate:this.formatUtcToBahrainTime(record.toDate),
					creationDatetime:this.formatUtcToBahrainTime(record.creationDatetime),
					expired:record.expired
                });

            },
        this);
		console.log('Table Data:',tableData);
		component.set("v.whitelistData",tableData);
		component.set("v.sortedBy", "creationDatetime");

		component.set("v.sortedDirection", "desc");
		this.sortData(component,"creationDatetime","desc");
    },
	createWhitelist : function(component) {
		var fromDate = component.get("v.fromDate");
		var toDate = component.get("v.toDate");
		component.set("v.errorMessage", null);

		if(!fromDate) {
			component.set("v.errorMessage","Please select From Date.");
			return;
		}
		if(!toDate) {
			component.set("v.errorMessage","Please select To Date.");
			return;
		}

		//fromDate = this.formatDateTimeForApi(fromDate);
		//toDate = this.formatDateTimeForApi(toDate);
		console.log("From Date for API:", fromDate);
		console.log("To Date for API:", toDate);
		component.set("v.isLoading", true);
		var customerId = component.get("v.caseId");
		var action = component.get("c.createWhitelist");
	
		action.setParams({
			accountId : customerId,
			fromDate : fromDate,
			toDate : toDate
		});
	
		action.setCallback(this, function(response) {
			var state = response.getState();
			console.log("Whitelist POST State:",state);
	
			if(state === "SUCCESS") {
				var result = response.getReturnValue();
				console.log("Whitelist POST Result:",JSON.stringify(result));
	
				if (result && result.success) {
					component.set("v.errorMessage",null);
					// Show success message
    				component.set("v.isWhitelistSuccess",true);
					// Clear From Date
    				component.set("v.fromDate",null);
					// Clear To Date
    				component.set("v.toDate",null);
					console.log("Whitelist created successfully.");
				}else{
					component.set("v.errorMessage",result && result.message ? result.message : "Unable to whitelist customer.");
				}
	
			}else if (state === "ERROR") {
				var errors = response.getError();
				var errorMessage = "An error occurred while creating whitelist.";
				if (errors && errors.length > 0 && errors[0].message) {
					errorMessage = errors[0].message;
				}
				component.set("v.errorMessage",errorMessage);
			}
	
			component.set("v.isLoading",false);
	
		});
	
		$A.enqueueAction(action);
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
	
	
	/*formatDateTimeForApi : function(dateTimeValue) {
	
		if (!dateTimeValue) {
			return "";
		}
	
		var date = new Date(dateTimeValue);
	
		if (isNaN(date.getTime())) {
			return "";
		}
	
		var year = date.getFullYear();
		var month = String(date.getMonth() + 1).padStart(2, "0");
		var day = String(date.getDate()).padStart(2, "0");
		var hours = String(date.getHours()).padStart(2, "0");
		var minutes = String(date.getMinutes()).padStart(2, "0");
	
		return year +
			"-" +
			month +
			"-" +
			day +
			" " +
			hours +
			":" +
			minutes;
	}*/
	/*formatDateTimeForApi : function(dateTimeValue) {
		if (!dateTimeValue) {
            return '';
        }

        var d = new Date(dateTimeValue);
        
        var pad = function(num) {
            return (num < 10 ? '0' : '') + num;
        };

        var year = d.getFullYear();
        var month = pad(d.getMonth() + 1);
        var day = pad(d.getDate());
        var hours = pad(d.getHours());
        var minutes = pad(d.getMinutes());
        var seconds = pad(d.getSeconds());

        // Returns "YYYY-MM-DD HH:mm" (e.g., "2026-09-21 16:00")
        return year + '-' + month + '-' + day + ' ' + hours + ':' + minutes;

        // If your API requires seconds or ISO format without 'Z', use:
        //return year + '-' + month + '-' + day + 'T' + hours + ':' + minutes + ':' + seconds;
	
 	},*/
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
	sortData : function(component, fieldName, sortDirection) {
		var data = component.get("v.whitelistData");
		var reverse = sortDirection !== "asc";
	
		data.sort(function(a, b) {
			var valueA = a[fieldName] || "";
			var valueB = b[fieldName] || "";
	
			if (fieldName === "creationDatetime") {
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
	
		component.set("v.whitelistData",data);
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
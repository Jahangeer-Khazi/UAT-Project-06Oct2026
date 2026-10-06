/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History: 
 *	        2021-11-27 - #CH01# - YZ Region Name changes
 *			   
 */
({
	loadCase : function(component, recordId) {
	    var helper = this;
		component.find('apexService').request(component.get('c.loadCase'), {
		    recordId: recordId
        },
		function(response) {
		    var result = response.getReturnValue();

            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                var caseObj = result.responseData;
                var account = {};
                if (caseObj.hasOwnProperty( 'Account') ) {
                    account = caseObj.Account;
                } else {
                    account = caseObj;
                }
            }
            console.log("loaded account: " + JSON.stringify(account));
            
            component.set('v.account', account);
            component.set('v.customerId', account.CIF__pc);
            component.set('v.RegionFlag', caseObj.Region_Flag__c); // #CH01#
            component.set('v.caseType', caseObj.Type);
            component.set('v.caseRecordTypeId', caseObj.RecordTypeId);
            var isOpenCase = 'Closed' !== caseObj.Status && 'Approved' !== caseObj.Status && 'Rejected' !== caseObj.Status;
            component.set('v.isOpenCase', isOpenCase);
		});
	},

    setCaseStatus: function(component, caseId, isApproved, closureType, rejectReason, fatcaDocumentExpiryDate, formType) {
	    var helper = this;
        console.log('incaseStatus '+formType);
        var status = isApproved? "Approved" : "Rejected";
        var params = {
		    caseId: caseId,
            status: status,
            closureType: closureType,
            rejectReason: rejectReason,
            formType: formType
        }
        console.log('incaseStatus2');
        if (undefined !== fatcaDocumentExpiryDate) {
            params["fatcaDocumentExpiryDate"] = fatcaDocumentExpiryDate;
        }
        console.log('incaseStatus3');
		component.find('apexService').request(component.get('c.updateCaseStatus'), params,
		function(response) {
            console.log('incaseStatus4');
		    var result = response.getReturnValue();
            console.log(">>>>> result update", result);
            if (true === result.isSuccess) {
                // reload case
                helper.loadCase(component, caseId);
                component.find('apexService').showSuccessMessage("Case status has been updated.");
                var device = $A.get("$Browser.formFactor");
                if ("DESKTOP" === device) {
                    // on DESKTOP - refresh the view
                    $A.get('e.force:refreshView').fire();
                } else {
                    // on mobile - reload the page by redirecting
                    helper.navigateToRecord(component, caseId);
                }
            }
		});
    },

    /**
     * Case.Type=Identification
     */
	sendIdentificationRequest : function(component, caseId, customerId, currentState, decision, isApproved, closureType, rejectReason, fatcaDocumentExpiryDate) {
        var helper = this;
        console.log('sendFatcaRequest');
        helper.sendXYZActionRequest(component, caseId, customerId, currentState, decision, isApproved, closureType, rejectReason, 'Identification', fatcaDocumentExpiryDate,'');
    },

    /**
     * Case.Type=FATCA
     */
	sendFatcaRequest : function(component, caseId, customerId, currentState, decision, isApproved, closureType, rejectReason, fatcaDocumentExpiryDate, formType) {//Added formType as part of NBA-12150
        var helper = this;
        console.log('sendFatcaRequest');
        console.log('formTYpe '+component.get("v.FormType"));
        console.log('formTYpe '+formType);
        helper.sendXYZActionRequest(component, caseId, customerId, currentState, decision, isApproved, closureType, rejectReason, 'FATCA', fatcaDocumentExpiryDate, formType);

    },
    /**
     * Case.Type=EDD
     */
	sendEddRequest : function(component, caseId, customerId, currentState, decision, isApproved, closureType, rejectReason, fatcaDocumentExpiryDate) {
        var helper = this;
        console.log('sendEddRequest');
        helper.sendXYZActionRequest(component, caseId, customerId, currentState, decision, isApproved, closureType, rejectReason, 'EDD', fatcaDocumentExpiryDate,'');

    },
    /**
     * Case.Type=Name Screening
     * 1. make a call to /compliances API endpoint to check if case can be closed
     * 2. close case
     */
	startNameScreeningRequest : function(component, caseId, customerId, accountId, currentState, decision, isApproved, closureType, rejectReason, fatcaDocumentExpiryDate) {
	    var helper = this;
        var actionName = 'Name Screening';
        var email = component.get("v.account.PersonEmail");
        email = email ? email : '';

        console.log('>>>startNameScreeningRequest');
        helper.sendXYZActionRequest(component, caseId, customerId, currentState, decision, isApproved, closureType, rejectReason, actionName, fatcaDocumentExpiryDate,'');
 

        //SP: 2019-11-08: change request from sendComplianceCheckRequest to sendOnboardingContinueRequest
        // var requestBody = {
        //     caseStatus: "Verified",
        //     email: email,
        //     caseType: actionName
        // };
        //
		// component.find('apexService').request(component.get('c.sendComplianceCheckRequest'), {
        //     caseId: caseId,
        //     customerId: customerId,
        //     actionName: actionName,
        //     email: email
        // }, 
		// function(response) {
		//     var result = response.getReturnValue();
         
        //     if (true === result.isSuccess && !$A.util.isEmpty(result.responseData) && !$A.util.isEmpty(result.responseData.data)) {
        //         var data = result.responseData.data;
        //         var isSuccessful = ["PASS", "REJECT", "EDD"].indexOf(data.decision.toUpperCase()) >=0;
        //         if (true !== isSuccessful) {
        //             var errorMessage = $A.get("$Label.c.Please_make_sure_you_complete_the_Case_in_Siron_before_closing_it_in_Salesforce");
        //             component.find('apexService').showWarningMessage(errorMessage);
        //             return;
        //         }
        //         if ("EDD" === data.decision && "P" === data.screeningResults) {
        //             var screeningResult = "True Match-PEP";
        //             helper.setNameScreeningResult(component, accountId, screeningResult, function() {
        //                 helper.sendXYZActionRequest(component, caseId, customerId, currentState, decision, isApproved, closureType, rejectReason, actionName);
        //             });
        //         } else if ("REJECT" === data.decision && "E" === data.screeningResults) {
        //             var screeningResult = "True Match-WatchList";
        //             helper.setNameScreeningResult(component, accountId, screeningResult, function() {
        //                 helper.sendXYZActionRequest(component, caseId, customerId, currentState, decision, isApproved, closureType, rejectReason, actionName);
        //             });
        //         } else {
        //             // no need to set ScreeningResult, update case status right away
        //             helper.sendXYZActionRequest(component, caseId, customerId, currentState, decision, isApproved, closureType, rejectReason, actionName);
        //         }
                
        //     }
		// }); 
        
    },
    
	setNameScreeningResult : function(component, accountId, screeningResult, successCallback) {
	    var helper = this;
	    
		component.find('apexService').request(component.get('c.setNameScreeningResult'), {
            accountId: accountId,
            result: screeningResult
        },
		function(response) {
		    var result = response.getReturnValue();
        
            if (true === result.isSuccess ) {
                // screening result is set successfully
                successCallback();
            }
		});

    },
    
	sendXYZActionRequest : function(component, caseId, customerId, currentState, decision, isApproved, 
                                    closureType, rejectReason, actionName, fatcaDocumentExpiryDate, formType) {
        var helper = this;
        console.log(">>>>> result sendXYZActionRequest");
        var email = component.get("v.account.PersonEmail");
        email = email ? email : '';
        console.log(">>>>> result sendXYZActionRequest");

        //JT 11-11-19 As per Ahmed request based on Confluence page expected statuses 
        //https://bank-abc.atlassian.net/wiki/spaces/NA/pages/479953123/Continue+On+boarding+Process+API
        if(actionName == 'Name Screening'){
          var decision = "Verified";  
        } else {
          var decision = isApproved ? "Approved": "Rejected";  
        }
        
        var requestBody = {
            caseStatus: decision,
            email: email,
            caseType: component.get('v.caseType')
        };
		component.find('apexService').request(component.get('c.sendOnboardingContinueRequest'), {
		    caseId: caseId,
            customerId: customerId,
            actionName: actionName,
            requestBody: JSON.stringify(requestBody),
            email: email,
            regionName: component.get('v.RegionFlag') // #CH01#
        },
		function(response) {
		    var result = response.getReturnValue();
        
            if (true === result.isSuccess) {
                // helper.setCaseStatus(component, caseId, isApproved, closureType, rejectReason, fatcaDocumentExpiryDate);
            }
		});

        //SP: 2019-10-04: change request to update without depend on onBoarding
        helper.setCaseStatus(component, caseId, isApproved, closureType, rejectReason, fatcaDocumentExpiryDate, formType);
        
    },
    navigateToRecord : function(component, recordId) {
        var navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParams({
            recordId: recordId,
            slideDevName: "detail"
        });
        navEvent.fire(); 
    }
})
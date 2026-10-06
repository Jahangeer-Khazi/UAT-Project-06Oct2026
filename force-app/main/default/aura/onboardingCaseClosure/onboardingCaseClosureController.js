({
    init : function(component, event, helper) {
        helper.loadCase(component, component.get('v.recordId'));
	},
    onViewRefresh : function(component, event, helper) {
        helper.loadCase(component, component.get('v.recordId'));
	},
    onSubmitClick: function(component, event, helper) {
        event.preventDefault();       // stop the form from submitting
        var fields = event.getParam('fields');
        var ClosureTypeSelect = component.get("v.ClosureType");
        var formType = component.get("v.FormType"); //Added as part of NBA-12150
        var caseType = component.get('v.caseType');
        console.log('+++++ '+formType)
        var closureType = fields.Closure_Type__c || ClosureTypeSelect;
        var rejectReason = fields.Case_Reject_Reason__c;
        var fatcaDocumentExpiryDate = fields.FATCA_Document_Expiry_Date__c;
        if ($A.util.isEmpty(closureType)) {
            component.find('apexService').showWarningMessage("Closure Type is required");
            return;
        }
        if(caseType=='FATCA'){
            if ($A.util.isEmpty(formType) && closureType.indexOf('Approved') >= 0) { //Added as part of NBA-12150
            component.find('apexService').showWarningMessage("Please select FATCA Declaration - Form Type");
            return;
           }
        }
        

        var isApproved = closureType.indexOf('Approved') >= 0;
        if (isApproved) {
            // case approved
        } else {
            // case rejected
            if ($A.util.isEmpty(rejectReason)) {
                component.find('apexService').showWarningMessage("Reject Reason is required");
                return;
            }

        }

        console.log("fields=" + JSON.stringify(fields));
        if (!confirm('You are submitting the case as "'+ closureType +'". Continue?')) {
            return;
        }
        
       
        var caseId = component.get('v.recordId');
        var customerId = component.get('v.customerId');
        var regionFlag = component.get('v.RegionFlag');
        var currentState = component.get('v.account.Onboarding_Stage__pc');
        var decision = isApproved ? "Approved": "Rejected"; 
        
        if ('Identification' == caseType) {
            helper.sendIdentificationRequest(component, caseId, customerId, currentState, decision, isApproved, closureType, rejectReason, fatcaDocumentExpiryDate);
        } else if ('FATCA' == caseType) {
            helper.sendFatcaRequest(component, caseId, customerId, currentState, decision, isApproved, closureType, rejectReason, 
                                    fatcaDocumentExpiryDate, formType);//Added formType as part of NBA-12150
        } else if ('EDD' == caseType) {
            helper.sendEddRequest(component, caseId, customerId, currentState, decision, isApproved, closureType, rejectReason, fatcaDocumentExpiryDate);
        } else if ('Name Screening' == caseType) {
            var accountId = component.get('v.account.Id');
            helper.startNameScreeningRequest(component, caseId, customerId, accountId, currentState, decision, isApproved, closureType, rejectReason, fatcaDocumentExpiryDate);
        }
        
        //fields.Street = '32 Prince Street';
        //component.find('myRecordForm').submit(fields);
    },
})
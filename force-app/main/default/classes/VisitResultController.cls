public without sharing virtual class VisitResultController {
    @TestVisible private static VisitResultController DAO = new VisitResultController();
    
    @TestVisible private Case loadedCase;
    private String caseUuid;
    public Boolean isSaveComplete {get; set;}

    public String getCaseUuid() {
        if (null == caseUuid) {
            final String uuidFromUrl = null != ApexPages.currentPage()? 
                ApexPages.currentPage().getParameters().get('id') : '';
            
            if (String.isNotBlank(uuidFromUrl)) {
                caseUuid = EncodingUtil.urlDecode(uuidFromUrl, 'UTF-8');
            }
        }
        return caseUuid;
    }
    
    private Case getCase() {
        if (null == loadedCase) {
            try {
                final String caseUuid = getCaseUuid();
                if (String.isNotBlank(caseUuid)) {
                    loadedCase = DAO.loadCase(caseUuid);
                }
                System.debug('agX loadedCase=' + loadedCase);
            } catch (Exception e){
                System.debug(e);
                loadedCase = null;
                /*
                ApexPages.Message errorMessage = new ApexPages.Message( ApexPages.Severity.ERROR, 'Failed to load case by Id: ' + getCaseUuid()); 
                ApexPages.addMessage(errorMessage);
                */

            }
        }
        return loadedCase;
    }
    
    public class CaseData {
        public Boolean hasData = false;
        public String subject {get; private set;}
        public String status {get; private set;}
        public String caseType {get; private set;}
        public Boolean getHasData() {
            return hasData;
        }
    }
    
    public CaseData getCaseData() {
        final Case caseRec = getCase();
        final CaseData data = new CaseData();
        if (null != caseRec) {
            data.hasData = true;
            data.subject = caseRec.Subject;
            data.status = caseRec.Status;
            data.caseType = caseRec.Type;

        }
        return data;
    }
    public void onYesClick() {
        recordResponse('Completed');
    }
    public void onNoClick() {
        recordResponse('Failed');
    }

    private void recordResponse(final String caseStatus) {
        if (null != loadedCase) {
            //update case 
            final List<String> errors = DAO.updateRecords(new List<Case>{new Case(Id = loadedCase.Id, Status = caseStatus)});
            dumpErrors(errors);

            //create System Action
            final System_Action__c action = new System_Action__c();
            action.Origin__c = 'CRM';
            action.Action__c = loadedCase.Type;
            action.Case__c = loadedCase.Id;
            action.Account__c = loadedCase.AccountId;
            action.Account_Number__c = loadedCase.Account.CIF__pc;
            if (errors.isEmpty()) {
                action.Response_Body__c = caseStatus;
                isSaveComplete = true;
            } else {
                // log errors in System_Action__c
                action.Response_Body__c = String.join(errors, ',');
                isSaveComplete = false;
            }
            SystemActionLogger.logAction(action);
        }
    }
    
    protected virtual Case loadCase(final String caseUuid) {
        return [select Id, Subject, Status, Type, AccountId, Account.CIF__pc 
                    from Case where Uuid__c = :caseUuid and Status in ('Collection', 'Delivery') 
                    limit 1];
    }
    
    protected virtual List<String> updateRecords(final List<SObject> recs) {
        final List<String> errors = new List<String>();
        for(Database.SaveResult res : Database.update(recs, /*all_or_none=*/false)) {
            if (!res.isSuccess()) {
                errors.add(res.getErrors()[0].getMessage());
            }
        }
        return errors;
    }
    private void dumpErrors(final List<String> errors) {
        for(String err : errors) {
            ApexPages.Message errorMessage = new ApexPages.Message( ApexPages.Severity.ERROR, err); 
            ApexPages.addMessage(errorMessage);
        }
    }

}
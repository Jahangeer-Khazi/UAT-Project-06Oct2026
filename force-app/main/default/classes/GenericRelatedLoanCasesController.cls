public without sharing class GenericRelatedLoanCasesController {
    private static final Set<String> ALLOWED_RECORD_TYPES = new Set<String>{
        'Loan_Application',
        'LoanFinanceServiceRequest'
    };

    private static final Set<String> ALLOWED_STATUSES = new Set<String>{
        'Closed'
    };

    private static final Set<String> ALLOWED_SUB_STATUSES = new Set<String>{
        'Declined',
        'Cancelled',
        'Processed',
        'Approved'
    };

    private static final String CURRENT_CASE_SUB_TYPE_TOKEN = 'Case.Sub_Type__c';
    private static final String LOAN_FINANCE_SERVICE_REQUEST = 'LoanFinanceServiceRequest';


    @AuraEnabled(cacheable=true)
    public static List<Case> getRelatedCases(
        Id caseId,
        String recordTypeDeveloperName,
        String caseStatut,
        String caseSubStatus,
        String caseSubType
    ) {
        System.debug('Start GenericRelatedLoanCasesController.getRelatedCases() caseId -> '+ caseId 
            + ' recordTypeDeveloperName --> '+ recordTypeDeveloperName 
            + ' caseStatut --> '+ caseStatut 
            + ' caseSubStatus --> '+ caseSubStatus 
            + ' caseSubType --> '+ caseSubType 
        );

        if (caseId == null || String.isBlank(recordTypeDeveloperName)) {
            return new List<Case>();
        }

        validateFilter('recordTypeDeveloperName', recordTypeDeveloperName, ALLOWED_RECORD_TYPES);

        caseStatut = normalizeOptionalFilter(caseStatut);
        caseSubStatus = normalizeOptionalFilter(caseSubStatus);

        if (caseStatut != null) {
            validateFilter('caseStatut', caseStatut, ALLOWED_STATUSES);
        }

        if (caseSubStatus != null) {
            validateFilter('caseSubStatus', caseSubStatus, ALLOWED_SUB_STATUSES);
        }

        Case sourceCase = [
            SELECT AccountId,Sub_Type__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

        if (sourceCase.AccountId == null) {
            return new List<Case>();
        }

        Id accountId = sourceCase.AccountId;

        String effectiveCaseSubType = caseSubType;
        /*
         * The Sub Type filter applies only to
         * LoanFinanceServiceRequest records.
         */
        if ( recordTypeDeveloperName == LOAN_FINANCE_SERVICE_REQUEST)
        {
            if ( caseSubType == CURRENT_CASE_SUB_TYPE_TOKEN ) 
            {
                /*
                 * Dynamic behavior:
                 * use the current record's Sub Type.
                 */
                effectiveCaseSubType = sourceCase.Sub_Type__c;
            }
        }

        String soql =
            'SELECT Id, Subject, CaseNumber, AccountId, Status, Sub_Status__c, ' +
            'Type, Sub_Type__c, CreatedDate, ClosedDate, Owner.Name, ' +
            'RecordType.DeveloperName ' +
            'FROM Case ' +
            'WHERE AccountId = :accountId ' +
            'AND Id != :caseId ' +
            'AND RecordType.DeveloperName = :recordTypeDeveloperName ';

        // Optional filters are appended only when they have a real value.
        if (caseStatut != null) {
            soql += 'AND Status = :caseStatut ';
        }

        if (caseSubStatus != null) {
            soql += 'AND Sub_Status__c = :caseSubStatus ';
        }

        if (recordTypeDeveloperName == LOAN_FINANCE_SERVICE_REQUEST && !String.isBlank(effectiveCaseSubType)) {
            soql += 'AND Sub_Type__c = :effectiveCaseSubType '; 
        }

        soql += 'ORDER BY CreatedDate DESC LIMIT 500';
        System.debug('GenericRelatedLoanCasesController.getRelatedCases() final soql query --> '+ soql );

        return Database.query(soql);
    }

    private static String normalizeOptionalFilter(String value) {
        if (String.isBlank(value) || value == 'None') {
            return null;
        }
        return value.trim();
    }

    private static void validateFilter(String parameterName, String value, Set<String> allowedValues) {
        if (!allowedValues.contains(value)) {
            throw new AuraHandledException(
                'Invalid value for ' + parameterName + ': ' + value
            );
        }
    }
}
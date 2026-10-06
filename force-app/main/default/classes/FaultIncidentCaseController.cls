public with sharing class FaultIncidentCaseController {

    // Existing – unchanged
    @AuraEnabled(cacheable=true)
    public static Id getFaultIncidentRecordTypeId() {
        return [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Case'
            AND DeveloperName = 'Case_Faults_and_Incidents'
            LIMIT 1
        ].Id;
    }

    // NEW: fetch Account by CIF (adjust field name as needed)
    @AuraEnabled(cacheable=true)
    public static Id getAccountIdByCIF(String cif) {
        if (String.isBlank(cif)) {
            return null;
        }
        // Replace 'CIF__pc' with your actual CIF field on Account
        List<Account> accounts = [SELECT Id FROM Account WHERE CIF__pc = :cif LIMIT 1];
        return accounts.isEmpty() ? null : accounts[0].Id;
    }

    @AuraEnabled(cacheable=true)
    public static String getCustomerNameByCIF(String cif) {   // ✅ changed return type to String
        if (String.isBlank(cif)) {
            return null;
        }
        List<Account> accounts = [SELECT Name FROM Account WHERE CIF__pc = :cif LIMIT 1];
        return accounts.isEmpty() ? null : accounts[0].Name;   // ✅ returns Name as String
    }

    // Existing – unchanged
    @AuraEnabled
    public static void createCaseAnnex(
        Id caseId,
        Boolean incidentOutage,
        String incidentOutageNumber
    ) {
        if(caseId == null){
            return;
        }

        CaseAnnex__c annex = new CaseAnnex__c();
        annex.Case__c = caseId;
        annex.Incident_Outage__c = incidentOutage;
        annex.RecordTypeId = '012Pw00000ApHtDIAV';

        System.debug('incidentOutageNumber --->'+incidentOutageNumber);
        if (!String.isBlank(incidentOutageNumber)) {
            annex.Incident_Outage_Number__c = incidentOutageNumber;
        }
        System.debug('annex --->'+annex);
        insert annex;
    }
}
public with sharing class CaseComplaintController {

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

    @AuraEnabled(cacheable=true)
    public static Id getComplaintRecordTypeId() {
        return [SELECT Id FROM RecordType 
                WHERE SObjectType = 'Case' 
                AND DeveloperName = 'Complaint' 
                LIMIT 1].Id;
    }
}
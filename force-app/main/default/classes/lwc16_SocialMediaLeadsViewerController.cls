public with sharing class lwc16_SocialMediaLeadsViewerController {

    public class LeadPagedResult {
        @AuraEnabled public Integer totalItemCount {get;set;}
        @AuraEnabled public List<Social_Media_Leads__c> leads {get;set;}
        @AuraEnabled public Map<String, String> accountIdMap {get;set;}
    }

 
    @AuraEnabled(cacheable=true)
    public static LeadPagedResult getSocialMediaLeads(
        Integer pageSize, 
        Integer pageNumber, 
        String ownerFilter, 
        String searchTerm,
        Boolean onlyUnassigned
    ) {
        Integer offset = (pageNumber - 1) * pageSize;
        
        // Build Where Clause
        String whereClause = '';
        List<String> conditions = new List<String>();

        if (onlyUnassigned == true) {
            conditions.add('Sales_Agent__c = null');
        }

        if (String.isNotBlank(ownerFilter) && ownerFilter != 'All') {
            conditions.add('Owner.Name = :ownerFilter');
        }

        if (String.isNotBlank(searchTerm)) {
            String term = '%' + searchTerm + '%';
            conditions.add('(Name LIKE :term OR Email__c LIKE :term OR CIF__c LIKE :term OR Mobile__c LIKE :term OR Secondary_Phone_Number__c LIKE :term OR Whatsapp_number__c LIKE :term)');
        }

        if (!conditions.isEmpty()) {
            whereClause = ' WHERE ' + String.join(conditions, ' AND ');
        }

        // Count Query
        String countQuery = 'SELECT COUNT() FROM Social_Media_Leads__c' + whereClause;
        Integer totalCount = Database.countQuery(countQuery);

        // Data Query
        String dataQuery = 'SELECT Id, Name, Email__c, Mobile__c, CIF__c, Status__c, ' +
                          'Is_Customer__c, Is_Blacklisted__c, Terminated_Relationship__c, ' +
                          'Active_Credit_Card__c, Pending_Credit_Card__c, Declined_Credit_Card__c, ' +
                          'Secondary_Phone_Number__c, Whatsapp_number__c, Source__c, ' +
                          'Owner.Name, Sales_Agent__r.Name, CreatedDate ' +
                          'FROM Social_Media_Leads__c' + whereClause + 
                          ' ORDER BY CreatedDate DESC LIMIT :pageSize OFFSET :offset';
        
        List<Social_Media_Leads__c> leads = Database.query(dataQuery);

        Set<String> cifSet = new Set<String>();
        for (Social_Media_Leads__c lead : leads) {
            if (String.isNotBlank(lead.CIF__c)) {
                cifSet.add(lead.CIF__c);
            }
        }

        Map<String, String> cifToAccountId = new Map<String, String>();
        if (!cifSet.isEmpty()) {
            for (Account acc : [SELECT Id, CIF__pc FROM Account WHERE CIF__pc IN :cifSet]) {
                cifToAccountId.put(acc.CIF__pc, acc.Id);
            }
        }

        LeadPagedResult result = new LeadPagedResult();
        result.totalItemCount = totalCount;
        result.leads = leads;
        result.accountIdMap = cifToAccountId;
        return result;
    }

    @AuraEnabled
    public static void assignLeads(List<Social_Media_Leads__c> leads, String agentId) {
        if (leads == null || leads.isEmpty() || String.isBlank(agentId)) {
            throw new AuraHandledException('Invalid assignment parameters.');
        }
        
        for (Social_Media_Leads__c lead : leads) {
            lead.Sales_Agent__c = agentId;
            lead.OwnerId = agentId;
        }
        
        try {
            update leads;
        } catch (Exception e) {
            throw new AuraHandledException('Error assigning leads: ' + e.getMessage());
        }
    }
}
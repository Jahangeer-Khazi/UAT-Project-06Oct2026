public with sharing class lwc14_SocialMediaLeadsController {
    

    public class SocialMediaLeadAnalysis {
        @AuraEnabled public String  name                 { get; set; }
        @AuraEnabled public String  email                { get; set; }
        @AuraEnabled public String  phone                { get; set; }
        @AuraEnabled public String  secondaryPhone       { get; set; }
        @AuraEnabled public String  whatsappNumber       { get; set; }
        @AuraEnabled public String  source               { get; set; }
        @AuraEnabled public String  channel              { get; set; }
        @AuraEnabled public String  cif                  { get; set; }
        @AuraEnabled public String  accountId            { get; set; }
        @AuraEnabled public Boolean isCustomer           { get; set; }
        @AuraEnabled public Boolean isBlacklisted        { get; set; }
        @AuraEnabled public Boolean terminatedRelationship { get; set; }
        @AuraEnabled public Boolean hasActiveCreditCard  { get; set; }
        @AuraEnabled public Boolean hasPendingCreditCard { get; set; }
        @AuraEnabled public Boolean hasDeclinedCreditCard{ get; set; }

        public SocialMediaLeadAnalysis() {
            this.isCustomer            = false;
            this.isBlacklisted         = false;
            this.terminatedRelationship= false;
            this.hasActiveCreditCard   = false;
            this.hasPendingCreditCard  = false;
            this.hasDeclinedCreditCard = false;
        }
    }

    @AuraEnabled
    public static List<SocialMediaLeadAnalysis> analyzeSocialMediaLeads(String base64Data, String fileName) {
        try {
            if (String.isBlank(base64Data)) {
                throw new AuraHandledException('File content is empty.');
            }

            String content = decodeFile(base64Data);
            List<List<String>> csvRows = parseCSV(content);
            
            if (csvRows.size() < 2) {
                throw new AuraHandledException('The file is empty or missing data rows.');
            }

            // Identify and validate required columns
            Map<String, Integer> columnMapping = getColumnMapping(csvRows[0]);
            validateColumns(columnMapping);

            List<SocialMediaLeadAnalysis> analysisList = mapRowsToAnalysisWrappers(csvRows, columnMapping);
            performBulkMatchingAnalysis(analysisList);

            return analysisList;
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            System.debug('Unexpected error in analyzeSocialMediaLeads: ' + e.getMessage());
            throw new AuraHandledException('Error analyzing file: ' + e.getMessage());
        }
    }

    /**
     * New method to support chunking of large files
     */
    @AuraEnabled
    public static List<SocialMediaLeadAnalysis> analyzeSocialMediaLeadsBatch(List<SocialMediaLeadAnalysis> inputList) {
        try {
            if (inputList == null || inputList.isEmpty()) {
                return new List<SocialMediaLeadAnalysis>();
            }
            performBulkMatchingAnalysis(inputList);
            return inputList;
        } catch (Exception e) {
            throw new AuraHandledException('Batch Analysis Error: ' + e.getMessage());
        }
    }

    /**
     * Final submission of reviewed leads to the database
     */
    @AuraEnabled
    public static void commitSocialMediaLeads(List<SocialMediaLeadAnalysis> analysisList) {
        if (analysisList == null || analysisList.isEmpty()) return;
        
        try {
            // Retrieve Queue ID from Custom Label
            String queueId = System.Label.Social_Media_Leads_Queue;
            List<Social_Media_Leads__c> leadsToInsert = new List<Social_Media_Leads__c>();
            
            for (SocialMediaLeadAnalysis analysis : analysisList) {
                Social_Media_Leads__c record = new Social_Media_Leads__c();
                record.Name                      = analysis.name;
                record.Email__c                  = analysis.email;
                record.Mobile__c                 = analysis.phone;
                record.Secondary_Phone_Number__c = analysis.secondaryPhone;
                record.Whatsapp_number__c        = analysis.whatsappNumber;
                record.Source__c                 = analysis.source;
                record.Channel__c                = analysis.channel;
                record.CIF__c                    = analysis.cif;
                record.Is_Customer__c            = analysis.isCustomer           == true;
                record.Is_Blacklisted__c         = analysis.isBlacklisted        == true;
                record.Terminated_Relationship__c= analysis.terminatedRelationship== true;
                record.Active_Credit_Card__c     = analysis.hasActiveCreditCard  == true;
                record.Pending_Credit_Card__c    = analysis.hasPendingCreditCard == true;
                record.Declined_Credit_Card__c   = analysis.hasDeclinedCreditCard== true;
                
                // Assign to the specific queue provided in Custom Label
                if (String.isNotBlank(queueId)) {
                    record.OwnerId = (Id)queueId;
                }
                
                leadsToInsert.add(record);
            }

            if (!leadsToInsert.isEmpty()) {
                insert leadsToInsert;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error committing records: ' + e.getMessage());
        }
    }

    // --- Private Processing Engine ---

    private static String decodeFile(String base64Data) {
        try {
            return EncodingUtil.base64Decode(base64Data).toString();
        } catch (Exception e) {
            throw new AuraHandledException('Failed to read file encoding. Please ensure it is a valid UTF-8 CSV.');
        }
    }

    private static List<List<String>> parseCSV(String content) {
        List<List<String>> allRows = new List<List<String>>();
        List<String> currentRow = new List<String>();
        String currentField = '';
        Boolean inQuotes = false;
        
        // Normalize line endings to LF only for easier processing
        // but avoid large replace() calls if possible. Actually, iterating is safer.
        
        for (Integer i = 0; i < content.length(); i++) {
            String c = content.substring(i, i+1);
            String nextC = (i + 1 < content.length()) ? content.substring(i+1, i+2) : '';

            if (c == '"') {
                if (inQuotes && nextC == '"') {
                    // Double quote inside quotes = escaped quote
                    currentField += '"';
                    i++; // Skip next quote
                } else {
                    inQuotes = !inQuotes;
                }
            } else if (c == ',' && !inQuotes) {
                currentRow.add(currentField.trim());
                currentField = '';
            } else if ((c == '\n' || c == '\r') && !inQuotes) {
                if (c == '\r' && nextC == '\n') i++; // Handle CRLF
                
                currentRow.add(currentField.trim());
                if (!currentRow.isEmpty() || String.isNotBlank(currentField)) {
                    allRows.add(currentRow);
                }
                currentRow = new List<String>();
                currentField = '';
            } else {
                currentField += c;
            }
        }
        
        // Add final row if exists
        if (!currentRow.isEmpty() || String.isNotBlank(currentField)) {
            currentRow.add(currentField.trim());
            allRows.add(currentRow);
        }
        
        return allRows;
    }

    private static Map<String, Integer> getColumnMapping(List<String> headers) {
        Map<String, Integer> mapping = new Map<String, Integer>();
        for (Integer i = 0; i < headers.size(); i++) {
            String h = headers[i].toLowerCase().trim();
            if      (h == 'created')          mapping.put('created', i);
            else if (h == 'name')             mapping.put('name', i);
            else if (h == 'email address')    mapping.put('email', i);
            else if (h == 'email')            mapping.put('email', i);
            else if (h == 'source')           mapping.put('source', i);
            else if (h == 'form')             mapping.put('form', i);
            else if (h == 'channel')          mapping.put('channel', i);
            else if (h == 'company')          mapping.put('company', i);
            else if (h == 'stage')            mapping.put('stage', i);
            else if (h == 'status')           mapping.put('status', i);
            else if (h == 'owner')            mapping.put('owner', i);
            else if (h == 'country')          mapping.put('country', i);
            else if (h == 'labels')           mapping.put('labels', i);
            else if (h == 'phone')            mapping.put('phone', i);
            else if (h == 'secondary phone')  mapping.put('secondaryphone', i);
            else if (h == 'whatsapp number')  mapping.put('whatsappnumber', i);
        }
        return mapping;
    }

    private static void validateColumns(Map<String, Integer> mapping) {
        if (!mapping.containsKey('name') || !mapping.containsKey('email') 
            || (!mapping.containsKey('phone') && !mapping.containsKey('secondaryphone'))) {
            throw new AuraHandledException('Required columns (Name, Email, Phone or Secondary phone number) not found.');
        }
    }

    private static List<SocialMediaLeadAnalysis> mapRowsToAnalysisWrappers(List<List<String>> rows, Map<String, Integer> mapping) {
        List<SocialMediaLeadAnalysis> wrappers = new List<SocialMediaLeadAnalysis>();
        Integer nameIdx  = mapping.get('name');
        Integer emailIdx = mapping.get('email');
        Integer phoneIdx = mapping.containsKey('phone') ? mapping.get('phone') : mapping.get('secondaryphone');
        Integer secondaryPhoneIdx = mapping.get('secondaryphone');
        Integer whatsappNumberIdx = mapping.get('whatsappnumber');
        Integer sourceIdx = mapping.get('source');
        Integer channelIdx = mapping.get('channel');

        for (Integer i = 1; i < rows.size(); i++) {
            List<String> cols = rows[i];
            
            // Determine the maximum index we need to safely access the row columns
            Integer maxIdx = 0;
            if (nameIdx != null) maxIdx = Math.max(maxIdx, nameIdx);
            if (emailIdx != null) maxIdx = Math.max(maxIdx, emailIdx);
            if (phoneIdx != null) maxIdx = Math.max(maxIdx, phoneIdx);
            if (secondaryPhoneIdx != null) maxIdx = Math.max(maxIdx, secondaryPhoneIdx);
            if (whatsappNumberIdx != null) maxIdx = Math.max(maxIdx, whatsappNumberIdx);
            if (sourceIdx != null) maxIdx = Math.max(maxIdx, sourceIdx);
            if (channelIdx != null) maxIdx = Math.max(maxIdx, channelIdx);

            if (cols.size() > maxIdx) {
                String nameVal  = (nameIdx != null) ? cols[nameIdx].trim() : '';
                String emailVal = (emailIdx != null) ? cols[emailIdx].trim() : '';
                String phoneVal = (phoneIdx != null) ? cols[phoneIdx].trim() : '';
                String secondaryPhoneVal = (secondaryPhoneIdx != null) ? cols[secondaryPhoneIdx].trim() : '';
                String whatsappNumberVal = (whatsappNumberIdx != null) ? cols[whatsappNumberIdx].trim() : '';
                String sourceVal = (sourceIdx != null) ? cols[sourceIdx].trim() : '';
                String channelVal = (channelIdx != null) ? cols[channelIdx].trim() : '';

                // Skip empty / trailing rows
                if (String.isBlank(nameVal) && String.isBlank(emailVal)) continue;

                SocialMediaLeadAnalysis wa = new SocialMediaLeadAnalysis();
                wa.name  = nameVal;
                wa.email = emailVal;
                wa.phone = phoneVal;
                wa.secondaryPhone  = secondaryPhoneVal;
                wa.whatsappNumber  = whatsappNumberVal;
                wa.source          = sourceVal;
                wa.channel         = channelVal;
                wrappers.add(wa);
            }
        }
        return wrappers;
    }

    private static void performBulkMatchingAnalysis(List<SocialMediaLeadAnalysis> analysisList) {
        Set<String> emails = new Set<String>();
        Set<String> phones = new Set<String>();
        for (SocialMediaLeadAnalysis wa : analysisList) {
            if (String.isNotBlank(wa.email)) emails.add(wa.email.toLowerCase());
            if (String.isNotBlank(wa.phone)) phones.add(wa.phone);
        }

        // --- Account / Person Account Matching ---
        Map<String, Account> accountsByEmail = new Map<String, Account>();
        Map<String, Account> accountsByPhone = new Map<String, Account>();

        List<Account> accs = [
            SELECT Id, CIF__pc, PersonEmail, PersonMobilePhone, Subscription_Model__pc,
                   Onboarding_Stage__pc, Blacklisted__c, CustomerStatus__c
            FROM Account
            WHERE PersonEmail IN :emails
               OR PersonMobilePhone IN :phones
        ];

        for (Account a : accs) {
            if (String.isNotBlank(a.PersonEmail))
                accountsByEmail.put(a.PersonEmail.toLowerCase(), a);
            if (String.isNotBlank(a.PersonMobilePhone))
                accountsByPhone.put(a.PersonMobilePhone, a);
        }

        // Collect account IDs for credit-card case queries
        Set<Id> accountIds = new Set<Id>();
        for (Account a : accs) accountIds.add(a.Id);

        // --- Customer_Product__c: Active Credit Card lookup ---
        Set<Id> activeCCFromProduct = new Set<Id>();
        if (!accountIds.isEmpty()) {
            for (Customer_Product__c cp : [
                SELECT Customer__c
                FROM Customer_Product__c
                WHERE Customer__c IN :accountIds
                //   AND Active_Credit_Card__c = true // change requested by ashish as the backend team changed the approach
                AND (Active_Secured_Credit_Card__c = true OR Active_Unsecured_Credit_Card__c = true)
            ]) {
                activeCCFromProduct.add(cp.Customer__c);
            }
        }

        // --- Pending Credit Card: RecordType_DeveloperName__c = 'Credit_Card' AND Sub_Status__c = 'Pending' ---
        Set<Id> pendingCC = new Set<Id>();
        if (!accountIds.isEmpty()) {
            for (Case c : [
                SELECT AccountId
                FROM Case
                WHERE AccountId IN :accountIds
                  AND RecordType_DeveloperName__c = 'Credit_Card'
                  AND Status != 'Closed'
            ]) {
                pendingCC.add(c.AccountId);
            }
        }

        // --- Declined Credit Card: Credit_Card record type, Declined, within last 6 months ---
        Set<Id> declinedCC = new Set<Id>();
        if (!accountIds.isEmpty()) {
            for (Case c : [
                SELECT AccountId
                FROM Case
                WHERE AccountId IN :accountIds
                  AND RecordType_DeveloperName__c = 'Credit_Card'
                  AND Sub_Status__c = 'Declined'
                  AND CreatedDate >= LAST_N_MONTHS:6
            ]) {
                declinedCC.add(c.AccountId);
            }
        }

        // --- Enrich each analysis record ---
        for (SocialMediaLeadAnalysis wa : analysisList) {
            Account matchedAcc = null;
            if (String.isNotBlank(wa.email) && accountsByEmail.containsKey(wa.email.toLowerCase())) {
                matchedAcc = accountsByEmail.get(wa.email.toLowerCase());
            } else if (String.isNotBlank(wa.phone) && accountsByPhone.containsKey(wa.phone)) {
                matchedAcc = accountsByPhone.get(wa.phone);
            }

            if (matchedAcc != null) {
                wa.accountId             = matchedAcc.Id;
                wa.isCustomer            = (matchedAcc.Onboarding_Stage__pc == 'ACCOUNT_ACTIVATED');
                wa.cif                   =   matchedAcc.CIF__pc ; 
                wa.isBlacklisted         = matchedAcc.Blacklisted__c == true;
                wa.terminatedRelationship = (matchedAcc.CustomerStatus__c == 'Closed'  );
                wa.hasActiveCreditCard   = activeCCFromProduct.contains(matchedAcc.Id);
                wa.hasPendingCreditCard  = pendingCC.contains(matchedAcc.Id);
                wa.hasDeclinedCreditCard = declinedCC.contains(matchedAcc.Id);
            }
        }
    }
}
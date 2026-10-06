/**
* @File Name : TemporaryCreditHandler.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : November 20, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 20, 2024 |   | Initial Version
**/

public class TemporaryCreditHandler {
	@AuraEnabled
    public static Map<String, String> getDocumentType(String caseId) {
        Map<String, String> result = new Map<String, String>();
        CaseAnnex__c caseAnnex = [
        SELECT Document_Type__c, Case__r.Status
        FROM CaseAnnex__c
        WHERE Case__c = :caseId
        LIMIT 1
    ];
        result.put('DocumentType', caseAnnex.Document_Type__c);
        result.put('Status', caseAnnex.Case__r.Status);
    return result;
	}

	@AuraEnabled
    public static void updateDocumentType(String caseId, String documentType) {
        CaseAnnex__c caseAnnex = [
            SELECT Id
            FROM CaseAnnex__c
            WHERE Case__c = :caseId
            LIMIT 1
        ];

        caseAnnex.Document_Type__c = documentType;
        update caseAnnex;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getConsolidatedRoutingDetails() {
        Id queueId;
        // Get current user's profile name
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
        String profileName = userProfile.Name;
        Id profileId = userProfile.Id;
        System.debug('profileName -->'+profileName);

        String pName;
        if (profileName == 'ila Risk') {
            pName = 'Risk';
        } else if(profileName == 'RMT'){
            pName = 'RMT';
        }

        if(pName != null) {
            // Query the Queue SObject where the Queue Name matches the Profile Name
            Group queue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :pName LIMIT 1];

            // Get the Queue Id
            queueId = queue != null ? queue.Id : null;
        }
        
        // Query CMDT to get routing configurations
        List<Request_Service_Configuration__mdt> records = [
            SELECT Profile_Names__c, Type__c, Sub_Type__c, Request_Type__c, Routing__c, Record_Type__c, Case_Nature__c, Case_Origin__c
            FROM Request_Service_Configuration__mdt
        ];
        System.debug('records -->'+records);

        // List to store the consolidated data
        List<Map<String, String>> consolidatedData = new List<Map<String, String>>();
        Boolean profileFound = false;

        // Loop through all metadata records to find matching profile and types
        for (Request_Service_Configuration__mdt rec : records) {
            if (rec.Profile_Names__c != null && rec.Profile_Names__c.contains(profileName)) {
                profileFound = true;

                // Split the metadata fields by commas
                List<String> typeList = rec.Type__c != null ? rec.Type__c.split(',') : new List<String>();
                List<String> subTypeList = rec.Sub_Type__c != null ? rec.Sub_Type__c.split(',') : new List<String>();
                List<String> requestTypeList = rec.Request_Type__c != null ? rec.Request_Type__c.split(',') : new List<String>();
                List<String> caseNatureList = rec.Case_Nature__c != null ? rec.Case_Nature__c.split(',') : new List<String>();
                List<String> caseOriginList = rec.Case_Origin__c != null ? rec.Case_Origin__c.split(',') : new List<String>();
                
                System.debug('typeList -->'+typeList);
                System.debug('subTypeList -->'+subTypeList);
                System.debug('requestTypeList -->'+requestTypeList);

                // Query the object for field values (for example, Case object)
                List<String> objectTypes = getObjectFieldValues('Type');
                List<String> objectSubTypes = getObjectFieldValues('Sub_Type__c');
                List<String> objectRequestTypes = getObjectFieldValues('cc_Request_Type__c');
                List<String> objectCaseNatures = getObjectFieldValues('Case_Nature__c');
                List<String> objectCaseOrigins = getObjectFieldValues('Origin');
                
                System.debug('objectTypes -->'+objectTypes);
                System.debug('objectSubTypes -->'+objectSubTypes);
                System.debug('objectRequestTypes -->'+objectRequestTypes);
                System.debug('objectCaseNatures -->'+objectCaseNatures);
                System.debug('objectCaseOrigins -->'+objectCaseOrigins);

                // Check if the metadata values match the object values
                if (matchesFieldValues(objectTypes, typeList) && 
                    matchesFieldValues(objectSubTypes, subTypeList) && 
                    matchesFieldValues(objectRequestTypes, requestTypeList)) {
                    
                    // Prepare consolidated result map
                    Map<String, String> row = new Map<String, String>();
                    row.put('Type', rec.Type__c);
                    row.put('Sub_Type__c', rec.Sub_Type__c);
                    row.put('cc_Request_Type__c', rec.Request_Type__c);
                    row.put('Routing__c', rec.Routing__c);
                    row.put('Record_Type__c', rec.Record_Type__c);
                    row.put('ProfileName', profileName);
                    row.put('QueueId', queueId);
                    row.put('Case_Nature__c', rec.Case_Nature__c);
                    row.put('Origin', rec.Case_Origin__c);
                    consolidatedData.add(row);
                        
                    System.debug('consolidatedData -->'+consolidatedData);
                }
            }
        }

        // If profile is not found, add an error message to the map
        if (!profileFound) {
            Map<String, String> errorMap = new Map<String, String>();
            errorMap.put('Error', 'Only the RMT and Fraud Teams can create this case.');
            consolidatedData.add(errorMap);
        }

        return consolidatedData;
    }

    // Helper method to get field values from an object dynamically
    private static List<String> getObjectFieldValues(String fieldName) {
        System.debug('fieldName -->'+fieldName);
        List<String> picklistValues = new List<String>();
    
        // Use Schema to get the object and field describe information
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Case');
        
        System.debug('objType -->'+objType);
        
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        System.debug('objDescribe -->'+objDescribe);
    
        // Get field describe information for the field name passed
        Schema.DescribeFieldResult fieldDescribe = objDescribe.fields.getMap().get(fieldName).getDescribe();
        
        System.debug('fieldDescribe -->'+fieldDescribe);
    
        // Check if the field is a picklist field
        if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST) {
            // Retrieve the picklist values
            List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
        
            for (Schema.PicklistEntry entry : picklistEntries) {
                if (entry.isActive()) {
                    picklistValues.add(entry.getLabel());
                }
            }
        }
        
        System.debug('picklistValues -->'+picklistValues);
        
        return picklistValues;
    }

    // Helper method to check if the object values match the metadata values
    private static Boolean matchesFieldValues(List<String> objectValues, List<String> metadataValues) {
        
        for (String metadataValue : metadataValues) {
            System.debug('objectValues --->'+objectValues);
        System.debug('metadataValue --->'+metadataValue);
            if (!objectValues.contains(metadataValue.trim())) {
                return false;
            }
        }
        return true;
    }
    
    // New method to validate Content__c records
    @AuraEnabled
    public static Boolean hasContentRecords(Id caseId, String documentType) {
        // Query to check if there are any Content__c records with the specified Document_Type__c and Case__c
        List<Content__c> contentRecords = [
            SELECT Id 
            FROM Content__c 
            WHERE Case__c = :caseId AND Document_Type__c = :documentType
            LIMIT 1
        ];
        return !contentRecords.isEmpty(); // Return true if records exist, false otherwise
    }
    
    // New method to update the case owner to the Operations queue
    @AuraEnabled
    public static void transferToOperationsQueue(Id caseId) {
        // Replace '00GXXXXXXXXXXXX' with the actual ID of the Operations queue
        Id operationsQueueId = [SELECT Id, Name, Type FROM Group WHERE Type = 'Queue' AND Name = 'Operations Team' LIMIT 1].Id; // Queue ID for Operations

        // Update the case owner
        Case caseToUpdate = new Case(Id = caseId, OwnerId = operationsQueueId);
        update caseToUpdate;
    }
}
/**
 * @File Name          : CaseFieldDependencyController.cls
 * @Description        : Dynamically forms dependency maps for Type, Sub Type, and Request Type 
 *                       based on Custom Metadata configurations.
 **/
public class CaseFieldDependencyController {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getPicklistDataByProfile() {
        // Step 1: Get the profile name of the current user
        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;

        // Step 2: Fetch allowed types, sub-types, and request types from CMDT
        Request_Access_Configuration__mdt profileConfig = [
            SELECT Available_Types__c, Available_Sub_Types__c, Available_Request_Types__c
            FROM Request_Access_Configuration__mdt
            WHERE Profile_Names__c LIKE :('%' + profileName + '%')
            LIMIT 1
        ];

        if (profileConfig == null) {
            throw new AuraHandledException('No configurations found for this profile.');
        }

        List<String> allowedTypes = splitValues(profileConfig.Available_Types__c);
        List<String> allowedSubTypes = splitValues(profileConfig.Available_Sub_Types__c);
        List<String> allowedRequestTypes = splitValues(profileConfig.Available_Request_Types__c);
        
        System.debug('allowedRequestTypes -->'+JSON.serialize(allowedRequestTypes));
        
        // Step 3: Fetch all mappings from the custom object
        List<Case_Field_Values_Configuration__c> allMappings = [
            SELECT Type__c, Sub_Type__c, Request_Type__c
            FROM Case_Field_Values_Configuration__c
        ];

        // Step 4: Build the dependency maps
        Map<String, List<String>> subTypeMap = buildDependencyMap(
            allMappings,
            allowedTypes,
            allowedSubTypes,
            'Type__c',
            'Sub_Type__c',
            null // No additional condition needed for sub-type map
        );

        Map<String, List<String>> requestTypeMap = buildDependencyMap(
            allMappings,
            allowedSubTypes,
            allowedRequestTypes,
            'Sub_Type__c',
            'Request_Type__c',
            allowedRequestTypes // Additional condition for request type map
        );

        // Step 5: Build and return the response map
        Map<String, Object> response = new Map<String, Object>{
            'allowedTypes' => allowedTypes,
            'subTypeMap' => subTypeMap,
            'requestTypeMap' => requestTypeMap
        };

        return response;
    }

    /**
     * Helper method to build dependency maps dynamically.
     * Includes additional filtering for child field based on extraConditions if provided.
     */
    private static Map<String, List<String>> buildDependencyMap(
        List<Case_Field_Values_Configuration__c> mappings,
        List<String> parentKeys,
        List<String> childKeys,
        String parentField,
        String childField,
        List<String> extraConditions
    ) {
        List<String> normalizedChildKeys = new List<String>();
        for (String key : childKeys) {
            normalizedChildKeys.add(key.replaceAll('\\s+', ' ').trim());
        }
        
        Map<String, List<String>> dependencyMap = new Map<String, List<String>>();

        for (Case_Field_Values_Configuration__c record : mappings) {
            String parentValue = (String) record.get(parentField);
            String childValue = (String) record.get(childField);
            
            System.debug('childValue -->'+childValue);
            System.debug('parentValue -->'+parentValue);

            if (parentValue != null && childValue != null) {
                parentValue = parentValue.trim();
                childValue = childValue.trim();

                System.debug('normalizedChildKeys -->'+normalizedChildKeys);
                System.debug('parentKeys -->'+parentKeys);
                
                System.debug('1 -->'+parentKeys.contains(parentValue));
                System.debug('2 -->'+normalizedChildKeys.contains(childValue));
                
                if (parentKeys.contains(parentValue) && normalizedChildKeys.contains(childValue)) {
                    System.debug('3 -->'+!dependencyMap.containsKey(parentValue));
                    if (!dependencyMap.containsKey(parentValue)) {
                        System.debug('4 -->');
                        dependencyMap.put(parentValue, new List<String>());
                    }

                    // Apply additional conditions if provided
                    if (extraConditions == null || extraConditions.contains(childValue)) {
                        if (!dependencyMap.get(parentValue).contains(childValue)) {
                            dependencyMap.get(parentValue).add(childValue);
                        }
                    }
                }
            }
        }

        return dependencyMap;
    }

    /**
     * Helper method to split comma-separated values.
     */
    private static List<String> splitValues(String input) {
        return (String.isNotBlank(input)) ? input.split(',') : new List<String>();
    }

    /**
     * Fetches Case Nature and Routing based on Type, Sub Type, and Request Type.
     * @param type The Type parameter.
     * @param subType The Sub Type parameter.
     * @param requestType The Request Type parameter.
     * @return A Map with keys 'CaseNature' and 'Routing' containing their respective values.
     */
    @AuraEnabled
    public static Map<String, String> fetchCaseNatureAndRouting(String type, String subType, String requestType) {
        Map<String, String> result = new Map<String, String>();

        try {
            Case_Field_Values_Configuration__c configRecord = [
                SELECT Case_Nature__c, Routing__c, Record_Type_Name__c 
                FROM Case_Field_Values_Configuration__c
                WHERE Type__c = :type
                  AND Sub_Type__c = :subType
                  AND Request_Type__c = :requestType
                LIMIT 1
            ];

            result.put('CaseNature', configRecord.Case_Nature__c);
            result.put('Routing', configRecord.Routing__c);
            result.put('RecordTypeName', configRecord.Record_Type_Name__c);
        } catch (Exception e) {
            // Handle case where no record is found or other exceptions
            throw new AuraHandledException('No matching configuration found or an error occurred: ' + e.getMessage());
        }

        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Id> getQueueNameToIdMap() {
        Map<String, Id> queueMap = new Map<String, Id>();
        
        // Query Group object where Type is 'Queue'
        List<Group> queueList = [
            SELECT Id, Name 
            FROM Group 
            WHERE Type = 'Queue'
        ];
        
        // Populate the map with Queue Name and Id
        for (Group queue : queueList) {
            queueMap.put(queue.Name, queue.Id);
        }
        
        return queueMap;
    }
    
    /**
     * Fetches Case Nature and Routing based on Type, Sub Type, and Request Type.
     * @param type The Type parameter.
     * @param subType The Sub Type parameter.
     * @param requestType The Request Type parameter.
     * @return A Map with keys 'CaseNature' and 'Routing' containing their respective values.
     */
    @AuraEnabled
    public static Map<String, String> fetchCaseNatureAndRoutingUsingSubType(String type, String subType) {
        Map<String, String> result = new Map<String, String>();

        try {
            Case_Field_Values_Configuration__c configRecord = [
                SELECT Case_Nature__c, Routing__c, Record_Type_Name__c
                FROM Case_Field_Values_Configuration__c
                WHERE Type__c = :type
                  AND Sub_Type__c = :subType
                LIMIT 1
            ];

            result.put('CaseNature', configRecord.Case_Nature__c);
            result.put('Routing', configRecord.Routing__c);
            result.put('RecordTypeName', configRecord.Record_Type_Name__c);
        } catch (Exception e) {
            // Handle case where no record is found or other exceptions
            throw new AuraHandledException('No matching configuration found or an error occurred: ' + e.getMessage());
        }

        return result;
    }

    @AuraEnabled
    public static void callResettingRecoveryCodeSMS(Id CaseId) {
        // Call the @future method
        Set<Id> setCaseId = new Set<Id>();
        setCaseId.add(CaseId);
        RequestAppUnlockController.resettingRecoveryCodeSMS(setCaseId);
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean isUserInMakerQueue() {
        Id userId = UserInfo.getUserId();

        // Fetch queue Id
        Group makerQueue = [
            SELECT Id 
            FROM Group 
            WHERE Type = 'Queue' 
            AND Name = 'Segment Change - Maker' 
            LIMIT 1
        ];

        // Check if user belongs to the queue
        Integer countMemberships = [
            SELECT COUNT() 
            FROM GroupMember 
            WHERE GroupId = :makerQueue.Id 
            AND UserOrGroupId = :userId
        ];

        return (countMemberships > 0);
    }

    /**
     * NEW: Fetch Account ID by CIF (for URL access)
     * @param cif The Customer CIF number
     * @return Account Id or null if not found
     */
    @AuraEnabled(cacheable=true)
    public static Id getAccountIdByCIF(String cif) {
        if (String.isBlank(cif)) {
            return null;
        }
        // Replace 'Customer_CIF__c' with the actual field name on Account that stores CIF
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
}
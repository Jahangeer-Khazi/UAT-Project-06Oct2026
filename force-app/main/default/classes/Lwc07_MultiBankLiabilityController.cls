public without sharing class Lwc07_MultiBankLiabilityController {

    private static final String PRE_SCREENER_QUEUE = 'Loan_Document_Verifier_OBL';//RCD meaining "Loan_Document_Verifier_OBL" not "Loan_Pre_Screer_Queue" //toDo
    private static final String OPERATIONS_QUEUE = 'Loan_Operations_Team';

    @AuraEnabled(cacheable=true)
    public static InitializationResponse getInitializationData(Id recordId) {
        if (recordId == null) {
            throw new AuraHandledException('Case Id cannot be null.');
        }

        try {
            Case caseRecord = [ SELECT Id, OwnerId FROM Case WHERE Id = :recordId LIMIT 1];
            List<CaseAnnex__c> annexes = [ SELECT Id,cx_ln_Requested_MultiBankLiabilities__c,cx_ln_Approved_Buyout_Amount__c FROM CaseAnnex__c WHERE Case__c = :recordId LIMIT 1];

            if (annexes.isEmpty()) {
                throw new AuraHandledException('No Case Annex record was found for this Case.');
            }

            InitializationResponse response = new InitializationResponse();
            response.caseAnnexId = annexes[0].Id;
            response.multiBankLiabilitiesJson = annexes[0].cx_ln_Requested_MultiBankLiabilities__c;
            response.approvedBuyoutAmount = annexes[0].cx_ln_Approved_Buyout_Amount__c;
            response.entityOptions = getActiveEntityOptions();
            response.permissions = resolvePermissions(caseRecord.OwnerId);

            return response;
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'Lwc07_MultiBankLiabilityController.getInitializationData: ' +e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException('An error occurred while loading Multi-Bank Liabilities.');
        }
    }

    @AuraEnabled
    public static SaveResponse saveMultiBankLiabilities(Id recordId, String liabilitiesJson) {
        if (recordId == null) {
            throw new AuraHandledException('Case Id cannot be null.');
        }
        if (String.isBlank(liabilitiesJson)) {
            throw new AuraHandledException('Multi-Bank Liability JSON cannot be empty.');
        }

        try {
            Case caseRecord = [SELECT Id, OwnerId FROM Case WHERE Id = :recordId LIMIT 1 ];

            PermissionsResponse permissions = resolvePermissions(caseRecord.OwnerId);
            if (!permissions.canModifyTable) {
                throw new AuraHandledException('You are not authorized to modify Multi-Bank Liabilities for this Case.');
            }

            List<CaseAnnex__c> annexes = [SELECT Id, cx_ln_Requested_MultiBankLiabilities__c FROM CaseAnnex__c WHERE Case__c = :recordId LIMIT 1 FOR UPDATE];

            if (annexes.isEmpty()) {
                throw new AuraHandledException('No Case Annex record was found for this Case.');
            }

            CaseAnnex__c annex = annexes[0];
            Set<String> activeEntities = getActiveEntityNames();

            List<Map<String, Object>> normalizedRows = validateAndNormalizeRows( liabilitiesJson, annex.cx_ln_Requested_MultiBankLiabilities__c, permissions, activeEntities);

            Decimal approvedBuyoutAmount = calculateApprovedBuyoutAmount(normalizedRows);
            String normalizedJson = JSON.serialize(normalizedRows);

            CaseAnnex__c updateAnnex = new CaseAnnex__c(Id = annex.Id,cx_ln_Requested_MultiBankLiabilities__c = normalizedJson,cx_ln_Approved_Buyout_Amount__c = approvedBuyoutAmount);
            update updateAnnex;

            SaveResponse response = new SaveResponse();
            response.multiBankLiabilitiesJson = normalizedJson;
            response.approvedBuyoutAmount = approvedBuyoutAmount;
            return response;
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'Lwc07_MultiBankLiabilityController.saveMultiBankLiabilities: ' +e.getMessage() + '\n' + e.getStackTraceString());
            //throw new AuraHandledException('An error occurred while saving Multi-Bank Liabilities.');
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<EntityOption> getActiveEntityOptions() {
        List<EntityOption> options = new List<EntityOption>();

        for (Loan_MultiBankLiability__mdt config : [SELECT EntityBankName__c, PaymentType__c FROM Loan_MultiBankLiability__mdt WHERE IsActive__c = true ORDER BY EntityBankName__c]) {
            if (String.isBlank(config.EntityBankName__c)) {
                continue;
            }

            EntityOption option = new EntityOption();
            option.label = config.EntityBankName__c.trim();
            option.value = config.EntityBankName__c.trim();
            option.paymentType = config.PaymentType__c;
            options.add(option);
        }

        return options;
    }

    private static Set<String> getActiveEntityNames() {
        Set<String> names = new Set<String>();
        for (Loan_MultiBankLiability__mdt config : [SELECT EntityBankName__c FROM Loan_MultiBankLiability__mdt WHERE IsActive__c = true]) {
            if (!String.isBlank(config.EntityBankName__c)) {
                names.add(normalizeEntityKey(config.EntityBankName__c));
            }
        }
        return names;
    }

    private static PermissionsResponse resolvePermissions(Id caseOwnerId) {
        Set<String> targetQueueDeveloperNames = new Set<String>{PRE_SCREENER_QUEUE,OPERATIONS_QUEUE};

        Map<String, Group> queuesByDeveloperName = new Map<String, Group>();
        for (Group queueGroup : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN :targetQueueDeveloperNames]) {
            queuesByDeveloperName.put(queueGroup.DeveloperName, queueGroup);
        }

        Id preScreenerQueueId = queuesByDeveloperName.containsKey(PRE_SCREENER_QUEUE) ? queuesByDeveloperName.get(PRE_SCREENER_QUEUE).Id : null;
        Id operationsQueueId = queuesByDeveloperName.containsKey(OPERATIONS_QUEUE) ? queuesByDeveloperName.get(OPERATIONS_QUEUE).Id : null;

        Id ownerUserRoleId;
        Set<Id> ownerRoleAndAncestors = new Set<Id>();
        Boolean ownerIsUser = caseOwnerId != null && String.valueOf(caseOwnerId).startsWith('005');

        if (ownerIsUser) { ownerRoleAndAncestors = getRoleAndAncestorIds([SELECT Id, UserRoleId FROM User WHERE Id = :caseOwnerId LIMIT 1].UserRoleId);}

        Boolean isPreScreenerContext = isOwnerInQueueContext(caseOwnerId,preScreenerQueueId,ownerUserRoleId,ownerRoleAndAncestors);
        Boolean isOperationsContext = isOwnerInQueueContext(caseOwnerId,operationsQueueId,ownerUserRoleId,ownerRoleAndAncestors);

        Profile currentProfile = [SELECT PermissionsModifyAllData FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
        Boolean isAdmin = currentProfile.PermissionsModifyAllData;

        PermissionsResponse result = new PermissionsResponse();
        result.isAdmin = isAdmin;
        result.isPreScreenerContext = isPreScreenerContext;
        result.isOperationsContext = isOperationsContext;

        result.canEditEntityOutstanding = isAdmin || isPreScreenerContext;

        // Admin overrides queue visibility restrictions.
        // If a non-admin owner context resolves to both queues, Pre-Screener wins
        // for Liability ID visibility because that field must be hidden there.
        result.showLiabilityId = isAdmin || !isPreScreenerContext;
        result.canEditLiabilityId = isAdmin || isOperationsContext;

        result.canAddRow = isAdmin || isPreScreenerContext;
        result.canModifySelection = isAdmin || isPreScreenerContext || isOperationsContext;
        result.canModifyTable = isAdmin || isPreScreenerContext || isOperationsContext;

        return result;
    }

    private static Boolean isOwnerInQueueContext(Id ownerId,Id queueId,Id ownerUserRoleId,Set<Id> ownerRoleAndAncestors) {
        if (ownerId == null || queueId == null) { return false;}

        if (ownerId == queueId) {
            return true;
        }

        // A Case owner can be a User or a Queue. Queue membership evaluation
        // only applies when the Case is directly owned by a User.
        if (!String.valueOf(ownerId).startsWith('005')) {
            return false;
        }

        return isUserMemberOfQueue( ownerId, queueId, ownerUserRoleId, ownerRoleAndAncestors);
    }

    /**
     * Resolves direct User membership, nested Public Group membership,
     * Role membership, and Role-and-Subordinates membership for a Queue.
     */
    public static Boolean isUserMemberOfQueue(Id userId,Id queueId,Id userRoleId,Set<Id> userRoleAndAncestors) {
        Set<Id> groupsToInspect = new Set<Id>{ queueId };
        Set<Id> inspectedGroups = new Set<Id>();
        Integer safetyCounter = 0;

        while (!groupsToInspect.isEmpty() && safetyCounter < 20) {
            safetyCounter++;
            groupsToInspect.removeAll(inspectedGroups);
            if (groupsToInspect.isEmpty()) {
                break;
            }

            Set<Id> currentGroupIds = new Set<Id>(groupsToInspect);
            inspectedGroups.addAll(currentGroupIds);
            groupsToInspect.clear();

            List<GroupMember> memberships = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :currentGroupIds];

            Set<Id> nestedGroupIds = new Set<Id>();
            for (GroupMember membership : memberships) {
                if (membership.UserOrGroupId == userId) {
                    return true;
                }

                if (String.valueOf(membership.UserOrGroupId).startsWith('00G')) {
                    nestedGroupIds.add(membership.UserOrGroupId);
                }
            }

            if (nestedGroupIds.isEmpty()) {
                continue;
            }

            for (Group nestedGroup : [SELECT Id, Type, RelatedId FROM Group WHERE Id IN :nestedGroupIds]) {
                if (nestedGroup.Type == 'Role') {
                    if (nestedGroup.RelatedId != null && userRoleId == nestedGroup.RelatedId) {
                        return true;
                    }
                    continue;
                }

                if (nestedGroup.Type == 'RoleAndSubordinates' || nestedGroup.Type == 'RoleAndSubordinatesInternal') {
                    if (nestedGroup.RelatedId != null && userRoleAndAncestors.contains(nestedGroup.RelatedId)) {
                        return true;
                    }
                    continue;
                }

                // Regular/Public groups (and any other explicitly nested groups)
                // are traversed recursively through GroupMember.
                if (!inspectedGroups.contains(nestedGroup.Id)) {
                    groupsToInspect.add(nestedGroup.Id);
                }
            }
        }

        return false;
    }

    private static Set<Id> getRoleAndAncestorIds(Id userRoleId) {
        Set<Id> result = new Set<Id>();
        if (userRoleId == null) {
            return result;
        }

        Map<Id, UserRole> rolesById = new Map<Id, UserRole>([ SELECT Id, ParentRoleId FROM UserRole]);

        Id currentRoleId = userRoleId;
        Integer safetyCounter = 0;
        while (currentRoleId != null && safetyCounter < 20 && !result.contains(currentRoleId)) {
            safetyCounter++;
            result.add(currentRoleId);

            UserRole currentRole = rolesById.get(currentRoleId);
            currentRoleId = currentRole == null ? null : currentRole.ParentRoleId;
        }

        return result;
    }

    private static List<Map<String, Object>> validateAndNormalizeRows(String submittedJson,String persistedJson,PermissionsResponse permissions,Set<String> activeEntities) {
        Map<String, String> paymentTypeByEntity = new Map<String, String>();
        for (Loan_MultiBankLiability__mdt config : [SELECT EntityBankName__c, PaymentType__c FROM Loan_MultiBankLiability__mdt WHERE IsActive__c = true]) {
            if (!String.isBlank(config.EntityBankName__c)) {
                paymentTypeByEntity.put(
                    normalizeEntityKey(config.EntityBankName__c),
                    config.PaymentType__c
                );
            }
        }

        List<Object> submittedRows = deserializeRows(submittedJson);
        List<Object> persistedRows = deserializeRows(persistedJson);

        Map<String, Map<String, Object>> persistedById = new Map<String, Map<String, Object>>();
        for (Object persistedObject : persistedRows) {
            Map<String, Object> row = castRow(persistedObject);
            String rowId = getStringValue(row, 'Id');
            if (!String.isBlank(rowId)) {
                persistedById.put(rowId, row);
            }
        }

        if (submittedRows.size() < persistedRows.size()) {
            throw new AuraHandledException('Deleting Multi-Bank Liability rows is not supported.');
        }

        Set<String> submittedIds = new Set<String>();
        Set<String> entityKeys = new Set<String>();
        List<Map<String, Object>> normalizedRows = new List<Map<String, Object>>();

        for (Integer index = 0; index < submittedRows.size(); index++) {
            Map<String, Object> submitted = castRow(submittedRows[index]);
            String rowId = getStringValue(submitted, 'Id');

            if (String.isBlank(rowId)) {
                throw new AuraHandledException('Every Multi-Bank Liability row must have an Id.');
            }
            if (submittedIds.contains(rowId)) {
                throw new AuraHandledException('Duplicate Multi-Bank Liability row Id detected: ' + rowId + '.');
            }
            submittedIds.add(rowId);

            Boolean isNewRow = !persistedById.containsKey(rowId);
            if (isNewRow && !permissions.canAddRow) {
                throw new AuraHandledException('You are not authorized to add Multi-Bank Liability rows.');
            }

            Map<String, Object> persisted = isNewRow ? null : persistedById.get(rowId);

            String entity = getStringValue(submitted, 'entity');
            Decimal outstanding = getDecimalValue(submitted, 'outstanding');
            String liabilityId = getStringValue(submitted, 'liabilityID');
            String chequeNumber = getStringValue(submitted, 'chequeNumber');
            Boolean selected = getBooleanValue(submitted, 'selected', true);

            String entityKey = normalizeEntityKey(entity);
            Boolean isChequePayment = paymentTypeByEntity.containsKey(entityKey) && 'cheque'.equalsIgnoreCase(paymentTypeByEntity.get(entityKey));
            if (!String.isBlank(entityKey)) {
                if (entityKeys.contains(entityKey)) {
                    throw new AuraHandledException('Entity/Bank must be unique. Duplicate value: ' + entity + '.');
                }
                entityKeys.add(entityKey);
            }

            if (outstanding != null && outstanding < 0) {
                throw new AuraHandledException('Outstanding Amount cannot be negative on row ' + rowId + '.');
            }

            if (permissions.canEditEntityOutstanding) {
                if (String.isBlank(entity)) {
                    throw new AuraHandledException('Entity/Bank is required on row ' + rowId + '.');
                }
                if (outstanding == null) {
                    throw new AuraHandledException('Outstanding Amount is required on row ' + rowId + '.');
                }

                Boolean entityChanged = isNewRow || !stringsEqual(entity, getStringValue(persisted, 'entity'));
                if (entityChanged && !activeEntities.contains(entityKey)) {
                    throw new AuraHandledException( 'Entity/Bank "' + entity + '" is not an active Loan Multi-Bank Liability configuration value.');
                }
            } else {
                if (isNewRow) {
                    throw new AuraHandledException('You are not authorized to add Multi-Bank Liability rows.');
                }

                if (!stringsEqual(entity, getStringValue(persisted, 'entity')) || !decimalsEqual(outstanding, getDecimalValue(persisted, 'outstanding'))) {
                    throw new AuraHandledException('Entity/Bank and Outstanding Amount are read-only in your current Case ownership context.');
                }
            }

            if (permissions.canEditLiabilityId) {
                if (String.isBlank(liabilityId)) {
                    throw new AuraHandledException('Liability ID is required on row ' + rowId + '.');
                }
            } else {
                if (isNewRow) {
                    if (!String.isBlank(liabilityId)) {
                        throw new AuraHandledException('Liability ID cannot be set in the Pre-Screener context.');
                    }
                } else if (!stringsEqual(liabilityId, getStringValue(persisted, 'liabilityID'))) {
                    throw new AuraHandledException('Liability ID is read-only in your current Case ownership context.');
                }
            }

            if (isChequePayment) {
                if (permissions.canEditLiabilityId) {
                    if (String.isBlank(chequeNumber)) {
                        throw new AuraHandledException('Cheque Number is required on row ' + rowId + '.');
                    }
                } else {
                    if (isNewRow && !String.isBlank(chequeNumber)) {
                        throw new AuraHandledException('Cheque Number is read-only in your current Case ownership context.');
                    }

                    if (!isNewRow &&
                        !stringsEqual(chequeNumber, getStringValue(persisted, 'chequeNumber'))) {
                        throw new AuraHandledException('Cheque Number is read-only in your current Case ownership context.');
                    }
                }
            } else {
                // Cheque Number is not applicable for non-Cheque payment types.
                // Clear any previous value automatically when Entity/Bank changes.
                chequeNumber = '';
            }

            Map<String, Object> normalized = new Map<String, Object>();
            normalized.put('Id', rowId);
            normalized.put('selected', selected);
            normalized.put('entity', entity);
            normalized.put('outstanding', outstanding);
            normalized.put('liabilityID', liabilityId);
            normalized.put('chequeNumber', chequeNumber);
            normalizedRows.add(normalized);
        }

        // Existing rows cannot be silently removed by manipulating the client JSON.
        for (String persistedId : persistedById.keySet()) {
            if (!submittedIds.contains(persistedId)) {
                throw new AuraHandledException('Deleting Multi-Bank Liability rows is not supported.');
            }
        }

        return normalizedRows;
    }

    private static Decimal calculateApprovedBuyoutAmount(List<Map<String, Object>> rows) {
        Decimal total = 0;

        for (Map<String, Object> row : rows) {
            Boolean selected = getBooleanValue(row, 'selected', true);
            Decimal outstanding = getDecimalValue(row, 'outstanding');

            if (selected && outstanding != null) {
                total += outstanding;
            }
        }

        return total;
    }

    private static List<Object> deserializeRows(String jsonValue) {
        if (String.isBlank(jsonValue)) {
            return new List<Object>();
        }

        Object parsed;
        try {
            parsed = JSON.deserializeUntyped(jsonValue);
        } catch (Exception e) {
            throw new AuraHandledException('Multi-Bank Liability data contains invalid JSON.');
        }

        if (!(parsed instanceof List<Object>)) {
            throw new AuraHandledException('Multi-Bank Liability data must be a JSON array.');
        }

        return (List<Object>)parsed;
    }

    private static Map<String, Object> castRow(Object rowObject) {
        if (!(rowObject instanceof Map<String, Object>)) {
            throw new AuraHandledException('Each Multi-Bank Liability entry must be a JSON object.');
        }
        return (Map<String, Object>)rowObject;
    }

    private static String getStringValue(Map<String, Object> row, String fieldName) {
        if (row == null || !row.containsKey(fieldName) || row.get(fieldName) == null) {
            return '';
        }
        return String.valueOf(row.get(fieldName)).trim();
    }

    private static Decimal getDecimalValue(Map<String, Object> row, String fieldName) {
        if (row == null || !row.containsKey(fieldName) || row.get(fieldName) == null) {
            return null;
        }

        String value = String.valueOf(row.get(fieldName));
        if (String.isBlank(value)) {
            return null;
        }

        try {
            return Decimal.valueOf(value);
        } catch (Exception e) {
            throw new AuraHandledException(fieldName + ' must contain a valid number.');
        }
    }

    private static Boolean getBooleanValue(Map<String, Object> row, String fieldName, Boolean defaultValue) {
        if (row == null || !row.containsKey(fieldName) || row.get(fieldName) == null) {
            return defaultValue;
        }

        Object rawValue = row.get(fieldName);
        if (rawValue instanceof Boolean) {
            return (Boolean)rawValue;
        }
        return String.valueOf(rawValue).toLowerCase() == 'true';
    }

    private static Boolean stringsEqual(String leftValue, String rightValue) {
        String leftNormalized = leftValue == null ? '' : leftValue.trim();
        String rightNormalized = rightValue == null ? '' : rightValue.trim();
        return leftNormalized == rightNormalized;
    }

    private static Boolean decimalsEqual(Decimal leftValue, Decimal rightValue) {
        if (leftValue == null && rightValue == null) {
            return true;
        }
        if (leftValue == null || rightValue == null) {
            return false;
        }
        return leftValue == rightValue;
    }

    private static String normalizeEntityKey(String value) {
        return String.isBlank(value) ? '' : value.trim().toLowerCase();
    }

    public class InitializationResponse {
        @AuraEnabled public Id caseAnnexId { get; set; }
        @AuraEnabled public String multiBankLiabilitiesJson { get; set; }
        @AuraEnabled public Decimal approvedBuyoutAmount { get; set; }
        @AuraEnabled public List<EntityOption> entityOptions { get; set; }
        @AuraEnabled public PermissionsResponse permissions { get; set; }
    }

    public class SaveResponse {
        @AuraEnabled public String multiBankLiabilitiesJson { get; set; }
        @AuraEnabled public Decimal approvedBuyoutAmount { get; set; }
    }

    public class EntityOption {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String paymentType { get; set; }
    }

    public class PermissionsResponse {
        @AuraEnabled public Boolean isAdmin { get; set; }
        @AuraEnabled public Boolean isPreScreenerContext { get; set; }
        @AuraEnabled public Boolean isOperationsContext { get; set; }
        @AuraEnabled public Boolean canEditEntityOutstanding { get; set; }
        @AuraEnabled public Boolean canEditLiabilityId { get; set; }
        @AuraEnabled public Boolean canAddRow { get; set; }
        @AuraEnabled public Boolean canModifySelection { get; set; }
        @AuraEnabled public Boolean canModifyTable { get; set; }
        @AuraEnabled public Boolean showLiabilityId { get; set; }
    }
}
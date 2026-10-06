public with sharing class CaseNotificationController {
    
    // Mapping: Product + Stage -> Template Key
    private static final Map<String, String> TEMPLATE_MAP = new Map<String, String>{
        'ILA_PRE'   => 'DISC_SMS_PRE_ILA',
        'ILA_OBL'   => 'DISC_SMS_OBL_ILA',
        'ILA_NDL'   => 'DISC_SMS_NDL_ILA',
        'ILA_STL'   => 'DISC_SMS_STL_ILA',
        'ILA_TP'    => 'DISC_SMS_TP_ILA',
        'ALBURAQ_PRE' => 'DISC_SMS_PRE_ALBURAQ',
        'ALBURAQ_OBL' => 'DISC_SMS_OBL_ALBURAQ',
        'ALBURAQ_NDL' => 'DISC_SMS_NDL_ALBURAQ',
        'ALBURAQ_STL' => 'DISC_SMS_STL_ALBURAQ',
        'ALBURAQ_TP'  => 'DISC_SMS_TP_ALBURAQ'
    };

    // Human-readable labels for the Chatter feed
    private static final Map<String, String> STAGE_LABELS = new Map<String, String>{
        'PRE' => 'Pre-Screener',
        'OBL' => 'OBL',
        'NDL' => 'NDL',
        'STL' => 'STL',
        'TP'  => 'Top-up'
    };

    // Queue name → stage code (used as fallback when owner name does not contain keywords)
    private static final Map<String, String> STAGE_MAPPING = new Map<String, String>{
        'Loan Pre-Screener Queue'    => 'PRE',
        'Loan Document Verifier OBL' => 'OBL',
        'Loan Document Verifier NDL' => 'NDL',
        'Loan Document Verifier STL' => 'STL'
    };

    // Order matters – first match wins
    private static final List<String> STAGE_ORDER = new List<String>{
        'Loan Pre-Screener Queue',
        'Loan Document Verifier OBL',
        'Loan Document Verifier NDL',
        'Loan Document Verifier STL'
    };

    @AuraEnabled
    public static String sendDiscrepancySMS(Id caseId) {

        if (caseId == null) {
            return 'ERROR: Case ID is missing.';
        }

        // Query Case with all needed fields – now including Sub_Type__c
        Case c = [
            SELECT Id, Case_Model__c, OwnerId, Owner.Name,
                   Account.PersonMobilePhone, Account.CIF__pc,
                   AccountId, Region_Flag__c, Sub_Type__c
            FROM Case
            WHERE Id = :caseId
        ];

        // Determine product
        String product = c.Case_Model__c;
        if (String.isBlank(product)) {
            return 'ERROR: Case Model (product) is missing.';
        }
        String productKey = product.toLowerCase().contains('alburaq') ? 'ALBURAQ' : 'ILA';

        System.debug('DISCREPANCY SMS - Case Model: ' + product);
        System.debug('DISCREPANCY SMS - Product Key: ' + productKey);

        // Determine stage – now passing the full case record
        String stage = getStageFromCase(c);

        System.debug('DISCREPANCY SMS - Sub Type: ' + c.Sub_Type__c);
        System.debug('DISCREPANCY SMS - Owner Name: ' + c.Owner.Name);
        System.debug('DISCREPANCY SMS - Determined Stage: ' + stage);

        if (String.isBlank(stage)) {
            return 'ERROR: Unable to determine stage from Sub_Type or Owner name. ' +
                   'Sub_Type: ' + c.Sub_Type__c + ', Owner: ' + c.Owner.Name;
        }

        // Get template key
        String templateMapKey = productKey + '_' + stage;
        String templateKey = TEMPLATE_MAP.get(templateMapKey);

        System.debug('DISCREPANCY SMS - Template Map Key: ' + templateMapKey);
        System.debug('DISCREPANCY SMS - Selected Template Key: ' + templateKey);

        if (String.isBlank(templateKey)) {
            return 'ERROR: No template configured for product=' + productKey + ', stage=' + stage;
        }

        // Get customer mobile
        String mobile = c.Account?.PersonMobilePhone;
        if (String.isBlank(mobile)) {
            return 'ERROR: Customer mobile number not available.';
        }

        // Build and send API request
        ApiConnection con = new ApiConnection();
        String regionName = c.Region_Flag__c;
        if (c.Case_Model__c == 'alburaq') {
            regionName += '_alburaq';
        }

        HttpRequest request = con.createRequest('POST', '/api/v1/notifications?', regionName);
        //HttpRequest request = con.createRequest('POST', '/api/v1/notificationssss?', regionName);
        request.setHeader('Content-Type', 'application/json');

        Map<String, Object> payload = new Map<String, Object>{
            'templateCode' => templateKey,
            'type' => 'sms',
            'subject' => null,
            'phoneNumber' => mobile
        };

        String reqBody = JSON.serialize(payload);
        request.setBody(reqBody);

        System.debug('DISCREPANCY SMS - Request Template Code: ' + templateKey);

        HttpResponse response;
        try {
            Http http = new Http();
            response = http.send(request);
        } catch (Exception e) {
            logSystemAction(
                reqBody,
                'Exception: ' + e.getMessage(),
                request.getEndpoint(),
                'POST',
                c.Id,
                c.Account?.CIF__pc,
                c.AccountId,
                500,
                'Send Discrepancy SMS',
                'Discrepancy SMS'
            );
            return 'ERROR: Exception during callout: ' + e.getMessage();
        }

        // Log attempt
        logSystemAction(
            reqBody,
            response.getBody(),
            request.getEndpoint(),
            'POST',
            c.Id,
            c.Account?.CIF__pc,
            c.AccountId,
            response.getStatusCode(),
            'Send Discrepancy SMS',
            'Discrepancy SMS'
        );

        // Return result & create FeedItem on success
        if (response.getStatusCode() == 200) {

            // ✅ Get the human-readable stage label
            String stageDisplay = STAGE_LABELS.get(stage);

            // ✅ Create a beautiful Chatter post
            try {
                FeedItem feed = new FeedItem();
                feed.ParentId = c.Id;
                feed.IsRichText = true;

                // Dynamic heading using the human-readable stage label
                String feedBody = '<b>✅ ' + stageDisplay + ' Discrepancy SMS Sent Successfully</b>' +
                                  '<p> </p>' +
                                  '<b>Template:</b> ' + templateKey;

                feed.Body = feedBody;
                insert feed;

                System.debug('FeedItem created for Case ' + c.Id);

            } catch (Exception e) {
                // Feed creation failed – log it but don't break the success response
                System.debug('Failed to create FeedItem: ' + e.getMessage());
            }

            return 'SUCCESS: SMS sent successfully.';

        } else {
            return 'FAILURE: Service returned status ' + response.getStatusCode() +
                   ' - ' + response.getBody();
        }
    }

    // ------------------------------------------------------------------
    // Enhanced stage detection: first check Sub_Type__c, then Owner name
    private static String getStageFromCase(Case caseRecord) {
        // 1. If Sub_Type is 'Top-up', return 'TP' immediately
        if (caseRecord.Sub_Type__c != null && 
            caseRecord.Sub_Type__c.equalsIgnoreCase('Top-up')) {

            System.debug('DISCREPANCY SMS - Stage determined from Sub Type: TP');
            return 'TP';
        }

        // 2. Otherwise, fall back to owner-name-based detection
        System.debug('DISCREPANCY SMS - Sub Type is not Top-up. Checking Owner Name for Stage.');
        return getStageFromOwnerName(caseRecord.Owner.Name);
    }

    // Original helper (kept for clarity)
    private static String getStageFromOwnerName(String ownerName) {
        if (String.isBlank(ownerName)) {
            System.debug('DISCREPANCY SMS - Owner Name is blank. Unable to determine stage.');
            return null;
        }

        String lower = ownerName.toLowerCase();

        for (String key : STAGE_ORDER) {
            if (lower.contains(key.toLowerCase())) {
                System.debug('DISCREPANCY SMS - Owner matched Stage Key: ' + key);
                System.debug('DISCREPANCY SMS - Stage from Owner: ' + STAGE_MAPPING.get(key));
                return STAGE_MAPPING.get(key);
            }
        }

        System.debug('DISCREPANCY SMS - No Stage matched from Owner Name: ' + ownerName);
        return null;
    }

    // Logging method (unchanged)
    private static void logSystemAction(
        String reqBody,
        String resBody,
        String endpoint,
        String method,
        Id caseId,
        String customerCIF,
        Id accountId,
        Integer statusCode,
        String actionName,
        String typeName
    ) {
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = customerCIF;
        action.Action__c = actionName;
        action.Case__c = caseId;
        action.Account__c = accountId;
        action.Endpoint__c = endpoint;
        action.Method__c = method;
        action.HTTP_Response_Code__c = statusCode;
        action.Origin__c = 'CRM';
        action.Request_Body__c = reqBody;
        action.Response_Body__c = resBody;
        action.Target__c = 'Orchestration Layer';
        action.Type__c = typeName;

        try {
            insert action;
        } catch (Exception e) {
            // silently ignore
        }
    }
}
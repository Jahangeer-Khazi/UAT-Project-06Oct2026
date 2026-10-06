public class CancelPlanQueueable implements Queueable {

    private Set<Id> caseIds;
    @TestVisible
    private static ApiConnection con = new ApiConnection();

    private static final String ACTION_NAME   = 'EPP Cancel';
    private static final String HTTP_METHOD   = 'POST';
    private static final String ENDPOINT_PATH = '/api/v1/credit-cards/epp/cancel';

    /**
     * API success codes returned inside response.meta.code
     * Add new success codes here as the API evolves.
     */
    private static final Set<String> SUCCESS_CODES = new Set<String>{
        'CCRD-1016'   // credit card EPP canceled
    };

    public CancelPlanQueueable(Set<Id> caseIds) {
        this.caseIds = caseIds;
    }

    public void execute(QueueableContext context) {
        processCancelPlans(caseIds);
    }

    @future(callout=true)
    private static void processCancelPlans(Set<Id> caseIds) {

        List<Case> cases = [
            SELECT Id,
                   cc_PCI_Id__c,
                   cc_Balance_Transfer_Card_Number__c,
                   cc_Balance_Transfer_Reference_Number__c,
                   Customer_CIF__c,
                   Region_Flag__c,
                   AccountId,
                   RecordType.Name
            FROM Case
            WHERE Id IN :caseIds
        ];

        List<Case> casesToUpdate               = new List<Case>();
        List<System_Action__c> actionsToInsert = new List<System_Action__c>();

        for (Case caseRecord : cases) {

            // Skip records missing required data — no callout performed
            if (String.isBlank(caseRecord.cc_PCI_Id__c) ||
                String.isBlank(caseRecord.cc_Balance_Transfer_Card_Number__c) ||
                String.isBlank(caseRecord.cc_Balance_Transfer_Reference_Number__c)) {
                casesToUpdate.add(caseRecord);
                continue;
            }

            String  requestBody  = null;
            String  responseBody = null;
            String  endpoint     = null;
            Integer statusCode   = null;

            try {
                Map<String, Object> requestBodyMap = new Map<String, Object>{
                    'pciNumber'          => caseRecord.cc_PCI_Id__c,
                    'planNumber'         => caseRecord.cc_Balance_Transfer_Card_Number__c,
                    'planSequenceNumber' => caseRecord.cc_Balance_Transfer_Reference_Number__c
                };
                requestBody = JSON.serialize(requestBodyMap);

                System.debug('Request Body --->' + requestBody);

                HttpRequest req = con.createRequest(
                    HTTP_METHOD,
                    ENDPOINT_PATH,
                    caseRecord.Customer_CIF__c,
                    caseRecord.Region_Flag__c
                );
                req.setBody(requestBody);
                req.setTimeout(120000);

                endpoint = req.getEndpoint();

                HttpResponse res = new Http().send(req);

                statusCode   = res.getStatusCode();
                responseBody = res.getBody();

                System.debug('Response --->'      + res);
                System.debug('Status Code --->'   + statusCode);
                System.debug('Response Body --->' + responseBody);

                if (statusCode == 200) {

                    Map<String, Object> responseMap =
                        (Map<String, Object>) JSON.deserializeUntyped(responseBody);

                    Boolean isSuccess = false;

                    // ---- Format A: legacy top-level "success" boolean ----
                    if (responseMap.containsKey('success') && responseMap.get('success') != null) {
                        isSuccess = (Boolean) responseMap.get('success');
                    }

                    // ---- Format B: current API -> { "meta": { "code": "CCRD-1016", ... } } ----
                    if (!isSuccess && responseMap.containsKey('meta') && responseMap.get('meta') != null) {
                        Map<String, Object> meta = (Map<String, Object>) responseMap.get('meta');
                        String code = (String) meta.get('code');
                        if (String.isNotBlank(code) && SUCCESS_CODES.contains(code)) {
                            isSuccess = true;
                        }
                    }

                    if (isSuccess) {
                        caseRecord.Last_Api_Call_Status__c = 'Success';
                        caseRecord.Sub_Status__c           = 'Cancelled';
                        caseRecord.Status                  = 'Closed';
                    } else {
                        caseRecord.Last_Api_Call_Status__c = 'Failed';
                    }

                } else {
                    caseRecord.Last_Api_Call_Status__c = 'Failed';
                }

            } catch (Exception e) {
                caseRecord.Last_Api_Call_Status__c = 'Failed';
                System.debug('Callout exception: ' + e);

                // Capture the exception as the response body so it's traceable
                if (String.isBlank(responseBody)) {
                    responseBody = 'Exception: ' + e.getMessage();
                }
            }

            // ---- Log System_Action__c with FULL request + response context ----
            String recordTypeName = (caseRecord.RecordType != null)
                                    ? caseRecord.RecordType.Name
                                    : null;

            actionsToInsert.add(CaseProcessingHandler.setSystemAction(
                requestBody,
                responseBody,
                endpoint,
                HTTP_METHOD,
                caseRecord.Id,
                caseRecord.Customer_CIF__c,
                caseRecord.AccountId,
                statusCode,
                ACTION_NAME,
                recordTypeName
            ));

            casesToUpdate.add(caseRecord);
        }

        // ---- DML ----
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }

        // Wrap in try/catch so a logging failure never rolls back the Case updates
        if (!actionsToInsert.isEmpty()) {
            try {
                insert actionsToInsert;
            } catch (Exception e) {
                System.debug('Failed to insert System_Action__c records: ' + e.getMessage());
            }
        }
    }
}
public class DeleteDeviceApiQueueable implements Queueable, Database.AllowsCallouts {
	@TestVisible
    private static ApiConnection con = new ApiConnection();
    
    private Set<Id> caseIds;

    public DeleteDeviceApiQueueable(Set<Id> caseIds) {
        this.caseIds = caseIds;
    }

    public void execute(QueueableContext context) {

        List<Case> cases = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();

        if (caseIds != null && caseIds.size() > 0) {

            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');

            String soqlQuery =
                'SELECT Id, Region_Flag__c, Case_Model__c, Hold_ID__c, ' +
    'Customer_CIF__c, AccountId, Type, Status, Last_Api_Call_Status__c, ' +
    'Account.PersonEmail, Account.CIF__pc, Account.Region_Flag__pc ' +
    'FROM Case WHERE Id IN :caseIds';

            cases = new List<Case>(
                (List<Case>) Database.query(soqlQuery)
            );
        }

        for (Case caseObj : cases) {

            try {

                String regionName = caseObj.Region_Flag__c;

                if (caseObj.Case_Model__c == 'alburaq') {
                    regionName += '_alburaq';
                }

                Http http = new Http();

                HttpRequest request =
                    con.createRequest(
                        'POST',
                        '/api/v1/devices/unpairing?',
                        regionName
                    );

                request.setHeader(
                    'customerId',
                    caseObj.Account.CIF__pc
                );

                request.setBody(
                    '{"deviceId": "' +
                    caseObj.Hold_ID__c +
                    '","reason": "REASON_DONT_USE"}'
                );

                request.setTimeout(60000);

                HttpResponse response;

                if (Test.isRunningTest()) {

                    response = new HttpResponse();

                    String body1 =
                        '{"meta":{"code":"CCRD-1500",' +
                        '"message":"Credit card request status has been updated successfully."}}';

                    response.setStatus('OK');
                    response.setStatusCode(200);
                    response.setBody(body1);
                    response.setHeader(
                        'Content-Type',
                        'application/json'
                    );

                } else {

                    response = http.send(request);
                }

                // Store response as system action
                lstSA.add(
                    SM001_ApiCalls.setSystemAction(
                        request.getBody(),
                        response.getBody(),
                        request.getEndpoint(),
                        request.getMethod(),
                        caseObj.Id,
                        caseObj.Customer_CIF__c,
                        caseObj.AccountId,
                        response.getStatusCode(),
                        'Calling PingOne Platform API - Delete MFA User Device',
                        caseObj.Type
                    )
                );

                if (response.getStatusCode() != 200) {

                    System.debug(
                        'The status code returned was not expected: ' +
                        response.getStatusCode() +
                        ' ' +
                        response.getStatus()
                    );

                    caseObj.Last_Api_Call_Status__c = 'Failed';

                } else {

                    caseObj.Status = 'Closed';
                }

            } catch (Exception e) {

                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());

                lstSA.add(
                    SM001_ApiCalls.setSystemAction(
                        null,
                        'Error Message : ' +
                        e.getMessage() +
                        '; Trace : ' +
                        String.valueOf(e.getStackTraceString()),
                        null,
                        null,
                        caseObj.Id,
                        caseObj.Customer_CIF__c,
                        caseObj.AccountId,
                        null,
                        caseObj.Type +
                        ' deleteDeviceApi (unhandled error)',
                        caseObj.Type
                    )
                );

                caseObj.Last_Api_Call_Status__c = 'Failed';
            }
        }

        if (cases != null && cases.size() > 0) {
            update cases;
        }

        if (lstSA != null && lstSA.size() > 0) {
            insert lstSA;
        }
    }
}
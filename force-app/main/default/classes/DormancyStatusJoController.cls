/**
 * auth : AITOGRAM Omar
 * @date 2026-04-16
 * @description : Invocable class to call the dormancy API and notification API asynchronously from dormancy status case update Subflow (JO)
 *                Aligned with CreditCardSendSMSReminder approach for state management  
 */
public with sharing class DormancyStatusJoController {

    private static String CLASS_NAME = DormancyStatusJoController.class.getName();
    private static ApiConnection con = new ApiConnection();
    private static List<System_Action__c> systemActions = new List<System_Action__c>();

    @InvocableMethod(label='Update Dormancy Status (Async)' description='Calls the dormancy PUT API and optionally the notification API using Case IDs' callout=true)
    public static List<Id> updateDormancyStatus(List<Id> caseIds) {
        System.debug('### DormancyStatusJoController.updateDormancyStatus called with ' + caseIds.size() + ' Case IDs');
        makeAsyncDormancyCallout(caseIds);
        return caseIds;
    }

    @future(callout=true)
    public static void makeAsyncDormancyCallout(List<Id> caseIds) {
        PAD.debugLogBegin(CLASS_NAME, 'makeAsyncDormancyCallout', 'Case IDs: ' + caseIds);
        
        List<Case> cases = new List<Case>();
        if (caseIds != null && caseIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.Subscription_Model__pc,Account.x_canary__pc FROM Case WHERE Id IN :caseIds';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }

        for (Case c : cases) {
            try {
                String customerId = String.isNotBlank(c.Customer_CIF__c) ? c.Customer_CIF__c : c.Account.CIF__pc;
                String region = String.isNotBlank(c.Region_Flag__c) ? c.Region_Flag__c : c.Account.Region_Flag__pc;
                String caseID = c.Id;
                Boolean dormancySuccess = false;

                // Dormancy API Call
                System.debug('### Calling Dormancy API for ' + customerId + ' in region ' + region);
                HttpRequest dormancyReq = con.createRequest('PUT', '/api/v1/dormancy', customerId, region);

                //Added case id to the body for now ......
                 Map<String, String> bodyMap = new Map<String, String>();
                bodyMap.put('caseId', caseId);
                String requestBody = JSON.serialize(bodyMap);
                dormancyReq.setBody(requestBody);
                System.debug('>>>> Dormancy Request Header customerId: ' + dormancyReq.getHeader('customerId'));
                System.debug('Request Body: ' + dormancyReq.getBody()); 
                // dormancyReq.setTimeout(120000);
                
                HttpResponse dormancyRes = new Http().send(dormancyReq);
                System.debug('### Dormancy API Response Code: ' + dormancyRes.getStatusCode());

                systemActions.add(SM001_ApiCalls.setSystemAction(
                    dormancyReq.getBody(), dormancyRes.getBody(), dormancyReq.getEndpoint(), 'PUT',
                    c.Id, customerId, c.AccountId, dormancyRes.getStatusCode(),
                    'Update Dormancy Status', 'Dormancy'
                ));

                if (dormancyRes.getStatusCode() == 200) {
                    dormancySuccess = true;
                    System.debug('### Dormancy API Success');
                } else {
                    System.debug('### Dormancy API Error: ' + dormancyRes.getBody());
                }
               
                c.Last_Api_Call_Status__c = dormancySuccess ? 'Success' : 'Failed';

                if (dormancySuccess) {
                    Boolean notificationSuccess = sendNotification(c, 'EMAIL_VERIFICATION', 'email', region);
                    
                    if (notificationSuccess) {
                        c.Status = 'Closed';
                        c.Sub_Status__c = 'Completed';
                        

                      
                    }
                }

            } catch (Exception e) {
                System.debug('### Error processing Case ' + c.Id + ': ' + e.getMessage());
                c.Last_Api_Call_Status__c = 'Failed';
                systemActions.add(SM001_ApiCalls.setSystemAction(
                    null, 'Error: ' + e.getMessage() + '; Trace: ' + e.getStackTraceString(),
                    null, null, c.Id, c.Customer_CIF__c, c.AccountId, null,
                    'Dormancy Async Error', 'Dormancy'
                ));
            }
        }

        if (!cases.isEmpty()) {
            System.debug('### Updating Cases: ' + cases.size());
            update cases;
        }
        if (!systemActions.isEmpty()) {
            System.debug('### Inserting System Actions: ' + systemActions.size());
            insert systemActions;
        }

        PAD.debugLogEnd(CLASS_NAME, 'makeAsyncDormancyCallout', 'Completed');
    }

    private static Boolean sendNotification(Case c, String templateCode, String notificationType, String defaultRegion) {
        Boolean isSuccess = false;
        try {
            String regionName = c.Account.Region_Flag__pc != null ? c.Account.Region_Flag__pc : defaultRegion;
            if (c.Account.Subscription_Model__pc == 'alburaq' || c.Case_Model__c == 'alburaq') {
                if (regionName != null && !regionName.endsWith('_alburaq')) regionName += '_alburaq';
            }

            System.debug('### Constructing Notification Request for region: ' + regionName);
            HttpRequest notifyReq = con.createRequest('POST', '/api/v1/notifications?', regionName);
            if (c.Account.x_canary__pc != null) {
                notifyReq.setHeader('x-canary', c.Account.x_canary__pc);
            }
            notifyReq.setHeader('userId', c.Account.PersonEmail);
            notifyReq.setHeader('customerId', c.Account.CIF__pc);
            notifyReq.setTimeout(20000);

            // Notification map 
            Map<String, Object> bodyMap = new Map<String, Object>();
            bodyMap.put('type', notificationType);
            bodyMap.put('email', c.Account.PersonEmail);
            bodyMap.put('templateCode', templateCode);
            bodyMap.put('subject', null);
            bodyMap.put('placeholderReplacements', new List<Map<String, String>>());

            String bodyJson = JSON.serialize(bodyMap);
            notifyReq.setBody(bodyJson);
            
            HttpResponse notifyRes = new Http().send(notifyReq);
            System.debug('### Notification API Response Code: ' + notifyRes.getStatusCode());

            // Create System Action for Notification
            systemActions.add(SM001_ApiCalls.setSystemAction(
                notifyReq.getBody(), notifyRes.getBody(), notifyReq.getEndpoint(), 'POST',
                c.Id, c.Account.CIF__pc, c.AccountId, notifyRes.getStatusCode(),
                'Send Dormancy Notification', 'Dormancy'
            ));

            if (notifyRes.getStatusCode() != 200) {
                System.debug('### Notification API Error: ' + notifyRes.getBody());
            } else {
                isSuccess = true;
                System.debug('### Notification API Success');
            }
        } catch (Exception e) {
            System.debug('### Error in sendNotification: ' + e.getMessage());
        }
        return isSuccess;
    }
}
/*
 *  Created By: AITOGRAM Omar
 *  Created Date: 27/04/2026
 *  Description: Invocable Apex action called from the Case Update Flow to cancel a Fawri transfer.
 *               Uses a @future method so it runs asynchronously after the Flow transaction commits.
 */
public without sharing class CancelFawriService {

   

    @AuraEnabled
    public static CancelResult callCancelSync(Id caseId) {
        System.debug('>>>> callCancelSync START – caseId: ' + caseId);
        
        Case caseObj = [
            SELECT Id, CaseNumber, AccountId,cc_Checker_Result__c,
                   Account.Customer_CIF__c, Account.Region_Flag__c,
                   New_Mobile_Number__c, cc_Transaction_Reference_Number__c,
                   Transaction_Date__c, ccol_Hold_Account_IBAN__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

        String customerId = caseObj.Account.Customer_CIF__c;
        String regionName = caseObj.Account.Region_Flag__c;

        if (String.isBlank(caseObj.New_Mobile_Number__c)) {
            return new CancelResult(false, 'MISSING_BATCH_ID', 'Batch ID is missing from the Case record. The transaction cannot be cancelled.');
        }
        if (String.isBlank(caseObj.cc_Transaction_Reference_Number__c)) {
            return new CancelResult(false, 'MISSING_REF_NUMBER', 'Transaction Reference Number is missing – aborting cancellation.');
        }

        Map<String, Object> bodyMap = new Map<String, Object>{
            'transactionId'     => caseObj.cc_Transaction_Reference_Number__c,
            'batchId'           => caseObj.New_Mobile_Number__c,
            'crmCaseId'         => caseObj.Id,
            'reasonCode'        => 'CANC',
            'reasonDescription' => 'Cancellation Request',
            'valueDate'         => caseObj.Transaction_Date__c != null
                                        ? String.valueOf(caseObj.Transaction_Date__c)
                                        : null,
            'senderAgentBic'    => caseObj.ccol_Hold_Account_IBAN__c
        };
        String body = JSON.serialize(bodyMap);

        ApiConnection con = new ApiConnection();
        final String path = '/api/v1/tmsxcontrol/transaction/cancel';
        HttpRequest req = con.createRequest('PUT', path, customerId, regionName);
        req.setTimeout(60000);
        req.setBody(body);

        System.debug('>>>> Request Endpoint: ' + req.getEndpoint());
        System.debug('>>>> Request Body: '     + body);

        HttpResponse res = new Http().send(req);

       
        String metaCode = '';
        String message  = '';
        try {
            if (String.isNotBlank(res.getBody())) {
                Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                if (resMap != null) {
                    if (resMap.containsKey('meta')) {
                        Map<String, Object> metaMap = (Map<String, Object>) resMap.get('meta');
                        if (metaMap != null) {
                            metaCode = metaMap.get('code')    != null ? String.valueOf(metaMap.get('code'))    : '';
                            message  = metaMap.get('message') != null ? String.valueOf(metaMap.get('message')) : '';
                              System.debug('>>>> Fawri1 >>>> :  ' + metaCode);
                                System.debug('>>>> Fawri2 >>>> : ' + message);
                        }
                    } else if (resMap.containsKey('message')) {
                        message = String.valueOf(resMap.get('message'));
                    }
                }
            }
        } catch (Exception ex) {
            System.debug('>>>> Error parsing response body: ' + ex.getMessage());
            message = res.getBody();
        }

        if (String.isBlank(message)) {
            message = res.getStatus();
        }

  
        final Set<String> FAWRI_FAILURE_CODES = new Set<String>{
            'TMSC-1003'
            
        };
         final Set<String> FAWRI_FAILURE_BODY = new Set<String>{
            'Could not submit cancelation request'
            
        };
        Boolean isHttpSuccess   = (res.getStatusCode() == 200);
        Boolean isMetaFailure   = String.isNotBlank(metaCode) && FAWRI_FAILURE_CODES.contains(metaCode) &&  FAWRI_FAILURE_BODY.contains(message) ;
        Boolean isSuccess       = isHttpSuccess && !isMetaFailure;

        System.debug('>>>> Response StatusCode : ' + res.getStatusCode());
        System.debug('>>>> Response Body       : ' + res.getBody());
        System.debug('>>>> metaCode            : ' + metaCode);
        System.debug('>>>> isHttpSuccess       : ' + isHttpSuccess);
        System.debug('>>>> isMetaFailure       : ' + isMetaFailure);
        System.debug('>>>> isSuccess (final)   : ' + isSuccess);

    
        System_Action__c action = SM001_ApiCalls.setSystemAction(
            req.getBody(), res.getBody(), req.getEndpoint(), 'PUT',
            caseId, customerId, caseObj.AccountId, res.getStatusCode(),
            'Cancel Fawri Transaction', 'Fawri'
        );
        insert action;
        System.debug('>>>> Response action : ' + action.Id);

        // caseObj.Last_Api_Call_Status__c = isSuccess ? 'Success' : 'Failed';
        // if(isSuccess){
        //     caseObj.cc_Checker_Result__c = 'approve';
        // }
        // update caseObj;
        // System.debug('>>>> Response caseObj : ' +  caseObj.Last_Api_Call_Status__c +  ' ... ' + caseObj.cc_Checker_Result__c);
        CaseAnnex__c caseAnnex = [
            SELECT Id, Fawri_Cancel_Api_Count__c
            FROM CaseAnnex__c
            WHERE Case__c = :caseId
            LIMIT 1
        ];
        if (caseAnnex.Fawri_Cancel_Api_Count__c == null) {
            caseAnnex.Fawri_Cancel_Api_Count__c = 0;
        }
        caseAnnex.Fawri_Cancel_Api_Count__c += 1;
        update caseAnnex;

        return new CancelResult(isSuccess, metaCode, message);
    }

    public class CancelResult {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String metaCode;
        @AuraEnabled public String message;

        public CancelResult(Boolean isSuccess, String metaCode, String message) {
            this.isSuccess = isSuccess;
            this.metaCode = metaCode;
            this.message = message;
        }
    }
}
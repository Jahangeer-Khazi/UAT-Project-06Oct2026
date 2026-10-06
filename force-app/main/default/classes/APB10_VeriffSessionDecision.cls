/**
 * @description       :
 *                      
 * @author            : ANISS MBARKI
 * @creation date     : 08-07-2023
 * History Changes :  
**/
global without sharing class APB10_VeriffSessionDecision implements Database.Batchable<sObject>,Database.AllowsCallouts {

    private static String BASE_URL = SYSTEM.LABEL.Veriff_BASE_URL ; //'https://stationapi.veriff.com';
    private static String PRIVATE_KEY = SYSTEM.LABEL.Veriff_PRIVATE_KEY; //'e687928a-5a79-4ce8-a12c-c86a379db149'; 
    private static String PUBLIC_KEY = SYSTEM.LABEL.Veriff_PUBLIC_KEY; //'97b12020-dc04-46da-8d90-9f3dcd887fb3';

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id,GetSessionDecision__c,SessionId__c,Customer__r.CIF__pc,Customer__r.PersonEmail,Customer__c '+
                                        'FROM Document_Reconciliation_Result__c WHERE GetSessionDecision__c = false ' );
    }

    global void execute(Database.BatchableContext bc, List<Document_Reconciliation_Result__c> docRescList) {
        System.debug('execute**********************');

        List<System_Action__c> lstSA = new List<System_Action__c>();

        for( Document_Reconciliation_Result__c docRescObj : docRescList ){
            
            //call Session Decision API
            HttpRequest request = new HttpRequest();
            request.setEndpoint(BASE_URL + '/v1/sessions/'+docRescObj.SessionId__c+'/decision' );
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            //request.setBody('{}');

            String algorithmName = 'HmacSHA256';
            Blob hmacData = Crypto.generateMac( algorithmName, Blob.valueOf(docRescObj.SessionId__c), Blob.valueOf(PRIVATE_KEY) );
            String signature = EncodingUtil.convertToHex(hmacData);
            request.setHeader('X-HMAC-SIGNATURE',signature);
            request.setHeader('X-AUTH-CLIENT', PUBLIC_KEY);
            HttpResponse response;
            if( test.isRunningTest() ){
                //fake response 
                response = new HttpResponse();
                String body = '{"status":"success","verification":{"id":"1fa27422-b60a-4e18-9edf-ff577894b5fe","code":9103,"person":{"gender":null,"idNumber":null,"lastName":null,"addresses":[],"firstName":null,"citizenship":null,"dateOfBirth":null,"nationality":null,"yearOfBirth":null,"placeOfBirth":null,"pepSanctionMatch":null},"reason":"Face image missing","status":"resubmission_requested","comments":[],"document":{"type":null,"number":null,"country":null,"validFrom":null,"validUntil":null},"reasonCode":605,"riskLabels":[],"vendorData":";null","decisionTime":"2023-07-18T11:25:16.412797Z","acceptanceTime":"2023-07-18T10:16:45.455006Z","additionalVerifiedData":{}},"technicalData":{"ip":null}}';
                response.setStatus('OK');    
                response.setStatusCode(200);
                response.setBody(body);
                response.setHeader('Content-Type', 'application/json'); 
            }
            else{
                response = new Http().send(request);
            }

            String bodyReq = request.getBody();
            if(request.getBody() != null && request.getBody().length() >= 131000){ bodyReq = request.getBody().substring(0,131000); }

            String bodyResp = response.getBody();
            if(response.getBody() != null && response.getBody().length() >= 131000){ bodyResp = response.getBody().substring(0,131000); }
            
            if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                lstSA.add(SM001_ApiCalls.setSystemAction(bodyReq,bodyResp,
                                                    request.getEndpoint(),request.getMethod(),
                                                    null,docRescObj.Customer__r.CIF__pc,docRescObj.Customer__c,response.getStatusCode(),
                                                    'Veriff Session Decision API -- error from the batch', 'Veriff API'));
            }else {
                System.debug('Response Api from Session Decision API : '+response.getBody());
                
                Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                Map<String, Object> resVerifMap = (Map<String, Object>)resMap.get('verification');

                docRescObj.GetSessionDecisionHttpResponse__c = response.getBody();
                docRescObj.GetSessionDecision__c = true;
                docRescObj.Veriff_ID_Verification_Status__c = (String) resVerifMap.get('status');
                docRescObj.Veriff_ID_Reject_Reason__c	 = String.valueOf(resVerifMap.get('reasonCode'));
                docRescObj.Veriff_ID_Reject_Reason_Details__c = (String) resVerifMap.get('reason');
                //docRescObj.Veriff_ID_Similarity__c = (String) resVerifMap.get('');//??
            }
        }

        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }

        if(docRescList != null && docRescList.size()>0){
            update docRescList;
        }
        

    }

    global void finish(Database.BatchableContext bc) {
        System.debug('APB10_VeriffSessionDecision finished !');
    }
}
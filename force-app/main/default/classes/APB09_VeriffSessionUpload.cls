/**
 * @description       : 
 *                      
 * @author            : ANISS MBARKI
 * @creation date     : 08-07-2023
 * History Changes :  
**/
global without sharing class APB09_VeriffSessionUpload implements Database.Batchable<sObject>,Database.AllowsCallouts {
    
    private static String BASE_URL = SYSTEM.LABEL.Veriff_BASE_URL ; //'https://stationapi.veriff.com';
    private static String PRIVATE_KEY = SYSTEM.LABEL.Veriff_PRIVATE_KEY; //'e687928a-5a79-4ce8-a12c-c86a379db149'; 
    private static String PUBLIC_KEY = SYSTEM.LABEL.Veriff_PUBLIC_KEY; //'97b12020-dc04-46da-8d90-9f3dcd887fb3';

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id,PersonContactId,CIF__pc,PersonEmail,ReconciliationStatus__pc,'+
                                            '(SELECT Id,Image_Type__c,Attachment_Base_64_Coding__c FROM Content__r WHERE Document_Type__c = \'Bahraini ID\' '+
                                                'AND Image_Type__c IN (\'Front\',\'Back\',\'Face\') ) '+//check Selfie??
                                        'FROM Account WHERE Region_Flag__pc = \'Bahrain\' AND ReconciliationStatus__pc = \'Initial\' LIMIT 1 ' );
    }

    global void execute(Database.BatchableContext bc, List<Account> accList) {
        System.debug('execute**********************');

        List<Document_Reconciliation_Result__c> docRecResults = new List<Document_Reconciliation_Result__c>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Map<Id,String> base64DataBasedOnContentId = new Map<Id,String>();
        ApiConnection con = new ApiConnection();

        Set<ID> parentIds = new Set<ID>();
        for(Account objAcc : accList){
            System.debug('record account : ********** ' + objAcc.Id);
            if(objAcc.Content__r != null && objAcc.Content__r.size()>0 ){
                for( Content__c cont : objAcc.Content__r ){
                    parentIds.add(cont.Id);
                }
            }
        }
        
        List<Content__c> lstContent = [SELECT Id, (SELECT Id,ContentDocument.LatestPublishedVersion.VersionData,ContentDocument.FileExtension
                                      FROM ContentDocumentLinks) FROM Content__c WHERE Id IN :parentIds];

        for ( Content__c objCon : lstContent){
            for(ContentDocumentLink objCDL : objCon.ContentDocumentLinks){
                String base64Data = EncodingUtil.base64Encode(objCDL.ContentDocument.LatestPublishedVersion.VersionData);
                String extentionFile = objCDL.ContentDocument.FileExtension;
                if(extentionFile.equalsIgnoreCase('pdf')){
                    base64Data = 'data:application/pdf;base64,'+ base64Data;
                }else{
                    base64Data = 'data:image/'+extentionFile+';base64,'+ base64Data;
                }
                base64DataBasedOnContentId.put(objCon.Id,base64Data);
            }
        }

        for(Account objAcc : accList){
            
            //call Create Session API
            HttpRequest request = con.createRequest('POST','/api/v1/veriff-client/sessions',null);
            request.setBody('{}');//Body should be blank (confirmed with Ashish)
            request.setHeader( 'customerId',objAcc.CIF__pc );
            request.setHeader( 'userId',objAcc.PersonEmail);

            HttpResponse response;
            if( test.isRunningTest() ){
                //fake response 
                response = new HttpResponse();
                String body = '{"meta":{"code":"VRFF-001","message":"Session processed successfully"},"data":{"sessionId":"3f5a58f7-7a44-4a76-808c-35d99d6992ea","sessionUrl":"https://magic.veriff.me/v/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2ODk2ODI5NTMsInNlc3Npb25faWQiOiIzZjVhNThmNy03YTQ0LTRhNzYtODA4Yy0zNWQ5OWQ2OTkyZWEiLCJpaWQiOiJiYjk5OTRhMS02MGU4LTQwMWMtOGVkNi1jMjM1MWYyMGIyMjgifQ.20Aarh950UZ4_-svt3FLqsggbqwHpruwoGd2xtbG95U"}}';
                response.setStatus('OK');    
                response.setStatusCode(200);
                response.setBody(body);
                response.setHeader('Content-Type', 'application/json'); 
            }
            else{
                response = new Http().send(request);
            }

            if (response.getStatusCode() != 200) {
                objAcc.ReconciliationStatus__pc = 'Error';
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                lstSA.add(SM001_ApiCalls.setSystemAction(request.getBody(),response.getBody(),
                                                    request.getEndpoint(),request.getMethod(),
                                                    null,objAcc.CIF__pc,objAcc.Id,response.getStatusCode(),
                                                    'Veriff Create Session API -- error from the batch', 'Veriff API'));
            }else {
                System.debug('Response Api from Create Session API : '+response.getBody());
                
                //after calling first api successfully we need to create a new record on Document_Reconciliation_Result__c to store sessionId
                Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                Map<String, Object> resDataMap = (Map<String, Object>)resMap.get('data');

                Document_Reconciliation_Result__c docRecon = new Document_Reconciliation_Result__c();
                docRecon.Customer__c = objAcc.Id;
                docRecon.SessionId__c = (String) resDataMap.get('sessionId');
                docRecResults.add(docRecon);


                //call API 2- (iteration) --> UPLOAD IMAGE DOCUMENT BASED ON CONTEXT 
                //qst : should be exactly 3 docs in all customers??
                //the response of the 3 expected api call of uploading documents what todo?? restore responses??
                if(objAcc.Content__r != null && objAcc.Content__r.size()>0 ){
                    for( Content__c cont : objAcc.Content__r ){

                        //toDO use diffrent function to call this api ...
                        HttpRequest request2 = new HttpRequest();
                        request2.setEndpoint(BASE_URL + '/v1/sessions/'+docRecon.SessionId__c+'/media' );
                        request2.setMethod('POST');
                        request2.setHeader('Content-Type', 'application/json');


                        String identifier;
                        if(cont.Image_Type__c == 'Front'){
                            identifier = 'document-front';
                        }else if(cont.Image_Type__c == 'Back'){
                            identifier = 'document-back';
                        }else if(cont.Image_Type__c == 'Face'){
                            identifier = 'face';
                        }

                        String base64 = base64DataBasedOnContentId.get(cont.Id) ;
                        request2.setBody('{"image": {"context": "'+identifier+'","content": "'+base64+'"}}');

                        String algorithmName = 'HmacSHA256';
                        Blob hmacData = Crypto.generateMac( algorithmName, Blob.valueOf(request2.getBody()), Blob.valueOf(PRIVATE_KEY) );
                        String signature = EncodingUtil.convertToHex(hmacData);
                        request2.setHeader( 'X-HMAC-SIGNATURE',signature);
                        request2.setHeader('X-AUTH-CLIENT', PUBLIC_KEY);

                        HttpResponse response2;
                        if( test.isRunningTest() ){
                            //fake response 
                            response2 = new HttpResponse();
                            response2.setStatus('OK');    
                            response2.setStatusCode(200);
                            response2.setHeader('Content-Type', 'application/json'); 
                        }
                        else{
                            response2 = new Http().send(request2);
                        }
                        //toDo : end
                        
                        String bodyReq2 = request2.getBody();
                        if(request2.getBody() != null && request2.getBody().length() >= 131000 ){ bodyReq2 = request2.getBody().substring(0,131000); }

                        String bodyResp2 = response2.getBody();
                        if(response2.getBody() != null && response2.getBody().length() >= 131000 ){ bodyResp2 = response2.getBody().substring(0,131000); }

                        if (response2.getStatusCode() != 200) {
                            objAcc.ReconciliationStatus__pc = 'Error';
                            System.debug('The status code returned was not expected: ' + response2.getStatusCode() + ' ' + response2.getStatus());
                            lstSA.add(SM001_ApiCalls.setSystemAction(bodyReq2,bodyResp2,
                                                                request2.getEndpoint(),request2.getMethod(),
                                                                null,objAcc.CIF__pc,objAcc.Id,response2.getStatusCode(),
                                                                'Veriff UPLOAD IMAGE DOCUMENT API -- error from the batch', 'Veriff API'));
                        }else {
                            System.debug('Response Api from UPLOAD IMAGE DOCUMENT API : '+response2.getBody());
                        }
                    }
                }

                //call API 3- "SUBMIT SESSION"
                //store response ?? where??
                
                //toDo : use diffrent function
                HttpRequest request3 = new HttpRequest();
                request3.setEndpoint(BASE_URL + '/v1/sessions/'+docRecon.SessionId__c );
                request3.setMethod('PATCH');
                request3.setHeader('Content-Type', 'application/json');

                request3.setBody('{"verification": {"status": "submitted"}}');
                
                String algorithmName = 'HmacSHA256';
                Blob hmacData = Crypto.generateMac( algorithmName, Blob.valueOf(request3.getBody()), Blob.valueOf(PRIVATE_KEY) );
                String signature = EncodingUtil.convertToHex(hmacData);
                request3.setHeader('X-HMAC-SIGNATURE',signature);
                request3.setHeader('X-AUTH-CLIENT', PUBLIC_KEY);

                HttpResponse response3;
                if( test.isRunningTest() ){
                    //fake response 
                    response3 = new HttpResponse();
                    response3.setStatus('OK');    
                    response3.setStatusCode(200);
                    response3.setHeader('Content-Type', 'application/json'); 
                }
                else{
                    response3 = new Http().send(request3);
                }
                //toDo : end
                
                String bodyReq3 = request3.getBody();
                if(request3.getBody() != null && request3.getBody().length() >= 131000){ bodyReq3 = request3.getBody().substring(0,131000); }

                String bodyResp3 = response3.getBody();
                if(response3.getBody() != null && response3.getBody().length() >= 131000){ bodyResp3 = response3.getBody().substring(0,131000); }

                if (response3.getStatusCode() != 200) {
                    objAcc.ReconciliationStatus__pc = 'Error';
                    System.debug('The status code returned was not expected: ' + response3.getStatusCode() + ' ' + response3.getStatus());
                    lstSA.add(SM001_ApiCalls.setSystemAction(bodyReq3,bodyResp3,
                                                        request3.getEndpoint(),request3.getMethod(),
                                                        null,objAcc.CIF__pc,objAcc.Id,response3.getStatusCode(),
                                                        'Veriff SUBMIT SESSION API -- error from the batch', 'Veriff API'));
                }else {
                    System.debug('Response Api from SUBMIT SESSION API : '+response3.getBody());
                }

            }

            if(objAcc.ReconciliationStatus__pc == 'Initial' ){ //if still equal 'Initial' it means there is no error 
                objAcc.ReconciliationStatus__pc = 'Completed';
            }
        }

        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }
        if(docRecResults != null && docRecResults.size()>0){
            insert docRecResults;
        }
        if(accList != null && accList.size()>0){
            update accList;
        }

    }

    global void finish(Database.BatchableContext bc) {
        System.debug('APB09_VeriffSessionUpload finished !');
         Long endT = System.Now().getTime()+60000;
        While(System.Now().getTime() < endT){
        }
        system.debug(System.Now());
        List<Account>RerunBatch=New List<Account>();
        RerunBatch= [Select id,ReconciliationStatus__pc  from Account WHERE Region_Flag__pc ='Bahrain' AND ReconciliationStatus__pc = 'Initial'];
        if(!RerunBatch.isEmpty() && System.Label.PeriodicReviewBatchManualStop=='False'){
            APB09_VeriffSessionUpload PRB = New APB09_VeriffSessionUpload();
            database.executeBatch(PRB,1);
        }
        System.debug('!!!!!!!!,!!!!!!! Periodic Review Batch finished !!!!!!!!!!!!!!!!!');
    }
}
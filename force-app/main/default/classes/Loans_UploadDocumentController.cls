/**
 * @description       : 
 * @author            : Elmustapha ELGARNI
 * @group             : 
 * @last modified on  : 07-10-2024
 * @last modified by  : Elmustapha ELGARNI
**/
public with sharing class Loans_UploadDocumentController {

    public static Integer statusCode = 200;   
    private static ApiConnection con = new ApiConnection();

    @AuraEnabled
    public static ApiConnection.Response uploadDocument(String caseId, String documentType, String fileName, String fileContent) {
        
        system.debug('lwc fileName' + fileName);
        system.debug('lwc fileContent' + fileContent.substring(0, 50));

        Case caseObj = [SELECT Id, Region_Flag__c, Case_Model__c, Loan_Application_ID__c, accountId,Account.CIF__pc, Customer_CIF__c, Type, cc_PCI_Id__c, Card_Product_Configuration_Id__c  FROM Case WHERE Id =:caseId];

        String regionName = caseObj.Region_Flag__c;
        if(caseObj.Case_Model__c == 'alburaq'){
            regionName += '_alburaq'; 
        }

        final HttpRequest request = con.createRequest('POST', '/api/v1/loans/documents/dms',regionName);
        request.setHeader('customerId', caseObj.Account.CIF__pc);
        request.setTimeout(60000);
        
        // String body = '{ "fileContent" : "' + fileContent + '", "fileName": "' + fileName + '", "documentType": "' + documentType + '", "applicationId": "' + caseObj.Loan_Application_ID__c + '", "loanProductConfigurationId": "' + caseObj.Card_Product_Configuration_Id__c + '", "appFulfilmentId": "' + caseObj.cc_PCI_Id__c + '"}'

        String appFulfilmentId = caseObj.cc_PCI_Id__c;
        String loanProductConfigurationId = caseObj.Card_Product_Configuration_Id__c;
        String applicationId = caseObj.Loan_Application_ID__c;
        String body = '{ "fileContent" : "' + fileContent + 
                        '", "fileName": "' + fileName + 
                        '", "documentType": "' + documentType + 
                        '", "applicationId": ' + (applicationId != null ? ('"' + applicationId + '"') : null )+
                        ', "loanProductConfigurationId": ' + (loanProductConfigurationId != null ? ('"' + loanProductConfigurationId + '"') : null ) +
                        ', "appFulfilmentId": ' + (appFulfilmentId != null ? ('"' + appFulfilmentId + '"') : null ) +
                        '}';
        request.setBody(body);

        System.debug('Request Endpoint: ' +request.getEndpoint());
        System.debug('Request Method: ' +request.getMethod());
        body = '{ "fileContent" : "' + fileContent.substring(0, 50) + 
                        '", "fileName": "' + fileName + 
                        '", "documentType": "' + documentType + 
                        '", "applicationId": ' + (applicationId != null ? ('"' + applicationId + '"') : null )+
                        ', "loanProductConfigurationId": ' + (loanProductConfigurationId != null ? ('"' + loanProductConfigurationId + '"') : null ) +
                        ', "appFulfilmentId": ' + (appFulfilmentId != null ? ('"' + appFulfilmentId + '"') : null ) +
                        '}';
        System.debug('Request Body:'+ '{ "fileContent" : "' + fileContent.substring(0, 50) + '", "fileName": "' + fileName + '", "documentType": "' + documentType + '", "applicationId": "' + caseObj.Loan_Application_ID__c + '", "loanProductConfigurationId": "' + caseObj.Card_Product_Configuration_Id__c + '", "appFulfilmentId": "' + caseObj.cc_PCI_Id__c + '"}');
        system.debug('Request Body 2 ": '+ body);
        HttpResponse res = new HttpResponse();
        if(!Test.isRunningTest()){
            res = new Http().send(request);
            system.debug('ressponse body: '+ res.getBody());
        } else{
            String responseBody = '{"meta": {"code": "LOAN-1008","message": "Documents has been uploaded successfully to dms."}}';
            res.setStatus('OK');
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            res.setHeader('Content-Type', 'application/json');
        }


        ApiConnection.Response response = new ApiConnection.Response();
        ///////////////////
        if (200 == res.getStatusCode()) {
            response.isSuccess = true;
            if (String.isNotBlank(res.getBody())) {
                final Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                response.responseData = resMap.get('data');
            }
            
        } else {
            response.isSuccess = false;
            try {
                final Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                response.errorData = resMap.containsKey('meta')? resMap.get('meta') : resMap;
            } catch (Exception e) {
                response.errorData = res.getBody();
            }
            System.debug('response.errorData=' + response.errorData);
        }
        //////////////

        //////////////////// Log system action
        List<System_Action__c> lstSA = new List<System_Action__c>();
        if(res.getStatusCode() != 200 ){
            // body = '{ "fileContent" : "' + fileContent.substring(0, 40) + '", "fileName": "' + fileName + '", "documentType": "' + documentType + '", "applicationId": "' + caseObj.Loan_Application_ID__c + '"}';
            body = '{ "fileContent" : "' + fileContent.substring(0, 50) + 
                        '", "fileName": "' + fileName + 
                        '", "documentType": "' + documentType + 
                        '", "applicationId": ' + (applicationId != null ? ('"' + applicationId + '"') : null )+
                        ', "loanProductConfigurationId": ' + (loanProductConfigurationId != null ? ('"' + loanProductConfigurationId + '"') : null ) +
                        ', "appFulfilmentId": ' + (appFulfilmentId != null ? ('"' + appFulfilmentId + '"') : null ) +
                        '}';
            lstSA.add(SM001_ApiCalls.setSystemAction(body,res.getBody(),
                                                     request.getEndpoint(),request.getMethod(),
                                                     caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,res.getStatusCode(), 
                                                     'Upload file to Infinity DMS Request Status API', caseObj.Type
                                                    ));
        }
        if(lstSA.size() > 0){
            insert lstSA;
        }
        ///////
        return response;
    }


    @AuraEnabled
    public static ApiConnection.Response confirmAllDocumentUploaded(String caseId) {
        
        Case caseObj = [SELECT Id, Region_Flag__c, Case_Model__c, Loan_Application_ID__c, Card_Product_Configuration_Id__c,cc_PCI_Id__c, accountId, Account.CIF__pc, Customer_CIF__c, Type  FROM Case WHERE Id =:caseId];

        String regionName = caseObj.Region_Flag__c;
        if(caseObj.Case_Model__c == 'alburaq'){
            regionName += '_alburaq'; 
        }

        final HttpRequest request = con.createRequest('POST', '/api/v1/loans/submit/infinity',regionName);
        request.setHeader('customerId', caseObj.Account.CIF__pc);
        
        // String body = '{"applicationId": "' + caseObj.Loan_Application_ID__c + '"}';
        String body = '{"applicationId": "' + caseObj.Loan_Application_ID__c + '","customerId": "' + caseObj.Customer_CIF__c + '","loanProductConfigurationId": "' + caseObj.Card_Product_Configuration_Id__c + '","appFulfilmentId": "' + caseObj.cc_PCI_Id__c + '","isDocumentsUploaded": true}';
        request.setBody(body);
        request.setTimeout(60000);

        System.debug('Request Endpoint: ' +request.getEndpoint());
        System.debug('Request Method: ' +request.getMethod());
        System.debug('Request Body:'+request.getBody());

        HttpResponse res = new HttpResponse();
        if(!Test.isRunningTest()){
            res = new Http().send(request);
            system.debug('ressponse body: '+ res.getBody());
        } else{
            String responseBody = '{"meta": {"code": "LOAN-1008","message": "Documents has been submitted successfully to infinity."}}';
            res.setStatus('OK');
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            res.setHeader('Content-Type', 'application/json');
        }


        ApiConnection.Response response = new ApiConnection.Response();
        ///////////////////
        if (200 == res.getStatusCode()) {
            response.isSuccess = true;
            if (String.isNotBlank(res.getBody())) {
                final Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                response.responseData = resMap.get('data');
            }
            
        } else {
            response.isSuccess = false;
            try {
                final Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                response.errorData = resMap.containsKey('meta')? resMap.get('meta') : resMap;
            } catch (Exception e) {
                response.errorData = res.getBody();
            }
            System.debug('response.errorData=' + response.errorData);
        }
        //////////////

        //////////////////// Log system action
        List<System_Action__c> lstSA = new List<System_Action__c>();
        if(res.getStatusCode() != 200 ){

            lstSA.add(SM001_ApiCalls.setSystemAction(request.getBody(),res.getBody(),
                                                     request.getEndpoint(),request.getMethod(),
                                                     caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,res.getStatusCode(), 
                                                     'Confirm All Documents Uploaded to Infinity DMS Request Status API', caseObj.Type
                                                    ));
        }
        if(lstSA.size() > 0){
            insert lstSA;
        }

        ///////

        return response;
        
            
    }

    @future(callout=true)
    public static void uploadDocumentFutureMethod(String caseId, String documentType, String fileName, String fileContent){
        
        uploadDocument(caseId, documentType, fileName, fileContent);
    }

}
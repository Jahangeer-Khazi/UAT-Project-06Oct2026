/*
Author :
Date :
Description : This is a global class to handle all Lead triggers
    #CH01# Added #09-11-2021# defaults to Bahrain if the region name is blank - YZ
    #CH02# Added #23-12-2021# adding a new Named Credential for JO - YZ
    #CH03# Added #30-05-2022# Hamza Chaoui -- filtring using MasterLabel instead of Region__c if it's related to alburaq product
*/

    public without sharing virtual class ApiConnection {
    private static String URL_Appendix;
    private static String API_Key;
    private static String API_Endpoint;

    /*public ApiConnection(String regionName){

    }*/
    /**
     * @param: method - POST | PUT
     * @param: path - must start with slash, e.g. /api/v1/cards
     */
    public virtual HttpRequest createRequest(final String method, final String path, String regionName) {
        if (String.isBlank(regionName)) { // #CH01#
            regionName = 'Bahrain';
        }
        setAPIKeyAndURL_Appendix(regionName);
        final HttpRequest req = new HttpRequest();
        String fullPath = String.isNotBlank(path) ? path : '';
        if (fullPath.contains('?')) {
            fullPath += '&' + ApiConnection.URL_Appendix;
        } else {
            fullPath += '?' + ApiConnection.URL_Appendix;
        }
        
        System.debug('fullPath --->'+fullPath);
        req.setEndpoint('callout:' + API_Endpoint + fullPath);
        req.setMethod(method);
        req.setHeader('x-apikey', API_Key);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('source', 'crm');
        req.setHeader('userId', '');
        return req;
    }

    private void setAPIKeyAndURL_Appendix(String regionName) {
        System.debug('current Region' +regionName);
        
        //#CH03 start#
        Boolean isAlburaqProduct = false;
        if(regionName != null && regionName.endsWithIgnoreCase('_alburaq')){
            regionName = regionName.remove('_alburaq');
            isAlburaqProduct = true;
        }

        Region__mdt currentRegion = [SELECT Id, API_Endpoint__c, API_Key__c, API_variable__c,Alburaq_API_variable__c FROM Region__mdt WHERE Region__c =: regionName LIMIT 1];
        String unitParam = '';

        if(isAlburaqProduct == true){
            unitParam = currentRegion.Alburaq_API_variable__c;
        }else{
            unitParam = currentRegion.API_variable__c;
        }   

        URL_Appendix = 'language=en&unit=' + unitParam;//#CH03#
        API_Key = currentRegion.API_Key__c;
        API_Endpoint = currentRegion.API_Endpoint__c; // #CH02#
        //#CH03 end#
    }

    public virtual HttpRequest createRequest(final String method, final String path, final String customerId, String regionName) {
        if (String.isBlank(regionName)) { // #CH01#
            regionName = 'Bahrain';
        }
        HttpRequest req = createRequest(method, path, regionName);
        req.setHeader('customerId', customerId);
        System.debug('End##3'+req.getEndpoint());
        System.debug('Content-Type##3'+req.getHeader('Content-Type'));
        System.debug('req###'+req.getHeader('customerId'));
        System.debug('req###'+req.getHeader('x-apikey'));
        //revert
      //  req.setHeader('x-canary', 'aurora');
        return req;
    }

    public virtual HttpRequest createRequest(final String method, final String path, final String customerId, String email, String regionName) {
        if (String.isBlank(regionName)) { // #CH01#
            regionName = 'Bahrain';
        }
        HttpRequest req = createRequest(method, path, customerId, regionName);
        req.setHeader('userId', email);
        return req;
    }

    /**
     * use this method when no System_Action__c log record is required
     * e.g. when querying data from API
     */
    public ApiConnection.Response makeCallout(final HttpRequest req) {
        return makeCallout(req, null);
    }

    /**
     * use this method when System_Action__c log record IS required
     * e.g. when updating data via API
     */
    public ApiConnection.Response makeCallout(final HttpRequest req, final System_Action__c action) {
        final Http http = new Http();
        final HTTPResponse res = http.send(req);
        System.debug('Request Body in API Connection:'+req.getBody());
        System.debug('Response Body in API Connection:'+res.getBody());
        System.debug('responseAPiConnection##'+res);
        return processCalloutResponse(res, action);

    }

    protected virtual ApiConnection.Response processCalloutResponse(final HTTPResponse res, final System_Action__c action) {
        final Response response = new Response();
        try {
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
        } finally {
            if (null != action) {
                SystemActionLogger.logResponse(res, action);
            }
        }
        return response;
    }
    
    public class Response {
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public Object responseData;
        @AuraEnabled
        public Object errorData;
        @AuraEnabled
        public Integer recordLength;
    }
}
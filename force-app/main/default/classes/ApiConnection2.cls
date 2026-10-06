public without sharing virtual class ApiConnection2 {
    private static String URL_Appendix = 'language=en&unit=neo';

    /**
     * @param: method - POST | PUT
     * @param: path - must start with slash, e.g. /api/v1/cards
     */
    protected virtual HttpRequest createRequest(final String method, final String path) {
        final HttpRequest req = new HttpRequest();
        String fullPath = String.isNotBlank(path) ? path : '';
        if (fullPath.contains('?')) {
            fullPath += '&' + ApiConnection2.URL_Appendix;
        } else {
            fullPath += '?' + ApiConnection2.URL_Appendix;
        }
        req.setEndpoint('callout:NeoBank_Endpoint' + fullPath);
        req.setMethod(method);
        req.setHeader('x-apikey', '3vT7MGyz1gMfybyTyYv08wUg4RzHG6Ih');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('source', 'crm');
        req.setHeader('userId', '');
        return req;
        
    }
    public virtual HttpRequest createRequest(final String method, final String path, final String customerId) { 
        HttpRequest req = createRequest(method, path);
        req.setHeader('customerId', customerId);
        System.debug(req.toString());
        return req;
    }
    
    public virtual HttpRequest createRequest(final String method, final String path, final String customerId, String email) { 
        HttpRequest req = createRequest(method, path, customerId);
        req.setHeader('userId', email);
        return req;
    }
    
    /**
     * use this method when no System_Action__c log record is required
     * e.g. when querying data from API
     */
    public ApiConnection2.Response makeCallout(final HttpRequest req) {
        return makeCallout(req, null);
    }
    
    /**
     * use this method when System_Action__c log record IS required
     * e.g. when updating data via API
     */
    public ApiConnection2.Response makeCallout(final HttpRequest req, final System_Action__c action) {
        final Http http = new Http();
        final HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        return processCalloutResponse(res, action);

    }
    
    protected virtual ApiConnection2.Response processCalloutResponse(final HTTPResponse res, final System_Action__c action) {
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
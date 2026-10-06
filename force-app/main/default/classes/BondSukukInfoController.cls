public with sharing virtual class BondSukukInfoController {
    private static ApiConnection con = new ApiConnection();
    public static String regionName;
       @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadBondList(final String customerId, String regionName) {
        final String path = '/api/v1/bond/investments';
        final HttpRequest req = con.createRequest('GET', path, regionName);
        //#CH08 : start
        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
           if(accs!= null && accs.size()>0){
           System.debug('x-canary added :'+accs.get(0).x_canary__pc);
             if(accs.get(0).x_canary__pc != null){
               req.setHeader('x-canary', accs.get(0).x_canary__pc);
                 }
           }
        //#CH08 : end
        req.setHeader('customerId',customerId);
		//req.setTimeout(120000);
        final ApiConnection.Response response = con.makeCallout(req);
        System.debug('loadAccountList ||'+JSON.serializePretty(response));
        if (response.isSuccess && null != response.responseData) {
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            final Object[] bonds = (Object[])responseData.get('investments');
        }
        System.debug('loadAccountList##'+response);
        return response;
    }
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadBondDetails(final String customerId, final String ISINCode, String regionName) {
        final String path = '/api/v1/bond/investments?customerId=';
        final HttpRequest req = con.createRequest('GET', path+customerId+'&isinCode='+ISINCode, regionName);
        //#CH08 : start
        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
           if(accs!= null && accs.size()>0){
           System.debug('x-canary added :'+accs.get(0).x_canary__pc);
             if(accs.get(0).x_canary__pc != null){
               req.setHeader('x-canary', accs.get(0).x_canary__pc);
                 }
           }
        //#CH08 : end
        req.setHeader('customerId',customerId);
        final ApiConnection.Response response = con.makeCallout(req);
        System.debug('******************** loadAccountDetails : Start ********************* ');

        System.debug(req.getEndpoint());    
        System.debug(req.getMethod());
        System.debug(req.getBody());
        System.debug(JSON.serializePretty(response));
        System.debug('******************** loadAccountDetails : End ********************* ');

        if (response.isSuccess && null != response.responseData) {
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
        }
        return response;
    }
    
    @AuraEnabled(cacheable=false)
     public static ApiConnection.Response loadCouponDetails(final String investment_id,String regionName,String customerId) {
        final String path = '/api/v1/bond/investments/distribute/'+investment_id;
        final HttpRequest req = con.createRequest('GET', path, regionName);
        //#CH08 : start
        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
           if(accs!= null && accs.size()>0){
           System.debug('x-canary added :'+accs.get(0).x_canary__pc);
             if(accs.get(0).x_canary__pc != null){
               req.setHeader('x-canary', accs.get(0).x_canary__pc);
                 }
           }
        //#CH08 : end
        req.setHeader('customerId',customerId);
        final ApiConnection.Response response = con.makeCallout(req);
        System.debug('******************** loadAccountDetails : Start ********************* ');
        System.debug(req.getEndpoint());    
        System.debug(req.getMethod());
        System.debug(req.getBody());
        System.debug(JSON.serializePretty(response));
        System.debug('******************** loadAccountDetails : End ********************* ');

        if (response.isSuccess && null != response.responseData) {
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
        }
        return response;
     }

}
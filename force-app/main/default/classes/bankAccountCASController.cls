/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 13-08-2023
*       Change History: 
*/
public class bankAccountCASController {
    private static ApiConnection con = new ApiConnection();
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadCASDet(String customerId, String accountId, String regionName) {
        final String path = '/api/v1/cas/inquires';
        final HttpRequest req = con.createRequest('POST', path, customerId, regionName);
        req.setBody('{"instrument_type":"IBAN","page_no":1,"instruments_ids":[{"instrument_id":"'+accountId+'"}],"page_size":"10"}');
        System.debug('End Point:'+req.getEndpoint());
        System.debug('Request Body:'+req.getBody());
        final ApiConnection.Response response = con.makeCallout(req);
        System.debug('Response Body:'+JSON.serializePretty(response));
        return response;
    }
}
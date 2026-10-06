/**
 * @author Charlie Nash (Westbrook)
 * @date 13/1/2022
 * @description:
 *
 * Used with the giftDetail.cmp Aura component.
 */

public class GiftingAPIController {
     @TestVisible // overwrite instance to provide custom connection in test class
    private static ApiConnection2 con = new ApiConnection2();

    @TestVisible // overwrite instance to provide custom DAO in test class
    private static GiftingAPIController dao = new GiftingAPIController();

    @AuraEnabled(cacheable=false)
    public static ApiConnection2.Response getSentGifts(final String customerId) {
        final String path = '/api/v1/gifts?status=sent';
        final HttpRequest req = con.createRequest('GET', path, customerId);
        System_Action__c action;
        ApiConnection2.Response response;
        response = con.makeCallout(req);
        response.errorData = 'No error found';
        System.debug('response' +response);

        return response;

    }

}
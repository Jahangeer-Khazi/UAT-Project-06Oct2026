/**
 * @author Charlie Nash (Westbrook)
 * @date Sunday 30th January 2022
 *
 * @description
 *
 * HTTP Callout mock class, to be used with test callouts when running test classes. Created by Charlie Nash (Westbrook).
 */

@isTest
global class CalloutMock implements HttpCalloutMock{
    global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('');
        return res;
    }
}
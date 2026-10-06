@isTest
global class FetchSTPFromBcrbAPIMockTest implements HttpCalloutMock {

    String RESPONSE_BODY = '{"meta":{"code":"CCRD-1500","message":"Credit card request status has been updated successfully."},"data":{}}';

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setBody(RESPONSE_BODY);
        resp.setStatusCode(200);
        return resp;
    }
}
/**
 * @author Jayanth
 * @date Création 07/12/2024
 * @date Modification 
 * @description MCK05_IDVVerificationServices - Apex class (part of the Mocking Framework) that contains the mock call for IDVVerificationServices
 * @history Modifications :
 *               
 */
@isTest

public class MCK05_IDVVerificationServices implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
      String endPoint = request.getEndpoint();
        System.debug('endPoint##'+endPoint);
        String method = request.getMethod();
        if( endPoint != null && endPoint.contains('/api/v1/id-and-verification/status') && method != null && method.contains('PUT')){
            return UpdateIDVVerificationStatus(request);
        }else if( endPoint != null && endPoint.contains('/api/v1/accounts/block-unblock') && method != null && method.contains('PUT')){
            return BlockAllAccount(request);
        }else{
            return getVerificationHistory(request);
        }
}
    
     public HTTPResponse getVerificationHistory(HTTPRequest request) {
            String body = '{"meta":{"code":"IDAV-1102","message":"Historyhasbeenretrivedsuccessfully"},"data":[{"id":"1","activity":"UPDATE_MOBILE_NUMBER","numberOfRetries":2,"status":"SUCCESS","crmCaseId":"123","createdDate":"2024-11-24T15:43:54","lastUpdatedDate":"2024-11-24T15:43:54"},{"id":"2","activity":"UPDATE_MOBILE_NUMBER","numberOfRetries":2,"status":"SUCCESS","crmCaseId":"123","createdDate":"2024-11-24T15:43:54","lastUpdatedDate":"2024-11-24T15:43:54"}]}';
            HTTPResponse res = new HTTPResponse();
         //  if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        } 
     Public HTTPResponse BlockAllAccount(HTTPRequest request) {
           String body = '{"meta":{"code":"IDAV-1104","message":"Statushasbeenupdatedsuccessfully"}}}';
            HTTPResponse res = new HTTPResponse();
         //  if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
    }
    Public HTTPResponse UpdateIDVVerificationStatus(HTTPRequest request) {
           String body = '{"meta":{"code":"IDAV-1104","message":"Statushasbeenupdatedsuccessfully"}}';
            HTTPResponse res = new HTTPResponse();
         //  if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
    }
}
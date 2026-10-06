/**
 * @author ANISS MBARKI
 * @date Création 07/03/2022
 * @date Modification 
 * @description MCK03_RaffleServiceApiCalls - Apex class (part of the Mocking Framework) that contains the mock call for raffle requirment
 * @history Modifications :
 *                  #CH01 29/12/2022 by Aniss Mbarki changes on body request of the api
 */
@isTest
public class MCK03_RaffleServiceApiCalls implements  ITF03_RaffleServiceApiCalls, HttpCalloutMock {
    
    public static Integer statusCodeGlobal {get; set;}
    
    public ApiConnection.Response callGetDrawListApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        return processCalloutResponse(callGetDrawListApi(request,statusCode));
    }
    public HttpResponse callGetDrawListApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String body = '{"meta":{"code":"RAFL-1020","message": "Draw list has been retrieved successfully "}, "data":{"draws": [{"id" : 1,"name": "draw_march_2022"},{"id" : 2,"name": "data_test_2022"}]}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }

    public ApiConnection.Response callGetDrawDataApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        return processCalloutResponse(callGetDrawDataApi(request,statusCode));
    }
    public HttpResponse callGetDrawDataApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // Create Manually json response For Test Class
        String csvData = 'TmFtZSxQcm9mZXNzaW9uClRlc3QxLFRlc3QxClRlc3QyLFRlc3QyCg==';
        String body = '{"meta":{"code":"RAFL-1020","message": "Reqeusted draw data has been retrieved successfully"},"data": {"fileMimeType" : "text/csv","fileName" : "drawData.csv","fileContent" : "'+csvData+'","fileSize": "40"}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }

    public HttpResponse callGetDrawWinnersApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        // One Winner (cif = 1245678)
        //#CH01 : add type and name to the fake respponse body
        String body = '{"meta":{"code":"RAFL-1000","message":"Request draw has been created successfully"},"data":{"draws":{"id":10953,"name":"1333","prizes":[{"type":"CASH","name":"Test Prize","numberOfWinners":1,"amount":1000.00,"winners":[{"customerId":"12345678","noOfChances":6,"eligibleBalance":100}],"prizeCurrency":{"code":"BHD","decimalPlaces":3}}]},"prizeCurrency":{"code":"BHD","decimalPlaces":3}}}';

        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }

    public HttpResponse callGetDrawSummaryApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        String body = '{"meta":{"code":"RAFL-1020","message": "Draw list has been retrieved successfully "},"data":{"drawFrom": "2022-03-05 00:00:00","drawTo": "2022-03-28 00:00:00","totalNumberOfCustomers": 8,"totalNumberOfChances": 16,"totalBalances":800.00,"totalEligibleBalances":800.00}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }

    public HttpResponse callCreateDrawApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        String body = '{"meta":{"code":"RAFL-1000","message": "Request draw has been created successfully "},"data":{"drawId": 1}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }
    
    public HttpResponse updateDrawStatusApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new HttpResponse();
        if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }

        String body = '{"meta":{"code":"RAFL-1025","message": "Draw status has been updated successfully"}}';
        response.setStatus('OK');
        response.setStatusCode(statusCode);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        
        return response ;   
    }


    public HttpResponse respond(HTTPRequest req) {
        System.debug('===========respond========');
        return callGetDrawDataApi(req, statusCodeGlobal);
    }
    
    public ApiConnection.Response processCalloutResponse(final HTTPResponse res) {
        final ApiConnection.Response response = new ApiConnection.Response();
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
        }catch(Exception ex){
                System.debug('ex.errorData=' + ex.getMessage());
        }
        return response;
    }
}
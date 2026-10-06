/**
 * @author ANISS MBARKI
 * @date Création 07/03/2022
 * @date Modification 
 * @description EM03_RaffleServiceApiCalls - Apex class (part of the Mocking Framework) Purpose : Reroute to the correct class Using Stub Concept  
 * @history Modifications : 
 */
public class EM03_RaffleServiceApiCalls implements  ITF03_RaffleServiceApiCalls {

    // WS STUB
    private static ITF03_RaffleServiceApiCalls stub {
        get {
           return callApi_STUB();
        }
    }

    // Private variable_Getter method
    private static ITF03_RaffleServiceApiCalls callApi_STUB(){
        ITF03_RaffleServiceApiCalls STUB;
       
        if (Test.isRunningTest()) {
           STUB = new MCK03_RaffleServiceApiCalls(); 
        } else {
           STUB = new DM03_RaffleServiceApiCalls();
        }

       return STUB;
    }

    // ****************  Api calls **********************************
    public static ApiConnection.Response callGetDrawListApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        ApiConnection.Response response = stub.callGetDrawListApi(con, request, statusCode);
        return response;     
    }
    public static ApiConnection.Response callGetDrawDataApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        ApiConnection.Response response = stub.callGetDrawDataApi(con, request, statusCode);
        return response;     
    }
    public static HttpResponse callGetDrawWinnersApi(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.callGetDrawWinnersApi(request, statusCode);
        return response;     
    }
    public static HttpResponse callGetDrawSummaryApi(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.callGetDrawSummaryApi(request, statusCode);
        return response;     
    }
    public static HttpResponse callCreateDrawApi(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.callCreateDrawApi(request, statusCode);
        return response;     
    }
    public static HttpResponse updateDrawStatusApi(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.updateDrawStatusApi(request, statusCode);
        return response;     
    }
}
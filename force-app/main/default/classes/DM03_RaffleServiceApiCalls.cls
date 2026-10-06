/**
 * @author ANISS MBARKI
 * @date Création 07/03/2022
 * @date Modification 
 * @description DM03_RaffleServiceApiCalls - Apex class (part of the Mocking Framework) that contains the real call to apis for raffle requirement
 * @history Modifications :
 */
public with sharing class DM03_RaffleServiceApiCalls implements ITF03_RaffleServiceApiCalls {

    public static ApiConnection.Response callGetDrawListApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        ApiConnection.Response response = con.makeCallout(request);
        return response ;
    }
    public static ApiConnection.Response callGetDrawDataApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        ApiConnection.Response response = con.makeCallout(request);
        return response ;
    }
    public static HttpResponse callGetDrawWinnersApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }
    public static HttpResponse callGetDrawSummaryApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request);
        return response ;
    }
    public static HttpResponse callCreateDrawApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }
    public static HttpResponse updateDrawStatusApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }
}
/**
 * @author ANISS MBARKI
 * @date Création 07/03/2022
 * @date Modification 
 * @description ITF03 - Interface class contains the definition of the different API calls for Raffle requirement
 * @history Modifications :
 */
public interface ITF03_RaffleServiceApiCalls {

    ApiConnection.Response callGetDrawListApi(ApiConnection con,HttpRequest request, Integer statusCode);
    ApiConnection.Response callGetDrawDataApi(ApiConnection con,HttpRequest request, Integer statusCode);
    HttpResponse callCreateDrawApi(HttpRequest request, Integer statusCode);
    HttpResponse callGetDrawSummaryApi(HttpRequest request, Integer statusCode);
    HttpResponse callGetDrawWinnersApi(HttpRequest request, Integer statusCode);
    HttpResponse updateDrawStatusApi(HttpRequest request, Integer statusCode);
}